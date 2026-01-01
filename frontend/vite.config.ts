import { sveltekit } from '@sveltejs/kit/vite';
import { defineConfig } from 'vite';
import { VitePWA } from 'vite-plugin-pwa';

export default defineConfig({
	plugins: [
		sveltekit(),
		VitePWA({
			registerType: 'autoUpdate',
			workbox: {
				globPatterns: ['**/*.{js,css,html,ico,png,svg,woff,woff2}'],
				runtimeCaching: [
					{
						urlPattern: /^https:\/\/api\.sovereign\.network\/api\/.*/i,
						handler: 'NetworkFirst',
						options: {
							cacheName: 'api-cache',
							expiration: {
								maxEntries: 200,
								maxAgeSeconds: 60 * 60 // 1 hour
							},
							cacheableResponse: {
								statuses: [0, 200]
							}
						}
					},
					{
						urlPattern: /^https:\/\/api\.sovereign\.network\/static\/.*/i,
						handler: 'CacheFirst',
						options: {
							cacheName: 'static-cache',
							expiration: {
								maxEntries: 500,
								maxAgeSeconds: 60 * 60 * 24 * 7 // 7 days
							}
						}
					},
					{
						urlPattern: /^https:\/\/.*\.(?:png|jpg|jpeg|svg|gif|webp)$/,
						handler: 'CacheFirst',
						options: {
							cacheName: 'image-cache',
							expiration: {
								maxEntries: 300,
								maxAgeSeconds: 60 * 60 * 24 * 30 // 30 days
							}
						}
					}
				]
			},
			manifest: {
				name: 'Global Sovereign System',
				short_name: 'Sovereign',
				description: 'Offline-first connectivity for communities worldwide',
				theme_color: '#1a1a1a',
				background_color: '#ffffff',
				display: 'standalone',
				scope: '/',
				start_url: '/',
				icons: [
					{
						src: '/icon-192.png',
						sizes: '192x192',
						type: 'image/png'
					},
					{
						src: '/icon-512.png',
						sizes: '512x512',
						type: 'image/png'
					},
					{
						src: '/icon-512.png',
						sizes: '512x512',
						type: 'image/png',
						purpose: 'any maskable'
					}
				]
			}
		})
	],
	
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
