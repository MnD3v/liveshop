// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'live_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LiveEvent _$LiveEventFromJson(Map<String, dynamic> json) => LiveEvent(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  startTime: DateTime.parse(json['startTime'] as String),
  endTime: json['endTime'] == null
      ? null
      : DateTime.parse(json['endTime'] as String),
  status: $enumDecode(_$LiveEventStatusEnumMap, json['status']),
  seller: Seller.fromJson(json['seller'] as Map<String, dynamic>),
  productIds: (json['products'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  featuredProductId: json['featuredProduct'] as String?,
  viewerCount: (json['viewerCount'] as num?)?.toInt() ?? 0,
  streamUrl: json['streamUrl'] as String?,
  replayUrl: json['replayUrl'] as String?,
  thumbnailUrl: json['thumbnailUrl'] as String,
);

Map<String, dynamic> _$LiveEventToJson(LiveEvent instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'startTime': instance.startTime.toIso8601String(),
  'endTime': instance.endTime?.toIso8601String(),
  'status': _$LiveEventStatusEnumMap[instance.status]!,
  'seller': instance.seller,
  'products': instance.productIds,
  'featuredProduct': instance.featuredProductId,
  'viewerCount': instance.viewerCount,
  'streamUrl': instance.streamUrl,
  'replayUrl': instance.replayUrl,
  'thumbnailUrl': instance.thumbnailUrl,
};

const _$LiveEventStatusEnumMap = {
  LiveEventStatus.scheduled: 'scheduled',
  LiveEventStatus.live: 'live',
  LiveEventStatus.ended: 'ended',
};
