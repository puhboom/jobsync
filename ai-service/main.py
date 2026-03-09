import os
from typing import Optional
import json
import httpx

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

app = FastAPI(title="JobSync AI Service", version="1.0.0")

OLLAMA_HOST = os.getenv("OLLAMA_HOST", "host.docker.internal:11434")
OLLAMA_MODEL = os.getenv("OLLAMA_MODEL", "llama3.2")


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


@app.get("/")
def root():
    return {"message": "JobSync AI Service", "version": "1.0.0"}


@app.get("/health")
def health():
    return {"status": "healthy"}


@app.post("/parse-job")
async def parse_job(request: JobDescriptionRequest):
    prompt = f"""You are a job description parser. Extract structured information from the following job description and return it as a JSON object with these fields:
- company: The company name (string or null)
- position: The job title/position (string or null)
- location: The location where the job is based (string or null)
- salary: Salary information if mentioned (string or null)
- remote_type: One of "remote", "hybrid", or "on-site" based on the job
- requirements: Must-have requirements as a single string (comma-separated list or null)
- nice_to_have: Nice-to-have qualifications as a single string (comma-separated list or null)
- responsibilities: Main responsibilities as a single string (comma-separated list or null)
- keywords: Important keywords and skills from the job (comma-separated list or null)
- credentials: Required certifications or credentials (comma-separated list or null)

Job Description:
{request.description}

Respond ONLY with valid JSON. No explanations or additional text."""  # noqa: E501

    response = await call_ollama(prompt, timeout=60)

    try:
        json_start = response.find("{")
        json_end = response.rfind("}") + 1
        if json_start >= 0 and json_end > json_start:
            json_str = response[json_start:json_end]
            result = json.loads(json_str)
        else:
            result = {}
    except json.JSONDecodeError:
        result = {}

    return result


@app.post("/generate-resume")
async def generate_resume(request: ResumeGenerateRequest):
    prompt_parts = [
        "You are an expert resume writer. Generate a professional, ATS-friendly resume tailored for this specific job.",
        "",
        "JOB DESCRIPTION:",
        request.job_description,
        "",
    ]

    if request.job_requirements:
        prompt_parts.append("REQUIREMENTS:")
        prompt_parts.append(request.job_requirements)
        prompt_parts.append("")

    if request.job_keywords:
        prompt_parts.append("KEY KEYWORDS TO INCLUDE:")
        prompt_parts.append(request.job_keywords)
        prompt_parts.append("")

    if request.example_resume:
        prompt_parts.append(
            "REFERENCE EXAMPLE RESUME (use this style and content as inspiration):"
        )
        prompt_parts.append(request.example_resume)
        prompt_parts.append("")

    if request.template_format:
        prompt_parts.append("TEMPLATE FORMAT (follow this structure):")
        prompt_parts.append(request.template_format)
        prompt_parts.append("")

    prompt_parts.extend(
        [
            "Generate a complete, professional resume that:",
            "1. Matches the job requirements closely",
            "2. Uses relevant keywords from the job description",
            "3. Highlights relevant experience and skills",
            "4. Is formatted clearly with sections for Summary, Experience, Education, and Skills",
            "",
            "Write the complete resume now:",
        ]
    )

    prompt = "\n".join(prompt_parts)
    response = await call_ollama(prompt, timeout=120)

    return {"resume": response.strip()}


@app.post("/analyze-ats")
async def analyze_ats(request: ATSAnalysisRequest):
    prompt = f"""You are an ATS (Applicant Tracking System) analyzer. Analyze this resume against the job description and provide a detailed ATS score.

RESUME:
{request.resume}

JOB DESCRIPTION:
{request.job_description}

{f"KEYWORDS: {request.keywords}" if request.keywords else ""}

Provide your analysis as a JSON object with these fields:
- parse_score: A score 0-100 for how well the resume is formatted (number)
- keyword_match: A score 0-100 for keyword matching (number)
- search_relevance: A score 0-100 for search relevance (number)
- overall_score: Overall ATS score 0-100 (number)
- issues: List of critical issues found (comma-separated string or null)
- recommendations: List of recommendations to improve ATS score (comma-separated string or null)
- keywords_found: Important keywords found in the resume (comma-separated string or null)
- keywords_missing: Important keywords from the job that are missing (comma-separated string or null)

Respond ONLY with valid JSON. No explanations."""  # noqa: E501

    response = await call_ollama(prompt, timeout=60)

    try:
        json_start = response.find("{")
        json_end = response.rfind("}") + 1
        if json_start >= 0 and json_end > json_start:
            json_str = response[json_start:json_end]
            result = json.loads(json_str)
            result["parse_score"] = float(result.get("parse_score", 0))
            result["keyword_match"] = float(result.get("keyword_match", 0))
            result["search_relevance"] = float(result.get("search_relevance", 0))
            result["overall_score"] = float(result.get("overall_score", 0))
        else:
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
    except json.JSONDecodeError:
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

    return result


@app.post("/analyze-tech-fit")
async def analyze_tech_fit(request: TechFitAnalysisRequest):
    prompt = f"""You are a technical fit analyzer. Analyze this resume against the job description and provide a technical fit score.

RESUME:
{request.resume}

JOB DESCRIPTION:
{request.job_description}

{f"REQUIREMENTS: {request.requirements}" if request.requirements else ""}

Provide your analysis as a JSON object with these fields:
- skill_match: A score 0-100 for how well the skills match (number)
- experience_relevance: A score 0-100 for relevant experience (number)
- leadership_fit: A score 0-100 for leadership fit if applicable (number)
- strengths: List of key strengths (comma-separated string or null)
- gaps: List of skill or experience gaps (comma-separated string or null)
- recommendations: List of recommendations to improve fit (comma-separated string or null)

Respond ONLY with valid JSON. No explanations."""  # noqa: E501

    response = await call_ollama(prompt, timeout=60)

    try:
        json_start = response.find("{")
        json_end = response.rfind("}") + 1
        if json_start >= 0 and json_end > json_start:
            json_str = response[json_start:json_end]
            result = json.loads(json_str)
            result["skill_match"] = float(result.get("skill_match", 0))
            result["experience_relevance"] = float(
                result.get("experience_relevance", 0)
            )
            result["leadership_fit"] = float(result.get("leadership_fit", 0))
        else:
            result = {
                "skill_match": 0.0,
                "experience_relevance": 0.0,
                "leadership_fit": 0.0,
                "strengths": None,
                "gaps": None,
                "recommendations": None,
            }
    except json.JSONDecodeError:
        result = {
            "skill_match": 0.0,
            "experience_relevance": 0.0,
            "leadership_fit": 0.0,
            "strengths": None,
            "gaps": None,
            "recommendations": None,
        }

    return result


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="0.0.0.0", port=8001)
