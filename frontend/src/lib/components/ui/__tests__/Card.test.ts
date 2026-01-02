import { describe, it, expect } from 'vitest';
import { render } from '@testing-library/svelte';
import Card from '../Card.svelte';

describe('Card Component', () => {
	it('renders card element', () => {
		const { container } = render(Card);
		const card = container.querySelector('.card');
		expect(card).toBeInTheDocument();
	});

	it('applies padding classes correctly', () => {
		const { container } = render(Card, { props: { padding: 'lg' } });
		const card = container.querySelector('.card');
		expect(card).toHaveClass('padding-lg');
	});

	it('applies shadow classes correctly', () => {
		const { container } = render(Card, { props: { shadow: 'md' } });
		const card = container.querySelector('.card');
		expect(card).toHaveClass('shadow-md');
	});

	it('applies hover class when hover prop is true', () => {
		const { container } = render(Card, { props: { hover: true } });
		const card = container.querySelector('.card');
		expect(card).toHaveClass('hover');
	});

	it('applies bordered class when bordered prop is true', () => {
		const { container } = render(Card, { props: { bordered: true } });
		const card = container.querySelector('.card');
		expect(card).toHaveClass('bordered');
	});
});
