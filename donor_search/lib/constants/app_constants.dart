class AppConstants {
  static const String appName = 'BloodBridge';
  static const String appTagline = 'Connecting Life Savers in Real-Time';

  static const List<String> bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'O+',
    'O-',
    'AB+',
    'AB-',
  ];

  static const List<String> indianStates = [
    'Tamil Nadu',
    'Kerala',
    'Karnataka',
    'Andhra Pradesh',
    'Telangana',
    'Maharashtra',
    'Delhi',
  ];

  static const Map<String, List<String>> stateDistricts = {
    'Tamil Nadu': [
      'Madurai',
      'Chennai',
      'Coimbatore',
      'Tiruchirappalli',
      'Salem',
      'Tirunelveli',
      'Thanjavur',
      'Dindigul',
      'Erode',
      'Vellore',
    ],
    'Kerala': [
      'Thiruvananthapuram',
      'Ernakulam',
      'Kozhikode',
      'Thrissur',
      'Kollam',
    ],
    'Karnataka': [
      'Bengaluru Urban',
      'Mysuru',
      'Mangaluru',
      'Hubballi-Dharwad',
      'Belagavi',
    ],
  };

  static const List<double> radiusOptions = [
    2.0,
    5.0,
    10.0,
    15.0,
    25.0,
    50.0,
  ];

  // Configurable eligibility threshold in months
  static const int eligibilityThresholdMonths = 6;
}
