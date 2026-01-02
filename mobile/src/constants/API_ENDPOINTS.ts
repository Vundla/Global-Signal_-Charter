/**
 * API Constants
 * Configuration for backend API endpoints
 */

export const API_ENDPOINTS = {
  // GraphQL endpoint (multi-region)
  GRAPHQL: 'https://api.global-sovereign.org/graphql',
  
  // Region-specific endpoints
  REGIONS: {
    AMS: 'https://api-ams.global-sovereign.org',  // Europe
    IAD: 'https://api-iad.global-sovereign.org',  // US East
    SYD: 'https://api-syd.global-sovereign.org',  // Australia
    SIN: 'https://api-sin.global-sovereign.org',  // Singapore
    SFO: 'https://api-sfo.global-sovereign.org',  // US West
    JNB: 'https://api-jnb.global-sovereign.org',  // South Africa
  },
  
  // Health checks
  HEALTH: {
    AMS: 'https://api-ams.global-sovereign.org/health',
    IAD: 'https://api-iad.global-sovereign.org/health',
    SYD: 'https://api-syd.global-sovereign.org/health',
    SIN: 'https://api-sin.global-sovereign.org/health',
    SFO: 'https://api-sfo.global-sovereign.org/health',
    JNB: 'https://api-jnb.global-sovereign.org/health',
  },
  
  // Auth endpoints
  AUTH: {
    LOGIN: '/auth/login',
    LOGOUT: '/auth/logout',
    REFRESH: '/auth/refresh',
    BIOMETRIC: '/auth/biometric',
  },
};

// API request timeouts (in milliseconds)
export const API_TIMEOUTS = {
  DEFAULT: 30000,      // 30 seconds
  LONG_RUNNING: 60000, // 60 seconds
  SHORT: 5000,         // 5 seconds
};

// Retry configuration
export const RETRY_CONFIG = {
  MAX_RETRIES: 3,
  INITIAL_DELAY: 1000,      // 1 second
  MAX_DELAY: 32000,          // 32 seconds
  BACKOFF_MULTIPLIER: 2,
};

// Pagination defaults
export const PAGINATION = {
  DEFAULT_LIMIT: 20,
  MAX_LIMIT: 100,
  DEFAULT_OFFSET: 0,
};

// Cache configuration
export const CACHE_CONFIG = {
  COUNTRIES: 3600000,   // 1 hour
  PROJECTS: 1800000,    // 30 minutes
  REGIONS: 3600000,     // 1 hour
  USER: 600000,         // 10 minutes
};
