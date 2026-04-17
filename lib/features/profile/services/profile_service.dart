// =======================================================
// PROFILE SERVICE
// -------------------------------------------------------
// Backend real com Firebase (MULTIUSER CORRETO)
// + sync de perfil público para tela de networking
// + busca de perfil por id para tela pública
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
  // GET PROFILE (USUÁRIO LOGADO)
  // =======================================================
  Future<ProfileModel> getProfile() async {
    try {
      final doc = await _firestore.collection('profiles').doc(_uid).get();

      if (!doc.exists || doc.data() == null) {
        throw Exception('Perfil não encontrado');
      }

      final data = doc.data()!;

      print('🔥 FIREBASE PROFILE: $data');

      return _mapProfile(data);
    } catch (e) {
      print('❌ ERRO AO BUSCAR PROFILE: $e');
      rethrow;
    }
  }

  // =======================================================
  // GET PROFILE BY ID (PERFIL PÚBLICO / OUTRO USUÁRIO)
  // =======================================================
  Future<ProfileModel> getProfileById(String userId) async {
    try {
      final doc = await _firestore.collection('profiles').doc(userId).get();

      if (!doc.exists || doc.data() == null) {
        throw Exception('Perfil público não encontrado');
      }

      final data = doc.data()!;

      print('🔥 FIREBASE PUBLIC PROFILE [$userId]: $data');

      return _mapProfile(data);
    } catch (e) {
      print('❌ ERRO AO BUSCAR PROFILE POR ID: $e');
      rethrow;
    }
  }

  // =======================================================
  // CREATE PROFILE
  // =======================================================
  Future<void> createProfile() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Usuário não autenticado');

      final docRef = _firestore.collection('profiles').doc(user.uid);
      final exists = await docRef.get();

      if (exists.exists) return;

      await docRef.set({
        'user': {
          'name': '',
          'email': user.email ?? '',
          'role': '',
          'avatarUrl': '',
          'coverUrl': '',
          'connections': 0,
          'views': 0,
        },
        'resume': {
          'state': '',
          'city': '',
          'description': '',
          'birthDate': null,
          'labels': ResumeLabels.defaultLabels().toMap(),
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
          .doc(_uid)
          .set(data, SetOptions(merge: true));

      await syncPublicProfile(profile);

      print('✅ PROFILE ATUALIZADO!');
    } catch (e) {
      print('❌ ERRO AO ATUALIZAR PROFILE: $e');
      rethrow;
    }
  }

  // =======================================================
  // SYNC PUBLIC PROFILE
  // -------------------------------------------------------
  // Espelha apenas os dados públicos para a rede
  // =======================================================
  Future<void> syncPublicProfile(ProfileModel profile) async {
    try {
      final tags = _buildPublicTags(profile);

      final publicData = {
        'uid': _uid,
        'name': profile.user.name.trim(),
        'role': profile.user.role.trim(),
        'avatarUrl': profile.user.avatarUrl.trim(),
        'coverUrl': profile.user.coverUrl.trim(),
        'city': (profile.resume.city ?? '').trim(),
        'state': (profile.resume.state ?? '').trim(),
        'connections': profile.user.connections,
        'views': profile.user.views,
        'tags': tags,
        'searchable': _buildSearchableText(profile, tags),
        'isRecruiter': _isRecruiter(profile.user.role),
        'isCompany': false,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('public_profiles')
          .doc(_uid)
          .set(publicData, SetOptions(merge: true));

      print('✅ PUBLIC PROFILE SINCRONIZADO!');
    } catch (e) {
      print('❌ ERRO AO SINCRONIZAR PUBLIC PROFILE: $e');
      rethrow;
    }
  }

  // =======================================================
  // MAP PROFILE
  // =======================================================
  ProfileModel _mapProfile(Map<String, dynamic> data) {
    return ProfileModel(
      user: UserModel.fromMap(
        Map<String, dynamic>.from(data['user'] ?? {}),
      ),
      resume: ResumeModel.fromMap(
        Map<String, dynamic>.from(data['resume'] ?? {}),
      ),
      languages: data['languages'] != null
          ? (data['languages'] as List)
              .map((e) => LanguageModel.fromMap(Map<String, dynamic>.from(e)))
              .toList()
          : [],
      softSkills: data['softSkills'] != null
          ? (data['softSkills'] as List)
              .map((e) => SoftSkillModel.fromMap(Map<String, dynamic>.from(e)))
              .toList()
          : [],
      techSkills: data['techSkills'] != null
          ? (data['techSkills'] as List)
              .map((e) => TechSkillModel.fromMap(Map<String, dynamic>.from(e)))
              .toList()
          : [],
      experiences: data['experiences'] != null
          ? (data['experiences'] as List)
              .map((e) => ExperienceModel.fromMap(Map<String, dynamic>.from(e)))
              .toList()
          : [],
      education: data['education'] != null
          ? (data['education'] as List)
              .map((e) => EducationModel.fromMap(Map<String, dynamic>.from(e)))
              .toList()
          : [],
      links: data['links'] != null
          ? (data['links'] as List)
              .map((e) => SocialLinkModel.fromMap(Map<String, dynamic>.from(e)))
              .toList()
          : [],
    );
  }

  // =======================================================
  // HELPERS
  // =======================================================
  List<String> _buildPublicTags(ProfileModel profile) {
    final role = profile.user.role.toLowerCase();
    final tags = <String>{};

    if (role.contains('design') ||
        role.contains('ux') ||
        role.contains('ui')) {
      tags.add('design');
    }

    if (role.contains('produto') ||
        role.contains('product') ||
        role.contains('pm')) {
      tags.add('produto');
    }

    if (role.contains('recruit') ||
        role.contains('talent') ||
        role.contains('rh')) {
      tags.add('recrutadores');
    }

    if (tags.isEmpty) {
      tags.add('tecnologia');
    }

    return tags.toList();
  }

  String _buildSearchableText(
    ProfileModel profile,
    List<String> tags,
  ) {
    final parts = [
      profile.user.name,
      profile.user.role,
      profile.resume.city ?? '',
      profile.resume.state ?? '',
      ...tags,
    ];

    return parts
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .join(' ')
        .toLowerCase();
  }

  bool _isRecruiter(String role) {
    final normalized = role.toLowerCase();

    return normalized.contains('recruit') ||
        normalized.contains('talent') ||
        normalized.contains('rh');
  }
}