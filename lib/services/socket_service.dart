import 'dart:async';
import 'dart:math';

class SocketService {
  static bool isConnected = false;
  static Timer? _typingTimer;
  static Timer? _autoReplyTimer;

  static final StreamController<Map<String, dynamic>> _messageController = 
      StreamController<Map<String, dynamic>>.broadcast();

  static final StreamController<Map<String, dynamic>> _typingController = 
      StreamController<Map<String, dynamic>>.broadcast();

  // ✅ NAYA: Generic event controller for status updates etc.
  static final StreamController<Map<String, dynamic>> _eventController = 
      StreamController<Map<String, dynamic>>.broadcast();

  // ✅ NAYA: Store event listeners
  static final Map<String, List<Function(dynamic)>> _eventListeners = {};

  static void connect() {
    isConnected = true;
    print('✅ Dummy socket connected');
    _startDummyTyping();
  }

  static void disconnect() {
    isConnected = false;
    _typingTimer?.cancel();
    _autoReplyTimer?.cancel();
  }

  static void _startDummyTyping() {
    _typingTimer = Timer.periodic(Duration(seconds: 15), (timer) {
      if (!isConnected) return;

      _typingController.add({
        'userId': 'user_2',
        'isTyping': true,
      });

      Future.delayed(Duration(seconds: 3), () {
        _typingController.add({
          'userId': 'user_2',
          'isTyping': false,
        });
      });
    });
  }

  // ✅ NAYA: Emit method for sending events to server
  static void emit(String event, dynamic data) {
    print('📤 Emit: $event => $data');

    // Dummy implementation: auto-handle read_receipt
    if (event == 'read_receipt') {
      // Simulate server acknowledging read receipt
      Future.delayed(Duration(milliseconds: 500), () {
        _eventController.add({
          'event': 'message_status_update',
          'data': {
            'messageId': data['senderId'],
            'status': 'read',
          },
        });
      });
    }
  }

  // ✅ NAYA: Listen to generic events
  static void on(String event, Function(dynamic) callback) {
    if (!_eventListeners.containsKey(event)) {
      _eventListeners[event] = [];
    }
    _eventListeners[event]!.add(callback);

    // Also listen to the broadcast stream and filter by event
    _eventController.stream.listen((data) {
      if (data['event'] == event) {
        callback(data['data']);
      }
    });
  }

  static void sendMessage(String receiverId, String message) {
    final replies = [
      'Achha! 👍',
      'Mujhe bhi batao',
      'Interesting!',
      'Ok, theek hai',
      'Hahaha 😄',
      'Wah, bohat khoob!',
      'Kya baat hai!',
      'Main busy hoon, baad mein baat karte hain',
    ];

    final random = Random();
    final msgId = 'msg_${DateTime.now().millisecondsSinceEpoch}';

    // ✅ Simulate message status updates: sent -> delivered -> read
    Future.delayed(Duration(seconds: 1), () {
      if (!isConnected) return;
      _eventController.add({
        'event': 'message_status_update',
        'data': {
          'messageId': msgId,
          'status': 'delivered',
        },
      });
    });

    Future.delayed(Duration(seconds: 2 + random.nextInt(4)), () {
      if (!isConnected) return;

      _messageController.add({
        'id': msgId,
        'senderId': receiverId,
        'receiverId': 'user_1',
        'message': replies[random.nextInt(replies.length)],
        'timestamp': DateTime.now().toIso8601String(),
        'isRead': false,
      });

      // Auto mark as read after receiving (simulating other user reading)
      Future.delayed(Duration(seconds: 3), () {
        _eventController.add({
          'event': 'message_status_update',
          'data': {
            'messageId': msgId,
            'status': 'read',
          },
        });
      });
    });
  }

  static void sendTyping(String receiverId, bool isTyping) {}

  static void onReceiveMessage(Function(Map<String, dynamic>) callback) {
    _messageController.stream.listen(callback);
  }

  static void onUserTyping(Function(Map<String, dynamic>) callback) {
    _typingController.stream.listen(callback);
  }

  static void onUserStatus(Function(Map<String, dynamic>) callback) {}

  static void offAll() {
    _eventListeners.clear();
  }
}
