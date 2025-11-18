import 'package:json_annotation/json_annotation.dart';

part 'product_category.g.dart';

@JsonSerializable()
class ProductCategory {
  final int id;
  final String name;
  final String? description;
  final bool isActive;

  ProductCategory({
    this.id = 0,
    this.name = '',
    this.description,
    this.isActive = true,
  });

  factory ProductCategory.fromJson(Map<String, dynamic> json) =>
      _$ProductCategoryFromJson(json);
  Map<String, dynamic> toJson() => _$ProductCategoryToJson(this);
}

