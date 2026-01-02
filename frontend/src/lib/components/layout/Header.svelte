<script lang="ts">
	import { page } from '$app/stores';
	import Badge from '../ui/Badge.svelte';

	export let healthStatus: string = 'ok';
	export let offlineMode = false;

	let menuOpen = false;

	function toggleMenu() {
		menuOpen = !menuOpen;
	}
</script>

<header class="header">
	<div class="header-container">
		<div class="header-left">
			<a href="/" class="logo">
				<span class="logo-icon">🌍</span>
				<span class="logo-text">Global Sovereign Network</span>
			</a>
		</div>

		<nav class="nav" class:open={menuOpen}>
			<a href="/" class="nav-link" class:active={$page.url.pathname === '/'}>
				Home
			</a>
			<a href="/regions" class="nav-link" class:active={$page.url.pathname === '/regions'}>
				Regions
			</a>
			<a href="/sectors/health" class="nav-link" class:active={$page.url.pathname === '/sectors/health'}>
				Health
			</a>
			<a href="/sectors/education" class="nav-link" class:active={$page.url.pathname === '/sectors/education'}>
				Education
			</a>
			<a href="/offline" class="nav-link" class:active={$page.url.pathname === '/offline'}>
				Offline
			</a>
			<a href="/showcase" class="nav-link" class:active={$page.url.pathname === '/showcase'}>
				Components
			</a>
		</nav>

		<div class="header-right">
			{#if offlineMode}
				<Badge variant="warning" size="sm">Offline</Badge>
			{:else}
				<Badge variant={healthStatus === 'ok' ? 'success' : 'danger'} size="sm">
					{healthStatus}
				</Badge>
			{/if}
			<button class="menu-toggle" on:click={toggleMenu} aria-label="Toggle menu">
				<span class="hamburger"></span>
			</button>
		</div>
	</div>
</header>

<style>
	.header {
		position: sticky;
		top: 0;
		z-index: 50;
		background: linear-gradient(135deg, #1e3a8a 0%, #3b82f6 100%);
		box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
		padding: 0;
	}

	.header-container {
		display: flex;
		align-items: center;
		justify-content: space-between;
		max-width: 1400px;
		margin: 0 auto;
		padding: 1rem 2rem;
	}

	.header-left {
		flex: 0 0 auto;
	}

	.logo {
		display: flex;
		align-items: center;
		gap: 0.75rem;
		text-decoration: none;
		color: white;
		font-weight: 700;
		font-size: 1.25rem;
		transition: opacity 0.2s;
	}

	.logo:hover {
		opacity: 0.9;
	}

	.logo-icon {
		font-size: 1.75rem;
	}

	.logo-text {
		display: none;
	}

	.nav {
		display: none;
		gap: 0.5rem;
	}

	.nav-link {
		padding: 0.625rem 1.25rem;
		color: rgba(255, 255, 255, 0.9);
		text-decoration: none;
		border-radius: 0.5rem;
		font-weight: 500;
		transition: all 0.2s;
		white-space: nowrap;
	}

	.nav-link:hover {
		background: rgba(255, 255, 255, 0.15);
		color: white;
	}

	.nav-link.active {
		background: rgba(255, 255, 255, 0.25);
		color: white;
	}

	.header-right {
		display: flex;
		align-items: center;
		gap: 1rem;
	}

	.menu-toggle {
		display: flex;
		align-items: center;
		justify-content: center;
		width: 2.5rem;
		height: 2.5rem;
		background: none;
		border: none;
		cursor: pointer;
		padding: 0;
	}

	.hamburger {
		display: block;
		width: 1.5rem;
		height: 2px;
		background: white;
		position: relative;
		transition: all 0.3s;
	}

	.hamburger::before,
	.hamburger::after {
		content: '';
		position: absolute;
		width: 1.5rem;
		height: 2px;
		background: white;
		transition: all 0.3s;
	}

	.hamburger::before {
		top: -0.5rem;
	}

	.hamburger::after {
		bottom: -0.5rem;
	}

	/* Desktop */
	@media (min-width: 768px) {
		.logo-text {
			display: inline;
		}

		.nav {
			display: flex;
		}

		.menu-toggle {
			display: none;
		}
	}

	/* Mobile menu open */
	@media (max-width: 767px) {
		.nav.open {
			display: flex;
			flex-direction: column;
			position: absolute;
			top: 100%;
			left: 0;
			right: 0;
			background: linear-gradient(135deg, #1e3a8a 0%, #3b82f6 100%);
			padding: 1rem 2rem;
			box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
		}

		.nav-link {
			width: 100%;
		}
	}
</style>
