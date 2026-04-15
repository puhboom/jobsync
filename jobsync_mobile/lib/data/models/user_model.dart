import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String email;
  final String? name;
  final String? pictureUrl;
  final List<String> oauthProviders;
  final bool hasActiveSubscription;

  const UserModel({
    required this.id,
    required this.email,
    this.name,
    this.pictureUrl,
    this.oauthProviders = const [],
    this.hasActiveSubscription = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      email: json['email'] ?? '',
      name: json['name'],
      pictureUrl: json['picture_url'],
      oauthProviders: List<String>.from(json['oauth_providers'] ?? []),
      hasActiveSubscription: json['has_active_subscription'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'picture_url': pictureUrl,
      'oauth_providers': oauthProviders,
      'has_active_subscription': hasActiveSubscription,
    };
  }

  @override
  List<Object?> get props => [
        id,
        email,
        name,
        pictureUrl,
        oauthProviders,
        hasActiveSubscription,
      ];
}
