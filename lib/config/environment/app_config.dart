import 'flavor.dart';

class AppConfig {
  final Flavor flavor;
  final String appName;
  final Duration apiTimeout;
  final bool enableLogging;
  final bool enableCrashReporting;

  const AppConfig({
    required this.flavor,
    required this.appName,
    required this.apiTimeout,
    required this.enableLogging,
    required this.enableCrashReporting,
  });

  static AppConfig get development => const AppConfig(
        flavor: Flavor.development,
        appName: 'Travel AI Planner (Dev)',
        apiTimeout: Duration(seconds: 30),
        enableLogging: true,
        enableCrashReporting: false,
      );

  static AppConfig get staging => const AppConfig(
        flavor: Flavor.staging,
        appName: 'Travel AI Planner (Staging)',
        apiTimeout: Duration(seconds: 20),
        enableLogging: true,
        enableCrashReporting: true,
      );

  static AppConfig get production => const AppConfig(
        flavor: Flavor.production,
        appName: 'Travel AI Planner',
        apiTimeout: Duration(seconds: 15),
        enableLogging: false,
        enableCrashReporting: true,
      );
}


