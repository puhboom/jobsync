import 'dart:convert';
import 'package:http/http.dart' as http;

class OneDriveService {
  static const String graphEndpoint = 'https://graph.microsoft.com/v1.0';

  Future<List<OneDriveItem>> pickFile(String accessToken) async {
    final response = await http.get(
      Uri.parse('$graphEndpoint/me/drive/root/children'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final items = data['value'] as List;
      return items
          .where((item) => item['file'] != null)
          .map((item) => OneDriveItem.fromJson(item))
          .toList();
    }
    return [];
  }

  Future<String?> downloadFile(String accessToken, String fileId) async {
    final response = await http.get(
      Uri.parse('$graphEndpoint/me/drive/items/$fileId/content'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 200) {
      return response.body;
    }
    return null;
  }
}

class OneDriveItem {
  final String id;
  final String name;
  final String? webUrl;

  OneDriveItem({required this.id, required this.name, this.webUrl});

  factory OneDriveItem.fromJson(Map<String, dynamic> json) {
    return OneDriveItem(
      id: json['id'],
      name: json['name'],
      webUrl: json['webUrl'],
    );
  }
}
