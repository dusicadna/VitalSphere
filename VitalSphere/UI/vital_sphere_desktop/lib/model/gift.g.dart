// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gift.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Gift _$GiftFromJson(Map<String, dynamic> json) =>
    Gift(
      id: (json['id'] as num?)?.toInt() ?? 0,
      userId: (json['userId'] as num?)?.toInt() ?? 0,
      userName: json['userName'] as String? ?? '',
      wellnessBoxId: (json['wellnessBoxId'] as num?)?.toInt() ?? 0,
      wellnessBoxName: json['wellnessBoxName'] as String? ?? '',
      wellnessBoxImage: json['wellnessBoxImage'] as String?,
      giftedAt: json['giftedAt'] == null
          ? DateTime.now()
          : DateTime.parse(json['giftedAt'] as String),
      giftStatusId: (json['giftStatusId'] as num?)?.toInt() ?? 0,
      giftStatusName: json['giftStatusName'] as String? ?? '',
    );

Map<String, dynamic> _$GiftToJson(Gift instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'userName': instance.userName,
      'wellnessBoxId': instance.wellnessBoxId,
      'wellnessBoxName': instance.wellnessBoxName,
      'wellnessBoxImage': instance.wellnessBoxImage,
      'giftedAt': instance.giftedAt.toIso8601String(),
      'giftStatusId': instance.giftStatusId,
      'giftStatusName': instance.giftStatusName,
    };


