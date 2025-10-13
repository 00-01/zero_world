import 'package:flutter/material.dart';

class TransportScreen extends StatefulWidget {
  const TransportScreen({super.key});

  @override
  State<TransportScreen> createState() => _TransportScreenState();
}

class _TransportScreenState extends State<TransportScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Transport'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(icon: Icon(Icons.local_taxi), text: 'Ride'),
              Tab(icon: Icon(Icons.local_shipping), text: 'Delivery'),
              Tab(icon: Icon(Icons.history), text: 'History'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildRideTab(),
            _buildDeliveryTab(),
            _buildHistoryTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildRideTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.my_location, color: Colors.green),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            hintText: 'Pickup location',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.red),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            hintText: 'Drop-off location',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              _buildRideOption('Economy', 'Affordable rides', '\$8-12', Icons.directions_car, Colors.blue),
              _buildRideOption('Premium', 'Comfortable rides', '\$12-18', Icons.car_rental, Colors.purple),
              _buildRideOption('XL', 'Large vehicles', '\$15-22', Icons.airport_shuttle, Colors.orange),
              _buildRideOption('Bike', 'Quick & eco', '\$3-6', Icons.motorcycle, Colors.green),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.inventory, color: Colors.blue),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            hintText: 'What are you sending?',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  Row(
                    children: [
                      const Icon(Icons.my_location, color: Colors.green),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            hintText: 'Pickup location',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.red),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            hintText: 'Delivery location',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              _buildDeliveryOption('Documents', 'Papers, contracts', '\$5-8', Icons.description),
              _buildDeliveryOption('Small Package', 'Up to 5kg', '\$8-15', Icons.inventory_2),
              _buildDeliveryOption('Large Package', 'Up to 20kg', '\$15-25', Icons.all_inbox),
              _buildDeliveryOption('Express', 'Same day delivery', '\$20-35', Icons.flash_on),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: index % 2 == 0 ? Colors.blue : Colors.orange,
              child: Icon(
                index % 2 == 0 ? Icons.local_taxi : Icons.local_shipping,
                color: Colors.white,
              ),
            ),
            title: Text(index % 2 == 0 ? 'Ride to Downtown' : 'Package Delivery'),
            subtitle: Text('${DateTime.now().subtract(Duration(days: index + 1)).toString().split(' ')[0]} • \$${(10 + index * 3).toStringAsFixed(2)}'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          ),
        );
      },
    );
  }

  Widget _buildRideOption(String name, String description, String price, IconData icon, Color color) {
    return Card(
      child: InkWell(
        onTap: () => _bookRide(name),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 8),
              Text(
                name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                description,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                price,
                style: TextStyle(color: color, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeliveryOption(String name, String description, String price, IconData icon) {
    return Card(
      child: InkWell(
        onTap: () => _bookDelivery(name),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.orange),
              const SizedBox(height: 8),
              Text(
                name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                description,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                price,
                style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _bookRide(String rideType) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$rideType ride booking coming soon!')),
    );
  }

  void _bookDelivery(String deliveryType) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$deliveryType delivery booking coming soon!')),
    );
  }
}