<script lang="ts">
	import { onMount, onDestroy } from 'svelte';
	import { realtimeClient, connectionStatus } from '$lib/realtime';
	import Card from '../ui/Card.svelte';
	import Badge from '../ui/Badge.svelte';
	import Button from '../ui/Button.svelte';

	let connected = false;
	let reconnectAttempts = 0;
	let events: any[] = [];
	let maxEvents = 10;

	const unsubscribeConnection = realtimeClient.connectionState.subscribe((state) => {
		connected = state.status === 'connected';
		reconnectAttempts = state.reconnectAttempts;
	});

	const unsubscribeEvents = realtimeClient.events.subscribe((allEvents) => {
		events = allEvents.slice(-maxEvents);
	});

	onMount(() => {
		// Auto-connect on mount
		if (!connected && navigator.onLine) {
			realtimeClient.connect();
		}
	});

	onDestroy(() => {
		unsubscribeConnection();
		unsubscribeEvents();
	});

	function toggleConnection() {
		if (connected) {
			realtimeClient.disconnect();
		} else {
			realtimeClient.connect();
		}
	}

	function clearEvents() {
		realtimeClient.events.set([]);
	}

	function getStatusColor(status: string) {
		switch (status) {
			case 'connected':
				return 'success';
			case 'connecting':
				return 'info';
			case 'disconnected':
				return 'warning';
			case 'error':
				return 'danger';
			default:
				return 'default';
		}
	}
</script>

<Card padding="lg" shadow="md">
	<div class="realtime-monitor">
		<div class="monitor-header">
			<h3>📡 Real-Time Connection</h3>
			<Badge variant={getStatusColor($connectionStatus)} size="md">
				{$connectionStatus}
			</Badge>
		</div>

		<div class="connection-controls">
			<Button variant={connected ? 'danger' : 'primary'} on:click={toggleConnection}>
				{connected ? 'Disconnect' : 'Connect'}
			</Button>
			{#if reconnectAttempts > 0}
				<span class="reconnect-info">Reconnect attempts: {reconnectAttempts}</span>
			{/if}
		</div>

		<div class="events-section">
			<div class="events-header">
				<h4>Recent Events</h4>
				{#if events.length > 0}
					<button class="clear-btn" on:click={clearEvents}>Clear</button>
				{/if}
			</div>

			{#if events.length === 0}
				<div class="empty-events">
					<p>No events received yet</p>
					<span class="empty-subtitle">Events will appear here in real-time</span>
				</div>
			{:else}
				<div class="events-list">
					{#each events as event (event.timestamp)}
						<div class="event-item">
							<div class="event-type">
								<Badge variant="info" size="sm">{event.type}</Badge>
							</div>
							<div class="event-payload">
								<pre>{JSON.stringify(event.payload, null, 2)}</pre>
							</div>
							<div class="event-timestamp">
								{new Date(event.timestamp).toLocaleTimeString()}
							</div>
						</div>
					{/each}
				</div>
			{/if}
		</div>

		<div class="connection-info">
			<h4>Available Channels</h4>
			<ul>
				<li>🌍 <strong>global:stats</strong> - Global covenant statistics</li>
				<li>🏗️ <strong>sectors:*</strong> - Sector-specific updates</li>
				<li>📊 <strong>projects:*</strong> - Project progress updates</li>
				<li>🗺️ <strong>regions:*</strong> - Regional health status</li>
			</ul>
		</div>
	</div>
</Card>

<style>
	.realtime-monitor {
		display: flex;
		flex-direction: column;
		gap: 1.5rem;
	}

	.monitor-header {
		display: flex;
		justify-content: space-between;
		align-items: center;
	}

	.monitor-header h3 {
		margin: 0;
		font-size: 1.25rem;
		color: #1f2937;
	}

	.connection-controls {
		display: flex;
		align-items: center;
		gap: 1rem;
	}

	.reconnect-info {
		font-size: 0.875rem;
		color: #6b7280;
	}

	.events-section {
		display: flex;
		flex-direction: column;
		gap: 1rem;
	}

	.events-header {
		display: flex;
		justify-content: space-between;
		align-items: center;
	}

	.events-header h4 {
		margin: 0;
		font-size: 1rem;
		color: #374151;
	}

	.clear-btn {
		padding: 0.5rem 1rem;
		background: none;
		border: 1px solid #d1d5db;
		border-radius: 0.375rem;
		font-size: 0.875rem;
		color: #6b7280;
		cursor: pointer;
		transition: all 0.2s;
	}

	.clear-btn:hover {
		background: #f3f4f6;
		border-color: #9ca3af;
	}

	.empty-events {
		text-align: center;
		padding: 2rem;
		color: #6b7280;
	}

	.empty-events p {
		margin: 0;
		font-weight: 600;
	}

	.empty-subtitle {
		display: block;
		margin-top: 0.5rem;
		font-size: 0.875rem;
	}

	.events-list {
		display: flex;
		flex-direction: column;
		gap: 0.75rem;
		max-height: 400px;
		overflow-y: auto;
	}

	.event-item {
		padding: 1rem;
		background: #f9fafb;
		border-radius: 0.5rem;
		border-left: 3px solid #3b82f6;
	}

	.event-type {
		margin-bottom: 0.5rem;
	}

	.event-payload {
		margin: 0.5rem 0;
	}

	.event-payload pre {
		margin: 0;
		padding: 0.75rem;
		background: white;
		border-radius: 0.375rem;
		font-size: 0.75rem;
		overflow-x: auto;
		font-family: 'Courier New', monospace;
	}

	.event-timestamp {
		font-size: 0.75rem;
		color: #6b7280;
		text-align: right;
	}

	.connection-info {
		padding: 1rem;
		background: #eff6ff;
		border-radius: 0.5rem;
		border-left: 3px solid #3b82f6;
	}

	.connection-info h4 {
		margin: 0 0 0.75rem 0;
		font-size: 1rem;
		color: #1e40af;
	}

	.connection-info ul {
		margin: 0;
		padding-left: 1.25rem;
		display: flex;
		flex-direction: column;
		gap: 0.5rem;
	}

	.connection-info li {
		font-size: 0.875rem;
		color: #1f2937;
	}

	@media (prefers-color-scheme: dark) {
		.monitor-header h3 {
			color: #f3f4f6;
		}

		.reconnect-info {
			color: #9ca3af;
		}

		.events-header h4 {
			color: #d1d5db;
		}

		.clear-btn {
			border-color: #4b5563;
			color: #9ca3af;
		}

		.clear-btn:hover {
			background: #374151;
			border-color: #6b7280;
		}

		.empty-events {
			color: #9ca3af;
		}

		.event-item {
			background: #1f2937;
		}

		.event-payload pre {
			background: #111827;
			color: #e5e7eb;
		}

		.event-timestamp {
			color: #9ca3af;
		}

		.connection-info {
			background: #1e3a8a;
		}

		.connection-info h4 {
			color: #93c5fd;
		}

		.connection-info li {
			color: #e5e7eb;
		}
	}
</style>
