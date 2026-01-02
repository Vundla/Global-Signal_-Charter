import { gql } from '@apollo/client';

export const GET_COUNTRIES = gql`
  query GetCountries($limit: Int, $offset: Int) {
    countries(limit: $limit, offset: $offset) {
      id
      name
      code
      gdp
      gdpPerCapita
      population
      gdpGrowthRate
      region
      subregion
    }
  }
`;

export const GET_COUNTRY = gql`
  query GetCountry($id: ID!) {
    country(id: $id) {
      id
      name
      code
      gdp
      gdpPerCapita
      population
      gdpGrowthRate
      region
      subregion
      landArea
      capitalCity
    }
  }
`;

export const GET_PROJECTS = gql`
  query GetProjects($limit: Int, $offset: Int, $countryId: ID) {
    projects(limit: $limit, offset: $offset, countryId: $countryId) {
      id
      name
      description
      countryId
      sector
      status
      budget
      gdpContribution
      createdAt
      updatedAt
    }
  }
`;

// PHASE 4: Sectoral Statistics Queries
export const GET_SECTORAL_STATS = gql`
  query GetSectoralStats {
    sectoralStats {
      sector
      projectCount
      totalBudget
      avgBudget
      avgImpact
      countriesInvolved
    }
  }
`;

export const GET_PROJECTS_BY_SECTOR = gql`
  query GetProjectsBySector($sector: String!) {
    projects(filter: { sector: $sector }) {
      id
      projectName
      sector
      status
      budgetUsd
      impactScore
      description
      insertedAt
      updatedAt
      country {
        id
        countryCode
        countryName
        region
      }
    }
  }
`;

export const GET_GLOBAL_STATS = gql`
  query GetGlobalStats {
    globalStats {
      totalCountries
      totalGdp
      totalCovenantFund
      activeCountries
    }
  }
`;

export const GET_REGIONAL_STATS = gql`
  query GetRegionalStats($region: String!) {
    regionalStats(region: $region) {
      region
      count
      totalGdp
      totalCovenant
      activeCountries
    }
  }
`;

export const GET_STATS = gql`
  query GetStats {
    stats {
      totalCountries
      totalProjects
      averageGdp
      totalPopulation
      countriesByRegion {
        region
        count
      }
    }
  }
`;

export const GET_CODEX_VERSES = gql`
  query GetCodexVerses($sector: String) {
    codexVerses(sector: $sector) {
      id
      verse
      sector
      content
      createdAt
    }
  }
`;

export const CREATE_PROJECT = gql`
  mutation CreateProject($input: ProjectInput!) {
    createProject(input: $input) {
      id
      name
      description
      countryId
      sector
      status
      budget
      gdpContribution
      createdAt
    }
  }
`;

export const UPDATE_PROJECT = gql`
  mutation UpdateProject($id: ID!, $input: ProjectInput!) {
    updateProject(id: $id, input: $input) {
      id
      name
      description
      status
      budget
      gdpContribution
      updatedAt
    }
  }
`;

export const DELETE_PROJECT = gql`
  mutation DeleteProject($id: ID!) {
    deleteProject(id: $id) {
      success
      message
    }
  }
`;

// TypeScript Interfaces for Phase 4
export interface SectoralStats {
  sector: string;
  projectCount: number;
  totalBudget: number;
  avgBudget: number | null;
  avgImpact: number | null;
  countriesInvolved: number;
}

export interface GlobalStats {
  totalCountries: number;
  totalGdp: number;
  totalCovenantFund: number;
  activeCountries: number;
}

export interface RegionalStats {
  region: string;
  count: number;
  totalGdp: number;
  totalCovenant: number;
  activeCountries: number;
}
