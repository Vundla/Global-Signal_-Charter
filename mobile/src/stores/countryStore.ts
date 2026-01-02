/**
 * Countries Store
 * Manages countries data state
 */

import { create } from 'zustand';

export interface Country {
  code: string;
  name: string;
  gdp_usd_billions: number;
  continent: string;
  region: string;
  contribution_usd_millions: number;
}

export interface CountryState {
  countries: Country[];
  selectedCountry: Country | null;
  isLoading: boolean;
  error: string | null;
  filter: {
    region?: string;
    continent?: string;
    search?: string;
  };
  
  // Actions
  setCountries: (countries: Country[]) => void;
  setSelectedCountry: (country: Country | null) => void;
  setLoading: (loading: boolean) => void;
  setError: (error: string | null) => void;
  setFilter: (filter: CountryState['filter']) => void;
  clearFilter: () => void;
}

export const useCountryStore = create<CountryState>((set) => ({
  countries: [],
  selectedCountry: null,
  isLoading: false,
  error: null,
  filter: {},
  
  setCountries: (countries) => set({ countries }),
  setSelectedCountry: (country) => set({ selectedCountry: country }),
  setLoading: (isLoading) => set({ isLoading }),
  setError: (error) => set({ error }),
  
  setFilter: (filter) => set((state) => ({
    filter: { ...state.filter, ...filter },
  })),
  
  clearFilter: () => set({ filter: {} }),
}));
