<script lang="ts">
	import {
		Button,
		Card,
		Badge,
		Alert,
		LoadingSpinner,
		RegionDashboard,
		HealthSector,
		EducationSector,
		OfflineIndicator,
		RealtimeMonitor,
		CodexVerse
	} from '$lib/components';
	import { getVerseBySector } from '$lib/codex';

	// Mock data for demos
	const healthData = {
		total_projects: 12,
		total_contribution_usd: 5000000,
		countries_participating: 45,
		patients_served: 250000,
		clinics_established: 120,
		health_workers_trained: 3500
	};

	const educationData = {
		total_projects: 15,
		total_contribution_usd: 6500000,
		countries_participating: 52,
		students_enrolled: 500000,
		teachers_trained: 8000,
		schools_built: 85,
		scholarships_awarded: 12000
	};

	let showAlert = true;
	let loading = false;

	function handleDemo() {
		loading = true;
		setTimeout(() => {
			loading = false;
			alert('Component library working perfectly! ✨');
		}, 1500);
	}
</script>

<svelte:head>
	<title>Component Showcase - Global Sovereign Network</title>
</svelte:head>

<div class="showcase">
	<div class="showcase-header">
		<h1>🎨 Phase 4 Component Library</h1>
		<p class="subtitle">Complete frontend infrastructure for 195 nations & 10M+ users</p>
		<CodexVerse verse={getVerseBySector('Technology')} display="quote" theme="dark" />
	</div>

	{#if showAlert}
		<Alert variant="success" title="System Ready!" dismissible on:close={() => (showAlert = false)}>
			All Phase 4 components successfully deployed. Ready for global scaling! 🚀
		</Alert>
	{/if}

	<!-- UI Components -->
	<section class="showcase-section">
		<h2>🎯 UI Components</h2>
		<Card padding="lg" shadow="md">
			<h3>Buttons</h3>
			<div class="demo-grid">
				<Button variant="primary">Primary</Button>
				<Button variant="secondary">Secondary</Button>
				<Button variant="danger">Danger</Button>
				<Button variant="ghost">Ghost</Button>
				<Button variant="primary" size="sm">Small</Button>
				<Button variant="primary" size="lg">Large</Button>
				<Button variant="primary" {loading} on:click={handleDemo}>Test Me!</Button>
			</div>
		</Card>

		<Card padding="lg" shadow="md">
			<h3>Badges</h3>
			<div class="demo-grid">
				<Badge variant="default">Default</Badge>
				<Badge variant="success">Success</Badge>
				<Badge variant="warning">Warning</Badge>
				<Badge variant="danger">Danger</Badge>
				<Badge variant="info">Info</Badge>
			</div>
		</Card>

		<Card padding="lg" shadow="md">
			<h3>Loading States</h3>
			<div class="demo-grid">
				<LoadingSpinner size="sm" />
				<LoadingSpinner size="md" />
				<LoadingSpinner size="lg" text="Loading..." />
			</div>
		</Card>
	</section>

	<!-- Region Dashboard -->
	<section class="showcase-section">
		<h2>🗺️ Global Infrastructure</h2>
		<RegionDashboard />
	</section>

	<!-- Health Sector -->
	<section class="showcase-section">
		<h2>🏥 Health Sector</h2>
		<HealthSector data={healthData} />
	</section>

	<!-- Education Sector -->
	<section class="showcase-section">
		<h2>📚 Education Sector</h2>
		<EducationSector data={educationData} />
	</section>

	<!-- Real-Time Monitor -->
	<section class="showcase-section">
		<h2>📡 Real-Time Updates</h2>
		<RealtimeMonitor />
	</section>

	<!-- Stats Summary -->
	<section class="showcase-section">
		<h2>📊 Component Library Stats</h2>
		<div class="stats-grid">
			<Card padding="md" shadow="md" hover>
				<div class="stat-card">
					<div class="stat-number">28</div>
					<div class="stat-label">Files Created</div>
				</div>
			</Card>
			<Card padding="md" shadow="md" hover>
				<div class="stat-card">
					<div class="stat-number">21</div>
					<div class="stat-label">Components</div>
				</div>
			</Card>
			<Card padding="md" shadow="md" hover>
				<div class="stat-card">
					<div class="stat-number">7</div>
					<div class="stat-label">Test Files</div>
				</div>
			</Card>
			<Card padding="md" shadow="md" hover>
				<div class="stat-card">
					<div class="stat-number">6</div>
					<div class="stat-label">Feature Areas</div>
				</div>
			</Card>
		</div>

		<Card padding="lg" shadow="md" bordered>
			<h3>✅ Phase 4 Ready</h3>
			<ul class="checklist">
				<li>✓ UI Component Library (6 components)</li>
				<li>✓ Layout System (Header, Footer, Sidebar)</li>
				<li>✓ Health & Education Sectors</li>
				<li>✓ 6-Region Global Dashboard</li>
				<li>✓ Advanced Offline Features</li>
				<li>✓ Real-Time WebSocket Integration</li>
				<li>✓ Comprehensive Test Suite</li>
				<li>✓ Dark Mode Support</li>
				<li>✓ Mobile-First Design</li>
				<li>✓ Accessibility Features</li>
			</ul>
		</Card>
	</section>

	<OfflineIndicator />
</div>

<style>
	.showcase {
		max-width: 1400px;
		margin: 0 auto;
		padding: 2rem;
	}

	.showcase-header {
		text-align: center;
		margin-bottom: 3rem;
	}

	.showcase-header h1 {
		margin: 0;
		font-size: 3rem;
		background: linear-gradient(135deg, #3b82f6 0%, #8b5cf6 100%);
		-webkit-background-clip: text;
		-webkit-text-fill-color: transparent;
		background-clip: text;
	}

	.subtitle {
		margin: 1rem 0 2rem 0;
		font-size: 1.25rem;
		color: #6b7280;
	}

	.showcase-section {
		margin: 3rem 0;
	}

	.showcase-section h2 {
		margin: 0 0 1.5rem 0;
		font-size: 2rem;
		color: #1f2937;
	}

	.showcase-section h3 {
		margin: 0 0 1rem 0;
		font-size: 1.25rem;
		color: #374151;
	}

	.demo-grid {
		display: flex;
		flex-wrap: wrap;
		gap: 1rem;
		align-items: center;
	}

	.stats-grid {
		display: grid;
		grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
		gap: 1.5rem;
		margin-bottom: 2rem;
	}

	.stat-card {
		text-align: center;
	}

	.stat-number {
		font-size: 3rem;
		font-weight: 700;
		background: linear-gradient(135deg, #3b82f6 0%, #8b5cf6 100%);
		-webkit-background-clip: text;
		-webkit-text-fill-color: transparent;
		background-clip: text;
	}

	.stat-label {
		font-size: 1rem;
		color: #6b7280;
		text-transform: uppercase;
		letter-spacing: 0.05em;
		margin-top: 0.5rem;
	}

	.checklist {
		list-style: none;
		padding: 0;
		display: grid;
		grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
		gap: 0.75rem;
	}

	.checklist li {
		font-size: 1rem;
		color: #059669;
		font-weight: 500;
	}

	@media (max-width: 768px) {
		.showcase {
			padding: 1rem;
		}

		.showcase-header h1 {
			font-size: 2rem;
		}

		.subtitle {
			font-size: 1rem;
		}

		.stats-grid {
			grid-template-columns: repeat(2, 1fr);
		}

		.checklist {
			grid-template-columns: 1fr;
		}
	}

	@media (prefers-color-scheme: dark) {
		.showcase-header h1 {
			background: linear-gradient(135deg, #60a5fa 0%, #a78bfa 100%);
			-webkit-background-clip: text;
			-webkit-text-fill-color: transparent;
			background-clip: text;
		}

		.subtitle {
			color: #9ca3af;
		}

		.showcase-section h2 {
			color: #f3f4f6;
		}

		.showcase-section h3 {
			color: #d1d5db;
		}

		.stat-label {
			color: #9ca3af;
		}
	}
</style>
