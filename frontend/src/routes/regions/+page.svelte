<script lang="ts">
  import { RegionDashboard } from '$lib/components';
  import { page } from '$app/stores';
</script>

<svelte:head>
  <title>Global Regions - Global Sovereign Network</title>
  <meta name="description" content="Real-time status of our 6 global infrastructure regions" />
</svelte:head>

<div class="min-h-screen bg-gray-50 dark:bg-gray-900">
  <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
    <!-- Header -->
    <div class="mb-8">
      <h1 class="text-4xl font-bold text-gray-900 dark:text-white mb-2">
        Global Infrastructure
      </h1>
      <p class="text-lg text-gray-600 dark:text-gray-300">
        Our multi-region infrastructure spans 6 strategic locations worldwide, ensuring low latency and high availability for all participants.
      </p>
    </div>

    <!-- Stats Overview -->
    <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
      <div class="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
        <div class="text-sm text-gray-500 dark:text-gray-400 mb-1">Total Regions</div>
        <div class="text-3xl font-bold text-gray-900 dark:text-white">6</div>
        <div class="text-xs text-green-600 dark:text-green-400 mt-1">All operational ✓</div>
      </div>
      
      <div class="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
        <div class="text-sm text-gray-500 dark:text-gray-400 mb-1">Average Uptime</div>
        <div class="text-3xl font-bold text-gray-900 dark:text-white">99.95%</div>
        <div class="text-xs text-gray-500 dark:text-gray-400 mt-1">Last 30 days</div>
      </div>
      
      <div class="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
        <div class="text-sm text-gray-500 dark:text-gray-400 mb-1">Global Coverage</div>
        <div class="text-3xl font-bold text-gray-900 dark:text-white">100%</div>
        <div class="text-xs text-gray-500 dark:text-gray-400 mt-1">6 continents</div>
      </div>
    </div>

    <!-- Region Dashboard Component -->
    <RegionDashboard />

    <!-- Region Details -->
    <div class="mt-12 bg-white dark:bg-gray-800 rounded-lg shadow-lg p-8">
      <h2 class="text-2xl font-bold text-gray-900 dark:text-white mb-6">
        Infrastructure Details
      </h2>
      
      <div class="space-y-6">
        <div>
          <h3 class="text-lg font-semibold text-gray-900 dark:text-white mb-2">
            Multi-Region Architecture
          </h3>
          <p class="text-gray-600 dark:text-gray-300">
            Our infrastructure is distributed across strategic locations to ensure optimal performance 
            and resilience. Each region operates independently while maintaining real-time synchronization 
            with the global network.
          </p>
        </div>

        <div>
          <h3 class="text-lg font-semibold text-gray-900 dark:text-white mb-2">
            Features
          </h3>
          <ul class="list-disc list-inside text-gray-600 dark:text-gray-300 space-y-2">
            <li>Real-time health monitoring and alerting</li>
            <li>Automatic failover and load balancing</li>
            <li>Edge caching for improved latency</li>
            <li>Distributed data replication</li>
            <li>Geographic routing optimization</li>
            <li>24/7 monitoring and support</li>
          </ul>
        </div>

        <div>
          <h3 class="text-lg font-semibold text-gray-900 dark:text-white mb-2">
            Region Coverage
          </h3>
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div class="flex items-start">
              <span class="font-mono text-sm bg-gray-100 dark:bg-gray-700 px-2 py-1 rounded mr-3">AMS</span>
              <div>
                <div class="font-medium text-gray-900 dark:text-white">Amsterdam, Netherlands</div>
                <div class="text-sm text-gray-500 dark:text-gray-400">Europe</div>
              </div>
            </div>
            
            <div class="flex items-start">
              <span class="font-mono text-sm bg-gray-100 dark:bg-gray-700 px-2 py-1 rounded mr-3">IAD</span>
              <div>
                <div class="font-medium text-gray-900 dark:text-white">Virginia, USA</div>
                <div class="text-sm text-gray-500 dark:text-gray-400">North America</div>
              </div>
            </div>
            
            <div class="flex items-start">
              <span class="font-mono text-sm bg-gray-100 dark:bg-gray-700 px-2 py-1 rounded mr-3">SYD</span>
              <div>
                <div class="font-medium text-gray-900 dark:text-white">Sydney, Australia</div>
                <div class="text-sm text-gray-500 dark:text-gray-400">Oceania</div>
              </div>
            </div>
            
            <div class="flex items-start">
              <span class="font-mono text-sm bg-gray-100 dark:bg-gray-700 px-2 py-1 rounded mr-3">SIN</span>
              <div>
                <div class="font-medium text-gray-900 dark:text-white">Singapore</div>
                <div class="text-sm text-gray-500 dark:text-gray-400">Asia</div>
              </div>
            </div>
            
            <div class="flex items-start">
              <span class="font-mono text-sm bg-gray-100 dark:bg-gray-700 px-2 py-1 rounded mr-3">SFO</span>
              <div>
                <div class="font-medium text-gray-900 dark:text-white">San Francisco, USA</div>
                <div class="text-sm text-gray-500 dark:text-gray-400">North America West</div>
              </div>
            </div>
            
            <div class="flex items-start">
              <span class="font-mono text-sm bg-gray-100 dark:bg-gray-700 px-2 py-1 rounded mr-3">JNB</span>
              <div>
                <div class="font-medium text-gray-900 dark:text-white">Johannesburg, South Africa</div>
                <div class="text-sm text-gray-500 dark:text-gray-400">Africa</div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</div>

<style>
  :global(body) {
    @apply bg-gray-50 dark:bg-gray-900;
  }
</style>
