/**
 * Type definitions for API and data models
 */

export interface GraphQLResponse<T = any> {
  data?: T;
  errors?: GraphQLError[];
}

export interface GraphQLError {
  message: string;
  extensions?: {
    code: string;
    [key: string]: any;
  };
}

export interface PaginatedResponse<T> {
  items: T[];
  total: number;
  limit: number;
  offset: number;
}

export interface SyncMutation {
  operation: 'create' | 'update' | 'delete';
  entity: string;
  payload: Record<string, any>;
}

export interface AuthResponse {
  accessToken: string;
  refreshToken: string;
  expiresIn: number;
  user: {
    id: string;
    email: string;
    name: string;
  };
}

export interface HealthCheckResponse {
  status: 'healthy' | 'degraded' | 'unhealthy';
  latency: number;
  timestamp: string;
  region: string;
}

export interface RegionInfo {
  code: string;
  name: string;
  latency: number;
  uptime: number;
  endpoint: string;
}

export interface CacheStats {
  itemCount: number;
  totalSize: number;
  lastSyncTime: string;
  hitRate: number;
}
