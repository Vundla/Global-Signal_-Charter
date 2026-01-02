/**
 * Sync Store
 * Manages offline sync state, queue, and sync status
 */

import { create } from 'zustand';

export interface SyncOperation {
  id: string;
  operation: 'create' | 'update' | 'delete';
  entity: 'countries' | 'projects' | 'users';
  payload: any;
  timestamp: Date;
  retries: number;
}

export interface SyncState {
  isOnline: boolean;
  isSyncing: boolean;
  queue: SyncOperation[];
  lastSyncTime: Date | null;
  syncError: string | null;
  syncProgress: number; // 0-100
  
  // Actions
  setOnlineStatus: (isOnline: boolean) => void;
  setSyncing: (isSyncing: boolean) => void;
  addToQueue: (operation: SyncOperation) => void;
  removeFromQueue: (id: string) => void;
  clearQueue: () => void;
  setLastSyncTime: (time: Date) => void;
  setSyncError: (error: string | null) => void;
  setSyncProgress: (progress: number) => void;
}

export const useSyncStore = create<SyncState>((set) => ({
  isOnline: true,
  isSyncing: false,
  queue: [],
  lastSyncTime: null,
  syncError: null,
  syncProgress: 0,
  
  setOnlineStatus: (isOnline) => set({ isOnline }),
  setSyncing: (isSyncing) => set({ isSyncing }),
  
  addToQueue: (operation) => set((state) => ({
    queue: [...state.queue, operation],
  })),
  
  removeFromQueue: (id) => set((state) => ({
    queue: state.queue.filter((op) => op.id !== id),
  })),
  
  clearQueue: () => set({ queue: [] }),
  setLastSyncTime: (time) => set({ lastSyncTime: time }),
  setSyncError: (error) => set({ syncError: error }),
  setSyncProgress: (progress) => set({ syncProgress: progress }),
}));
