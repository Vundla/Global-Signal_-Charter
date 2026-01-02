<script lang="ts">
	export let variant: 'info' | 'success' | 'warning' | 'danger' = 'info';
	export let title: string = '';
	export let dismissible = false;

	let visible = true;

	function dismiss() {
		visible = false;
	}
</script>

{#if visible}
	<div class="alert alert-{variant}" role="alert">
		<div class="alert-content">
			{#if title}
				<div class="alert-title">{title}</div>
			{/if}
			<div class="alert-message">
				<slot />
			</div>
		</div>
		{#if dismissible}
			<button class="alert-dismiss" on:click={dismiss} aria-label="Dismiss">
				×
			</button>
		{/if}
	</div>
{/if}

<style>
	.alert {
		display: flex;
		align-items: flex-start;
		justify-content: space-between;
		padding: 1rem 1.25rem;
		border-radius: 0.5rem;
		border-left: 4px solid;
		margin: 1rem 0;
	}

	.alert-content {
		flex: 1;
	}

	.alert-title {
		font-weight: 600;
		margin-bottom: 0.25rem;
	}

	.alert-message {
		font-size: 0.875rem;
	}

	.alert-dismiss {
		background: none;
		border: none;
		font-size: 1.5rem;
		line-height: 1;
		cursor: pointer;
		padding: 0;
		margin-left: 1rem;
		opacity: 0.7;
		transition: opacity 0.2s;
	}

	.alert-dismiss:hover {
		opacity: 1;
	}

	.alert-info {
		background: #dbeafe;
		border-color: #3b82f6;
		color: #1e40af;
	}

	.alert-success {
		background: #d1fae5;
		border-color: #10b981;
		color: #065f46;
	}

	.alert-warning {
		background: #fef3c7;
		border-color: #f59e0b;
		color: #92400e;
	}

	.alert-danger {
		background: #fee2e2;
		border-color: #ef4444;
		color: #991b1b;
	}

	@media (prefers-color-scheme: dark) {
		.alert-info {
			background: #1e3a8a;
			color: #bfdbfe;
		}

		.alert-success {
			background: #064e3b;
			color: #a7f3d0;
		}

		.alert-warning {
			background: #78350f;
			color: #fde68a;
		}

		.alert-danger {
			background: #7f1d1d;
			color: #fecaca;
		}
	}
</style>
