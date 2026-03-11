# JobSync Data Model

## Overview
JobSync is a job application tracking system that helps users manage their job search workflow, store resumes, and analyze job fit.

## Entities

### User
Represents an authenticated user of the system.

| Field | Type | Constraints | Description |
|-------|------|--------------|-------------|
| id | INT | PK, AUTO_INCREMENT | Unique identifier |
| email | VARCHAR(255) | UNIQUE, NOT NULL | User email address |
| name | VARCHAR(255) | NULLABLE | Display name |
| picture | VARCHAR(500) | NULLABLE | Profile picture URL |
| created_at | TIMESTAMP | DEFAULT NOW() | Creation timestamp |
| updated_at | TIMESTAMP | ON UPDATE NOW() | Last update timestamp |

### OAuthLink
Links external OAuth providers (Google, LinkedIn) to users.

| Field | Type | Constraints | Description |
|-------|------|--------------|-------------|
| id | INT | PK, AUTO_INCREMENT | Unique identifier |
| user_id | INT | FK → users.id, NOT NULL | Reference to user |
| provider | VARCHAR(50) | NOT NULL | OAuth provider name |
| provider_user_id | VARCHAR(255) | NOT NULL | Provider's user ID |
| access_token | TEXT | NULLABLE | OAuth access token |
| refresh_token | TEXT | NULLABLE | OAuth refresh token |
| token_expires_at | TIMESTAMP | NULLABLE | Token expiration time |
| created_at | TIMESTAMP | DEFAULT NOW() | Creation timestamp |
| updated_at | TIMESTAMP | ON UPDATE NOW() | Last update timestamp |

**Unique Constraint**: (provider, provider_user_id)

### Job
Represents a job application.

| Field | Type | Constraints | Description |
|-------|------|--------------|-------------|
| id | INT | PK, AUTO_INCREMENT | Unique identifier |
| user_id | INT | FK → users.id | Reference to user |
| company | VARCHAR(255) | NOT NULL | Company name |
| position | VARCHAR(255) | NOT NULL | Job title |
| status | ENUM | DEFAULT 'saved' | Application status |
| job_url | TEXT | NULLABLE | Link to job posting |
| location | VARCHAR(255) | NULLABLE | Job location |
| remote_type | ENUM | DEFAULT 'on-site' | Work arrangement |
| salary | VARCHAR(100) | NULLABLE | Salary range |
| applied_date | DATE | NULLABLE | Date applied |
| notes | TEXT | NULLABLE | User notes |
| response_received | BOOLEAN | DEFAULT FALSE | Got a response? |
| raw_description | TEXT | NULLABLE | Original job description |
| requirements | TEXT | NULLABLE | Job requirements |
| nice_to_have | TEXT | NULLABLE | Nice-to-have skills |
| responsibilities | TEXT | NULLABLE | Job responsibilities |
| keywords | TEXT | NULLABLE | Extracted keywords |
| credentials | TEXT | NULLABLE | Required credentials |
| created_at | TIMESTAMP | DEFAULT NOW() | Creation timestamp |
| updated_at | TIMESTAMP | ON UPDATE NOW() | Last update timestamp |

**Indexes**: status, company, applied_date, user_id

**Status Values**: saved, applied, phone_screen, interview, executive_call, offered, rejected, withdrawn, closed

**Remote Type Values**: remote, hybrid, on-site

### ApplicationHistory
Tracks status changes for a job application.

| Field | Type | Constraints | Description |
|-------|------|--------------|-------------|
| id | INT | PK, AUTO_INCREMENT | Unique identifier |
| job_id | INT | FK → jobs.id, NOT NULL | Reference to job |
| status | VARCHAR(50) | NOT NULL | Status at this point |
| notes | TEXT | NULLABLE | Notes about this change |
| created_at | TIMESTAMP | DEFAULT NOW() | Timestamp |

### BaseResume
Stores user's uploaded resume templates/examples.

| Field | Type | Constraints | Description |
|-------|------|--------------|-------------|
| id | INT | PK, AUTO_INCREMENT | Unique identifier |
| user_id | INT | FK → users.id | Reference to user |
| filename | VARCHAR(255) | NOT NULL | Original filename |
| content | LONGBLOB | NULLABLE | Raw file content |
| content_type | VARCHAR(100) | NULLABLE | MIME type |
| file_type | ENUM | NOT NULL | example or template |
| text_content | LONGTEXT | NULLABLE | Extracted text |
| created_at | TIMESTAMP | DEFAULT NOW() | Creation timestamp |
| updated_at | TIMESTAMP | ON UPDATE NOW() | Last update timestamp |

### GeneratedResume
AI-generated resumes tailored to specific jobs.

| Field | Type | Constraints | Description |
|-------|------|--------------|-------------|
| id | INT | PK, AUTO_INCREMENT | Unique identifier |
| job_id | INT | FK → jobs.id, NOT NULL | Reference to job |
| content | LONGTEXT | NOT NULL | Generated resume content |
| created_at | TIMESTAMP | DEFAULT NOW() | Creation timestamp |
| updated_at | TIMESTAMP | ON UPDATE NOW() | Last update timestamp |

### ATSAnalysis
ATS (Applicant Tracking System) compatibility analysis.

| Field | Type | Constraints | Description |
|-------|------|--------------|-------------|
| id | INT | PK, AUTO_INCREMENT | Unique identifier |
| job_id | INT | FK → jobs.id, NOT NULL | Reference to job |
| resume_id | INT | FK → generated_resumes.id | Reference to resume |
| parse_score | DECIMAL(5,2) | NULLABLE | How well parsed |
| keyword_match | DECIMAL(5,2) | NULLABLE | Keyword match % |
| search_relevance | DECIMAL(5,2) | NULLABLE | Search relevance |
| overall_score | DECIMAL(5,2) | NULLABLE | Overall fit score |
| issues | TEXT | NULLABLE | Parsing issues |
| recommendations | TEXT | NULLABLE | Improvement tips |
| keywords_found | TEXT | NULLABLE | Keywords found |
| keywords_missing | TEXT | NULLABLE | Keywords missing |
| created_at | TIMESTAMP | DEFAULT NOW() | Analysis timestamp |

### TechFitAnalysis
Technical skills fit analysis for a job-resume pair.

| Field | Type | Constraints | Description |
|-------|------|--------------|-------------|
| id | INT | PK, AUTO_INCREMENT | Unique identifier |
| job_id | INT | FK → jobs.id, NOT NULL | Reference to job |
| resume_id | INT | FK → generated_resumes.id | Reference to resume |
| skill_match | DECIMAL(5,2) | NULLABLE | Skill match % |
| experience_relevance | DECIMAL(5,2) | NULLABLE | Experience relevance |
| leadership_fit | DECIMAL(5,2) | NULLABLE | Leadership fit |
| strengths | TEXT | NULLABLE | Candidate strengths |
| gaps | TEXT | NULLABLE | Skill gaps |
| recommendations | TEXT | NULLABLE | Recommendations |
| created_at | TIMESTAMP | DEFAULT NOW() | Analysis timestamp |

## Relationships

```
User (1) ───< (N) OAuthLink
User (1) ───< (N) Job
User (1) ───< (N) BaseResume

Job (1) ───< (N) ApplicationHistory
Job (1) ───< (N) GeneratedResume
Job (1) ───< (N) ATSAnalysis
Job (1) ───< (N) TechFitAnalysis

GeneratedResume (1) ───< (N) ATSAnalysis
GeneratedResume (1) ───< (N) TechFitAnalysis
```
