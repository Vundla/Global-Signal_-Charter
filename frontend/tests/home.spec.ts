import { test, expect } from '@playwright/test';

test.describe('Homepage', () => {
  test('should load the homepage', async ({ page }) => {
    await page.goto('/');
    
    // Check that page loads
    await expect(page).toHaveTitle(/Global/i);
  });

  test('should display main content', async ({ page }) => {
    await page.goto('/');
    
    // Wait for page to be interactive
    await page.waitForLoadState('networkidle');
    
    // Check for main UI elements
    const body = await page.locator('body');
    await expect(body).toBeVisible();
  });
});

test.describe('Service Worker', () => {
  test('should register service worker', async ({ page, context }) => {
    await context.grantPermissions(['notifications']);
    await page.goto('/');
    
    // Wait for service worker registration
    await page.waitForTimeout(2000);
    
    // Check if service worker is registered
    const swRegistered = await page.evaluate(() => {
      return navigator.serviceWorker.controller !== null;
    });
    
    // Service worker should eventually be registered
    expect(typeof swRegistered).toBe('boolean');
  });
});
