// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'appointment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Appointment _$AppointmentFromJson(Map<String, dynamic> json) =>
    Appointment(
      id: (json['id'] as num?)?.toInt() ?? 0,
      userId: (json['userId'] as num?)?.toInt() ?? 0,
      userName: json['userName'] as String? ?? '',
      wellnessServiceId: (json['wellnessServiceId'] as num?)?.toInt() ?? 0,
      wellnessServiceName: json['wellnessServiceName'] as String? ?? '',
      wellnessServiceImage: json['wellnessServiceImage'] as String?,
      scheduledAt: json['scheduledAt'] == null
          ? DateTime.now()
          : DateTime.parse(json['scheduledAt'] as String),
      notes: json['notes'] as String?,
      createdAt: json['createdAt'] == null
          ? DateTime.now()
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$AppointmentToJson(Appointment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'userName': instance.userName,
      'wellnessServiceId': instance.wellnessServiceId,
      'wellnessServiceName': instance.wellnessServiceName,
      'wellnessServiceImage': instance.wellnessServiceImage,
      'scheduledAt': instance.scheduledAt.toIso8601String(),
      'notes': instance.notes,
      'createdAt': instance.createdAt.toIso8601String(),
    };


