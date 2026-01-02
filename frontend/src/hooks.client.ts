/**
 * Client-side hooks for Global Sovereign Charter
 * 
 * - Service worker registration
 * - Authentication token handling
 */

export async function handleError({ error, event }: { error: any; event: any }) {
  console.error('Client error:', error);
  
  if (error.message === 'Unauthorized') {
    localStorage.removeItem('auth_token');
    window.location.href = '/login';
  }
}

// Service worker registration
if (typeof window !== 'undefined' && 'serviceWorker' in navigator) {
  navigator.serviceWorker.register('/service-worker.js').then(
    (registration) => {
      console.log('Service Worker registered:', registration.scope);
    },
    (error) => {
      console.error('Service Worker registration failed:', error);
    }
  );
}
