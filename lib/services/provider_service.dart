import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/provider_model.dart';

class ProviderService extends ChangeNotifier {
  final String _baseUrl = '${ApiConfig.baseUrl}/providers';
  List<ProviderModel> _providers = [];
  ProviderModel? _selectedProvider;
  bool _isLoading = false;
  String? _error;

  List<ProviderModel> get providers => _providers;
  ProviderModel? get selectedProvider => _selectedProvider;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<ProviderListResponse> getProviders(Map<String, dynamic> filters) async {
    try {
      final queryParams = {
        if (filters['name'] != null) 'name': filters['name'],
        if (filters['city'] != null) 'city': filters['city'],
        if (filters['state'] != null) 'state': filters['state'],
        if (filters['rating'] != null) 'rating': filters['rating'].toString(),
        if (filters['minPlans'] != null) 'minPlans': filters['minPlans'].toString(),
        if (filters['maxPlans'] != null) 'maxPlans': filters['maxPlans'].toString(),
        'page': (filters['page'] ?? 1).toString(),
        'limit': (filters['limit'] ?? 10).toString(),
      };

      final uri = Uri.parse(_baseUrl).replace(queryParameters: queryParams);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          final List<ProviderModel> providers = (data['data'] as List)
              .map((json) => ProviderModel.fromJson(json))
              .toList();

          if (filters['page'] == 1) {
            _providers = providers;
          } else {
            _providers.addAll(providers);
          }

          notifyListeners();

          return ProviderListResponse(
            providers: providers,
            pagination: PaginationData(
              total: data['pagination']['total'],
              page: data['pagination']['page'],
              totalPages: data['pagination']['totalPages'],
            ),
          );
        }
      }
      throw ApiException('Failed to fetch providers');
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<ProviderModel> getProviderDetails(String providerId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await http.get(Uri.parse('$_baseUrl/$providerId'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          _selectedProvider = ProviderModel.fromJson(data['data']);
          notifyListeners();
          return _selectedProvider!;
        }
      }
      throw ApiException('Failed to fetch provider details');
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Map<String, dynamic>>> getProviderReviews(
    String providerId, {
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/$providerId/reviews').replace(
          queryParameters: {
            'page': page.toString(),
            'limit': limit.toString(),
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          return List<Map<String, dynamic>>.from(data['data']);
        }
      }
      throw ApiException('Failed to fetch provider reviews');
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> addProviderReview(
    String providerId, {
    required int rating,
    String? comment,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/$providerId/reviews'),
        body: json.encode({
          'rating': rating,
          'comment': comment,
        }),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['success']) {
          // Refresh provider details to update rating
          await getProviderDetails(providerId);
          return;
        }
      }
      throw ApiException('Failed to add review');
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getProviderPlans(String providerId) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/$providerId/plans'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          return List<Map<String, dynamic>>.from(data['data']);
        }
      }
      throw ApiException('Failed to fetch provider plans');
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getProviderHospitals(
    String providerId, {
    Map<String, dynamic>? filters,
  }) async {
    try {
      final queryParams = {
        if (filters?['city'] != null) 'city': filters!['city'],
        if (filters?['state'] != null) 'state': filters!['state'],
        if (filters?['rating'] != null) 'rating': filters!['rating'].toString(),
        'page': (filters?['page'] ?? 1).toString(),
        'limit': (filters?['limit'] ?? 10).toString(),
      };

      final response = await http.get(
        Uri.parse('$_baseUrl/$providerId/hospitals').replace(
          queryParameters: queryParams,
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          return List<Map<String, dynamic>>.from(data['data']);
        }
      }
      throw ApiException('Failed to fetch provider hospitals');
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

class ProviderListResponse {
  final List<ProviderModel> providers;
  final PaginationData pagination;

  ProviderListResponse({
    required this.providers,
    required this.pagination,
  });
}

class PaginationData {
  final int total;
  final int page;
  final int totalPages;

  PaginationData({
    required this.total,
    required this.page,
    required this.totalPages,
  });
} 

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => 'ApiException: $message';
}