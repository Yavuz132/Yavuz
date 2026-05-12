class UserModel {
  final int id;
  final String email;
  final String name;
  final String role;
  final int creditBalance;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.creditBalance,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as int,
        email: json['email'] as String,
        name: json['name'] as String,
        role: json['role'] as String,
        creditBalance: json['creditBalance'] as int,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
