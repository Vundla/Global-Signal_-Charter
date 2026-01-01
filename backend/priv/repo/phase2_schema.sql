-- Phase 2: Economic Orchestration Schema
-- "Agriculture feeds, minerals sustain, energy empowers, technology connects"

-- Agriculture Projects Table
CREATE TABLE IF NOT EXISTS agriculture_projects (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    country_code VARCHAR(3) NOT NULL REFERENCES countries(code),
    project_name TEXT NOT NULL,
    crop_type TEXT,
    yield_estimate BIGINT, -- in kilograms
    irrigation_method TEXT,
    contribution_usd BIGINT,
    status VARCHAR(50) DEFAULT 'active',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Minerals & Resources Table
CREATE TABLE IF NOT EXISTS mineral_projects (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    country_code VARCHAR(3) NOT NULL REFERENCES countries(code),
    resource_type TEXT NOT NULL, -- gold, lithium, copper, etc.
    extraction_volume BIGINT, -- in metric tons
    profit_usd BIGINT,
    local_reinvestment_usd BIGINT, -- 50% goes to communities
    global_contribution_usd BIGINT, -- 30% to covenant
    status VARCHAR(50) DEFAULT 'active',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Energy Projects Table
CREATE TABLE IF NOT EXISTS energy_projects (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    country_code VARCHAR(3) NOT NULL REFERENCES countries(code),
    project_name TEXT NOT NULL,
    source_type TEXT NOT NULL, -- solar, wind, hydro, geothermal
    capacity_mw BIGINT, -- megawatts
    uptime_percent NUMERIC(5,2), -- 0-100
    profit_usd BIGINT,
    resilience_reserve_usd BIGINT, -- 20% for maintenance
    status VARCHAR(50) DEFAULT 'active',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Technology & Connectivity Table
CREATE TABLE IF NOT EXISTS tech_projects (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    country_code VARCHAR(3) NOT NULL REFERENCES countries(code),
    project_name TEXT NOT NULL,
    sector TEXT, -- education, health, fintech, connectivity
    offline_capability BOOLEAN DEFAULT TRUE,
    users_served BIGINT,
    contribution_usd BIGINT,
    status VARCHAR(50) DEFAULT 'active',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_agriculture_country ON agriculture_projects(country_code);
CREATE INDEX IF NOT EXISTS idx_mineral_country ON mineral_projects(country_code);
CREATE INDEX IF NOT EXISTS idx_energy_country ON energy_projects(country_code);
CREATE INDEX IF NOT EXISTS idx_tech_country ON tech_projects(country_code);

-- Create update triggers
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_agriculture_updated_at BEFORE UPDATE ON agriculture_projects
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_mineral_updated_at BEFORE UPDATE ON mineral_projects
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_energy_updated_at BEFORE UPDATE ON energy_projects
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_tech_updated_at BEFORE UPDATE ON tech_projects
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Seed sample data
INSERT INTO agriculture_projects (country_code, project_name, crop_type, yield_estimate, irrigation_method, contribution_usd) VALUES
('ZAF', 'Ubuntu Seed Bank Initiative', 'maize', 500000000, 'drip irrigation', 5000000),
('ZWE', 'Solar Pump Network', 'wheat', 100000000, 'solar-powered', 2000000),
('NGA', 'Cassava Resilience Program', 'cassava', 800000000, 'rainwater harvesting', 8000000),
('KEN', 'Highland Tea Cooperative', 'tea', 50000000, 'stream diversion', 3000000);

INSERT INTO mineral_projects (country_code, resource_type, extraction_volume, profit_usd, local_reinvestment_usd, global_contribution_usd) VALUES
('ZAF', 'platinum', 150000, 500000000, 250000000, 150000000),
('ZWE', 'lithium', 80000, 200000000, 100000000, 60000000),
('CHL', 'copper', 500000, 1000000000, 500000000, 300000000),
('AUS', 'iron ore', 900000, 1500000000, 750000000, 450000000);

INSERT INTO energy_projects (country_code, project_name, source_type, capacity_mw, uptime_percent, profit_usd, resilience_reserve_usd) VALUES
('ZAF', 'Karoo Solar Farm', 'solar', 500, 92.5, 100000000, 20000000),
('KEN', 'Lake Turkana Wind', 'wind', 310, 88.0, 80000000, 16000000),
('NOR', 'Bergen Hydro Plant', 'hydro', 800, 95.0, 200000000, 40000000),
('ISL', 'Geothermal Valley', 'geothermal', 600, 98.0, 150000000, 30000000);

INSERT INTO tech_projects (country_code, project_name, sector, offline_capability, users_served, contribution_usd) VALUES
('ZAF', 'Ubuntu Net Fiber Towers', 'connectivity', true, 5000000, 10000000),
('RWA', 'Health Connect Offline', 'health', true, 2000000, 5000000),
('IND', 'Edu-Seva Digital', 'education', true, 50000000, 25000000),
('KEN', 'M-Pesa Covenant', 'fintech', true, 30000000, 15000000);

-- Covenant statistics view
CREATE OR REPLACE VIEW covenant_sectoral_stats AS
SELECT 
    'agriculture' as sector,
    COUNT(*) as total_projects,
    SUM(contribution_usd) as total_contribution,
    COUNT(DISTINCT country_code) as countries_participating
FROM agriculture_projects
WHERE status = 'active'
UNION ALL
SELECT 
    'minerals',
    COUNT(*),
    SUM(global_contribution_usd),
    COUNT(DISTINCT country_code)
FROM mineral_projects
WHERE status = 'active'
UNION ALL
SELECT 
    'energy',
    COUNT(*),
    SUM(profit_usd),
    COUNT(DISTINCT country_code)
FROM energy_projects
WHERE status = 'active'
UNION ALL
SELECT 
    'technology',
    COUNT(*),
    SUM(contribution_usd),
    COUNT(DISTINCT country_code)
FROM tech_projects
WHERE status = 'active';
