import os
from dotenv import load_dotenv

load_dotenv()

from flask import (
    Flask,
    render_template,
    request,
    redirect,
    url_for,
    flash,
    jsonify,
    session,
)
import requests

BACKEND_URL = os.getenv("BACKEND_URL", "http://backend:8000")
FRONTEND_URL = os.getenv("FRONTEND_URL", "http://localhost:5000")

app = Flask(__name__)
app.secret_key = os.getenv(
    "APPLICATION_SECRET_KEY", "dev-secret-key-change-in-production"
)


def get_backend_url(endpoint):
    return f"{BACKEND_URL}{endpoint}"


def call_backend(method, endpoint, data=None, params=None, use_auth=False):
    url = get_backend_url(endpoint)
    headers = {}
    if use_auth and session.get("auth_token"):
        headers["Authorization"] = f"Bearer {session.get('auth_token')}"
    try:
        if method == "GET":
            response = requests.get(url, params=params, headers=headers, timeout=30)
        elif method == "POST":
            response = requests.post(url, json=data, headers=headers, timeout=120)
        elif method == "PUT":
            response = requests.put(url, json=data, headers=headers, timeout=30)
        elif method == "DELETE":
            response = requests.delete(url, headers=headers, timeout=30)
        else:
            return None

        response.raise_for_status()
        return response.json()
    except requests.exceptions.RequestException as e:
        app.logger.error(f"Backend error: {e}")
        return None


def get_current_user():
    token = session.get("auth_token")
    if not token:
        return None
    user = call_backend("GET", f"/api/auth/me?token={token}")
    return user


def require_auth(f):
    from functools import wraps

    @wraps(f)
    def decorated_function(*args, **kwargs):
        if not session.get("auth_token"):
            flash("Please log in to access this page.", "error")
            return redirect(url_for("login"))
        return f(*args, **kwargs)

    return decorated_function


@app.route("/")
def index():
    if not session.get("auth_token"):
        return redirect(url_for("login"))
    return redirect(url_for("dashboard"))


@app.route("/dashboard")
@require_auth
def dashboard():
    user = get_current_user()
    if not user:
        return redirect(url_for("login"))

    stats = call_backend("GET", "/api/dashboard/stats")
    if stats is None:
        stats = {
            "total_jobs": 0,
            "active_applications": 0,
            "interviews": 0,
            "offers": 0,
        }

    jobs = call_backend("GET", "/api/jobs")
    if jobs is None:
        jobs = []

    active_jobs = [
        j
        for j in jobs
        if j.get("status")
        in ["saved", "applied", "phone_screen", "interview", "executive_call"]
    ]
    archived_jobs = [
        j
        for j in jobs
        if j.get("status") in ["offered", "rejected", "withdrawn", "closed"]
    ]

    return render_template(
        "dashboard.html",
        stats=stats,
        active_jobs=active_jobs,
        archived_jobs=archived_jobs,
    )


@app.route("/jobs")
@require_auth
def jobs():
    status_filter = request.args.get("status", None)
    params = {}
    if status_filter:
        params["status"] = status_filter

    jobs_list = call_backend("GET", "/api/jobs", params=params)
    if jobs_list is None:
        jobs_list = []

    return render_template("jobs.html", jobs=jobs_list, status_filter=status_filter)


@app.route("/jobs/new", methods=["GET", "POST"])
@require_auth
def new_job():
    if request.method == "POST":
        data = {
            "company": request.form.get("company", ""),
            "position": request.form.get("position", ""),
            "status": request.form.get("status", "saved"),
            "job_url": request.form.get("job_url") or None,
            "location": request.form.get("location") or None,
            "remote_type": request.form.get("remote_type") or None,
            "salary": request.form.get("salary") or None,
            "applied_date": request.form.get("applied_date") or None,
            "notes": request.form.get("notes") or None,
            "response_received": request.form.get("response_received") == "on",
        }

        result = call_backend("POST", "/api/jobs", data=data)

        if result:
            description = request.form.get("description", "")
            if description:
                call_backend(
                    "POST",
                    f"/api/jobs/{result['id']}/parse-description",
                    data={"description": description},
                )

            flash("Job created successfully!", "success")
            return redirect(url_for("job_detail", job_id=result["id"]))
        else:
            flash("Failed to create job.", "error")

    return render_template("job_form.html", job=None)


@app.route("/jobs/<int:job_id>")
@require_auth
def job_detail(job_id):
    job = call_backend("GET", f"/api/jobs/{job_id}")
    if job is None:
        flash("Job not found.", "error")
        return redirect(url_for("dashboard"))

    history = call_backend("GET", f"/api/jobs/{job_id}/history")
    if history is None:
        history = []

    generated_resumes = call_backend("GET", f"/api/jobs/{job_id}/generated-resumes")
    if generated_resumes is None:
        generated_resumes = []

    ats_analyses = call_backend("GET", f"/api/jobs/{job_id}/ats-analyses")
    if ats_analyses is None:
        ats_analyses = []

    tech_fit_analyses = call_backend("GET", f"/api/jobs/{job_id}/tech-fit-analyses")
    if tech_fit_analyses is None:
        tech_fit_analyses = []

    base_resumes = call_backend("GET", "/api/resumes")
    if base_resumes is None:
        base_resumes = []

    example_resumes = [r for r in base_resumes if r.get("file_type") == "example"]
    template_resumes = [r for r in base_resumes if r.get("file_type") == "template"]

    return render_template(
        "job_detail.html",
        job=job,
        history=history,
        generated_resumes=generated_resumes,
        ats_analyses=ats_analyses,
        tech_fit_analyses=tech_fit_analyses,
        example_resumes=example_resumes,
        template_resumes=template_resumes,
    )


@app.route("/jobs/<int:job_id>/edit", methods=["GET", "POST"])
@require_auth
def edit_job(job_id):
    job = call_backend("GET", f"/api/jobs/{job_id}")
    if job is None:
        flash("Job not found.", "error")
        return redirect(url_for("dashboard"))

    if request.method == "POST":
        data = {}
        fields = [
            "company",
            "position",
            "status",
            "job_url",
            "location",
            "remote_type",
            "salary",
            "applied_date",
            "notes",
        ]
        for field in fields:
            if request.form.get(field):
                data[field] = request.form.get(field)

        data["response_received"] = request.form.get("response_received") == "on"

        result = call_backend("PUT", f"/api/jobs/{job_id}", data=data)

        if result:
            flash("Job updated successfully!", "success")
            return redirect(url_for("job_detail", job_id=job_id))
        else:
            flash("Failed to update job.", "error")

    return render_template("job_form.html", job=job)


@app.route("/jobs/<int:job_id>/delete", methods=["POST"])
@require_auth
def delete_job(job_id):
    result = call_backend("DELETE", f"/api/jobs/{job_id}")
    if result:
        flash("Job deleted successfully.", "success")
    else:
        flash("Failed to delete job.", "error")
    return redirect(url_for("dashboard"))


@app.route("/jobs/<int:job_id>/parse", methods=["POST"])
@require_auth
def parse_description(job_id):
    description = request.form.get("description", "")
    result = call_backend(
        "POST",
        f"/api/jobs/{job_id}/parse-description",
        data={"description": description},
    )

    if result:
        flash("Job description parsed successfully!", "success")
    else:
        flash("Failed to parse job description.", "error")

    return redirect(url_for("job_detail", job_id=job_id))


@app.route("/jobs/<int:job_id>/history", methods=["POST"])
@require_auth
def add_history(job_id):
    data = {
        "status": request.form.get("status"),
        "notes": request.form.get("notes") or None,
    }

    result = call_backend("POST", f"/api/jobs/{job_id}/history", data=data)

    if result:
        flash("Status updated successfully!", "success")
    else:
        flash("Failed to update status.", "error")

    return redirect(url_for("job_detail", job_id=job_id))


@app.route("/resumes")
@require_auth
def resumes():
    base_resumes = call_backend("GET", "/api/resumes")
    if base_resumes is None:
        base_resumes = []

    examples = [r for r in base_resumes if r.get("file_type") == "example"]
    templates = [r for r in base_resumes if r.get("file_type") == "template"]

    return render_template("resumes.html", examples=examples, templates=templates)


@app.route("/resumes/upload", methods=["POST"])
@require_auth
def upload_resume():
    file_type = request.form.get("file_type")

    if "file" not in request.files:
        flash("No file provided.", "error")
        return redirect(url_for("resumes"))

    file = request.files["file"]

    if file.filename == "":
        flash("No file selected.", "error")
        return redirect(url_for("resumes"))

    files = {"file": (file.filename, file.read(), file.content_type)}
    data = {"file_type": file_type}

    try:
        response = requests.post(
            get_backend_url("/api/resumes"), files=files, data=data, timeout=30
        )
        response.raise_for_status()
        flash("Resume uploaded successfully!", "success")
    except requests.exceptions.RequestException:
        flash("Failed to upload resume.", "error")

    return redirect(url_for("resumes"))


@app.route("/resumes/<int:resume_id>/delete", methods=["POST"])
@require_auth
def delete_resume(resume_id):
    result = call_backend("DELETE", f"/api/resumes/{resume_id}")
    if result:
        flash("Resume deleted successfully.", "success")
    else:
        flash("Failed to delete resume.", "error")
    return redirect(url_for("resumes"))


@app.route("/jobs/<int:job_id>/generate-resume", methods=["POST"])
@require_auth
def generate_resume(job_id):
    example_resume_id = request.form.get("example_resume_id") or None
    template_resume_id = request.form.get("template_resume_id") or None

    data = {"job_id": job_id}
    if example_resume_id:
        data["example_resume_id"] = int(example_resume_id)
    if template_resume_id:
        data["template_resume_id"] = int(template_resume_id)

    result = call_backend("POST", "/api/generate-resume", data=data)

    if result:
        flash("Resume generated successfully!", "success")
    else:
        flash("Failed to generate resume.", "error")

    return redirect(url_for("job_detail", job_id=job_id))


@app.route("/generated-resumes/<int:resume_id>/edit", methods=["GET", "POST"])
@require_auth
def edit_generated_resume(resume_id):
    resume = call_backend("GET", f"/api/generated-resumes/{resume_id}")
    if resume is None:
        flash("Resume not found.", "error")
        return redirect(url_for("dashboard"))

    if request.method == "POST":
        content = request.form.get("content", "")
        result = call_backend(
            "PUT", f"/api/generated-resumes/{resume_id}", data={"content": content}
        )

        if result:
            flash("Resume updated successfully!", "success")
            return redirect(url_for("job_detail", job_id=resume.get("job_id")))
        else:
            flash("Failed to update resume.", "error")

    return render_template("resume_edit.html", resume=resume)


@app.route("/generated-resumes/<int:resume_id>/export")
@require_auth
def export_resume(resume_id):
    try:
        response = requests.get(
            get_backend_url(f"/api/generated-resumes/{resume_id}/export"), timeout=30
        )
        response.raise_for_status()

        from flask import Response

        return Response(
            response.content,
            mimetype="application/vnd.openxmlformats-officedocument.wordprocessingml.document",
            headers={
                "Content-Disposition": response.headers.get(
                    "Content-Disposition", "attachment"
                )
            },
        )
    except requests.exceptions.RequestException as e:
        flash("Failed to export resume.", "error")
        return redirect(url_for("dashboard"))


@app.route("/jobs/<int:job_id>/analyze-ats", methods=["POST"])
@require_auth
def analyze_ats(job_id):
    resume_id = request.form.get("resume_id") or None
    data = {}
    if resume_id:
        data["resume_id"] = int(resume_id)

    result = call_backend("POST", f"/api/jobs/{job_id}/analyze-ats", data=data)

    if result:
        flash("ATS analysis completed!", "success")
    else:
        flash("Failed to perform ATS analysis.", "error")

    return redirect(url_for("job_detail", job_id=job_id))


@app.route("/jobs/<int:job_id>/analyze-tech-fit", methods=["POST"])
@require_auth
def analyze_tech_fit(job_id):
    resume_id = request.form.get("resume_id") or None
    data = {}
    if resume_id:
        data["resume_id"] = int(resume_id)

    result = call_backend("POST", f"/api/jobs/{job_id}/analyze-tech-fit", data=data)

    if result:
        flash("Technical fit analysis completed!", "success")
    else:
        flash("Failed to perform technical fit analysis.", "error")

    return redirect(url_for("job_detail", job_id=job_id))


STATUS_DISPLAY = {
    "saved": "Saved",
    "applied": "Applied",
    "phone_screen": "Phone Screen",
    "interview": "Interview",
    "executive_call": "Executive Call",
    "offered": "Offered",
    "rejected": "Rejected",
    "withdrawn": "Withdrawn",
    "closed": "Closed",
}

STATUS_COLORS = {
    "saved": "secondary",
    "applied": "primary",
    "phone_screen": "info",
    "interview": "warning",
    "executive_call": "warning",
    "offered": "success",
    "rejected": "danger",
    "withdrawn": "secondary",
    "closed": "dark",
}

REMOTE_DISPLAY = {"remote": "Remote", "hybrid": "Hybrid", "on-site": "On-site"}


@app.template_filter("status_display")
def status_display_filter(status):
    return STATUS_DISPLAY.get(status, status)


@app.template_filter("status_color")
def status_color_filter(status):
    return STATUS_COLORS.get(status, "secondary")


@app.template_filter("remote_display")
def remote_display_filter(remote):
    return REMOTE_DISPLAY.get(remote, remote)


@app.route("/login")
def login():
    user = get_current_user()
    if user:
        return redirect(url_for("dashboard"))

    google_oauth_url = ""
    linkedin_oauth_url = ""

    google_client_id = os.getenv("GOOGLE_CLIENT_ID", "")
    linkedin_client_id = os.getenv("LINKEDIN_CLIENT_ID", "")
    redirect_uri = f"{FRONTEND_URL}/oauth"

    if google_client_id:
        scope = "openid email profile"
        google_oauth_url = f"https://accounts.google.com/o/oauth2/v2/auth?client_id={google_client_id}&redirect_uri={redirect_uri}/google&response_type=code&scope={scope}&access_type=offline"

    if linkedin_client_id:
        scope = "openid email profile"
        linkedin_oauth_url = f"https://www.linkedin.com/oauth/v2/authorization?client_id={linkedin_client_id}&redirect_uri={redirect_uri}/linkedin&response_type=code&scope={scope}"

    return render_template(
        "login.html",
        google_oauth_url=google_oauth_url,
        linkedin_oauth_url=linkedin_oauth_url,
        GOOGLE_CLIENT_ID=google_client_id,
        LINKEDIN_CLIENT_ID=linkedin_client_id,
    )


@app.route("/logout")
def logout():
    session.clear()
    flash("You have been logged out.", "info")
    return redirect(url_for("login"))


@app.route("/oauth/<provider>")
def oauth_callback(provider):
    code = request.args.get("code")
    if not code:
        flash("Authorization failed: No code provided.", "error")
        return redirect(url_for("login"))

    token = session.get("auth_token")
    if token:
        callback_data = {"provider": provider, "code": f"{token}||{code}"}
        result = call_backend("POST", "/api/auth/link-oauth", data=callback_data)
    else:
        callback_data = {"provider": provider, "code": code}
        result = call_backend("POST", "/api/auth/oauth-callback", data=callback_data)

    if result and result.get("token"):
        session["auth_token"] = result["token"]
        session["user"] = result.get("user")
        flash("Successfully logged in!", "success")
        return redirect(url_for("dashboard"))
    else:
        flash("Login failed. Please try again.", "error")
        return redirect(url_for("login"))


@app.route("/link-oauth/<provider>")
def link_oauth(provider):
    if not session.get("auth_token"):
        flash("You must be logged in to link accounts.", "error")
        return redirect(url_for("login"))

    client_id = ""
    redirect_uri = ""

    if provider == "google":
        client_id = os.getenv("GOOGLE_CLIENT_ID", "")
        redirect_uri = f"{FRONTEND_URL}/oauth/google"
        scope = "openid email profile"
    elif provider == "linkedin":
        client_id = os.getenv("LINKEDIN_CLIENT_ID", "")
        redirect_uri = f"{FRONTEND_URL}/oauth/linkedin"
        scope = "openid email profile"
    else:
        flash("Invalid provider.", "error")
        return redirect(url_for("dashboard"))

    if not client_id:
        flash("OAuth not configured. Please contact administrator.", "error")
        return redirect(url_for("dashboard"))

    auth_url = ""
    if provider == "google":
        auth_url = f"https://accounts.google.com/o/oauth2/v2/auth?client_id={client_id}&redirect_uri={redirect_uri}&response_type=code&scope={scope}&access_type=offline"
    elif provider == "linkedin":
        auth_url = f"https://www.linkedin.com/oauth/v2/authorization?client_id={client_id}&redirect_uri={redirect_uri}&response_type=code&scope={scope}"

    return redirect(auth_url)


@app.route("/account")
@require_auth
def account():
    user = get_current_user()
    if not user:
        flash("Please log in to view your account.", "error")
        return redirect(url_for("login"))

    base_resumes = call_backend("GET", "/api/resumes")
    if base_resumes is None:
        base_resumes = []

    examples = [r for r in base_resumes if r.get("file_type") == "example"]
    templates = [r for r in base_resumes if r.get("file_type") == "template"]

    return render_template(
        "account.html", user=user, examples=examples, templates=templates
    )


@app.route("/account/upload-picture", methods=["POST"])
@require_auth
def upload_profile_picture():
    if "picture" not in request.files:
        flash("No file provided.", "error")
        return redirect(url_for("account"))

    file = request.files["picture"]

    if file.filename == "":
        flash("No file selected.", "error")
        return redirect(url_for("account"))

    token = session.get("auth_token")
    files = {"file": (file.filename, file.read(), file.content_type)}
    data = {"token": token}

    try:
        response = requests.post(
            get_backend_url("/api/auth/upload-picture"),
            files=files,
            data=data,
            timeout=30,
        )
        response.raise_for_status()
        result = response.json()
        session["user"] = result
        flash("Profile picture updated successfully!", "success")
    except requests.exceptions.RequestException:
        flash("Failed to upload profile picture.", "error")

    return redirect(url_for("account"))


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
