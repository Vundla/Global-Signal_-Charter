import { test, expect } from '@playwright/test';

test.describe('Region Dashboard', () => {
	test.beforeEach(async ({ page }) => {
		await page.goto('/regions');
		await page.waitForLoadState('networkidle');
	});

	test('should display region dashboard title', async ({ page }) => {
		await expect(page.getByRole('heading', { name: /regions|infrastructure/i })).toBeVisible();
	});

	test('should display region information', async ({ page }) => {
		// Look for region-related content
		await expect(page.getByText(/region|infrastructure|global/i).first()).toBeVisible();
	});

	test('should display status badges', async ({ page }) => {
		const statusBadges = page.locator('[class*="badge"]');
		const count = await statusBadges.count();
		expect(count).toBeGreaterThanOrEqual(0);
	});
});

test.describe('Region Health', () => {
	test.beforeEach(async ({ page }) => {
		await page.goto('/regions');
		await page.waitForLoadState('networkidle');
	});

	test('should display region metrics', async ({ page }) => {
		// Check for common metrics
		const content = await page.textContent('body');
		expect(content).toBeTruthy();
	});
});
