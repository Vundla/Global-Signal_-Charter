<script lang="ts">
	import Card from '../ui/Card.svelte';
	import Badge from '../ui/Badge.svelte';
	import CodexVerse from '../CodexVerse.svelte';
	import { getVerseBySector } from '$lib/codex';

	export let data: {
		total_projects: number;
		total_contribution_usd: string | number;
		countries_participating: number;
		students_enrolled?: number;
		teachers_trained?: number;
		schools_built?: number;
		scholarships_awarded?: number;
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
	<div class="sector-card education">
		<div class="sector-header">
			<div class="sector-title">
				<span class="sector-icon">📚</span>
				<h3>Education</h3>
			</div>
			<Badge variant="success" size="md">{data.total_projects} projects</Badge>
		</div>

		<CodexVerse verse={getVerseBySector('Education')} display="quote" theme="light" />

		<div class="sector-stats">
			<div class="stat-row">
				<span class="label">Annual Contribution:</span>
				<span class="value">{formatCurrency(data.total_contribution_usd)}</span>
			</div>
			{#if data.students_enrolled}
				<div class="stat-row">
					<span class="label">Students Enrolled:</span>
					<span class="value">{formatNumber(data.students_enrolled)}</span>
				</div>
			{/if}
			{#if data.teachers_trained}
				<div class="stat-row">
					<span class="label">Teachers Trained:</span>
					<span class="value">{formatNumber(data.teachers_trained)}</span>
				</div>
			{/if}
			{#if data.schools_built}
				<div class="stat-row">
					<span class="label">Schools Built:</span>
					<span class="value">{formatNumber(data.schools_built)}</span>
				</div>
			{/if}
			{#if data.scholarships_awarded}
				<div class="stat-row">
					<span class="label">Scholarships Awarded:</span>
					<span class="value">{formatNumber(data.scholarships_awarded)}</span>
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
				<span class="impact-tag">Primary Education</span>
				<span class="impact-tag">STEM Programs</span>
				<span class="impact-tag">Teacher Training</span>
				<span class="impact-tag">Digital Literacy</span>
				<span class="impact-tag">Vocational Skills</span>
			</div>
		</div>
	</div>
</Card>

<style>
	.education {
		display: flex;
		flex-direction: column;
		gap: 1.5rem;
	}

	.sector-header {
		display: flex;
		justify-content: space-between;
		align-items: center;
		padding-bottom: 1rem;
		border-bottom: 2px solid #d1fae5;
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
		color: #065f46;
	}

	.sector-stats {
		display: flex;
		flex-direction: column;
		gap: 0.75rem;
		background: #ecfdf5;
		padding: 1.25rem;
		border-radius: 0.5rem;
	}

	.stat-row {
		display: flex;
		justify-content: space-between;
		align-items: center;
		padding: 0.5rem 0;
		border-bottom: 1px solid #a7f3d0;
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
		color: #065f46;
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
		background: #d1fae5;
		color: #065f46;
		border-radius: 1rem;
		font-size: 0.875rem;
		font-weight: 500;
	}

	@media (prefers-color-scheme: dark) {
		.sector-title h3 {
			color: #6ee7b7;
		}

		.sector-header {
			border-bottom-color: #064e3b;
		}

		.sector-stats {
			background: #064e3b;
		}

		.stat-row {
			border-bottom-color: #10b981;
		}

		.label {
			color: #cbd5e1;
		}

		.value {
			color: #6ee7b7;
		}

		.impact-tag {
			background: #064e3b;
			color: #6ee7b7;
		}
	}
</style>
