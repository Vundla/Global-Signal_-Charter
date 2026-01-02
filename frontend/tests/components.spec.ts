import { test, expect } from '@playwright/test';

test.describe('UI Components', () => {
	test.beforeEach(async ({ page }) => {
		await page.goto('/');
		await page.waitForLoadState('networkidle');
	});

	test('should display header with logo', async ({ page }) => {
		const logo = page.locator('.header .logo');
		await expect(logo).toBeVisible();
		await expect(logo).toContainText('Global Sovereign Network');
	});

	test('should display navigation links', async ({ page }) => {
		const nav = page.locator('.header .nav');
		await expect(nav).toBeVisible();

		// Check for key navigation items
		await expect(page.getByRole('link', { name: /home/i })).toBeVisible();
		await expect(page.getByRole('link', { name: /regions/i })).toBeVisible();
		await expect(page.getByRole('link', { name: /health/i })).toBeVisible();
	});

	test('should display footer with copyright', async ({ page }) => {
		const footer = page.locator('footer.footer');
		await page.evaluate(() => window.scrollTo(0, document.body.scrollHeight));
		await expect(footer).toBeVisible();
		await expect(footer).toContainText('Global Sovereign Covenant');
	});

	test('should show online status badge', async ({ page }) => {
		const statusBadge = page.locator('.header-right').getByRole('status');
		await expect(statusBadge).toBeVisible();
	});
});

test.describe('Responsive Design', () => {
	test('should show mobile menu toggle on small screens', async ({ page }) => {
		await page.setViewportSize({ width: 375, height: 667 });
		await page.goto('/');
		await page.waitForLoadState('networkidle');

		const menuToggle = page.locator('button.menu-toggle');
		await expect(menuToggle).toBeVisible();
	});

	test('should hide mobile menu toggle on desktop', async ({ page }) => {
		await page.setViewportSize({ width: 1280, height: 720 });
		await page.goto('/');
		await page.waitForLoadState('networkidle');

		const menuToggle = page.locator('button.menu-toggle');
		// On desktop, menu toggle should be hidden (display: none)
		const isHidden = await menuToggle.evaluate((el) => {
			const styles = window.getComputedStyle(el);
			return styles.display === 'none';
		});
		expect(isHidden).toBe(true);
	});
});
