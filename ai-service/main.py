import os
import json
import httpx
from pathlib import Path
from typing import Optional

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

app = FastAPI(title="JobSync AI Service", version="2.0.0")

OLLAMA_HOST = (
    os.getenv("OLLAMA_HOST", "http://localhost:11434")
    .replace("http://", "")
    .replace("https://", "")
)
OLLAMA_MODEL = os.getenv("OLLAMA_MODEL", "llama3.2")

AGENTS_DIR = Path(__file__).parent.parent / "agents"


def load_agent_prompt(agent_name: str) -> str:
    path = AGENTS_DIR / f"{agent_name}.md"
    if path.exists():
        content = path.read_text()
        lines = content.split("\n")
        filtered = []
        in_frontmatter = False
        for line in lines:
            if line.strip() == "---":
                in_frontmatter = not in_frontmatter
                continue
            if not in_frontmatter:
                filtered.append(line)
        return "\n".join(filtered).strip()
    return ""


JOB_PARSER_PROMPT = load_agent_prompt("job-description-archiver")
RESUME_TAILOR_PROMPT = load_agent_prompt("executive-resume-tailor")
ATS_REVIEWER_PROMPT = load_agent_prompt("ats-resume-reviewer")
TECH_MANAGER_PROMPT = load_agent_prompt("technical-hiring-manager")
HR_PROFESSIONAL_PROMPT = load_agent_prompt("hr-professional")


def get_ollama_url():
    return f"http://{OLLAMA_HOST}/api/generate"


async def call_ollama(prompt: str, timeout: int = 120) -> str:
    url = get_ollama_url()
    payload = {"model": OLLAMA_MODEL, "prompt": prompt, "stream": False}

    async with httpx.AsyncClient(timeout=timeout) as client:
        try:
            response = await client.post(url, json=payload)
            response.raise_for_status()
            result = response.json()
            return result.get("response", "")
        except httpx.HTTPError as e:
            raise HTTPException(status_code=500, detail=f"Ollama error: {str(e)}")


def extract_json(response: str) -> dict:
    try:
        json_start = response.find("{")
        json_end = response.rfind("}") + 1
        if json_start >= 0 and json_end > json_start:
            json_str = response[json_start:json_end]
            return json.loads(json_str)
    except json.JSONDecodeError:
        pass
    return {}


class JobDescriptionRequest(BaseModel):
    description: str


class ResumeGenerateRequest(BaseModel):
    job_description: str
    job_requirements: Optional[str] = None
    job_keywords: Optional[str] = None
    example_resume: Optional[str] = None
    template_format: Optional[str] = None


class ATSAnalysisRequest(BaseModel):
    resume: str
    job_description: str
    keywords: Optional[str] = None


class TechFitAnalysisRequest(BaseModel):
    resume: str
    job_description: str
    requirements: Optional[str] = None


class ResumeReviewRequest(BaseModel):
    job_description: str
    job_requirements: Optional[str] = None
    job_keywords: Optional[str] = None
    example_resume: Optional[str] = None
    resume: Optional[str] = None


@app.get("/")
def root():
    return {"message": "JobSync AI Service", "version": "2.0.0"}


@app.get("/health")
def health():
    return {"status": "healthy"}


@app.post("/parse-job")
async def parse_job(request: JobDescriptionRequest):
    agent_context = JOB_PARSER_PROMPT if JOB_PARSER_PROMPT else ""

    prompt = f"""{agent_context}

JOB DESCRIPTION TO PARSE:
{request.description}

Extract the structured data and return it as a JSON object with these fields:
- company: The company name (string or null)
- position: The job title/position (string or null)
- title: Same as position (string or null)
- location: The location (string or null)
- salary: Salary information as a string (string or null)
- max_pay: Maximum salary as a number (number or null)
- remote_type: One of "remote", "hybrid", or "on-site"
- requirements: Must-have requirements as a single string (comma-separated or null) - map from "required_experience"
- nice_to_have: Nice-to-have qualifications as a single string (comma-separated or null) - map from "preferred_experience"
- responsibilities: Main responsibilities as a single string (comma-separated or null)
- keywords: Important keywords and skills (comma-separated string or null)
- credentials: Required certifications or credentials (comma-separated string or null)

Respond ONLY with valid JSON. No explanations or additional text."""

    response = await call_ollama(prompt, timeout=60)
    result = extract_json(response)

    if not result:
        result = {}

    if result.get("title") and not result.get("position"):
        result["position"] = result["title"]
    if result.get("position") and not result.get("title"):
        result["title"] = result["position"]

    return result


@app.post("/generate-resume")
async def generate_resume(request: ResumeGenerateRequest):
    agent_context = RESUME_TAILOR_PROMPT if RESUME_TAILOR_PROMPT else ""

    prompt_parts = []

    if agent_context:
        prompt_parts.append(agent_context)
        prompt_parts.append("")
        prompt_parts.append("---")
        prompt_parts.append("")
        prompt_parts.append("NOW APPLY YOUR EXPERTISE TO THIS SPECIFIC TASK:")
        prompt_parts.append("")

    prompt_parts.append(
        "Generate a professional, ATS-friendly resume tailored for this specific job."
    )

    prompt_parts.append("")
    prompt_parts.append("JOB DESCRIPTION:")
    prompt_parts.append(request.job_description)
    prompt_parts.append("")

    if request.job_requirements:
        prompt_parts.append("REQUIREMENTS:")
        prompt_parts.append(request.job_requirements)
        prompt_parts.append("")

    if request.job_keywords:
        prompt_parts.append("KEY KEYWORDS TO INCLUDE:")
        prompt_parts.append(request.job_keywords)
        prompt_parts.append("")

    if request.example_resume:
        prompt_parts.extend(
            [
                "CANDIDATE'S COMPLETE RESUME (USE THIS EXACT INFORMATION):",
                request.example_resume,
                "",
                "CRITICAL - YOU MUST PRESERVE EVERYTHING:",
                "- Include EVERY SINGLE job/role from this resume - do NOT skip, merge, truncate, or summarize ANY positions",
                "- Include ALL work experience entries, even if there are many roles",
                "- Include the EXACT name, email, phone, and location from this resume",
                "- Include your EXACT LinkedIn URL if present",
                "- Include ALL education entries",
                "- Include ALL skills and certifications",
                "- The output resume MUST be complete with all positions listed",
                "",
            ]
        )

    if request.template_format:
        prompt_parts.append(
            "RESUME TEMPLATE (follow this exact structure and formatting):"
        )
        prompt_parts.append(request.template_format)
        prompt_parts.append("")

    prompt_parts.extend(
        [
            "Generate a complete, detailed resume that:",
            "1. Includes ALL of your work experience - every single position must be present",
            "2. Uses YOUR EXACT personal information (name, email, phone, location, LinkedIn) from your resume",
            "3. Matches the job requirements closely by emphasizing relevant skills in each role",
            "4. Incorporates relevant keywords naturally throughout",
            "5. Is formatted clearly with sections for Summary, Skills, Experience, and Education",
            "6. Uses the S.T.A.R. method: Scope, Transformation, Architecture, Results",
            "7. Leads with BUSINESS OUTCOME before technical implementation",
            "8. Uses strong verbs: architected, strategized, transformed, scaled, optimized, led, drove, pioneered",
            "",
            "ABSOLUTE REQUIREMENTS:",
            "- DO NOT truncate, summarize, or omit ANY work experience entries",
            "- DO NOT invent or change personal information",
            "- Write a COMPLETE resume including ALL positions from your background",
            "- Experience MUST be in REVERSE CHRONOLOGICAL ORDER (most recent first)",
            "- It is better to be comprehensive than brief",
            "",
            "Write the complete resume now (include ALL positions):",
        ]
    )

    prompt = "\n".join(prompt_parts)
    response = await call_ollama(prompt, timeout=120)

    return {"resume": response.strip()}


@app.post("/analyze-ats")
async def analyze_ats(request: ATSAnalysisRequest):
    agent_context = ATS_REVIEWER_PROMPT if ATS_REVIEWER_PROMPT else ""

    prompt_parts = []

    if agent_context:
        prompt_parts.append(agent_context)
        prompt_parts.append("")
        prompt_parts.append("---")
        prompt_parts.append("")
        prompt_parts.append("NOW ANALYZE THIS SPECIFIC RESUME AND JOB:")
        prompt_parts.append("")

    prompt_parts.extend(
        [
            "Analyze this resume against the job description for ATS compatibility and job alignment.",
            "",
            "RESUME:",
            request.resume,
            "",
            "JOB DESCRIPTION:",
            request.job_description,
            "",
        ]
    )

    if request.keywords:
        prompt_parts.append(f"KEYWORDS: {request.keywords}")
        prompt_parts.append("")

    prompt_parts.extend(
        [
            "Provide your analysis as a JSON object with these exact fields:",
            "- parse_score: A score 0-100 for how well the resume is formatted for ATS parsing (number)",
            "- keyword_match: A score 0-100 for keyword matching with the job description (number)",
            "- search_relevance: A score 0-100 for search relevance (number)",
            "- overall_score: Overall ATS compatibility score 0-100 (number)",
            "- issues: Critical issues found as a comma-separated string or null",
            "- recommendations: Recommendations to improve ATS score as a comma-separated string or null",
            "- keywords_found: Important keywords found in the resume as a comma-separated string or null",
            "- keywords_missing: Important keywords from the job that are missing as a comma-separated string or null",
            "",
            "Respond ONLY with valid JSON. No explanations.",
        ]
    )

    prompt = "\n".join(prompt_parts)
    response = await call_ollama(prompt, timeout=60)
    result = extract_json(response)

    if not result:
        result = {
            "parse_score": 0.0,
            "keyword_match": 0.0,
            "search_relevance": 0.0,
            "overall_score": 0.0,
            "issues": None,
            "recommendations": None,
            "keywords_found": None,
            "keywords_missing": None,
        }
    else:
        result["parse_score"] = float(result.get("parse_score", 0))
        result["keyword_match"] = float(result.get("keyword_match", 0))
        result["search_relevance"] = float(result.get("search_relevance", 0))
        result["overall_score"] = float(result.get("overall_score", 0))

    return result


@app.post("/analyze-tech-fit")
async def analyze_tech_fit(request: TechFitAnalysisRequest):
    agent_context = TECH_MANAGER_PROMPT if TECH_MANAGER_PROMPT else ""

    prompt_parts = []

    if agent_context:
        prompt_parts.append(agent_context)
        prompt_parts.append("")
        prompt_parts.append("---")
        prompt_parts.append("")
        prompt_parts.append("NOW EVALUATE THIS SPECIFIC RESUME AGAINST THE JOB:")
        prompt_parts.append("")

    prompt_parts.extend(
        [
            "Evaluate the technical fit of this resume against the job description.",
            "",
            "RESUME:",
            request.resume,
            "",
            "JOB DESCRIPTION:",
            request.job_description,
            "",
        ]
    )

    if request.requirements:
        prompt_parts.append(f"REQUIREMENTS: {request.requirements}")
        prompt_parts.append("")

    prompt_parts.extend(
        [
            "Provide your analysis as a JSON object with these exact fields:",
            "- skill_match: A score 0-100 for how well the skills match the job requirements (number)",
            "- experience_relevance: A score 0-100 for how relevant the experience is (number)",
            "- leadership_fit: A score 0-100 for leadership capability alignment, 0 if not a leadership role (number)",
            "- strengths: Key technical strengths as a comma-separated string or null",
            "- gaps: Skill or experience gaps, note if critical or concerning, as a comma-separated string or null",
            "- recommendations: Actionable recommendations to improve technical fit as a comma-separated string or null",
            "",
            "Respond ONLY with valid JSON. No explanations.",
        ]
    )

    prompt = "\n".join(prompt_parts)
    response = await call_ollama(prompt, timeout=60)
    result = extract_json(response)

    if not result:
        result = {
            "skill_match": 0.0,
            "experience_relevance": 0.0,
            "leadership_fit": 0.0,
            "strengths": None,
            "gaps": None,
            "recommendations": None,
        }
    else:
        result["skill_match"] = float(result.get("skill_match", 0))
        result["experience_relevance"] = float(result.get("experience_relevance", 0))
        result["leadership_fit"] = float(result.get("leadership_fit", 0))

    return result


@app.post("/review-resume")
async def review_resume(request: ResumeReviewRequest):
    resume_content = request.resume or request.example_resume or ""

    if not resume_content:
        raise HTTPException(
            status_code=400, detail="Either resume or example_resume is required"
        )

    ats_task = analyze_ats(
        ATSAnalysisRequest(
            resume=resume_content,
            job_description=request.job_description,
            keywords=request.job_keywords,
        )
    )

    tech_task = analyze_tech_fit(
        TechFitAnalysisRequest(
            resume=resume_content,
            job_description=request.job_description,
            requirements=request.job_requirements,
        )
    )

    import asyncio

    ats_result, tech_result = await asyncio.gather(ats_task, tech_task)

    hr_prompt_parts = [
        HR_PROFESSIONAL_PROMPT
        if HR_PROFESSIONAL_PROMPT
        else "You are an HR professional evaluating resumes.",
        "",
        "---",
        "",
        "NOW EVALUATE THIS RESUME FROM AN HR PERSPECTIVE:",
        "",
        "RESUME:",
        resume_content,
        "",
        "JOB DESCRIPTION:",
        request.job_description,
        "",
        "Provide your analysis as a JSON object with these exact fields:",
        "- career_trajectory: Score 0-100 for career progression quality (number)",
        "- presentation_quality: Score 0-100 for resume presentation (number)",
        "- cultural_fit: Score 0-100 for cultural alignment indicators (number)",
        "- overall_hr_score: Overall HR assessment score 0-100 (number)",
        "- career_story_assessment: Brief assessment of career narrative (string)",
        "- strengths: Career/presentation strengths as a comma-separated string or null",
        "- concerns: Concerns or red flags as a comma-separated string or null",
        "- recommendations: Recommendations to strengthen presentation as a comma-separated string or null",
        "",
        "Respond ONLY with valid JSON. No explanations.",
    ]
    hr_prompt = "\n".join(hr_prompt_parts)
    hr_response = await call_ollama(hr_prompt, timeout=60)
    hr_result = extract_json(hr_response)

    if not hr_result:
        hr_result = {
            "career_trajectory": 0.0,
            "presentation_quality": 0.0,
            "cultural_fit": 0.0,
            "overall_hr_score": 0.0,
            "career_story_assessment": None,
            "strengths": None,
            "concerns": None,
            "recommendations": None,
        }
    else:
        for key in [
            "career_trajectory",
            "presentation_quality",
            "cultural_fit",
            "overall_hr_score",
        ]:
            hr_result[key] = float(hr_result.get(key, 0))

    ats_score = ats_result.get("overall_score", 0)
    tech_score = (
        tech_result.get("skill_match", 0) + tech_result.get("experience_relevance", 0)
    ) / 2
    hr_score = hr_result.get("overall_hr_score", 0)
    overall_fit = round((ats_score * 0.3 + tech_score * 0.4 + hr_score * 0.3), 1)

    return {
        "overall_fit_score": overall_fit,
        "ats_analysis": ats_result,
        "tech_fit_analysis": tech_result,
        "hr_assessment": hr_result,
        "cover_letter_topics": _extract_cover_letter_topics(tech_result, hr_result),
        "key_strengths": _extract_key_strengths(ats_result, tech_result, hr_result),
    }


def _extract_cover_letter_topics(tech_result: dict, hr_result: dict) -> list:
    topics = []
    gaps = tech_result.get("gaps") or ""
    if gaps:
        topics.extend([g.strip() for g in gaps.split(",") if g.strip()][:3])
    concerns = hr_result.get("concerns") or ""
    if concerns:
        topics.extend([c.strip() for c in concerns.split(",") if c.strip()][:2])
    return topics[:5]


def _extract_key_strengths(
    ats_result: dict, tech_result: dict, hr_result: dict
) -> list:
    strengths = []
    for source in [ats_result, tech_result, hr_result]:
        s = source.get("strengths") or source.get("keywords_found") or ""
        if s:
            strengths.extend([x.strip() for x in s.split(",") if x.strip()][:2])
    return list(dict.fromkeys(strengths))[:5]


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="0.0.0.0", port=8001)
