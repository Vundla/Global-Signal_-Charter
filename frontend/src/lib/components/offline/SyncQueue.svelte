<script lang="ts" context="module">
	export interface SyncQueueItem {
		id: string;
		type: 'create' | 'update' | 'delete';
		entity: string;
		timestamp: Date;
		status: 'pending' | 'syncing' | 'failed';
		retries: number;
	}
</script>

<script lang="ts">
	import Card from '../ui/Card.svelte';
	import Badge from '../ui/Badge.svelte';
	import Button from '../ui/Button.svelte';

	export let items: SyncQueueItem[] = [];

	function getTypeVariant(type: string) {
		switch (type) {
			case 'create':
				return 'success';
			case 'update':
				return 'info';
			case 'delete':
				return 'danger';
			default:
				return 'default';
		}
	}

	function getStatusVariant(status: string) {
		switch (status) {
			case 'pending':
				return 'warning';
			case 'syncing':
				return 'info';
			case 'failed':
				return 'danger';
			default:
				return 'default';
		}
	}

	function formatTimestamp(date: Date): string {
		return new Intl.DateTimeFormat('en-US', {
			hour: '2-digit',
			minute: '2-digit',
			second: '2-digit'
		}).format(date);
	}

	function retryItem(id: string) {
		console.log('Retry item:', id);
		// In real implementation, trigger retry logic
	}

	function clearItem(id: string) {
		console.log('Clear item:', id);
		// In real implementation, remove from queue
	}

	function clearAll() {
		console.log('Clear all items');
		// In real implementation, clear entire queue
	}
</script>

<Card padding="lg" shadow="md">
	<div class="sync-queue">
		<div class="queue-header">
			<h3>📥 Sync Queue</h3>
			{#if items.length > 0}
				<Button variant="ghost" size="sm" on:click={clearAll}>
					Clear All
				</Button>
			{/if}
		</div>

		{#if items.length === 0}
			<div class="empty-state">
				<p>✓ All changes synced</p>
				<span class="empty-subtitle">Changes will appear here when offline</span>
			</div>
		{:else}
			<div class="queue-list">
				{#each items as item (item.id)}
					<div class="queue-item">
						<div class="item-content">
							<div class="item-badges">
								<Badge variant={getTypeVariant(item.type)} size="sm">
									{item.type}
								</Badge>
								<Badge variant={getStatusVariant(item.status)} size="sm">
									{item.status}
								</Badge>
							</div>
							<div class="item-info">
								<span class="item-entity">{item.entity}</span>
								<span class="item-timestamp">{formatTimestamp(item.timestamp)}</span>
								{#if item.retries > 0}
									<span class="item-retries">Retries: {item.retries}</span>
								{/if}
							</div>
						</div>
						<div class="item-actions">
							{#if item.status === 'failed'}
								<button class="action-btn retry" on:click={() => retryItem(item.id)}>
									↻
								</button>
							{/if}
							<button class="action-btn delete" on:click={() => clearItem(item.id)}>
								×
							</button>
						</div>
					</div>
				{/each}
			</div>
		{/if}
	</div>
</Card>

<style>
	.sync-queue {
		display: flex;
		flex-direction: column;
		gap: 1.25rem;
	}

	.queue-header {
		display: flex;
		justify-content: space-between;
		align-items: center;
	}

	.queue-header h3 {
		margin: 0;
		font-size: 1.25rem;
		color: #1f2937;
	}

	.empty-state {
		text-align: center;
		padding: 3rem 1rem;
		color: #6b7280;
	}

	.empty-state p {
		margin: 0;
		font-size: 1.125rem;
		font-weight: 600;
	}

	.empty-subtitle {
		display: block;
		margin-top: 0.5rem;
		font-size: 0.875rem;
	}

	.queue-list {
		display: flex;
		flex-direction: column;
		gap: 0.75rem;
	}

	.queue-item {
		display: flex;
		justify-content: space-between;
		align-items: center;
		padding: 1rem;
		background: #f9fafb;
		border-radius: 0.5rem;
		border-left: 3px solid #3b82f6;
	}

	.item-content {
		flex: 1;
		display: flex;
		flex-direction: column;
		gap: 0.5rem;
	}

	.item-badges {
		display: flex;
		gap: 0.5rem;
	}

	.item-info {
		display: flex;
		flex-wrap: wrap;
		gap: 0.75rem;
		font-size: 0.875rem;
	}

	.item-entity {
		font-weight: 600;
		color: #1f2937;
	}

	.item-timestamp,
	.item-retries {
		color: #6b7280;
	}

	.item-actions {
		display: flex;
		gap: 0.5rem;
	}

	.action-btn {
		width: 2rem;
		height: 2rem;
		display: flex;
		align-items: center;
		justify-content: center;
		border: none;
		border-radius: 0.375rem;
		cursor: pointer;
		font-size: 1.25rem;
		transition: all 0.2s;
	}

	.action-btn.retry {
		background: #3b82f6;
		color: white;
	}

	.action-btn.retry:hover {
		background: #2563eb;
	}

	.action-btn.delete {
		background: #ef4444;
		color: white;
	}

	.action-btn.delete:hover {
		background: #dc2626;
	}

	@media (prefers-color-scheme: dark) {
		.queue-header h3 {
			color: #f3f4f6;
		}

		.empty-state {
			color: #9ca3af;
		}

		.queue-item {
			background: #1f2937;
		}

		.item-entity {
			color: #f3f4f6;
		}

		.item-timestamp,
		.item-retries {
			color: #9ca3af;
		}
	}
</style>
