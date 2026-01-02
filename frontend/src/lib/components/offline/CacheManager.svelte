<script lang="ts">
	import { onMount } from 'svelte';
	import Card from '../ui/Card.svelte';
	import Button from '../ui/Button.svelte';
	import Badge from '../ui/Badge.svelte';

	interface CacheStats {
		totalSize: number;
		itemCount: number;
		lastCleared: Date | null;
	}

	let cacheStats: CacheStats = {
		totalSize: 0,
		itemCount: 0,
		lastCleared: null
	};

	let clearing = false;

	onMount(async () => {
		await loadCacheStats();
	});

	async function loadCacheStats() {
		try {
			if ('storage' in navigator && 'estimate' in navigator.storage) {
				const estimate = await navigator.storage.estimate();
				cacheStats.totalSize = estimate.usage || 0;
			}

			// Check IndexedDB size (simplified)
			if ('indexedDB' in window) {
				const databases = await window.indexedDB.databases();
				cacheStats.itemCount = databases.length;
			}

			// Load last cleared time from localStorage
			const lastCleared = localStorage.getItem('lastCacheCleared');
			if (lastCleared) {
				cacheStats.lastCleared = new Date(lastCleared);
			}
		} catch (error) {
			console.error('Failed to load cache stats:', error);
		}
	}

	async function clearCache() {
		if (!confirm('Are you sure you want to clear all cached data?')) {
			return;
		}

		clearing = true;

		try {
			// Clear all caches
			if ('caches' in window) {
				const cacheNames = await caches.keys();
				await Promise.all(cacheNames.map((name) => caches.delete(name)));
			}

			// Clear IndexedDB (careful in production)
			if ('indexedDB' in window) {
				const databases = await window.indexedDB.databases();
				databases.forEach((db) => {
					if (db.name) {
						window.indexedDB.deleteDatabase(db.name);
					}
				});
			}

			// Update stats
			cacheStats.lastCleared = new Date();
			localStorage.setItem('lastCacheCleared', cacheStats.lastCleared.toISOString());

			// Reload stats
			await loadCacheStats();

			alert('Cache cleared successfully!');
		} catch (error) {
			console.error('Failed to clear cache:', error);
			alert('Failed to clear cache. Please try again.');
		} finally {
			clearing = false;
		}
	}

	function formatBytes(bytes: number): string {
		if (bytes === 0) return '0 Bytes';

		const k = 1024;
		const sizes = ['Bytes', 'KB', 'MB', 'GB'];
		const i = Math.floor(Math.log(bytes) / Math.log(k));

		return Math.round((bytes / Math.pow(k, i)) * 100) / 100 + ' ' + sizes[i];
	}

	function formatLastCleared(): string {
		if (!cacheStats.lastCleared) return 'Never';

		const now = new Date();
		const diff = now.getTime() - cacheStats.lastCleared.getTime();
		const days = Math.floor(diff / (1000 * 60 * 60 * 24));

		if (days === 0) return 'Today';
		if (days === 1) return 'Yesterday';
		return `${days} days ago`;
	}
</script>

<Card padding="lg" shadow="md">
	<div class="cache-manager">
		<div class="manager-header">
			<h3>💾 Cache Manager</h3>
			<Badge variant="info" size="md">
				{formatBytes(cacheStats.totalSize)}
			</Badge>
		</div>

		<div class="cache-stats">
			<div class="stat-row">
				<span class="stat-label">Total Size:</span>
				<span class="stat-value">{formatBytes(cacheStats.totalSize)}</span>
			</div>
			<div class="stat-row">
				<span class="stat-label">Cached Items:</span>
				<span class="stat-value">{cacheStats.itemCount}</span>
			</div>
			<div class="stat-row">
				<span class="stat-label">Last Cleared:</span>
				<span class="stat-value">{formatLastCleared()}</span>
			</div>
		</div>

		<div class="cache-info">
			<h4>What's Cached?</h4>
			<ul>
				<li>🖼️ Static assets (images, fonts, CSS, JS)</li>
				<li>📊 API responses and data</li>
				<li>🗺️ Offline maps and resources</li>
				<li>📝 User-created content drafts</li>
			</ul>
		</div>

		<div class="manager-actions">
			<Button variant="danger" fullWidth loading={clearing} on:click={clearCache}>
				Clear All Cache
			</Button>
		</div>

		<p class="cache-warning">
			⚠️ Clearing cache will remove all offline data and require re-download
		</p>
	</div>
</Card>

<style>
	.cache-manager {
		display: flex;
		flex-direction: column;
		gap: 1.5rem;
	}

	.manager-header {
		display: flex;
		justify-content: space-between;
		align-items: center;
	}

	.manager-header h3 {
		margin: 0;
		font-size: 1.25rem;
		color: #1f2937;
	}

	.cache-stats {
		display: flex;
		flex-direction: column;
		gap: 0.75rem;
		padding: 1rem;
		background: #f9fafb;
		border-radius: 0.5rem;
	}

	.stat-row {
		display: flex;
		justify-content: space-between;
		align-items: center;
	}

	.stat-label {
		font-weight: 500;
		color: #6b7280;
	}

	.stat-value {
		font-weight: 600;
		color: #1f2937;
	}

	.cache-info {
		padding: 1rem;
		background: #eff6ff;
		border-radius: 0.5rem;
		border-left: 3px solid #3b82f6;
	}

	.cache-info h4 {
		margin: 0 0 0.75rem 0;
		font-size: 1rem;
		color: #1e40af;
	}

	.cache-info ul {
		margin: 0;
		padding-left: 1.25rem;
		display: flex;
		flex-direction: column;
		gap: 0.5rem;
	}

	.cache-info li {
		font-size: 0.875rem;
		color: #1f2937;
	}

	.manager-actions {
		margin-top: 0.5rem;
	}

	.cache-warning {
		margin: 0;
		font-size: 0.75rem;
		color: #ef4444;
		text-align: center;
	}

	@media (prefers-color-scheme: dark) {
		.manager-header h3 {
			color: #f3f4f6;
		}

		.cache-stats {
			background: #1f2937;
		}

		.stat-label {
			color: #9ca3af;
		}

		.stat-value {
			color: #f3f4f6;
		}

		.cache-info {
			background: #1e3a8a;
		}

		.cache-info h4 {
			color: #93c5fd;
		}

		.cache-info li {
			color: #e5e7eb;
		}
	}
</style>
