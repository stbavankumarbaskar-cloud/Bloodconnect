import 'package:flutter/foundation.dart';

class ApiEndpoints {
  // Configurable base URL
  static String? _customBaseUrl;

  static void setCustomBaseUrl(String url) {
    _customBaseUrl = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  static String get baseUrl {
    if (_customBaseUrl != null && _customBaseUrl!.isNotEmpty) {
      return _customBaseUrl!;
    }
    if (kIsWeb) {
      return 'http://127.0.0.1/bloodconnect/backend';
    }
    // For physical Android device or emulator on LAN
    // 192.168.1.49 is the host machine's LAN IP
    return 'http://192.168.1.49/bloodconnect/backend';
  }

  // Auth endpoints
  static String get checkMobile => '$baseUrl/api/auth/check-mobile.php';
  static String get login => '$baseUrl/api/auth/login.php';
  static String get register => '$baseUrl/api/auth/register.php';
  static String get logout => '$baseUrl/api/auth/logout.php';

  // Donor endpoints
  static String get donorList => '$baseUrl/api/donors/list.php';
  static String get donorDetails => '$baseUrl/api/donors/details.php';
  static String get nearbyDonors => '$baseUrl/api/donors/nearby.php';
  static String get updateDonorStatus => '$baseUrl/api/donors/update-status.php';

  // Search endpoints
  static String get manualSearch => '$baseUrl/api/search/manual.php';
  static String get liveLocationSearch => '$baseUrl/api/search/live-location.php';

  // Profile endpoints
  static String get getProfile => '$baseUrl/api/profile/get.php';
  static String get updateProfile => '$baseUrl/api/profile/update.php';
  static String get uploadPhoto => '$baseUrl/api/profile/upload-photo.php';

  // Requests endpoints
  static String get listRequests => '$baseUrl/api/requests/list.php';
  static String get createRequest => '$baseUrl/api/requests/create.php';
  static String get updateRequest => '$baseUrl/api/requests/update.php';

  // Notifications endpoints
  static String get listNotifications => '$baseUrl/api/notifications/list.php';
  static String get readNotifications => '$baseUrl/api/notifications/read.php';

  // History endpoints
  static String get listHistory => '$baseUrl/api/history/list.php';
  static String get addHistory => '$baseUrl/api/history/add.php';
}
