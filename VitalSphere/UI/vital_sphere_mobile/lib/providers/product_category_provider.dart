import 'package:vital_sphere_mobile/model/product_category.dart';
import 'package:vital_sphere_mobile/providers/base_provider.dart';

class ProductCategoryProvider extends BaseProvider<ProductCategory> {
  ProductCategoryProvider() : super("ProductCategory");

  @override
  ProductCategory fromJson(dynamic json) {
    return ProductCategory.fromJson(json);
  }
}

