import 'package:flutter/material.dart';

class ServiceCategory {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final List<Service> services;

  ServiceCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.services,
  });
}

class Service {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final String route;
  final bool isActive;

  Service({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.route,
    this.isActive = true,
  });
}

class DeliveryOrder {
  final String id;
  final String restaurantName;
  final String restaurantAddress;
  final List<OrderItem> items;
  final double totalAmount;
  final String status;
  final DateTime orderTime;
  final String deliveryAddress;
  final String? estimatedDelivery;

  DeliveryOrder({
    required this.id,
    required this.restaurantName,
    required this.restaurantAddress,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.orderTime,
    required this.deliveryAddress,
    this.estimatedDelivery,
  });
}

class OrderItem {
  final String name;
  final int quantity;
  final double price;

  OrderItem({
    required this.name,
    required this.quantity,
    required this.price,
  });
}

class BookingService {
  final String id;
  final String name;
  final String category;
  final String description;
  final double rating;
  final double price;
  final String imageUrl;
  final List<String> availableSlots;

  BookingService({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.rating,
    required this.price,
    required this.imageUrl,
    required this.availableSlots,
  });
}

class Booking {
  final String id;
  final String serviceId;
  final String serviceName;
  final DateTime dateTime;
  final String status;
  final double amount;
  final String customerName;
  final String customerPhone;

  Booking({
    required this.id,
    required this.serviceId,
    required this.serviceName,
    required this.dateTime,
    required this.status,
    required this.amount,
    required this.customerName,
    required this.customerPhone,
  });
}

class SocialPost {
  final String id;
  final String authorName;
  final String authorAvatar;
  final String content;
  final List<String> images;
  final DateTime timestamp;
  final int likes;
  final int comments;
  final bool isLiked;

  SocialPost({
    required this.id,
    required this.authorName,
    required this.authorAvatar,
    required this.content,
    required this.images,
    required this.timestamp,
    required this.likes,
    required this.comments,
    required this.isLiked,
  });
}

class PaymentMethod {
  final String id;
  final String name;
  final IconData icon;
  final String details;
  final bool isDefault;

  PaymentMethod({
    required this.id,
    required this.name,
    required this.icon,
    required this.details,
    required this.isDefault,
  });
}

class Transaction {
  final String id;
  final String type;
  final double amount;
  final String description;
  final DateTime timestamp;
  final String status;

  Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.description,
    required this.timestamp,
    required this.status,
  });
}