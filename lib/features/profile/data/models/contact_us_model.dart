class ContactUsModel {
  final String phone;
  final String email;
  final String address;

  const ContactUsModel({
    required this.phone,
    required this.email,
    required this.address,
  });

  factory ContactUsModel.fromJson(Map<String, dynamic> json) {
    return ContactUsModel(
      phone: json['phone'] as String,
      email: json['email'] as String,
      address: json['address'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
      'email': email,
      'address': address,
    };
  }
}
