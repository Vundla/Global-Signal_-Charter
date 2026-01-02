<script lang="ts">
	import { page } from '$app/stores';

	interface NavItem {
		label: string;
		href: string;
		icon: string;
		children?: { label: string; href: string }[];
	}

	const navItems: NavItem[] = [
		{
			label: 'Dashboard',
			href: '/',
			icon: '📊'
		},
		{
			label: 'Sectors',
			href: '/sectors',
			icon: '🏗️',
			children: [
				{ label: 'Agriculture', href: '/sectors/agriculture' },
				{ label: 'Minerals', href: '/sectors/minerals' },
				{ label: 'Energy', href: '/sectors/energy' },
				{ label: 'Technology', href: '/sectors/technology' },
				{ label: 'Health', href: '/sectors/health' },
				{ label: 'Education', href: '/sectors/education' }
			]
		},
		{
			label: 'Countries',
			href: '/countries',
			icon: '🌍'
		},
		{
			label: 'Projects',
			href: '/projects',
			icon: '🚀'
		},
		{
			label: 'Regions',
			href: '/regions',
			icon: '🗺️'
		},
		{
			label: 'Codex',
			href: '/codex',
			icon: '📜'
		}
	];

	let expandedItems: Set<string> = new Set();

	function toggleExpanded(label: string) {
		if (expandedItems.has(label)) {
			expandedItems.delete(label);
		} else {
			expandedItems.add(label);
		}
		expandedItems = expandedItems;
	}

	function isActive(href: string): boolean {
		return $page.url.pathname === href || $page.url.pathname.startsWith(href + '/');
	}

	function isExpanded(label: string): boolean {
		return expandedItems.has(label);
	}
</script>

<aside class="sidebar">
	<nav class="sidebar-nav">
		{#each navItems as item}
			<div class="nav-item">
				{#if item.children}
					<button
						class="nav-button"
						class:active={isActive(item.href)}
						on:click={() => toggleExpanded(item.label)}
					>
						<span class="nav-icon">{item.icon}</span>
						<span class="nav-label">{item.label}</span>
						<span class="nav-expand" class:expanded={isExpanded(item.label)}>
							▼
						</span>
					</button>
					{#if isExpanded(item.label)}
						<div class="nav-children">
							{#each item.children as child}
								<a href={child.href} class="nav-child" class:active={isActive(child.href)}>
									{child.label}
								</a>
							{/each}
						</div>
					{/if}
				{:else}
					<a href={item.href} class="nav-link" class:active={isActive(item.href)}>
						<span class="nav-icon">{item.icon}</span>
						<span class="nav-label">{item.label}</span>
					</a>
				{/if}
			</div>
		{/each}
	</nav>

	<div class="sidebar-footer">
		<div class="sidebar-stats">
			<div class="stat">
				<span class="stat-label">Phase</span>
				<span class="stat-value">4</span>
			</div>
			<div class="stat">
				<span class="stat-label">Nations</span>
				<span class="stat-value">195</span>
			</div>
		</div>
	</div>
</aside>

<style>
	.sidebar {
		position: sticky;
		top: 0;
		height: 100vh;
		width: 280px;
		background: linear-gradient(180deg, #1e293b 0%, #0f172a 100%);
		border-right: 1px solid #334155;
		display: flex;
		flex-direction: column;
		overflow-y: auto;
	}

	.sidebar-nav {
		flex: 1;
		padding: 1.5rem 1rem;
		display: flex;
		flex-direction: column;
		gap: 0.5rem;
	}

	.nav-item {
		display: flex;
		flex-direction: column;
	}

	.nav-link,
	.nav-button {
		display: flex;
		align-items: center;
		gap: 0.75rem;
		padding: 0.875rem 1rem;
		color: #cbd5e1;
		text-decoration: none;
		border-radius: 0.5rem;
		transition: all 0.2s;
		border: none;
		background: none;
		width: 100%;
		cursor: pointer;
		font-family: inherit;
		font-size: 0.9375rem;
	}

	.nav-link:hover,
	.nav-button:hover {
		background: rgba(59, 130, 246, 0.1);
		color: #60a5fa;
	}

	.nav-link.active,
	.nav-button.active {
		background: rgba(59, 130, 246, 0.2);
		color: #60a5fa;
		font-weight: 600;
	}

	.nav-icon {
		font-size: 1.25rem;
		flex-shrink: 0;
	}

	.nav-label {
		flex: 1;
		text-align: left;
	}

	.nav-expand {
		font-size: 0.625rem;
		transition: transform 0.2s;
		color: #94a3b8;
	}

	.nav-expand.expanded {
		transform: rotate(180deg);
	}

	.nav-children {
		display: flex;
		flex-direction: column;
		gap: 0.25rem;
		padding-left: 2.5rem;
		margin-top: 0.25rem;
	}

	.nav-child {
		padding: 0.625rem 1rem;
		color: #94a3b8;
		text-decoration: none;
		border-radius: 0.375rem;
		font-size: 0.875rem;
		transition: all 0.2s;
	}

	.nav-child:hover {
		background: rgba(59, 130, 246, 0.1);
		color: #93c5fd;
	}

	.nav-child.active {
		background: rgba(59, 130, 246, 0.15);
		color: #93c5fd;
		font-weight: 500;
	}

	.sidebar-footer {
		padding: 1.5rem 1rem;
		border-top: 1px solid #334155;
	}

	.sidebar-stats {
		display: grid;
		grid-template-columns: 1fr 1fr;
		gap: 1rem;
	}

	.stat {
		display: flex;
		flex-direction: column;
		align-items: center;
		gap: 0.25rem;
		padding: 0.75rem;
		background: rgba(59, 130, 246, 0.1);
		border-radius: 0.5rem;
	}

	.stat-label {
		font-size: 0.75rem;
		color: #94a3b8;
		text-transform: uppercase;
		letter-spacing: 0.05em;
	}

	.stat-value {
		font-size: 1.5rem;
		font-weight: 700;
		color: #60a5fa;
	}

	@media (max-width: 1024px) {
		.sidebar {
			display: none;
		}
	}
</style>
