// =======================================================
// COMPANY PROFILE MODEL
// -------------------------------------------------------
// Modelo da página/perfil empresarial criada a partir do
// cadastro de empresa.
// =======================================================

class CompanyProfileJobModel {
  final String title;
  final String seniority;
  final String workModel;
  final String location;
  final String salary;
  final String description;

  const CompanyProfileJobModel({
    this.title = '',
    this.seniority = '',
    this.workModel = '',
    this.location = '',
    this.salary = '',
    this.description = '',
  });

  factory CompanyProfileJobModel.fromMap(Map<String, dynamic> map) {
    final city = (map['city'] ?? '').toString().trim();
    final uf = (map['uf'] ?? '').toString().trim();
    final rawLocation = (map['location'] ?? '').toString().trim();

    final normalizedLocation = rawLocation.isNotEmpty
        ? rawLocation
        : city.isEmpty && uf.isEmpty
            ? ''
            : city.isEmpty
                ? uf
                : uf.isEmpty
                    ? city
                    : 'Brasil - $city ($uf)';

    return CompanyProfileJobModel(
      title: (map['title'] ?? '').toString(),
      seniority: (map['seniority'] ?? map['level'] ?? '').toString(),
      workModel: (map['workModel'] ?? map['workMode'] ?? '').toString(),
      location: normalizedLocation,
      salary: (map['salary'] ?? '').toString(),
      description: (map['description'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'seniority': seniority,
      'workModel': workModel,
      'location': location,
      'salary': salary,
      'description': description,
    };
  }
}

class CompanyProfileModel {
  final String id;
  final String ownerId;
  final String coverUrl;
  final String logoUrl;
  final String companyName;
  final String companyCategory;
  final String cnpj;
  final String slogan;
  final String sector;
  final String companyType;
  final String website;
  final String description;
  final bool isHiring;
  final List<CompanyProfileJobModel> jobs;
  final int employeesCount;
  final String companySize;

  const CompanyProfileModel({
    this.id = '',
    this.ownerId = '',
    this.coverUrl = '',
    this.logoUrl = '',
    this.companyName = '',
    this.companyCategory = '',
    this.cnpj = '',
    this.slogan = '',
    this.sector = '',
    this.companyType = '',
    this.website = '',
    this.description = '',
    this.isHiring = false,
    this.jobs = const [],
    this.employeesCount = 0,
    this.companySize = '',
  });

  factory CompanyProfileModel.fromMap(
    Map<String, dynamic> map, {
    String id = '',
  }) {
    final rawJobs = map['jobs'];

    return CompanyProfileModel(
      id: id.isNotEmpty ? id : (map['id'] ?? '').toString(),
      ownerId: (map['ownerId'] ?? '').toString(),
      coverUrl: (map['coverUrl'] ?? '').toString(),
      logoUrl: (map['logoUrl'] ?? '').toString(),
      companyName: (map['companyName'] ?? '').toString(),
      companyCategory: (map['companyCategory'] ?? '').toString(),
      cnpj: (map['cnpj'] ?? '').toString(),
      slogan: (map['slogan'] ?? '').toString(),
      sector: (map['sector'] ?? '').toString(),
      companyType: (map['companyType'] ?? '').toString(),
      website: (map['website'] ?? '').toString(),
      description: (map['description'] ?? '').toString(),
      isHiring: map['isHiring'] == true,
      jobs: rawJobs is List
          ? rawJobs
              .whereType<Map>()
              .map(
                (item) => CompanyProfileJobModel.fromMap(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList()
          : const [],
      employeesCount: _toInt(map['employeesCount']),
      companySize: (map['companySize'] ?? '').toString(),
    );
  }

  CompanyProfileModel copyWith({
    String? id,
    String? ownerId,
    String? coverUrl,
    String? logoUrl,
    String? companyName,
    String? companyCategory,
    String? cnpj,
    String? slogan,
    String? sector,
    String? companyType,
    String? website,
    String? description,
    bool? isHiring,
    List<CompanyProfileJobModel>? jobs,
    int? employeesCount,
    String? companySize,
  }) {
    return CompanyProfileModel(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      coverUrl: coverUrl ?? this.coverUrl,
      logoUrl: logoUrl ?? this.logoUrl,
      companyName: companyName ?? this.companyName,
      companyCategory: companyCategory ?? this.companyCategory,
      cnpj: cnpj ?? this.cnpj,
      slogan: slogan ?? this.slogan,
      sector: sector ?? this.sector,
      companyType: companyType ?? this.companyType,
      website: website ?? this.website,
      description: description ?? this.description,
      isHiring: isHiring ?? this.isHiring,
      jobs: jobs ?? this.jobs,
      employeesCount: employeesCount ?? this.employeesCount,
      companySize: companySize ?? this.companySize,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ownerId': ownerId,
      'coverUrl': coverUrl,
      'logoUrl': logoUrl,
      'companyName': companyName,
      'companyCategory': companyCategory,
      'cnpj': cnpj,
      'slogan': slogan,
      'sector': sector,
      'companyType': companyType,
      'website': website,
      'description': description,
      'isHiring': isHiring,
      'jobs': jobs.map((job) => job.toMap()).toList(),
      'employeesCount': employeesCount,
      'companySize': companySize,
    };
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse((value ?? '').toString()) ?? 0;
  }
}
