import '../config/app_config.dart';

class AuthUser {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final String? avatarPath;
  final bool isEmailVerified;

  const AuthUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    this.avatarPath,
    this.isEmailVerified = true,
  });

  String get fullName => '$firstName $lastName';
  String? get avatarUrl {
    final path = avatarPath?.trim();
    if (path == null || path.isEmpty) {
      return null;
    }

    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }

    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return '${AppConfig.apiOrigin}$normalizedPath';
  }

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    final rawFirstName = json['firstName'] as String?;
    final rawLastName = json['lastName'] as String?;
    final rawName = json['name'] as String?;
    final fallbackName = rawName?.trim() ?? '';
    final nameParts = fallbackName.isEmpty
        ? const <String>[]
        : fallbackName.split(RegExp(r'\s+'));

    final firstName = rawFirstName?.trim().isNotEmpty == true
        ? rawFirstName!.trim()
        : (nameParts.isNotEmpty ? nameParts.first : 'Customer');
    final lastName = rawLastName?.trim().isNotEmpty == true
        ? rawLastName!.trim()
        : (nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '');

    return AuthUser(
      id: json['id'] as String,
      firstName: firstName,
      lastName: lastName,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      avatarPath: json['avatarPath'] as String?,
      isEmailVerified: json['isEmailVerified'] as bool? ?? true,
    );
  }
}
