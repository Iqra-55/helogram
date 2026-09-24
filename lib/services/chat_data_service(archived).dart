import 'package:flutter/material.dart';

class ChatDataService {
  static final List<Map<String, dynamic>> archivedUsers = [];
  static final Set<String> mutedUserIds = {};
  static final Map<String, List<dynamic>> _messages = {};
  static final List<Map<String, dynamic>> _restoredUsers = [];

  static void clearMessages(String userId) {
    _messages.remove(userId);
  }

  static List<dynamic> getMessages(String userId) {
    return _messages[userId] ?? [];
  }

  static void addMessage(String userId, dynamic message) {
    _messages.putIfAbsent(userId, () => []).add(message);
  }

  static void archiveUser(Map<String, dynamic> user) {
    archivedUsers.add(user);
  }

  static void restoreUser(Map<String, dynamic> user) {
    _restoredUsers.add(user);
    archivedUsers.removeWhere((u) => (u['_id'] ?? '') == (user['_id'] ?? ''));
  }

  static List<Map<String, dynamic>> pullRestoredUsers() {
    final list = [..._restoredUsers];
    _restoredUsers.clear();
    return list;
  }
}
