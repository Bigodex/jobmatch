// =======================================================
// PROFILE SERVICE
// -------------------------------------------------------
// Backend real com Firebase
//
// Estrutura:
// - Busca do Firestore
// - Fallback preparado (comentado)
// - Pronto para expansão futura
// =======================================================

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/profile_model.dart';
import '../models/user_model.dart';
import '../models/resume_model.dart';
import '../models/language_model.dart';
import '../models/soft_skill_model.dart';
import '../models/tech_skill_model.dart';
import '../models/experience_model.dart';
import '../models/education_model.dart';
import '../models/social_link_model.dart';

class ProfileService {
  final _firestore = FirebaseFirestore.instance;

  // =======================================================
  // GET PROFILE (FIREBASE)
  // =======================================================
  Future<ProfileModel> getProfile() async {
    try {
      final doc = await _firestore
          .collection('profiles')
          .doc('S0izTate1BROQEV81Ct4') // 👈 seu ID atual
          .get();

      if (!doc.exists || doc.data() == null) {
        throw Exception('Perfil não encontrado');
      }

      final data = doc.data()!;

      // ===================================================
      // DEBUG
      // ===================================================
      print('🔥 FIREBASE PROFILE: $data');

      return ProfileModel(
        user: UserModel.fromMap(data['user']),
        resume: ResumeModel.fromMap(data['resume']),

        // ===================================================
        // FUTURO (quando adicionar no Firestore)
        // ===================================================
        languages: data['languages'] != null
            ? (data['languages'] as List)
                .map((e) => LanguageModel.fromMap(e))
                .toList()
            : [],

        softSkills: data['softSkills'] != null
            ? (data['softSkills'] as List)
                .map((e) => SoftSkillModel.fromMap(e))
                .toList()
            : [],

        techSkills: data['techSkills'] != null
            ? (data['techSkills'] as List)
                .map((e) => TechSkillModel.fromMap(e))
                .toList()
            : [],

        experiences: data['experiences'] != null
            ? (data['experiences'] as List)
                .map((e) => ExperienceModel.fromMap(e))
                .toList()
            : [],

        education: data['education'] != null
            ? (data['education'] as List)
                .map((e) => EducationModel.fromMap(e))
                .toList()
            : [],

        links: data['links'] != null
            ? (data['links'] as List)
                .map((e) => SocialLinkModel.fromMap(e))
                .toList()
            : [],
      );
    } catch (e) {
      print('❌ ERRO AO BUSCAR PROFILE: $e');
      rethrow;
    }
  }

  // =======================================================
  // 🔥 MOCK DE REFERÊNCIA (NÃO USAR - SOMENTE BACKUP)
  // =======================================================
  /*
  Future<ProfileModel> getProfileMock() async {
    await Future.delayed(const Duration(seconds: 1));

    final Map<String, dynamic> data = {
      'user': {
        'name': 'Pedro Piola',
        'role': 'Desenvolvedor FullStack',
        'avatarUrl': 'https://i.pravatar.cc/150?img=3',
        'coverUrl': 'https://picsum.photos/600/300',
        'connections': 1000,
        'views': 10000,
      },

      'resume': {
        'birthDate': '1996-10-23',
        'city': 'Brasil - Pato Branco PR',
        'description': 'Descrição mock',
        'labels': {
          'title': 'Resumo Profissional',
          'birthDateLabel': 'Data de Nascimento',
          'cityLabel': 'Cidade',
          'descriptionLabel': 'Descrição',
        }
      },

      // 👇 PRÓXIMOS CAMPOS (AINDA NÃO NO FIREBASE)
      'languages': [],
      'softSkills': [],
      'techSkills': [],
      'experiences': [],
      'education': [],
      'links': [],
    };

    return ProfileModel(
      user: UserModel.fromMap(data['user']),
      resume: ResumeModel.fromMap(data['resume']),
      languages: [],
      softSkills: [],
      techSkills: [],
      experiences: [],
      education: [],
      links: [],
    );
  }
  */
}