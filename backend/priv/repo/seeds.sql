-- UbuntuNet Global: Pilot Mode Expansion
-- Adding countries from all continents to join the covenant
-- Each contributes 0.01% of GDP to the Global Sovereign Fund

-- ============================================
-- AFRICA (Expanding beyond SA & Zimbabwe)
-- ============================================
INSERT INTO countries (code, name, gdp_usd, contribution_usd, covenant_status) VALUES
('NGA', 'Nigeria', 477380000000, 47738000, 'active'),
('EGY', 'Egypt', 469090000000, 46909000, 'active'),
('KEN', 'Kenya', 113420000000, 11342000, 'active'),
('ETH', 'Ethiopia', 126780000000, 12678000, 'active'),
('GHA', 'Ghana', 76710000000, 7671000, 'active'),
('TZA', 'Tanzania', 75700000000, 7570000, 'active'),
('UGA', 'Uganda', 45800000000, 4580000, 'active'),
('RWA', 'Rwanda', 13310000000, 1331000, 'active'),
('SEN', 'Senegal', 30910000000, 3091000, 'active'),
('BFA', 'Burkina Faso', 19740000000, 1974000, 'active')
ON CONFLICT (code) DO NOTHING;

-- ============================================
-- ASIA
-- ============================================
INSERT INTO countries (code, name, gdp_usd, contribution_usd, covenant_status) VALUES
('CHN', 'China', 17963170000000, 1796317000, 'active'),
('IND', 'India', 3736880000000, 373688000, 'active'),
('JPN', 'Japan', 4409740000000, 440974000, 'active'),
('IDN', 'Indonesia', 1319100000000, 131910000, 'active'),
('KOR', 'South Korea', 1673920000000, 167392000, 'active'),
('THA', 'Thailand', 514950000000, 51495000, 'active'),
('PHL', 'Philippines', 440900000000, 44090000, 'active'),
('MYS', 'Malaysia', 399650000000, 39965000, 'active'),
('VNM', 'Vietnam', 429700000000, 42970000, 'active'),
('BGD', 'Bangladesh', 460200000000, 46020000, 'active'),
('PAK', 'Pakistan', 338100000000, 33810000, 'active'),
('SGP', 'Singapore', 501430000000, 50143000, 'active')
ON CONFLICT (code) DO NOTHING;

-- ============================================
-- EUROPE
-- ============================================
INSERT INTO countries (code, name, gdp_usd, contribution_usd, covenant_status) VALUES
('DEU', 'Germany', 4456080000000, 445608000, 'active'),
('GBR', 'United Kingdom', 3070670000000, 307067000, 'active'),
('FRA', 'France', 3049020000000, 304902000, 'active'),
('ITA', 'Italy', 2255470000000, 225547000, 'active'),
('ESP', 'Spain', 1582050000000, 158205000, 'active'),
('NLD', 'Netherlands', 1118060000000, 111806000, 'active'),
('POL', 'Poland', 688180000000, 68818000, 'active'),
('SWE', 'Sweden', 593270000000, 59327000, 'active'),
('BEL', 'Belgium', 632230000000, 63223000, 'active'),
('IRL', 'Ireland', 529240000000, 52924000, 'active'),
('NOR', 'Norway', 485510000000, 48551000, 'active'),
('DNK', 'Denmark', 404150000000, 40415000, 'active')
ON CONFLICT (code) DO NOTHING;

-- ============================================
-- NORTH AMERICA
-- ============================================
INSERT INTO countries (code, name, gdp_usd, contribution_usd, covenant_status) VALUES
('USA', 'United States', 27357560000000, 2735756000, 'active'),
('CAN', 'Canada', 2117710000000, 211771000, 'active'),
('MEX', 'Mexico', 1811470000000, 181147000, 'active')
ON CONFLICT (code) DO NOTHING;

-- ============================================
-- SOUTH AMERICA
-- ============================================
INSERT INTO countries (code, name, gdp_usd, contribution_usd, covenant_status) VALUES
('BRA', 'Brazil', 2173080000000, 217308000, 'active'),
('ARG', 'Argentina', 640590000000, 64059000, 'active'),
('CHL', 'Chile', 335530000000, 33553000, 'active'),
('COL', 'Colombia', 363870000000, 36387000, 'active'),
('PER', 'Peru', 268230000000, 26823000, 'active'),
('ECU', 'Ecuador', 118840000000, 11884000, 'active'),
('BOL', 'Bolivia', 47810000000, 4781000, 'active')
ON CONFLICT (code) DO NOTHING;

-- ============================================
-- OCEANIA
-- ============================================
INSERT INTO countries (code, name, gdp_usd, contribution_usd, covenant_status) VALUES
('AUS', 'Australia', 1687710000000, 168771000, 'active'),
('NZL', 'New Zealand', 253400000000, 25340000, 'active'),
('PNG', 'Papua New Guinea', 30190000000, 3019000, 'active'),
('FJI', 'Fiji', 5490000000, 549000, 'active')
ON CONFLICT (code) DO NOTHING;

-- ============================================
-- MIDDLE EAST
-- ============================================
INSERT INTO countries (code, name, gdp_usd, contribution_usd, covenant_status) VALUES
('SAU', 'Saudi Arabia', 1068440000000, 106844000, 'active'),
('ARE', 'United Arab Emirates', 507540000000, 50754000, 'active'),
('ISR', 'Israel', 525000000000, 52500000, 'active'),
('TUR', 'Turkey', 1029300000000, 102930000, 'active'),
('IRN', 'Iran', 413500000000, 41350000, 'active'),
('IRQ', 'Iraq', 250100000000, 25010000, 'active')
ON CONFLICT (code) DO NOTHING;

-- ============================================
-- SUMMARY STATISTICS
-- ============================================
DO $$
DECLARE
    total_countries INTEGER;
    total_contribution BIGINT;
    total_gdp BIGINT;
BEGIN
    SELECT COUNT(*), SUM(contribution_usd), SUM(gdp_usd) 
    INTO total_countries, total_contribution, total_gdp
    FROM countries;
    
    RAISE NOTICE '════════════════════════════════════════════════════════';
    RAISE NOTICE 'UbuntuNet Global: Pilot Mode Expansion Complete';
    RAISE NOTICE '════════════════════════════════════════════════════════';
    RAISE NOTICE 'Total Countries:     %', total_countries;
    RAISE NOTICE 'Combined GDP:        $% trillion', ROUND(total_gdp::numeric / 1000000000000, 2);
    RAISE NOTICE 'Annual Contribution: $% billion', ROUND(total_contribution::numeric / 1000000000, 2);
    RAISE NOTICE '════════════════════════════════════════════════════════';
    RAISE NOTICE 'Profit Distribution:';
    RAISE NOTICE '  50%% → Poor Communities:      $% billion', ROUND((total_contribution * 0.50)::numeric / 1000000000, 2);
    RAISE NOTICE '  30%% → Contributing Nations:  $% billion', ROUND((total_contribution * 0.30)::numeric / 1000000000, 2);
    RAISE NOTICE '  20%% → Maintenance Reserve:   $% billion', ROUND((total_contribution * 0.20)::numeric / 1000000000, 2);
    RAISE NOTICE '════════════════════════════════════════════════════════';
    RAISE NOTICE '🐆🦁🐇 Charter of Sovereign Unity Active';
    RAISE NOTICE 'Ubuntu: I am because we are';
END $$;

-- Verify the expansion
SELECT 
    CASE 
        WHEN code IN ('ZAF', 'ZWE') THEN '🌍 PILOT'
        ELSE '🌐 EXPANSION'
    END as status,
    code,
    name,
    ROUND(gdp_usd::numeric / 1000000000, 2) as gdp_billion,
    ROUND(contribution_usd::numeric / 1000000, 2) as contribution_million,
    covenant_status
FROM countries
ORDER BY gdp_usd DESC
LIMIT 20;
