import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_endpoints.dart';
import '../models/user_model.dart';
import '../models/donor_model.dart';
import '../models/request_model.dart';
import '../models/notification_model.dart';
import '../models/history_model.dart';
import 'storage_service.dart';

class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
  });
}

class ApiService {
  static Future<Map<String, String>> _getHeaders({bool requireAuth = false}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (requireAuth) {
      final token = await StorageService.getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
        headers['X-Auth-Token'] = token;
      }
    }
    return headers;
  }

  // Auth: Check Mobile Number
  static Future<ApiResponse<Map<String, dynamic>>> checkMobile(String mobile) async {
    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.checkMobile),
        headers: await _getHeaders(),
        body: jsonEncode({'mobile_number': mobile}),
      );
      final json = jsonDecode(response.body);
      return ApiResponse<Map<String, dynamic>>(
        success: json['success'] ?? false,
        message: json['message'] ?? '',
        data: json['data'],
      );
    } catch (e) {
      return ApiResponse(success: false, message: 'Connection error: $e');
    }
  }

  // Auth: Login
  static Future<ApiResponse<Map<String, dynamic>>> login(String mobile) async {
    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.login),
        headers: await _getHeaders(),
        body: jsonEncode({'mobile_number': mobile}),
      );
      final json = jsonDecode(response.body);
      if (json['success'] == true && json['data'] != null) {
        final token = json['data']['token'];
        final user = UserModel.fromJson(json['data']['user']);
        await StorageService.saveSession(token, user);
      }
      return ApiResponse<Map<String, dynamic>>(
        success: json['success'] ?? false,
        message: json['message'] ?? '',
        data: json['data'],
      );
    } catch (e) {
      return ApiResponse(success: false, message: 'Login failed: $e');
    }
  }

  // Auth: Register
  static Future<ApiResponse<Map<String, dynamic>>> register(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.register),
        headers: await _getHeaders(),
        body: jsonEncode(data),
      );
      final json = jsonDecode(response.body);
      if (json['success'] == true && json['data'] != null) {
        final token = json['data']['token'];
        final user = UserModel.fromJson(json['data']['user']);
        await StorageService.saveSession(token, user);
      }
      return ApiResponse<Map<String, dynamic>>(
        success: json['success'] ?? false,
        message: json['message'] ?? '',
        data: json['data'],
      );
    } catch (e) {
      return ApiResponse(success: false, message: 'Registration failed: $e');
    }
  }

  // Auth: Logout
  static Future<void> logout() async {
    try {
      await http.post(
        Uri.parse(ApiEndpoints.logout),
        headers: await _getHeaders(requireAuth: true),
      );
    } catch (_) {}
    await StorageService.clearSession();
  }

  // Donors: Get List with Filters
  static Future<ApiResponse<List<DonorModel>>> getDonors({
    String? bloodGroup,
    String? availability,
    String? district,
    String? state,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (bloodGroup != null && bloodGroup.isNotEmpty) queryParams['blood_group'] = bloodGroup;
      if (availability != null && availability.isNotEmpty) queryParams['availability'] = availability;
      if (district != null && district.isNotEmpty) queryParams['district'] = district;
      if (state != null && state.isNotEmpty) queryParams['state'] = state;
      if (latitude != null) queryParams['latitude'] = latitude.toString();
      if (longitude != null) queryParams['longitude'] = longitude.toString();

      final uri = Uri.parse(ApiEndpoints.donorList).replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: await _getHeaders());
      final json = jsonDecode(response.body);

      if (json['success'] == true && json['data'] is List) {
        final list = (json['data'] as List)
            .map((item) => DonorModel.fromJson(item))
            .toList();
        return ApiResponse(success: true, message: json['message'] ?? '', data: list);
      }
      return ApiResponse(success: false, message: json['message'] ?? 'Failed to load donors', data: []);
    } catch (e) {
      return ApiResponse(success: false, message: 'Error loading donors: $e', data: []);
    }
  }

  // Donors: Get Specific Donor Details by ID
  static Future<ApiResponse<Map<String, dynamic>>> getDonorDetails(int id) async {
    try {
      final uri = Uri.parse('${ApiEndpoints.donorDetails}?id=$id');
      final response = await http.get(uri, headers: await _getHeaders());
      final json = jsonDecode(response.body);
      if (json['success'] == true && json['data'] != null) {
        return ApiResponse(
          success: true,
          message: json['message'] ?? '',
          data: json['data'] as Map<String, dynamic>,
        );
      }
      return ApiResponse(success: false, message: json['message'] ?? 'Donor not found');
    } catch (e) {
      return ApiResponse(success: false, message: 'Error loading donor details: $e');
    }
  }

  // Donors: Nearby by Coordinates & Radius
  static Future<ApiResponse<List<DonorModel>>> getNearbyDonors({
    required double latitude,
    required double longitude,
    double radius = 5.0,
    String? bloodGroup,
  }) async {
    try {
      final queryParams = <String, String>{
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'radius': radius.toString(),
      };
      if (bloodGroup != null && bloodGroup.isNotEmpty && bloodGroup != 'ALL') {
        queryParams['blood_group'] = bloodGroup;
      }

      final uri = Uri.parse(ApiEndpoints.nearbyDonors).replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: await _getHeaders());
      final json = jsonDecode(response.body);

      if (json['success'] == true && json['data'] != null && json['data']['donors'] is List) {
        final list = (json['data']['donors'] as List)
            .map((item) => DonorModel.fromJson(item))
            .toList();
        return ApiResponse(success: true, message: json['message'] ?? '', data: list);
      }
      return ApiResponse(success: false, message: json['message'] ?? 'No nearby donors found', data: []);
    } catch (e) {
      return ApiResponse(success: false, message: 'Error loading nearby donors: $e', data: []);
    }
  }

  // Search: Manual Search
  static Future<ApiResponse<List<DonorModel>>> searchManual(Map<String, dynamic> filters) async {
    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.manualSearch),
        headers: await _getHeaders(),
        body: jsonEncode(filters),
      );
      final json = jsonDecode(response.body);
      if (json['success'] == true && json['data'] != null && json['data']['donors'] is List) {
        final list = (json['data']['donors'] as List)
            .map((item) => DonorModel.fromJson(item))
            .toList();
        return ApiResponse(success: true, message: json['message'] ?? '', data: list);
      }
      return ApiResponse(success: false, message: json['message'] ?? 'Search completed', data: []);
    } catch (e) {
      return ApiResponse(success: false, message: 'Manual search error: $e', data: []);
    }
  }

  // Search: Live Location Search
  static Future<ApiResponse<List<DonorModel>>> searchLiveLocation({
    required double latitude,
    required double longitude,
    double radius = 5.0,
    String? bloodGroup,
    String? availability,
  }) async {
    try {
      final body = {
        'latitude': latitude,
        'longitude': longitude,
        'radius': radius,
        if (bloodGroup != null && bloodGroup != 'ALL') 'blood_group': bloodGroup,
        if (availability != null && availability != 'ALL') 'availability': availability,
      };
      final response = await http.post(
        Uri.parse(ApiEndpoints.liveLocationSearch),
        headers: await _getHeaders(),
        body: jsonEncode(body),
      );
      final json = jsonDecode(response.body);
      if (json['success'] == true && json['data'] != null && json['data']['donors'] is List) {
        final list = (json['data']['donors'] as List)
            .map((item) => DonorModel.fromJson(item))
            .toList();
        return ApiResponse(success: true, message: json['message'] ?? '', data: list);
      }
      return ApiResponse(success: false, message: json['message'] ?? 'Search completed', data: []);
    } catch (e) {
      return ApiResponse(success: false, message: 'Live search error: $e', data: []);
    }
  }

  // Profile: Get Current User Profile
  static Future<ApiResponse<UserModel>> getProfile() async {
    try {
      final response = await http.get(
        Uri.parse(ApiEndpoints.getProfile),
        headers: await _getHeaders(requireAuth: true),
      );
      final json = jsonDecode(response.body);
      if (json['success'] == true && json['data'] != null) {
        final user = UserModel.fromJson(json['data']);
        final token = await StorageService.getToken();
        if (token != null) {
          await StorageService.saveSession(token, user);
        }
        return ApiResponse(success: true, message: json['message'] ?? '', data: user);
      }
      return ApiResponse(success: false, message: json['message'] ?? 'Failed to load profile');
    } catch (e) {
      return ApiResponse(success: false, message: 'Profile error: $e');
    }
  }

  // Profile: Update
  static Future<ApiResponse<UserModel>> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.updateProfile),
        headers: await _getHeaders(requireAuth: true),
        body: jsonEncode(data),
      );
      final json = jsonDecode(response.body);
      if (json['success'] == true && json['data'] != null) {
        final user = UserModel.fromJson(json['data']);
        final token = await StorageService.getToken();
        if (token != null) {
          await StorageService.saveSession(token, user);
        }
        return ApiResponse(success: true, message: json['message'] ?? '', data: user);
      }
      return ApiResponse(success: false, message: json['message'] ?? 'Failed to update profile');
    } catch (e) {
      return ApiResponse(success: false, message: 'Update error: $e');
    }
  }

  // Blood Requests: List
  static Future<ApiResponse<List<BloodRequestModel>>> getRequests({
    String? status,
    String? bloodGroup,
    bool myRequests = false,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (status != null && status.isNotEmpty) queryParams['status'] = status;
      if (bloodGroup != null && bloodGroup.isNotEmpty) queryParams['blood_group'] = bloodGroup;
      if (myRequests) {
        queryParams['my_requests'] = '1';
        final token = await StorageService.getToken();
        if (token != null && token.isNotEmpty) {
          queryParams['token'] = token;
        }
      }

      final uri = Uri.parse(ApiEndpoints.listRequests).replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: await _getHeaders(requireAuth: myRequests));
      final json = jsonDecode(response.body);

      if (json['success'] == true && json['data'] is List) {
        final list = (json['data'] as List)
            .map((item) => BloodRequestModel.fromJson(item))
            .toList();
        return ApiResponse(success: true, message: json['message'] ?? '', data: list);
      }
      return ApiResponse(success: false, message: json['message'] ?? 'No requests', data: []);
    } catch (e) {
      return ApiResponse(success: false, message: 'Requests error: $e', data: []);
    }
  }

  // Blood Requests: Create
  static Future<ApiResponse<Map<String, dynamic>>> createRequest(Map<String, dynamic> data) async {
    try {
      final token = await StorageService.getToken();
      final headers = await _getHeaders(requireAuth: true);
      final payload = Map<String, dynamic>.from(data);
      if (token != null && token.isNotEmpty) {
        payload['token'] = token;
      }
      final uri = token != null && token.isNotEmpty
          ? Uri.parse('${ApiEndpoints.createRequest}?token=$token')
          : Uri.parse(ApiEndpoints.createRequest);

      final response = await http.post(
        uri,
        headers: headers,
        body: jsonEncode(payload),
      );
      final json = jsonDecode(response.body);
      return ApiResponse(
        success: json['success'] ?? false,
        message: json['message'] ?? '',
        data: json['data'],
      );
    } catch (e) {
      return ApiResponse(success: false, message: 'Failed to create request: $e');
    }
  }

  // Blood Requests: Update status or details
  static Future<ApiResponse<Map<String, dynamic>>> updateRequestStatus({
    required int requestId,
    required String status,
    Map<String, dynamic>? extraFields,
  }) async {
    try {
      final token = await StorageService.getToken();
      final headers = await _getHeaders(requireAuth: true);
      final payload = <String, dynamic>{
        'request_id': requestId,
        'status': status,
        ...?extraFields,
      };
      if (token != null && token.isNotEmpty) {
        payload['token'] = token;
      }
      final uri = token != null && token.isNotEmpty
          ? Uri.parse('${ApiEndpoints.updateRequest}?token=$token')
          : Uri.parse(ApiEndpoints.updateRequest);

      final response = await http.post(
        uri,
        headers: headers,
        body: jsonEncode(payload),
      );
      final json = jsonDecode(response.body);
      return ApiResponse(
        success: json['success'] ?? false,
        message: json['message'] ?? '',
        data: json['data'],
      );
    } catch (e) {
      return ApiResponse(success: false, message: 'Failed to update request: $e');
    }
  }

  // Notifications: List
  static Future<ApiResponse<Map<String, dynamic>>> getNotifications() async {
    try {
      final response = await http.get(
        Uri.parse(ApiEndpoints.listNotifications),
        headers: await _getHeaders(requireAuth: true),
      );
      final json = jsonDecode(response.body);
      if (json['success'] == true && json['data'] != null) {
        final rawList = json['data']['notifications'] as List? ?? [];
        final notifs = rawList.map((n) => NotificationModel.fromJson(n)).toList();
        return ApiResponse(
          success: true,
          message: json['message'] ?? '',
          data: {
            'unread_count': json['data']['unread_count'] ?? 0,
            'notifications': notifs,
          },
        );
      }
      return ApiResponse(success: false, message: json['message'] ?? 'No notifications');
    } catch (e) {
      return ApiResponse(success: false, message: 'Notification error: $e');
    }
  }

  // History: List
  static Future<ApiResponse<List<DonationHistoryModel>>> getHistory() async {
    try {
      final response = await http.get(
        Uri.parse(ApiEndpoints.listHistory),
        headers: await _getHeaders(requireAuth: true),
      );
      final json = jsonDecode(response.body);
      if (json['success'] == true && json['data'] is List) {
        final list = (json['data'] as List)
            .map((item) => DonationHistoryModel.fromJson(item))
            .toList();
        return ApiResponse(success: true, message: json['message'] ?? '', data: list);
      }
      return ApiResponse(success: false, message: json['message'] ?? 'No history', data: []);
    } catch (e) {
      return ApiResponse(success: false, message: 'History error: $e', data: []);
    }
  }

  // History: Add Record
  static Future<ApiResponse<Map<String, dynamic>>> addHistory(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.addHistory),
        headers: await _getHeaders(requireAuth: true),
        body: jsonEncode(data),
      );
      final json = jsonDecode(response.body);
      return ApiResponse(
        success: json['success'] ?? false,
        message: json['message'] ?? '',
        data: json['data'],
      );
    } catch (e) {
      return ApiResponse(success: false, message: 'Error adding history: $e');
    }
  }
}
