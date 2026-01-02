<script lang="ts">
  import { EducationSector } from '$lib/components';
  import { LoadingSpinner } from '$lib/components';
  import { onMount } from 'svelte';
  import { client } from '$lib/graphql/client';
  import { GET_SECTORAL_STATS, GET_PROJECTS_BY_SECTOR, type SectoralStats } from '$lib/graphql/queries';

  let loading = $state(true);
  let educationData = $state<any>(null);
  let error = $state<string | null>(null);

  onMount(async () => {
    try {
      // Fetch sectoral statistics
      const statsResult = await client.query({
        query: GET_SECTORAL_STATS
      });

      // Find education sector stats
      const sectoralStats: SectoralStats[] = statsResult.data.sectoralStats || [];
      const educationStats = sectoralStats.find((s: SectoralStats) => 
        s.sector.toLowerCase() === 'education'
      );

      if (educationStats) {
        // Fetch education projects for more details
        const projectsResult = await client.query({
          query: GET_PROJECTS_BY_SECTOR,
          variables: { sector: 'Education' }
        });

        const projects = projectsResult.data.projects || [];

        // Transform backend data to match component interface
        educationData = {
          contribution_usd: educationStats.totalBudget,
          countries_participating: educationStats.countriesInvolved,
          schools_built: Math.floor(educationStats.projectCount * 52), // Estimated
          universities_established: Math.floor(educationStats.projectCount * 1.9), // Estimated
          teachers_trained: Math.floor(educationStats.totalBudget / 22150), // Estimated
          students_enrolled: Math.floor(educationStats.totalBudget / 138), // Estimated
          digital_learning_platforms: Math.floor(educationStats.projectCount * 3.5), // Estimated
          literacy_rate_increase: educationStats.avgImpact || 22.8,
          stem_graduates: Math.floor(educationStats.projectCount * 5210), // Estimated
          scholarship_recipients: Math.floor(educationStats.projectCount * 1875), // Estimated
          projects_count: educationStats.projectCount,
          avg_project_budget: educationStats.avgBudget
        };
      } else {
        // Fallback to mock data if no education stats found
        educationData = {
          contribution_usd: 620000000,
          countries_participating: 38,
          schools_built: 1250,
          universities_established: 45,
          teachers_trained: 28000,
          students_enrolled: 4500000,
          digital_learning_platforms: 85,
          literacy_rate_increase: 22.8,
          stem_graduates: 125000,
          scholarship_recipients: 45000
        };
        console.warn('No education sector data found in backend, using mock data');
      }
      
      loading = false;
    } catch (e) {
      console.error('Failed to fetch education sector data:', e);
      error = e instanceof Error ? e.message : 'Failed to load education sector data';
      
      // Fallback to mock data on error
      educationData = {
        contribution_usd: 620000000,
        countries_participating: 38,
        schools_built: 1250,
        universities_established: 45,
        teachers_trained: 28000,
        students_enrolled: 4500000,
        digital_learning_platforms: 85,
        literacy_rate_increase: 22.8,
        stem_graduates: 125000,
        scholarship_recipients: 45000
      };
      loading = false;
    }
  });
</script>

<svelte:head>
  <title>Education Sector - Global Sovereign Network</title>
  <meta name="description" content="Building world-class education systems and empowering learners across participating nations" />
</svelte:head>

<div class="min-h-screen bg-gray-50 dark:bg-gray-900">
  <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
    <!-- Header -->
    <div class="mb-8">
      <div class="flex items-center gap-3 mb-4">
        <div class="w-12 h-12 bg-gradient-to-br from-blue-500 to-indigo-600 rounded-lg flex items-center justify-center">
          <svg class="w-7 h-7 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253" />
          </svg>
        </div>
        <div>
          <h1 class="text-4xl font-bold text-gray-900 dark:text-white">
            Education Sector
          </h1>
          <p class="text-sm text-gray-500 dark:text-gray-400 mt-1">
            Empowering minds, building futures through quality education
          </p>
        </div>
      </div>
      <p class="text-lg text-gray-600 dark:text-gray-300">
        Creating inclusive education systems, training educators, and providing digital learning 
        platforms to ensure every child has access to quality education across 38 participating nations.
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
    {:else if educationData}
      <EducationSector data={educationData} />

      <!-- Additional Context -->
      <div class="mt-12 grid grid-cols-1 md:grid-cols-2 gap-8">
        <div class="bg-white dark:bg-gray-800 rounded-lg shadow-lg p-8">
          <h2 class="text-2xl font-bold text-gray-900 dark:text-white mb-4">
            Education Initiatives
          </h2>
          <ul class="space-y-3 text-gray-600 dark:text-gray-300">
            <li class="flex items-start">
              <span class="text-blue-500 mr-2">•</span>
              <span>Primary and secondary school infrastructure</span>
            </li>
            <li class="flex items-start">
              <span class="text-blue-500 mr-2">•</span>
              <span>Teacher training and certification programs</span>
            </li>
            <li class="flex items-start">
              <span class="text-blue-500 mr-2">•</span>
              <span>Digital learning platform deployment</span>
            </li>
            <li class="flex items-start">
              <span class="text-blue-500 mr-2">•</span>
              <span>STEM education enhancement programs</span>
            </li>
            <li class="flex items-start">
              <span class="text-blue-500 mr-2">•</span>
              <span>Scholarship and financial aid systems</span>
            </li>
            <li class="flex items-start">
              <span class="text-blue-500 mr-2">•</span>
              <span>Vocational training centers</span>
            </li>
          </ul>
        </div>

        <div class="bg-white dark:bg-gray-800 rounded-lg shadow-lg p-8">
          <h2 class="text-2xl font-bold text-gray-900 dark:text-white mb-4">
            Success Stories
          </h2>
          <div class="space-y-4">
            <div class="border-l-4 border-blue-500 pl-4">
              <h3 class="font-semibold text-gray-900 dark:text-white mb-1">
                Digital Classroom Initiative
              </h3>
              <p class="text-sm text-gray-600 dark:text-gray-300">
                85 digital learning platforms deployed, reaching 4.5 million students with interactive, accessible content.
              </p>
            </div>
            
            <div class="border-l-4 border-blue-500 pl-4">
              <h3 class="font-semibold text-gray-900 dark:text-white mb-1">
                Literacy Campaign
              </h3>
              <p class="text-sm text-gray-600 dark:text-gray-300">
                22.8% increase in literacy rates through community learning centers and adult education programs.
              </p>
            </div>
            
            <div class="border-l-4 border-blue-500 pl-4">
              <h3 class="font-semibold text-gray-900 dark:text-white mb-1">
                STEM Excellence
              </h3>
              <p class="text-sm text-gray-600 dark:text-gray-300">
                125,000 STEM graduates from enhanced science and technology programs, driving innovation across nations.
              </p>
            </div>
          </div>
        </div>
      </div>

      <!-- Program Highlights -->
      <div class="mt-12 bg-white dark:bg-gray-800 rounded-lg shadow-lg p-8">
        <h2 class="text-2xl font-bold text-gray-900 dark:text-white mb-6">
          Featured Programs
        </h2>
        <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
          <div class="text-center">
            <div class="w-16 h-16 bg-blue-100 dark:bg-blue-900 rounded-full flex items-center justify-center mx-auto mb-3">
              <svg class="w-8 h-8 text-blue-600 dark:text-blue-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9.75 17L9 20l-1 1h8l-1-1-.75-3M3 13h18M5 17h14a2 2 0 002-2V5a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" />
              </svg>
            </div>
            <h3 class="font-semibold text-gray-900 dark:text-white mb-2">
              Digital Learning
            </h3>
            <p class="text-sm text-gray-600 dark:text-gray-300">
              Cloud-based platforms with interactive content and AI-powered tutoring
            </p>
          </div>

          <div class="text-center">
            <div class="w-16 h-16 bg-green-100 dark:bg-green-900 rounded-full flex items-center justify-center mx-auto mb-3">
              <svg class="w-8 h-8 text-green-600 dark:text-green-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" />
              </svg>
            </div>
            <h3 class="font-semibold text-gray-900 dark:text-white mb-2">
              Scholarships
            </h3>
            <p class="text-sm text-gray-600 dark:text-gray-300">
              45,000 students supported through merit and need-based scholarships
            </p>
          </div>

          <div class="text-center">
            <div class="w-16 h-16 bg-purple-100 dark:bg-purple-900 rounded-full flex items-center justify-center mx-auto mb-3">
              <svg class="w-8 h-8 text-purple-600 dark:text-purple-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19.428 15.428a2 2 0 00-1.022-.547l-2.387-.477a6 6 0 00-3.86.517l-.318.158a6 6 0 01-3.86.517L6.05 15.21a2 2 0 00-1.806.547M8 4h8l-1 1v5.172a2 2 0 00.586 1.414l5 5c1.26 1.26.367 3.414-1.415 3.414H4.828c-1.782 0-2.674-2.154-1.414-3.414l5-5A2 2 0 009 10.172V5L8 4z" />
              </svg>
            </div>
            <h3 class="font-semibold text-gray-900 dark:text-white mb-2">
              Teacher Training
            </h3>
            <p class="text-sm text-gray-600 dark:text-gray-300">
              28,000 educators trained in modern pedagogical methods and technology
            </p>
          </div>
        </div>
      </div>

      <!-- Call to Action -->
      <div class="mt-12 bg-gradient-to-r from-blue-500 to-indigo-600 rounded-lg shadow-xl p-8 text-white">
        <h2 class="text-3xl font-bold mb-4">Transform Education in Your Nation</h2>
        <p class="text-lg mb-6 text-blue-50">
          Join our global network to build world-class education systems. 
          Every child deserves access to quality learning opportunities.
        </p>
        <div class="flex gap-4">
          <a href="/join" class="bg-white text-blue-600 px-6 py-3 rounded-lg font-semibold hover:bg-blue-50 transition-colors">
            Join Network
          </a>
          <a href="/projects" class="bg-blue-700 text-white px-6 py-3 rounded-lg font-semibold hover:bg-blue-800 transition-colors">
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
