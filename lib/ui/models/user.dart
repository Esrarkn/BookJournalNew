class AppUser {
  final String id;
  final String email;
  final String? name;  

  AppUser({
    required this.id,
    required this.email,
    this.name,
  });
}