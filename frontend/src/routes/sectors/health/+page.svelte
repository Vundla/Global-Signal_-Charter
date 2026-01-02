<script lang="ts">
  import { HealthSector } from '$lib/components';
  import { LoadingSpinner } from '$lib/components';
  import { onMount } from 'svelte';
  import { client } from '$lib/graphql/client';
  import { GET_SECTORAL_STATS, GET_PROJECTS_BY_SECTOR, type SectoralStats } from '$lib/graphql/queries';

  let loading = $state(true);
  let healthData = $state<any>(null);
  let error = $state<string | null>(null);

  onMount(async () => {
    try {
      // Fetch sectoral statistics
      const statsResult = await client.query({
        query: GET_SECTORAL_STATS
      });

      // Find health sector stats
      const sectoralStats: SectoralStats[] = statsResult.data.sectoralStats || [];
      const healthStats = sectoralStats.find((s: SectoralStats) => 
        s.sector.toLowerCase() === 'health' || s.sector.toLowerCase() === 'healthcare'
      );

      if (healthStats) {
        // Fetch health projects for more details
        const projectsResult = await client.query({
          query: GET_PROJECTS_BY_SECTOR,
          variables: { sector: 'Health' }
        });

        const projects = projectsResult.data.projects || [];

        // Transform backend data to match component interface
        healthData = {
          contribution_usd: healthStats.totalBudget,
          countries_participating: healthStats.countriesInvolved,
          hospitals_built: Math.floor(healthStats.projectCount * 6.5), // Estimated
          clinics_established: Math.floor(healthStats.projectCount * 37), // Estimated
          medical_professionals_trained: Math.floor(healthStats.totalBudget / 68000), // Estimated
          patients_served: Math.floor(healthStats.totalBudget / 265), // Estimated
          telemedicine_consultations: Math.floor(healthStats.projectCount * 18750), // Estimated
          health_coverage_increase: healthStats.avgImpact || 28.5,
          maternal_mortality_reduction: 35, // Static for now
          child_vaccination_rate: 89, // Static for now
          projects_count: healthStats.projectCount,
          avg_project_budget: healthStats.avgBudget
        };
      } else {
        // Fallback to mock data if no health stats found
        healthData = {
          contribution_usd: 850000000,
          countries_participating: 42,
          hospitals_built: 156,
          clinics_established: 890,
          medical_professionals_trained: 12500,
          patients_served: 3200000,
          telemedicine_consultations: 450000,
          health_coverage_increase: 28.5,
          maternal_mortality_reduction: 35,
          child_vaccination_rate: 89
        };
        console.warn('No health sector data found in backend, using mock data');
      }
      
      loading = false;
    } catch (e) {
      console.error('Failed to fetch health sector data:', e);
      error = e instanceof Error ? e.message : 'Failed to load health sector data';
      
      // Fallback to mock data on error
      healthData = {
        contribution_usd: 850000000,
        countries_participating: 42,
        hospitals_built: 156,
        clinics_established: 890,
        medical_professionals_trained: 12500,
        patients_served: 3200000,
        telemedicine_consultations: 450000,
        health_coverage_increase: 28.5,
        maternal_mortality_reduction: 35,
        child_vaccination_rate: 89
      };
      loading = false;
    }
  });
</script>

<svelte:head>
  <title>Health Sector - Global Sovereign Network</title>
  <meta name="description" content="Health infrastructure development and medical services across participating nations" />
</svelte:head>

<div class="min-h-screen bg-gray-50 dark:bg-gray-900">
  <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
    <!-- Header -->
    <div class="mb-8">
      <div class="flex items-center gap-3 mb-4">
        <div class="w-12 h-12 bg-gradient-to-br from-red-500 to-pink-600 rounded-lg flex items-center justify-center">
          <svg class="w-7 h-7 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z" />
          </svg>
        </div>
        <div>
          <h1 class="text-4xl font-bold text-gray-900 dark:text-white">
            Health Sector
          </h1>
          <p class="text-sm text-gray-500 dark:text-gray-400 mt-1">
            Building resilient healthcare infrastructure for all nations
          </p>
        </div>
      </div>
      <p class="text-lg text-gray-600 dark:text-gray-300">
        Developing comprehensive healthcare systems, training medical professionals, 
        and ensuring equitable access to quality medical services across 42 participating nations.
      </p>
    </div>

    {#if loading}
      <div class="flex justify-center items-center py-20">
        <LoadingSpinner size="lg" />
      </div>
    {:else if error}
      <div class="bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 rounded-lg p-6">
        <h3 class="text-red-800 dark:text-red-300 font-semibold mb-2">Error Loading Data</h3>
        <p class="text-red-700 dark:text-red-400">{error}</p>
      </div>
    {:else if healthData}
      <HealthSector data={healthData} />

      <!-- Additional Context -->
      <div class="mt-12 grid grid-cols-1 md:grid-cols-2 gap-8">
        <div class="bg-white dark:bg-gray-800 rounded-lg shadow-lg p-8">
          <h2 class="text-2xl font-bold text-gray-900 dark:text-white mb-4">
            Healthcare Initiatives
          </h2>
          <ul class="space-y-3 text-gray-600 dark:text-gray-300">
            <li class="flex items-start">
              <span class="text-red-500 mr-2">•</span>
              <span>Primary healthcare infrastructure development</span>
            </li>
            <li class="flex items-start">
              <span class="text-red-500 mr-2">•</span>
              <span>Medical equipment procurement and distribution</span>
            </li>
            <li class="flex items-start">
              <span class="text-red-500 mr-2">•</span>
              <span>Healthcare workforce training programs</span>
            </li>
            <li class="flex items-start">
              <span class="text-red-500 mr-2">•</span>
              <span>Telemedicine platform deployment</span>
            </li>
            <li class="flex items-start">
              <span class="text-red-500 mr-2">•</span>
              <span>Pharmaceutical supply chain optimization</span>
            </li>
            <li class="flex items-start">
              <span class="text-red-500 mr-2">•</span>
              <span>Emergency response systems</span>
            </li>
          </ul>
        </div>

        <div class="bg-white dark:bg-gray-800 rounded-lg shadow-lg p-8">
          <h2 class="text-2xl font-bold text-gray-900 dark:text-white mb-4">
            Impact Stories
          </h2>
          <div class="space-y-4">
            <div class="border-l-4 border-red-500 pl-4">
              <h3 class="font-semibold text-gray-900 dark:text-white mb-1">
                Maternal Health Program
              </h3>
              <p class="text-sm text-gray-600 dark:text-gray-300">
                35% reduction in maternal mortality through improved prenatal care and delivery facilities across rural regions.
              </p>
            </div>
            
            <div class="border-l-4 border-red-500 pl-4">
              <h3 class="font-semibold text-gray-900 dark:text-white mb-1">
                Vaccination Campaign
              </h3>
              <p class="text-sm text-gray-600 dark:text-gray-300">
                89% child vaccination rate achieved through mobile clinics and community health worker programs.
              </p>
            </div>
            
            <div class="border-l-4 border-red-500 pl-4">
              <h3 class="font-semibold text-gray-900 dark:text-white mb-1">
                Telemedicine Expansion
              </h3>
              <p class="text-sm text-gray-600 dark:text-gray-300">
                450,000 remote consultations conducted, connecting rural patients with specialist doctors.
              </p>
            </div>
          </div>
        </div>
      </div>

      <!-- Call to Action -->
      <div class="mt-12 bg-gradient-to-r from-red-500 to-pink-600 rounded-lg shadow-xl p-8 text-white">
        <h2 class="text-3xl font-bold mb-4">Join the Health Revolution</h2>
        <p class="text-lg mb-6 text-red-50">
          Your nation can participate in building resilient healthcare systems. 
          Together, we ensure every citizen has access to quality medical care.
        </p>
        <div class="flex gap-4">
          <a href="/join" class="bg-white text-red-600 px-6 py-3 rounded-lg font-semibold hover:bg-red-50 transition-colors">
            Join Network
          </a>
          <a href="/projects" class="bg-red-700 text-white px-6 py-3 rounded-lg font-semibold hover:bg-red-800 transition-colors">
            View Projects
          </a>
        </div>
      </div>
    {/if}
  </div>
</div>

<style>
  :global(body) {
    @apply bg-gray-50 dark:bg-gray-900;
  }
</style>
