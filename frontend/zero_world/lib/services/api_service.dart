import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/chat.dart';
import '../models/community.dart';
import '../models/listing.dart';
import '../models/message.dart';
import '../models/user.dart';

class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiService {
  ApiService({http.Client? client, String? baseUrl})
    : httpClient = client ?? http.Client(),
      baseUrl = baseUrl ?? ApiConfig.baseUrl {
    // Print configuration on first initialization (debug mode only)
    if (kDebugMode && !_configPrinted) {
      ApiConfig.printConfig();
      _configPrinted = true;
    }
  }

  static bool _configPrinted = false;
  final http.Client httpClient;
  final String baseUrl;

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$baseUrl$normalizedPath').replace(queryParameters: query);
  }

  Map<String, String> _jsonHeaders({String? token}) => {
    'Content-Type': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };

  Map<String, String> _authHeaders(String token) => {
    'Authorization': 'Bearer $token',
  };

  Future<void> _throwIfError(http.Response response) async {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }
    String message = 'Request failed (${response.statusCode})';
    try {
      final Map<String, dynamic> body =
          jsonDecode(response.body) as Map<String, dynamic>;
      message = body['detail']?.toString() ?? message;
    } catch (_) {
      message = response.body.isNotEmpty ? response.body : message;
    }
    throw ApiException(message, statusCode: response.statusCode);
  }

  Future<User> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await httpClient.post(
      _uri('/auth/register'),
      headers: _jsonHeaders(),
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );
    await _throwIfError(response);
    final Map<String, dynamic> data =
        jsonDecode(response.body) as Map<String, dynamic>;
    return User.fromJson(data);
  }

  Future<String> login({
    required String email,
    required String password,
  }) async {
    final response = await httpClient.post(
      _uri('/auth/login'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {'username': email, 'password': password},
    );
    await _throwIfError(response);
    final Map<String, dynamic> data =
        jsonDecode(response.body) as Map<String, dynamic>;
    return data['access_token']?.toString() ?? '';
  }

  Future<User> fetchProfile(String token) async {
    final response = await httpClient.get(
      _uri('/auth/me'),
      headers: _authHeaders(token),
    );
    await _throwIfError(response);
    final Map<String, dynamic> data =
        jsonDecode(response.body) as Map<String, dynamic>;
    return User.fromJson(data);
  }

  Future<List<Listing>> fetchListings({int limit = 50}) async {
    final response = await httpClient.get(
      _uri('/listings/', {'limit': '$limit'}),
    );
    await _throwIfError(response);
    final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((e) => Listing.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Listing> createListing({
    required String token,
    required String title,
    required String description,
    required double price,
    String? category,
    String? location,
    List<String>? imageUrls,
  }) async {
    final response = await httpClient.post(
      _uri('/listings/'),
      headers: _jsonHeaders(token: token),
      body: jsonEncode({
        'title': title,
        'description': description,
        'price': price,
        if (category?.isNotEmpty ?? false) 'category': category,
        if (location?.isNotEmpty ?? false) 'location': location,
        if (imageUrls != null && imageUrls.isNotEmpty) 'image_urls': imageUrls,
      }),
    );
    await _throwIfError(response);
    final Map<String, dynamic> data =
        jsonDecode(response.body) as Map<String, dynamic>;
    return Listing.fromJson(data);
  }

  Future<List<Chat>> fetchChats(String token) async {
    final response = await httpClient.get(
      _uri('/chat/'),
      headers: _authHeaders(token),
    );
    await _throwIfError(response);
    final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((chat) => Chat.fromJson(chat as Map<String, dynamic>))
        .toList();
  }

  Future<Chat> startChat({
    required String token,
    required String participantId,
  }) async {
    final response = await httpClient.post(
      _uri('/chat/'),
      headers: _jsonHeaders(token: token),
      body: jsonEncode({'participant_id': participantId}),
    );
    await _throwIfError(response);
    final Map<String, dynamic> data =
        jsonDecode(response.body) as Map<String, dynamic>;
    return Chat.fromJson(data);
  }

  Future<List<Message>> fetchMessages({
    required String token,
    required String chatId,
  }) async {
    final response = await httpClient.get(
      _uri('/chat/$chatId/messages'),
      headers: _authHeaders(token),
    );
    await _throwIfError(response);
    final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((message) => Message.fromJson(message as Map<String, dynamic>))
        .toList();
  }

  Future<Message> sendMessage({
    required String token,
    required String chatId,
    required String content,
  }) async {
    final response = await httpClient.post(
      _uri('/chat/$chatId/messages'),
      headers: _jsonHeaders(token: token),
      body: jsonEncode({'content': content}),
    );
    await _throwIfError(response);
    final Map<String, dynamic> data =
        jsonDecode(response.body) as Map<String, dynamic>;
    return Message.fromJson(data);
  }

  Future<List<CommunityPost>> fetchCommunityPosts({String? tag}) async {
    final response = await httpClient.get(
      _uri(
        '/community/posts',
        tag != null && tag.isNotEmpty ? {'tag': tag} : null,
      ),
    );
    await _throwIfError(response);
    final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((post) => CommunityPost.fromJson(post as Map<String, dynamic>))
        .toList();
  }

  Future<CommunityPost> createCommunityPost({
    required String token,
    required String title,
    required String content,
    List<String> tags = const [],
  }) async {
    final response = await httpClient.post(
      _uri('/community/posts'),
      headers: _jsonHeaders(token: token),
      body: jsonEncode({'title': title, 'content': content, 'tags': tags}),
    );
    await _throwIfError(response);
    final Map<String, dynamic> data =
        jsonDecode(response.body) as Map<String, dynamic>;
    return CommunityPost.fromJson(data);
  }

  Future<List<CommunityComment>> fetchComments(String postId) async {
    final response = await httpClient.get(
      _uri('/community/posts/$postId/comments'),
    );
    await _throwIfError(response);
    final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map(
          (comment) =>
              CommunityComment.fromJson(comment as Map<String, dynamic>),
        )
        .toList();
  }

  Future<CommunityComment> addComment({
    required String token,
    required String postId,
    required String content,
  }) async {
    final response = await httpClient.post(
      _uri('/community/posts/$postId/comments'),
      headers: _jsonHeaders(token: token),
      body: jsonEncode({'content': content}),
    );
    await _throwIfError(response);
    final Map<String, dynamic> data =
        jsonDecode(response.body) as Map<String, dynamic>;
    return CommunityComment.fromJson(data);
  }

  Future<Chat> startListingChat({
    required String listingId,
    required String token,
  }) async {
    final response = await httpClient.post(
      _uri('/chat/listing/$listingId'),
      headers: _jsonHeaders(token: token),
    );
    await _throwIfError(response);
    final Map<String, dynamic> data =
        jsonDecode(response.body) as Map<String, dynamic>;
    return Chat.fromJson(data);
  }

  void dispose() {
    if (!kIsWeb) {
      httpClient.close();
    }
  }
}
