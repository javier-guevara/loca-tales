import 'package:go_router/go_router.dart';
import '../ui/home/widgets/home_screen.dart';
import '../ui/chat/widgets/chat_screen.dart';
import '../ui/map/widgets/map_screen.dart';
import '../ui/plan_detail/widgets/plan_detail_screen.dart';
import '../domain/models/travel_plan.dart';
import '../domain/models/place.dart';
import 'route_names.dart';

final appRouter = GoRouter(
  initialLocation: RouteNames.home,
  routes: [
    GoRoute(
      path: RouteNames.home,
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: RouteNames.chat,
      name: 'chat',
      builder: (context, state) {
        final initialMessage = state.extra as String?;
        return ChatScreen(initialMessage: initialMessage);
      },
    ),
    GoRoute(
      path: RouteNames.map,
      name: 'map',
      builder: (context, state) {
        // Accept either TravelPlan or Map with plan and focusedPlace
        final extra = state.extra;
        if (extra is Map<String, dynamic>) {
          return MapScreen(
            travelPlan: extra['plan'] as TravelPlan?,
            focusedPlace: extra['focusedPlace'] as Place?,
          );
        }
        return MapScreen(travelPlan: extra as TravelPlan?);
      },
    ),
    GoRoute(
      path: RouteNames.planDetail,
      name: 'plan-detail',
      builder: (context, state) {
        final travelPlan = state.extra as TravelPlan;
        return PlanDetailScreen(travelPlan: travelPlan);
      },
    ),
  ],
);


