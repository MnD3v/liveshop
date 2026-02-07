import 'package:json_annotation/json_annotation.dart';

part 'user_notification.g.dart';

@JsonSerializable()
class UserNotification {
  final String id;
  final String userId;
  final String type;
  final String title;
  final String message;
  final bool read;
  final DateTime createdAt;

  UserNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    required this.read,
    required this.createdAt,
  });

  factory UserNotification.fromJson(Map<String, dynamic> json) =>
      _$UserNotificationFromJson(json);
  Map<String, dynamic> toJson() => _$UserNotificationToJson(this);
}
