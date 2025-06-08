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
    final request = await HttpClient().postUrl(url);
    request.headers.set('Content-Type', 'application/json');
    request.add(utf8.encode(json.encode(user.toMap())));
    final response = await request.close();
    if (response.statusCode != 200) {
      throw Exception('Failed to save user profile: ${response.statusCode}');
    }
  }

  static Future<UserModel?> getUserProfile(String uid) async {
    final url = Uri.parse('$getDatabaseUrl?uid=$uid');
    final request = await HttpClient().getUrl(url);
    final response = await request.close();
    String? jsonString; // 提升到方法級別

    if (response.statusCode == 200) {
      jsonString = await response.transform(utf8.decoder).join();
      try {
        if (jsonString.isEmpty || (!jsonString.startsWith('{') && !jsonString.startsWith('['))) {
          print('Raw response is not valid JSON: $jsonString');
          return null;
        }
        final Map<String, dynamic> data = json.decode(jsonString) as Map<String, dynamic>;
        return UserModel.fromMap(data);
      } catch (e) {
        print('Error decoding JSON: $e, Raw response: $jsonString');
        return null;
      }
    } else if (response.statusCode == 404) {
      return null;
    } else {
      jsonString = await response.transform(utf8.decoder).join(); // 獲取回應內容
      throw Exception('Failed to fetch user profile: ${response.statusCode}, Response: $jsonString');
    }
  }

  static Future<UserModel> createUserProfile(UserModel user) async {
    final url = Uri.parse(registerDatabaseUrl);
    final request = await HttpClient().postUrl(url);
    request.headers.set('Content-Type', 'application/json');
    request.add(utf8.encode(json.encode(user.toMap())));
    final response = await request.close();
    if (response.statusCode == 200) {
      print('User profile created successfully! Status: ${response.statusCode}');
      return user;
    } else {
      final responseBody = await response.transform(utf8.decoder).join();
      print('Failed to create user profile. Status: ${response.statusCode}, Response: $responseBody');
      throw Exception('Failed to create user profile: ${response.statusCode}, Response: $responseBody');
    }
  }
}