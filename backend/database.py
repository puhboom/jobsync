import os
from contextlib import asynccontextmanager
from datetime import datetime
from typing import Optional, List
import base64

from sqlalchemy import (
    create_engine,
    Column,
    Integer,
    String,
    Text,
    Boolean,
    DateTime,
    Enum,
    ForeignKey,
    DECIMAL,
    Date,
    LargeBinary,
)
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, relationship
from sqlalchemy.sql import func

DATABASE_SERVER = os.getenv("DATABASE_SERVER", "db")
DATABASE_PORT = os.getenv("DATABASE_PORT", "3306")
DATABASE_NAME = os.getenv("DATABASE_NAME", "jobsync")
DATABASE_USER = os.getenv("DATABASE_USER", "jobsync")
DATABASE_PASSWORD = os.getenv("DATABASE_PASSWORD", "jobsyncpass")
DATABASE_URL = f"mysql+pymysql://{DATABASE_USER}:{DATABASE_PASSWORD}@{DATABASE_SERVER}:{DATABASE_PORT}/{DATABASE_NAME}"

engine = create_engine(DATABASE_URL, pool_pre_ping=True, pool_recycle=3600)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()


class Job(Base):
    __tablename__ = "jobs"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    company = Column(String(255), nullable=False)
    position = Column(String(255), nullable=False)
    status = Column(
        Enum(
            "saved",
            "applied",
            "phone_screen",
            "interview",
            "executive_call",
            "offered",
            "rejected",
            "withdrawn",
            "closed",
        ),
        default="saved",
    )
    job_url = Column(Text, nullable=True)
    location = Column(String(255), nullable=True)
    remote_type = Column(Enum("remote", "hybrid", "on-site"), default="on-site")
    salary = Column(String(100), nullable=True)
    applied_date = Column(Date, nullable=True)
    notes = Column(Text, nullable=True)
    response_received = Column(Boolean, default=False)
    created_at = Column(DateTime, server_default=func.now())
    updated_at = Column(DateTime, server_default=func.now(), onupdate=func.now())

    raw_description = Column(Text, nullable=True)
    requirements = Column(Text, nullable=True)
    nice_to_have = Column(Text, nullable=True)
    responsibilities = Column(Text, nullable=True)
    keywords = Column(Text, nullable=True)
    credentials = Column(Text, nullable=True)

    history = relationship(
        "ApplicationHistory", back_populates="job", cascade="all, delete-orphan"
    )
    generated_resumes = relationship(
        "GeneratedResume", back_populates="job", cascade="all, delete-orphan"
    )


class ApplicationHistory(Base):
    __tablename__ = "application_history"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    job_id = Column(Integer, ForeignKey("jobs.id", ondelete="CASCADE"), nullable=False)
    status = Column(String(50), nullable=False)
    notes = Column(Text, nullable=True)
    created_at = Column(DateTime, server_default=func.now())

    job = relationship("Job", back_populates="history")


class BaseResume(Base):
    __tablename__ = "base_resumes"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    filename = Column(String(255), nullable=False)
    content = Column(LargeBinary, nullable=True)
    content_type = Column(String(100), nullable=True)
    file_type = Column(Enum("example", "template"), nullable=False)
    text_content = Column(Text, nullable=True)
    created_at = Column(DateTime, server_default=func.now())
    updated_at = Column(DateTime, server_default=func.now(), onupdate=func.now())


class GeneratedResume(Base):
    __tablename__ = "generated_resumes"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    job_id = Column(Integer, ForeignKey("jobs.id", ondelete="CASCADE"), nullable=False)
    content = Column(Text, nullable=False)
    created_at = Column(DateTime, server_default=func.now())
    updated_at = Column(DateTime, server_default=func.now(), onupdate=func.now())

    job = relationship("Job", back_populates="generated_resumes")


class ATSAnalysis(Base):
    __tablename__ = "ats_analysis"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    job_id = Column(Integer, ForeignKey("jobs.id", ondelete="CASCADE"), nullable=False)
    resume_id = Column(
        Integer, ForeignKey("generated_resumes.id", ondelete="CASCADE"), nullable=True
    )
    parse_score = Column(DECIMAL(5, 2), nullable=True)
    keyword_match = Column(DECIMAL(5, 2), nullable=True)
    search_relevance = Column(DECIMAL(5, 2), nullable=True)
    overall_score = Column(DECIMAL(5, 2), nullable=True)
    issues = Column(Text, nullable=True)
    recommendations = Column(Text, nullable=True)
    keywords_found = Column(Text, nullable=True)
    keywords_missing = Column(Text, nullable=True)
    created_at = Column(DateTime, server_default=func.now())


class TechFitAnalysis(Base):
    __tablename__ = "tech_fit_analysis"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    job_id = Column(Integer, ForeignKey("jobs.id", ondelete="CASCADE"), nullable=False)
    resume_id = Column(
        Integer, ForeignKey("generated_resumes.id", ondelete="CASCADE"), nullable=True
    )
    skill_match = Column(DECIMAL(5, 2), nullable=True)
    experience_relevance = Column(DECIMAL(5, 2), nullable=True)
    leadership_fit = Column(DECIMAL(5, 2), nullable=True)
    strengths = Column(Text, nullable=True)
    gaps = Column(Text, nullable=True)
    recommendations = Column(Text, nullable=True)
    created_at = Column(DateTime, server_default=func.now())


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


def init_db():
    Base.metadata.create_all(bind=engine)
