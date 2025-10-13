import 'package:flutter/foundation.dart';

import '../models/listing.dart';
import '../services/api_service.dart';

class ListingsState extends ChangeNotifier {
  ListingsState(this._apiService);

  final ApiService _apiService;

  final List<Listing> _listings = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _hasLoadedOnce = false;

  List<Listing> get listings => List.unmodifiable(_listings);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasLoadedOnce => _hasLoadedOnce;

  Future<void> ensureLoaded() async {
    if (_hasLoadedOnce || _isLoading) {
      return;
    }
    await refresh();
  }

  Future<void> refresh() async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final items = await _apiService.fetchListings();
      _listings
        ..clear()
        ..addAll(items);
      _hasLoadedOnce = true;
    } on ApiException catch (error) {
      _setError(error.message);
    } catch (error) {
      _setError('Something went wrong: $error');
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    if (_isLoading != value) {
      _isLoading = value;
      notifyListeners();
    }
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }
}
