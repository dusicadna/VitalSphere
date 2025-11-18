import 'package:json_annotation/json_annotation.dart';

part 'wellness_box.g.dart';

@JsonSerializable()
class WellnessBox {
  final int id;
  final String name;
  final String? description;
  final String? image;
  final String? includedItems;
  final bool isActive;
  final DateTime createdAt;

  WellnessBox({
    this.id = 0,
    this.name = '',
    this.description,
    this.image,
    this.includedItems,
    this.isActive = true,
    required this.createdAt,
  });

  factory WellnessBox.fromJson(Map<String, dynamic> json) =>
      _$WellnessBoxFromJson(json);
  Map<String, dynamic> toJson() => _$WellnessBoxToJson(this);
}

