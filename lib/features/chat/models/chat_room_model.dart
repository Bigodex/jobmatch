// =======================================================
// CHAT ROOM MODEL
// -------------------------------------------------------
// Estrutura da sala/conversa direta
// =======================================================

import 'package:cloud_firestore/cloud_firestore.dart';

import 'chat_user_preview_model.dart';

class ChatRoomModel {
  final String id;
  final List<String> participantIds;
  final Map<String, ChatUserPreviewModel> participantSummaries;
  final String lastMessageText;
  final String lastMessageSenderId;
  final DateTime? lastMessageAt;
  final DateTime? createdAt;
  final Map<String, DateTime?> lastReadAtByUser;

  const ChatRoomModel({
    required this.id,
    required this.participantIds,
    required this.participantSummaries,
    required this.lastMessageText,
    required this.lastMessageSenderId,
    required this.lastMessageAt,
    required this.createdAt,
    required this.lastReadAtByUser,
  });

  // =====================================================
  // FROM FIRESTORE
  // =====================================================
  factory ChatRoomModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};

    final rawSummaries =
        Map<String, dynamic>.from(data['participantSummaries'] ?? {});

    final summaries = <String, ChatUserPreviewModel>{
      for (final entry in rawSummaries.entries)
        entry.key: ChatUserPreviewModel.fromMap(
          entry.key,
          Map<String, dynamic>.from(entry.value ?? {}),
        ),
    };

    final rawReadMap =
        Map<String, dynamic>.from(data['lastReadAtByUser'] ?? {});

    return ChatRoomModel(
      id: doc.id,
      participantIds: (data['participantIds'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      participantSummaries: summaries,
      lastMessageText: (data['lastMessageText'] ?? '').toString(),
      lastMessageSenderId: (data['lastMessageSenderId'] ?? '').toString(),
      lastMessageAt: (data['lastMessageAt'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      lastReadAtByUser: {
        for (final entry in rawReadMap.entries)
          entry.key: (entry.value as Timestamp?)?.toDate(),
      },
    );
  }

  // =====================================================
  // PEGA O OUTRO PARTICIPANTE
  // =====================================================
  ChatUserPreviewModel? otherParticipant(String currentUserId) {
    for (final participantId in participantIds) {
      if (participantId != currentUserId) {
        return participantSummaries[participantId];
      }
    }
    return null;
  }

  // =====================================================
  // VALIDA SE TEM NÃO LIDO
  // =====================================================
  bool hasUnread(String currentUserId) {
    if (lastMessageSenderId.isEmpty || lastMessageAt == null) {
      return false;
    }

    if (lastMessageSenderId == currentUserId) {
      return false;
    }

    final lastReadAt = lastReadAtByUser[currentUserId];

    if (lastReadAt == null) {
      return true;
    }

    return lastReadAt.isBefore(lastMessageAt!);
  }
}