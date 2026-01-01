/**
 * Background Sync Service
 * Handles offline queue and background synchronization
 */

import {Q} from '@nozbe/watermelondb';
import database from '../database';
import axios from 'axios';

const API_BASE_URL = process.env.API_BASE_URL || 'https://api.globalsovereign.org';

class SyncService {
  private syncInterval: NodeJS.Timeout | null = null;
  private accessToken: string = '';

  /**
   * Initialize sync service with auth token
   */
  setAccessToken(token: string) {
    this.accessToken = token;
  }

  /**
   * Start background sync (every 5 minutes)
   */
  startBackgroundSync() {
    if (this.syncInterval) {
      clearInterval(this.syncInterval);
    }

    console.log('Starting background sync...');
    this.syncInterval = setInterval(() => {
      this.performSync();
    }, 5 * 60 * 1000); // 5 minutes

    // Perform immediate sync
    this.performSync();
  }

  /**
   * Stop background sync
   */
  stopBackgroundSync() {
    if (this.syncInterval) {
      clearInterval(this.syncInterval);
      this.syncInterval = null;
      console.log('Background sync stopped');
    }
  }

  /**
   * Perform full synchronization
   */
  async performSync(): Promise<void> {
    try {
      console.log('🔄 Starting sync...');

      // 1. Push pending changes to server
      await this.pushPendingChanges();

      // 2. Pull latest data from server
      await this.pullLatestData();

      console.log('✅ Sync completed successfully');
    } catch (error) {
      console.error('❌ Sync failed:', error);
      throw error;
    }
  }

  /**
   * Push pending changes from sync queue to server
   */
  private async pushPendingChanges(): Promise<void> {
    const syncQueueCollection = database.get('sync_queue');
    const pendingItems = await syncQueueCollection
      .query(Q.where('status', 'pending'))
      .fetch();

    console.log(`📤 Pushing ${pendingItems.length} pending changes...`);

    for (const item of pendingItems) {
      try {
        const payload = JSON.parse(item.payload);

        // Send to API based on action
        switch (item.action) {
          case 'create':
            await axios.post(
              `${API_BASE_URL}/${item.table_name}`,
              payload,
              {headers: {Authorization: `Bearer ${this.accessToken}`}}
            );
            break;
          case 'update':
            await axios.put(
              `${API_BASE_URL}/${item.table_name}/${item.record_id}`,
              payload,
              {headers: {Authorization: `Bearer ${this.accessToken}`}}
            );
            break;
          case 'delete':
            await axios.delete(
              `${API_BASE_URL}/${item.table_name}/${item.record_id}`,
              {headers: {Authorization: `Bearer ${this.accessToken}`}}
            );
            break;
        }

        // Mark as synced
        await database.write(async () => {
          await item.update(record => {
            record.status = 'synced';
          });
        });

        console.log(`✅ Synced ${item.action} on ${item.table_name}`);
      } catch (error: any) {
        console.error(`❌ Failed to sync item ${item.id}:`, error);

        // Increment retry counter
        await database.write(async () => {
          await item.update(record => {
            record.retries = (record.retries || 0) + 1;
            if (record.retries >= 3) {
              record.status = 'failed';
            }
          });
        });
      }
    }
  }

  /**
   * Pull latest data from server and update local database
   */
  private async pullLatestData(): Promise<void> {
    try {
      console.log('📥 Pulling latest data from server...');

      // Fetch countries
      const countriesResponse = await axios.get(`${API_BASE_URL}/countries`, {
        headers: {Authorization: `Bearer ${this.accessToken}`},
      });

      await this.updateCountries(countriesResponse.data);

      // Fetch projects
      const projectsResponse = await axios.get(`${API_BASE_URL}/projects`, {
        headers: {Authorization: `Bearer ${this.accessToken}`},
      });

      await this.updateProjects(projectsResponse.data);

      console.log('✅ Data pulled and updated successfully');
    } catch (error) {
      console.error('❌ Failed to pull data:', error);
      throw error;
    }
  }

  /**
   * Update local countries table with server data
   */
  private async updateCountries(serverCountries: any[]): Promise<void> {
    const countriesCollection = database.get('countries');

    await database.write(async () => {
      for (const serverCountry of serverCountries) {
        const existingCountries = await countriesCollection
          .query(Q.where('country_code', serverCountry.country_code))
          .fetch();

        if (existingCountries.length > 0) {
          // Update existing
          await existingCountries[0].update(country => {
            Object.assign(country, {
              country_name: serverCountry.name,
              region: serverCountry.region,
              gdp_usd: serverCountry.gdp_usd,
              contribution_usd: serverCountry.contribution_usd,
              covenant_status: serverCountry.covenant_status,
              last_synced_at: Date.now(),
            });
          });
        } else {
          // Create new
          await countriesCollection.create(country => {
            Object.assign(country, {
              country_code: serverCountry.country_code,
              country_name: serverCountry.name,
              region: serverCountry.region,
              gdp_usd: serverCountry.gdp_usd,
              contribution_usd: serverCountry.contribution_usd,
              covenant_status: serverCountry.covenant_status,
              joined_at: new Date(serverCountry.joined_at).getTime(),
              last_synced_at: Date.now(),
            });
          });
        }
      }
    });

    console.log(`✅ Updated ${serverCountries.length} countries`);
  }

  /**
   * Update local projects table with server data
   */
  private async updateProjects(serverProjects: any[]): Promise<void> {
    const projectsCollection = database.get('projects');

    await database.write(async () => {
      for (const serverProject of serverProjects) {
        const existingProjects = await projectsCollection
          .query(Q.where('project_id', serverProject.id))
          .fetch();

        if (existingProjects.length > 0) {
          // Update existing
          await existingProjects[0].update(project => {
            Object.assign(project, {
              project_name: serverProject.name,
              sector: serverProject.sector,
              country_id: serverProject.country_id,
              status: serverProject.status,
              budget_usd: serverProject.budget_usd,
              impact_score: serverProject.impact_score,
              last_synced_at: Date.now(),
            });
          });
        } else {
          // Create new
          await projectsCollection.create(project => {
            Object.assign(project, {
              project_id: serverProject.id,
              project_name: serverProject.name,
              sector: serverProject.sector,
              country_id: serverProject.country_id,
              status: serverProject.status,
              budget_usd: serverProject.budget_usd,
              impact_score: serverProject.impact_score,
              created_at: new Date(serverProject.created_at).getTime(),
              last_synced_at: Date.now(),
            });
          });
        }
      }
    });

    console.log(`✅ Updated ${serverProjects.length} projects`);
  }

  /**
   * Add item to sync queue (for offline changes)
   */
  async addToSyncQueue(
    action: 'create' | 'update' | 'delete',
    tableName: string,
    recordId: string,
    payload: any
  ): Promise<void> {
    const syncQueueCollection = database.get('sync_queue');

    await database.write(async () => {
      await syncQueueCollection.create(item => {
        item.action = action;
        item.table_name = tableName;
        item.record_id = recordId;
        item.payload = JSON.stringify(payload);
        item.status = 'pending';
        item.retries = 0;
        item.created_at = Date.now();
      });
    });

    console.log(`📋 Added ${action} to sync queue for ${tableName}`);
  }
}

export default new SyncService();
