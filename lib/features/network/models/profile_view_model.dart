class ProfileViewModel {
  final String id;
  final String viewerId;
  final String viewedUserId;
  final String name;
  final String role;
  final String city;
  final String avatarUrl;
  final DateTime viewedAt;

  const ProfileViewModel({
    required this.id,
    required this.viewerId,
    required this.viewedUserId,
    required this.name,
    required this.role,
    required this.city,
    required this.avatarUrl,
    required this.viewedAt,
  });
}