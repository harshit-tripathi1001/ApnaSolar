import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../screens/splash/splash_screen.dart';
import '../screens/welcome/welcome_screen.dart';
import '../services/auth_service.dart';

/// Root widget that listens to Firebase auth state and routes accordingly.
///
/// - If signed in → show the normal app (starting with SplashScreen)
/// - If not signed in → show WelcomeScreen ("Get Started")
///
/// When Firebase is not initialized (e.g., in widget tests), falls back
/// directly to SplashScreen so tests remain unaffected.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    // In test environments where Firebase is not initialized, go straight
    // to the normal app flow to avoid crashing tests.
    if (!AuthService.isFirebaseInitialized) {
      return const SplashScreen();
    }

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Still determining auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _AuthLoadingScreen();
        }

        // Signed in with real account (not anonymous) → normal app flow
        if (snapshot.hasData && snapshot.data != null && !snapshot.data!.isAnonymous) {
          return const SplashScreen();
        }

        // If an anonymous user session was stored, sign out immediately
        if (snapshot.hasData && snapshot.data != null && snapshot.data!.isAnonymous) {
          AuthService().signOut();
        }

        // Not signed in → show WelcomeScreen with "Get Started"
        return const WelcomeScreen();
      },
    );
  }
}

/// Minimal full-screen loader shown while Firebase resolves the auth state.
class _AuthLoadingScreen extends StatelessWidget {
  const _AuthLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF003323),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFFF5C542), strokeWidth: 2),
            SizedBox(height: 20),
            Text(
              'ApnaSolar',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
