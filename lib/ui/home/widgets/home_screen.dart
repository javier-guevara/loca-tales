import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import '../../../routing/route_names.dart';
import '../../../data/providers/providers.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String? _userCity;
  String? _userCountry;
  bool _isLoadingLocation = true;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    try {
      final locationService = ref.read(locationServiceProvider);
      final location = await locationService.getCurrentLocation();
      
      if (location != null && mounted) {
        // Reverse geocoding to get city name
        // For now, we'll use hardcoded values based on coordinates
        // In production, you'd use Mapbox Geocoding API
        final city = _getCityFromCoordinates(location.latitude, location.longitude);
        setState(() {
          _userCity = city['city'];
          _userCountry = city['country'];
          _isLoadingLocation = false;
        });
      } else {
        setState(() {
          _isLoadingLocation = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  Map<String, String> _getCityFromCoordinates(double lat, double lon) {
    // Colombia region
    if (lat >= 4 && lat <= 13 && lon >= -80 && lon <= -66) {
      if (lat >= 10.3 && lat <= 11.2 && lon >= -75.6 && lon <= -74.7) {
        return {'city': 'Barranquilla', 'country': 'Colombia'};
      } else if (lat >= 10.3 && lat <= 10.5 && lon >= -75.6 && lon <= -75.4) {
        return {'city': 'Cartagena', 'country': 'Colombia'};
      } else if (lat >= 4.5 && lat <= 4.8 && lon >= -74.2 && lon <= -74.0) {
        return {'city': 'Bogotá', 'country': 'Colombia'};
      }
      return {'city': 'Colombia', 'country': 'Colombia'};
    }
    
    // Default
    return {'city': 'tu ciudad', 'country': 'tu país'};
  }

  List<Map<String, String>> _getLocationBasedSuggestions() {
    if (_userCity == null) {
      return [
        {'emoji': '🏖️', 'text': '3 días en Cartagena'},
        {'emoji': '🏔️', 'text': 'Fin de semana en Bogotá'},
        {'emoji': '🌴', 'text': '5 días en Santa Marta'},
        {'emoji': '🎭', 'text': 'Tour cultural en Medellín'},
      ];
    }

    // Suggestions based on user's city
    if (_userCity == 'Barranquilla' || _userCity == 'Cartagena') {
      return [
        {'emoji': '🏖️', 'text': '3 días en Cartagena'},
        {'emoji': '🌴', 'text': 'Fin de semana en Santa Marta'},
        {'emoji': '🏝️', 'text': '5 días en San Andrés'},
        {'emoji': '🏔️', 'text': 'Escapada a Villa de Leyva'},
      ];
    } else if (_userCity == 'Bogotá') {
      return [
        {'emoji': '🏔️', 'text': 'Fin de semana en Villa de Leyva'},
        {'emoji': '🏖️', 'text': '5 días en Cartagena'},
        {'emoji': '🌄', 'text': 'Tour del Eje Cafetero'},
        {'emoji': '🎭', 'text': '3 días en Medellín'},
      ];
    }

    // Default suggestions
    return [
      {'emoji': '🏖️', 'text': '3 días en Cartagena'},
      {'emoji': '🏔️', 'text': 'Fin de semana en Bogotá'},
      {'emoji': '🌴', 'text': '5 días en Santa Marta'},
      {'emoji': '🎭', 'text': 'Tour cultural en Medellín'},
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final suggestions = _getLocationBasedSuggestions();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primaryContainer,
              theme.colorScheme.secondaryContainer,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '✈️ LocaTales',
                      style: theme.textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isLoadingLocation
                          ? 'Cargando ubicación...'
                          : _userCity != null
                              ? 'Hola desde $_userCity, $_userCountry 👋'
                              : 'Tu asistente de viajes con IA',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),

              // Main Content
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(32),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Welcome Card
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                theme.colorScheme.primary,
                                theme.colorScheme.tertiary,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: theme.colorScheme.primary.withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '¿A dónde quieres ir?',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  color: theme.colorScheme.onPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Cuéntame tus planes y crearé el itinerario perfecto para ti',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: theme.colorScheme.onPrimary.withOpacity(0.9),
                                ),
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    context.push(RouteNames.chat);
                                  },
                                  icon: const Icon(Icons.chat_bubble_outline),
                                  label: const Text('Planear mi viaje'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: theme.colorScheme.surface,
                                    foregroundColor: theme.colorScheme.primary,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Suggestions Section
                        Text(
                          _userCity != null
                              ? 'Destinos recomendados cerca de ti'
                              : 'Ideas para tu próximo viaje',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Suggestion Cards
                        ...suggestions.map((suggestion) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: InkWell(
                            onTap: () {
                              context.push(
                                RouteNames.chat,
                                extra: suggestion['text'],
                              );
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: theme.colorScheme.outline.withOpacity(0.2),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primaryContainer,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      suggestion['emoji']!,
                                      style: const TextStyle(fontSize: 24),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      suggestion['text']!,
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


