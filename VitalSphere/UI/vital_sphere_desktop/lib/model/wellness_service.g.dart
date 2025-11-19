// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wellness_service.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WellnessService _$WellnessServiceFromJson(Map<String, dynamic> json) =>
    WellnessService(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      image: json['image'] as String?,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      durationMinutes: (json['durationMinutes'] as num?)?.toInt(),
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] == null
          ? DateTime.now()
          : DateTime.parse(json['createdAt'] as String),
      wellnessServiceCategoryId:
          (json['wellnessServiceCategoryId'] as num?)?.toInt() ?? 0,
      wellnessServiceCategoryName:
          json['wellnessServiceCategoryName'] as String? ?? '',
    );

Map<String, dynamic> _$WellnessServiceToJson(WellnessService instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'image': instance.image,
      'price': instance.price,
      'durationMinutes': instance.durationMinutes,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt.toIso8601String(),
      'wellnessServiceCategoryId': instance.wellnessServiceCategoryId,
      'wellnessServiceCategoryName': instance.wellnessServiceCategoryName,
    };










