import 'package:vital_sphere_desktop/model/appointment.dart';
import 'package:vital_sphere_desktop/providers/base_provider.dart';

class AppointmentProvider extends BaseProvider<Appointment> {
  AppointmentProvider() : super("Appointment");

  @override
  Appointment fromJson(dynamic json) {
    return Appointment.fromJson(json);
  }
}

