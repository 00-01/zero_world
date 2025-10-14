import 'package:flutter/material.dart';

// ============================================================================
// HOME SERVICES SCREEN
// ============================================================================

class HomeServicesScreen extends StatefulWidget {
  const HomeServicesScreen({Key? key}) : super(key: key);

  @override
  State<HomeServicesScreen> createState() => _HomeServicesScreenState();
}

class _HomeServicesScreenState extends State<HomeServicesScreen> {
  final List<Map<String, dynamic>> _services = [
    {
      'name': 'House Cleaning',
      'icon': Icons.cleaning_services,
      'description': 'Professional cleaning service',
      'price': 'From \$50',
      'rating': 4.8,
      'providers': 245,
    },
    {
      'name': 'Plumbing',
      'icon': Icons.plumbing,
      'description': 'Expert plumbers available',
      'price': 'From \$75',
      'rating': 4.7,
      'providers': 189,
    },
    {
      'name': 'Electrical',
      'icon': Icons.electrical_services,
      'description': 'Licensed electricians',
      'price': 'From \$80',
      'rating': 4.9,
      'providers': 156,
    },
    {
      'name': 'Painting',
      'icon': Icons.format_paint,
      'description': 'Interior & exterior painting',
      'price': 'From \$100',
      'rating': 4.6,
      'providers': 134,
    },
    {
      'name': 'Carpentry',
      'icon': Icons.carpenter,
      'description': 'Custom woodwork & repairs',
      'price': 'From \$90',
      'rating': 4.8,
      'providers': 98,
    },
    {
      'name': 'Gardening',
      'icon': Icons.yard,
      'description': 'Lawn care & landscaping',
      'price': 'From \$60',
      'rating': 4.5,
      'providers': 167,
    },
    {
      'name': 'AC Repair',
      'icon': Icons.ac_unit,
      'description': 'HVAC maintenance & repair',
      'price': 'From \$85',
      'rating': 4.7,
      'providers': 123,
    },
    {
      'name': 'Pest Control',
      'icon': Icons.pest_control,
      'description': 'Termite & pest removal',
      'price': 'From \$65',
      'rating': 4.6,
      'providers': 112,
    },
    {
      'name': 'Moving',
      'icon': Icons.local_shipping,
      'description': 'Professional movers',
      'price': 'From \$150',
      'rating': 4.8,
      'providers': 89,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Services'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {},
            tooltip: 'Service History',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search for home services...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                filled: true,
              ),
            ),
          ),

          // Emergency Services Banner
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red.shade400, Colors.red.shade600],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning, color: Colors.white, size: 32),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Emergency Service',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '24/7 Available',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.red,
                  ),
                  child: const Text('Call Now'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Services Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.85,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _services.length,
              itemBuilder: (context, index) {
                final service = _services[index];
                return Card(
                  elevation: 2,
                  child: InkWell(
                    onTap: () => _showServiceDetails(service),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            service['icon'] as IconData,
                            size: 48,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            service['name'].toString(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            service['description'].toString(),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.star, size: 14, color: Colors.amber),
                              Text(
                                ' ${service['rating']}',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            service['price'].toString(),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showServiceDetails(Map<String, dynamic> service) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Icon(
              service['icon'] as IconData,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              service['name'].toString(),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star, color: Colors.amber),
                Text(
                  ' ${service['rating']} (${service['providers']} providers)',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Service Details',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              service['description'].toString(),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            _buildDetailRow(Icons.monetization_on, 'Starting Price', service['price'].toString()),
            _buildDetailRow(Icons.schedule, 'Availability', '7 AM - 9 PM'),
            _buildDetailRow(Icons.verified, 'All providers verified', ''),
            _buildDetailRow(Icons.support_agent, '24/7 Support', ''),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _bookService(service);
              },
              icon: const Icon(Icons.calendar_today),
              label: const Text('Book Service'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 24, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (value.isNotEmpty) Text(value, style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _bookService(Map<String, dynamic> service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Book ${service['name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Select Date',
                prefixIcon: Icon(Icons.calendar_today),
              ),
              readOnly: true,
              onTap: () {},
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Select Time',
                prefixIcon: Icon(Icons.access_time),
              ),
              readOnly: true,
              onTap: () {},
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Address',
                prefixIcon: Icon(Icons.location_on),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Service booked: ${service['name']}'),
                  action: SnackBarAction(label: 'VIEW', onPressed: () {}),
                ),
              );
            },
            child: const Text('Confirm Booking'),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// BEAUTY & WELLNESS SCREEN
// ============================================================================

class BeautyWellnessScreen extends StatefulWidget {
  const BeautyWellnessScreen({Key? key}) : super(key: key);

  @override
  State<BeautyWellnessScreen> createState() => _BeautyWellnessScreenState();
}

class _BeautyWellnessScreenState extends State<BeautyWellnessScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  final List<Map<String, dynamic>> _salons = [
    {
      'name': 'Luxe Beauty Salon',
      'rating': 4.8,
      'reviews': 523,
      'distance': '1.2 km',
      'services': ['Haircut', 'Color', 'Spa', 'Facial'],
      'price': '\$\$',
    },
    {
      'name': 'Elite Spa & Wellness',
      'rating': 4.9,
      'reviews': 789,
      'distance': '2.5 km',
      'services': ['Massage', 'Facial', 'Manicure', 'Pedicure'],
      'price': '\$\$\$',
    },
    {
      'name': 'Fresh Look Studio',
      'rating': 4.7,
      'reviews': 345,
      'distance': '0.8 km',
      'services': ['Haircut', 'Styling', 'Makeup'],
      'price': '\$\$',
    },
  ];

  final List<Map<String, dynamic>> _gyms = [
    {
      'name': 'PowerFit Gym',
      'rating': 4.6,
      'amenities': ['Cardio', 'Weights', 'Pool', 'Classes'],
      'membership': '\$59/month',
    },
    {
      'name': 'Yoga Bliss Studio',
      'rating': 4.9,
      'amenities': ['Yoga', 'Pilates', 'Meditation'],
      'membership': '\$79/month',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Beauty & Wellness'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Salon'),
            Tab(text: 'Spa'),
            Tab(text: 'Fitness'),
            Tab(text: 'Wellness'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSalonTab(),
          _buildSpaTab(),
          _buildFitnessTab(),
          _buildWellnessTab(),
        ],
      ),
    );
  }

  Widget _buildSalonTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _salons.length,
      itemBuilder: (context, index) {
        final salon = _salons[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: InkWell(
            onTap: () {},
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          salon['name'].toString(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        salon['price'].toString(),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 16, color: Colors.amber),
                      Text(' ${salon['rating']} (${salon['reviews']} reviews)'),
                      const SizedBox(width: 16),
                      const Icon(Icons.location_on, size: 16),
                      Text(' ${salon['distance']}'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: (salon['services'] as List<String>)
                        .map((service) => Chip(
                              label: Text(service, style: const TextStyle(fontSize: 12)),
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.info_outline),
                          label: const Text('Details'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.calendar_today),
                          label: const Text('Book'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSpaTab() {
    final treatments = [
      {'name': 'Swedish Massage', 'duration': '60 min', 'price': 80.0},
      {'name': 'Deep Tissue Massage', 'duration': '90 min', 'price': 120.0},
      {'name': 'Hot Stone Therapy', 'duration': '75 min', 'price': 100.0},
      {'name': 'Aromatherapy', 'duration': '60 min', 'price': 90.0},
      {'name': 'Body Scrub', 'duration': '45 min', 'price': 70.0},
      {'name': 'Facial Treatment', 'duration': '60 min', 'price': 85.0},
    ];

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: treatments.length,
      itemBuilder: (context, index) {
        final treatment = treatments[index];
        return Card(
          child: InkWell(
            onTap: () {},
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.spa, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    treatment['name'].toString(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    treatment['duration'].toString(),
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const Spacer(),
                  Text(
                    '\$${treatment['price']}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 36),
                    ),
                    child: const Text('Book'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFitnessTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _gyms.length,
      itemBuilder: (context, index) {
        final gym = _gyms[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  gym['name'].toString(),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star, size: 16, color: Colors.amber),
                    Text(' ${gym['rating']}'),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: (gym['amenities'] as List<String>)
                      .map((amenity) => Chip(
                            label: Text(amenity),
                            avatar: const Icon(Icons.check_circle, size: 16),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      gym['membership'].toString(),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      child: const Text('Join Now'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWellnessTab() {
    final programs = [
      {'name': 'Weight Loss Program', 'duration': '3 months', 'price': 299.0},
      {'name': 'Nutrition Counseling', 'duration': '6 sessions', 'price': 180.0},
      {'name': 'Mental Wellness', 'duration': '8 weeks', 'price': 250.0},
      {'name': 'Sleep Therapy', 'duration': '4 weeks', 'price': 200.0},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: programs.length,
      itemBuilder: (context, index) {
        final program = programs[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const CircleAvatar(
              child: Icon(Icons.favorite),
            ),
            title: Text(program['name'].toString()),
            subtitle: Text(program['duration'].toString()),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${program['price']}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                const Icon(Icons.arrow_forward),
              ],
            ),
            onTap: () {},
          ),
        );
      },
    );
  }
}

// ============================================================================
// ENTERTAINMENT SCREEN
// ============================================================================

class EntertainmentScreen extends StatefulWidget {
  const EntertainmentScreen({Key? key}) : super(key: key);

  @override
  State<EntertainmentScreen> createState() => _EntertainmentScreenState();
}

class _EntertainmentScreenState extends State<EntertainmentScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Entertainment'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Movies'),
            Tab(text: 'Music'),
            Tab(text: 'Events'),
            Tab(text: 'Gaming'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMoviesTab(),
          _buildMusicTab(),
          _buildEventsTab(),
          _buildGamingTab(),
        ],
      ),
    );
  }

  Widget _buildMoviesTab() {
    final movies = [
      {'title': 'The Dark Knight', 'genre': 'Action', 'rating': '9.0', 'duration': '152 min'},
      {'title': 'Inception', 'genre': 'Sci-Fi', 'rating': '8.8', 'duration': '148 min'},
      {'title': 'Interstellar', 'genre': 'Adventure', 'rating': '8.6', 'duration': '169 min'},
      {'title': 'The Matrix', 'genre': 'Action', 'rating': '8.7', 'duration': '136 min'},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: movies.length,
      itemBuilder: (context, index) {
        final movie = movies[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            leading: Container(
              width: 60,
              height: 90,
              color: Colors.grey[300],
              child: const Icon(Icons.movie, size: 40),
            ),
            title: Text(movie['title'].toString()),
            subtitle: Text('${movie['genre']} • ${movie['duration']}'),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star, color: Colors.amber),
                Text(movie['rating'].toString()),
              ],
            ),
            onTap: () {},
          ),
        );
      },
    );
  }

  Widget _buildMusicTab() {
    final playlists = [
      {'name': 'Top Hits', 'songs': 50, 'duration': '3h 20m'},
      {'name': 'Chill Vibes', 'songs': 35, 'duration': '2h 15m'},
      {'name': 'Workout Mix', 'songs': 40, 'duration': '2h 45m'},
      {'name': 'Classical', 'songs': 30, 'duration': '4h 10m'},
    ];

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: playlists.length,
      itemBuilder: (context, index) {
        final playlist = playlists[index];
        return Card(
          child: InkWell(
            onTap: () {},
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.library_music, size: 64),
                const SizedBox(height: 12),
                Text(
                  playlist['name'].toString(),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text('${playlist['songs']} songs'),
                Text(playlist['duration'].toString()),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEventsTab() {
    final events = [
      {
        'name': 'Summer Music Festival',
        'date': 'Jul 15, 2025',
        'location': 'Central Park',
        'price': 75.0,
      },
      {
        'name': 'Tech Conference 2025',
        'date': 'Aug 20, 2025',
        'location': 'Convention Center',
        'price': 150.0,
      },
      {
        'name': 'Food & Wine Expo',
        'date': 'Sep 10, 2025',
        'location': 'Downtown Arena',
        'price': 45.0,
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event['name'].toString(),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16),
                    const SizedBox(width: 8),
                    Text(event['date'].toString()),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16),
                    const SizedBox(width: 8),
                    Text(event['location'].toString()),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$${event['price']}',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      child: const Text('Get Tickets'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGamingTab() {
    final games = [
      {'name': 'Action Game 1', 'players': '1M+', 'rating': '4.5'},
      {'name': 'Puzzle Game 2', 'players': '500K+', 'rating': '4.7'},
      {'name': 'Racing Game 3', 'players': '2M+', 'rating': '4.6'},
      {'name': 'Strategy Game 4', 'players': '800K+', 'rating': '4.8'},
    ];

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: games.length,
      itemBuilder: (context, index) {
        final game = games[index];
        return Card(
          child: InkWell(
            onTap: () {},
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    color: Colors.blue[100],
                    child: const Center(child: Icon(Icons.games, size: 64)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Text(
                        game['name'].toString(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text('${game['players']} players'),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.star, size: 14, color: Colors.amber),
                          Text(' ${game['rating']}'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
