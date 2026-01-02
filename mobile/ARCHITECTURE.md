# 📱 Global Sovereign Network - Mobile App Architecture

**Framework**: React Native + Expo  
**Database**: WatermelonDB (offline-first)  
**State Management**: Zustand  
**Authentication**: Biometric + OAuth2  
**Sync Engine**: Background sync with conflict resolution  
**Target Platforms**: iOS 13.4+ | Android 6.0+  

---

## 🏗️ Application Architecture

### Layer Structure

```
┌─────────────────────────────────────────────────────────────┐
│                   UI Layer (React Components)               │
│  Screens │ Components │ Navigation │ Styling │ Accessibility│
└────────────────────────┬────────────────────────────────────┘
                         │
┌────────────────────────▼────────────────────────────────────┐
│                 State Management (Zustand)                   │
│  authStore │ countryStore │ projectStore │ syncStore        │
└────────────────────────┬────────────────────────────────────┘
                         │
┌────────────────────────▼────────────────────────────────────┐
│                 API & Sync Layer                             │
│  GraphQL Client │ REST Fallback │ Background Sync │ Conflict│
│  Resolution     │ Queue Manager │ Encryption      │         │
└────────────────────────┬────────────────────────────────────┘
                         │
┌────────────────────────▼────────────────────────────────────┐
│              Local Database (WatermelonDB)                   │
│  Countries │ Projects │ Users │ Sync Metadata │ Offline Ops │
└────────────────────────┬────────────────────────────────────┘
                         │
┌────────────────────────▼────────────────────────────────────┐
│                Device Services                               │
│  Biometric │ Keychain │ Push Notifications │ File Storage    │
└─────────────────────────────────────────────────────────────┘
```

---

## 📂 Project Structure

```
mobile/
├── src/
│   ├── screens/
│   │   ├── auth/
│   │   │   ├── LoginScreen.tsx          # Biometric login
│   │   │   ├── RegisterScreen.tsx       # New account creation
│   │   │   └── BiometricSetup.tsx       # Fingerprint/FaceID
│   │   │
│   │   ├── home/
│   │   │   ├── HomeScreen.tsx           # Dashboard
│   │   │   ├── CountriesListScreen.tsx  # 195 countries
│   │   │   └── CountryDetailScreen.tsx  # Country details
│   │   │
│   │   ├── projects/
│   │   │   ├── ProjectsListScreen.tsx   # All projects
│   │   │   ├── ProjectDetailScreen.tsx  # Project info
│   │   │   └── ProjectMapScreen.tsx     # Map view (6 regions)
│   │   │
│   │   ├── regions/
│   │   │   ├── RegionsScreen.tsx        # 6 regions overview
│   │   │   └── RegionDetailScreen.tsx   # Region data
│   │   │
│   │   ├── offline/
│   │   │   ├── OfflineScreen.tsx        # Offline status
│   │   │   ├── SyncQueueScreen.tsx      # Pending operations
│   │   │   └── CacheScreen.tsx          # Local storage
│   │   │
│   │   └── settings/
│   │       ├── SettingsScreen.tsx       # User preferences
│   │       ├── DataManagementScreen.tsx # Cache/DB management
│   │       └── ProfileScreen.tsx        # User profile
│   │
│   ├── components/
│   │   ├── ui/
│   │   │   ├── Button.tsx               # Reusable button
│   │   │   ├── Card.tsx                 # Card component
│   │   │   ├── Badge.tsx                # Status badges
│   │   │   ├── Spinner.tsx              # Loading spinner
│   │   │   └── StatusIndicator.tsx      # Online/offline
│   │   │
│   │   ├── common/
│   │   │   ├── Header.tsx               # Screen header
│   │   │   ├── Footer.tsx               # Screen footer
│   │   │   ├── ErrorBoundary.tsx        # Error handling
│   │   │   └── SyncStatus.tsx           # Sync indicator
│   │   │
│   │   └── data/
│   │       ├── CountryCard.tsx          # Country item
│   │       ├── ProjectCard.tsx          # Project item
│   │       └── RegionCard.tsx           # Region item
│   │
│   ├── navigation/
│   │   ├── RootNavigator.tsx            # Main navigation
│   │   ├── AuthNavigator.tsx            # Auth stack
│   │   ├── MainNavigator.tsx            # Main app stack
│   │   └── TabNavigator.tsx             # Bottom tabs
│   │
│   ├── stores/
│   │   ├── authStore.ts                 # Auth state (Zustand)
│   │   ├── countryStore.ts              # Countries state
│   │   ├── projectStore.ts              # Projects state
│   │   ├── syncStore.ts                 # Sync state
│   │   └── settingsStore.ts             # User settings
│   │
│   ├── services/
│   │   ├── api/
│   │   │   ├── graphqlClient.ts         # Apollo GraphQL
│   │   │   ├── queries.ts               # GraphQL queries
│   │   │   └── mutations.ts             # GraphQL mutations
│   │   │
│   │   ├── auth/
│   │   │   ├── biometricAuth.ts         # Biometric login
│   │   │   ├── tokenManager.ts          # JWT token handling
│   │   │   └── secureStorage.ts         # Keychain integration
│   │   │
│   │   ├── database/
│   │   │   ├── schema.ts                # WatermelonDB schema
│   │   │   ├── models.ts                # Database models
│   │   │   └── database.ts              # DB initialization
│   │   │
│   │   ├── sync/
│   │   │   ├── syncEngine.ts            # Main sync logic
│   │   │   ├── conflictResolver.ts      # Conflict resolution
│   │   │   ├── queueManager.ts          # Offline queue
│   │   │   └── backgroundSync.ts        # Background tasks
│   │   │
│   │   ├── notifications/
│   │   │   ├── pushNotifications.ts     # Push setup
│   │   │   ├── localNotifications.ts    # Local alerts
│   │   │   └── notificationHandler.ts   # Handle notifications
│   │   │
│   │   └── utils/
│   │       ├── encryption.ts            # Data encryption
│   │       ├── compression.ts           # Data compression
│   │       ├── validators.ts            # Input validation
│   │       └── formatters.ts            # Data formatting
│   │
│   ├── hooks/
│   │   ├── useAuth.ts                   # Auth hook
│   │   ├── useCountries.ts              # Countries hook
│   │   ├── useProjects.ts               # Projects hook
│   │   ├── useSync.ts                   # Sync hook
│   │   ├── useOffline.ts                # Offline hook
│   │   └── useNotifications.ts          # Notifications hook
│   │
│   ├── theme/
│   │   ├── colors.ts                    # Color palette
│   │   ├── typography.ts                # Font settings
│   │   ├── spacing.ts                   # Spacing scale
│   │   └── theme.ts                     # Theme configuration
│   │
│   ├── constants/
│   │   ├── API_ENDPOINTS.ts             # API URLs
│   │   ├── DATABASE.ts                  # DB constants
│   │   ├── REGIONS.ts                   # Region config
│   │   └── FEATURES.ts                  # Feature flags
│   │
│   ├── types/
│   │   ├── api.ts                       # API types
│   │   ├── models.ts                    # Data models
│   │   ├── navigation.ts                # Navigation types
│   │   └── common.ts                    # Common types
│   │
│   └── App.tsx                          # App entry
│
├── App.json                             # Expo config
├── app.json                             # React Native config
├── tsconfig.json                        # TypeScript config
├── package.json                         # Dependencies
└── README.md                            # Documentation
```

---

## 🗄️ Database Schema (WatermelonDB)

### Collections

#### Countries
```typescript
{
  code: string (primary)
  name: string
  gdp_usd_billions: number
  continent: string
  region: string  // ams|iad|syd|sin|sfo|jnb
  contribution_usd_millions: number
  created_at: Date
  updated_at: Date
  sync_status: 'synced' | 'pending' | 'failed'
}
```

#### Projects
```typescript
{
  id: string (primary)
  name: string
  description: string
  region: string
  country_code: string (foreign key)
  sector: string  // Agriculture|Minerals|Energy|Technology|Health|Education
  status: 'Active' | 'Pending' | 'Completed'
  funding_usd_millions: number
  progress: number  // 0-100
  created_at: Date
  updated_at: Date
  sync_status: 'synced' | 'pending' | 'failed'
}
```

#### Users
```typescript
{
  id: string (primary)
  email: string (unique)
  name: string
  avatar_url?: string
  biometric_enabled: boolean
  created_at: Date
  updated_at: Date
}
```

#### SyncQueue
```typescript
{
  id: string (primary)
  operation: 'create' | 'update' | 'delete'
  entity: string  // 'countries' | 'projects' | 'users'
  payload: object (JSON)
  created_at: Date
  retry_count: number
  last_error?: string
}
```

---

## 🔐 Security Implementation

### Authentication Flow
```
User → Biometric Prompt → Secure Token → GraphQL Auth Header
                            ↓
                    Refresh Token (Keychain)
                            ↓
                    Access Token (Memory)
```

### Data Protection
- **At Rest**: AES-256 encryption for sensitive data
- **In Transit**: TLS 1.3, certificate pinning
- **Tokens**: Stored in iOS Keychain / Android Keystore
- **Local DB**: Encrypted WatermelonDB

### Permissions
- Camera (for QR code scanning)
- Biometric (for authentication)
- Location (optional, for region detection)
- Notifications (for push alerts)

---

## 🔄 Sync Strategy

### Offline-First Sync Engine

```typescript
// On app launch
1. Check network status
2. Load data from WatermelonDB
3. If online, start background sync
4. Emit changes via Zustand stores

// When user creates/updates data
1. Save to WatermelonDB immediately
2. Add to SyncQueue
3. If online, sync immediately
4. If offline, queue for later
5. Retry with exponential backoff

// Background sync
1. Wake up periodically
2. Check network
3. Process SyncQueue
4. Resolve conflicts
5. Update local cache
6. Emit notifications
```

### Conflict Resolution

```
Server Version → Compare with Local → Apply Strategy

Strategies:
1. Server Wins (default for read-only)
2. Client Wins (for offline-created)
3. Manual Merge (for important data)
4. Custom Logic (business rules)
```

---

## 🎯 Key Features

### 1. **Biometric Authentication**
- Face ID (iOS) / Face Unlock (Android)
- Fingerprint authentication
- Fallback to PIN/Password
- Session management with timeout

### 2. **Offline-First Sync**
- Automatic background sync
- Smart queue management
- Conflict resolution
- Retry logic with exponential backoff

### 3. **Push Notifications**
- Real-time project updates
- Regional alerts
- Offline cached notifications
- Local notification fallback

### 4. **Multi-Region Support**
- Region-specific data filtering
- Latency-optimized endpoints
- Regional language support
- Local timezone handling

### 5. **Data Management**
- Cache statistics
- Storage optimization
- Selective sync
- Data export/import

---

## 📊 Performance Targets

| Metric | Target | Current |
|--------|--------|---------|
| Cold Launch | < 3 sec | - |
| Hot Launch | < 1 sec | - |
| Initial Sync | < 30 sec | - |
| List Rendering | 60 FPS | - |
| Memory Usage | < 150 MB | - |
| DB Size | < 100 MB | - |
| Cache Hit Rate | > 90% | - |

---

## 🧪 Testing Strategy

### Unit Tests
- Store logic (Zustand)
- Utility functions
- Data formatters
- Validation functions

### Integration Tests
- API integration
- Database operations
- Sync engine
- Auth flow

### E2E Tests
- User authentication
- Data synchronization
- Offline/online transitions
- Navigation flows

### Performance Tests
- Bundle size
- Memory leaks
- Battery consumption
- Network optimization

---

## 🚀 Phase 4 Deployment Timeline

### Week 1: Setup & Foundation
- [ ] Initialize Expo project
- [ ] Configure WatermelonDB
- [ ] Setup navigation
- [ ] Implement auth flow

### Week 2: Core Features
- [ ] Implement offline sync
- [ ] Build screens (countries, projects, regions)
- [ ] Add push notifications
- [ ] Setup error handling

### Week 3: Polish & Testing
- [ ] E2E testing
- [ ] Performance optimization
- [ ] Security audit
- [ ] Documentation

### Week 4: Beta & Rollout
- [ ] Internal beta testing
- [ ] App Store review prep
- [ ] Production deployment
- [ ] Monitoring setup

---

## 📚 Related Files

- [Architecture](../docs/ARCHITECTURE.md)
- [Security Policies](../docs/SECURITY.md)
- [Phase 4 Plan](../PHASE4_PLAN.md)
- [Go-Live Checklist](../GO_LIVE_CHECKLIST.md)

---

**Status**: ✅ Architecture complete, ready for implementation  
**Next Step**: Run `npm install && npm run start`  
**Owner**: Mobile Development Team
