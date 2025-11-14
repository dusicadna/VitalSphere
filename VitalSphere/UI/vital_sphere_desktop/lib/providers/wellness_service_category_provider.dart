import 'package:vital_sphere_desktop/model/wellness_service_category.dart';
import 'package:vital_sphere_desktop/providers/base_provider.dart';

class WellnessServiceCategoryProvider extends BaseProvider<WellnessServiceCategory> {
  WellnessServiceCategoryProvider() : super("WellnessServiceCategory");

  @override
  WellnessServiceCategory fromJson(dynamic json) {
    return WellnessServiceCategory.fromJson(json);
  }
}

