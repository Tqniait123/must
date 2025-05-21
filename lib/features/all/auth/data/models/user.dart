enum UserType { parent, teen }

class AppUser {
  final int id;
  final String name;
  final String? photo;
  final String email;
  final bool hasSubscription;
  final String? address;
  final String linkId;
  final UserType type;
  final bool? isOnline;
  final String image;
  final String? phoneNumber;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    this.photo,
    this.hasSubscription = false,
    this.address,
    required this.linkId,
    required this.image,
    required this.type,
    this.isOnline = false,
    this.phoneNumber,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      photo: json['photo'],
      hasSubscription: json['has_subscription'],
      address: json['address'],
      linkId: json['link_id'],
      type: json['type'] == 'parent' ? UserType.parent : UserType.teen,
      isOnline: json['is_online'],
      image: json['image'],
      phoneNumber: json['phone_number'],
    );
  }
}
