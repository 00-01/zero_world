import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/super_app_home.dart';
import 'screens/essential_services_screens.dart';
import 'screens/customization_screen.dart';
import 'screens/additional_services_screens.dart';
import 'screens/more_services_screens.dart';
import 'screens/messages_screen.dart';
import 'screens/chat_screen.dart';
import 'services/api_service.dart';
import 'state/auth_state.dart';
import 'state/listings_state.dart';
import 'state/theme_manager.dart';

typedef AuthStateBuilder = AuthState Function(ApiService apiService);
typedef ListingsStateBuilder = ListingsState Function(ApiService apiService);

class ZeroWorldApp extends StatelessWidget {
  const ZeroWorldApp({super.key, this.apiService, this.authStateBuilder, this.listingsStateBuilder});

  final ApiService? apiService;
  final AuthStateBuilder? authStateBuilder;
  final ListingsStateBuilder? listingsStateBuilder;

  @override
  Widget build(BuildContext context) {
    final ownsApiService = apiService == null;

    return MultiProvider(
      providers: [
        Provider<ApiService>(
          create: (_) => apiService ?? ApiService(),
          dispose: (_, service) {
            if (ownsApiService) {
              service.dispose();
            }
          },
        ),
        ChangeNotifierProvider<AuthState>(
          create: (context) {
            final service = context.read<ApiService>();
            final builder = authStateBuilder ?? _defaultAuthBuilder;
            return builder(service);
          },
        ),
        ChangeNotifierProvider<ListingsState>(
          create: (context) {
            final service = context.read<ApiService>();
            final builder = listingsStateBuilder ?? _defaultListingsBuilder;
            return builder(service);
          },
        ),
        ChangeNotifierProvider<AppThemeManager>(create: (_) => AppThemeManager()),
      ],
      child: Consumer<AppThemeManager>(
        builder: (context, themeManager, child) {
          return MaterialApp(
            title: 'Zero World - Super App',
            theme: themeManager.getLightTheme(),
            darkTheme: themeManager.getDarkTheme(),
            themeMode: themeManager.themeMode,
            home: const SuperAppHome(),
            debugShowCheckedModeBanner: false,
            // Route definitions for all super app features
            routes: {
              '/food': (context) => const FoodDeliveryScreen(),
              '/transport': (context) => const TransportationScreen(),
              '/health': (context) => const HealthcareScreen(),
              '/finance': (context) => const FinanceScreen(),
              '/customize': (context) => const CustomizationScreen(),
              '/education': (context) => const EducationScreen(),
              '/travel': (context) => const TravelScreen(),
              '/home-services': (context) => const HomeServicesScreen(),
              '/beauty': (context) => const BeautyWellnessScreen(),
              '/entertainment': (context) => const EntertainmentScreen(),
              '/messages': (context) => const MessagesScreen(),
            },
          );
        },
      ),
    );
  }

  static AuthState _defaultAuthBuilder(ApiService api) => AuthState(api);

  static ListingsState _defaultListingsBuilder(ApiService api) => ListingsState(api);
}
