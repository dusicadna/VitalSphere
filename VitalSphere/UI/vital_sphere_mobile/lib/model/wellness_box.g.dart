// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wellness_box.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WellnessBox _$WellnessBoxFromJson(Map<String, dynamic> json) =>
    WellnessBox(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      image: json['image'] as String?,
      includedItems: json['includedItems'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] == null
          ? DateTime.now()
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$WellnessBoxToJson(WellnessBox instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'image': instance.image,
      'includedItems': instance.includedItems,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt.toIso8601String(),
    };


