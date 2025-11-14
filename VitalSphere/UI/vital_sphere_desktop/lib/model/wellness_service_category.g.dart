// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wellness_service_category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WellnessServiceCategory _$WellnessServiceCategoryFromJson(
        Map<String, dynamic> json) =>
    WellnessServiceCategory(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      image: json['image'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] == null
          ? DateTime.now()
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$WellnessServiceCategoryToJson(
        WellnessServiceCategory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'image': instance.image,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt.toIso8601String(),
    };

