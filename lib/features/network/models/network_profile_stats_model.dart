// =======================================================
// NETWORK PROFILE STATS MODEL
// -------------------------------------------------------
// Dados mockados do card de perfil da rede
// =======================================================

class NetworkProfileStatsModel {
  final int connectionsCount;
  final int trophiesCount;
  final int trophiesMax;
  final String trophyRank;

  const NetworkProfileStatsModel({
    required this.connectionsCount,
    required this.trophiesCount,
    required this.trophiesMax,
    required this.trophyRank,
  });

  const NetworkProfileStatsModel.mock()
      : connectionsCount = 12,
        trophiesCount = 14,
        trophiesMax = 40,
        trophyRank = 'Prata';

  NetworkProfileStatsModel copyWith({
    int? connectionsCount,
    int? trophiesCount,
    int? trophiesMax,
    String? trophyRank,
  }) {
    return NetworkProfileStatsModel(
      connectionsCount: connectionsCount ?? this.connectionsCount,
      trophiesCount: trophiesCount ?? this.trophiesCount,
      trophiesMax: trophiesMax ?? this.trophiesMax,
      trophyRank: trophyRank ?? this.trophyRank,
    );
  }
}