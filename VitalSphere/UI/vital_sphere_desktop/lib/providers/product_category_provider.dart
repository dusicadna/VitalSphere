import 'package:vital_sphere_desktop/model/product_category.dart';
import 'package:vital_sphere_desktop/providers/base_provider.dart';

class ProductCategoryProvider extends BaseProvider<ProductCategory> {
  ProductCategoryProvider() : super("ProductCategory");

  @override
  ProductCategory fromJson(dynamic json) {
    return ProductCategory.fromJson(json);
  }
}

