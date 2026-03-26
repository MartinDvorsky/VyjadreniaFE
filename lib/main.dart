import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vyjadrenia/utils/supabase_config.dart';

import 'package:vyjadrenia/utils/app_theme.dart';
import 'package:vyjadrenia/utils/desktop_window.dart';

import 'providers/theme_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/city_provider.dart';
import 'providers/step2_data_provider.dart';
import 'providers/step3_data_provider.dart';
import 'providers/step4_notifications_provider.dart';
import 'providers/step5_data_provider.dart';
import 'providers/generation_provider.dart';
import 'providers/application_edit_provider.dart';
import 'providers/project_designer_edit_provider.dart';
import 'providers/building_purpose_provider.dart';
import 'providers/city_offices_provider.dart';
import 'providers/office_cities_provider.dart';
import 'providers/ai_usage_provider.dart';
import 'providers/automation_provider.dart';
import 'providers/generate_provider.dart';
import 'providers/designer_team_member_edit_provider.dart';
import 'providers/metrics_provider.dart';
import 'providers/text_type_provider.dart';
import 'providers/ai_chat_provider.dart';

import 'screens/home_screen.dart';
import 'screens/login_screen.dart';

import 'package:auto_updater/auto_updater.dart';

Future<void> main() async {



  WidgetsFlutterBinding.ensureInitialized();





  // Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Supabase (nech to nezabije appku, ak init spadne)
  try {
    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      anonKey: SupabaseConfig.supabaseAnonKey,
    );
  } catch (e) {
    debugPrint('❌ Supabase init error: $e');
  }

  if (!kIsWeb) {  // PRIDAJ TENTO IF
    await setupDesktopWindow();
  }

  // Dôležité: spustiť appku vždy (web aj desktop)
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(),
          lazy: false,
        ),
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(),
          lazy: false,
        ),
        ChangeNotifierProvider<CityProvider>(
          create: (_) => CityProvider(),
          lazy: false,
        ),
        ChangeNotifierProvider<Step2DataProvider>(
          create: (_) => Step2DataProvider(),
          lazy: false,
        ),
        ChangeNotifierProvider<Step3DataProvider>(
          create: (_) => Step3DataProvider(),
          lazy: false,
        ),
        ChangeNotifierProvider<Step4NotificationsProvider>(
          create: (_) => Step4NotificationsProvider(),
          lazy: false,
        ),
        ChangeNotifierProvider<Step5DataProvider>(
          create: (_) => Step5DataProvider(),
          lazy: false,
        ),
        ChangeNotifierProvider<GenerationProvider>(
          create: (_) => GenerationProvider(),
          lazy: false,
        ),
        ChangeNotifierProvider<ApplicationEditProvider>(
          create: (_) => ApplicationEditProvider(),
          lazy: false,
        ),
        ChangeNotifierProvider<ProjectDesignerEditProvider>(
          create: (_) => ProjectDesignerEditProvider(),
          lazy: false,
        ),
        ChangeNotifierProvider<BuildingPurposeProvider>(
          create: (_) => BuildingPurposeProvider(),
          lazy: false,
        ),
        ChangeNotifierProvider<CityOfficesProvider>(
          create: (_) => CityOfficesProvider(),
          lazy: false,
        ),
        ChangeNotifierProvider<OfficeCitiesProvider>(
          create: (_) => OfficeCitiesProvider(),
          lazy: false,
        ),
        ChangeNotifierProvider<AIUsageProvider>(
          create: (_) => AIUsageProvider(),
          lazy: false,
        ),
        ChangeNotifierProvider<AutomationProvider>(
          create: (_) => AutomationProvider(),
          lazy: false,
        ),
        ChangeNotifierProvider<DesignerTeamMemberEditProvider>(
          create: (_) => DesignerTeamMemberEditProvider(),
          lazy: false,
        ),
        ChangeNotifierProvider<MetricsProvider>(
          create: (_) => MetricsProvider(),
          lazy: false,
        ),
        ChangeNotifierProvider<TextTypeProvider>(
          create: (_) => TextTypeProvider(),
          lazy: false,
        ),
        ChangeNotifierProvider<AiChatProvider>(
          create: (_) => AiChatProvider(),
          lazy: false,
        ),

        // Proxy provider (ako si to mal)
        ChangeNotifierProxyProvider<CityProvider, GenerateProvider>(
          create: (context) => GenerateProvider(
            cityProvider: context.read<CityProvider>(),
          ),
          update: (context, cityProvider, previous) =>
          previous ?? GenerateProvider(cityProvider: cityProvider),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Vyjadrenia',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const AuthWrapper(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Auth check
      context.read<AuthProvider>().checkAuthStatus();


      if (!kIsWeb) {
        String feedURL = 'https://raw.githubusercontent.com/MartinDvorsky/VyjadreniaFE/main/appcast.xml';

        await autoUpdater.setFeedURL(feedURL);
        await autoUpdater.checkForUpdates(inBackground: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isAuthenticated) {
          return const HomeScreen();
        }
        return const LoginScreen();
      },
    );
  }
}
