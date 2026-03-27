// =======================================================
// CLOUDINARY SERVICE
// -------------------------------------------------------
// Upload de imagens para Cloudinary
// =======================================================

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class CloudinaryService {

  // ===================================================
  // CONFIGURAÇÕES (COLOQUE AS SUAS AQUI)
  // ===================================================
  static const String cloudName = 'dcpgbwynt';
  static const String uploadPreset = 'jobmatch_cover_upload';

  // ===================================================
  // UPLOAD DE IMAGEM
  // ===================================================
  static Future<String?> uploadImage(File file) async {
    final url = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
    );

    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      final resBody = await response.stream.bytesToString();
      final data = jsonDecode(resBody);

      return data['secure_url'];
    } else {
      return null;
    }
  }
}