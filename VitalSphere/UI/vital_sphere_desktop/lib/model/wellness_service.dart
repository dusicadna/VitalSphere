import 'package:json_annotation/json_annotation.dart';

part 'wellness_service.g.dart';

@JsonSerializable()
class WellnessService {
  final int id;
  final String name;
  final String? description;
  final String? image;
  final double price;
  final int? durationMinutes;
  final bool isActive;
  final DateTime createdAt;
  final int wellnessServiceCategoryId;
  final String wellnessServiceCategoryName;

  WellnessService({
    this.id = 0,
    this.name = '',
    this.description,
    this.image,
    this.price = 0.0,
    this.durationMinutes,
    this.isActive = true,
    required this.createdAt,
    this.wellnessServiceCategoryId = 0,
    this.wellnessServiceCategoryName = '',
  });

  factory WellnessService.fromJson(Map<String, dynamic> json) =>
      _$WellnessServiceFromJson(json);
  Map<String, dynamic> toJson() => _$WellnessServiceToJson(this);
}


