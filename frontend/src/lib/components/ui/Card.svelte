<script lang="ts">
	export let padding: 'none' | 'sm' | 'md' | 'lg' = 'md';
	export let shadow: 'none' | 'sm' | 'md' | 'lg' = 'md';
	export let hover = false;
	export let bordered = false;
</script>

<div class="card padding-{padding} shadow-{shadow}" class:hover class:bordered>
	<slot />
</div>

<style>
	.card {
		background: white;
		border-radius: 0.75rem;
		transition: all 0.2s ease;
	}

	.bordered {
		border: 1px solid #e5e7eb;
	}

	/* Padding */
	.padding-none {
		padding: 0;
	}

	.padding-sm {
		padding: 0.75rem;
	}

	.padding-md {
		padding: 1.5rem;
	}

	.padding-lg {
		padding: 2rem;
	}

	/* Shadow */
	.shadow-none {
		box-shadow: none;
	}

	.shadow-sm {
		box-shadow: 0 1px 2px 0 rgba(0, 0, 0, 0.05);
	}

	.shadow-md {
		box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
	}

	.shadow-lg {
		box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
	}

	.hover:hover {
		transform: translateY(-2px);
		box-shadow: 0 12px 20px -5px rgba(0, 0, 0, 0.15);
	}

	@media (prefers-color-scheme: dark) {
		.card {
			background: #1f2937;
			color: #f3f4f6;
		}

		.bordered {
			border-color: #374151;
		}
	}
</style>
