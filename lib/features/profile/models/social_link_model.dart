// =======================================================
// SOCIAL LINK MODEL
// -------------------------------------------------------
// Links externos (GitHub, Behance, etc)
// - Suporte a lista
// - Pronto para Firestore
// =======================================================

class SocialLinkModel {
  final String label;
  final String url;

  SocialLinkModel({
    required this.label,
    required this.url,
  });

  // =======================================================
  // FROM MAP
  // =======================================================
  factory SocialLinkModel.fromMap(Map<String, dynamic> map) {
    return SocialLinkModel(
      label: map['label'] ?? '',
      url: map['url'] ?? '',
    );
  }

  // =======================================================
  // TO MAP
  // =======================================================
  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'url': url,
    };
  }

  // =======================================================
  // LIST FROM MAP
  // =======================================================
  static List<SocialLinkModel> fromList(List<dynamic>? list) {
    if (list == null) return [];

    return list
        .map((e) => SocialLinkModel.fromMap(
              Map<String, dynamic>.from(e),
            ))
        .toList();
  }

  // =======================================================
  // LIST TO MAP
  // =======================================================
  static List<Map<String, dynamic>> toList(
      List<SocialLinkModel> links) {
    return links.map((e) => e.toMap()).toList();
  }
}