# JobSync - Functional Requirements (Actual Implementation)

## Overview
JobSync is a job application tracking system with AI-powered resume generation and job description parsing.

## User Authentication
- Signup with Google or LinkedIn OAuth
- Google OAuth integration (working)
- LinkedIn OAuth integration (working)
- No password-based authentication (by design)
- No password reset capability (by design - no password system)
- Session-based authentication with Flask

## Job Management

### Job Description Processing
- Paste plain text job descriptions
- AI automatically parses job details (company, position, location, salary, remote type)
- Extracts requirements (must-have/nice-to-have), responsibilities, keywords, and credentials
- URL support: URL can be stored for reference but is NOT auto-fetched (not implemented)

### Job Tracker Fields
- Company name
- Position/Job title
- Status/Stage (dropdown with 9 options)
- Job URL (stored for reference)
- Location (where job is based)
- Remote capability (Remote/Hybrid/On-site)
- Salary information
- Applied date
- Notes/Comments
- Response received (checkbox)
- Application history timeline

### Job Stages (Implemented)
1. Saved
2. Applied
3. Phone Screen
4. Interview
5. Executive Call
6. Offered
7. Rejected
8. Withdrawn
9. Closed

## Resume Management

### Base Resumes
- Upload example resumes (PDF, DOCX, TXT) - used for AI reference
- Upload resume templates (DOCX only) - used for formatting generated resumes
- View uploaded base resumes
- Delete uploaded base resumes

### Generated Resumes
- AI generates tailored resume for specific job applications
- Uses example resumes for content reference
- Uses template for formatting structure
- View generated resume in editor
- Edit generated resume text
- Export to DOCX format
- Regenerate resume for same job

## AI Agent Capabilities

### Job Parser Agent
- Parses pasted job descriptions using LLM
- Extracts structured data: company, position, location, salary, remote type
- Identifies requirements (must-have/nice-to-have)
- Extracts responsibilities and keywords

### Resume Generator Agent
- Generates customized resume for specific job
- Matches content from example resumes to job requirements
- Applies template formatting
- Returns plain text resume content

### ATS Analysis Agent
- Analyzes resume against job description
- Provides parse score, keyword match, search relevance, overall score
- Identifies critical issues and recommendations
- Shows keywords found and missing

### Technical Fit Analysis Agent
- Evaluates technical fit of resume for job
- Returns skill match, experience relevance, leadership fit scores
- Identifies strengths, gaps, and recommendations

## Dashboard & Statistics
- Live statistics: Total jobs, Active applications, Interviews, Offers
- Filter tabs: All, Active, Interviewing, Offers, Archived
- Two-column layout: Active and Archived applications
- Quick action buttons on job cards
- Job cards with position, company, location, status badge, remote type badge, salary badge

## Technical Architecture
- **Backend API**: FastAPI (Python) on port 8000
- **Database**: MariaDB 10.11
- **Frontend Web UI**: Flask (Python) on port 5005
- **AI Service**: FastAPI + Ollama local LLM integration on port 8001
- **File Storage**: Base64 encoded in database (LONGBLOB)
- **Deployment**: Docker Compose with separate containers for frontend, database, backend, AI services

## Agent Specifications (Defined but Not Integrated)
The `agents/` folder contains detailed agent specifications:
- job-description-archiver.md
- executive-resume-tailor.md
- ats-resume-reviewer.md
- technical-hiring-manager.md
- hr-professional.md
- resume-review-agent.md
- template-formatter.md
- Status: These agent specifications are documented but NOT integrated into the current AI service

## Additional Features
- User authentication with OAuth (Google, LinkedIn)
- Account page showing linked OAuth providers
- Ability to link additional OAuth providers to existing account
- Multi-user support (in progress - auth works, API isolation pending)

## Not Currently Implemented
- True URL scraping from job boards (job URL stored but not auto-fetched)
- Personal instructions for resume generation
- Industry panel feedback/tuning
- Advanced agent orchestration system (current implementation uses direct LLM prompts)