import 'package:vital_sphere_desktop/model/organizer.dart';
import 'package:vital_sphere_desktop/providers/base_provider.dart';

class OrganizerProvider extends BaseProvider<Organizer> {
  OrganizerProvider() : super('Organizer');

  @override
  Organizer fromJson(dynamic json) {
    return Organizer.fromJson(json as Map<String, dynamic>);
  }
}
