import 'package:vital_sphere_desktop/model/product.dart';
import 'package:vital_sphere_desktop/providers/base_provider.dart';

class ProductProvider extends BaseProvider<Product> {
  ProductProvider() : super("Product");

  @override
  Product fromJson(dynamic json) {
    return Product.fromJson(json);
  }
}

