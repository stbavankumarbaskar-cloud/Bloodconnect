class DonorModel {
  final int id;
  final String fullName;
  final String mobileNumber;
  final String? email;
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
  final double? distanceKm;
  final String markerColor;
  final String statusLabel;

  DonorModel({
    required this.id,
    required this.fullName,
    required this.mobileNumber,
    this.email,
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
    this.distanceKm,
    this.markerColor = 'green',
    this.statusLabel = 'Potentially Available',
  });

  bool get isRecentlyDonated => markerColor == 'red';
  bool get isAvailable => availabilityStatus == 'Available';

  factory DonorModel.fromJson(Map<String, dynamic> json) {
    return DonorModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      fullName: json['full_name'] ?? '',
      mobileNumber: json['mobile_number'] ?? '',
      email: json['email'],
      gender: json['gender'] ?? 'Male',
      profilePhoto: json['profile_photo'],
      bloodGroup: json['blood_group'] ?? '',
      address: json['address'],
      state: json['state'] ?? '',
      district: json['district'] ?? '',
      area: json['area'] ?? '',
      pincode: json['pincode'] ?? '',
      latitude: json['latitude'] != null
          ? double.tryParse(json['latitude'].toString())
          : null,
      longitude: json['longitude'] != null
          ? double.tryParse(json['longitude'].toString())
          : null,
      whatsappNumber: json['whatsapp_number'] ?? json['mobile_number'],
      lastDonationDate: json['last_donation_date'],
      availabilityStatus: json['availability_status'] ?? 'Available',
      isVerified:
          json['is_verified'] == 1 ||
          json['is_verified'] == true ||
          json['is_verified'] == '1',
      distanceKm: json['distance_km'] != null
          ? double.tryParse(json['distance_km'].toString())
          : null,
      markerColor: json['marker_color'] ?? 'green',
      statusLabel: json['status_label'] ?? 'Potentially Available',
    );
  }
}
