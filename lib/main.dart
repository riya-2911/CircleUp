import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'utils/theme.dart';
import 'ui/screens/splash_screen.dart';
import 'ui/screens/onboarding_screen.dart';
import 'ui/screens/login_screen.dart';
import 'ui/screens/home_screen.dart';
import 'ui/screens/intent_selection_screen.dart';
import 'ui/screens/discovery_screen.dart';
import 'ui/screens/requests_screen.dart';
import 'ui/screens/chat_screen.dart';
import 'ui/screens/profile_setup_screen.dart';
import 'ui/screens/main_navigation_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/intent_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/post_provider.dart';
import 'providers/live_provider.dart';
import 'providers/connections_provider.dart';

import 'package:flutter/foundation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (kIsWeb) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: 'AIzaSyCFjPm8dsJFJoSxesD1H_v7RSkeSxSnwpA',
          appId: '1:191633865917:web:c5b9bea9a18e6761ee8bd4',
          messagingSenderId: '191633865917',
          projectId: 'circleup-cf99a',
          authDomain: 'circleup-cf99a.firebaseapp.com',
          storageBucket: 'circleup-cf99a.firebasestorage.app',
        ),
      );
    } else {
      await Firebase.initializeApp();
    }
  } catch (e) {
    debugPrint('Firebase init error: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => IntentProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => PostProvider()),
        ChangeNotifierProvider(create: (_) => LiveProvider()),
        ChangeNotifierProvider(create: (_) => ConnectionsProvider()),
      ],
      child: const CircleUpApp(),
    ),
  );
}

class CircleUpApp extends StatelessWidget {
  const CircleUpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CircleUP',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Respects user system preferences
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/intent': (context) => const IntentSelectionScreen(),
        '/discovery': (context) => const DiscoveryScreen(),
        '/requests': (context) => const RequestsScreen(),
        '/chat': (context) => const ChatScreen(),
        '/profile-setup': (context) => const ProfileSetupScreen(),
        '/main-nav': (context) => const MainNavigationScreen(),
      },
    );
  }
}
