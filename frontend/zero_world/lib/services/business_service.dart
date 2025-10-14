/// Business Service
/// Complete REST API integration for business management

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/business.dart';

class BusinessService {
  final String baseUrl;
  String? _authToken;

  BusinessService({this.baseUrl = 'http://localhost:8000/api'});

  void setAuthToken(String token) {
    _authToken = token;
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };

  // ===== DASHBOARD & METRICS =====

  /// Get business metrics
  Future<BusinessMetrics> getMetrics({String period = 'month'}) async {
    try {
      final uri = Uri.parse('$baseUrl/business/metrics')
          .replace(queryParameters: {'period': period});
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        return BusinessMetrics.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load metrics: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading metrics: $e');
    }
  }

  /// Get sales history
  Future<List<DailySales>> getSalesHistory({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (startDate != null) queryParams['start_date'] = startDate.toIso8601String();
      if (endDate != null) queryParams['end_date'] = endDate.toIso8601String();

      final uri = Uri.parse('$baseUrl/business/sales-history')
          .replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        return data.map((json) => DailySales.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load sales history: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading sales history: $e');
    }
  }

  // ===== STOREFRONT =====

  /// Get storefront
  Future<Storefront> getStorefront(String storefrontId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/business/storefronts/$storefrontId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return Storefront.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load storefront: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading storefront: $e');
    }
  }

  /// Create storefront
  Future<Storefront> createStorefront({
    required String name,
    String? description,
    String? logo,
    String? banner,
    String? domain,
    Map<String, dynamic>? theme,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/business/storefronts'),
        headers: _headers,
        body: json.encode({
          'name': name,
          'description': description,
          'logo': logo,
          'banner': banner,
          'domain': domain,
          'theme': theme,
        }),
      );

      if (response.statusCode == 201) {
        return Storefront.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create storefront: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating storefront: $e');
    }
  }

  /// Update storefront
  Future<Storefront> updateStorefront(String storefrontId, Map<String, dynamic> updates) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/business/storefronts/$storefrontId'),
        headers: _headers,
        body: json.encode(updates),
      );

      if (response.statusCode == 200) {
        return Storefront.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to update storefront: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating storefront: $e');
    }
  }

  /// Delete storefront
  Future<void> deleteStorefront(String storefrontId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/business/storefronts/$storefrontId'),
        headers: _headers,
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete storefront: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting storefront: $e');
    }
  }

  // ===== TEAM MANAGEMENT =====

  /// Get team members
  Future<List<TeamMember>> getTeamMembers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/business/team'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        return data.map((json) => TeamMember.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load team: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading team: $e');
    }
  }

  /// Add team member
  Future<TeamMember> addTeamMember({
    required String email,
    required TeamRole role,
    List<String>? permissions,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/business/team'),
        headers: _headers,
        body: json.encode({
          'email': email,
          'role': role.name,
          'permissions': permissions,
        }),
      );

      if (response.statusCode == 201) {
        return TeamMember.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to add team member: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error adding team member: $e');
    }
  }

  /// Update team member
  Future<TeamMember> updateTeamMember(String memberId, Map<String, dynamic> updates) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/business/team/$memberId'),
        headers: _headers,
        body: json.encode(updates),
      );

      if (response.statusCode == 200) {
        return TeamMember.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to update team member: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating team member: $e');
    }
  }

  /// Remove team member
  Future<void> removeTeamMember(String memberId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/business/team/$memberId'),
        headers: _headers,
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to remove team member: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error removing team member: $e');
    }
  }

  // ===== CRM (CUSTOMER RELATIONSHIP MANAGEMENT) =====

  /// Get customers
  Future<List<Customer>> getCustomers({
    String? search,
    String? status,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (search != null) 'search': search,
        if (status != null) 'status': status,
      };
      final uri = Uri.parse('$baseUrl/business/customers')
          .replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        return data.map((json) => Customer.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load customers: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading customers: $e');
    }
  }

  /// Get customer by ID
  Future<Customer> getCustomer(String customerId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/business/customers/$customerId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return Customer.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load customer: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading customer: $e');
    }
  }

  /// Create customer
  Future<Customer> createCustomer({
    required String name,
    required String email,
    String? phone,
    String? address,
    String? city,
    String? country,
    List<String>? tags,
    String? notes,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/business/customers'),
        headers: _headers,
        body: json.encode({
          'name': name,
          'email': email,
          'phone': phone,
          'address': address,
          'city': city,
          'country': country,
          'tags': tags,
          'notes': notes,
        }),
      );

      if (response.statusCode == 201) {
        return Customer.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create customer: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating customer: $e');
    }
  }

  /// Update customer
  Future<Customer> updateCustomer(String customerId, Map<String, dynamic> updates) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/business/customers/$customerId'),
        headers: _headers,
        body: json.encode(updates),
      );

      if (response.statusCode == 200) {
        return Customer.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to update customer: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating customer: $e');
    }
  }

  /// Delete customer
  Future<void> deleteCustomer(String customerId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/business/customers/$customerId'),
        headers: _headers,
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete customer: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting customer: $e');
    }
  }

  // ===== INVOICES =====

  /// Get invoices
  Future<List<Invoice>> getInvoices({
    String? status,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (status != null) 'status': status,
      };
      final uri = Uri.parse('$baseUrl/business/invoices')
          .replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        return data.map((json) => Invoice.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load invoices: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading invoices: $e');
    }
  }

  /// Get invoice by ID
  Future<Invoice> getInvoice(String invoiceId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/business/invoices/$invoiceId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return Invoice.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load invoice: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading invoice: $e');
    }
  }

  /// Create invoice
  Future<Invoice> createInvoice({
    required String customerId,
    required DateTime dueDate,
    required List<InvoiceItem> items,
    double discount = 0,
    double tax = 0,
    String? notes,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/business/invoices'),
        headers: _headers,
        body: json.encode({
          'customer_id': customerId,
          'due_date': dueDate.toIso8601String(),
          'items': items.map((i) => i.toJson()).toList(),
          'discount': discount,
          'tax': tax,
          'notes': notes,
        }),
      );

      if (response.statusCode == 201) {
        return Invoice.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create invoice: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating invoice: $e');
    }
  }

  /// Update invoice
  Future<Invoice> updateInvoice(String invoiceId, Map<String, dynamic> updates) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/business/invoices/$invoiceId'),
        headers: _headers,
        body: json.encode(updates),
      );

      if (response.statusCode == 200) {
        return Invoice.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to update invoice: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating invoice: $e');
    }
  }

  /// Send invoice
  Future<void> sendInvoice(String invoiceId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/business/invoices/$invoiceId/send'),
        headers: _headers,
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to send invoice: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error sending invoice: $e');
    }
  }

  /// Mark invoice as paid
  Future<Invoice> markInvoicePaid(String invoiceId, String paymentMethod) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/business/invoices/$invoiceId/pay'),
        headers: _headers,
        body: json.encode({'payment_method': paymentMethod}),
      );

      if (response.statusCode == 200) {
        return Invoice.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to mark invoice as paid: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error marking invoice as paid: $e');
    }
  }

  /// Delete invoice
  Future<void> deleteInvoice(String invoiceId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/business/invoices/$invoiceId'),
        headers: _headers,
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete invoice: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting invoice: $e');
    }
  }

  // ===== ANALYTICS =====

  /// Get analytics data
  Future<AnalyticsData> getAnalytics({String period = 'week'}) async {
    try {
      final uri = Uri.parse('$baseUrl/business/analytics')
          .replace(queryParameters: {'period': period});
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        return AnalyticsData.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load analytics: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading analytics: $e');
    }
  }

  /// Get traffic sources
  Future<Map<String, int>> getTrafficSources({String period = 'week'}) async {
    try {
      final uri = Uri.parse('$baseUrl/business/analytics/traffic')
          .replace(queryParameters: {'period': period});
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        return Map<String, int>.from(json.decode(response.body) as Map);
      } else {
        throw Exception('Failed to load traffic sources: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading traffic sources: $e');
    }
  }

  /// Get device breakdown
  Future<Map<String, int>> getDeviceBreakdown({String period = 'week'}) async {
    try {
      final uri = Uri.parse('$baseUrl/business/analytics/devices')
          .replace(queryParameters: {'period': period});
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        return Map<String, int>.from(json.decode(response.body) as Map);
      } else {
        throw Exception('Failed to load device breakdown: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading device breakdown: $e');
    }
  }

  // ===== REPORTS =====

  /// Generate sales report
  Future<Map<String, dynamic>> generateSalesReport({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/business/reports/sales').replace(
        queryParameters: {
          'start_date': startDate.toIso8601String(),
          'end_date': endDate.toIso8601String(),
        },
      );
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to generate report: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error generating report: $e');
    }
  }

  /// Generate customer report
  Future<Map<String, dynamic>> generateCustomerReport() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/business/reports/customers'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to generate report: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error generating report: $e');
    }
  }
}
