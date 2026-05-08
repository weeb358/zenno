import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class StorageService {
  static const _cloudName = 'dv9mbay6p';
  static const _uploadPreset = 'uxz5weix';
  static const _uploadUrl = 'https://api.cloudinary.com/v1_1/$_cloudName/image/upload';

  Future<String> _upload(File imageFile, String folder, String publicId) async {
    final request = http.MultipartRequest('POST', Uri.parse(_uploadUrl));
    request.fields['upload_preset'] = _uploadPreset;
    request.fields['public_id'] = '$folder/$publicId';
    request.fields['folder'] = folder;
    request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    final response = await request.send();
    final body = await response.stream.bytesToString();

    if (response.statusCode != 200) {
      throw Exception('Cloudinary upload failed: ${response.statusCode}');
    }

    final json = jsonDecode(body) as Map<String, dynamic>;
    return json['secure_url'] as String;
  }

  Future<String> uploadGameBanner(File imageFile, String gameId) =>
      _upload(imageFile, 'games/banners', gameId);

  Future<String> uploadUserAvatar(File imageFile, String userId) =>
      _upload(imageFile, 'users/avatars', userId);
}
