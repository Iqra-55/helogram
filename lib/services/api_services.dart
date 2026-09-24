import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_config.dart';

class ApiService {
  static String? _token;
  static String? _userId;
  static String? _userName;

  static String get token => _token ?? '';
  static String get userId => _userId ?? '';
  static String get userName => _userName ?? '';

  static Future<void> init() async {
    _token = 'dummy_token';
    _userId = 'user_1';
    _userName = 'Test User';
  }

  static Future<Map<String, dynamic>> loginWithPhone(String phone, String name) async {
    await Future.delayed(Duration(seconds: 1));
    
    return {
      'success': true,
      'token': 'dummy_token',
      'user': {
        'id': 'user_1',
        'phone': phone,
        'name': name,
      }
    };
  }

  static Future<List<dynamic>> getUsers() async {
    await Future.delayed(Duration(milliseconds: 500));
    
    return [
      {
        '_id': 'user_2',
        'name': 'iqra hussain',
        'phone': '+92 300 1111111',
        'online': true,
        'lastSeen': DateTime.now().toIso8601String(),
      },
      {
        '_id': 'user_3',
        'name': 'Sara mustafa',
        'phone': '+92 300 2222222',
        'online': false,
        'lastSeen': DateTime.now().subtract(Duration(minutes: 30)).toIso8601String(),
      },
      {
        '_id': 'user_4',
        'name': 'zainab zahra',
        'phone': '+92 300 3333333',
        'online': true,
        'lastSeen': DateTime.now().toIso8601String(),
      },
      {
        '_id': 'user_5',
        'name': 'saba azam',
        'phone': '+92 300 4444444',
        'online': false,
        'lastSeen': DateTime.now().subtract(Duration(hours: 2)).toIso8601String(),
      },
    ];
  }

  static Future<List<dynamic>> getMessages(String otherUserId) async {
    await Future.delayed(Duration(milliseconds: 300));
    
    final now = DateTime.now();
    
    return [
      {
        '_id': 'msg_1',
        'senderId': otherUserId,
        'receiverId': 'user_1',
        'message': 'Assalam-o-Alaikum! Kaise ho?',
        'timestamp': now.subtract(Duration(hours: 2)).toIso8601String(),
        'isRead': true,
      },
      {
        '_id': 'msg_2',
        'senderId': 'user_1',
        'receiverId': otherUserId,
        'message': 'Walaikum Assalam! Main theek hoon.',
        'timestamp': now.subtract(Duration(hours: 1, minutes: 55)).toIso8601String(),
        'isRead': true,
      },
      {
        '_id': 'msg_3',
        'senderId': otherUserId,
        'receiverId': 'user_1',
        'message': 'HeloGram app kaisi lag rahi hai?',
        'timestamp': now.subtract(Duration(hours: 1, minutes: 50)).toIso8601String(),
        'isRead': true,
      },
      {
        '_id': 'msg_4',
        'senderId': 'user_1',
        'receiverId': otherUserId,
        'message': 'Bohat achi! Dark theme WhatsApp jaisi hai.',
        'timestamp': now.subtract(Duration(hours: 1, minutes: 45)).toIso8601String(),
        'isRead': true,
      },
      {
        '_id': 'msg_5',
        'senderId': otherUserId,
        'receiverId': 'user_1',
        'message': 'Wah! Mujhe bhi try karni hai.',
        'timestamp': now.subtract(Duration(minutes: 30)).toIso8601String(),
        'isRead': true,
      },
      {
        '_id': 'msg_6',
        'senderId': 'user_1',
        'receiverId': otherUserId,
        'message': 'Jaldi hi InshaAllah! Testing chal rahi hai.',
        'timestamp': now.subtract(Duration(minutes: 25)).toIso8601String(),
        'isRead': true,
      },
      {
        '_id': 'msg_7',
        'senderId': otherUserId,
        'receiverId': 'user_1',
        'message': 'Best of luck! 🚀',
        'timestamp': now.subtract(Duration(minutes: 20)).toIso8601String(),
        'isRead': false,
      },
    ];
  }
}