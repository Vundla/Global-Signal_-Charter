import { describe, it, expect } from 'vitest';
import { render, screen } from '@testing-library/svelte';
import Button from '../Button.svelte';

describe('Button Component', () => {
	it('renders with text content', () => {
		const { container } = render(Button);
		const button = container.querySelector('button');
		expect(button).toBeInTheDocument();
	});

	it('applies variant classes correctly', () => {
		const { container } = render(Button, {
			props: { variant: 'primary' }
		});
		const button = container.querySelector('button');
		expect(button).toHaveClass('btn-primary');
	});

	it('applies size classes correctly', () => {
		const { container } = render(Button, { props: { size: 'lg' } });
		const button = container.querySelector('button');
		expect(button).toHaveClass('btn-lg');
	});

	it('shows loading spinner when loading prop is true', () => {
		const { container } = render(Button, { props: { loading: true } });
		const spinner = container.querySelector('.spinner');
		expect(spinner).toBeInTheDocument();
	});

	it('disables button when disabled prop is true', () => {
		const { container } = render(Button, { props: { disabled: true } });
		const button = container.querySelector('button');
		expect(button).toBeDisabled();
	});

	it('applies full-width class when fullWidth is true', () => {
		const { container } = render(Button, { props: { fullWidth: true } });
		const button = container.querySelector('button');
		expect(button).toHaveClass('full-width');
	});
});
