// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Review _$ReviewFromJson(Map<String, dynamic> json) => Review(
      id: (json['id'] as num?)?.toInt() ?? 0,
      rating: (json['rating'] as num?)?.toInt() ?? 0,
      comment: json['comment'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      wellnessServiceId: (json['wellnessServiceId'] as num?)?.toInt() ?? 0,
      wellnessServiceName: json['wellnessServiceName'] as String? ?? '',
      userId: (json['userId'] as num?)?.toInt() ?? 0,
      userFullName: json['userFullName'] as String? ?? '',
      appointmentId: (json['appointmentId'] as num?)?.toInt() ?? 0,
      wellnessServiceImage: json['wellnessServiceImage'] as String?,
    );

Map<String, dynamic> _$ReviewToJson(Review instance) => <String, dynamic>{
      'id': instance.id,
      'rating': instance.rating,
      'comment': instance.comment,
      'createdAt': instance.createdAt.toIso8601String(),
      'wellnessServiceId': instance.wellnessServiceId,
      'wellnessServiceName': instance.wellnessServiceName,
      'userId': instance.userId,
      'userFullName': instance.userFullName,
      'appointmentId': instance.appointmentId,
      'wellnessServiceImage': instance.wellnessServiceImage,
    };
