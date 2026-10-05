class DonationHistoryModel {
  final int id;
  final int donorId;
  final String donationDate;
  final String hospitalName;
  final String location;
  final String? notes;
  final String? createdAt;

  DonationHistoryModel({
    required this.id,
    required this.donorId,
    required this.donationDate,
    required this.hospitalName,
    required this.location,
    this.notes,
    this.createdAt,
  });

  factory DonationHistoryModel.fromJson(Map<String, dynamic> json) {
    return DonationHistoryModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      donorId: json['donor_id'] is int ? json['donor_id'] : int.tryParse(json['donor_id'].toString()) ?? 0,
      donationDate: json['donation_date'] ?? '',
      hospitalName: json['hospital_name'] ?? '',
      location: json['location'] ?? '',
      notes: json['notes'],
      createdAt: json['created_at'],
    );
  }
}
