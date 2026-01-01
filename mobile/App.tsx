/**
 * Global Sovereign Covenant - Mobile App
 * Phase 4: React Native with Offline-First Architecture
 */

import React from 'react';
import {
  SafeAreaView,
  ScrollView,
  StatusBar,
  StyleSheet,
  Text,
  View,
  useColorScheme,
} from 'react-native';

function App(): JSX.Element {
  const isDarkMode = useColorScheme() === 'dark';

  const backgroundStyle = {
    backgroundColor: isDarkMode ? '#1a1a1a' : '#f5f5f5',
  };

  return (
    <SafeAreaView style={[styles.container, backgroundStyle]}>
      <StatusBar
        barStyle={isDarkMode ? 'light-content' : 'dark-content'}
        backgroundColor={backgroundStyle.backgroundColor}
      />
      <ScrollView
        contentInsetAdjustmentBehavior="automatic"
        style={backgroundStyle}>
        <View style={styles.header}>
          <Text style={styles.title}>🌍 Global Sovereign Covenant</Text>
          <Text style={styles.subtitle}>Phase 4: Mobile Edition</Text>
        </View>

        <View style={styles.card}>
          <Text style={styles.cardTitle}>📱 Welcome</Text>
          <Text style={styles.cardText}>
            This is the React Native mobile app for the Global Sovereign Covenant.
          </Text>
          <Text style={styles.cardText}>
            • 195 Nations{'\n'}
            • 500+ Projects{'\n'}
            • Offline-First Sync{'\n'}
            • Zero-Trust Security
          </Text>
        </View>

        <View style={styles.card}>
          <Text style={styles.cardTitle}>🎯 Phase 4 Features</Text>
          <Text style={styles.cardText}>
            ✅ Biometric Authentication{'\n'}
            ✅ WatermelonDB Offline Storage{'\n'}
            ✅ Push Notifications{'\n'}
            ✅ Background Sync{'\n'}
            ✅ Multi-Region Support
          </Text>
        </View>

        <View style={styles.footer}>
          <Text style={styles.footerText}>
            "Resilience becomes law, unity becomes inheritance."
          </Text>
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  header: {
    alignItems: 'center',
    paddingVertical: 32,
    paddingHorizontal: 16,
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    marginBottom: 8,
  },
  subtitle: {
    fontSize: 16,
    color: '#666',
  },
  card: {
    backgroundColor: 'white',
    marginHorizontal: 16,
    marginBottom: 16,
    padding: 20,
    borderRadius: 12,
    shadowColor: '#000',
    shadowOffset: {width: 0, height: 2},
    shadowOpacity: 0.1,
    shadowRadius: 8,
    elevation: 3,
  },
  cardTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    marginBottom: 12,
  },
  cardText: {
    fontSize: 14,
    lineHeight: 22,
    color: '#333',
  },
  footer: {
    paddingVertical: 32,
    paddingHorizontal: 16,
    alignItems: 'center',
  },
  footerText: {
    fontSize: 14,
    fontStyle: 'italic',
    color: '#666',
    textAlign: 'center',
  },
});

export default App;
