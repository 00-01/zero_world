import 'package:flutter/material.dart';

import 'account/account_tab.dart';
import 'chat/chat_tab.dart';
import 'listings/listings_tab.dart';
import 'services/services_screen.dart';
import 'social/social_feed_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Use LayoutBuilder to adapt to screen size
    return LayoutBuilder(
      builder: (context, constraints) {
        // Desktop/tablet layout (wider screens)
        if (constraints.maxWidth >= 600) {
          return _buildDesktopLayout(context);
        }
        // Mobile layout (narrow screens)
        return _buildMobileLayout(context);
      },
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Image.asset(
                'assets/images/zn_logo.png',
                height: 32,
                width: 32,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.public, color: Colors.blue);
                },
              ),
              const SizedBox(width: 12),
              const Text('Zero World'),
            ],
          ),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(icon: Icon(Icons.home), text: 'Services'),
              Tab(icon: Icon(Icons.storefront), text: 'Marketplace'),
              Tab(icon: Icon(Icons.chat_bubble_outline), text: 'Chats'),
              Tab(icon: Icon(Icons.people_alt_outlined), text: 'Community'),
              Tab(icon: Icon(Icons.person_outline), text: 'Account'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            ServicesScreen(),
            ListingsTab(),
            ChatTab(),
            EnhancedSocialFeedScreen(),
            AccountTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Image.asset(
                'assets/images/zn_logo.png',
                height: 40,
                width: 40,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.public, color: Colors.blue, size: 40);
                },
              ),
              const SizedBox(width: 16),
              const Text('Zero World - Cross-Platform Super App'),
            ],
          ),
          centerTitle: false,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: Container(
              alignment: Alignment.center,
              child: const TabBar(
                isScrollable: false,
                tabAlignment: TabAlignment.center,
                tabs: [
                  Tab(icon: Icon(Icons.home), text: 'Services'),
                  Tab(icon: Icon(Icons.storefront), text: 'Marketplace'),
                  Tab(icon: Icon(Icons.chat_bubble_outline), text: 'Chats'),
                  Tab(icon: Icon(Icons.people_alt_outlined), text: 'Community'),
                  Tab(icon: Icon(Icons.person_outline), text: 'Account'),
                ],
              ),
            ),
          ),
        ),
        body: const TabBarView(
          children: [
            ServicesScreen(),
            ListingsTab(),
            ChatTab(),
            EnhancedSocialFeedScreen(),
            AccountTab(),
          ],
        ),
      ),
    );
  }
}
