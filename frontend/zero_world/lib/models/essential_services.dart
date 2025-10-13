import 'package:flutter/material.dart';

// ============================================
// ESSENTIAL LIFE CATEGORIES
// ============================================

// 1. BASIC NEEDS & UTILITIES
class UtilitiesService {
  final String id;
  final String name;
  final String description;
  final IconData icon;

  const UtilitiesService({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
  });
}

// Water, electricity, gas, internet, phone bills
class UtilityBill {
  final String id;
  final String provider;
  final String accountNumber;
  final double amount;
  final DateTime dueDate;
  final String status;
  final String type; // water, electricity, gas, internet, phone

  const UtilityBill({
    required this.id,
    required this.provider,
    required this.accountNumber,
    required this.amount,
    required this.dueDate,
    required this.status,
    required this.type,
  });
}

// 2. HEALTHCARE & WELLNESS
class HealthService {
  final String id;
  final String name;
  final String category; // doctor, pharmacy, emergency, mental-health, fitness
  final double rating;
  final String location;
  final bool available24x7;

  const HealthService({
    required this.id,
    required this.name,
    required this.category,
    required this.rating,
    required this.location,
    required this.available24x7,
  });
}

class MedicalRecord {
  final String id;
  final DateTime date;
  final String type; // consultation, prescription, lab-test, vaccination
  final String provider;
  final String summary;
  final List<String> attachments;

  const MedicalRecord({
    required this.id,
    required this.date,
    required this.type,
    required this.provider,
    required this.summary,
    required this.attachments,
  });
}

class HealthAppointment {
  final String id;
  final DateTime dateTime;
  final String doctor;
  final String specialty;
  final String location;
  final String status;
  final String type; // in-person, video-call, phone-call

  const HealthAppointment({
    required this.id,
    required this.dateTime,
    required this.doctor,
    required this.specialty,
    required this.location,
    required this.status,
    required this.type,
  });
}

// 3. EDUCATION & LEARNING
class EducationService {
  final String id;
  final String name;
  final String category; // school, university, online-course, tutoring, certification
  final String description;
  final double price;
  final double rating;
  final int enrolledStudents;

  const EducationService({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.price,
    required this.rating,
    required this.enrolledStudents,
  });
}

class Course {
  final String id;
  final String title;
  final String instructor;
  final String category;
  final int duration; // in hours
  final double progress;
  final List<String> modules;
  final bool certified;

  const Course({
    required this.id,
    required this.title,
    required this.instructor,
    required this.category,
    required this.duration,
    required this.progress,
    required this.modules,
    required this.certified,
  });
}

// 4. EMPLOYMENT & FREELANCING
class JobListing {
  final String id;
  final String title;
  final String company;
  final String location;
  final String type; // full-time, part-time, contract, freelance, remote
  final String salary;
  final List<String> requirements;
  final DateTime postedDate;

  const JobListing({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.type,
    required this.salary,
    required this.requirements,
    required this.postedDate,
  });
}

class FreelanceGig {
  final String id;
  final String title;
  final String client;
  final double budget;
  final String category;
  final String description;
  final List<String> skills;
  final DateTime deadline;

  const FreelanceGig({
    required this.id,
    required this.title,
    required this.client,
    required this.budget,
    required this.category,
    required this.description,
    required this.skills,
    required this.deadline,
  });
}

// 5. GOVERNMENT & LEGAL SERVICES
class GovernmentService {
  final String id;
  final String name;
  final String department;
  final String category; // id-card, passport, license, permits, certificates, taxes
  final String description;
  final List<String> requirements;
  final int processingDays;

  const GovernmentService({
    required this.id,
    required this.name,
    required this.department,
    required this.category,
    required this.description,
    required this.requirements,
    required this.processingDays,
  });
}

class LegalService {
  final String id;
  final String name;
  final String specialty; // lawyer, notary, court, contracts
  final double hourlyRate;
  final double rating;
  final int yearsExperience;

  const LegalService({
    required this.id,
    required this.name,
    required this.specialty,
    required this.hourlyRate,
    required this.rating,
    required this.yearsExperience,
  });
}

// 6. REAL ESTATE & HOUSING
class Property {
  final String id;
  final String title;
  final String type; // buy, rent, commercial, land
  final double price;
  final String location;
  final int bedrooms;
  final int bathrooms;
  final double sqft;
  final List<String> amenities;
  final List<String> images;
  final String agentName;
  final String agentContact;

  const Property({
    required this.id,
    required this.title,
    required this.type,
    required this.price,
    required this.location,
    required this.bedrooms,
    required this.bathrooms,
    required this.sqft,
    required this.amenities,
    required this.images,
    required this.agentName,
    required this.agentContact,
  });
}

// 7. FINANCIAL SERVICES
class FinancialProduct {
  final String id;
  final String name;
  final String type; // insurance, loan, investment, savings, credit-card
  final String provider;
  final double rate; // interest rate or premium
  final String description;
  final List<String> features;

  const FinancialProduct({
    required this.id,
    required this.name,
    required this.type,
    required this.provider,
    required this.rate,
    required this.description,
    required this.features,
  });
}

class Investment {
  final String id;
  final String name;
  final String type; // stocks, crypto, mutual-funds, bonds, real-estate
  final double currentValue;
  final double investedAmount;
  final double returns;
  final DateTime purchaseDate;

  const Investment({
    required this.id,
    required this.name,
    required this.type,
    required this.currentValue,
    required this.investedAmount,
    required this.returns,
    required this.purchaseDate,
  });
}

// 8. EVENTS & ENTERTAINMENT
class Event {
  final String id;
  final String title;
  final String category; // concert, sports, theater, festival, conference
  final DateTime dateTime;
  final String venue;
  final double ticketPrice;
  final int availableSeats;
  final String organizer;
  final List<String> images;

  const Event({
    required this.id,
    required this.title,
    required this.category,
    required this.dateTime,
    required this.venue,
    required this.ticketPrice,
    required this.availableSeats,
    required this.organizer,
    required this.images,
  });
}

// 9. CHARITY & DONATIONS
class CharityOrganization {
  final String id;
  final String name;
  final String cause;
  final String description;
  final double fundsRaised;
  final double goalAmount;
  final int supporters;
  final bool verified;

  const CharityOrganization({
    required this.id,
    required this.name,
    required this.cause,
    required this.description,
    required this.fundsRaised,
    required this.goalAmount,
    required this.supporters,
    required this.verified,
  });
}

// 10. EMERGENCY SERVICES
class EmergencyContact {
  final String id;
  final String name;
  final String service; // police, fire, ambulance, disaster-relief
  final String phoneNumber;
  final String location;
  final bool available24x7;

  const EmergencyContact({
    required this.id,
    required this.name,
    required this.service,
    required this.phoneNumber,
    required this.location,
    required this.available24x7,
  });
}

class EmergencyAlert {
  final String id;
  final String type; // fire, flood, earthquake, medical, security
  final String severity; // low, medium, high, critical
  final String location;
  final String message;
  final DateTime timestamp;
  final List<String> instructions;

  const EmergencyAlert({
    required this.id,
    required this.type,
    required this.severity,
    required this.location,
    required this.message,
    required this.timestamp,
    required this.instructions,
  });
}

// 11. AUTOMOTIVE SERVICES
class VehicleService {
  final String id;
  final String type; // repair, maintenance, insurance, rental, buying, selling
  final String provider;
  final String location;
  final double rating;
  final List<String> services;

  const VehicleService({
    required this.id,
    required this.type,
    required this.provider,
    required this.location,
    required this.rating,
    required this.services,
  });
}

class Vehicle {
  final String id;
  final String make;
  final String model;
  final int year;
  final String plateNumber;
  final DateTime insuranceExpiry;
  final DateTime registrationExpiry;
  final int mileage;
  final List<MaintenanceRecord> maintenanceHistory;

  const Vehicle({
    required this.id,
    required this.make,
    required this.model,
    required this.year,
    required this.plateNumber,
    required this.insuranceExpiry,
    required this.registrationExpiry,
    required this.mileage,
    required this.maintenanceHistory,
  });
}

class MaintenanceRecord {
  final String id;
  final DateTime date;
  final String type;
  final double cost;
  final String provider;
  final int mileageAtService;

  const MaintenanceRecord({
    required this.id,
    required this.date,
    required this.type,
    required this.cost,
    required this.provider,
    required this.mileageAtService,
  });
}

// 12. TRAVEL & TOURISM
class TravelBooking {
  final String id;
  final String type; // flight, hotel, package, visa
  final String destination;
  final DateTime departureDate;
  final DateTime returnDate;
  final int travelers;
  final double totalCost;
  final String bookingReference;

  const TravelBooking({
    required this.id,
    required this.type,
    required this.destination,
    required this.departureDate,
    required this.returnDate,
    required this.travelers,
    required this.totalCost,
    required this.bookingReference,
  });
}

class TravelGuide {
  final String id;
  final String destination;
  final List<String> attractions;
  final List<String> restaurants;
  final List<String> tips;
  final Map<String, String> translations;

  const TravelGuide({
    required this.id,
    required this.destination,
    required this.attractions,
    required this.restaurants,
    required this.tips,
    required this.translations,
  });
}

// 13. PETS & ANIMAL CARE
class PetService {
  final String id;
  final String type; // veterinary, grooming, training, boarding, adoption
  final String provider;
  final String location;
  final double rating;
  final double price;

  const PetService({
    required this.id,
    required this.type,
    required this.provider,
    required this.location,
    required this.rating,
    required this.price,
  });
}

class Pet {
  final String id;
  final String name;
  final String species;
  final String breed;
  final int age;
  final List<MedicalRecord> medicalHistory;
  final DateTime lastVetVisit;
  final List<String> vaccinations;

  const Pet({
    required this.id,
    required this.name,
    required this.species,
    required this.breed,
    required this.age,
    required this.medicalHistory,
    required this.lastVetVisit,
    required this.vaccinations,
  });
}

// 14. NEWS & INFORMATION
class NewsArticle {
  final String id;
  final String title;
  final String category; // local, national, world, business, tech, sports, entertainment
  final String content;
  final String source;
  final DateTime publishedDate;
  final List<String> images;
  final int views;
  final int shares;

  const NewsArticle({
    required this.id,
    required this.title,
    required this.category,
    required this.content,
    required this.source,
    required this.publishedDate,
    required this.images,
    required this.views,
    required this.shares,
  });
}

// 15. DATING & RELATIONSHIPS
class DatingProfile {
  final String id;
  final String name;
  final int age;
  final String bio;
  final List<String> interests;
  final List<String> photos;
  final String location;
  final Map<String, dynamic> preferences;

  const DatingProfile({
    required this.id,
    required this.name,
    required this.age,
    required this.bio,
    required this.interests,
    required this.photos,
    required this.location,
    required this.preferences,
  });
}

// 16. PROFESSIONAL NETWORKING
class ProfessionalProfile {
  final String id;
  final String name;
  final String title;
  final String company;
  final String industry;
  final List<String> skills;
  final List<String> certifications;
  final List<WorkExperience> experience;
  final List<String> connections;

  const ProfessionalProfile({
    required this.id,
    required this.name,
    required this.title,
    required this.company,
    required this.industry,
    required this.skills,
    required this.certifications,
    required this.experience,
    required this.connections,
  });
}

class WorkExperience {
  final String company;
  final String title;
  final DateTime startDate;
  final DateTime? endDate;
  final String description;

  const WorkExperience({
    required this.company,
    required this.title,
    required this.startDate,
    this.endDate,
    required this.description,
  });
}

// 17. WEATHER & ENVIRONMENT
class WeatherInfo {
  final String location;
  final double temperature;
  final String condition;
  final int humidity;
  final double windSpeed;
  final List<HourlyForecast> hourlyForecast;
  final List<DailyForecast> weeklyForecast;
  final List<String> alerts;

  const WeatherInfo({
    required this.location,
    required this.temperature,
    required this.condition,
    required this.humidity,
    required this.windSpeed,
    required this.hourlyForecast,
    required this.weeklyForecast,
    required this.alerts,
  });
}

class HourlyForecast {
  final DateTime time;
  final double temperature;
  final String condition;

  const HourlyForecast({
    required this.time,
    required this.temperature,
    required this.condition,
  });
}

class DailyForecast {
  final DateTime date;
  final double highTemp;
  final double lowTemp;
  final String condition;

  const DailyForecast({
    required this.date,
    required this.highTemp,
    required this.lowTemp,
    required this.condition,
  });
}

// 18. RELIGIOUS & SPIRITUAL SERVICES
class ReligiousService {
  final String id;
  final String name;
  final String religion;
  final String type; // prayer-times, events, donations, online-service
  final String location;
  final List<DateTime> serviceTimes;

  const ReligiousService({
    required this.id,
    required this.name,
    required this.religion,
    required this.type,
    required this.location,
    required this.serviceTimes,
  });
}

// 19. ENVIRONMENTAL & SUSTAINABILITY
class RecyclingService {
  final String id;
  final String type; // pickup, drop-off, buy-back
  final String location;
  final List<String> acceptedMaterials;
  final Map<String, double> rates;

  const RecyclingService({
    required this.id,
    required this.type,
    required this.location,
    required this.acceptedMaterials,
    required this.rates,
  });
}

// 20. COMMUNITY & NEIGHBORHOOD
class CommunityPost {
  final String id;
  final String authorId;
  final String category; // lost-found, recommendations, complaints, announcements
  final String content;
  final String location;
  final DateTime timestamp;
  final List<String> images;
  final int upvotes;
  final List<String> comments;

  const CommunityPost({
    required this.id,
    required this.authorId,
    required this.category,
    required this.content,
    required this.location,
    required this.timestamp,
    required this.images,
    required this.upvotes,
    required this.comments,
  });
}

class NeighborhoodWatch {
  final String id;
  final String type; // security, incident, missing-person, suspicious-activity
  final String description;
  final String location;
  final DateTime timestamp;
  final String severity;

  const NeighborhoodWatch({
    required this.id,
    required this.type,
    required this.description,
    required this.location,
    required this.timestamp,
    required this.severity,
  });
}
