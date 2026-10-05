class UserModel {
  final int id;
  final String fullName;
  final String mobileNumber;
  final String? email;
  final String? dateOfBirth;
  final String gender;
  final String? profilePhoto;
  final String bloodGroup;
  final String? address;
  final String state;
  final String district;
  final String area;
  final String pincode;
  final double? latitude;
  final double? longitude;
  final String? whatsappNumber;
  final String? lastDonationDate;
  final String availabilityStatus;
  final bool isVerified;
  final Map<String, dynamic>? eligibility;

  UserModel({
    required this.id,
    required this.fullName,
    required this.mobileNumber,
    this.email,
    this.dateOfBirth,
    this.gender = 'Male',
    this.profilePhoto,
    required this.bloodGroup,
    this.address,
    required this.state,
    required this.district,
    required this.area,
    required this.pincode,
    this.latitude,
    this.longitude,
    this.whatsappNumber,
    this.lastDonationDate,
    this.availabilityStatus = 'Available',
    this.isVerified = true,
    this.eligibility,
  });

  bool get isEligible {
    if (eligibility != null && eligibility!['is_eligible'] != null) {
      return eligibility!['is_eligible'] == true;
    }
    return true;
  }

  String get markerColor => eligibility?['marker_color'] ?? 'green';
  String get statusLabel => eligibility?['status_label'] ?? 'Potentially Available';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      fullName: json['full_name'] ?? '',
      mobileNumber: json['mobile_number'] ?? '',
      email: json['email'],
      dateOfBirth: json['date_of_birth'],
      gender: json['gender'] ?? 'Male',
      profilePhoto: json['profile_photo'],
      bloodGroup: json['blood_group'] ?? '',
      address: json['address'],
      state: json['state'] ?? '',
      district: json['district'] ?? '',
      area: json['area'] ?? '',
      pincode: json['pincode'] ?? '',
      latitude: json['latitude'] != null ? double.tryParse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.tryParse(json['longitude'].toString()) : null,
      whatsappNumber: json['whatsapp_number'] ?? json['mobile_number'],
      lastDonationDate: json['last_donation_date'],
      availabilityStatus: json['availability_status'] ?? 'Available',
      isVerified: json['is_verified'] == 1 || json['is_verified'] == true || json['is_verified'] == '1',
      eligibility: json['eligibility'] is Map<String, dynamic> ? json['eligibility'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'mobile_number': mobileNumber,
      'email': email,
      'date_of_birth': dateOfBirth,
      'gender': gender,
      'profile_photo': profilePhoto,
      'blood_group': bloodGroup,
      'address': address,
      'state': state,
      'district': district,
      'area': area,
      'pincode': pincode,
      'latitude': latitude,
      'longitude': longitude,
      'whatsapp_number': whatsappNumber,
      'last_donation_date': lastDonationDate,
      'availability_status': availabilityStatus,
      'is_verified': isVerified ? 1 : 0,
    };
  }
}
