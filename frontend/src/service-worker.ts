/// <reference types="@sveltejs/kit" />
/// <reference no-default-lib="true"/>
/// <reference lib="esnext" />
/// <reference lib="webworker" />

import { build, files, version } from '$service-worker';

const sw = self as unknown as ServiceWorkerGlobalScope;
const CACHE_NAME = `sovereign-cache-${version}`;

// Files to cache immediately on install
const STATIC_CACHE = [...build, ...files];

// Install event - cache static assets
sw.addEventListener('install', (event) => {
	event.waitUntil(
		caches.open(CACHE_NAME).then((cache) => {
			console.log('[SW] Caching static assets');
			return cache.addAll(STATIC_CACHE);
		}).then(() => {
			console.log('[SW] Skip waiting');
			return sw.skipWaiting();
		})
	);
});

// Activate event - clean up old caches
sw.addEventListener('activate', (event) => {
	event.waitUntil(
		caches.keys().then((cacheNames) => {
			return Promise.all(
				cacheNames
					.filter((name) => name !== CACHE_NAME)
					.map((name) => {
						console.log('[SW] Deleting old cache:', name);
						return caches.delete(name);
					})
			);
		}).then(() => {
			console.log('[SW] Claiming clients');
			return sw.clients.claim();
		})
	);
});

// Fetch event - serve from cache, fallback to network
sw.addEventListener('fetch', (event) => {
	const { request } = event;
	const url = new URL(request.url);

	// Skip cross-origin requests
	if (url.origin !== location.origin) {
		return;
	}

	// API requests: Network first, fallback to cache
	if (url.pathname.startsWith('/api/')) {
		event.respondWith(
			fetch(request)
				.then((response) => {
					// Clone response for cache
					const responseClone = response.clone();
					
					caches.open(CACHE_NAME).then((cache) => {
						cache.put(request, responseClone);
					});
					
					return response;
				})
				.catch(() => {
					// Network failed, try cache
					return caches.match(request).then((cached) => {
						if (cached) {
							console.log('[SW] Serving API from cache:', request.url);
							return cached;
						}
						
						// Return offline response
						return new Response(
							JSON.stringify({ 
								error: 'Offline', 
								message: 'No cached data available' 
							}),
							{
								status: 503,
								headers: { 'Content-Type': 'application/json' }
							}
						);
					});
				})
		);
		return;
	}

	// Static assets: Cache first
	event.respondWith(
		caches.match(request).then((cached) => {
			if (cached) {
				console.log('[SW] Serving from cache:', request.url);
				return cached;
			}

			return fetch(request)
				.then((response) => {
					// Don't cache non-successful responses
					if (!response || response.status !== 200 || response.type === 'error') {
						return response;
					}

					const responseClone = response.clone();
					
					caches.open(CACHE_NAME).then((cache) => {
						cache.put(request, responseClone);
					});

					return response;
				})
				.catch(() => {
					// Return offline page for navigation requests
					if (request.mode === 'navigate') {
						return caches.match('/offline');
					}
					
					return new Response('Offline', { status: 503 });
				});
		})
	);
});

// Background sync for queued operations
sw.addEventListener('sync', (event) => {
	if (event.tag === 'sync-operations') {
		event.waitUntil(syncQueuedOperations());
	}
});

async function syncQueuedOperations() {
	console.log('[SW] Syncing queued operations');
	
	// Open IndexedDB and get queued operations
	const db = await openDB();
	const operations = await db.getAll('queue');
	
	for (const op of operations) {
		try {
			await fetch(op.url, {
				method: op.method,
				headers: op.headers,
				body: op.body
			});
			
			// Remove from queue on success
			await db.delete('queue', op.id);
			console.log('[SW] Synced operation:', op.id);
		} catch (error) {
			console.error('[SW] Failed to sync operation:', op.id, error);
		}
	}
}

async function openDB(): Promise<any> {
	return new Promise((resolve, reject) => {
		const request = indexedDB.open('sovereign-db', 1);
		
		request.onerror = () => reject(request.error);
		request.onsuccess = () => resolve(request.result);
		
		request.onupgradeneeded = (event: any) => {
			const db = event.target.result;
			
			if (!db.objectStoreNames.contains('queue')) {
				db.createObjectStore('queue', { keyPath: 'id', autoIncrement: true });
			}
		};
	});
}

// Message handler for client communication
sw.addEventListener('message', (event) => {
	if (event.data && event.data.type === 'SKIP_WAITING') {
		sw.skipWaiting();
	}
	
	if (event.data && event.data.type === 'CACHE_URLS') {
		event.waitUntil(
			caches.open(CACHE_NAME).then((cache) => {
				return cache.addAll(event.data.urls);
			})
		);
	}
});

console.log('[SW] Service Worker loaded, version:', version);
