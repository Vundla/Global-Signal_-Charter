/**
 * Projects Store
 * Manages projects data state
 */

import { create } from 'zustand';

export interface Project {
  id: string;
  name: string;
  description: string;
  region: string;
  country_code: string;
  sector: string;
  status: 'Active' | 'Pending' | 'Completed';
  funding_usd_millions: number;
  progress: number;
}

export interface ProjectState {
  projects: Project[];
  selectedProject: Project | null;
  isLoading: boolean;
  error: string | null;
  filter: {
    region?: string;
    sector?: string;
    status?: string;
    search?: string;
  };
  
  // Actions
  setProjects: (projects: Project[]) => void;
  setSelectedProject: (project: Project | null) => void;
  setLoading: (loading: boolean) => void;
  setError: (error: string | null) => void;
  setFilter: (filter: ProjectState['filter']) => void;
  clearFilter: () => void;
}

export const useProjectStore = create<ProjectState>((set) => ({
  projects: [],
  selectedProject: null,
  isLoading: false,
  error: null,
  filter: {},
  
  setProjects: (projects) => set({ projects }),
  setSelectedProject: (project) => set({ selectedProject: project }),
  setLoading: (isLoading) => set({ isLoading }),
  setError: (error) => set({ error }),
  
  setFilter: (filter) => set((state) => ({
    filter: { ...state.filter, ...filter },
  })),
  
  clearFilter: () => set({ filter: {} }),
}));
