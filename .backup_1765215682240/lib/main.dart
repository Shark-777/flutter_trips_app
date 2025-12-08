import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/trips_provider.dart';
import 'providers/cars_provider.dart';
import 'routes/app_router.dart';
import 'theme/app_theme.dart';
import 'services/editor_bridge_service.dart';
import 'widgets/inspector_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  EditorBridgeService.init(AppRouter.router);
  runApp(const TripsApp());
}

class TripsApp extends StatelessWidget {
  const TripsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TripsProvider()),
        ChangeNotifierProvider(create: (_) => CarsProvider()),
      ],
      child: MaterialApp.router(
        title: 'Trips App',
        theme: AppTheme.lightTheme,
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,
        builder: (context, child) {
          // InspectorWrapper внутри MaterialApp для доступа к Directionality
          return InspectorWrapper(child: child ?? const SizedBox());
        },
      ),
    );
  }
}
