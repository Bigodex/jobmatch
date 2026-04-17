// =======================================================
// NETWORK DISCOVER PROFILE MODEL
// -------------------------------------------------------
// Modelo público usado na listagem da tela de networking
// =======================================================

class NetworkDiscoverProfileModel {
  final String id;
  final String name;
  final String role;
  final String avatarUrl;
  final String coverUrl;
  final String city;
  final List<String> tags;
  final bool isRecruiter;
  final bool isCompany;

  const NetworkDiscoverProfileModel({
    required this.id,
    required this.name,
    required this.role,
    required this.avatarUrl,
    required this.coverUrl,
    required this.city,
    required this.tags,
    required this.isRecruiter,
    required this.isCompany,
  });

  factory NetworkDiscoverProfileModel.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    return NetworkDiscoverProfileModel(
      id: id,
      name: (map['name'] ?? '').toString().trim(),
      role: (map['role'] ?? '').toString().trim(),
      avatarUrl: (map['avatarUrl'] ?? '').toString().trim(),
      coverUrl: (map['coverUrl'] ?? '').toString().trim(),
      city: (map['city'] ?? '').toString().trim(),
      tags: map['tags'] != null
          ? List<String>.from((map['tags'] as List).map((e) => e.toString()))
          : const [],
      isRecruiter: map['isRecruiter'] == true,
      isCompany: map['isCompany'] == true,
    );
  }

  String get searchableText {
    return [
      name,
      role,
      city,
      ...tags,
    ].join(' ').toLowerCase().trim();
  }

  bool matchesSearch(String query) {
    final normalized = query.trim().toLowerCase();

    if (normalized.isEmpty) return true;

    return searchableText.contains(normalized);
  }

  bool matchesFilter(String filter) {
    final normalized = filter.trim().toLowerCase();

    if (normalized.isEmpty || normalized == 'todos') {
      return true;
    }

    if (normalized == 'empresas') {
      return isCompany;
    }

    if (normalized == 'recrutadores') {
      return isRecruiter;
    }

    return tags.map((e) => e.toLowerCase()).contains(normalized);
  }
}