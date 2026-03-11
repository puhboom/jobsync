-- JobSync Database Schema

CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    name VARCHAR(255),
    picture TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS oauth_links (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    provider VARCHAR(50) NOT NULL,
    provider_user_id VARCHAR(255) NOT NULL,
    access_token TEXT,
    refresh_token TEXT,
    token_expires_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY unique_provider_user (provider, provider_user_id)
);

CREATE TABLE IF NOT EXISTS jobs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    company VARCHAR(255) NOT NULL,
    position VARCHAR(255) NOT NULL,
    status ENUM('saved', 'applied', 'phone_screen', 'interview', 'executive_call', 'offered', 'rejected', 'withdrawn', 'closed') DEFAULT 'saved',
    job_url TEXT,
    location VARCHAR(255),
    remote_type ENUM('remote', 'hybrid', 'on-site') DEFAULT 'on-site',
    salary VARCHAR(100),
    applied_date DATE,
    notes TEXT,
    response_received BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Parsed job description data
    raw_description TEXT,
    requirements TEXT,
    nice_to_have TEXT,
    responsibilities TEXT,
    keywords TEXT,
    credentials TEXT,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS application_history (
    id INT AUTO_INCREMENT PRIMARY KEY,
    job_id INT NOT NULL,
    status VARCHAR(50) NOT NULL,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (job_id) REFERENCES jobs(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS base_resumes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    filename VARCHAR(255) NOT NULL,
    content LONGBLOB,
    content_type VARCHAR(100),
    file_type ENUM('example', 'template') NOT NULL,
    text_content LONGTEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS generated_resumes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    job_id INT NOT NULL,
    content LONGTEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (job_id) REFERENCES jobs(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS ats_analysis (
    id INT AUTO_INCREMENT PRIMARY KEY,
    job_id INT NOT NULL,
    resume_id INT,
    parse_score DECIMAL(5,2),
    keyword_match DECIMAL(5,2),
    search_relevance DECIMAL(5,2),
    overall_score DECIMAL(5,2),
    issues TEXT,
    recommendations TEXT,
    keywords_found TEXT,
    keywords_missing TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (job_id) REFERENCES jobs(id) ON DELETE CASCADE,
    FOREIGN KEY (resume_id) REFERENCES generated_resumes(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS tech_fit_analysis (
    id INT AUTO_INCREMENT PRIMARY KEY,
    job_id INT NOT NULL,
    resume_id INT,
    skill_match DECIMAL(5,2),
    experience_relevance DECIMAL(5,2),
    leadership_fit DECIMAL(5,2),
    strengths TEXT,
    gaps TEXT,
    recommendations TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (job_id) REFERENCES jobs(id) ON DELETE CASCADE,
    FOREIGN KEY (resume_id) REFERENCES generated_resumes(id) ON DELETE CASCADE
);

-- Indexes for performance
CREATE INDEX idx_jobs_status ON jobs(status);
CREATE INDEX idx_jobs_company ON jobs(company);
CREATE INDEX idx_jobs_applied_date ON jobs(applied_date);
CREATE INDEX idx_jobs_user_id ON jobs(user_id);
CREATE INDEX idx_oauth_links_user_id ON oauth_links(user_id);
CREATE INDEX idx_application_history_job_id ON application_history(job_id);
CREATE INDEX idx_application_history_created ON application_history(created_at);