import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'providers/app_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/alert_creation_screen.dart';
import 'screens/mesh_relay_screen.dart';
import 'screens/connectivity_restored_screen.dart';
import 'screens/alert_delivered_screen.dart';
import 'screens/contacts_screen.dart';
import 'screens/history_screen.dart';
import 'screens/about_screen.dart';
import 'screens/ai_assistant_screen.dart';
import 'screens/features_screen.dart';
import 'screens/trusted_messaging_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const SheShieldMeshApp());
}

class SheShieldMeshApp extends StatelessWidget {
  const SheShieldMeshApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: MaterialApp(
        title: 'SheShield Mesh',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        initialRoute: '/',
        routes: {
          '/': (ctx) => const SplashScreen(),
          '/home': (ctx) => const HomeScreen(),
          '/alert-creation': (ctx) => const AlertCreationScreen(),
          '/mesh-relay': (ctx) => const MeshRelayScreen(),
          '/connectivity-restored': (ctx) => const ConnectivityRestoredScreen(),
          '/alert-delivered': (ctx) => const AlertDeliveredScreen(),
          '/contacts': (ctx) => const ContactsScreen(),
          '/history': (ctx) => const HistoryScreen(),
          '/about': (ctx) => const AboutScreen(),
          '/ai-assistant': (ctx) => const AiAssistantScreen(),
          '/features': (ctx) => const FeaturesScreen(),
          '/trusted-messages': (ctx) => const TrustedMessagingScreen(),
        },
      ),
    );
  }
}
