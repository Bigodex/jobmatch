// =======================================================
// PROFILE MODEL
// -------------------------------------------------------
// Agrega todos os dados do perfil
// =======================================================

import 'user_model.dart';
import 'resume_model.dart';
import 'language_model.dart';
import 'soft_skill_model.dart';
import 'tech_skill_model.dart';
import 'experience_model.dart';
import 'education_model.dart';
import 'social_link_model.dart';

class ProfileModel {
  final UserModel user;
  final ResumeModel resume;
  final List<LanguageModel> languages;
  final List<SoftSkillModel> softSkills;
  final List<TechSkillModel> techSkills;
  final List<ExperienceModel> experiences;
  final List<EducationModel> education;
  final List<SocialLinkModel> links;

  ProfileModel({
    required this.user,
    required this.resume,
    required this.languages,
    required this.softSkills,
    required this.techSkills,
    required this.experiences,
    required this.education,
    required this.links,
  });

  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    return ProfileModel(
      user: UserModel.fromMap(map['user']),
      resume: ResumeModel.fromMap(map['resume']),
      languages: List<LanguageModel>.from(
        (map['languages'] ?? []).map((x) => LanguageModel.fromMap(x)),
      ),
      softSkills: List<SoftSkillModel>.from(
        (map['softSkills'] ?? []).map((x) => SoftSkillModel.fromMap(x)),
      ),
      techSkills: List<TechSkillModel>.from(
        (map['techSkills'] ?? []).map((x) => TechSkillModel.fromMap(x)),
      ),
      experiences: List<ExperienceModel>.from(
        (map['experiences'] ?? []).map((x) => ExperienceModel.fromMap(x)),
      ),
      education: List<EducationModel>.from(
        (map['education'] ?? []).map((x) => EducationModel.fromMap(x)),
      ),
      links: List<SocialLinkModel>.from(
        (map['links'] ?? []).map((x) => SocialLinkModel.fromMap(x)),
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user': user.toMap(),
      'resume': resume.toMap(),
      'languages': languages.map((e) => e.toMap()).toList(),
      'softSkills': softSkills.map((e) => e.toMap()).toList(),
      'techSkills': techSkills.map((e) => e.toMap()).toList(),
      'experiences': experiences.map((e) => e.toMap()).toList(),
      'education': education.map((e) => e.toMap()).toList(),
      'links': links.map((e) => e.toMap()).toList(),
    };
  }
}