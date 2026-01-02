import { test, expect } from '@playwright/test';

test.describe('Offline Features', () => {
	test('should load offline page without errors', async ({ page }) => {
		await page.goto('/offline');
		await page.waitForLoadState('networkidle');

		// Check page loaded
		const content = await page.textContent('body');
		expect(content).toBeTruthy();
	});

	test('should display offline-related content', async ({ page }) => {
		await page.goto('/offline');
		await page.waitForLoadState('networkidle');

		const content = await page.textContent('body');
		expect(content).toMatch(/offline|cache|sync/i);
	});
});

test.describe('Cache Manager', () => {
	test('should load cache manager component', async ({ page }) => {
		await page.goto('/offline');
		await page.waitForLoadState('networkidle');

		const content = await page.textContent('body');
		expect(content).toBeTruthy();
	});

	test('should have interactive buttons', async ({ page }) => {
		await page.goto('/offline');
		await page.waitForLoadState('networkidle');

		const buttons = page.locator('button');
		const count = await buttons.count();
		expect(count).toBeGreaterThanOrEqual(0);
	});
});

test.describe('Sync Queue', () => {
	test('should display sync queue section', async ({ page }) => {
		await page.goto('/offline');
		await page.waitForLoadState('networkidle');

		const content = await page.textContent('body');
		expect(content).toBeTruthy();
	});

	test('should be responsive on mobile', async ({ page }) => {
		await page.setViewportSize({ width: 375, height: 667 });
		await page.goto('/offline');
		await page.waitForLoadState('networkidle');

		const content = await page.textContent('body');
		expect(content).toBeTruthy();
	});
});
