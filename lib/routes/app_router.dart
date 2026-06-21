import 'package:go_router/go_router.dart';
import '../screens/auth/start_page.dart';
import '../screens/auth/sms_page.dart';
import '../screens/home/home_page.dart';
import '../screens/home/fill_profile_page.dart';
import '../screens/trips/my_trips_page.dart';
import '../screens/trips/trip_page.dart';
import '../screens/trips/create_trip_page.dart';
import '../screens/trips/search_trip_page.dart';
import '../screens/cars/add_car_page.dart';
import '../screens/cars/select_mark_widget.dart';
import '../screens/cars/select_model_widget.dart';
import '../screens/city/city_search_page.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/start',
    routes: [
      // Auth Routes
      GoRoute(
        path: '/start',
        builder: (context, state) => const StartPage(),
      ),
      GoRoute(
        path: '/sms',
        builder: (context, state) => const SMSPage(),
      ),
      
      // Home Routes
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const FillProfilePage(),
      ),
      
      // Trips Routes
      GoRoute(
        path: '/my-trips',
        builder: (context, state) => const MyTripsPage(),
      ),
      GoRoute(
        path: '/trip/:id',
        builder: (context, state) {
          final tripId = state.pathParameters['id']!;
          return TripPage(tripId: tripId);
        },
      ),
      GoRoute(
        path: '/create-trip',
        builder: (context, state) => const CreateTripPage(),
      ),
      GoRoute(
        path: '/search-trip',
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>?;
          return SearchTripPage(
            from: args?['from']?.toString() ?? '',
            to: args?['to']?.toString() ?? '',
          );
        },
      ),
      
      // Cars Routes
      GoRoute(
        path: '/add-car',
        builder: (context, state) => const AddCarPage(),
      ),
      GoRoute(
        path: '/select-mark',
        builder: (context, state) => const SelectMarkWidget(),
      ),
      GoRoute(
        path: '/select-model',
        builder: (context, state) => const SelectModelWidget(),
      ),
      
      // City Routes
      GoRoute(
        path: '/city-search',
        builder: (context, state) => const CitySearchPage(),
      ),
    ],
  );
}
