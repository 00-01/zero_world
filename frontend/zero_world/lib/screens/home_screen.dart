import 'package:flutter/material.dart';
import 'air_interface.dart';
import 'main_chat_screen.dart';

/// Home Screen - Combines traditional chat with Air Interface
///
/// Architecture:
/// - Background: Traditional chat interface (backward compatibility)
/// - Overlay: Air Interface (breathing UI) - can be summoned anytime
/// - Transition: Gradually shift users from chat to air interface
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showAirInterface = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _summonAir() {
    setState(() {
      _showAirInterface = true;
    });
  }

  void _dismissAir() {
    setState(() {
      _showAirInterface = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Stack(
        children: [
          // Background: Traditional chat interface
          const MainChatScreen(),

          // Overlay: Air Interface (breathing UI)
          if (_showAirInterface) GestureDetector(onTap: _dismissAir, child: const AirInterface()),

          // Floating action button to summon air interface
          if (!_showAirInterface)
            Positioned(
              bottom: 24,
              right: 24,
              child: FloatingActionButton.extended(
                onPressed: _summonAir,
                backgroundColor: const Color(0xFF00CED1),
                icon: const Icon(Icons.air, color: Colors.white),
                label: const Text(
                  'Cmd+Space',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w300),
                ),
                elevation: 8,
                heroTag: 'air_summon',
              ),
            ),
        ],
      ),
    );
  }
}
