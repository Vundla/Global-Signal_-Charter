<script lang="ts">
	import RegionCard, { type Region } from './RegionCard.svelte';
	import LoadingSpinner from '../ui/LoadingSpinner.svelte';

	// Phase 4 Global Regions
	const regions: Region[] = [
		{
			code: 'ams',
			name: 'Europe (Amsterdam)',
			location: 'Amsterdam, Netherlands',
			status: 'healthy',
			latency: 12,
			countries: 44,
			activeProjects: 156,
			uptime: 99.9
		},
		{
			code: 'iad',
			name: 'Americas East (Ashburn)',
			location: 'Ashburn, Virginia, USA',
			status: 'healthy',
			latency: 18,
			countries: 35,
			activeProjects: 142,
			uptime: 99.8
		},
		{
			code: 'syd',
			name: 'Asia-Pacific (Sydney)',
			location: 'Sydney, Australia',
			status: 'healthy',
			latency: 45,
			countries: 16,
			activeProjects: 78,
			uptime: 99.7
		},
		{
			code: 'sin',
			name: 'Asia (Singapore)',
			location: 'Singapore',
			status: 'healthy',
			latency: 38,
			countries: 24,
			activeProjects: 95,
			uptime: 99.9
		},
		{
			code: 'sfo',
			name: 'Americas West (San Francisco)',
			location: 'San Francisco, California, USA',
			status: 'healthy',
			latency: 22,
			countries: 28,
			activeProjects: 118,
			uptime: 99.8
		},
		{
			code: 'jnb',
			name: 'Africa (Johannesburg)',
			location: 'Johannesburg, South Africa',
			status: 'healthy',
			latency: 52,
			countries: 48,
			activeProjects: 134,
			uptime: 99.6
		}
	];

	let loading = false;
	let selectedRegion: string | null = null;

	function selectRegion(code: string) {
		selectedRegion = selectedRegion === code ? null : code;
	}

	$: totalCountries = regions.reduce((sum, r) => sum + r.countries, 0);
	$: totalProjects = regions.reduce((sum, r) => sum + r.activeProjects, 0);
	$: avgLatency = Math.round(regions.reduce((sum, r) => sum + r.latency, 0) / regions.length);
	$: avgUptime = (regions.reduce((sum, r) => sum + r.uptime, 0) / regions.length).toFixed(1);
</script>

<div class="region-dashboard">
	<div class="dashboard-header">
		<h2>🗺️ Global Infrastructure Dashboard</h2>
		<p class="subtitle">6 Regions • Multi-DC Replication • Phase 4 Architecture</p>
	</div>

	<div class="global-stats">
		<div class="global-stat">
			<div class="stat-icon">🌍</div>
			<div class="stat-content">
				<div class="stat-value">{totalCountries}</div>
				<div class="stat-label">Countries</div>
			</div>
		</div>
		<div class="global-stat">
			<div class="stat-icon">🚀</div>
			<div class="stat-content">
				<div class="stat-value">{totalProjects}</div>
				<div class="stat-label">Active Projects</div>
			</div>
		</div>
		<div class="global-stat">
			<div class="stat-icon">⚡</div>
			<div class="stat-content">
				<div class="stat-value">{avgLatency}ms</div>
				<div class="stat-label">Avg Latency</div>
			</div>
		</div>
		<div class="global-stat">
			<div class="stat-icon">✅</div>
			<div class="stat-content">
				<div class="stat-value">{avgUptime}%</div>
				<div class="stat-label">Global Uptime</div>
			</div>
		</div>
	</div>

	{#if loading}
		<LoadingSpinner size="lg" centered text="Loading regions..." />
	{:else}
		<div class="regions-grid">
			{#each regions as region (region.code)}
				<div on:click={() => selectRegion(region.code)} on:keypress={() => selectRegion(region.code)} role="button" tabindex="0">
					<RegionCard {region} />
				</div>
			{/each}
		</div>

		<div class="region-map">
			<h3>Network Topology</h3>
			<div class="topology">
				<div class="topology-info">
					<p>🔗 <strong>Multi-Region Replication:</strong> PostgreSQL async + Cassandra multi-DC (RF=3)</p>
					<p>⚡ <strong>Edge Caching:</strong> NGINX/Varnish at each regional node</p>
					<p>📡 <strong>Event Streaming:</strong> NATS JetStream with geo-distributed topics</p>
					<p>🔐 <strong>Security:</strong> WireGuard mesh network + mTLS between regions</p>
				</div>
			</div>
		</div>
	{/if}
</div>

<style>
	.region-dashboard {
		padding: 2rem 0;
	}

	.dashboard-header {
		margin-bottom: 2rem;
	}

	.dashboard-header h2 {
		margin: 0;
		font-size: 2rem;
		color: #1f2937;
	}

	.subtitle {
		margin: 0.5rem 0 0 0;
		font-size: 1rem;
		color: #6b7280;
	}

	.global-stats {
		display: grid;
		grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
		gap: 1.5rem;
		margin-bottom: 2rem;
	}

	.global-stat {
		display: flex;
		align-items: center;
		gap: 1rem;
		padding: 1.5rem;
		background: linear-gradient(135deg, #3b82f6 0%, #2563eb 100%);
		border-radius: 1rem;
		color: white;
		box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
	}

	.stat-icon {
		font-size: 2.5rem;
	}

	.stat-content {
		flex: 1;
	}

	.global-stat .stat-value {
		font-size: 2rem;
		font-weight: 700;
		line-height: 1;
	}

	.global-stat .stat-label {
		font-size: 0.875rem;
		opacity: 0.9;
		margin-top: 0.25rem;
	}

	.regions-grid {
		display: grid;
		grid-template-columns: repeat(auto-fit, minmax(350px, 1fr));
		gap: 1.5rem;
		margin-bottom: 2rem;
	}

	.region-map {
		margin-top: 3rem;
		padding: 2rem;
		background: linear-gradient(135deg, #f9fafb 0%, #f3f4f6 100%);
		border-radius: 1rem;
		border: 2px solid #e5e7eb;
	}

	.region-map h3 {
		margin: 0 0 1.5rem 0;
		font-size: 1.5rem;
		color: #1f2937;
	}

	.topology {
		display: flex;
		flex-direction: column;
		gap: 1rem;
	}

	.topology-info {
		display: flex;
		flex-direction: column;
		gap: 0.75rem;
	}

	.topology-info p {
		margin: 0;
		font-size: 0.9375rem;
		color: #4b5563;
		line-height: 1.6;
	}

	@media (max-width: 768px) {
		.regions-grid {
			grid-template-columns: 1fr;
		}

		.global-stats {
			grid-template-columns: repeat(2, 1fr);
		}
	}

	@media (prefers-color-scheme: dark) {
		.dashboard-header h2 {
			color: #f3f4f6;
		}

		.subtitle {
			color: #9ca3af;
		}

		.region-map {
			background: linear-gradient(135deg, #1f2937 0%, #111827 100%);
			border-color: #374151;
		}

		.region-map h3 {
			color: #f3f4f6;
		}

		.topology-info p {
			color: #d1d5db;
		}
	}
</style>
