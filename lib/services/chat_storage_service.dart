import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ChatStorageService {
  static const String _prefix = 'chat_messages_';

  static Future<void> saveMessages(String chatId, List<Map<String, dynamic>> messages) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = messages.map((msg) => {
      'senderId': msg['senderId'],
      'message': msg['message'],
      'type': msg['type'] ?? 'text',
      'mediaPath': msg['mediaPath'],           // 👈 Image/Video path
      'voicePath': msg['voicePath'],
      'duration': msg['duration'],
      'timestamp': msg['timestamp'],
      'isRead': msg['isRead'] ?? false,
    }).toList();
    
    await prefs.setString('$_prefix$chatId', jsonEncode(jsonList));
  }

  static Future<List<Map<String, dynamic>>> loadMessages(String chatId) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('$_prefix$chatId');
    
    if (data == null) return [];
    
    try {
      final List<dynamic> decoded = jsonDecode(data);
      return decoded.map((item) => Map<String, dynamic>.from(item)).toList();
    } catch (e) {
      print('Load messages error: $e');
      return [];
    }
  }

  static Future<void> clearMessages(String chatId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_prefix$chatId');
  }
}