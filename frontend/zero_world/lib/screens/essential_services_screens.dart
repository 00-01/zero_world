import 'package:flutter/material.dart';

/// Food delivery screen - order from restaurants, groceries, etc.
class FoodDeliveryScreen extends StatelessWidget {
  const FoodDeliveryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food & Delivery'),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(icon: const Icon(Icons.shopping_cart), onPressed: () {}),
        ],
      ),
      body: ListView(
        children: [
          _buildAddressBar(context),
          _buildQuickCategories(context),
          _buildSection(context, 'Featured Restaurants'),
          _buildSection(context, 'Popular Near You'),
          _buildSection(context, 'Groceries'),
          _buildSection(context, 'Fast Food'),
        ],
      ),
    );
  }

  Widget _buildAddressBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.blue.shade50,
      child: Row(
        children: [
          const Icon(Icons.location_on, color: Colors.red),
          const SizedBox(width: 8),
          const Expanded(
            child: Text('Delivery to: Home - 123 Main St', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          TextButton(onPressed: () {}, child: const Text('Change')),
        ],
      ),
    );
  }

  Widget _buildQuickCategories(BuildContext context) {
    final categories = [
      {'name': 'Restaurants', 'icon': Icons.restaurant},
      {'name': 'Groceries', 'icon': Icons.shopping_basket},
      {'name': 'Fast Food', 'icon': Icons.fastfood},
      {'name': 'Desserts', 'icon': Icons.cake},
      {'name': 'Coffee', 'icon': Icons.coffee},
    ];

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              CircleAvatar(
                radius: 30,
                child: Icon(categories[index]['icon'] as IconData),
              ),
              const SizedBox(height: 4),
              Text(categories[index]['name'] as String, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 5,
            itemBuilder: (context, index) => _buildRestaurantCard(context),
          ),
        ),
      ],
    );
  }

  Widget _buildRestaurantCard(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Container(
        width: 200,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 120,
              color: Colors.grey[300],
              child: Stack(
                children: [
                  const Center(child: Icon(Icons.restaurant, size: 50)),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text('30 min', style: TextStyle(color: Colors.white, fontSize: 12)),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Restaurant Name', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('Italian, Pizza, Pasta', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  SizedBox(height: 4),
                  Text('⭐ 4.5 • \$\$ • 2.3 km', style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Transportation screen - ride sharing, taxis, bikes, etc.
class TransportationScreen extends StatelessWidget {
  const TransportationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transportation')),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.grey[300],
              child: const Center(
                child: Text('Map View', style: TextStyle(fontSize: 24)),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildLocationInput(Icons.circle, 'Pick-up location', Colors.green),
                  const SizedBox(height: 8),
                  _buildLocationInput(Icons.location_on, 'Drop-off location', Colors.red),
                  const SizedBox(height: 16),
                  _buildRideOptions(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationInput(IconData icon, String hint, Color color) {
    return Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText: hint,
              border: const OutlineInputBorder(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRideOptions(BuildContext context) {
    final options = [
      {'name': 'Economy', 'time': '3 min', 'price': '\$8'},
      {'name': 'Comfort', 'time': '5 min', 'price': '\$12'},
      {'name': 'Premium', 'time': '7 min', 'price': '\$18'},
    ];

    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: options.length,
        itemBuilder: (context, index) => Card(
          child: Container(
            width: 120,
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(options[index]['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(options[index]['time']!, style: const TextStyle(fontSize: 12)),
                Text(options[index]['price']!, style: const TextStyle(color: Colors.green)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Healthcare screen - doctors, appointments, pharmacies
class HealthcareScreen extends StatelessWidget {
  const HealthcareScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Healthcare')),
      body: ListView(
        children: [
          _buildQuickActions(context),
          _buildSection(context, 'Find Doctors', Icons.local_hospital),
          _buildSection(context, 'Book Lab Tests', Icons.science),
          _buildSection(context, 'Order Medicines', Icons.local_pharmacy),
          _buildSection(context, 'Mental Health', Icons.psychology),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      {'name': 'Consult Now', 'icon': Icons.video_call, 'color': Colors.blue},
      {'name': 'Appointments', 'icon': Icons.calendar_today, 'color': Colors.green},
      {'name': 'Records', 'icon': Icons.folder, 'color': Colors.orange},
      {'name': 'Emergency', 'icon': Icons.emergency, 'color': Colors.red},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) => Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: (actions[index]['color'] as Color).withOpacity(0.1),
            child: Icon(actions[index]['icon'] as IconData, color: actions[index]['color'] as Color),
          ),
          const SizedBox(height: 4),
          Text(actions[index]['name'] as String, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon),
              const SizedBox(width: 8),
              Text(title, style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
        ),
        SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 5,
            itemBuilder: (context, index) => Card(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              child: Container(
                width: 150,
                padding: const EdgeInsets.all(8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    CircleAvatar(radius: 30, child: Icon(Icons.person)),
                    SizedBox(height: 8),
                    Text('Dr. Smith', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('Cardiologist', style: TextStyle(fontSize: 12)),
                    Text('⭐ 4.8 (200)', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Finance screen - banking, payments, investments
class FinanceScreen extends StatelessWidget {
  const FinanceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Finance')),
      body: ListView(
        children: [
          _buildBalanceCard(context),
          _buildQuickActions(context),
          _buildTransactionHistory(context),
          _buildInvestmentSection(context),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      color: Colors.blue,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Total Balance', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 8),
            const Text('\$12,345.67', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                _BalanceStat(label: 'Income', value: '+\$5,000'),
                _BalanceStat(label: 'Expenses', value: '-\$2,500'),
                _BalanceStat(label: 'Savings', value: '\$8,000'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      {'name': 'Transfer', 'icon': Icons.send},
      {'name': 'Pay Bills', 'icon': Icons.receipt},
      {'name': 'Top Up', 'icon': Icons.add_circle},
      {'name': 'Scan QR', 'icon': Icons.qr_code_scanner},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: actions
            .map((action) => Column(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      child: Icon(action['icon'] as IconData),
                    ),
                    const SizedBox(height: 4),
                    Text(action['name'] as String, style: const TextStyle(fontSize: 12)),
                  ],
                ))
            .toList(),
      ),
    );
  }

  Widget _buildTransactionHistory(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('Recent Transactions', style: Theme.of(context).textTheme.titleLarge),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 5,
          itemBuilder: (context, index) => ListTile(
            leading: const CircleAvatar(child: Icon(Icons.shopping_bag)),
            title: const Text('Transaction Name'),
            subtitle: const Text('Today, 12:30 PM'),
            trailing: const Text('-\$25.00', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildInvestmentSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('Investments', style: Theme.of(context).textTheme.titleLarge),
        ),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 5,
            itemBuilder: (context, index) => Card(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              child: Container(
                width: 150,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('AAPL', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('Apple Inc.', style: TextStyle(fontSize: 12)),
                    Spacer(),
                    Text('\$150.25', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('+2.5%', style: TextStyle(color: Colors.green, fontSize: 12)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BalanceStat extends StatelessWidget {
  final String label;
  final String value;

  const _BalanceStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
