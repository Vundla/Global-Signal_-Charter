/**
 * WatermelonDB Schema for Offline-First Sync
 * Phase 4: 195 Countries, 500+ Projects
 */

import {appSchema, tableSchema} from '@nozbe/watermelondb';

export default appSchema({
  version: 1,
  tables: [
    tableSchema({
      name: 'countries',
      columns: [
        {name: 'country_code', type: 'string', isIndexed: true},
        {name: 'country_name', type: 'string'},
        {name: 'region', type: 'string', isIndexed: true},
        {name: 'gdp_usd', type: 'number'},
        {name: 'contribution_usd', type: 'number'},
        {name: 'covenant_status', type: 'string'},
        {name: 'joined_at', type: 'number'},
        {name: 'last_synced_at', type: 'number'},
      ],
    }),
    tableSchema({
      name: 'projects',
      columns: [
        {name: 'project_id', type: 'string', isIndexed: true},
        {name: 'project_name', type: 'string'},
        {name: 'sector', type: 'string', isIndexed: true},
        {name: 'country_id', type: 'string', isIndexed: true},
        {name: 'status', type: 'string', isIndexed: true},
        {name: 'budget_usd', type: 'number'},
        {name: 'impact_score', type: 'number'},
        {name: 'created_at', type: 'number'},
        {name: 'last_synced_at', type: 'number'},
      ],
    }),
    tableSchema({
      name: 'sync_queue',
      columns: [
        {name: 'action', type: 'string'},
        {name: 'table_name', type: 'string'},
        {name: 'record_id', type: 'string'},
        {name: 'payload', type: 'string'},
        {name: 'status', type: 'string'},
        {name: 'retries', type: 'number'},
        {name: 'created_at', type: 'number'},
      ],
    }),
  ],
});
