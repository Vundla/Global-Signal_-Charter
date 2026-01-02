<script lang="ts">
	export let variant: 'default' | 'success' | 'warning' | 'danger' | 'info' = 'default';
	export let size: 'sm' | 'md' = 'md';
	export let rounded = true;
</script>

<span class="badge badge-{variant} badge-{size}" class:rounded>
	<slot />
</span>

<style>
	.badge {
		display: inline-flex;
		align-items: center;
		justify-content: center;
		font-weight: 600;
		line-height: 1;
		white-space: nowrap;
	}

	.badge-sm {
		padding: 0.25rem 0.5rem;
		font-size: 0.75rem;
	}

	.badge-md {
		padding: 0.375rem 0.75rem;
		font-size: 0.875rem;
	}

	.rounded {
		border-radius: 9999px;
	}

	.badge-default {
		background: #e5e7eb;
		color: #1f2937;
	}

	.badge-success {
		background: #d1fae5;
		color: #065f46;
	}

	.badge-warning {
		background: #fef3c7;
		color: #92400e;
	}

	.badge-danger {
		background: #fee2e2;
		color: #991b1b;
	}

	.badge-info {
		background: #dbeafe;
		color: #1e40af;
	}

	@media (prefers-color-scheme: dark) {
		.badge-default {
			background: #374151;
			color: #f3f4f6;
		}

		.badge-success {
			background: #064e3b;
			color: #a7f3d0;
		}

		.badge-warning {
			background: #78350f;
			color: #fde68a;
		}

		.badge-danger {
			background: #7f1d1d;
			color: #fecaca;
		}

		.badge-info {
			background: #1e3a8a;
			color: #bfdbfe;
		}
	}
</style>
