defmodule GlobalSovereign.Repo.Migrations.Phase4Countries do
  use Ecto.Migration

  def up do
    execute """
    -- Phase 4: Countries Schema Migration
    -- Expand from 56 to 195 nations

    CREATE TABLE IF NOT EXISTS countries_phase4 (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  country_code VARCHAR(3) NOT NULL UNIQUE,
  country_name VARCHAR(100) NOT NULL,
  region VARCHAR(20) NOT NULL, -- APAC, EMEA, Americas
  gdp_usd BIGINT NOT NULL,
  contribution_usd BIGINT NOT NULL, -- 0.01% of GDP
  covenant_status VARCHAR(20) NOT NULL DEFAULT 'active',
  joined_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  last_synced_at TIMESTAMP WITH TIME ZONE,
  inserted_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX idx_countries_region ON countries_phase4(region);
CREATE INDEX idx_countries_status ON countries_phase4(covenant_status);
CREATE INDEX idx_countries_joined ON countries_phase4(joined_at);

-- Function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_countries_phase4_updated_at BEFORE UPDATE
    ON countries_phase4 FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- View for regional covenant statistics
CREATE OR REPLACE VIEW covenant_regional_stats AS
SELECT 
  region,
  COUNT(*) as country_count,
  SUM(gdp_usd) as total_gdp,
  SUM(contribution_usd) as total_covenant_contribution,
  AVG(gdp_usd) as avg_gdp,
  MAX(gdp_usd) as max_gdp,
  MIN(gdp_usd) as min_gdp
FROM countries_phase4
WHERE covenant_status = 'active'
GROUP BY region;

-- View for global covenant statistics
CREATE OR REPLACE VIEW covenant_global_stats AS
SELECT 
  COUNT(*) as total_countries,
  SUM(gdp_usd) as global_gdp,
  SUM(contribution_usd) as global_covenant_fund,
  AVG(contribution_usd) as avg_contribution
FROM countries_phase4
WHERE covenant_status = 'active';

COMMENT ON TABLE countries_phase4 IS 'Phase 4: All 195 UN-recognized nations with covenant contributions';
COMMENT ON COLUMN countries_phase4.country_code IS 'ISO 3166-1 alpha-3 country code';
COMMENT ON COLUMN countries_phase4.contribution_usd IS '0.01% of GDP contribution to covenant fund';
    """
  end

  def down do
    execute """
    DROP VIEW IF EXISTS covenant_global_stats;
    DROP VIEW IF EXISTS covenant_regional_stats;
    DROP TRIGGER IF EXISTS update_countries_phase4_updated_at ON countries_phase4;
    DROP FUNCTION IF EXISTS update_updated_at_column();
    DROP TABLE IF EXISTS countries_phase4;
    """
  end
end
