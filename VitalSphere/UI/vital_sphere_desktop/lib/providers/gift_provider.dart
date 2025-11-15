import 'package:vital_sphere_desktop/model/gift.dart';
import 'package:vital_sphere_desktop/providers/base_provider.dart';

class GiftProvider extends BaseProvider<Gift> {
  GiftProvider() : super("Gift");

  @override
  Gift fromJson(dynamic json) {
    return Gift.fromJson(json);
  }
}

