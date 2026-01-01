-- UbuntuNet Global Database Initialization
-- Database: global_DB
-- Owner: global-signal_-charter
-- Purpose: Charter of Sovereign Unity - Offline Fibre Tower System

-- Note: Database and role are created by Docker, skip those steps

-- ============================================
-- PHASE 2: SCHEMA OWNERSHIP
-- ============================================

-- Grant ownership of public schema to application role
ALTER SCHEMA public OWNER TO "global-signal_-charter";

-- Grant all privileges on database
GRANT ALL PRIVILEGES ON DATABASE "global_DB" TO "global-signal_-charter";

-- Grant all on all tables in public schema
GRANT ALL ON ALL TABLES IN SCHEMA public TO "global-signal_-charter";
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO "global-signal_-charter";
GRANT ALL ON ALL FUNCTIONS IN SCHEMA public TO "global-signal_-charter";

-- Set default privileges for future objects
ALTER DEFAULT PRIVILEGES IN SCHEMA public
    GRANT ALL ON TABLES TO "global-signal_-charter";

ALTER DEFAULT PRIVILEGES IN SCHEMA public
    GRANT ALL ON SEQUENCES TO "global-signal_-charter";

ALTER DEFAULT PRIVILEGES IN SCHEMA public
    GRANT ALL ON FUNCTIONS TO "global-signal_-charter";

-- ============================================
-- PHASE 3: EXTENSIONS
-- ============================================

-- UUID support
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- PostGIS for geospatial data (tower locations)
CREATE EXTENSION IF NOT EXISTS postgis;

-- pg_trgm for fuzzy text search
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- timescaledb for time-series telemetry (optional)
-- CREATE EXTENSION IF NOT EXISTS timescaledb;

-- ============================================
-- PHASE 4: CORE TABLES
-- ============================================

-- Countries participating in 0.01% GDP covenant
CREATE TABLE IF NOT EXISTS countries (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code VARCHAR(3) NOT NULL UNIQUE, -- ISO 3166-1 alpha-3
    name VARCHAR(255) NOT NULL,
    gdp_usd BIGINT, -- Annual GDP in USD
    contribution_usd BIGINT, -- 0.01% of GDP
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    covenant_status VARCHAR(50) DEFAULT 'pending', -- pending, active, suspended
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Offline Fibre Towers
CREATE TABLE IF NOT EXISTS towers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    country_id UUID REFERENCES countries(id),
    location GEOGRAPHY(POINT, 4326), -- PostGIS point (lat/lon)
    status VARCHAR(50) DEFAULT 'planned', -- planned, construction, operational, maintenance
    capacity_gbps INTEGER, -- Fibre capacity in Gbps
    power_source VARCHAR(100), -- solar+battery, grid+battery, hybrid
    battery_kwh INTEGER, -- Battery capacity
    coverage_radius_km FLOAT, -- WiFi/LTE coverage radius
    population_served INTEGER, -- Estimated population
    deployed_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create spatial index for tower locations
CREATE INDEX idx_towers_location ON towers USING GIST(location);

-- Community Beneficiaries
CREATE TABLE IF NOT EXISTS communities (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tower_id UUID REFERENCES towers(id),
    name VARCHAR(255) NOT NULL,
    type VARCHAR(100), -- school, hospital, clinic, library, community_center
    location GEOGRAPHY(POINT, 4326),
    population INTEGER,
    connectivity_status VARCHAR(50) DEFAULT 'offline', -- offline, online, intermittent
    free_access BOOLEAN DEFAULT true, -- 50% profit goes to free access
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tower Telemetry (Time-Series Data)
CREATE TABLE IF NOT EXISTS tower_telemetry (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tower_id UUID REFERENCES towers(id),
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    uptime_seconds BIGINT,
    bandwidth_used_gbps FLOAT,
    battery_soc_percent FLOAT, -- State of charge
    active_users INTEGER,
    cache_hit_rate_percent FLOAT,
    sync_status VARCHAR(50), -- synced, syncing, offline
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create index for time-series queries
CREATE INDEX idx_telemetry_tower_time ON tower_telemetry(tower_id, timestamp DESC);

-- Profit Distribution Ledger
CREATE TABLE IF NOT EXISTS profit_ledger (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    period VARCHAR(50) NOT NULL, -- YYYY-MM format
    total_revenue_usd BIGINT,
    communities_share_usd BIGINT, -- 50%
    nations_share_usd BIGINT, -- 30%
    maintenance_share_usd BIGINT, -- 20%
    distribution_status VARCHAR(50) DEFAULT 'pending', -- pending, distributed, audited
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Chaos Engineering Events (Fault Tolerance Tracking)
CREATE TABLE IF NOT EXISTS chaos_events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tower_id UUID REFERENCES towers(id),
    event_type VARCHAR(100), -- network_partition, power_loss, disk_failure
    injected_at TIMESTAMP WITH TIME ZONE,
    detected_at TIMESTAMP WITH TIME ZONE,
    recovered_at TIMESTAMP WITH TIME ZONE,
    mttr_seconds INTEGER, -- Mean Time To Recovery
    impact_severity VARCHAR(50), -- low, medium, high, critical
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Development Scoring Checklist
CREATE TABLE IF NOT EXISTS dev_checklist (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    phase VARCHAR(100) NOT NULL, -- foundation, data_caching, ai_security, chaos, community
    task VARCHAR(255) NOT NULL,
    score INTEGER DEFAULT 0 CHECK (score >= 0 AND score <= 100),
    status VARCHAR(50) DEFAULT 'not_started', -- not_started, in_progress, completed, blocked
    review_gate_passed BOOLEAN DEFAULT false,
    reviewer VARCHAR(255),
    reviewed_at TIMESTAMP WITH TIME ZONE,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Audit Trail
CREATE TABLE IF NOT EXISTS audit_log (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    table_name VARCHAR(255) NOT NULL,
    record_id UUID,
    action VARCHAR(50) NOT NULL, -- INSERT, UPDATE, DELETE
    changed_by VARCHAR(255),
    changed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    old_values JSONB,
    new_values JSONB,
    ip_address INET,
    user_agent TEXT
);

-- Create index for audit queries
CREATE INDEX idx_audit_table_time ON audit_log(table_name, changed_at DESC);

-- ============================================
-- PHASE 5: SEED DATA
-- ============================================

-- Insert South Africa (primary pilot)
INSERT INTO countries (code, name, gdp_usd, contribution_usd, covenant_status) VALUES
('ZAF', 'South Africa', 405870000000, 40587000, 'active'),
('ZWE', 'Zimbabwe', 28370000000, 2837000, 'active')
ON CONFLICT (code) DO NOTHING;

-- Insert Codex Charters as metadata
CREATE TABLE IF NOT EXISTS codex_charters (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title VARCHAR(255) NOT NULL,
    verse TEXT NOT NULL,
    guardian VARCHAR(100), -- Leopard, Lion, Hare
    inscribed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

INSERT INTO codex_charters (title, verse, guardian) VALUES
('River of Resilience Charter', 'As rivers carve stone not by force but persistence, so South Africa rises not through ease but through endurance forged in the crucible of history.', 'Leopard'),
('Charter of Fault-Tolerant Sovereignty', 'Let it crash, then rise with wisdom. Every failure is a stepping stone, not a grave. Our systems breathe resilience, supervised and eternal.', 'Lion'),
('Charter of Offline Fibre Towers', 'No longer shall communities wait for distant ISPs. We plant towers that stand sovereign, caching the world even when the world disconnects.', 'Hare')
ON CONFLICT DO NOTHING;

-- ============================================
-- PHASE 6: TRIGGERS & FUNCTIONS
-- ============================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply triggers to all tables with updated_at
CREATE TRIGGER update_countries_updated_at BEFORE UPDATE ON countries
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_towers_updated_at BEFORE UPDATE ON towers
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_communities_updated_at BEFORE UPDATE ON communities
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_profit_ledger_updated_at BEFORE UPDATE ON profit_ledger
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_dev_checklist_updated_at BEFORE UPDATE ON dev_checklist
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- VERIFICATION QUERIES
-- ============================================

-- Verify schema ownership
SELECT nspname, rolname 
FROM pg_namespace 
JOIN pg_roles ON pg_namespace.nspowner = pg_roles.oid 
WHERE nspname = 'public';

-- Verify tables exist
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
ORDER BY table_name;

-- Verify extensions
SELECT extname, extversion 
FROM pg_extension 
WHERE extname IN ('uuid-ossp', 'postgis', 'pg_trgm');

-- ============================================
-- COMPLETE
-- ============================================

-- Ubuntu Philosophy: "I am because we are"
COMMENT ON DATABASE "global_DB" IS 'UbuntuNet Global: The Charter of Sovereign Unity - Offline connectivity for communities, by communities, with fault-tolerant resilience';
