import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ImgBBService {
  static const String _apiKey = '07e0c805e11a0923e1edc5975c5c0821';
  static const String _uploadUrl = 'https://api.imgbb.com/1/upload';

  /// Upload image to ImgBB and return the URL
  /// Returns null if upload fails
  Future<String?> uploadImage(File imageFile) async {
    try {
      // Read image as bytes and convert to base64
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      // Create multipart request
      final request = http.MultipartRequest('POST', Uri.parse(_uploadUrl));
      request.fields['key'] = _apiKey;
      request.fields['image'] = base64Image;

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true) {
          // Return the display URL
          return jsonData['data']['display_url'] as String?;
        }
      }

      print('ImgBB upload failed: ${response.statusCode} - ${response.body}');
      return null;
    } catch (e) {
      print('Error uploading to ImgBB: $e');
      return null;
    }
  }

  /// Upload image from bytes (useful for web)
  Future<String?> uploadImageFromBytes(List<int> bytes, String filename) async {
    try {
      final base64Image = base64Encode(bytes);

      final request = http.MultipartRequest('POST', Uri.parse(_uploadUrl));
      request.fields['key'] = _apiKey;
      request.fields['image'] = base64Image;
      request.fields['name'] = filename;

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true) {
          return jsonData['data']['display_url'] as String?;
        }
      }

      print('ImgBB upload failed: ${response.statusCode} - ${response.body}');
      return null;
    } catch (e) {
      print('Error uploading to ImgBB: $e');
      return null;
    }
  }
}
