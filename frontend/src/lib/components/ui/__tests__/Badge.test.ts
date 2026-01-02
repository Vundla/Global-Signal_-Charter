import { describe, it, expect } from 'vitest';
import { render } from '@testing-library/svelte';
import Badge from '../Badge.svelte';

describe('Badge Component', () => {
	it('renders badge element', () => {
		const { container } = render(Badge);
		const badge = container.querySelector('.badge');
		expect(badge).toBeInTheDocument();
	});

	it('applies variant classes correctly', () => {
		const { container } = render(Badge, {
			props: { variant: 'success' }
		});
		const badge = container.querySelector('.badge');
		expect(badge).toHaveClass('badge-success');
	});

	it('applies size classes correctly', () => {
		const { container } = render(Badge, {
			props: { size: 'sm' }
		});
		const badge = container.querySelector('.badge');
		expect(badge).toHaveClass('badge-sm');
	});

	it('applies rounded class by default', () => {
		const { container } = render(Badge);
		const badge = container.querySelector('.badge');
		expect(badge).toHaveClass('rounded');
	});

	it('does not apply rounded class when rounded is false', () => {
		const { container } = render(Badge, {
			props: { rounded: false }
		});
		const badge = container.querySelector('.badge');
		expect(badge).not.toHaveClass('rounded');
	});
});
