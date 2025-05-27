class Brand {
  final int id;
  final String businessName;
  final String email;
  final String logo;
  final String? photo;
  final String contactPerson;
  final bool blocked;
  final bool isApproved;
  final bool isActive;

  Brand({
    required this.id,
    required this.businessName,
    required this.email,
    required this.logo,
    this.photo,
    required this.contactPerson,
    required this.blocked,
    required this.isApproved,
    required this.isActive,
  });

  factory Brand.fromJson(Map<String, dynamic> json) {
    return Brand(
      id: json['id'],
      businessName: json['business_name'],
      email: json['email'],
      logo: json['logo'],
      photo: json['photo'],
      contactPerson: json['contact_person'],
      blocked: json['blocked'] == 1,
      isApproved: json['is_approved'] == 1,
      isActive: json['is_active'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'business_name': businessName,
      'email': email,
      'logo': logo,
      'photo': photo,
      'contact_person': contactPerson,
      'blocked': blocked ? 1 : 0,
      'is_approved': isApproved ? 1 : 0,
      'is_active': isActive ? 1 : 0,
    };
  }
}
