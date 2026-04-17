// =======================================================
// CHAT MESSAGE MODEL
// -------------------------------------------------------
// Estrutura de cada mensagem do chat
// =======================================================

import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessageModel {
  final String id;
  final String senderId;
  final String text;
  final DateTime? createdAt;
  final List<String> readBy;

  const ChatMessageModel({
    required this.id,
    required this.senderId,
    required this.text,
    required this.createdAt,
    required this.readBy,
  });

  // =====================================================
  // FROM FIRESTORE
  // =====================================================
  factory ChatMessageModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};

    return ChatMessageModel(
      id: doc.id,
      senderId: (data['senderId'] ?? '').toString(),
      text: (data['text'] ?? '').toString(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      readBy: (data['readBy'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  // =====================================================
  // TO MAP
  // =====================================================
  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'text': text,
      'createdAt': createdAt,
      'readBy': readBy,
    };
  }

  // =====================================================
  // COPY WITH
  // =====================================================
  ChatMessageModel copyWith({
    String? id,
    String? senderId,
    String? text,
    DateTime? createdAt,
    List<String>? readBy,
  }) {
    return ChatMessageModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      readBy: readBy ?? this.readBy,
    );
  }
}