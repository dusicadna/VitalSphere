import 'package:json_annotation/json_annotation.dart';

part 'gift.g.dart';

@JsonSerializable()
class Gift {
  final int id;
  final int userId;
  final String userName;
  final int wellnessBoxId;
  final String wellnessBoxName;
  final String? wellnessBoxImage;
  final DateTime giftedAt;
  final int giftStatusId;
  final String giftStatusName;

  Gift({
    this.id = 0,
    this.userId = 0,
    this.userName = '',
    this.wellnessBoxId = 0,
    this.wellnessBoxName = '',
    this.wellnessBoxImage,
    required this.giftedAt,
    this.giftStatusId = 0,
    this.giftStatusName = '',
  });

  factory Gift.fromJson(Map<String, dynamic> json) => _$GiftFromJson(json);
  Map<String, dynamic> toJson() => _$GiftToJson(this);
}

