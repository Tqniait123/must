// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:mohtm/features/all/auth/domain/entities/user.dart';

// abstract class Mapper<T> {
//   T fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot);
//   Map<String, dynamic> toDocument(T object);
// }

// class UserMapper extends Mapper<AppUser> {
//   @override
//   AppUser fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
//     final data = snapshot.data();
//     if (data == null) {
//       // Handle the case where snapshot.data() is null, such as document not existing
//       throw StateError('Snapshot data is null for document ${snapshot.id}');
//     }
//     return AppUser(
//       id: snapshot.id,
//       username: data['username'] ?? '',
//       fullName: data['fullName'] ?? '',
//       email: data['email'] ?? '',
//       image: data['image'] ?? '',
//     );
//   }

//   @override
//   Map<String, dynamic> toDocument(AppUser user) {
//     return {
//       'username': user.username,
//       'fullName': user.fullName,
//       'email': user.email,
//       'image': user.image,
//     };
//   }
// }
