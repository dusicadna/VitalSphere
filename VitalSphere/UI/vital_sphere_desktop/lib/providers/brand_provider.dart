import 'package:vital_sphere_desktop/model/brand.dart';
import 'package:vital_sphere_desktop/providers/base_provider.dart';

class BrandProvider extends BaseProvider<Brand> {
  BrandProvider() : super("Brand");

  @override
  Brand fromJson(dynamic json) {
    return Brand.fromJson(json);
  }
}

