import { test, expect } from '@playwright/test';

test.describe('Health Sector', () => {
	test('should display health sector page', async ({ page }) => {
		await page.goto('/sectors/health');
		await page.waitForLoadState('networkidle');

		const content = await page.textContent('body');
		expect(content).toContain('health');
	});

	test('should load without errors', async ({ page }) => {
		await page.goto('/sectors/health');
		await page.waitForLoadState('networkidle');

		// Check page loaded successfully
		const title = await page.title();
		expect(title).toBeTruthy();
	});
});

test.describe('Education Sector', () => {
	test('should display education sector page', async ({ page }) => {
		await page.goto('/sectors/education');
		await page.waitForLoadState('networkidle');

		const content = await page.textContent('body');
		expect(content).toContain('education');
	});

	test('should load without errors', async ({ page }) => {
		await page.goto('/sectors/education');
		await page.waitForLoadState('networkidle');

		const title = await page.title();
		expect(title).toBeTruthy();
	});
});

test.describe('Sectors Navigation', () => {
	test('should navigate between sectors', async ({ page }) => {
		await page.goto('/sectors/health');
		await page.waitForLoadState('networkidle');

		const healthContent = await page.textContent('body');
		expect(healthContent).toBeTruthy();

		// Navigate to education
		await page.goto('/sectors/education');
		await page.waitForLoadState('networkidle');

		const educationContent = await page.textContent('body');
		expect(educationContent).toBeTruthy();
	});
});
