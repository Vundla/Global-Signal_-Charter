<script lang="ts">
	import Card from '../ui/Card.svelte';
	import Badge from '../ui/Badge.svelte';
	import CodexVerse from '../CodexVerse.svelte';
	import { getVerseBySector } from '$lib/codex';

	export let data: {
		total_projects: number;
		total_contribution_usd: string | number;
		countries_participating: number;
		patients_served?: number;
		clinics_established?: number;
		health_workers_trained?: number;
	};

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

<Card padding="lg" shadow="lg" hover>
	<div class="sector-card health">
		<div class="sector-header">
			<div class="sector-title">
				<span class="sector-icon">🏥</span>
				<h3>Health</h3>
			</div>
			<Badge variant="info" size="md">{data.total_projects} projects</Badge>
		</div>

		<CodexVerse verse={getVerseBySector('Health')} display="quote" theme="light" />

		<div class="sector-stats">
			<div class="stat-row">
				<span class="label">Annual Contribution:</span>
				<span class="value">{formatCurrency(data.total_contribution_usd)}</span>
			</div>
			{#if data.patients_served}
				<div class="stat-row">
					<span class="label">Patients Served:</span>
					<span class="value">{formatNumber(data.patients_served)}</span>
				</div>
			{/if}
			{#if data.clinics_established}
				<div class="stat-row">
					<span class="label">Clinics Established:</span>
					<span class="value">{formatNumber(data.clinics_established)}</span>
				</div>
			{/if}
			{#if data.health_workers_trained}
				<div class="stat-row">
					<span class="label">Health Workers Trained:</span>
					<span class="value">{formatNumber(data.health_workers_trained)}</span>
				</div>
			{/if}
			<div class="stat-row">
				<span class="label">Countries Participating:</span>
				<span class="value">{data.countries_participating}</span>
			</div>
		</div>

		<div class="sector-impact">
			<h4>Impact Areas</h4>
			<div class="impact-tags">
				<span class="impact-tag">Primary Care</span>
				<span class="impact-tag">Disease Prevention</span>
				<span class="impact-tag">Maternal Health</span>
				<span class="impact-tag">Mental Health</span>
				<span class="impact-tag">Medical Equipment</span>
			</div>
		</div>
	</div>
</Card>

<style>
	.health {
		display: flex;
		flex-direction: column;
		gap: 1.5rem;
	}

	.sector-header {
		display: flex;
		justify-content: space-between;
		align-items: center;
		padding-bottom: 1rem;
		border-bottom: 2px solid #dbeafe;
	}

	.sector-title {
		display: flex;
		align-items: center;
		gap: 0.75rem;
	}

	.sector-icon {
		font-size: 2rem;
	}

	.sector-title h3 {
		margin: 0;
		font-size: 1.5rem;
		color: #1e40af;
	}

	.sector-stats {
		display: flex;
		flex-direction: column;
		gap: 0.75rem;
		background: #f0f9ff;
		padding: 1.25rem;
		border-radius: 0.5rem;
	}

	.stat-row {
		display: flex;
		justify-content: space-between;
		align-items: center;
		padding: 0.5rem 0;
		border-bottom: 1px solid #bfdbfe;
	}

	.stat-row:last-child {
		border-bottom: none;
	}

	.label {
		font-weight: 500;
		color: #475569;
	}

	.value {
		font-weight: 700;
		color: #1e40af;
		font-size: 1.125rem;
	}

	.sector-impact {
		margin-top: 0.5rem;
	}

	.sector-impact h4 {
		margin: 0 0 0.75rem 0;
		font-size: 1rem;
		color: #475569;
	}

	.impact-tags {
		display: flex;
		flex-wrap: wrap;
		gap: 0.5rem;
	}

	.impact-tag {
		padding: 0.375rem 0.75rem;
		background: #dbeafe;
		color: #1e40af;
		border-radius: 1rem;
		font-size: 0.875rem;
		font-weight: 500;
	}

	@media (prefers-color-scheme: dark) {
		.sector-title h3 {
			color: #60a5fa;
		}

		.sector-header {
			border-bottom-color: #1e3a8a;
		}

		.sector-stats {
			background: #1e3a8a;
		}

		.stat-row {
			border-bottom-color: #3b82f6;
		}

		.label {
			color: #cbd5e1;
		}

		.value {
			color: #93c5fd;
		}

		.impact-tag {
			background: #1e3a8a;
			color: #93c5fd;
		}
	}
</style>
