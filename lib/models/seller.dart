import 'package:json_annotation/json_annotation.dart';

part 'seller.g.dart';

@JsonSerializable()
class Seller {
  final String id;
  final String name;
  final String? storeName;
  @JsonKey(name: 'logoUrl', readValue: _logoUrlReader)
  final String logoUrl;

  // Handle difference between JSON "avatar" and "logoUrl"
  static Object? _logoUrlReader(Map map, String key) {
    if (map.containsKey('logoUrl')) return map['logoUrl'];
    if (map.containsKey('avatar')) return map['avatar'];
    return null;
  }

  Seller({
    required this.id,
    required this.name,
    this.storeName,
    required this.logoUrl,
  });

  factory Seller.fromJson(Map<String, dynamic> json) => _$SellerFromJson(json);
  Map<String, dynamic> toJson() => _$SellerToJson(this);
}
