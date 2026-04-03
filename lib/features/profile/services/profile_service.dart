// =======================================================
// PROFILE SERVICE
// -------------------------------------------------------
// Backend real com Firebase (MULTIUSER CORRETO)
// =======================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  final _auth = FirebaseAuth.instance;

  // =======================================================
  // GET UID
  // =======================================================
  String get _uid {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Usuário não autenticado');
    }
    return user.uid;
  }

  // =======================================================
  // GET PROFILE
  // =======================================================
  Future<ProfileModel> getProfile() async {
    try {
      final doc = await _firestore
          .collection('profiles')
          .doc(_uid) // 🔥 AGORA É POR USUÁRIO
          .get();

      if (!doc.exists || doc.data() == null) {
        throw Exception('Perfil não encontrado');
      }

      final data = doc.data()!;

      print('🔥 FIREBASE PROFILE: $data');

      return ProfileModel(
        user: UserModel.fromMap(data['user']),
        resume: ResumeModel.fromMap(data['resume']),

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
  // CREATE PROFILE (🔥 NOVO)
  // =======================================================
  Future<void> createProfile() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Usuário não autenticado');

      final docRef = _firestore.collection('profiles').doc(user.uid);

      final exists = await docRef.get();

      if (exists.exists) return; // 👈 não recria

      await docRef.set({
        'user': {
          'name': '',
          'role': '',
          'avatarUrl': '',
          'coverUrl': '',
        },
        'resume': {
          'city': '',
          'description': '',
          'birthDate': null,
        },
        'languages': [],
        'softSkills': [],
        'techSkills': [],
        'experiences': [],
        'education': [],
        'links': [],
      });

      print('✅ PROFILE CRIADO!');
    } catch (e) {
      print('❌ ERRO AO CRIAR PROFILE: $e');
      rethrow;
    }
  }

  // =======================================================
  // UPDATE PROFILE
  // =======================================================
  Future<void> updateProfile(ProfileModel profile) async {
    try {
      final data = {
        'user': profile.user.toMap(),
        'resume': profile.resume.toMap(),
        'languages': profile.languages.map((e) => e.toMap()).toList(),
        'softSkills': profile.softSkills.map((e) => e.toMap()).toList(),
        'techSkills': profile.techSkills.map((e) => e.toMap()).toList(),
        'experiences': profile.experiences.map((e) => e.toMap()).toList(),
        'education': profile.education.map((e) => e.toMap()).toList(),
        'links': profile.links.map((e) => e.toMap()).toList(),
      };

      await _firestore
          .collection('profiles')
          .doc(_uid) // 🔥 AGORA CORRETO
          .set(data, SetOptions(merge: true));

      print('✅ PROFILE ATUALIZADO!');
    } catch (e) {
      print('❌ ERRO AO ATUALIZAR PROFILE: $e');
      rethrow;
    }
  }
}