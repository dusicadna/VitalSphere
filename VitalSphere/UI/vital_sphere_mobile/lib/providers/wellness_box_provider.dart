import 'package:vital_sphere_mobile/model/wellness_box.dart';
import 'package:vital_sphere_mobile/providers/base_provider.dart';

class WellnessBoxProvider extends BaseProvider<WellnessBox> {
  WellnessBoxProvider() : super("WellnessBox");

  @override
  WellnessBox fromJson(dynamic json) {
    return WellnessBox.fromJson(json);
  }
}

