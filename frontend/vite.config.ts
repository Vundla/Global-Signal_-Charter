import { sveltekit } from '@sveltejs/kit/vite';
import { defineConfig } from 'vitest/config';

export default defineConfig({
	plugins: [
		sveltekit()
	],
	
	// Force resolution to client-side Svelte for testing
	resolve: {
		conditions: ['browser', 'default']
	},
	
	test: {
		globals: true,
		environment: 'happy-dom',
		setupFiles: ['./src/setupTests.ts'],
		exclude: ['node_modules', 'tests/**'],
		// Svelte 5 specific configuration
		alias: {
			'$app': '.svelte-kit/runtime/app',
			'$lib': './src/lib'
		}
	},
	
	optimizeDeps: {
		exclude: ['@apollo/client', 'graphql']
	},
	
	server: {
		port: 5173,
		proxy: {
			'/api': {
				target: 'http://localhost:4000',
				changeOrigin: true
			}
		}
	},

	build: {
		target: 'es2020',
		minify: 'esbuild',
		cssMinify: true
	}
});
