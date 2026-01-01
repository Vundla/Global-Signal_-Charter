/**
 * Authentication Service
 * OAuth2 + Biometric + Keychain
 */

import {Alert} from 'react-native';
import ReactNativeBiometrics, {BiometryTypes} from 'react-native-biometrics';
import * as Keychain from 'react-native-keychain';
import axios from 'axios';

const API_BASE_URL = process.env.API_BASE_URL || 'https://api.globalsovereign.org';

export interface AuthTokens {
  accessToken: string;
  refreshToken: string;
  expiresAt: number;
}

export interface User {
  id: string;
  email: string;
  name: string;
  country_code: string;
  roles: string[];
}

class AuthService {
  private biometrics = new ReactNativeBiometrics();

  /**
   * Check if biometric authentication is available
   */
  async checkBiometricAvailability(): Promise<boolean> {
    try {
      const {available, biometryType} = await this.biometrics.isSensorAvailable();
      
      if (available) {
        console.log(`Biometric type available: ${biometryType}`);
        return true;
      }
      return false;
    } catch (error) {
      console.error('Biometric check failed:', error);
      return false;
    }
  }

  /**
   * Authenticate with email + password (OAuth2)
   */
  async login(email: string, password: string): Promise<{user: User; tokens: AuthTokens}> {
    try {
      const response = await axios.post(`${API_BASE_URL}/auth/login`, {
        email,
        password,
        grant_type: 'password',
      });

      const {user, access_token, refresh_token, expires_in} = response.data;

      const tokens: AuthTokens = {
        accessToken: access_token,
        refreshToken: refresh_token,
        expiresAt: Date.now() + expires_in * 1000,
      };

      // Store tokens securely in Keychain
      await this.storeTokens(tokens);

      return {user, tokens};
    } catch (error: any) {
      console.error('Login failed:', error);
      throw new Error(error.response?.data?.message || 'Authentication failed');
    }
  }

  /**
   * Authenticate with biometrics (after initial login)
   */
  async loginWithBiometrics(): Promise<{user: User; tokens: AuthTokens}> {
    try {
      // Check if biometrics are available
      const available = await this.checkBiometricAvailability();
      if (!available) {
        throw new Error('Biometric authentication not available');
      }

      // Prompt for biometric authentication
      const {success} = await this.biometrics.simplePrompt({
        promptMessage: 'Authenticate to access Global Sovereign Covenant',
        cancelButtonText: 'Cancel',
      });

      if (!success) {
        throw new Error('Biometric authentication failed');
      }

      // Retrieve stored tokens
      const credentials = await Keychain.getGenericPassword();
      if (!credentials) {
        throw new Error('No stored credentials found');
      }

      const tokens: AuthTokens = JSON.parse(credentials.password);

      // Validate token expiration
      if (tokens.expiresAt < Date.now()) {
        console.log('Token expired, refreshing...');
        const newTokens = await this.refreshAccessToken(tokens.refreshToken);
        await this.storeTokens(newTokens);
        return {user: await this.fetchUser(newTokens.accessToken), tokens: newTokens};
      }

      // Fetch user profile
      const user = await this.fetchUser(tokens.accessToken);

      return {user, tokens};
    } catch (error: any) {
      console.error('Biometric login failed:', error);
      throw error;
    }
  }

  /**
   * Store authentication tokens securely
   */
  private async storeTokens(tokens: AuthTokens): Promise<void> {
    await Keychain.setGenericPassword(
      'global_sovereign_tokens',
      JSON.stringify(tokens),
      {
        accessControl: Keychain.ACCESS_CONTROL.BIOMETRY_ANY,
        accessible: Keychain.ACCESSIBLE.WHEN_UNLOCKED_THIS_DEVICE_ONLY,
      }
    );
  }

  /**
   * Refresh expired access token
   */
  private async refreshAccessToken(refreshToken: string): Promise<AuthTokens> {
    try {
      const response = await axios.post(`${API_BASE_URL}/auth/refresh`, {
        refresh_token: refreshToken,
        grant_type: 'refresh_token',
      });

      const {access_token, refresh_token, expires_in} = response.data;

      return {
        accessToken: access_token,
        refreshToken: refresh_token,
        expiresAt: Date.now() + expires_in * 1000,
      };
    } catch (error: any) {
      console.error('Token refresh failed:', error);
      throw new Error('Session expired. Please login again.');
    }
  }

  /**
   * Fetch user profile from API
   */
  private async fetchUser(accessToken: string): Promise<User> {
    try {
      const response = await axios.get(`${API_BASE_URL}/auth/me`, {
        headers: {Authorization: `Bearer ${accessToken}`},
      });

      return response.data;
    } catch (error: any) {
      console.error('Fetch user failed:', error);
      throw new Error('Failed to fetch user profile');
    }
  }

  /**
   * Logout and clear stored credentials
   */
  async logout(): Promise<void> {
    try {
      await Keychain.resetGenericPassword();
      console.log('Logged out successfully');
    } catch (error) {
      console.error('Logout failed:', error);
    }
  }
}

export default new AuthService();
