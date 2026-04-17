// =======================================================
// CHAT SERVICE
// -------------------------------------------------------
// Regras de chat real via Firestore
// - lista conversas
// - lista usuários
// - envia mensagens
// - marca conversa como lida
// - exclui conversa
// =======================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/chat_message_model.dart';
import '../models/chat_room_model.dart';
import '../models/chat_user_preview_model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // =====================================================
  // CURRENT UID
  // =====================================================
  String get currentUid {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('Usuário não autenticado');
    }

    return user.uid;
  }

  // =====================================================
  // HELPERS
  // =====================================================
  CollectionReference<Map<String, dynamic>> get _roomsRef {
    return _firestore.collection('chat_rooms');
  }

  String buildDirectRoomId(String uidA, String uidB) {
    final ids = [uidA, uidB]..sort();
    return 'direct_${ids.join('_')}';
  }

  // =====================================================
  // WATCH ROOMS
  // =====================================================
  Stream<List<ChatRoomModel>> watchRooms() {
    return _roomsRef
        .where('participantIds', arrayContains: currentUid)
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map(ChatRoomModel.fromFirestore)
          .where((room) => room.participantIds.length >= 2)
          .toList();
    });
  }

  // =====================================================
  // WATCH PEOPLE
  // =====================================================
  Stream<List<ChatUserPreviewModel>> watchPeople() {
    return _firestore.collection('profiles').snapshots().map((snapshot) {
      final people = snapshot.docs
          .where((doc) => doc.id != currentUid)
          .map((doc) {
            final data = doc.data();
            final userMap = Map<String, dynamic>.from(data['user'] ?? {});
            return ChatUserPreviewModel.fromMap(doc.id, userMap);
          })
          .where((person) =>
              person.name.trim().isNotEmpty || person.email.trim().isNotEmpty)
          .toList();

      people.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      return people;
    });
  }

  // =====================================================
  // WATCH USER PREVIEW
  // =====================================================
  Stream<ChatUserPreviewModel?> watchUserPreview(String uid) {
    return _firestore.collection('profiles').doc(uid).snapshots().map((doc) {
      final data = doc.data();
      if (data == null) return null;

      final userMap = Map<String, dynamic>.from(data['user'] ?? {});
      return ChatUserPreviewModel.fromMap(uid, userMap);
    });
  }

  // =====================================================
  // WATCH MESSAGES
  // =====================================================
  Stream<List<ChatMessageModel>> watchMessages(String otherUserId) {
    final roomId = buildDirectRoomId(currentUid, otherUserId);

    return _roomsRef
        .doc(roomId)
        .collection('messages')
        .orderBy('createdAt')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map(ChatMessageModel.fromFirestore).toList();
    });
  }

  // =====================================================
  // SEND MESSAGE
  // =====================================================
  Future<void> sendMessage({
    required String otherUserId,
    required String text,
  }) async {
    final cleanText = text.trim();

    if (cleanText.isEmpty) return;

    final myUid = currentUid;
    final roomId = buildDirectRoomId(myUid, otherUserId);

    final roomRef = _roomsRef.doc(roomId);
    final messageRef = roomRef.collection('messages').doc();

    final roomSnapshot = await roomRef.get();
    final me = await _getUserPreviewByUid(myUid);
    final other = await _getUserPreviewByUid(otherUserId);

    final participantIds = [myUid, otherUserId]..sort();

    final batch = _firestore.batch();

    final roomData = <String, dynamic>{
      'type': 'direct',
      'participantIds': participantIds,
      'participantSummaries': {
        myUid: me.toMap(),
        otherUserId: other.toMap(),
      },
      'lastMessageText': cleanText,
      'lastMessageSenderId': myUid,
      'lastMessageAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'lastReadAtByUser': {
        myUid: FieldValue.serverTimestamp(),
      },
    };

    if (!roomSnapshot.exists) {
      roomData['createdAt'] = FieldValue.serverTimestamp();
    }

    batch.set(
      roomRef,
      roomData,
      SetOptions(merge: true),
    );

    batch.set(messageRef, {
      'senderId': myUid,
      'text': cleanText,
      'createdAt': FieldValue.serverTimestamp(),
      'readBy': [myUid],
    });

    await batch.commit();
  }

  // =====================================================
  // MARK AS READ
  // =====================================================
  Future<void> markConversationAsRead(String otherUserId) async {
    final roomId = buildDirectRoomId(currentUid, otherUserId);

    await _roomsRef.doc(roomId).set(
      {
        'lastReadAtByUser': {
          currentUid: FieldValue.serverTimestamp(),
        },
      },
      SetOptions(merge: true),
    );
  }

  // =====================================================
  // DELETE CONVERSATION
  // =====================================================
  Future<void> deleteConversation(String otherUserId) async {
    final roomId = buildDirectRoomId(currentUid, otherUserId);
    final roomRef = _roomsRef.doc(roomId);
    final roomSnapshot = await roomRef.get();

    if (!roomSnapshot.exists) {
      return;
    }

    while (true) {
      final messagesSnapshot = await roomRef
          .collection('messages')
          .limit(100)
          .get();

      if (messagesSnapshot.docs.isEmpty) {
        break;
      }

      final batch = _firestore.batch();

      for (final doc in messagesSnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();

      if (messagesSnapshot.docs.length < 100) {
        break;
      }
    }

    await roomRef.delete();
  }

  // =====================================================
  // GET USER PREVIEW
  // =====================================================
  Future<ChatUserPreviewModel> _getUserPreviewByUid(String uid) async {
    final doc = await _firestore.collection('profiles').doc(uid).get();
    final data = doc.data();

    if (data == null) {
      throw Exception('Perfil do usuário não encontrado para o chat.');
    }

    final userMap = Map<String, dynamic>.from(data['user'] ?? {});
    return ChatUserPreviewModel.fromMap(uid, userMap);
  }
}