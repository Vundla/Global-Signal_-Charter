# Phase 4: Mobile App Architecture

> Building iOS/Android apps for the Global Covenant

---

## Tech Stack Decision: React Native

### Why React Native (vs Flutter/Native)?
| Factor | React Native | Flutter | Native (Swift/Kotlin) |
|--------|--------------|---------|----------------------|
| Code Sharing | 70% iOS/Android | 95% iOS/Android | 0% |
| Learning Curve | Medium (JS/TypeScript) | Medium (Dart) | High (2 languages) |
| Performance | ~95% native | ~98% native | 100% native |
| Ecosystem | Mature (Expo, RN Paper) | Growing | Native libraries |
| Team Fit | Existing JS team | New language | Splits team |
| **Our Choice** | ✅ | 🤔 | ❌ |

---

## App Architecture

### Directory Structure
```
mobile/
├── ios/                      # iOS native code (pods, config)
├── android/                  # Android native code (gradle, config)
├── src/
│   ├── api/                  # REST client, GraphQL client
│   │   ├── client.ts
│   │   ├── covenant.ts
│   │   ├── sectors.ts
│   │   └── projects.ts
│   ├── components/           # Reusable UI components
│   │   ├── CountryCard.tsx
│   │   ├── ProjectDetail.tsx
│   │   ├── OfflineIndicator.tsx
│   │   └── NotificationBanner.tsx
│   ├── screens/              # Navigation screens
│   │   ├── auth/
│   │   │   ├── LoginScreen.tsx
│   │   │   ├── BiometricScreen.tsx
│   │   │   └── SignupScreen.tsx
│   │   ├── home/
│   │   │   ├── CovenantOverviewScreen.tsx
│   │   │   ├── CountriesListScreen.tsx
│   │   │   └── ProjectsListScreen.tsx
│   │   ├── sectors/
│   │   │   ├── SectorDetailScreen.tsx
│   │   │   └── ProjectDetailScreen.tsx
│   │   └── profile/
│   │       ├── ProfileScreen.tsx
│   │       ├── PreferencesScreen.tsx
│   │       └── DownloadDataScreen.tsx
│   ├── store/                # State management (Zustand/Redux)
│   │   ├── authStore.ts
│   │   ├── covenantStore.ts
│   │   └── syncStore.ts
│   ├── db/                   # WatermelonDB schemas
│   │   ├── schema.ts
│   │   ├── countries.ts
│   │   ├── projects.ts
│   │   └── sync.ts
│   ├── services/             # Business logic
│   │   ├── authService.ts
│   │   ├── syncService.ts
│   │   ├── notificationService.ts
│   │   └── offlineService.ts
│   ├── utils/
│   │   ├── constants.ts
│   │   ├── formatting.ts
│   │   └── storage.ts
│   ├── App.tsx               # Root component
│   └── index.ts
├── package.json
└── app.json                  # Expo/EAS config
```

---

## Core Features (MVP)

### 1. Authentication
```typescript
// src/services/authService.ts

export interface AuthCredentials {
  email: string;
  password: string;
}

export interface BiometricAuth {
  type: "face" | "fingerprint";
  enabled: boolean;
}

class AuthService {
  // OAuth2 with backend
  async loginWithCredentials(creds: AuthCredentials) {
    const response = await fetch(`${API_URL}/auth/login`, {
      method: "POST",
      body: JSON.stringify(creds)
    });
    const { token, refreshToken } = await response.json();
    await SecureStore.setItemAsync("authToken", token);
    await SecureStore.setItemAsync("refreshToken", refreshToken);
    return { token, refreshToken };
  }

  // Biometric (Face ID / Touch ID)
  async setupBiometric() {
    const compatible = await * BiometricAuth.isAvailableAsync();
    if (!compatible) throw new Error("Biometric not available");
    
    const savedTokens = await SecureStore.getItemAsync("authToken");
    if (savedTokens) {
      return { success: true };
    }
  }

  // Token refresh (background)
  async refreshToken() {
    const refreshToken = await SecureStore.getItemAsync("refreshToken");
    const response = await fetch(`${API_URL}/auth/refresh`, {
      method: "POST",
      body: JSON.stringify({ refreshToken })
    });
    const { token } = await response.json();
    await SecureStore.setItemAsync("authToken", token);
    return token;
  }
}
```

### 2. Offline-First Data Sync (WatermelonDB)
```typescript
// src/db/schema.ts

import { Database } from "@nozbe/watermelon";
import SQLiteAdapter from "@nozbe/watermelon/adapters/sqlite";

import CountrySchema from "./countries";
import ProjectSchema from "./projects";
import UserSchema from "./users";

const adapter = new SQLiteAdapter({
  dbName: "global_sovereign",
  schema: {
    tables: [CountrySchema, ProjectSchema, UserSchema]
  }
});

export const database = new Database({
  adapter,
  modelClasses: [Country, Project, User]
});

// src/db/countries.ts
export const CountrySchema = tableSchema({
  name: "countries",
  columns: [
    { name: "country_code", type: "string", isIndexed: true },
    { name: "country_name", type: "string" },
    { name: "gdp_usd", type: "number" },
    { name: "contribution_usd", type: "number" },
    { name: "covenant_status", type: "string" },
    { name: "region", type: "string" },
    { name: "synced_at", type: "number" }
  ]
});

// src/services/syncService.ts
class SyncService {
  async syncCountries() {
    try {
      const response = await fetch(`${API_URL}/api/countries`);
      const countries = await response.json();
      
      await database.write(async () => {
        for (const country of countries) {
          await Country.create(c => {
            c.countryCode = country.country_code;
            c.countryName = country.country_name;
            c.gdpUsd = country.gdp_usd;
            c.region = country.region;
            c.syncedAt = Date.now();
          });
        }
      });
      
      return { synced: countries.length };
    } catch (error) {
      // Offline: queue update for later
      await queueUpdate("sync_countries", { timestamp: Date.now() });
      throw error;
    }
  }

  async syncProjects(sectorName: string) {
    // Similar pattern for projects per sector
  }

  async executeQueuedUpdates() {
    // When online: send queued operations to backend
    const queued = await getQueuedUpdates();
    for (const update of queued) {
      try {
        await this.syncCountries(); // Or other sync methods
        await markUpdateAsSynced(update.id);
      } catch (error) {
        // Retry logic
        console.error("Failed to sync:", error);
      }
    }
  }
}
```

### 3. Real-Time Notifications
```typescript
// src/services/notificationService.ts

import * as Notifications from "expo-notifications";

class NotificationService {
  async initialize() {
    // Request permissions
    const { status } = await Notifications.requestPermissionsAsync();
    if (status !== "granted") {
      console.log("Notification permissions denied");
      return;
    }

    // Get device token
    const token = await Notifications.getExpoPushTokenAsync({
      projectId: System.get_env("EAS_PROJECT_ID")
    });

    // Send to backend for server-side notification management
    await fetch(`${API_URL}/notifications/register-device`, {
      method: "POST",
      body: JSON.stringify({ deviceToken: token.data })
    });

    // Handle notification events
    this.setupListeners();
  }

  private setupListeners() {
    // When app is in foreground
    Notifications.setNotificationHandler({
      handleNotification: async (notification) => {
        const { title, body, data } = notification.request.content;
        console.log(`Notification: ${title} - ${body}`);
        
        return {
          shouldShowAlert: true,
          shouldPlaySound: true,
          shouldSetBadge: true
        };
      }
    });

    // When user taps notification
    Notifications.addNotificationResponseReceivedListener(response => {
      const { data } = response.notification.request.content;
      this.handleDeepLink(data); // Navigate to relevant screen
    });
  }

  private handleDeepLink(data: Record<string, any>) {
    // Example: {"screen": "project_detail", "projectId": "123"}
    navigation.navigate(data.screen, data);
  }
}
```

### 4. User Interface Screens

#### Login Screen
```typescript
// src/screens/auth/LoginScreen.tsx

import React, { useState } from "react";
import { View, TextInput, TouchableOpacity, Text } from "react-native";
import { useAuth } from "@/store/authStore";

export function LoginScreen({ navigation }) {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const { login, isLoading } = useAuth();

  async function handleLogin() {
    try {
      await login({ email, password });
      navigation.reset({
        index: 0,
        routes: [{ name: "Home" }]
      });
    } catch (error) {
      alert(`Login failed: ${error.message}`);
    }
  }

  return (
    <View style={{ flex: 1, padding: 20, justifyContent: "center" }}>
      <Text style={{ fontSize: 24, marginBottom: 20, fontWeight: "bold" }}>
        Global Sovereign Covenant
      </Text>

      <TextInput
        placeholder="Email"
        value={email}
        onChangeText={setEmail}
        style={{ marginBottom: 12, padding: 10, borderWidth: 1 }}
        autoCapitalize="none"
      />

      <TextInput
        placeholder="Password"
        value={password}
        onChangeText={setPassword}
        secureTextEntry
        style={{ marginBottom: 20, padding: 10, borderWidth: 1 }}
      />

      <TouchableOpacity
        onPress={handleLogin}
        disabled={isLoading}
        style={{ backgroundColor: "#0066cc", padding: 15, borderRadius: 5 }}
      >
        <Text style={{ color: "white", textAlign: "center", fontSize: 16 }}>
          {isLoading ? "Logging in..." : "Login"}
        </Text>
      </TouchableOpacity>
    </View>
  );
}
```

#### Countries List Screen
```typescript
// src/screens/home/CountriesListScreen.tsx

import React, { useState, useEffect } from "react";
import { View, FlatList, SearchBar } from "react-native";
import { CountryCard } from "@/components/CountryCard";
import { useCovenantStore } from "@/store/covenantStore";
import { OfflineIndicator } from "@/components/OfflineIndicator";

export function CountriesListScreen({ navigation }) {
  const [search, setSearch] = useState("");
  const { countries, isLoading, refresh } = useCovenantStore();
  const [filteredCountries, setFilteredCountries] = useState(countries);

  useEffect(() => {
    const filtered = countries.filter(c =>
      c.countryName.toLowerCase().includes(search.toLowerCase()) ||
      c.countryCode.includes(search.toUpperCase())
    );
    setFilteredCountries(filtered);
  }, [search, countries]);

  return (
    <View style={{ flex: 1 }}>
      <OfflineIndicator />

      <SearchBar
        placeholder="Search countries..."
        value={search}
        onChangeText={setSearch}
        containerStyle={{ backgroundColor: "#fff" }}
      />

      <FlatList
        data={filteredCountries}
        renderItem={({ item }) => (
          <CountryCard
            country={item}
            onPress={() => navigation.navigate("CountryDetail", { id: item.id })}
          />
        )}
        keyExtractor={c => c.id}
        onRefresh={refresh}
        refreshing={isLoading}
      />
    </View>
  );
}
```

### 5. State Management (Zustand)
```typescript
// src/store/covenantStore.ts

import { create } from "zustand";
import { database } from "@/db";

export const useCovenantStore = create((set) => ({
  countries: [],
  projects: [],
  stats: null,
  isLoading: false,

  async loadCountries() {
    set({ isLoading: true });
    try {
      const countries = await database.collections
        .get("countries")
        .query()
        .fetch();
      set({ countries });
    } finally {
      set({ isLoading: false });
    }
  },

  async refresh() {
    set({ isLoading: true });
    try {
      // Sync from backend
      const response = await fetch(`${API_URL}/api/countries`);
      const data = await response.json();
      
      // Update local database
      await database.write(async () => {
        // Update logic here
      });

      set({ countries: data });
    } finally {
      set({ isLoading: false });
    }
  }
}));
```

---

## Implementation Timeline

### Week 1-2: Foundation
- [ ] Initialize React Native project (Expo)
- [ ] Set up navigation (React Navigation)
- [ ] Create authentication screens
- [ ] Set up WatermelonDB

### Week 3-4: Data Layer
- [ ] Implement sync service
- [ ] Create offline queuing
- [ ] Build countries list screen
- [ ] Build project detail screen

### Week 5-6: Features
- [ ] Add push notifications
- [ ] Implement biometric auth
- [ ] Create user preferences
- [ ] Add data download/export

### Week 7-8: Polish & Testing
- [ ] Load testing
- [ ] Offline scenario testing
- [ ] Performance optimization
- [ ] Beta testing

---

## Deployment

### iOS
```bash
# Build for iOS
eas build --platform ios

# Push to TestFlight
eas submit --platform ios --latest

# Release to App Store
# (manual review in App Store Connect)
```

### Android
```bash
# Build for Android
eas build --platform android

# Submit to Play Store
eas submit --platform android --latest
```

---

## Success Metrics (Mobile MVP)
- [ ] 50K+ downloads week 1
- [ ] 4.5+ star rating
- [ ] <2% crash rate
- [ ] 50%+ DAU/MAU ratio
- [ ] <5s app launch
- [ ] <100ms sync latency (online)
- [ ] Full functionality offline
