import 'package:flutter/material.dart';

// ============================================================================
// EDUCATION SERVICES SCREEN
// ============================================================================

class EducationScreen extends StatefulWidget {
  const EducationScreen({Key? key}) : super(key: key);

  @override
  State<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends State<EducationScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedCategory = 'All';

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

  // Mock data
  final List<Map<String, dynamic>> _courses = [
    {
      'title': 'Complete Web Development Bootcamp',
      'instructor': 'Dr. Angela Yu',
      'rating': 4.8,
      'students': 125000,
      'price': 89.99,
      'duration': '65 hours',
      'category': 'Programming',
      'level': 'Beginner',
      'image': '🖥️',
    },
    {
      'title': 'Machine Learning A-Z',
      'instructor': 'Kirill Eremenko',
      'rating': 4.9,
      'students': 85000,
      'price': 99.99,
      'duration': '44 hours',
      'category': 'Data Science',
      'level': 'Intermediate',
      'image': '🤖',
    },
    {
      'title': 'IELTS Speaking Masterclass',
      'instructor': 'Emma Johnson',
      'rating': 4.7,
      'students': 45000,
      'price': 49.99,
      'duration': '12 hours',
      'category': 'Language',
      'level': 'All Levels',
      'image': '🗣️',
    },
    {
      'title': 'Digital Marketing Complete Course',
      'instructor': 'Phil Ebiner',
      'rating': 4.6,
      'students': 95000,
      'price': 79.99,
      'duration': '23 hours',
      'category': 'Marketing',
      'level': 'Beginner',
      'image': '📱',
    },
  ];

  final List<Map<String, dynamic>> _tutors = [
    {
      'name': 'Sarah Williams',
      'subject': 'Mathematics',
      'rating': 4.9,
      'reviews': 234,
      'hourlyRate': 45.0,
      'experience': '8 years',
      'image': '👩‍🏫',
      'availability': 'Available Now',
    },
    {
      'name': 'James Chen',
      'subject': 'Physics',
      'rating': 4.8,
      'reviews': 189,
      'hourlyRate': 50.0,
      'experience': '10 years',
      'image': '👨‍🏫',
      'availability': 'Today 3-6 PM',
    },
    {
      'name': 'Maria Garcia',
      'subject': 'Spanish',
      'rating': 5.0,
      'reviews': 312,
      'hourlyRate': 35.0,
      'experience': '12 years',
      'image': '👩‍💼',
      'availability': 'Tomorrow',
    },
  ];

  final List<String> _categories = ['All', 'Programming', 'Data Science', 'Business', 'Language', 'Design', 'Marketing', 'Music', 'Health', 'Photography'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Education & Learning'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Courses'),
            Tab(text: 'Tutors'),
            Tab(text: 'Tests'),
            Tab(text: 'Certificates'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search courses, tutors, or topics...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                filled: true,
              ),
              onChanged: (value) => setState(() {}),
            ),
          ),

          // Category Chips
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(_categories[index]),
                    selected: _selectedCategory == _categories[index],
                    onSelected: (selected) {
                      setState(() => _selectedCategory = _categories[index]);
                    },
                  ),
                );
              },
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCoursesTab(),
                _buildTutorsTab(),
                _buildTestsTab(),
                _buildCertificatesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoursesTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _courses.length,
      itemBuilder: (context, index) {
        final course = _courses[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: InkWell(
            onTap: () => _showCourseDetails(course),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // Course Image
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        course['image'],
                        style: const TextStyle(fontSize: 40),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Course Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          course['title'],
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          course['instructor'],
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.star, size: 16, color: Colors.amber),
                            Text(' ${course['rating']} '),
                            Text(
                              '(${course['students']} students)',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '\$${course['price']}',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                            ),
                            Text(
                              course['duration'],
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTutorsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _tutors.length,
      itemBuilder: (context, index) {
        final tutor = _tutors[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: InkWell(
            onTap: () => _showTutorDetails(tutor),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Tutor Avatar
                  CircleAvatar(
                    radius: 40,
                    child: Text(
                      tutor['image'],
                      style: const TextStyle(fontSize: 40),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Tutor Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tutor['name'],
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          tutor['subject'],
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.star, size: 18, color: Colors.amber),
                            Text(' ${tutor['rating']} (${tutor['reviews']} reviews)'),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text('Experience: ${tutor['experience']}'),
                        Text(
                          '\$${tutor['hourlyRate']}/hour',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Chip(
                          label: Text(tutor['availability']),
                          backgroundColor: Colors.green.withOpacity(0.2),
                          avatar: const Icon(Icons.check_circle, color: Colors.green, size: 16),
                        ),
                      ],
                    ),
                  ),

                  // Book Button
                  Column(
                    children: [
                      ElevatedButton(
                        onPressed: () => _bookTutor(tutor),
                        child: const Text('Book'),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => _showTutorDetails(tutor),
                        child: const Text('Details'),
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

  Widget _buildTestsTab() {
    final tests = [
      {'name': 'IELTS Practice Test', 'type': 'Language', 'duration': '2 hours', 'price': 'Free'},
      {'name': 'SAT Mock Exam', 'type': 'Standardized', 'duration': '3 hours', 'price': '\$25'},
      {'name': 'GRE Sample Test', 'type': 'Graduate', 'duration': '3.5 hours', 'price': '\$30'},
      {'name': 'TOEFL IBT Simulator', 'type': 'Language', 'duration': '4 hours', 'price': '\$20'},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tests.length,
      itemBuilder: (context, index) {
        final test = tests[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.quiz)),
            title: Text(test['name']!),
            subtitle: Text('${test['type']} • ${test['duration']}'),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  test['price']!,
                  style: const TextStyle(fontWeight: FontWeight.bold),
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

  Widget _buildCertificatesTab() {
    final certificates = [
      {'name': 'Google IT Support', 'provider': 'Google', 'duration': '6 months', 'enrolled': '500K+'},
      {'name': 'AWS Cloud Practitioner', 'provider': 'Amazon', 'duration': '3 months', 'enrolled': '250K+'},
      {'name': 'PMP Certification', 'provider': 'PMI', 'duration': '4 months', 'enrolled': '100K+'},
      {'name': 'Data Science Professional', 'provider': 'IBM', 'duration': '8 months', 'enrolled': '300K+'},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: certificates.length,
      itemBuilder: (context, index) {
        final cert = certificates[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const Icon(Icons.workspace_premium, size: 40, color: Colors.amber),
            title: Text(cert['name']!),
            subtitle: Text('${cert['provider']} • ${cert['duration']}\n${cert['enrolled']} enrolled'),
            isThreeLine: true,
            trailing: ElevatedButton(
              onPressed: () {},
              child: const Text('Enroll'),
            ),
          ),
        );
      },
    );
  }

  void _showCourseDetails(Map<String, dynamic> course) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
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
            Text(
              course['title'],
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'By ${course['instructor']}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(label: Text('⭐ ${course['rating']}')),
                Chip(label: Text('👥 ${course['students']} students')),
                Chip(label: Text('⏱️ ${course['duration']}')),
                Chip(label: Text('📊 ${course['level']}')),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Course Description',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'This comprehensive course will take you from beginner to expert. Learn the fundamentals and advanced concepts with hands-on projects and real-world examples.',
            ),
            const SizedBox(height: 24),
            const Text(
              'What you\'ll learn',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...List.generate(
                5,
                (i) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green, size: 20),
                          const SizedBox(width: 8),
                          Expanded(child: Text('Key learning point ${i + 1}')),
                        ],
                      ),
                    )),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.shopping_cart),
                    label: Text('Buy Now - \$${course['price']}'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showTutorDetails(Map<String, dynamic> tutor) {
    // Similar to course details
  }

  void _bookTutor(Map<String, dynamic> tutor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Book ${tutor['name']}'),
        content: const Text('Choose your preferred time slot'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Booking confirmed!')),
              );
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// TRAVEL SERVICES SCREEN
// ============================================================================

class TravelScreen extends StatefulWidget {
  const TravelScreen({Key? key}) : super(key: key);

  @override
  State<TravelScreen> createState() => _TravelScreenState();
}

class _TravelScreenState extends State<TravelScreen> with SingleTickerProviderStateMixin {
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

  final List<Map<String, dynamic>> _hotels = [
    {
      'name': 'Grand Hyatt',
      'location': 'New York, USA',
      'rating': 4.8,
      'reviews': 1234,
      'price': 299.0,
      'image': '🏨',
      'amenities': ['WiFi', 'Pool', 'Spa', 'Restaurant'],
    },
    {
      'name': 'Marina Bay Sands',
      'location': 'Singapore',
      'rating': 4.9,
      'reviews': 2341,
      'price': 450.0,
      'image': '🏨',
      'amenities': ['Infinity Pool', 'Casino', 'Shopping'],
    },
    {
      'name': 'Burj Al Arab',
      'location': 'Dubai, UAE',
      'rating': 5.0,
      'reviews': 892,
      'price': 1200.0,
      'image': '🏨',
      'amenities': ['Butler Service', 'Helicopter', 'Private Beach'],
    },
  ];

  final List<Map<String, dynamic>> _flights = [
    {
      'airline': 'Emirates',
      'from': 'JFK',
      'to': 'DXB',
      'departure': '10:30 AM',
      'arrival': '8:45 PM',
      'duration': '14h 15m',
      'price': 1299.0,
      'class': 'Business',
    },
    {
      'airline': 'Singapore Airlines',
      'from': 'LAX',
      'to': 'SIN',
      'departure': '11:00 PM',
      'arrival': '6:30 AM +2',
      'duration': '17h 30m',
      'price': 899.0,
      'class': 'Economy',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Travel & Experiences'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Hotels'),
            Tab(text: 'Flights'),
            Tab(text: 'Experiences'),
            Tab(text: 'Packages'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildHotelsTab(),
          _buildFlightsTab(),
          _buildExperiencesTab(),
          _buildPackagesTab(),
        ],
      ),
    );
  }

  Widget _buildHotelsTab() {
    return Column(
      children: [
        // Search Form
        Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Destination',
                    prefixIcon: const Icon(Icons.location_on),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: 'Check-in',
                          prefixIcon: const Icon(Icons.calendar_today),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        readOnly: true,
                        onTap: () {},
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: 'Check-out',
                          prefixIcon: const Icon(Icons.calendar_today),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        readOnly: true,
                        onTap: () {},
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.search),
                  label: const Text('Search Hotels'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Hotels List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _hotels.length,
            itemBuilder: (context, index) {
              final hotel = _hotels[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hotel Image
                    Container(
                      height: 200,
                      color: Theme.of(context).colorScheme.primaryContainer,
                      child: Center(
                        child: Text(hotel['image'], style: const TextStyle(fontSize: 80)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hotel['name'],
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.location_on, size: 16),
                              const SizedBox(width: 4),
                              Text(hotel['location']),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 20),
                              const SizedBox(width: 4),
                              Text('${hotel['rating']}'),
                              const SizedBox(width: 8),
                              Text('(${hotel['reviews']} reviews)'),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: (hotel['amenities'] as List<String>)
                                .map((amenity) => Chip(
                                      label: Text(amenity, style: const TextStyle(fontSize: 12)),
                                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ))
                                .toList(),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '\$${hotel['price']}',
                                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).colorScheme.primary,
                                        ),
                                  ),
                                  const Text('per night'),
                                ],
                              ),
                              ElevatedButton(
                                onPressed: () {},
                                child: const Text('Book Now'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFlightsTab() {
    return Column(
      children: [
        // Flight Search
        Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: 'From',
                          prefixIcon: const Icon(Icons.flight_takeoff),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.swap_horiz),
                      onPressed: () {},
                    ),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: 'To',
                          prefixIcon: const Icon(Icons.flight_land),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Departure Date',
                    prefixIcon: const Icon(Icons.calendar_today),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  readOnly: true,
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.search),
                  label: const Text('Search Flights'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Flights List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _flights.length,
            itemBuilder: (context, index) {
              final flight = _flights[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        flight['airline'],
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  flight['from'],
                                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                ),
                                Text(flight['departure']),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  flight['to'],
                                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                ),
                                Text(flight['arrival']),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text('Duration: ${flight['duration']} • ${flight['class']}'),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '\$${flight['price']}',
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          ElevatedButton(
                            onPressed: () {},
                            child: const Text('Select'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildExperiencesTab() {
    final experiences = [
      {'name': 'Hot Air Balloon Ride', 'location': 'Cappadocia', 'price': 250.0, 'rating': 4.9},
      {'name': 'Scuba Diving Adventure', 'location': 'Great Barrier Reef', 'price': 180.0, 'rating': 4.8},
      {'name': 'City Food Tour', 'location': 'Tokyo', 'price': 95.0, 'rating': 4.7},
      {'name': 'Desert Safari', 'location': 'Dubai', 'price': 120.0, 'rating': 4.6},
    ];

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: experiences.length,
      itemBuilder: (context, index) {
        final exp = experiences[index];
        return Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: const Center(child: Icon(Icons.landscape, size: 60)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exp['name'].toString(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      exp['location'].toString(),
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 14, color: Colors.amber),
                        Text(' ${exp['rating']}'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${exp['price']}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPackagesTab() {
    final packages = [
      {
        'name': 'Europe Grand Tour',
        'duration': '14 days',
        'cities': '7 cities',
        'price': 3499.0,
        'includes': 'Flights, Hotels, Transfers',
      },
      {
        'name': 'Asian Adventure',
        'duration': '10 days',
        'cities': '5 cities',
        'price': 2299.0,
        'includes': 'Flights, Hotels, Tours',
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: packages.length,
      itemBuilder: (context, index) {
        final package = packages[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  package['name'].toString(),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('${package['duration']} • ${package['cities']}'),
                Text(package['includes'].toString()),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$${package['price']}',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      child: const Text('View Details'),
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
}
