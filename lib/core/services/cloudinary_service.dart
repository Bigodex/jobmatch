// =======================================================
// CLOUDINARY SERVICE
// -------------------------------------------------------
// Service responsável pelo upload de imagens para Cloudinary.
//
// Responsabilidades:
// - receber um arquivo local
// - enviar para o endpoint configurado
// - retornar a URL segura da imagem enviada
//
// Observações:
// - configurações ficam centralizadas em CloudinaryConfig
// - logs passam pelo AppLogger
// - o método mantém retorno String? para não quebrar telas atuais
// =======================================================

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/cloudinary_config.dart';
import '../utils/app_logger.dart';

class CloudinaryService {
  const CloudinaryService._();

  // ===================================================
  // UPLOAD IMAGE
  // ---------------------------------------------------
  // Faz upload de uma imagem local para o Cloudinary.
  //
  // Retorna:
  // - secure_url quando o upload for bem-sucedido
  // - null quando houver erro ou resposta inválida
  // ===================================================
  static Future<String?> uploadImage(File file) async {
    try {
      if (!file.existsSync()) {
        AppLogger.warning(
          'Arquivo de imagem não encontrado para upload.',
          name: 'CloudinaryService',
        );

        return null;
      }

      final url = Uri.parse(CloudinaryConfig.uploadUrl);

      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = CloudinaryConfig.uploadPreset
        ..files.add(
          await http.MultipartFile.fromPath(
            'file',
            file.path,
          ),
        );

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode != 200) {
        AppLogger.warning(
          'Upload recusado pelo Cloudinary. Status: ${response.statusCode}.',
          name: 'CloudinaryService',
        );

        return null;
      }

      final decodedBody = jsonDecode(responseBody);

      if (decodedBody is! Map<String, dynamic>) {
        AppLogger.warning(
          'Resposta inesperada do Cloudinary.',
          name: 'CloudinaryService',
        );

        return null;
      }

      final secureUrl = decodedBody['secure_url'];

      if (secureUrl is! String || secureUrl.trim().isEmpty) {
        AppLogger.warning(
          'Cloudinary não retornou uma secure_url válida.',
          name: 'CloudinaryService',
        );

        return null;
      }

      AppLogger.info(
        'Imagem enviada para o Cloudinary com sucesso.',
        name: 'CloudinaryService',
      );

      return secureUrl;
    } catch (e, st) {
      AppLogger.error(
        'Erro ao fazer upload de imagem para o Cloudinary.',
        error: e,
        stackTrace: st,
        name: 'CloudinaryService',
      );

      return null;
    }
  }
}
