import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/main_navigation_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'services/api_service.dart';
import 'services/ai_service.dart';
import 'state/auth_state.dart';
import 'state/auth_provider.dart';
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
        Provider<AIService>(
          create: (_) => AIService(),
          dispose: (_, service) {
            service.dispose();
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
      child: Consumer2<AppThemeManager, AuthProvider>(
        builder: (context, themeManager, authProvider, child) {
          return MaterialApp(
            title: 'Zero World - AI Assistant',
            theme: themeManager.getLightTheme(),
            darkTheme: themeManager.getDarkTheme(),
            themeMode: themeManager.themeMode,
            home: authProvider.isAuthenticated
                ? const MainNavigationScreen()
                : const LoginScreen(),
            routes: {
              '/login': (context) => const LoginScreen(),
              '/signup': (context) => const SignupScreen(),
              '/home': (context) => const MainNavigationScreen(),
            },
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }

  static AuthState _defaultAuthBuilder(ApiService api) => AuthState(api);

  static ListingsState _defaultListingsBuilder(ApiService api) => ListingsState(api);
}
