class User {
  final String id;
  final String username;
  final String names;
  final String lastnames;
  final String email;
  final String phone;
  final String role;

  User({
    required this.id,
    required this.username,
    required this.names,
    required this.lastnames,
    required this.email,
    required this.phone,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      names: json['names'] ?? '',
      lastnames: json['lastnames'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? 'client',
    );
  }
}