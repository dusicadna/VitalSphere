import 'package:json_annotation/json_annotation.dart';

part 'wellness_service_category.g.dart';

@JsonSerializable()
class WellnessServiceCategory {
  final int id;
  final String name;
  final String? description;
  final String? image;
  final bool isActive;
  final DateTime createdAt;

  WellnessServiceCategory({
    this.id = 0,
    this.name = '',
    this.description,
    this.image,
    this.isActive = true,
    required this.createdAt,
  });

  factory WellnessServiceCategory.fromJson(Map<String, dynamic> json) =>
      _$WellnessServiceCategoryFromJson(json);
  Map<String, dynamic> toJson() => _$WellnessServiceCategoryToJson(this);
}

