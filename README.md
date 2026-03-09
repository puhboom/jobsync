# JobSync - Job Application Tracking System

JobSync is a comprehensive job application tracking system with AI-powered resume generation and job description parsing.

## Features

- **Job Management**: Track job applications through 9 stages (Saved, Applied, Phone Screen, Interview, Executive Call, Offered, Rejected, Withdrawn, Closed)
- **AI-Powered Job Parsing**: Paste job descriptions and automatically extract company, position, location, salary, requirements, and keywords
- **Resume Generation**: Generate tailored resumes using AI based on job descriptions
- **Resume Management**: Upload example resumes and templates for reference
- **ATS Analysis**: Analyze resumes against job descriptions for ATS compatibility
- **Technical Fit Analysis**: Evaluate technical fit scores for job applications
- **Dashboard Statistics**: View real-time stats on your job applications

## Architecture

- **Backend**: FastAPI (Python) - REST API
- **Database**: MariaDB
- **Frontend**: Flask (Python) - Web UI
- **AI Service**: FastAPI with Ollama integration
- **Deployment**: Docker Compose with separate containers

## Quick Start

### Prerequisites

- Docker and Docker Compose
- Ollama running locally (for AI features)
- Pull the AI model: `ollama pull llama3.2`

### Running the Application

1. Clone the repository

2. Create environment file from the example and configure values:
   ```bash
   cp .env.example .env
   ```
   
   Edit `.env` and update the values for your environment.

3. Start all services:
   ```bash
   docker-compose up -d
   ```

4. Access the application:
   - Frontend: http://localhost:5000
   - Backend API: http://localhost:8000
   - AI Service: http://localhost:8001

## Usage

### Adding a Job

1. Click "Add New Job" on the dashboard
2. Fill in company name, position, and other details
3. Optionally paste a job description - AI will automatically parse it
4. Save the job

### Generating a Resume

1. Navigate to Resumes page and upload example resumes (for content reference)
2. Upload resume templates (DOCX, for formatting)
3. Go to a job detail page
4. Scroll to "Generated Resumes" section
5. Select example/template if desired
6. Click "Generate Resume"
7. Edit or export the generated resume as DOCX

### Running Analyses

1. Generate a resume for the job first
2. Click "Run ATS Analysis" to check ATS compatibility
3. Click "Run Tech Fit Analysis" to evaluate technical fit

## API Endpoints

### Jobs
- `GET /api/jobs` - List all jobs
- `POST /api/jobs` - Create a job
- `GET /api/jobs/{id}` - Get job details
- `PUT /api/jobs/{id}` - Update job
- `DELETE /api/jobs/{id}` - Delete job
- `POST /api/jobs/{id}/parse-description` - Parse job description with AI

### Resumes
- `GET /api/resumes` - List base resumes
- `POST /api/resumes` - Upload resume
- `DELETE /api/resumes/{id}` - Delete resume
- `POST /api/generate-resume` - Generate tailored resume

### Analysis
- `POST /api/jobs/{id}/analyze-ats` - Run ATS analysis
- `POST /api/jobs/{id}/analyze-tech-fit` - Run tech fit analysis

## Development

### Running Locally (without Docker)

1. Start MariaDB

2. Copy `.env.example` to `.env` and configure for local development

3. Start backend:
   ```bash
   cd backend
   pip install -r requirements.txt
   uvicorn main:app --reload --port 8000
   ```

4. Start AI service:
   ```bash
   cd ai-service
   pip install -r requirements.txt
   uvicorn main:app --reload --port 8001
   ```

5. Start frontend:
   ```bash
   cd frontend
   pip install -r requirements.txt
   python app.py
   ```

## License

MIT License