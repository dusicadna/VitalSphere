import 'package:json_annotation/json_annotation.dart';

part 'product.g.dart';

@JsonSerializable()
class Product {
  final int id;
  final String name;
  final double price;
  final String? picture;
  final bool isActive;
  final DateTime createdAt;
  final int productCategoryId;
  final String productCategoryName;
  final int brandId;
  final String brandName;

  Product({
    this.id = 0,
    this.name = '',
    this.price = 0.0,
    this.picture,
    this.isActive = true,
    required this.createdAt,
    this.productCategoryId = 0,
    this.productCategoryName = '',
    this.brandId = 0,
    this.brandName = '',
  });

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);
  Map<String, dynamic> toJson() => _$ProductToJson(this);
}

