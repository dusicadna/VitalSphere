import 'package:vital_sphere_mobile/model/wellness_service.dart';
import 'package:vital_sphere_mobile/providers/base_provider.dart';

class WellnessServiceProvider extends BaseProvider<WellnessService> {
  WellnessServiceProvider() : super("WellnessService");

  @override
  WellnessService fromJson(dynamic json) {
    return WellnessService.fromJson(json);
  }
}






