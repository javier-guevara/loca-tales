import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'config/environment/app_config.dart';
import 'config/theme/app_theme.dart';
import 'routing/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await dotenv.load(fileName: '.env.staging');
  } catch (e) {
    print('Warning: Could not load .env.staging: $e');
  }
  
  final config = AppConfig.staging;
  
  runApp(
    ProviderScope(
      child: TravelApp(config: config),
    ),
  );
}

class TravelApp extends StatelessWidget {
  final AppConfig config;

  const TravelApp({
    super.key,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: config.appName,
      debugShowCheckedModeBanner: !config.enableCrashReporting,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: appRouter,
    );
  }
}


