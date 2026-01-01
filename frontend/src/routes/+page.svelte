<script lang="ts">
	import { onMount } from 'svelte';
	import CodexVerse from '$lib/components/CodexVerse.svelte';
	import { getVerseBySector } from '$lib/codex';

	interface Country {
		id: string;
		name: string;
		code: string;
		gdp_usd: number;
		contribution_usd: number;
		covenant_status: string;
	}

	interface Stats {
		total_countries: number;
		active_countries: number;
		total_gdp_usd: string;
		total_fund_usd: string;
	}

	interface SectorStats {
		agriculture: any;
		minerals: any;
		energy: any;
		technology: any;
	}

	let healthStatus = 'checking...';
	let countries: Country[] = [];
	let stats: Stats | null = null;
	let sectorStats: SectorStats = {
		agriculture: null,
		minerals: null,
		energy: null,
		technology: null
	};
	let loading = true;
	let error = '';

	const API_URL = 'http://127.0.0.1:4000/api';

	onMount(async () => {
		try {
			// Test backend connection
			const healthRes = await fetch(`${API_URL}/health`);
			const health = await healthRes.json();
			healthStatus = health.status;

			// Fetch covenant stats
			const statsRes = await fetch(`${API_URL}/countries/stats`);
			const statsData = await statsRes.json();
			stats = statsData.data;

			// Fetch Phase 2 sector stats
			const [agRes, minRes, engRes, techRes] = await Promise.all([
				fetch(`${API_URL}/agriculture/stats`),
				fetch(`${API_URL}/minerals/stats`),
				fetch(`${API_URL}/energy/stats`),
				fetch(`${API_URL}/tech/stats`)
			]);

			const agData = await agRes.json();
			const minData = await minRes.json();
			const engData = await engRes.json();
			const techData = await techRes.json();

			sectorStats = {
				agriculture: agData.data,
				minerals: minData.data,
				energy: engData.data,
				technology: techData.data
			};

			// Fetch countries
			const countriesRes = await fetch(`${API_URL}/countries`);
			const countriesData = await countriesRes.json();
			countries = countriesData.data;

			loading = false;
		} catch (e) {
			healthStatus = 'error';
			error = `Backend connection failed: ${e}`;
			loading = false;
			console.error('Backend connection failed:', e);
		}
	});

	function formatCurrency(value: number | string): string {
		const num = typeof value === 'string' ? parseInt(value) : value;
		return new Intl.NumberFormat('en-US', {
			style: 'currency',
			currency: 'USD',
			minimumFractionDigits: 0,
			maximumFractionDigits: 0
		}).format(num);
	}

	function formatNumber(value: number): string {
		return new Intl.NumberFormat('en-US').format(value);
	}
</script>

<main>
	<h1>🌍 Global Sovereign Network</h1>
	<p class="subtitle">Connecting communities, sharing prosperity, building together.</p>
	
	<div class="status">
		<h2>System Status</h2>
		<p>Backend Health: <strong class="status-{healthStatus}">{healthStatus}</strong></p>
	</div>

	{#if loading}
		<div class="loading">Loading covenant data...</div>
	{:else if error}
		<div class="error">{error}</div>
	{:else}
		{#if stats}
			<div class="stats-grid">
				<div class="stat-card">
					<h3>{formatNumber(stats.total_countries)}</h3>
					<p>Total Countries</p>
				</div>
				<div class="stat-card">
					<h3>{formatNumber(stats.active_countries)}</h3>
					<p>Active Members</p>
				</div>
				<div class="stat-card">
					<h3>{formatCurrency(stats.total_gdp_usd)}</h3>
					<p>Combined GDP</p>
				</div>
				<div class="stat-card highlight">
					<h3>{formatCurrency(stats.total_fund_usd)}</h3>
					<p>Annual Fund (0.01% GDP)</p>
				</div>
			</div>

			<div class="info">
				<h2>The Charter</h2>
				<p>
					{stats.total_countries} nations united in covenant. Each contributes 0.01% of GDP annually.
				</p>
				<div class="distribution">
					<div class="dist-item">
						<strong>50%</strong> → Communities (local development)
					</div>
					<div class="dist-item">
						<strong>30%</strong> → Nations (treasury share)
					</div>
					<div class="dist-item">
						<strong>20%</strong> → Infrastructure (maintenance)
					</div>
				</div>
			</div>

			<!-- Phase 2: Economic Sectors -->
			<div class="phase2-section">
				<h2>📊 Economic Sectors (Phase 2)</h2>
				<p class="phase2-subtitle">Nations rise not by hoarding, but by weaving wealth into covenant.</p>
				
				<CodexVerse verse={getVerseBySector('Agriculture')} display="quote" theme="dark" />

				<div class="sectors-grid">
					<!-- Agriculture Sector -->
					<div class="sector-card agriculture">
						<div class="sector-header">
							<h3>🌾 Agriculture</h3>
							<div class="sector-badge">{sectorStats.agriculture?.total_projects || 0} projects</div>
						</div>
						<CodexVerse verse={getVerseBySector('Agriculture')} display="quote" theme="light" />
						{#if sectorStats.agriculture}
							<div class="sector-stats">
								<div class="stat-row">
									<span class="label">Annual Contribution:</span>
									<span class="value">{formatCurrency(sectorStats.agriculture.total_contribution_usd)}</span>
								</div>
								<div class="stat-row">
									<span class="label">Estimated Yield:</span>
									<span class="value">{formatNumber(parseInt(sectorStats.agriculture.total_yield_kg))} kg</span>
								</div>
								<div class="stat-row">
									<span class="label">Countries Participating:</span>
									<span class="value">{sectorStats.agriculture.countries_participating}</span>
								</div>
							</div>
						{/if}
					</div>

					<!-- Minerals Sector -->
					<div class="sector-card minerals">
						<div class="sector-header">
							<h3>⛏️ Minerals</h3>
							<div class="sector-badge">{sectorStats.minerals?.total_projects || 0} projects</div>
						</div>
						<CodexVerse verse={getVerseBySector('Minerals')} display="quote" theme="light" />
						{#if sectorStats.minerals}
							<div class="sector-stats">
								<div class="stat-row">
									<span class="label">Total Profit:</span>
									<span class="value">{formatCurrency(sectorStats.minerals.total_profit_usd)}</span>
								</div>
								<div class="profit-split">
									<div class="split-item">
										<span class="split-label">Local (50%):</span>
										<span class="split-value">{formatCurrency(sectorStats.minerals.local_reinvestment_usd)}</span>
									</div>
									<div class="split-item">
										<span class="split-label">Global (30%):</span>
										<span class="split-value">{formatCurrency(sectorStats.minerals.global_contribution_usd)}</span>
									</div>
								</div>
								<div class="stat-row">
									<span class="label">Countries Participating:</span>
									<span class="value">{sectorStats.minerals.countries_participating}</span>
								</div>
							</div>
						{/if}
					</div>

					<!-- Energy Sector -->
					<div class="sector-card energy">
						<div class="sector-header">
							<h3>⚡ Energy</h3>
							<div class="sector-badge">{sectorStats.energy?.total_projects || 0} projects</div>
						</div>
						<CodexVerse verse={getVerseBySector('Energy')} display="quote" theme="light" />
						{#if sectorStats.energy && sectorStats.energy.total_projects > 0}
							<div class="sector-stats">
								<div class="stat-row">
									<span class="label">Total Profit:</span>
									<span class="value">{formatCurrency(sectorStats.energy.total_profit_usd)}</span>
								</div>
								<div class="stat-row">
									<span class="label">Resilience Reserve (20%):</span>
									<span class="value">{formatCurrency(sectorStats.energy.resilience_reserves_usd)}</span>
								</div>
								<div class="stat-row">
									<span class="label">Avg Uptime:</span>
									<span class="value">{(sectorStats.energy.avg_uptime_percent || 0).toFixed(1)}%</span>
								</div>
								<div class="stat-row">
									<span class="label">Countries Participating:</span>
									<span class="value">{sectorStats.energy.countries_participating}</span>
								</div>
							</div>
						{:else}
							<div class="sector-empty">
								<p>No active energy projects</p>
								<span class="note">Awaiting country data integration</span>
							</div>
						{/if}
					</div>

					<!-- Technology Sector -->
					<div class="sector-card technology">
						<div class="sector-header">
							<h3>💻 Technology</h3>
							<div class="sector-badge">{sectorStats.technology?.total_projects || 0} projects</div>
						</div>
						<CodexVerse verse={getVerseBySector('Technology')} display="quote" theme="light" />
						{#if sectorStats.technology}
							<div class="sector-stats">
								<div class="stat-row">
									<span class="label">Users Served:</span>
									<span class="value">{formatNumber(parseInt(sectorStats.technology.total_users_served))}</span>
								</div>
								<div class="stat-row">
									<span class="label">Annual Contribution:</span>
									<span class="value">{formatCurrency(sectorStats.technology.total_contribution_usd)}</span>
								</div>
								<div class="stat-row">
									<span class="label">Offline-Capable:</span>
									<span class="value">{sectorStats.technology.offline_capable_projects}/{sectorStats.technology.total_projects}</span>
								</div>
								<div class="stat-row">
									<span class="label">Countries Participating:</span>
									<span class="value">{sectorStats.technology.countries_participating}</span>
								</div>
							</div>
						{/if}
					</div>
				</div>
			</div>

			<!-- Phase 3: Observability & Security -->
			<div class="phase3-section">
				<h2>🔍 Observability & Security (Phase 3)</h2>
				<p class="phase3-subtitle">Watchers rise, guardians stand watch over the covenant</p>
				
				<div class="observability-grid">
					<div class="observability-card observability">
						<h3>📊 Observability</h3>
						<CodexVerse verse={getVerseBySector('Observability')} display="quote" theme="light" />
						<ul class="checklist">
							<li>✅ PromEx metrics dashboards live</li>
							<li>✅ Prometheus alerts configured</li>
							<li>✅ Grafana panels integrated</li>
							<li>✅ Anomaly detection active</li>
						</ul>
					</div>

					<div class="observability-card security">
						<h3>🔐 Security</h3>
						<CodexVerse verse={getVerseBySector('Security')} display="quote" theme="light" />
						<ul class="checklist">
							<li>✅ mTLS between services</li>
							<li>✅ Zero-trust architecture</li>
							<li>✅ Tamper-evident logs</li>
							<li>✅ Role-based access control</li>
						</ul>
					</div>

					<div class="observability-card chaos">
						<h3>🌀 Chaos Engineering</h3>
						<CodexVerse verse={getVerseBySector('Chaos')} display="quote" theme="light" />
						<ul class="checklist">
							<li>✅ Fault injection ready</li>
							<li>✅ Recovery KPIs tracked</li>
							<li>✅ Quarterly drills scheduled</li>
							<li>✅ Postmortems archived</li>
						</ul>
					</div>
				</div>
			</div>

			<!-- Phase 1: Countries -->
			<div class="countries-section">
				<h2>🌐 Covenant Members ({countries.length})</h2>
				<p class="countries-subtitle">56 nations united in shared prosperity and mutual development</p>
				<div class="countries-grid">
					{#each countries as country}
						<div class="country-card">
							<div class="country-flag">{country.code}</div>
							<div class="country-info">
								<h4>{country.name}</h4>
								<p class="country-gdp">GDP: {formatCurrency(country.gdp_usd)}</p>
								<p class="country-contribution">
									Contribution: {formatCurrency(country.contribution_usd)}/year
								</p>
							</div>
						</div>
					{/each}
				</div>
			</div>
		{/if}
	{/if}
</main>

<style>
	main {
		max-width: 1400px;
		margin: 0 auto;
		padding: 2rem;
		font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
	}

	h1 {
		color: #2563eb;
		font-size: 2.5rem;
		margin-bottom: 0.5rem;
	}

	.subtitle {
		color: #6b7280;
		font-size: 1.1rem;
		margin-bottom: 2rem;
	}

	.status, .info {
		background: #f3f4f6;
		border-radius: 8px;
		padding: 1.5rem;
		margin: 1.5rem 0;
	}

	.status h2, .info h2, .countries-section h2 {
		margin-top: 0;
		color: #374151;
	}

	.status-ok {
		color: #059669;
	}

	.status-error {
		color: #dc2626;
	}

	.loading, .error {
		text-align: center;
		padding: 2rem;
		font-size: 1.1rem;
		color: #6b7280;
	}

	.error {
		color: #dc2626;
		background: #fee2e2;
		border-radius: 8px;
	}

	.stats-grid {
		display: grid;
		grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
		gap: 1.5rem;
		margin: 2rem 0;
	}

	.stat-card {
		background: white;
		border: 2px solid #e5e7eb;
		border-radius: 8px;
		padding: 1.5rem;
		text-align: center;
	}

	.stat-card.highlight {
		border-color: #2563eb;
		background: #eff6ff;
	}

	.stat-card h3 {
		margin: 0 0 0.5rem 0;
		font-size: 1.8rem;
		color: #1f2937;
	}

	.stat-card p {
		margin: 0;
		color: #6b7280;
		font-size: 0.9rem;
	}

	.distribution {
		display: flex;
		gap: 1.5rem;
		margin-top: 1rem;
		flex-wrap: wrap;
	}

	.dist-item {
		flex: 1;
		min-width: 200px;
		padding: 1rem;
		background: white;
		border-left: 4px solid #2563eb;
		border-radius: 4px;
	}

	.dist-item strong {
		color: #2563eb;
		font-size: 1.3rem;
	}

	.countries-section {
		margin-top: 3rem;
	}

	.countries-grid {
		display: grid;
		grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
		gap: 1rem;
		margin-top: 1rem;
	}

	.country-card {
		background: white;
		border: 1px solid #e5e7eb;
		border-radius: 8px;
		padding: 1rem;
		display: flex;
		gap: 1rem;
		transition: all 0.2s;
	}

	.country-card:hover {
		border-color: #2563eb;
		box-shadow: 0 4px 6px -1px rgb(0 0 0 / 0.1);
		transform: translateY(-2px);
	}

	.country-flag {
		background: #2563eb;
		color: white;
		font-weight: bold;
		font-size: 0.85rem;
		padding: 0.5rem;
		border-radius: 4px;
		display: flex;
		align-items: center;
		justify-content: center;
		min-width: 60px;
		height: 60px;
	}

	.country-info {
		flex: 1;
	}

	.country-info h4 {
		margin: 0 0 0.5rem 0;
		color: #1f2937;
	}

	.country-gdp, .country-contribution {
		margin: 0.25rem 0;
		font-size: 0.85rem;
		color: #6b7280;
	}

	.country-contribution {
		color: #059669;
		font-weight: 500;
	}

	/* Phase 2 Economic Sectors Styles */
	.phase2-section {
		margin-top: 4rem;
		padding: 2rem;
		background: linear-gradient(135deg, #f3f4f6 0%, #e5e7eb 100%);
		border-radius: 12px;
	}

	.phase2-section h2 {
		color: #1f2937;
		margin-top: 0;
		margin-bottom: 0.5rem;
	}

	.phase2-subtitle {
		color: #6b7280;
		font-size: 0.95rem;
		font-style: italic;
		margin: 0 0 1.5rem 0;
	}

	.sectors-grid {
		display: grid;
		grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
		gap: 1.5rem;
		margin-bottom: 2rem;
	}

	.sector-card {
		background: white;
		border-radius: 8px;
		padding: 1.5rem;
		box-shadow: 0 2px 4px -1px rgb(0 0 0 / 0.1);
		border-left: 5px solid #6b7280;
		transition: all 0.3s ease;
	}

	.sector-card:hover {
		box-shadow: 0 10px 15px -3px rgb(0 0 0 / 0.1);
		transform: translateY(-4px);
	}

	.sector-card.agriculture {
		border-left-color: #84cc16;
	}

	.sector-card.minerals {
		border-left-color: #a78bfa;
	}

	.sector-card.energy {
		border-left-color: #fbbf24;
	}

	.sector-card.technology {
		border-left-color: #3b82f6;
	}

	.sector-header {
		display: flex;
		justify-content: space-between;
		align-items: center;
		margin-bottom: 1.5rem;
		gap: 1rem;
	}

	.sector-header h3 {
		margin: 0;
		font-size: 1.25rem;
		color: #1f2937;
	}

	.sector-badge {
		background: #f3f4f6;
		color: #374151;
		padding: 0.35rem 0.75rem;
		border-radius: 20px;
		font-size: 0.85rem;
		font-weight: 500;
		white-space: nowrap;
	}

	:global(.sector-card .codex-verse) {
		margin: 1rem 0;
		padding: 1rem;
		border-left: 4px solid currentColor;
	}

	:global(.sector-card.agriculture .codex-verse) {
		border-left-color: #84cc16;
		background: rgba(132, 204, 22, 0.08);
	}

	:global(.sector-card.minerals .codex-verse) {
		border-left-color: #a78bfa;
		background: rgba(167, 139, 250, 0.08);
	}

	:global(.sector-card.energy .codex-verse) {
		border-left-color: #fbbf24;
		background: rgba(251, 191, 36, 0.08);
	}

	:global(.sector-card.technology .codex-verse) {
		border-left-color: #3b82f6;
		background: rgba(59, 130, 246, 0.08);
	}

	:global(.sector-card .codex-verse.light) {
		background: rgba(0, 0, 0, 0.02);
		border-left: 3px solid;
	}

	:global(.sector-card .codex-verse p) {
		margin: 0.25rem 0;
		font-size: 0.9rem;
	}

	.sector-stats {
		display: flex;
		flex-direction: column;
		gap: 0.75rem;
	}

	.stat-row {
		display: flex;
		justify-content: space-between;
		align-items: center;
		padding: 0.5rem 0;
		border-bottom: 1px solid #f3f4f6;
	}

	.stat-row:last-child {
		border-bottom: none;
	}

	.stat-row .label {
		color: #6b7280;
		font-size: 0.9rem;
		font-weight: 500;
	}

	.stat-row .value {
		color: #1f2937;
		font-weight: 600;
		font-size: 0.95rem;
	}

	.profit-split {
		background: #f9fafb;
		padding: 0.75rem;
		border-radius: 6px;
		margin: 0.5rem 0;
	}

	.split-item {
		display: flex;
		justify-content: space-between;
		align-items: center;
		padding: 0.35rem 0;
		font-size: 0.85rem;
	}

	.split-label {
		color: #6b7280;
	}

	.split-value {
		color: #059669;
		font-weight: 600;
	}

	.sector-empty {
		text-align: center;
		padding: 1rem;
		background: #fef3c7;
		border-radius: 6px;
		color: #92400e;
	}

	.sector-empty p {
		margin: 0 0 0.25rem 0;
		font-weight: 500;
	}

	.sector-empty .note {
		font-size: 0.8rem;
		color: #b45309;
	}

	.countries-section {
		margin-top: 3rem;
	}

	.countries-subtitle {
		color: #6b7280;
		font-size: 0.95rem;
		margin: 0.5rem 0 1.5rem 0;
	}

	/* Phase 3 Observability & Security Styles */
	.phase3-section {
		margin-top: 4rem;
		padding: 2rem;
		background: linear-gradient(135deg, #1f2937 0%, #111827 100%);
		border-radius: 12px;
		color: white;
	}

	.phase3-section h2 {
		color: white;
		margin-top: 0;
		margin-bottom: 0.5rem;
	}

	.phase3-subtitle {
		color: #d1d5db;
		font-size: 0.95rem;
		font-style: italic;
		margin: 0 0 1.5rem 0;
	}

	.observability-grid {
		display: grid;
		grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
		gap: 1.5rem;
	}

	.observability-card {
		background: rgba(255, 255, 255, 0.1);
		border-radius: 8px;
		padding: 1.5rem;
		border: 1px solid rgba(255, 255, 255, 0.2);
		backdrop-filter: blur(10px);
		transition: all 0.3s ease;
	}

	.observability-card:hover {
		border-color: rgba(255, 255, 255, 0.4);
		background: rgba(255, 255, 255, 0.15);
	}

	.observability-card h3 {
		margin: 0 0 1rem 0;
		color: white;
		font-size: 1.25rem;
	}

	.observability-card.observability {
		border-left: 4px solid #3b82f6;
	}

	.observability-card.security {
		border-left: 4px solid #10b981;
	}

	.observability-card.chaos {
		border-left: 4px solid #f59e0b;
	}

	:global(.observability-card .codex-verse) {
		margin: 1rem 0;
		padding: 1rem;
		background: rgba(255, 255, 255, 0.05);
		border-left: 3px solid currentColor;
	}

	:global(.observability-card .codex-verse.light) {
		--border-color: currentColor;
		background: rgba(255, 255, 255, 0.05);
		color: #f0f0f0;
	}

	:global(.observability-card .codex-verse p) {
		margin: 0.25rem 0;
		font-size: 0.9rem;
		color: #d1d5db;
		font-style: italic;
	}

	.checklist {
		list-style: none;
		padding: 0;
		margin: 1rem 0 0 0;
	}

	.checklist li {
		padding: 0.5rem 0;
		color: #d1d5db;
		font-size: 0.9rem;
		border-bottom: 1px solid rgba(255, 255, 255, 0.1);
	}

	.checklist li:last-child {
		border-bottom: none;
	}</style>
