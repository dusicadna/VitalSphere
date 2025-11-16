import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:vital_sphere_desktop/model/gift.dart';
import 'package:vital_sphere_desktop/providers/base_provider.dart';

class GiftProvider extends BaseProvider<Gift> {
  GiftProvider() : super("Gift");

  @override
  Gift fromJson(dynamic json) {
    return Gift.fromJson(json);
  }

  /// Marks a gift as picked up by calling `POST Gift/{id}/pickup`
  /// and returns the updated gift from the backend.
  Future<Gift?> markAsPickedUp(int id) async {
    final url = "${BaseProvider.baseUrl}$endpoint/$id/pickup";
    final uri = Uri.parse(url);
    final headers = createHeaders();

    final response = await http.post(uri, headers: headers);

    if (isValidResponse(response)) {
      if (response.body.isEmpty) return null;
      final data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw Exception("Failed to mark gift as picked up");
    }
  }
}

