// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'seller.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Seller _$SellerFromJson(Map<String, dynamic> json) => Seller(
  id: json['id'] as String,
  name: json['name'] as String,
  storeName: json['storeName'] as String?,
  logoUrl: Seller._logoUrlReader(json, 'logoUrl') as String,
);

Map<String, dynamic> _$SellerToJson(Seller instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'storeName': instance.storeName,
  'logoUrl': instance.logoUrl,
};
