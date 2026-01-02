<script lang="ts">
	export let size: 'sm' | 'md' | 'lg' = 'md';
	export let color: string = '#3b82f6';
	export let centered = false;
	export let text: string = '';
</script>

<div class="spinner-container" class:centered>
	<div class="spinner spinner-{size}" style="border-color: {color}; border-right-color: transparent;"></div>
	{#if text}
		<p class="spinner-text">{text}</p>
	{/if}
</div>

<style>
	.spinner-container {
		display: inline-flex;
		flex-direction: column;
		align-items: center;
		gap: 0.75rem;
	}

	.spinner-container.centered {
		width: 100%;
		padding: 3rem;
		justify-content: center;
	}

	.spinner {
		border: 3px solid;
		border-radius: 50%;
		animation: spin 0.8s linear infinite;
	}

	.spinner-sm {
		width: 1rem;
		height: 1rem;
		border-width: 2px;
	}

	.spinner-md {
		width: 2rem;
		height: 2rem;
		border-width: 3px;
	}

	.spinner-lg {
		width: 3rem;
		height: 3rem;
		border-width: 4px;
	}

	.spinner-text {
		margin: 0;
		font-size: 0.875rem;
		color: #6b7280;
	}

	@keyframes spin {
		to {
			transform: rotate(360deg);
		}
	}

	@media (prefers-color-scheme: dark) {
		.spinner-text {
			color: #9ca3af;
		}
	}
</style>
