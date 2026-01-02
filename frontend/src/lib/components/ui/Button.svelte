<script lang="ts">
	export let variant: 'primary' | 'secondary' | 'danger' | 'ghost' = 'primary';
	export let size: 'sm' | 'md' | 'lg' = 'md';
	export let disabled = false;
	export let loading = false;
	export let fullWidth = false;
	export let type: 'button' | 'submit' | 'reset' = 'button';
</script>

<button
	{type}
	class="btn btn-{variant} btn-{size}"
	class:full-width={fullWidth}
	class:loading
	{disabled}
	on:click
>
	{#if loading}
		<span class="spinner"></span>
	{/if}
	<slot />
</button>

<style>
	.btn {
		display: inline-flex;
		align-items: center;
		justify-content: center;
		gap: 0.5rem;
		border: none;
		border-radius: 0.5rem;
		font-weight: 600;
		cursor: pointer;
		transition: all 0.2s ease;
		font-family: inherit;
	}

	.btn:disabled {
		opacity: 0.5;
		cursor: not-allowed;
	}

	/* Sizes */
	.btn-sm {
		padding: 0.5rem 1rem;
		font-size: 0.875rem;
	}

	.btn-md {
		padding: 0.75rem 1.5rem;
		font-size: 1rem;
	}

	.btn-lg {
		padding: 1rem 2rem;
		font-size: 1.125rem;
	}

	/* Variants */
	.btn-primary {
		background: #3b82f6;
		color: white;
	}

	.btn-primary:hover:not(:disabled) {
		background: #2563eb;
		transform: translateY(-1px);
		box-shadow: 0 4px 12px rgba(59, 130, 246, 0.4);
	}

	.btn-secondary {
		background: #6b7280;
		color: white;
	}

	.btn-secondary:hover:not(:disabled) {
		background: #4b5563;
		transform: translateY(-1px);
	}

	.btn-danger {
		background: #ef4444;
		color: white;
	}

	.btn-danger:hover:not(:disabled) {
		background: #dc2626;
		transform: translateY(-1px);
	}

	.btn-ghost {
		background: transparent;
		color: #3b82f6;
		border: 2px solid #3b82f6;
	}

	.btn-ghost:hover:not(:disabled) {
		background: #3b82f6;
		color: white;
	}

	.full-width {
		width: 100%;
	}

	.loading {
		position: relative;
		pointer-events: none;
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

	@keyframes spin {
		to {
			transform: rotate(360deg);
		}
	}
</style>
