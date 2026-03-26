// =======================================================
// SOCIAL LINK MODEL
// -------------------------------------------------------
// Links externos (GitHub, Behance, etc)
// =======================================================

class SocialLinkModel {
  final String label;
  final String url;

  SocialLinkModel({
    required this.label,
    required this.url,
  });

  factory SocialLinkModel.fromMap(Map<String, dynamic> map) {
    return SocialLinkModel(
      label: map['label'] ?? '',
      url: map['url'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'url': url,
    };
  }
}