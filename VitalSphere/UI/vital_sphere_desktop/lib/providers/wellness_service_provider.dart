import 'package:vital_sphere_desktop/model/wellness_service.dart';
import 'package:vital_sphere_desktop/providers/base_provider.dart';

class WellnessServiceProvider extends BaseProvider<WellnessService> {
  WellnessServiceProvider() : super("WellnessService");

  @override
  WellnessService fromJson(dynamic json) {
    return WellnessService.fromJson(json);
  }
}




