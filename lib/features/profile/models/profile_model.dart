// =======================================================
// PROFILE MODEL
// -------------------------------------------------------
// Estrutura completa do perfil
// =======================================================

import 'user_model.dart';
import 'resume_model.dart';
import 'experience_model.dart';
import 'education_model.dart';
import 'language_model.dart';
import 'soft_skill_model.dart';
import 'tech_skill_model.dart';
import 'social_link_model.dart';

class ProfileModel {
  final UserModel user;
  final ResumeModel resume;
  final List<ExperienceModel> experiences;
  final List<EducationModel> education;
  final List<LanguageModel> languages;
  final List<SoftSkillModel> softSkills;
  final List<TechSkillModel> techSkills;
  final List<SocialLinkModel> links;

  ProfileModel({
    required this.user,
    required this.resume,
    required this.experiences,
    required this.education,
    required this.languages,
    required this.softSkills,
    required this.techSkills,
    required this.links,
  });

  // =======================================================
  // COPY WITH (CORRETO)
  // =======================================================
  ProfileModel copyWith({
    UserModel? user,
    ResumeModel? resume,
    List<ExperienceModel>? experiences,
    List<EducationModel>? education,
    List<LanguageModel>? languages,
    List<SoftSkillModel>? softSkills,
    List<TechSkillModel>? techSkills,
    List<SocialLinkModel>? links,
  }) {
    return ProfileModel(
      user: user ?? this.user,
      resume: resume ?? this.resume,
      experiences: experiences ?? this.experiences,
      education: education ?? this.education,
      languages: languages ?? this.languages,
      softSkills: softSkills ?? this.softSkills,
      techSkills: techSkills ?? this.techSkills,
      links: links ?? this.links,
    );
  }
}