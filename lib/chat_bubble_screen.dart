import 'package:flutter/material.dart';
import 'dart:ui';
import 'apptheme.dart';
import '../services/chat_theme_service.dart';

class ChatBubbleScreen extends StatefulWidget {
  final Color initialColor;
  final Color defaultColor;
  final String chatId;
  final bool isReceiver;

  const ChatBubbleScreen({
    Key? super.key,
    required this.initialColor,
    required this.defaultColor,
    required this.chatId,
    this.isReceiver = false,
  });

  @override
  State<ChatBubbleScreen> createState() => _ChatBubbleScreenState();
}

class _ChatBubbleScreenState extends State<ChatBubbleScreen> {
  late Color _selectedColor;
  late List<Color> _bubbleColors;

  final List<Color> _baseColors = [
    Color(0xFF2E8B57), Color.fromARGB(255, 19, 49, 21), Color(0xFF4CAF50), Color(0xFF66BB6A),
    Color(0xFF1565C0), Color(0xFF0D47A1), Color(0xFF1976D2), Color(0xFF0277BD),
    Color(0xFF5E35B1), Color(0xFF4527A0), Color(0xFF7E57C2), Color(0xFF3949AB),
    Color(0xFF00838F), Color(0xFF006064), Color(0xFF0097A7), Color(0xFF26A69A),
    Color(0xFFC62828), Color(0xFFB71C1C), Color(0xFFD32F2F), Color(0xFFAD1457),
    Color(0xFFD84315), Color(0xFFBF360C), Color(0xFF795548), Color(0xFF5D4037),
    Color(0xFFF9A825), Color(0xFFF57F17), Color(0xFFFFB300), Color(0xFFFF8F00),
    Color(0xFF616161), Color(0xFF424242), Color(0xFF37474F), Color(0xFF263238),
    Color(0xFF8E24AA), Color(0xFF6A1B9A), Color(0xFFEC407A), Color(0xFFC2185B),
    Colors.white,
    Colors.black,
  ];

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.initialColor;
    _bubbleColors = [
      widget.defaultColor,
      ..._baseColors.where((c) => c.value != widget.defaultColor.value),
    ];
  }

  void _selectColor(Color color) {
    setState(() => _selectedColor = color);
  }

  void _resetToDefault() {
    setState(() => _selectedColor = widget.defaultColor);
  }

  void _showResetMenu(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay = Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    showMenu(
      context: context,
      position: position,
      color: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      items: [
        PopupMenuItem<String>(
          value: 'reset',
          padding: EdgeInsets.zero,
          height: 0,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                width: 180,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1A1A1A).withOpacity(0.95)
                      : const Color(0xFFFFFFFF).withOpacity(0.95),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withOpacity(0.06)
                        : Colors.black.withOpacity(0.06),
                    width: 0.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withOpacity(0.4)
                          : Colors.black.withOpacity(0.08),
                      blurRadius: 20,
                      spreadRadius: 2,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      _resetToDefault();
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.restart_alt_rounded,
                            size: 18,
                            color: isDark ? Colors.white60 : Colors.black54,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Reset to Default',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Poppins',
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ✅ FIX: PopScope se system back button bhi color return karega
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppTheme.darkBackground : AppTheme.lightBackground;
    final textPrimary = isDark ? AppTheme.darkLightText : AppTheme.lightDarkText;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        // Jab bhi screen pop ho, selected color return karo
        if (didPop && result == null) {
          Navigator.of(context).pop(_selectedColor);
        }
      },
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: isDark ? AppTheme.darkAppBarBg : AppTheme.lightAppBarBg,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: textPrimary),
            onPressed: () => Navigator.pop(context, _selectedColor),
          ),
          title: Text(
            widget.isReceiver ? 'Their bubble' : 'My bubble',
            style: TextStyle(
              color: textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
            ),
          ),
          centerTitle: false,
          actions: [
            Builder(
              builder: (context) => IconButton(
                icon: Icon(Icons.more_vert, color: textPrimary),
                onPressed: () => _showResetMenu(context),
              ),
            ),
          ],
        ),
        body: GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 16,
            crossAxisSpacing: 12,
            childAspectRatio: 1,
          ),
          itemCount: _bubbleColors.length,
          itemBuilder: (context, index) {
            final color = _bubbleColors[index];
            final isSelected = _selectedColor.value == color.value;

            return GestureDetector(
              onTap: () => _selectColor(color),
              child: Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 52,
                  height: 52,
                  curve: Curves.easeOut,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: isSelected
                        ? Border.all(
                            color: color == Colors.white ? Colors.grey : Colors.white,
                            width: 3,
                          )
                        : (color == Colors.white
                            ? Border.all(color: Colors.grey.withOpacity(0.3), width: 1)
                            : null),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: color == Colors.white
                                  ? Colors.grey.withOpacity(0.3)
                                  : color.withOpacity(0.5),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  child: isSelected
                      ? Center(
                          child: Icon(
                            Icons.check,
                            color: color == Colors.white || color.computeLuminance() > 0.5
                                ? Colors.black
                                : Colors.white,
                            size: 24,
                          ),
                        )
                      : null,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}