// =======================================================
// CLOUDINARY CONFIG
// -------------------------------------------------------
// Centraliza as configurações usadas no upload de imagens.
//
// Observação importante:
// - apps mobile não conseguem esconder totalmente valores
//   embutidos no código final.
// - para upload direto pelo app, use sempre upload preset
//   restrito no Cloudinary.
// - em produção mais robusta, o ideal é assinar uploads em
//   um backend próprio.
// =======================================================

class CloudinaryConfig {
  const CloudinaryConfig._();

  // ===================================================
  // CLOUD NAME
  // ---------------------------------------------------
  // Nome da cloud no Cloudinary.
  //
  // Pode ser sobrescrito em build usando:
  // --dart-define=CLOUDINARY_CLOUD_NAME=seu_cloud_name
  // ===================================================
  static const String cloudName = String.fromEnvironment(
    'CLOUDINARY_CLOUD_NAME',
    defaultValue: 'dcpgbwynt',
  );

  // ===================================================
  // UPLOAD PRESET
  // ---------------------------------------------------
  // Preset usado para upload unsigned.
  //
  // Pode ser sobrescrito em build usando:
  // --dart-define=CLOUDINARY_UPLOAD_PRESET=seu_preset
  // ===================================================
  static const String uploadPreset = String.fromEnvironment(
    'CLOUDINARY_UPLOAD_PRESET',
    defaultValue: 'jobmatch_cover_upload',
  );

  // ===================================================
  // UPLOAD URL
  // ---------------------------------------------------
  // Endpoint usado para upload de imagem.
  // ===================================================
  static String get uploadUrl {
    return 'https://api.cloudinary.com/v1_1/$cloudName/image/upload';
  }
}
