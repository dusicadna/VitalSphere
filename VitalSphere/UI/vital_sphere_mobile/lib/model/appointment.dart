import 'package:json_annotation/json_annotation.dart';

part 'appointment.g.dart';

@JsonSerializable()
class Appointment {
  final int id;
  final int userId;
  final String userName;
  final int wellnessServiceId;
  final String wellnessServiceName;
  final String? wellnessServiceImage;
  final DateTime scheduledAt;
  final String? notes;
  final DateTime createdAt;

  Appointment({
    this.id = 0,
    this.userId = 0,
    this.userName = '',
    this.wellnessServiceId = 0,
    this.wellnessServiceName = '',
    this.wellnessServiceImage,
    required this.scheduledAt,
    this.notes,
    required this.createdAt,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) => _$AppointmentFromJson(json);
  Map<String, dynamic> toJson() => _$AppointmentToJson(this);
}

