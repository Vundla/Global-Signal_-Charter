<script lang="ts">
  import { OfflineIndicator, SyncQueue, CacheManager } from '$lib/components';
  import { onMount } from 'svelte';

  let isOnline = $state(true);
  let syncStatus = $state<'idle' | 'syncing' | 'error'>('idle');
  let lastSyncTime = $state<Date | null>(null);

  onMount(() => {
    // Update online status
    isOnline = navigator.onLine;
    
    const updateOnlineStatus = () => {
      isOnline = navigator.onLine;
    };

    window.addEventListener('online', updateOnlineStatus);
    window.addEventListener('offline', updateOnlineStatus);

    // Load last sync time from localStorage
    const lastSync = localStorage.getItem('lastSyncTime');
    if (lastSync) {
      lastSyncTime = new Date(lastSync);
    }

    return () => {
      window.removeEventListener('online', updateOnlineStatus);
      window.removeEventListener('offline', updateOnlineStatus);
    };
  });

  function handleSyncComplete() {
    lastSyncTime = new Date();
    localStorage.setItem('lastSyncTime', lastSyncTime.toISOString());
    syncStatus = 'idle';
  }
</script>

<svelte:head>
  <title>Offline Management - Global Sovereign Network</title>
  <meta name="description" content="Manage offline data synchronization and caching" />
</svelte:head>

<div class="min-h-screen bg-gray-50 dark:bg-gray-900">
  <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
    <!-- Header -->
    <div class="mb-8">
      <div class="flex items-center justify-between mb-4">
        <div class="flex items-center gap-3">
          <div class="w-12 h-12 bg-gradient-to-br from-purple-500 to-indigo-600 rounded-lg flex items-center justify-center">
            <svg class="w-7 h-7 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7H5a2 2 0 00-2 2v9a2 2 0 002 2h14a2 2 0 002-2V9a2 2 0 00-2-2h-3m-1 4l-3 3m0 0l-3-3m3 3V4" />
            </svg>
          </div>
          <div>
            <h1 class="text-4xl font-bold text-gray-900 dark:text-white">
              Offline Management
            </h1>
            <p class="text-sm text-gray-500 dark:text-gray-400 mt-1">
              Work seamlessly even without internet connection
            </p>
          </div>
        </div>
        <OfflineIndicator />
      </div>
      <p class="text-lg text-gray-600 dark:text-gray-300">
        Our offline-first architecture ensures you can continue working even when internet connectivity is limited. 
        Changes are queued and automatically synchronized when you're back online.
      </p>
    </div>

    <!-- Connection Status Card -->
    <div class="mb-8 bg-white dark:bg-gray-800 rounded-lg shadow-lg p-6">
      <div class="flex items-center justify-between">
        <div>
          <h2 class="text-xl font-bold text-gray-900 dark:text-white mb-2">
            Connection Status
          </h2>
          <div class="flex items-center gap-2">
            <div class={`w-3 h-3 rounded-full ${isOnline ? 'bg-green-500 animate-pulse' : 'bg-red-500'}`}></div>
            <span class="text-gray-600 dark:text-gray-300">
              {isOnline ? 'Online' : 'Offline'} - 
              {#if lastSyncTime}
                Last synced {lastSyncTime.toLocaleString()}
              {:else}
                Never synced
              {/if}
            </span>
          </div>
        </div>
        
        {#if isOnline}
          <button 
            onclick={() => { syncStatus = 'syncing'; setTimeout(handleSyncComplete, 2000); }}
            disabled={syncStatus === 'syncing'}
            class="bg-purple-600 hover:bg-purple-700 disabled:bg-gray-400 text-white px-6 py-2 rounded-lg font-semibold transition-colors flex items-center gap-2"
          >
            {#if syncStatus === 'syncing'}
              <svg class="animate-spin h-5 w-5" fill="none" viewBox="0 0 24 24">
                <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
              </svg>
              Syncing...
            {:else}
              <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
              </svg>
              Sync Now
            {/if}
          </button>
        {/if}
      </div>
    </div>

    <!-- Sync Queue Component -->
    <div class="mb-8">
      <SyncQueue />
    </div>

    <!-- Cache Manager Component -->
    <div class="mb-8">
      <CacheManager />
    </div>

    <!-- Offline Features -->
    <div class="grid grid-cols-1 md:grid-cols-2 gap-8 mb-8">
      <div class="bg-white dark:bg-gray-800 rounded-lg shadow-lg p-6">
        <h2 class="text-xl font-bold text-gray-900 dark:text-white mb-4 flex items-center gap-2">
          <svg class="w-6 h-6 text-purple-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
          </svg>
          Offline Capabilities
        </h2>
        <ul class="space-y-3 text-gray-600 dark:text-gray-300">
          <li class="flex items-start">
            <span class="text-purple-500 mr-2">✓</span>
            <span>Read and browse all previously loaded content</span>
          </li>
          <li class="flex items-start">
            <span class="text-purple-500 mr-2">✓</span>
            <span>Create and edit data locally</span>
          </li>
          <li class="flex items-start">
            <span class="text-purple-500 mr-2">✓</span>
            <span>Queue changes for automatic sync</span>
          </li>
          <li class="flex items-start">
            <span class="text-purple-500 mr-2">✓</span>
            <span>Access cached API responses</span>
          </li>
          <li class="flex items-start">
            <span class="text-purple-500 mr-2">✓</span>
            <span>Background synchronization when online</span>
          </li>
        </ul>
      </div>

      <div class="bg-white dark:bg-gray-800 rounded-lg shadow-lg p-6">
        <h2 class="text-xl font-bold text-gray-900 dark:text-white mb-4 flex items-center gap-2">
          <svg class="w-6 h-6 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
          </svg>
          How It Works
        </h2>
        <ol class="space-y-3 text-gray-600 dark:text-gray-300">
          <li class="flex items-start">
            <span class="font-bold text-blue-600 mr-2">1.</span>
            <span>Data is automatically cached as you browse</span>
          </li>
          <li class="flex items-start">
            <span class="font-bold text-blue-600 mr-2">2.</span>
            <span>When offline, changes are stored locally</span>
          </li>
          <li class="flex items-start">
            <span class="font-bold text-blue-600 mr-2">3.</span>
            <span>App detects when you're back online</span>
          </li>
          <li class="flex items-start">
            <span class="font-bold text-blue-600 mr-2">4.</span>
            <span>Queued changes sync automatically</span>
          </li>
          <li class="flex items-start">
            <span class="font-bold text-blue-600 mr-2">5.</span>
            <span>Conflicts are resolved intelligently</span>
          </li>
        </ol>
      </div>
    </div>

    <!-- Best Practices -->
    <div class="bg-gradient-to-r from-purple-500 to-indigo-600 rounded-lg shadow-xl p-8 text-white">
      <h2 class="text-2xl font-bold mb-4">💡 Best Practices</h2>
      <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
        <div>
          <h3 class="font-semibold mb-2">When Working Offline:</h3>
          <ul class="space-y-2 text-sm text-purple-50">
            <li>• Make frequent saves to preserve your work</li>
            <li>• Check the sync queue before going offline</li>
            <li>• Avoid large file uploads without connection</li>
            <li>• Monitor storage usage regularly</li>
          </ul>
        </div>
        <div>
          <h3 class="font-semibold mb-2">When Back Online:</h3>
          <ul class="space-y-2 text-sm text-purple-50">
            <li>• Wait for sync to complete before making new changes</li>
            <li>• Review synced data for any conflicts</li>
            <li>• Clear old cache periodically</li>
            <li>• Check for app updates</li>
          </ul>
        </div>
      </div>
    </div>
  </div>
</div>

<style>
  :global(body) {
    @apply bg-gray-50 dark:bg-gray-900;
  }

  @keyframes pulse {
    0%, 100% {
      opacity: 1;
    }
    50% {
      opacity: 0.5;
    }
  }
</style>
