import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'services/concierge_service.dart';
import 'state/conversation_provider.dart';
import 'state/auth_provider.dart';

void main() async {
  // Enable transparent status bar (invisible UI)
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarColor: Colors.transparent, systemNavigationBarColor: Colors.transparent));

  // Initialize auth provider
  final authProvider = AuthProvider();
  await authProvider.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ProxyProvider<AuthProvider, ConciergeService>(
          update: (_, auth, __) => ConciergeService(
            baseUrl: 'http://localhost:8000',  // TODO: Use environment config
            authToken: auth.accessToken,
          ),
        ),
        ProxyProvider<ConciergeService, ConversationProvider>(
          update: (_, service, __) => ConversationProvider(service),
        ),
      ],
      child: const ZeroWorldApp(),
    ),
  );
}
