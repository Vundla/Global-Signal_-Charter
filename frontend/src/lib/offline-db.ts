import { openDB, type IDBPDatabase } from 'idb';

export interface QueuedOperation {
	id?: number;
	url: string;
	method: string;
	headers: Record<string, string>;
	body?: string;
	timestamp: number;
	retries: number;
}

export interface CachedContent {
	id: string;
	type: string;
	data: any;
	timestamp: number;
	expiresAt: number;
}

const DB_NAME = 'sovereign-db';
const DB_VERSION = 1;

class OfflineDatabase {
	private dbPromise: Promise<IDBPDatabase> | null = null;

	async getDB(): Promise<IDBPDatabase> {
		if (!this.dbPromise) {
			this.dbPromise = openDB(DB_NAME, DB_VERSION, {
				upgrade(db) {
					// Queue for failed operations
					if (!db.objectStoreNames.contains('queue')) {
						const queueStore = db.createObjectStore('queue', { 
							keyPath: 'id', 
							autoIncrement: true 
						});
						queueStore.createIndex('timestamp', 'timestamp');
					}

					// Cache for content
					if (!db.objectStoreNames.contains('content')) {
						const contentStore = db.createObjectStore('content', { keyPath: 'id' });
						contentStore.createIndex('type', 'type');
						contentStore.createIndex('expiresAt', 'expiresAt');
					}

					// Sync status
					if (!db.objectStoreNames.contains('syncStatus')) {
						db.createObjectStore('syncStatus', { keyPath: 'key' });
					}
				}
			});
		}
		return this.dbPromise;
	}

	// Queue operations
	async queueOperation(operation: Omit<QueuedOperation, 'id'>): Promise<number> {
		const db = await this.getDB();
		return db.add('queue', operation);
	}

	async getQueuedOperations(): Promise<QueuedOperation[]> {
		const db = await this.getDB();
		return db.getAll('queue');
	}

	async removeQueuedOperation(id: number): Promise<void> {
		const db = await this.getDB();
		await db.delete('queue', id);
	}

	async clearQueue(): Promise<void> {
		const db = await this.getDB();
		await db.clear('queue');
	}

	// Content caching
	async cacheContent(content: CachedContent): Promise<void> {
		const db = await this.getDB();
		await db.put('content', content);
	}

	async getCachedContent(id: string): Promise<CachedContent | undefined> {
		const db = await this.getDB();
		const content = await db.get('content', id);
		
		// Check expiration
		if (content && content.expiresAt < Date.now()) {
			await db.delete('content', id);
			return undefined;
		}
		
		return content;
	}

	async getCachedContentByType(type: string): Promise<CachedContent[]> {
		const db = await this.getDB();
		const index = db.transaction('content').store.index('type');
		const contents = await index.getAll(type);
		
		// Filter expired
		const now = Date.now();
		return contents.filter(c => c.expiresAt > now);
	}

	async removeCachedContent(id: string): Promise<void> {
		const db = await this.getDB();
		await db.delete('content', id);
	}

	async clearExpiredContent(): Promise<void> {
		const db = await this.getDB();
		const tx = db.transaction('content', 'readwrite');
		const index = tx.store.index('expiresAt');
		const now = Date.now();
		
		let cursor = await index.openCursor();
		
		while (cursor) {
			if (cursor.value.expiresAt < now) {
				await cursor.delete();
			}
			cursor = await cursor.continue();
		}
		
		await tx.done;
	}

	// Sync status
	async setSyncStatus(key: string, value: any): Promise<void> {
		const db = await this.getDB();
		await db.put('syncStatus', { key, value, timestamp: Date.now() });
	}

	async getSyncStatus(key: string): Promise<any> {
		const db = await this.getDB();
		const result = await db.get('syncStatus', key);
		return result?.value;
	}
}

export const offlineDB = new OfflineDatabase();

// Background sync helper
export async function registerBackgroundSync() {
	if ('serviceWorker' in navigator && 'sync' in ServiceWorkerRegistration.prototype) {
		try {
			const registration = await navigator.serviceWorker.ready;
			await registration.sync.register('sync-operations');
			console.log('[OfflineDB] Background sync registered');
		} catch (error) {
			console.error('[OfflineDB] Background sync failed:', error);
		}
	}
}

// Periodic cleanup
if (typeof window !== 'undefined') {
	setInterval(async () => {
		await offlineDB.clearExpiredContent();
	}, 60 * 60 * 1000); // Every hour
}
