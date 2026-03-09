from pydantic import BaseModel
from typing import Optional, List
from datetime import date
from enum import Enum


class JobStatus(str, Enum):
    saved = "saved"
    applied = "applied"
    phone_screen = "phone_screen"
    interview = "interview"
    executive_call = "executive_call"
    offered = "offered"
    rejected = "rejected"
    withdrawn = "withdrawn"
    closed = "closed"


class RemoteType(str, Enum):
    remote = "remote"
    hybrid = "hybrid"
    on_site = "on-site"


class ResumeType(str, Enum):
    example = "example"
    template = "template"


class JobCreate(BaseModel):
    company: str
    position: str
    status: JobStatus = JobStatus.saved
    job_url: Optional[str] = None
    location: Optional[str] = None
    remote_type: Optional[RemoteType] = None
    salary: Optional[str] = None
    applied_date: Optional[date] = None
    notes: Optional[str] = None
    response_received: bool = False


class JobDescriptionParse(BaseModel):
    description: str


class JobUpdate(BaseModel):
    company: Optional[str] = None
    position: Optional[str] = None
    status: Optional[JobStatus] = None
    job_url: Optional[str] = None
    location: Optional[str] = None
    remote_type: Optional[RemoteType] = None
    salary: Optional[str] = None
    applied_date: Optional[date] = None
    notes: Optional[str] = None
    response_received: Optional[bool] = None


class Job(BaseModel):
    id: int
    company: str
    position: str
    status: JobStatus
    job_url: Optional[str]
    location: Optional[str]
    remote_type: Optional[RemoteType]
    salary: Optional[str]
    applied_date: Optional[date]
    notes: Optional[str]
    response_received: bool
    created_at: str
    updated_at: str
    requirements: Optional[str] = None
    nice_to_have: Optional[str] = None
    responsibilities: Optional[str] = None
    keywords: Optional[str] = None
    credentials: Optional[str] = None

    class Config:
        from_attributes = True


class ApplicationHistory(BaseModel):
    id: int
    job_id: int
    status: str
    notes: Optional[str]
    created_at: str

    class Config:
        from_attributes = True


class ApplicationHistoryCreate(BaseModel):
    status: str
    notes: Optional[str] = None


class BaseResumeCreate(BaseModel):
    filename: str
    content: str  # Base64 encoded
    content_type: str
    file_type: ResumeType
    text_content: Optional[str] = None


class BaseResume(BaseModel):
    id: int
    filename: str
    file_type: ResumeType
    created_at: str

    class Config:
        from_attributes = True


class GeneratedResume(BaseModel):
    id: int
    job_id: int
    content: str
    created_at: str
    updated_at: str

    class Config:
        from_attributes = True


class ATSAnalysis(BaseModel):
    id: int
    job_id: int
    resume_id: Optional[int]
    parse_score: float
    keyword_match: float
    search_relevance: float
    overall_score: float
    issues: Optional[str]
    recommendations: Optional[str]
    keywords_found: Optional[str]
    keywords_missing: Optional[str]

    class Config:
        from_attributes = True


class TechFitAnalysis(BaseModel):
    id: int
    job_id: int
    resume_id: Optional[int]
    skill_match: float
    experience_relevance: float
    leadership_fit: float
    strengths: Optional[str]
    gaps: Optional[str]
    recommendations: Optional[str]

    class Config:
        from_attributes = True


class DashboardStats(BaseModel):
    total_jobs: int
    active_applications: int
    interviews: int
    offers: int


class ResumeGenerateRequest(BaseModel):
    job_id: int
    example_resume_id: Optional[int] = None
    template_resume_id: Optional[int] = None
