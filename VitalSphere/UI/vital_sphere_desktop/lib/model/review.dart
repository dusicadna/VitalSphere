import 'package:json_annotation/json_annotation.dart';

part 'review.g.dart';

@JsonSerializable()
class Review {
  final int id;
  final int rating;
  final String? comment;
  final DateTime createdAt;
  final int wellnessServiceId;
  final String wellnessServiceName;
  final int userId;
  final String userFullName;
  final int appointmentId;
  final String? wellnessServiceImage;

  const Review({
    this.id = 0,
    this.rating = 0,
    this.comment,
    required this.createdAt,
    this.wellnessServiceId = 0,
    this.wellnessServiceName = '',
    this.userId = 0,
    this.userFullName = '',
    this.appointmentId = 0,
    this.wellnessServiceImage,
  });

  factory Review.fromJson(Map<String, dynamic> json) => _$ReviewFromJson(json);
  Map<String, dynamic> toJson() => _$ReviewToJson(this);
}
