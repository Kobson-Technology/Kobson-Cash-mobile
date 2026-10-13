class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String referralCode;
  final bool hasActiveMembership;
  final String? photo;
  /// Nom complet du parrain associé (null tant qu'aucune clé de parrain n'a été validée).
  final String? sponsorName;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.referralCode,
    required this.hasActiveMembership,
    this.photo,
    this.sponsorName,
  });

  UserModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phoneNumber,
    String? referralCode,
    bool? hasActiveMembership,
    String? photo,
    String? sponsorName,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      referralCode: referralCode ?? this.referralCode,
      hasActiveMembership: hasActiveMembership ?? this.hasActiveMembership,
      photo: photo ?? this.photo,
      sponsorName: sponsorName ?? this.sponsorName,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      referralCode: json['referralCode'] ?? '',
      hasActiveMembership: json['hasActiveMembership'] ?? false,
      photo: json['photo'],
      sponsorName: json['parentName'],
    );
  }
}

