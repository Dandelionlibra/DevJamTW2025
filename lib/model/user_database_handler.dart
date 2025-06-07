import 'dart:io';
import 'dart:convert';
import 'user_model.dart';

class UserDatabaseHandler {
  static final String getDatabaseUrl =
      'https://n8n.ja-errorpro.codes/webhook/b9ecbf82-b060-4d25-9747-bcf55e1bc063';
  static final String updateDatabaseUrl =
      'https://n8n.ja-errorpro.codes/webhook/d4239cdb-62b9-44d8-86fc-15dd90915b1a/';
  static final String registerDatabaseUrl =
      'https://n8n.ja-errorpro.codes/webhook/7961c17f-8830-46ad-bf6c-47499dd550cf';

  static Future<void> saveUserProfile(UserModel user) async {
    final url = Uri.parse(updateDatabaseUrl);
    final response = await HttpClient().postUrl(url);
    response.headers.set('Content-Type', 'application/json');
    response.add(utf8.encode(json.encode(user.toMap())));
    final HttpClientResponse httpResponse = await response.close();
    if (httpResponse.statusCode != 200) {
      throw Exception(
        'Failed to save user profile: ${httpResponse.statusCode}',
      );
    }
  }

  static Future<UserModel?> getUserProfile(String uid) async {
    final url = Uri.parse(getDatabaseUrl);
    final response = await HttpClient().getUrl(
      Uri.https(url.toString(), '', {'uid': uid}),
    );
    final HttpClientResponse httpResponse = await response.close();
    if (httpResponse.statusCode == 200) {
      final String jsonString = await httpResponse
          .transform(utf8.decoder)
          .join();
      return UserModel.fromMap(json.decode(jsonString));
    } else if (httpResponse.statusCode == 404) {
      return null; // User not found
    } else {
      throw Exception(
        'Failed to fetch user profile: ${httpResponse.statusCode}',
      );
    }
  }
}
