class UserModel {
  final String id;
  final String phone;
  final String name;
  final String role; // 'parent' or 'caregiver'
  final String? profileImage;
  final String? location;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.phone,
    required this.name,
    required this.role,
    this.profileImage,
    this.location,
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      phone: map['phone'] ?? '',
      name: map['name'] ?? '',
      role: map['role'] ?? 'parent',
      profileImage: map['profileImage'],
      location: map['location'],
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'phone': phone,
      'name': name,
      'role': role,
      'profileImage': profileImage,
      'location': location,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }
}
