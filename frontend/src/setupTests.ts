import '@testing-library/jest-dom';
import { vi } from 'vitest';

// Force Svelte to use client-side mode for testing
globalThis.window = globalThis.window || ({} as any);
globalThis.document = globalThis.document || ({} as any);

// Mock navigator
if (!globalThis.navigator) {
  (globalThis as any).navigator = {
    onLine: true,
    userAgent: 'Mozilla/5.0 (Test)'
  };
}

// Mock localStorage with actual storage
const storage: Record<string, string> = {};
const localStorageMock = {
  getItem: (key: string) => storage[key] || null,
  setItem: (key: string, value: string) => { storage[key] = value; },
  removeItem: (key: string) => { delete storage[key]; },
  clear: () => { Object.keys(storage).forEach(key => delete storage[key]); }
};
(globalThis as any).localStorage = localStorageMock;

// Mock fetch
(globalThis as any).fetch = vi.fn();
