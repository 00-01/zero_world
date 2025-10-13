import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/home_screen.dart';
import 'services/api_service.dart';
import 'state/auth_state.dart';
import 'state/listings_state.dart';

typedef AuthStateBuilder = AuthState Function(ApiService apiService);
typedef ListingsStateBuilder = ListingsState Function(ApiService apiService);

class ZeroWorldApp extends StatelessWidget {
  const ZeroWorldApp({
    super.key,
    this.apiService,
    this.authStateBuilder,
    this.listingsStateBuilder,
  });

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
      ],
      child: MaterialApp(
        title: 'Zero World - Cross-Platform Super App',
        theme: ThemeData(
          colorSchemeSeed: Colors.blue,
          brightness: Brightness.light,
          useMaterial3: true,
          // Responsive typography
          textTheme: const TextTheme(
            displayLarge: TextStyle(fontSize: 57, fontWeight: FontWeight.bold),
            displayMedium: TextStyle(fontSize: 45, fontWeight: FontWeight.bold),
            displaySmall: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
            headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
            bodyLarge: TextStyle(fontSize: 16),
            bodyMedium: TextStyle(fontSize: 14),
          ),
          // Adaptive platform behavior
          platform: TargetPlatform.android, // Will adapt based on device
        ),
        darkTheme: ThemeData(
          colorSchemeSeed: Colors.blue,
          brightness: Brightness.dark,
          useMaterial3: true,
        ),
        themeMode: ThemeMode.system, // Respects system theme preference
        home: const HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }

  static AuthState _defaultAuthBuilder(ApiService api) => AuthState(api);

  static ListingsState _defaultListingsBuilder(ApiService api) => ListingsState(api);
}
