<script lang="ts" context="module">
	export interface Region {
		code: string;
		name: string;
		location: string;
		status: 'healthy' | 'degraded' | 'down';
		latency: number;
		countries: number;
		activeProjects: number;
		uptime: number;
	}
</script>

<script lang="ts">
	import Card from '../ui/Card.svelte';
	import Badge from '../ui/Badge.svelte';

	export let region: Region;

	function getStatusVariant(status: string) {
		switch (status) {
			case 'healthy':
				return 'success';
			case 'degraded':
				return 'warning';
			case 'down':
				return 'danger';
			default:
				return 'default';
		}
	}

	function getStatusColor(status: string) {
		switch (status) {
			case 'healthy':
				return '#10b981';
			case 'degraded':
				return '#f59e0b';
			case 'down':
				return '#ef4444';
			default:
				return '#6b7280';
		}
	}
</script>

<Card padding="lg" shadow="md" hover>
	<div class="region-card">
		<div class="region-header">
			<div class="region-title">
				<h3>{region.name}</h3>
				<p class="region-code">{region.code}</p>
			</div>
			<Badge variant={getStatusVariant(region.status)} size="md">
				{region.status}
			</Badge>
		</div>

		<div class="region-location">
			<span class="location-icon">📍</span>
			<span>{region.location}</span>
		</div>

		<div class="region-stats">
			<div class="stat-item">
				<div class="stat-value">{region.latency}ms</div>
				<div class="stat-label">Latency</div>
			</div>
			<div class="stat-item">
				<div class="stat-value">{region.countries}</div>
				<div class="stat-label">Countries</div>
			</div>
			<div class="stat-item">
				<div class="stat-value">{region.activeProjects}</div>
				<div class="stat-label">Projects</div>
			</div>
			<div class="stat-item">
				<div class="stat-value">{region.uptime}%</div>
				<div class="stat-label">Uptime</div>
			</div>
		</div>

		<div class="region-health">
			<div class="health-bar">
				<div
					class="health-fill"
					style="width: {region.uptime}%; background: {getStatusColor(region.status)}"
				></div>
			</div>
		</div>
	</div>
</Card>

<style>
	.region-card {
		display: flex;
		flex-direction: column;
		gap: 1.25rem;
	}

	.region-header {
		display: flex;
		justify-content: space-between;
		align-items: flex-start;
	}

	.region-title h3 {
		margin: 0;
		font-size: 1.5rem;
		color: #1f2937;
	}

	.region-code {
		margin: 0.25rem 0 0 0;
		font-size: 0.875rem;
		color: #6b7280;
		font-weight: 600;
		font-family: 'Courier New', monospace;
	}

	.region-location {
		display: flex;
		align-items: center;
		gap: 0.5rem;
		padding: 0.75rem;
		background: #f9fafb;
		border-radius: 0.5rem;
		font-size: 0.9375rem;
		color: #4b5563;
	}

	.location-icon {
		font-size: 1.25rem;
	}

	.region-stats {
		display: grid;
		grid-template-columns: repeat(4, 1fr);
		gap: 1rem;
	}

	.stat-item {
		display: flex;
		flex-direction: column;
		align-items: center;
		padding: 0.75rem;
		background: #f9fafb;
		border-radius: 0.5rem;
	}

	.stat-value {
		font-size: 1.5rem;
		font-weight: 700;
		color: #1f2937;
	}

	.stat-label {
		font-size: 0.75rem;
		color: #6b7280;
		text-transform: uppercase;
		letter-spacing: 0.05em;
		margin-top: 0.25rem;
	}

	.region-health {
		margin-top: 0.5rem;
	}

	.health-bar {
		height: 8px;
		background: #e5e7eb;
		border-radius: 9999px;
		overflow: hidden;
	}

	.health-fill {
		height: 100%;
		transition: width 0.3s ease;
	}

	@media (max-width: 768px) {
		.region-stats {
			grid-template-columns: repeat(2, 1fr);
		}
	}

	@media (prefers-color-scheme: dark) {
		.region-title h3 {
			color: #f3f4f6;
		}

		.region-code {
			color: #9ca3af;
		}

		.region-location {
			background: #1f2937;
			color: #d1d5db;
		}

		.stat-item {
			background: #1f2937;
		}

		.stat-value {
			color: #f3f4f6;
		}

		.stat-label {
			color: #9ca3af;
		}

		.health-bar {
			background: #374151;
		}
	}
</style>
