import 'package:flutter/material.dart';

// ============================================
// UNIVERSAL MARKETPLACE - BUY & SELL ANYTHING
// ============================================

class MarketplaceCategory {
  final String id;
  final String name;
  final IconData icon;
  final List<String> subcategories;

  const MarketplaceCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.subcategories,
  });
}

class MarketplaceListing {
  final String id;
  final String title;
  final String description;
  final double price;
  final String category;
  final String subcategory;
  final String condition; // new, like-new, good, fair, poor
  final String sellerId;
  final String sellerName;
  final double sellerRating;
  final List<String> images;
  final String location;
  final DateTime postedDate;
  final int views;
  final int favorites;
  final bool negotiable;
  final String deliveryOption; // pickup, delivery, both
  final Map<String, dynamic> specifications;

  const MarketplaceListing({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.category,
    required this.subcategory,
    required this.condition,
    required this.sellerId,
    required this.sellerName,
    required this.sellerRating,
    required this.images,
    required this.location,
    required this.postedDate,
    required this.views,
    required this.favorites,
    required this.negotiable,
    required this.deliveryOption,
    required this.specifications,
  });
}

// VEHICLES
class VehicleListing {
  final String id;
  final String make;
  final String model;
  final int year;
  final int mileage;
  final String fuelType;
  final String transmission;
  final String color;
  final double price;
  final String condition;
  final List<String> features;
  final List<String> images;
  final String sellerId;
  final String location;
  final bool accidentFree;
  final int owners;

  const VehicleListing({
    required this.id,
    required this.make,
    required this.model,
    required this.year,
    required this.mileage,
    required this.fuelType,
    required this.transmission,
    required this.color,
    required this.price,
    required this.condition,
    required this.features,
    required this.images,
    required this.sellerId,
    required this.location,
    required this.accidentFree,
    required this.owners,
  });
}

// ELECTRONICS
class ElectronicsListing {
  final String id;
  final String brand;
  final String model;
  final String category; // phone, laptop, tablet, camera, tv, audio
  final String condition;
  final double price;
  final Map<String, dynamic> specs;
  final bool warranty;
  final DateTime? warrantyExpiry;
  final List<String> accessories;
  final List<String> images;
  final String sellerId;

  const ElectronicsListing({
    required this.id,
    required this.brand,
    required this.model,
    required this.category,
    required this.condition,
    required this.price,
    required this.specs,
    required this.warranty,
    this.warrantyExpiry,
    required this.accessories,
    required this.images,
    required this.sellerId,
  });
}

// REAL ESTATE MARKETPLACE
class RealEstateMarketplace {
  final String id;
  final String type; // sale, rent, commercial, land, roommate
  final String propertyType; // house, apartment, condo, studio, office, warehouse
  final double price;
  final String location;
  final int bedrooms;
  final int bathrooms;
  final double sqft;
  final List<String> amenities;
  final List<String> images;
  final bool furnished;
  final DateTime availableFrom;
  final String sellerId;
  final String agentName;
  final String agentContact;

  const RealEstateMarketplace({
    required this.id,
    required this.type,
    required this.propertyType,
    required this.price,
    required this.location,
    required this.bedrooms,
    required this.bathrooms,
    required this.sqft,
    required this.amenities,
    required this.images,
    required this.furnished,
    required this.availableFrom,
    required this.sellerId,
    required this.agentName,
    required this.agentContact,
  });
}

// FURNITURE & HOME GOODS
class FurnitureListing {
  final String id;
  final String name;
  final String category; // living-room, bedroom, kitchen, outdoor, office
  final String material;
  final String color;
  final Map<String, double> dimensions; // height, width, depth
  final String condition;
  final double price;
  final List<String> images;
  final String sellerId;
  final bool assemblyRequired;

  const FurnitureListing({
    required this.id,
    required this.name,
    required this.category,
    required this.material,
    required this.color,
    required this.dimensions,
    required this.condition,
    required this.price,
    required this.images,
    required this.sellerId,
    required this.assemblyRequired,
  });
}

// FASHION & APPAREL
class FashionListing {
  final String id;
  final String brand;
  final String category; // clothing, shoes, accessories, jewelry
  final String subcategory;
  final String size;
  final String color;
  final String condition;
  final double price;
  final List<String> images;
  final String sellerId;
  final String gender; // male, female, unisex, kids
  final String material;

  const FashionListing({
    required this.id,
    required this.brand,
    required this.category,
    required this.subcategory,
    required this.size,
    required this.color,
    required this.condition,
    required this.price,
    required this.images,
    required this.sellerId,
    required this.gender,
    required this.material,
  });
}

// BOOKS & MEDIA
class BookListing {
  final String id;
  final String title;
  final String author;
  final String isbn;
  final String condition;
  final double price;
  final String category; // fiction, non-fiction, textbook, comics
  final String language;
  final int pages;
  final List<String> images;
  final String sellerId;

  const BookListing({
    required this.id,
    required this.title,
    required this.author,
    required this.isbn,
    required this.condition,
    required this.price,
    required this.category,
    required this.language,
    required this.pages,
    required this.images,
    required this.sellerId,
  });
}

// SPORTS & FITNESS
class SportsListing {
  final String id;
  final String name;
  final String category; // equipment, apparel, bikes, outdoor
  final String condition;
  final double price;
  final String brand;
  final List<String> images;
  final String sellerId;

  const SportsListing({
    required this.id,
    required this.name,
    required this.category,
    required this.condition,
    required this.price,
    required this.brand,
    required this.images,
    required this.sellerId,
  });
}

// TOYS & GAMES
class ToysListing {
  final String id;
  final String name;
  final String category; // action-figures, board-games, puzzles, video-games
  final String ageRange;
  final String condition;
  final double price;
  final List<String> images;
  final String sellerId;

  const ToysListing({
    required this.id,
    required this.name,
    required this.category,
    required this.ageRange,
    required this.condition,
    required this.price,
    required this.images,
    required this.sellerId,
  });
}

// TOOLS & EQUIPMENT
class ToolsListing {
  final String id;
  final String name;
  final String category; // power-tools, hand-tools, garden, industrial
  final String brand;
  final String condition;
  final double price;
  final bool electric;
  final List<String> images;
  final String sellerId;

  const ToolsListing({
    required this.id,
    required this.name,
    required this.category,
    required this.brand,
    required this.condition,
    required this.price,
    required this.electric,
    required this.images,
    required this.sellerId,
  });
}

// BUSINESS EQUIPMENT
class BusinessEquipmentListing {
  final String id;
  final String name;
  final String category; // office, restaurant, retail, industrial, medical
  final String condition;
  final double price;
  final Map<String, dynamic> specifications;
  final List<String> images;
  final String sellerId;
  final bool warranty;

  const BusinessEquipmentListing({
    required this.id,
    required this.name,
    required this.category,
    required this.condition,
    required this.price,
    required this.specifications,
    required this.images,
    required this.sellerId,
    required this.warranty,
  });
}

// AUCTIONS
class AuctionListing {
  final String id;
  final String title;
  final String description;
  final double startingBid;
  final double currentBid;
  final int totalBids;
  final DateTime endTime;
  final String category;
  final List<String> images;
  final String sellerId;
  final double? reservePrice;

  const AuctionListing({
    required this.id,
    required this.title,
    required this.description,
    required this.startingBid,
    required this.currentBid,
    required this.totalBids,
    required this.endTime,
    required this.category,
    required this.images,
    required this.sellerId,
    this.reservePrice,
  });
}

class Bid {
  final String id;
  final String auctionId;
  final String bidderId;
  final double amount;
  final DateTime timestamp;

  const Bid({
    required this.id,
    required this.auctionId,
    required this.bidderId,
    required this.amount,
    required this.timestamp,
  });
}

// FREE STUFF
class FreeStuffListing {
  final String id;
  final String title;
  final String description;
  final String category;
  final String condition;
  final List<String> images;
  final String giverId;
  final String location;
  final DateTime postedDate;

  const FreeStuffListing({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.condition,
    required this.images,
    required this.giverId,
    required this.location,
    required this.postedDate,
  });
}

// BARTER / TRADE
class BarterListing {
  final String id;
  final String offering;
  final String lookingFor;
  final String category;
  final String description;
  final List<String> images;
  final String userId;
  final String location;
  final DateTime postedDate;

  const BarterListing({
    required this.id,
    required this.offering,
    required this.lookingFor,
    required this.category,
    required this.description,
    required this.images,
    required this.userId,
    required this.location,
    required this.postedDate,
  });
}

// SERVICE MARKETPLACE
class ServiceMarketplace {
  final String id;
  final String title;
  final String category; // handyman, cleaning, tutoring, design, consulting
  final String description;
  final double hourlyRate;
  final String providerId;
  final String providerName;
  final double rating;
  final int completedJobs;
  final List<String> skills;
  final List<String> portfolio;
  final String availability;

  const ServiceMarketplace({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.hourlyRate,
    required this.providerId,
    required this.providerName,
    required this.rating,
    required this.completedJobs,
    required this.skills,
    required this.portfolio,
    required this.availability,
  });
}

// WANTED ADS
class WantedListing {
  final String id;
  final String title;
  final String description;
  final String category;
  final double? maxBudget;
  final String location;
  final String buyerId;
  final DateTime postedDate;

  const WantedListing({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    this.maxBudget,
    required this.location,
    required this.buyerId,
    required this.postedDate,
  });
}

// REVIEWS & RATINGS
class MarketplaceReview {
  final String id;
  final String listingId;
  final String reviewerId;
  final double rating;
  final String comment;
  final DateTime date;
  final List<String> images;

  const MarketplaceReview({
    required this.id,
    required this.listingId,
    required this.reviewerId,
    required this.rating,
    required this.comment,
    required this.date,
    required this.images,
  });
}

// SAVED SEARCHES
class SavedSearch {
  final String id;
  final String name;
  final String category;
  final Map<String, dynamic> filters;
  final bool notifications;

  const SavedSearch({
    required this.id,
    required this.name,
    required this.category,
    required this.filters,
    required this.notifications,
  });
}
