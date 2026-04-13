// =======================================================
// PROFILE MODEL
// -------------------------------------------------------
// Estrutura completa do perfil
// - fromMap
// - toMap
// - copyWith
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
  // FROM MAP
  // =======================================================
  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    return ProfileModel(
      user: map['user'] != null
          ? UserModel.fromMap(Map<String, dynamic>.from(map['user']))
          : UserModel(
              name: '',
              role: '',
              avatarUrl: '',
              coverUrl: '',
              connections: 0,
              views: 0, email: '',
            ),
      resume: map['resume'] != null
          ? ResumeModel.fromMap(Map<String, dynamic>.from(map['resume']))
          : ResumeModel(
              birthDate: null,
              city: null,
              description: null,
              labels: ResumeLabels.defaultLabels(),
            ),
      experiences: map['experiences'] != null
          ? List<ExperienceModel>.from(
              (map['experiences'] as List).map(
                (item) => ExperienceModel.fromMap(
                  Map<String, dynamic>.from(item),
                ),
              ),
            )
          : [],
      education: map['education'] != null
          ? List<EducationModel>.from(
              (map['education'] as List).map(
                (item) => EducationModel.fromMap(
                  Map<String, dynamic>.from(item),
                ),
              ),
            )
          : [],
      languages: map['languages'] != null
          ? List<LanguageModel>.from(
              (map['languages'] as List).map(
                (item) => LanguageModel.fromMap(
                  Map<String, dynamic>.from(item),
                ),
              ),
            )
          : [],
      softSkills: map['softSkills'] != null
          ? List<SoftSkillModel>.from(
              (map['softSkills'] as List).map(
                (item) => SoftSkillModel.fromMap(
                  Map<String, dynamic>.from(item),
                ),
              ),
            )
          : [],
      techSkills: map['techSkills'] != null
          ? List<TechSkillModel>.from(
              (map['techSkills'] as List).map(
                (item) => TechSkillModel.fromMap(
                  Map<String, dynamic>.from(item),
                ),
              ),
            )
          : [],
      links: map['links'] != null
          ? List<SocialLinkModel>.from(
              (map['links'] as List).map(
                (item) => SocialLinkModel.fromMap(
                  Map<String, dynamic>.from(item),
                ),
              ),
            )
          : [],
    );
  }

  // =======================================================
  // TO MAP
  // =======================================================
  Map<String, dynamic> toMap() {
    return {
      'user': user.toMap(),
      'resume': resume.toMap(),
      'experiences': experiences.map((e) => e.toMap()).toList(),
      'education': education.map((e) => e.toMap()).toList(),
      'languages': languages.map((e) => e.toMap()).toList(),
      'softSkills': softSkills.map((e) => e.toMap()).toList(),
      'techSkills': techSkills.map((e) => e.toMap()).toList(),
      'links': links.map((e) => e.toMap()).toList(),
    };
  }

  // =======================================================
  // COPY WITH
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