// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Product _$ProductFromJson(Map<String, dynamic> json) => Product(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      picture: json['picture'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] == null
          ? DateTime.now()
          : DateTime.parse(json['createdAt'] as String),
      productCategoryId: (json['productCategoryId'] as num?)?.toInt() ?? 0,
      productCategoryName:
          json['productCategoryName'] as String? ?? '',
      brandId: (json['brandId'] as num?)?.toInt() ?? 0,
      brandName: json['brandName'] as String? ?? '',
    );

Map<String, dynamic> _$ProductToJson(Product instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'price': instance.price,
      'picture': instance.picture,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt.toIso8601String(),
      'productCategoryId': instance.productCategoryId,
      'productCategoryName': instance.productCategoryName,
      'brandId': instance.brandId,
      'brandName': instance.brandName,
    };

