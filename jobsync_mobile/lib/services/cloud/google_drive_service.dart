import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;

class GoogleDriveService {
  // Requires OAuth2 token from Google Sign-In
  Future<List<DriveFile>> pickFile(String accessToken) async {
    final client = http.Client();
    final driveApi = drive.DriveApi(client);

    // Get files with specific MIME types (documents, PDFs)
    final files = await driveApi.files.list(
      q: "mimeType='application/pdf' or mimeType='application/vnd.google-apps.document'",
      spaces: 'drive',
    );

    return (files.files ?? []).map((f) => DriveFile(
      id: f.id ?? '',
      name: f.name ?? '',
      mimeType: f.mimeType,
    )).toList();
  }

  Future<String?> downloadFile(String accessToken, String fileId) async {
    final client = http.Client();
    final driveApi = drive.DriveApi(client);

    // Download file content using media option
    final response = await driveApi.files.get(
      fileId,
      downloadOptions: drive.DownloadOptions.fullMedia,
    ) as drive.Media;
    
    // Read the stream into a string
    final bytes = await response.stream.toList();
    final buffer = <int>[];
    for (final chunk in bytes) {
      buffer.addAll(chunk);
    }
    return String.fromCharCodes(buffer);
  }

  Future<void> uploadFile(String accessToken, String filePath, String fileName) async {
    // TODO: Implement file upload
  }
}

class DriveFile {
  final String id;
  final String name;
  final String? mimeType;

  DriveFile({required this.id, required this.name, this.mimeType});

  factory DriveFile.fromJson(Map<String, dynamic> json) {
    return DriveFile(
      id: json['id'],
      name: json['name'],
      mimeType: json['mimeType'],
    );
  }
}
