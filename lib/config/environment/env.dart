import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static String get mapboxAccessToken => dotenv.env['MAPBOX_ACCESS_TOKEN'] ?? '';
  static String get geminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
  static String get apiBaseUrl => dotenv.env['API_BASE_URL'] ?? '';
  
  static bool get isDevelopment => dotenv.env['ENVIRONMENT'] == 'development';
  static bool get isStaging => dotenv.env['ENVIRONMENT'] == 'staging';
  static bool get isProduction => dotenv.env['ENVIRONMENT'] == 'production';
}


