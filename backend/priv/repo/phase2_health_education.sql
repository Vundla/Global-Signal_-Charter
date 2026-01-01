-- Phase 2 Extension: Health & Education
-- "Health heals, education empowers the covenant"

-- Health Projects Table
CREATE TABLE IF NOT EXISTS health_projects (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    country_code VARCHAR(3) NOT NULL REFERENCES countries(code),
    project_name TEXT NOT NULL,
    health_type TEXT, -- clinic, vaccine program, maternal health, mental health, etc.
    beneficiaries BIGINT, -- number of people served
    facilities_count INT, -- number of clinics/hospitals
    annual_budget_usd BIGINT,
    status VARCHAR(50) DEFAULT 'active',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Education Projects Table
CREATE TABLE IF NOT EXISTS education_projects (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    country_code VARCHAR(3) NOT NULL REFERENCES countries(code),
    project_name TEXT NOT NULL,
    education_level TEXT, -- primary, secondary, tertiary, vocational
    students_reached BIGINT,
    teachers_trained INT,
    schools_built INT,
    annual_budget_usd BIGINT,
    status VARCHAR(50) DEFAULT 'active',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_health_country ON health_projects(country_code);
CREATE INDEX IF NOT EXISTS idx_education_country ON education_projects(country_code);

-- Add update triggers
CREATE TRIGGER update_health_updated_at BEFORE UPDATE ON health_projects
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_education_updated_at BEFORE UPDATE ON education_projects
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Seed sample data
INSERT INTO health_projects (country_code, project_name, health_type, beneficiaries, facilities_count, annual_budget_usd) VALUES
('ZAF', 'Ubuntu Health Initiative', 'primary care', 5000000, 250, 50000000),
('ZWE', 'Maternal Health Program', 'maternal health', 800000, 45, 8000000),
('NGA', 'Vaccine Rollout Campaign', 'vaccine program', 50000000, 500, 100000000),
('KEN', 'Mental Health Network', 'mental health', 2000000, 30, 15000000),
('IND', 'Rural Clinic Expansion', 'primary care', 100000000, 1000, 200000000),
('BRA', 'Amazon Health Corps', 'primary care', 30000000, 400, 75000000);

INSERT INTO education_projects (country_code, project_name, education_level, students_reached, teachers_trained, schools_built, annual_budget_usd) VALUES
('ZAF', 'Ubuntu Schools Network', 'primary', 3000000, 15000, 500, 75000000),
('ZWE', 'Secondary STEM Initiative', 'secondary', 500000, 5000, 100, 20000000),
('NGA', 'Teacher Training Academy', 'vocational', 100000, 10000, 50, 30000000),
('KEN', 'Digital Learning Platform', 'secondary', 2000000, 8000, 200, 25000000),
('IND', 'Rural Education Expansion', 'primary', 50000000, 200000, 5000, 300000000),
('RWA', 'Girls Education Fund', 'secondary', 1000000, 5000, 100, 20000000);
