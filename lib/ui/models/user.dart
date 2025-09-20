// ui/models/user.dart dosyasında
class AppUser {
  final String id;
  final String? name;
  final String? email;
  final DateTime? createdAt; // Bu alanı ekleyin

  AppUser({
    required this.id,
    this.name,
    this.email,
    this.createdAt, // Bu alanı ekleyin
  });

  // fromMap ve toMap metodlarını da güncelleyin
  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}