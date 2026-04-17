// =======================================================
// CHAT PROVIDERS
// -------------------------------------------------------
// Estado e streams do módulo de chat
// =======================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/chat_message_model.dart';
import '../models/chat_room_model.dart';
import '../models/chat_user_preview_model.dart';
import '../services/chat_service.dart';

// =======================================================
// TAB
// =======================================================
enum ChatInboxTab {
  people,
  companies,
}

// =======================================================
// SERVICE
// =======================================================
final chatServiceProvider = Provider<ChatService>((ref) {
  return ChatService();
});

// =======================================================
// SEARCH
// =======================================================
final chatSearchProvider = StateProvider<String>((ref) {
  return '';
});

// =======================================================
// TAB STATE
// =======================================================
final chatTabProvider = StateProvider<ChatInboxTab>((ref) {
  return ChatInboxTab.people;
});

// =======================================================
// ROOMS
// =======================================================
final chatRoomsProvider = StreamProvider<List<ChatRoomModel>>((ref) {
  final service = ref.watch(chatServiceProvider);
  return service.watchRooms();
});

// =======================================================
// PEOPLE
// =======================================================
final chatPeopleProvider = StreamProvider<List<ChatUserPreviewModel>>((ref) {
  final service = ref.watch(chatServiceProvider);
  return service.watchPeople();
});

// =======================================================
// USER PREVIEW BY UID
// =======================================================
final chatUserPreviewProvider =
    StreamProvider.autoDispose.family<ChatUserPreviewModel?, String>((ref, uid) {
  final service = ref.watch(chatServiceProvider);
  return service.watchUserPreview(uid);
});

// =======================================================
// MESSAGES BY OTHER USER ID
// =======================================================
final chatMessagesProvider =
    StreamProvider.autoDispose.family<List<ChatMessageModel>, String>((ref, uid) {
  final service = ref.watch(chatServiceProvider);
  return service.watchMessages(uid);
});