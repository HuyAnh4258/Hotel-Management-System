class LoginRequest {
  final String username;
  final String password;

  LoginRequest({required this.username, required this.password});

  Map<String, dynamic> toJson() => {'username': username, 'password': password};
}

class LoginResponse {
  final String accessToken;
  final String userId;
  final String username;
  final List<String> roles;
  final String? fullName;

  LoginResponse({
    required this.accessToken,
    required this.userId,
    required this.username,
    required this.roles,
    this.fullName,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
    accessToken: json['accessToken'] as String,
    userId: json['userId'] as String,
    username: json['username'] as String,
    roles: (json['roles'] as List).map((e) => e as String).toList(),
    fullName: json['fullName'] as String?,
  );
}
