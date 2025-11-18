import 'package:vital_sphere_mobile/model/brand.dart';
import 'package:vital_sphere_mobile/providers/base_provider.dart';

class BrandProvider extends BaseProvider<Brand> {
  BrandProvider() : super("Brand");

  @override
  Brand fromJson(dynamic json) {
    return Brand.fromJson(json);
  }
}

