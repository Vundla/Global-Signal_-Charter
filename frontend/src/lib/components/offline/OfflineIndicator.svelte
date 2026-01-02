<script lang="ts">
	import { onMount } from 'svelte';
	import Badge from '../ui/Badge.svelte';
	import Alert from '../ui/Alert.svelte';

	let online = true;
	let syncStatus: 'idle' | 'syncing' | 'success' | 'error' = 'idle';
	let pendingSync = 0;
	let lastSyncTime: Date | null = null;

	onMount(() => {
		// Check online status
		online = navigator.onLine;

		// Listen for online/offline events
		const handleOnline = () => {
			online = true;
			triggerSync();
		};

		const handleOffline = () => {
			online = false;
		};

		window.addEventListener('online', handleOnline);
		window.addEventListener('offline', handleOffline);

		// Check for pending sync items
		checkPendingSync();

		return () => {
			window.removeEventListener('online', handleOnline);
			window.removeEventListener('offline', handleOffline);
		};
	});

	async function checkPendingSync() {
		// In a real app, this would check IndexedDB for pending items
		// For now, simulate with random number
		pendingSync = 0;
	}

	async function triggerSync() {
		if (!online || syncStatus === 'syncing') return;

		syncStatus = 'syncing';

		try {
			// Simulate sync operation
			await new Promise((resolve) => setTimeout(resolve, 1500));

			syncStatus = 'success';
			pendingSync = 0;
			lastSyncTime = new Date();

			// Reset status after 3 seconds
			setTimeout(() => {
				if (syncStatus === 'success') {
					syncStatus = 'idle';
				}
			}, 3000);
		} catch (error) {
			syncStatus = 'error';
			console.error('Sync failed:', error);
		}
	}

	function formatLastSync(): string {
		if (!lastSyncTime) return 'Never';

		const now = new Date();
		const diff = now.getTime() - lastSyncTime.getTime();
		const seconds = Math.floor(diff / 1000);
		const minutes = Math.floor(seconds / 60);
		const hours = Math.floor(minutes / 60);

		if (seconds < 60) return 'Just now';
		if (minutes < 60) return `${minutes}m ago`;
		if (hours < 24) return `${hours}h ago`;
		return lastSyncTime.toLocaleDateString();
	}
</script>

<div class="offline-indicator">
	{#if !online}
		<div class="offline-banner">
			<Alert variant="warning" dismissible>
				<strong>You're offline</strong> - Changes will sync when connection is restored
			</Alert>
		</div>
	{/if}

	<div class="sync-status">
		<div class="status-info">
			<Badge variant={online ? 'success' : 'warning'} size="sm">
				{online ? '🟢 Online' : '🟡 Offline'}
			</Badge>

			{#if pendingSync > 0}
				<Badge variant="info" size="sm">
					{pendingSync} pending
				</Badge>
			{/if}
		</div>

		{#if online}
			<button class="sync-button" on:click={triggerSync} disabled={syncStatus === 'syncing'}>
				{#if syncStatus === 'syncing'}
					<span class="spinner"></span>
					Syncing...
				{:else if syncStatus === 'success'}
					✓ Synced
				{:else if syncStatus === 'error'}
					✗ Error
				{:else}
					🔄 Sync
				{/if}
			</button>
		{/if}
	</div>

	{#if lastSyncTime}
		<div class="last-sync">
			<span class="last-sync-text">Last sync: {formatLastSync()}</span>
		</div>
	{/if}
</div>

<style>
	.offline-indicator {
		position: fixed;
		bottom: 1.5rem;
		right: 1.5rem;
		z-index: 1000;
		display: flex;
		flex-direction: column;
		gap: 0.75rem;
		max-width: 400px;
	}

	.offline-banner {
		animation: slideIn 0.3s ease-out;
	}

	.sync-status {
		display: flex;
		align-items: center;
		gap: 0.75rem;
		padding: 0.75rem 1rem;
		background: white;
		border-radius: 0.75rem;
		box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
		animation: slideIn 0.3s ease-out;
	}

	.status-info {
		display: flex;
		gap: 0.5rem;
	}

	.sync-button {
		display: flex;
		align-items: center;
		gap: 0.5rem;
		padding: 0.5rem 1rem;
		background: #3b82f6;
		color: white;
		border: none;
		border-radius: 0.5rem;
		font-weight: 600;
		font-size: 0.875rem;
		cursor: pointer;
		transition: all 0.2s;
		font-family: inherit;
	}

	.sync-button:hover:not(:disabled) {
		background: #2563eb;
	}

	.sync-button:disabled {
		opacity: 0.7;
		cursor: not-allowed;
	}

	.spinner {
		display: inline-block;
		width: 1em;
		height: 1em;
		border: 2px solid currentColor;
		border-right-color: transparent;
		border-radius: 50%;
		animation: spin 0.6s linear infinite;
	}

	.last-sync {
		text-align: right;
		padding: 0 0.5rem;
	}

	.last-sync-text {
		font-size: 0.75rem;
		color: #6b7280;
	}

	@keyframes slideIn {
		from {
			transform: translateY(20px);
			opacity: 0;
		}
		to {
			transform: translateY(0);
			opacity: 1;
		}
	}

	@keyframes spin {
		to {
			transform: rotate(360deg);
		}
	}

	@media (max-width: 640px) {
		.offline-indicator {
			bottom: 1rem;
			right: 1rem;
			left: 1rem;
			max-width: none;
		}
	}

	@media (prefers-color-scheme: dark) {
		.sync-status {
			background: #1f2937;
		}

		.last-sync-text {
			color: #9ca3af;
		}
	}
</style>
