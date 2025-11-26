import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:developer' as developer;
import 'config/environment/app_config.dart';
import 'config/environment/env.dart';
import 'config/theme/app_theme.dart';
import 'routing/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await dotenv.load(fileName: '.env.development');
    developer.log('Loaded .env.development', name: 'Main');
  } catch (e) {
    developer.log(
      'Warning: Could not load .env.development',
      name: 'Main',
      error: e,
    );
  }
  
  // Validate API keys
  _validateConfiguration();
  
  final config = AppConfig.development;
  
  runApp(
    ProviderScope(
      child: TravelApp(config: config),
    ),
  );
}

void _validateConfiguration() {
  final geminiKey = Env.geminiApiKey;
  final mapboxToken = Env.mapboxAccessToken;
  
  if (geminiKey.isEmpty) {
    developer.log(
      '⚠️ GEMINI_API_KEY no está configurada',
      name: 'Main',
      level: 900, // Warning level
    );
  } else {
    developer.log(
      '✅ GEMINI_API_KEY configurada (${geminiKey.length} caracteres)',
      name: 'Main',
    );
  }
  
  if (mapboxToken.isEmpty) {
    developer.log(
      '⚠️ MAPBOX_ACCESS_TOKEN no está configurada',
      name: 'Main',
      level: 900,
    );
  } else {
    developer.log(
      '✅ MAPBOX_ACCESS_TOKEN configurada (${mapboxToken.length} caracteres)',
      name: 'Main',
    );
  }
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


