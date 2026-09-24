import 'package:flutter/material.dart';

class MessageStatus {
  static const String sending = 'sending';
  static const String sent = 'sent';
  static const String delivered = 'delivered';
  static const String read = 'read';
}

class DeliveryTicks extends StatelessWidget {
  final String? status;
  final double size;
  final bool isMe;

  const DeliveryTicks({
    Key? key,
    this.status,
    this.size = 14,
    required this.isMe,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!isMe) return const SizedBox.shrink();

    final isRead = status == MessageStatus.read;
    final isDelivered = status == MessageStatus.delivered || isRead;
    final color = isRead ? const Color(0xFF53BDEB) : Colors.grey.shade500;

    if (status == MessageStatus.sending || status == null) {
      return SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          strokeWidth: 1.5,
          color: Colors.grey.shade400,
        ),
      );
    }

    return SizedBox(
      width: isDelivered ? size + size * 0.35 : size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.done, size: size, color: color),
          if (isDelivered)
            Positioned(
              left: size * 0.22,
              child: Icon(Icons.done, size: size, color: color),
            ),
        ],
      ),
    );
  }
}