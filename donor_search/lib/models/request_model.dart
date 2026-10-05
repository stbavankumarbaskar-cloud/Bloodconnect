class BloodRequestModel {
  final int id;
  final int requestUserId;
  final String patientName;
  final String bloodGroup;
  final int requiredUnits;
  final String hospitalName;
  final String hospitalAddress;
  final String state;
  final String district;
  final String area;
  final String pincode;
  final double? latitude;
  final double? longitude;
  final String urgency;
  final String? description;
  final String status;
  final String createdAt;
  final String? requesterName;
  final String? requesterMobile;

  BloodRequestModel({
    required this.id,
    required this.requestUserId,
    required this.patientName,
    required this.bloodGroup,
    this.requiredUnits = 1,
    required this.hospitalName,
    required this.hospitalAddress,
    required this.state,
    required this.district,
    required this.area,
    required this.pincode,
    this.latitude,
    this.longitude,
    this.urgency = 'Urgent',
    this.description,
    this.status = 'Active',
    required this.createdAt,
    this.requesterName,
    this.requesterMobile,
  });

  bool get isCritical => urgency == 'Critical';
  bool get isActive => status == 'Active';

  factory BloodRequestModel.fromJson(Map<String, dynamic> json) {
    return BloodRequestModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      requestUserId: json['request_user_id'] is int
          ? json['request_user_id']
          : int.tryParse(json['request_user_id'].toString()) ?? 0,
      patientName: json['patient_name'] ?? '',
      bloodGroup: json['blood_group'] ?? '',
      requiredUnits: json['required_units'] is int
          ? json['required_units']
          : int.tryParse(json['required_units'].toString()) ?? 1,
      hospitalName: json['hospital_name'] ?? '',
      hospitalAddress: json['hospital_address'] ?? '',
      state: json['state'] ?? '',
      district: json['district'] ?? '',
      area: json['area'] ?? '',
      pincode: json['pincode'] ?? '',
      latitude: json['latitude'] != null ? double.tryParse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.tryParse(json['longitude'].toString()) : null,
      urgency: json['urgency'] ?? 'Urgent',
      description: json['description'],
      status: json['status'] ?? 'Active',
      createdAt: json['created_at'] ?? '',
      requesterName: json['requester_name'],
      requesterMobile: json['requester_mobile'],
    );
  }
}
