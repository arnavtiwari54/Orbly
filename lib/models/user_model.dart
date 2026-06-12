class UserModel {
  final String uid;
  final String username;
  final String email;
  final String profilePicBase64;
  final int postsCount;

  UserModel({
    required this.uid,
    required this.username,
    required this.email,
    this.profilePicBase64 = '',
    this.postsCount = 0,
  });

  // Convert Firestore data → UserModel
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      profilePicBase64: map['profilePicBase64'] ?? '',
      postsCount: map['postsCount'] ?? 0,
    );
  }

  // Convert UserModel → Firestore data
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'email': email,
      'profilePicBase64': profilePicBase64,
      'postsCount': postsCount,
    };
  }
}
