import 'package:flutter/material.dart';

class BookingHomeScreen extends StatefulWidget {
  const BookingHomeScreen({super.key});

  @override
  State<BookingHomeScreen> createState() => _BookingHomeScreenState();
}

class _BookingHomeScreenState extends State<BookingHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Booking & Services'),
          backgroundColor: Colors.purple,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            isScrollable: true,
            tabs: [
              Tab(icon: Icon(Icons.hotel), text: 'Hotels'),
              Tab(icon: Icon(Icons.spa), text: 'Beauty'),
              Tab(icon: Icon(Icons.build), text: 'Home Services'),
              Tab(icon: Icon(Icons.history), text: 'My Bookings'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildHotelsTab(),
            _buildBeautyTab(),
            _buildHomeServicesTab(),
            _buildMyBookingsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildHotelsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.red),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            hintText: 'Where are you going?',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Colors.blue),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text('Check-in: Select date'),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Text('Check-out: Select date'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Featured Hotels',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...List.generate(3, (index) => _buildHotelCard(index)),
        ],
      ),
    );
  }

  Widget _buildBeautyTab() {
    return GridView.count(
      crossAxisCount: 2,
      padding: const EdgeInsets.all(16),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _buildServiceCard('Hair Salon', Icons.content_cut, Colors.pink),
        _buildServiceCard('Nail Art', Icons.fingerprint, Colors.purple),
        _buildServiceCard('Spa & Massage', Icons.spa, Colors.teal),
        _buildServiceCard('Facial Treatment', Icons.face, Colors.orange),
        _buildServiceCard('Makeup', Icons.face_retouching_natural, Colors.red),
        _buildServiceCard('Eyebrow Threading', Icons.visibility, Colors.brown),
      ],
    );
  }

  Widget _buildHomeServicesTab() {
    return GridView.count(
      crossAxisCount: 2,
      padding: const EdgeInsets.all(16),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _buildServiceCard('Plumbing', Icons.plumbing, Colors.blue),
        _buildServiceCard('Electrical', Icons.electrical_services, Colors.yellow.shade700),
        _buildServiceCard('Cleaning', Icons.cleaning_services, Colors.green),
        _buildServiceCard('AC Repair', Icons.ac_unit, Colors.cyan),
        _buildServiceCard('Painting', Icons.format_paint, Colors.indigo),
        _buildServiceCard('Carpentry', Icons.carpenter, Colors.brown),
        _buildServiceCard('Pest Control', Icons.bug_report, Colors.red),
        _buildServiceCard('Appliance Repair', Icons.microwave, Colors.grey),
      ],
    );
  }

  Widget _buildMyBookingsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      index % 2 == 0 ? 'Grand Hotel' : 'Hair Salon Appointment',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: index % 3 == 0 ? Colors.green : Colors.orange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        index % 3 == 0 ? 'Confirmed' : 'Pending',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Booking ID: #BK${1000 + index}',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 4),
                Text(
                  'Date: ${DateTime.now().add(Duration(days: index + 1)).toString().split(' ')[0]}',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 4),
                Text(
                  'Amount: \$${(50 + index * 25).toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHotelCard(int index) {
    final hotels = [
      {'name': 'Grand Hotel', 'rating': 4.8, 'price': 120},
      {'name': 'City View Resort', 'rating': 4.5, 'price': 95},
      {'name': 'Luxury Suites', 'rating': 4.9, 'price': 200},
    ];
    
    final hotel = hotels[index];
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: const Center(
              child: Icon(Icons.hotel, size: 50, color: Colors.grey),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hotel['name'] as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text('${hotel['rating']}'),
                    const Spacer(),
                    Text(
                      '\$${hotel['price']}/night',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _bookHotel(hotel['name'] as String),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Book Now'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(String title, IconData icon, Color color) {
    return Card(
      child: InkWell(
        onTap: () => _bookService(title),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => _bookService(title),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 32),
                ),
                child: const Text('Book'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _bookHotel(String hotelName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$hotelName booking coming soon!')),
    );
  }

  void _bookService(String serviceName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$serviceName booking coming soon!')),
    );
  }
}