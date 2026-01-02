import { ApolloClient, InMemoryCache, HttpLink, ApolloLink, Observable } from '@apollo/client';
import { setContext } from '@apollo/client/link/context';
import type { ApolloClientOptions } from '@apollo/client';

/**
 * Apollo Client configuration for Global Sovereign GraphQL API
 * 
 * Features:
 * - Bearer token authentication from localStorage
 * - Automatic retry on network errors
 * - Error handling for 401/403 responses
 */

const httpLink = new HttpLink({
  uri: import.meta.env.VITE_GRAPHQL_ENDPOINT || 'http://localhost:4000/api/graphql',
  credentials: 'include' // Send cookies if needed
});

// Auth link to attach JWT token from localStorage
const authLink = setContext((_, { headers }) => {
  let token: string | null = null;
  
  // Get token from localStorage (browser) or SSR context
  if (typeof window !== 'undefined') {
    token = localStorage.getItem('auth_token');
  }

  return {
    headers: {
      ...headers,
      ...(token && { authorization: `Bearer ${token}` })
    }
  };
});

// Retry link for handling network failures
const retryLink = new ApolloLink((operation, forward) => {
  let retryCount = 0;
  const maxRetries = 3;

  return new Observable(observer => {
    const attemptRequest = () => {
      forward(operation).subscribe({
        next: (result) => {
          // Handle 401 - clear token and redirect to login
          if (result.errors?.some(err => err.message === 'Unauthorized')) {
            if (typeof window !== 'undefined') {
              localStorage.removeItem('auth_token');
              window.location.href = '/login';
            }
          }
          observer.next(result);
        },
        error: (networkError) => {
          if (retryCount < maxRetries && (networkError as any)?.statusCode !== 401) {
            retryCount++;
            attemptRequest();
          } else {
            observer.error(networkError);
          }
        },
        complete: () => observer.complete()
      });
    };
    attemptRequest();
  });
});

export const client = new ApolloClient({
  link: authLink.concat(retryLink).concat(httpLink),
  cache: new InMemoryCache(),
  defaultOptions: {
    watchQuery: {
      fetchPolicy: 'cache-and-network',
      errorPolicy: 'ignore'
    },
    query: {
      fetchPolicy: 'network-only',
      errorPolicy: 'all'
    }
  }
} as ApolloClientOptions<any>);

export default client;
