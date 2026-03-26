import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SupabaseService {
  SupabaseService._();

  static const String _baseUrl = String.fromEnvironment('API_BASE_URL');
  static const String _apiKey = String.fromEnvironment('API_SECRET_KEY');

  static Map<String, String> get _headers => {'x-api-key': _apiKey};

  // Upload file to Supabase via Express
  // Returns storagePath and fileSizeBytes
  static Future<SupabaseUploadResult> uploadFile({
    required String filePath,
    required String uid,
    required String fileName,
  }) async {
    final file = File(filePath);
    final fileBytes = await file.readAsBytes();
    final fileSize = fileBytes.length;

    final request =
        http.MultipartRequest('POST', Uri.parse('$_baseUrl/storage/upload'))
          ..headers.addAll(_headers)
          ..fields['uid'] = uid
          ..files.add(
            http.MultipartFile.fromBytes('file', fileBytes, filename: fileName),
          );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Upload failed');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final result = data['data'] as Map<String, dynamic>;

    return SupabaseUploadResult(
      storagePath: result['storagePath'] as String,
      fileSizeBytes: result['fileSizeBytes'] as int? ?? fileSize,
    );
  }

  // Upload raw bytes to Supabase via Express (used for copy operations)
  // Returns storagePath
  static Future<String> uploadBytes({
    required List<int> bytes,
    required String storagePath,
    required String fileName,
  }) async {
    final uid = storagePath.split('/')[1]; // extract uid from path

    final request =
        http.MultipartRequest('POST', Uri.parse('$_baseUrl/storage/upload'))
          ..headers.addAll(_headers)
          ..fields['uid'] = uid
          ..files.add(
            http.MultipartFile.fromBytes('file', bytes, filename: fileName),
          );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Upload failed');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final result = data['data'] as Map<String, dynamic>;
    return result['storagePath'] as String;
  }

  static Future<String> getSignedUrl(String storagePath) async {
    final uri = Uri.parse(
      '$_baseUrl/storage/signed-url',
    ).replace(queryParameters: {'path': storagePath});

    final response = await http.get(uri, headers: _headers);

    if (response.statusCode != 200) {
      throw Exception('Failed to get signed URL');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data['data']['url'] as String;
  }

  // Delete a file via Express
  static Future<void> deleteFile(String storagePath) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/storage/delete'),
      headers: {..._headers, 'Content-Type': 'application/json'},
      body: jsonEncode({'storagePath': storagePath}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete file');
    }
  }
}

class SupabaseUploadResult {
  final String storagePath;
  final int fileSizeBytes;

  double get fileSizeMB => fileSizeBytes / (1024 * 1024);

  const SupabaseUploadResult({
    required this.storagePath,
    required this.fileSizeBytes,
  });
}
