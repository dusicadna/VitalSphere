import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:vital_sphere_mobile/model/wellness_service.dart';
import 'package:vital_sphere_mobile/providers/base_provider.dart';

class WellnessServiceProvider extends BaseProvider<WellnessService> {
  WellnessServiceProvider() : super("WellnessService");

  @override
  WellnessService fromJson(dynamic json) {
    return WellnessService.fromJson(json);
  }

  Future<WellnessService?> getRecommendationForUser(int userId) async {
    var url = "${BaseProvider.baseUrl}$endpoint/user/$userId/recommend";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await http.get(uri, headers: headers);

    if (isValidResponse(response)) {
      if (response.body.isEmpty) return null;
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw Exception("Unknown error");
    }
  }
}






