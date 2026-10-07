class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String referralCode;
  final bool hasActiveMembership;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.referralCode,
    required this.hasActiveMembership,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      referralCode: json['referralCode'] ?? '',
      hasActiveMembership: json['hasActiveMembership'] ?? false,
    );
  }
}
