<script lang="ts">
	export let type: 'text' | 'email' | 'password' | 'number' | 'search' = 'text';
	export let value: string | number = '';
	export let placeholder: string = '';
	export let disabled = false;
	export let required = false;
	export let label: string = '';
	export let error: string = '';
	export let id: string = `input-${Math.random().toString(36).substr(2, 9)}`;
</script>

<div class="input-group">
	{#if label}
		<label for={id} class="input-label">{label}</label>
	{/if}
	<input
		{id}
		{type}
		{placeholder}
		{disabled}
		{required}
		bind:value
		class="input"
		class:error
		on:input
		on:change
		on:focus
		on:blur
	/>
	{#if error}
		<span class="input-error">{error}</span>
	{/if}
</div>

<style>
	.input-group {
		display: flex;
		flex-direction: column;
		gap: 0.5rem;
		margin-bottom: 1rem;
	}

	.input-label {
		font-size: 0.875rem;
		font-weight: 600;
		color: #374151;
	}

	.input {
		width: 100%;
		padding: 0.75rem 1rem;
		border: 2px solid #d1d5db;
		border-radius: 0.5rem;
		font-size: 1rem;
		font-family: inherit;
		transition: all 0.2s ease;
		background: white;
	}

	.input:focus {
		outline: none;
		border-color: #3b82f6;
		box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
	}

	.input:disabled {
		background: #f3f4f6;
		cursor: not-allowed;
		opacity: 0.6;
	}

	.input.error {
		border-color: #ef4444;
	}

	.input.error:focus {
		box-shadow: 0 0 0 3px rgba(239, 68, 68, 0.1);
	}

	.input-error {
		font-size: 0.875rem;
		color: #ef4444;
	}

	@media (prefers-color-scheme: dark) {
		.input-label {
			color: #f3f4f6;
		}

		.input {
			background: #1f2937;
			border-color: #4b5563;
			color: #f3f4f6;
		}

		.input:disabled {
			background: #111827;
		}
	}
</style>
