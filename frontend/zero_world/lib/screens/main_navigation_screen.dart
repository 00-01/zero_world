import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'concierge_screen.dart';
import 'air_interface.dart';

/// Main Navigation Screen
/// Bottom navigation bar with different sections
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  bool _showAirInterface = false;

  final List<Widget> _screens = [
    const HomeScreen(),
    const ConciergeScreen(),
    const PlaceholderScreen(title: 'Orders'),
    const PlaceholderScreen(title: 'Community'),
    const PlaceholderScreen(title: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main content
          IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),

          // Air Interface overlay
          if (_showAirInterface)
            AirInterface(
              onDismiss: () {
                setState(() {
                  _showAirInterface = false;
                });
              },
            ),

          // Floating Air button
          if (!_showAirInterface)
            Positioned(
              bottom: 80,
              right: 24,
              child: FloatingActionButton(
                onPressed: () {
                  setState(() {
                    _showAirInterface = true;
                  });
                },
                backgroundColor: const Color(0xFF1A1A1A),
                child: const Icon(
                  Icons.air,
                  color: Color(0xFFFFFFFF),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Color(0xFF1A1A1A),
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: const Color(0xFF000000),
          selectedItemColor: const Color(0xFFFFFFFF),
          unselectedItemColor: const Color(0xFF666666),
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline),
              activeIcon: Icon(Icons.chat_bubble),
              label: 'AI Concierge',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long),
              label: 'Orders',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_outline),
              activeIcon: Icon(Icons.people),
              label: 'Community',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

/// Placeholder screen for sections not yet implemented
class PlaceholderScreen extends StatelessWidget {
  final String title;

  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      appBar: AppBar(
        backgroundColor: const Color(0xFF000000),
        elevation: 0,
        title: Text(
          title,
          style: const TextStyle(
            color: Color(0xFFFFFFFF),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getIcon(),
              size: 64,
              color: const Color(0xFF333333),
            ),
            const SizedBox(height: 24),
            Text(
              '$title Coming Soon',
              style: const TextStyle(
                color: Color(0xFFFFFFFF),
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'This feature is under development',
              style: TextStyle(
                color: Color(0xFF999999),
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIcon() {
    switch (title.toLowerCase()) {
      case 'orders':
        return Icons.receipt_long;
      case 'community':
        return Icons.people;
      case 'profile':
        return Icons.person;
      default:
        return Icons.construction;
    }
  }
}
