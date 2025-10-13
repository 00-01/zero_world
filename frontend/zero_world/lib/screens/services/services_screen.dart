import 'package:flutter/material.dart';
import '../../models/services.dart';
import 'delivery/delivery_home_screen.dart';
import 'booking/booking_home_screen.dart';
import 'payment/wallet_screen.dart';
import 'transport/transport_screen.dart';
import 'other_screens.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final serviceCategories = [
      // === SURVIVAL ESSENTIALS ===
      ServiceCategory(
        id: 'food',
        name: '🍽️ Food & Groceries',
        icon: Icons.restaurant,
        color: Colors.orange,
        services: [
          Service(id: 'food_delivery', name: 'Restaurant Delivery', description: 'Order from restaurants', icon: Icons.fastfood, color: Colors.red, route: '/delivery'),
          Service(id: 'grocery', name: 'Grocery Delivery', description: 'Fresh groceries', icon: Icons.shopping_basket, color: Colors.green, route: '/grocery'),
          Service(id: 'meal_plans', name: 'Meal Plans', description: 'Weekly meal subscriptions', icon: Icons.calendar_today, color: Colors.orange, route: '/meal-plans'),
          Service(id: 'catering', name: 'Catering', description: 'Event catering', icon: Icons.people, color: Colors.deepOrange, route: '/catering'),
        ],
      ),
      ServiceCategory(
        id: 'healthcare',
        name: '🏥 Healthcare & Wellness',
        icon: Icons.local_hospital,
        color: Colors.red,
        services: [
          Service(id: 'doctor', name: 'Doctor Consultation', description: 'Book appointments', icon: Icons.medical_services, color: Colors.red, route: '/health'),
          Service(id: 'telemedicine', name: 'Telemedicine', description: 'Video consultations', icon: Icons.video_call, color: Colors.redAccent, route: '/telemedicine'),
          Service(id: 'pharmacy', name: 'Pharmacy', description: 'Medicine delivery', icon: Icons.local_pharmacy, color: Colors.pink, route: '/pharmacy'),
          Service(id: 'emergency', name: 'Emergency', description: 'Ambulance & urgent care', icon: Icons.emergency, color: Colors.red.shade900, route: '/emergency'),
          Service(id: 'lab_tests', name: 'Lab Tests', description: 'Book diagnostic tests', icon: Icons.biotech, color: Colors.purple, route: '/lab-tests'),
          Service(id: 'mental_health', name: 'Mental Health', description: 'Therapy & counseling', icon: Icons.psychology, color: Colors.indigo, route: '/mental-health'),
        ],
      ),
      ServiceCategory(
        id: 'financial',
        name: '💰 Financial Services',
        icon: Icons.account_balance,
        color: Colors.teal,
        services: [
          Service(id: 'wallet', name: 'Digital Wallet', description: 'Payments & transfers', icon: Icons.account_balance_wallet, color: Colors.teal, route: '/wallet'),
          Service(id: 'bills', name: 'Pay Bills', description: 'All utility bills', icon: Icons.receipt_long, color: Colors.cyan, route: '/bills'),
          Service(id: 'loans', name: 'Loans', description: 'Personal & business loans', icon: Icons.attach_money, color: Colors.green, route: '/loans'),
          Service(id: 'insurance', name: 'Insurance', description: 'Health, vehicle, home', icon: Icons.shield, color: Colors.blue, route: '/insurance'),
          Service(id: 'investments', name: 'Investments', description: 'Stocks, crypto, funds', icon: Icons.trending_up, color: Colors.amber, route: '/investments'),
          Service(id: 'banking', name: 'Banking', description: 'Account management', icon: Icons.account_balance, color: Colors.indigo, route: '/banking'),
        ],
      ),
      ServiceCategory(
        id: 'housing',
        name: '🏠 Housing & Real Estate',
        icon: Icons.home,
        color: Colors.brown,
        services: [
          Service(id: 'buy_property', name: 'Buy Property', description: 'Houses, apartments, land', icon: Icons.home_work, color: Colors.brown, route: '/buy-property'),
          Service(id: 'rent_property', name: 'Rent Property', description: 'Long-term rentals', icon: Icons.apartment, color: Colors.brown.shade400, route: '/rent-property'),
          Service(id: 'roommates', name: 'Find Roommate', description: 'Share accommodation', icon: Icons.people_outline, color: Colors.orange, route: '/roommates'),
          Service(id: 'home_services', name: 'Home Services', description: 'Repairs & maintenance', icon: Icons.build, color: Colors.grey, route: '/booking'),
          Service(id: 'utilities', name: 'Utilities Setup', description: 'Connect services', icon: Icons.power, color: Colors.yellow.shade700, route: '/utilities'),
        ],
      ),
      ServiceCategory(
        id: 'transport',
        name: '🚗 Transportation',
        icon: Icons.directions_car,
        color: Colors.blue,
        services: [
          Service(id: 'ride', name: 'Ride Booking', description: 'Cars, bikes, auto', icon: Icons.local_taxi, color: Colors.blue, route: '/transport'),
          Service(id: 'delivery_service', name: 'Package Delivery', description: 'Send packages', icon: Icons.local_shipping, color: Colors.indigo, route: '/transport'),
          Service(id: 'public_transit', name: 'Public Transit', description: 'Bus, train, metro', icon: Icons.train, color: Colors.green, route: '/transit'),
          Service(id: 'car_rental', name: 'Car Rental', description: 'Rent vehicles', icon: Icons.car_rental, color: Colors.purple, route: '/car-rental'),
          Service(id: 'parking', name: 'Parking', description: 'Find & book parking', icon: Icons.local_parking, color: Colors.grey, route: '/parking'),
          Service(id: 'vehicle_services', name: 'Vehicle Services', description: 'Repair & maintenance', icon: Icons.car_repair, color: Colors.red, route: '/vehicle-services'),
        ],
      ),
      ServiceCategory(
        id: 'employment',
        name: '💼 Jobs & Employment',
        icon: Icons.work,
        color: Colors.deepPurple,
        services: [
          Service(id: 'job_search', name: 'Job Search', description: 'Find full-time jobs', icon: Icons.work_outline, color: Colors.deepPurple, route: '/jobs'),
          Service(id: 'freelance', name: 'Freelance Gigs', description: 'Project-based work', icon: Icons.laptop, color: Colors.purple, route: '/freelance'),
          Service(id: 'networking', name: 'Networking', description: 'Professional connections', icon: Icons.people, color: Colors.indigo, route: '/networking'),
          Service(id: 'resume', name: 'Resume Builder', description: 'Create your CV', icon: Icons.description, color: Colors.blue, route: '/resume'),
        ],
      ),
      ServiceCategory(
        id: 'education',
        name: '📚 Education & Learning',
        icon: Icons.school,
        color: Colors.deepPurple.shade300,
        services: [
          Service(id: 'courses', name: 'Online Courses', description: 'Learn new skills', icon: Icons.laptop, color: Colors.deepPurple, route: '/education'),
          Service(id: 'tutoring', name: 'Tutoring', description: '1-on-1 lessons', icon: Icons.person, color: Colors.purple, route: '/tutoring'),
          Service(id: 'certifications', name: 'Certifications', description: 'Official credentials', icon: Icons.card_membership, color: Colors.amber, route: '/certifications'),
          Service(id: 'language', name: 'Language Learning', description: 'Master new languages', icon: Icons.translate, color: Colors.blue, route: '/language'),
        ],
      ),
      ServiceCategory(
        id: 'government',
        name: '🏛️ Government & Legal',
        icon: Icons.gavel,
        color: Colors.blueGrey,
        services: [
          Service(id: 'documents', name: 'ID Documents', description: 'Passports, licenses', icon: Icons.badge, color: Colors.blueGrey, route: '/documents'),
          Service(id: 'taxes', name: 'Tax Services', description: 'File & pay taxes', icon: Icons.account_balance, color: Colors.green, route: '/taxes'),
          Service(id: 'legal', name: 'Legal Services', description: 'Lawyers & consultations', icon: Icons.gavel, color: Colors.brown, route: '/legal'),
          Service(id: 'permits', name: 'Permits & Licenses', description: 'Business permits', icon: Icons.assignment, color: Colors.orange, route: '/permits'),
        ],
      ),

      // === DAILY LIFE ===
      ServiceCategory(
        id: 'shopping',
        name: '🛍️ Shopping & Marketplace',
        icon: Icons.shopping_bag,
        color: Colors.amber,
        services: [
          Service(id: 'marketplace', name: 'Marketplace', description: 'Buy & sell anything', icon: Icons.store, color: Colors.amber, route: '/shopping'),
          Service(id: 'auctions', name: 'Auctions', description: 'Bid on items', icon: Icons.gavel, color: Colors.orange, route: '/auctions'),
          Service(id: 'free_stuff', name: 'Free Stuff', description: 'Give away items', icon: Icons.card_giftcard, color: Colors.green, route: '/free-stuff'),
          Service(id: 'wanted', name: 'Wanted Ads', description: 'Looking for items', icon: Icons.search, color: Colors.blue, route: '/wanted'),
        ],
      ),
      ServiceCategory(
        id: 'booking',
        name: '📅 Booking & Reservations',
        icon: Icons.event_available,
        color: Colors.purple,
        services: [
          Service(id: 'hotel', name: 'Hotels', description: 'Book accommodations', icon: Icons.hotel, color: Colors.purple, route: '/booking'),
          Service(id: 'beauty', name: 'Beauty & Spa', description: 'Salon services', icon: Icons.spa, color: Colors.pink, route: '/booking'),
          Service(id: 'restaurants', name: 'Restaurants', description: 'Table reservations', icon: Icons.restaurant, color: Colors.orange, route: '/restaurant-booking'),
          Service(id: 'events', name: 'Events & Tickets', description: 'Concerts, sports, shows', icon: Icons.confirmation_number, color: Colors.red, route: '/events'),
        ],
      ),
      ServiceCategory(
        id: 'entertainment',
        name: '🎬 Entertainment & Media',
        icon: Icons.movie,
        color: Colors.pink,
        services: [
          Service(id: 'movies', name: 'Movies', description: 'Cinema tickets', icon: Icons.local_movies, color: Colors.red, route: '/movies'),
          Service(id: 'streaming', name: 'Streaming', description: 'Videos & music', icon: Icons.play_circle, color: Colors.purple, route: '/streaming'),
          Service(id: 'gaming', name: 'Gaming', description: 'Games & tournaments', icon: Icons.sports_esports, color: Colors.blue, route: '/gaming'),
          Service(id: 'news', name: 'News', description: 'Latest updates', icon: Icons.newspaper, color: Colors.grey, route: '/news'),
        ],
      ),
      ServiceCategory(
        id: 'travel',
        name: '✈️ Travel & Tourism',
        icon: Icons.flight,
        color: Colors.cyan,
        services: [
          Service(id: 'flights', name: 'Flights', description: 'Book air tickets', icon: Icons.flight_takeoff, color: Colors.blue, route: '/flights'),
          Service(id: 'travel_hotels', name: 'Hotels', description: 'Accommodations', icon: Icons.hotel, color: Colors.purple, route: '/travel-hotels'),
          Service(id: 'visa', name: 'Visa Services', description: 'Travel visas', icon: Icons.flight, color: Colors.indigo, route: '/visa'),
          Service(id: 'travel_guide', name: 'Travel Guides', description: 'Destination info', icon: Icons.map, color: Colors.green, route: '/travel-guide'),
        ],
      ),
      ServiceCategory(
        id: 'pets',
        name: '🐾 Pet Care',
        icon: Icons.pets,
        color: Colors.brown.shade300,
        services: [
          Service(id: 'vet', name: 'Veterinary', description: 'Pet healthcare', icon: Icons.medical_services, color: Colors.red, route: '/vet'),
          Service(id: 'pet_grooming', name: 'Grooming', description: 'Pet beauty', icon: Icons.spa, color: Colors.pink, route: '/pet-grooming'),
          Service(id: 'pet_adoption', name: 'Adoption', description: 'Adopt pets', icon: Icons.favorite, color: Colors.red, route: '/pet-adoption'),
          Service(id: 'pet_supplies', name: 'Pet Supplies', description: 'Food & accessories', icon: Icons.shopping_bag, color: Colors.amber, route: '/pet-supplies'),
        ],
      ),
      ServiceCategory(
        id: 'dating',
        name: '💕 Dating & Relationships',
        icon: Icons.favorite,
        color: Colors.red.shade300,
        services: [
          Service(id: 'dating', name: 'Dating', description: 'Find partners', icon: Icons.favorite, color: Colors.pink, route: '/dating'),
          Service(id: 'events_singles', name: 'Singles Events', description: 'Meet people', icon: Icons.people, color: Colors.purple, route: '/singles-events'),
          Service(id: 'matchmaking', name: 'Matchmaking', description: 'Professional matching', icon: Icons.group_add, color: Colors.red, route: '/matchmaking'),
        ],
      ),
      ServiceCategory(
        id: 'charity',
        name: '❤️ Charity & Volunteering',
        icon: Icons.volunteer_activism,
        color: Colors.red.shade400,
        services: [
          Service(id: 'donate', name: 'Donate', description: 'Support causes', icon: Icons.favorite, color: Colors.red, route: '/donate'),
          Service(id: 'volunteer', name: 'Volunteer', description: 'Help community', icon: Icons.people, color: Colors.green, route: '/volunteer'),
          Service(id: 'fundraising', name: 'Fundraising', description: 'Create campaigns', icon: Icons.campaign, color: Colors.blue, route: '/fundraising'),
        ],
      ),
      ServiceCategory(
        id: 'weather',
        name: '🌤️ Weather & Environment',
        icon: Icons.wb_sunny,
        color: Colors.yellow.shade700,
        services: [
          Service(id: 'weather', name: 'Weather', description: 'Forecasts & alerts', icon: Icons.wb_sunny, color: Colors.orange, route: '/weather'),
          Service(id: 'recycling', name: 'Recycling', description: 'Waste management', icon: Icons.recycling, color: Colors.green, route: '/recycling'),
          Service(id: 'air_quality', name: 'Air Quality', description: 'Pollution levels', icon: Icons.air, color: Colors.cyan, route: '/air-quality'),
        ],
      ),
      ServiceCategory(
        id: 'community',
        name: '🏘️ Community & Local',
        icon: Icons.location_city,
        color: Colors.lightBlue,
        services: [
          Service(id: 'neighborhood', name: 'Neighborhood', description: 'Local updates', icon: Icons.home, color: Colors.blue, route: '/neighborhood'),
          Service(id: 'lost_found', name: 'Lost & Found', description: 'Find lost items', icon: Icons.search, color: Colors.orange, route: '/lost-found'),
          Service(id: 'local_events', name: 'Local Events', description: 'Community gatherings', icon: Icons.event, color: Colors.purple, route: '/local-events'),
        ],
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Services'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Quick Actions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade400, Colors.purple.shade400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.flash_on, color: Colors.white, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Quick Services',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Access your most used services instantly',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Service Categories
            ...serviceCategories.map((category) => _buildCategorySection(context, category)),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection(BuildContext context, ServiceCategory category) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: category.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  category.icon,
                  color: category.color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                category.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: category.services.length,
          itemBuilder: (context, index) {
            final service = category.services[index];
            return _buildServiceCard(context, service);
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildServiceCard(BuildContext context, Service service) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => _navigateToService(context, service),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: LinearGradient(
              colors: [
                service.color.withValues(alpha: 0.1),
                service.color.withValues(alpha: 0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: service.color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  service.icon,
                  color: service.color,
                  size: 32,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                service.name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                service.description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToService(BuildContext context, Service service) {
    switch (service.id) {
      case 'food_delivery':
      case 'grocery':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const DeliveryHomeScreen()),
        );
        break;
      case 'ride':
      case 'delivery_service':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const TransportScreen()),
        );
        break;
      case 'hotel':
      case 'beauty':
      case 'repair':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const BookingHomeScreen()),
        );
        break;
      case 'wallet':
      case 'transfer':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const WalletScreen()),
        );
        break;
      case 'marketplace':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ShoppingScreen()),
        );
        break;
      case 'doctor':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const HealthScreen()),
        );
        break;
      case 'courses':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const EducationScreen()),
        );
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${service.name} coming soon!')),
        );
    }
  }
}
