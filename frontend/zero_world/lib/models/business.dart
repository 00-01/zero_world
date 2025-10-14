/// Business Management Models
/// Complete business platform data structures

/// Business Dashboard Metrics
class BusinessMetrics {
  final double totalRevenue;
  final double monthlyRevenue;
  final int totalOrders;
  final int pendingOrders;
  final int totalProducts;
  final int totalCustomers;
  final double averageOrderValue;
  final double conversionRate;
  final Map<String, double> revenueByCategory;
  final List<DailySales> salesHistory;

  const BusinessMetrics({
    required this.totalRevenue,
    required this.monthlyRevenue,
    required this.totalOrders,
    required this.pendingOrders,
    required this.totalProducts,
    required this.totalCustomers,
    required this.averageOrderValue,
    required this.conversionRate,
    this.revenueByCategory = const {},
    this.salesHistory = const [],
  });

  factory BusinessMetrics.fromJson(Map<String, dynamic> json) {
    return BusinessMetrics(
      totalRevenue: (json['total_revenue'] as num).toDouble(),
      monthlyRevenue: (json['monthly_revenue'] as num).toDouble(),
      totalOrders: json['total_orders'] as int,
      pendingOrders: json['pending_orders'] as int,
      totalProducts: json['total_products'] as int,
      totalCustomers: json['total_customers'] as int,
      averageOrderValue: (json['average_order_value'] as num).toDouble(),
      conversionRate: (json['conversion_rate'] as num).toDouble(),
      revenueByCategory: json['revenue_by_category'] != null ? Map<String, double>.from(json['revenue_by_category'] as Map) : {},
      salesHistory: json['sales_history'] != null ? (json['sales_history'] as List).map((s) => DailySales.fromJson(s as Map<String, dynamic>)).toList() : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_revenue': totalRevenue,
      'monthly_revenue': monthlyRevenue,
      'total_orders': totalOrders,
      'pending_orders': pendingOrders,
      'total_products': totalProducts,
      'total_customers': totalCustomers,
      'average_order_value': averageOrderValue,
      'conversion_rate': conversionRate,
      'revenue_by_category': revenueByCategory,
      'sales_history': salesHistory.map((s) => s.toJson()).toList(),
    };
  }
}

/// Daily Sales Data
class DailySales {
  final DateTime date;
  final double revenue;
  final int orders;

  const DailySales({
    required this.date,
    required this.revenue,
    required this.orders,
  });

  factory DailySales.fromJson(Map<String, dynamic> json) {
    return DailySales(
      date: DateTime.parse(json['date'] as String),
      revenue: (json['revenue'] as num).toDouble(),
      orders: json['orders'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'revenue': revenue,
      'orders': orders,
    };
  }
}

/// Storefront Model
class Storefront {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final String? logo;
  final String? banner;
  final String? domain;
  final Map<String, dynamic> theme;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastUpdated;

  const Storefront({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    this.logo,
    this.banner,
    this.domain,
    this.theme = const {},
    this.isActive = true,
    required this.createdAt,
    this.lastUpdated,
  });

  factory Storefront.fromJson(Map<String, dynamic> json) {
    return Storefront(
      id: json['_id'] as String? ?? json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      logo: json['logo'] as String?,
      banner: json['banner'] as String?,
      domain: json['domain'] as String?,
      theme: json['theme'] as Map<String, dynamic>? ?? {},
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      lastUpdated: json['last_updated'] != null ? DateTime.parse(json['last_updated'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'description': description,
      'logo': logo,
      'banner': banner,
      'domain': domain,
      'theme': theme,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'last_updated': lastUpdated?.toIso8601String(),
    };
  }
}

/// Team Member Model
class TeamMember {
  final String id;
  final String userId;
  final String name;
  final String email;
  final String? photo;
  final TeamRole role;
  final List<String> permissions;
  final bool isActive;
  final DateTime joinedAt;

  const TeamMember({
    required this.id,
    required this.userId,
    required this.name,
    required this.email,
    this.photo,
    required this.role,
    this.permissions = const [],
    this.isActive = true,
    required this.joinedAt,
  });

  factory TeamMember.fromJson(Map<String, dynamic> json) {
    return TeamMember(
      id: json['_id'] as String? ?? json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      photo: json['photo'] as String?,
      role: TeamRole.values.byName(json['role'] as String),
      permissions: json['permissions'] != null ? List<String>.from(json['permissions'] as List) : [],
      isActive: json['is_active'] as bool? ?? true,
      joinedAt: DateTime.parse(json['joined_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'email': email,
      'photo': photo,
      'role': role.name,
      'permissions': permissions,
      'is_active': isActive,
      'joined_at': joinedAt.toIso8601String(),
    };
  }
}

/// Team Role
enum TeamRole {
  owner,
  admin,
  manager,
  sales,
  support,
  viewer,
}

/// Customer Model (CRM)
class Customer {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? photo;
  final String? address;
  final String? city;
  final String? country;
  final double totalSpent;
  final int orderCount;
  final DateTime? lastOrderDate;
  final String status; // active, inactive, vip
  final List<String> tags;
  final String? notes;
  final DateTime createdAt;

  const Customer({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.photo,
    this.address,
    this.city,
    this.country,
    this.totalSpent = 0,
    this.orderCount = 0,
    this.lastOrderDate,
    this.status = 'active',
    this.tags = const [],
    this.notes,
    required this.createdAt,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['_id'] as String? ?? json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      photo: json['photo'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      country: json['country'] as String?,
      totalSpent: json['total_spent'] != null ? (json['total_spent'] as num).toDouble() : 0,
      orderCount: json['order_count'] as int? ?? 0,
      lastOrderDate: json['last_order_date'] != null ? DateTime.parse(json['last_order_date'] as String) : null,
      status: json['status'] as String? ?? 'active',
      tags: json['tags'] != null ? List<String>.from(json['tags'] as List) : [],
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'photo': photo,
      'address': address,
      'city': city,
      'country': country,
      'total_spent': totalSpent,
      'order_count': orderCount,
      'last_order_date': lastOrderDate?.toIso8601String(),
      'status': status,
      'tags': tags,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

/// Invoice Model
class Invoice {
  final String id;
  final String businessId;
  final String customerId;
  final String customerName;
  final String? customerEmail;
  final String invoiceNumber;
  final DateTime issueDate;
  final DateTime dueDate;
  final List<InvoiceItem> items;
  final double subtotal;
  final double tax;
  final double discount;
  final double total;
  final String status; // draft, sent, paid, overdue, cancelled
  final String? notes;
  final String? paymentMethod;
  final DateTime? paidAt;
  final DateTime createdAt;

  const Invoice({
    required this.id,
    required this.businessId,
    required this.customerId,
    required this.customerName,
    this.customerEmail,
    required this.invoiceNumber,
    required this.issueDate,
    required this.dueDate,
    required this.items,
    required this.subtotal,
    required this.tax,
    this.discount = 0,
    required this.total,
    this.status = 'draft',
    this.notes,
    this.paymentMethod,
    this.paidAt,
    required this.createdAt,
  });

  bool get isPaid => status == 'paid';
  bool get isOverdue => status != 'paid' && DateTime.now().isAfter(dueDate);

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['_id'] as String? ?? json['id'] as String,
      businessId: json['business_id'] as String,
      customerId: json['customer_id'] as String,
      customerName: json['customer_name'] as String,
      customerEmail: json['customer_email'] as String?,
      invoiceNumber: json['invoice_number'] as String,
      issueDate: DateTime.parse(json['issue_date'] as String),
      dueDate: DateTime.parse(json['due_date'] as String),
      items: (json['items'] as List).map((i) => InvoiceItem.fromJson(i as Map<String, dynamic>)).toList(),
      subtotal: (json['subtotal'] as num).toDouble(),
      tax: (json['tax'] as num).toDouble(),
      discount: json['discount'] != null ? (json['discount'] as num).toDouble() : 0,
      total: (json['total'] as num).toDouble(),
      status: json['status'] as String? ?? 'draft',
      notes: json['notes'] as String?,
      paymentMethod: json['payment_method'] as String?,
      paidAt: json['paid_at'] != null ? DateTime.parse(json['paid_at'] as String) : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'business_id': businessId,
      'customer_id': customerId,
      'customer_name': customerName,
      'customer_email': customerEmail,
      'invoice_number': invoiceNumber,
      'issue_date': issueDate.toIso8601String(),
      'due_date': dueDate.toIso8601String(),
      'items': items.map((i) => i.toJson()).toList(),
      'subtotal': subtotal,
      'tax': tax,
      'discount': discount,
      'total': total,
      'status': status,
      'notes': notes,
      'payment_method': paymentMethod,
      'paid_at': paidAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}

/// Invoice Item
class InvoiceItem {
  final String description;
  final int quantity;
  final double unitPrice;
  final double total;

  const InvoiceItem({
    required this.description,
    required this.quantity,
    required this.unitPrice,
    required this.total,
  });

  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
      description: json['description'] as String,
      quantity: json['quantity'] as int,
      unitPrice: (json['unit_price'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total': total,
    };
  }
}

/// Analytics Data
class AnalyticsData {
  final String period; // today, week, month, year
  final int visitors;
  final int pageViews;
  final int uniqueVisitors;
  final double bounceRate;
  final Duration avgSessionDuration;
  final Map<String, int> topPages;
  final Map<String, int> trafficSources;
  final Map<String, int> deviceTypes;
  final List<HourlyTraffic> hourlyTraffic;

  const AnalyticsData({
    required this.period,
    required this.visitors,
    required this.pageViews,
    required this.uniqueVisitors,
    required this.bounceRate,
    required this.avgSessionDuration,
    this.topPages = const {},
    this.trafficSources = const {},
    this.deviceTypes = const {},
    this.hourlyTraffic = const [],
  });

  factory AnalyticsData.fromJson(Map<String, dynamic> json) {
    return AnalyticsData(
      period: json['period'] as String,
      visitors: json['visitors'] as int,
      pageViews: json['page_views'] as int,
      uniqueVisitors: json['unique_visitors'] as int,
      bounceRate: (json['bounce_rate'] as num).toDouble(),
      avgSessionDuration: Duration(seconds: json['avg_session_duration'] as int),
      topPages: json['top_pages'] != null ? Map<String, int>.from(json['top_pages'] as Map) : {},
      trafficSources: json['traffic_sources'] != null ? Map<String, int>.from(json['traffic_sources'] as Map) : {},
      deviceTypes: json['device_types'] != null ? Map<String, int>.from(json['device_types'] as Map) : {},
      hourlyTraffic: json['hourly_traffic'] != null ? (json['hourly_traffic'] as List).map((h) => HourlyTraffic.fromJson(h as Map<String, dynamic>)).toList() : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'period': period,
      'visitors': visitors,
      'page_views': pageViews,
      'unique_visitors': uniqueVisitors,
      'bounce_rate': bounceRate,
      'avg_session_duration': avgSessionDuration.inSeconds,
      'top_pages': topPages,
      'traffic_sources': trafficSources,
      'device_types': deviceTypes,
      'hourly_traffic': hourlyTraffic.map((h) => h.toJson()).toList(),
    };
  }
}

/// Hourly Traffic
class HourlyTraffic {
  final int hour;
  final int visitors;

  const HourlyTraffic({
    required this.hour,
    required this.visitors,
  });

  factory HourlyTraffic.fromJson(Map<String, dynamic> json) {
    return HourlyTraffic(
      hour: json['hour'] as int,
      visitors: json['visitors'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hour': hour,
      'visitors': visitors,
    };
  }
}
