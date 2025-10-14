// Part of the Super App architecture.
// This file defines data models for services that enhance and simplify daily life.

// -----------------
// Core Daily Life Service Models
// -----------------

/// Represents a generic service provider for various daily life needs.
class ServiceProvider {
  final String id;
  final String name;
  final String description;
  final String category; // e.g., "Home Services", "Personal Care"
  final String imageUrl;
  final double rating;
  final int reviewCount;
  final bool isVerified;
  final List<String> serviceTags; // e.g., "eco-friendly", "24/7"

  ServiceProvider({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.imageUrl,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.isVerified = false,
    this.serviceTags = const [],
  });
}

/// Represents a specific service offered by a provider.
class ServiceOffering {
  final String id;
  final String providerId;
  final String name;
  final String description;
  final double price;
  final String priceUnit; // e.g., "per hour", "per session", "flat rate"
  final Duration estimatedDuration;

  ServiceOffering({
    required this.id,
    required this.providerId,
    required this.name,
    required this.description,
    required this.price,
    required this.priceUnit,
    required this.estimatedDuration,
  });
}

/// Model for booking an appointment for a service.
class ServiceBooking {
  final String id;
  final String userId;
  final String serviceId;
  final String providerId;
  final DateTime bookingTime;
  final String status; // e.g., "Confirmed", "Completed", "Cancelled"
  final String? specialInstructions;
  final double finalPrice;

  ServiceBooking({
    required this.id,
    required this.userId,
    required this.serviceId,
    required this.providerId,
    required this.bookingTime,
    required this.status,
    this.specialInstructions,
    required this.finalPrice,
  });
}

// -----------------
// Specific Daily Life Service Categories
// -----------------

// --- Home Services ---

/// Cleaning service details.
class CleaningService {
  final String id;
  final String type; // "Standard", "Deep Clean", "Move-out"
  final int numberOfBedrooms;
  final int numberOfBathrooms;
  final bool includeInteriorWindows;
  final bool includeOven;

  CleaningService({
    required this.id,
    required this.type,
    required this.numberOfBedrooms,
    required this.numberOfBathrooms,
    this.includeInteriorWindows = false,
    this.includeOven = false,
  });
}

/// Laundry and dry cleaning service model.
class LaundryService {
  final String id;
  final double weightKg;
  final String serviceType; // "Wash & Fold", "Dry Cleaning", "Ironing"
  final bool useHypoallergenicDetergent;
  final DateTime pickupTime;
  final DateTime deliveryTime;

  LaundryService({
    required this.id,
    required this.weightKg,
    required this.serviceType,
    this.useHypoallergenicDetergent = false,
    required this.pickupTime,
    required this.deliveryTime,
  });
}

/// Home repair and maintenance service.
class HomeMaintenanceService {
  final String id;
  final String trade; // "Plumbing", "Electrical", "Carpentry", "Painting"
  final String issueDescription;
  final List<String> issueImageUrls;
  final bool isEmergency;

  HomeMaintenanceService({
    required this.id,
    required this.trade,
    required this.issueDescription,
    this.issueImageUrls = const [],
    this.isEmergency = false,
  });
}

// --- Personal Care ---

/// Represents a salon or spa.
class Salon {
  final String id;
  final String name;
  final String address;
  final List<String> servicesOffered; // e.g., "Haircut", "Manicure", "Massage"
  final double rating;

  Salon({
    required this.id,
    required this.name,
    required this.address,
    required this.servicesOffered,
    required this.rating,
  });
}

/// Represents a stylist or therapist at a salon.
class Stylist {
  final String id;
  final String salonId;
  final String name;
  final String specialization;
  final String profileImageUrl;
  final List<String> availableTimeSlots;

  Stylist({
    required this.id,
    required this.salonId,
    required this.name,
    required this.specialization,
    required this.profileImageUrl,
    required this.availableTimeSlots,
  });
}

// --- Fitness & Wellness ---

/// Represents a gym or fitness center.
class FitnessCenter {
  final String id;
  final String name;
  final String address;
  final List<String> amenities; // "Pool", "Sauna", "Yoga Studio"
  final String membershipType; // "Basic", "Premium", "Class-only"

  FitnessCenter({
    required this.id,
    required this.name,
    required this.address,
    required this.amenities,
    required this.membershipType,
  });
}

/// Represents a fitness class.
class FitnessClass {
  final String id;
  final String centerId;
  final String name; // "Yoga", "Spin", "HIIT"
  final String instructorName;
  final DateTime classTime;
  final Duration duration;
  final int spotsAvailable;

  FitnessClass({
    required this.id,
    required this.centerId,
    required this.name,
    required this.instructorName,
    required this.classTime,
    required this.duration,
    required this.spotsAvailable,
  });
}

// --- Education & Learning ---

/// Represents a tutor or instructor.
class Tutor {
  final String id;
  final String name;
  final List<String> subjects; // "Math", "Physics", "English Literature"
  final String educationLevel; // "High School", "University", "Professional"
  final double hourlyRate;
  final double rating;

  Tutor({
    required this.id,
    required this.name,
    required this.subjects,
    required this.educationLevel,
    required this.hourlyRate,
    required this.rating,
  });
}

/// Represents an online course or workshop.
class OnlineCourse {
  final String id;
  final String title;
  final String instructorName;
  final String category; // "Programming", "Design", "Business"
  final int lessonCount;
  final double price;
  final String skillLevel; // "Beginner", "Intermediate", "Advanced"

  OnlineCourse({
    required this.id,
    required this.title,
    required this.instructorName,
    required this.category,
    required this.lessonCount,
    required this.price,
    required this.skillLevel,
  });
}

// --- Pet Services ---

/// Model for pet grooming services.
class PetGrooming {
  final String id;
  final String petType; // "Dog", "Cat"
  final String breed;
  final String servicePackage; // "Basic Bath", "Full Groom", "Puppy Cut"
  final DateTime appointmentTime;

  PetGrooming({
    required this.id,
    required this.petType,
    required this.breed,
    required this.servicePackage,
    required this.appointmentTime,
  });
}

/// Model for pet sitting or walking services.
class PetSitting {
  final String id;
  final String serviceType; // "Sitting", "Walking", "Boarding"
  final DateTime startTime;
  final DateTime endTime;
  final int numberOfPets;
  final String? notesForSitter;

  PetSitting({
    required this.id,
    required this.serviceType,
    required this.startTime,
    required this.endTime,
    required this.numberOfPets,
    this.notesForSitter,
  });
}
