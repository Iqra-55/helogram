import 'package:flutter/material.dart';
import '../apptheme.dart';

class DisappearingMessagesScreen extends StatefulWidget {
  final int? initialDays; // null = Off
  
  const DisappearingMessagesScreen({
    Key? key, 
    this.initialDays,
  }) : super(key: key);

  @override
  State<DisappearingMessagesScreen> createState() => _DisappearingMessagesScreenState();
}

class _DisappearingMessagesScreenState extends State<DisappearingMessagesScreen> {
  bool _isEnabled = false;
  double _selectedDays = 7;

  final List<int> _durationOptions = [1, 3, 7, 14, 30, 60, 90];

  @override
  void initState() {
    super.initState();
    if (widget.initialDays != null) {
      _isEnabled = true;
      _selectedDays = widget.initialDays!.toDouble();
    }
  }

  void _setDuration(int days) {
    if (!_isEnabled) return;
    setState(() => _selectedDays = days.toDouble());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? AppTheme.darkBackground : AppTheme.lightBackground;
    final textPrimary = isDark ? AppTheme.darkLightText : AppTheme.lightDarkText;
    final textSecondary = isDark ? AppTheme.darkNavInactive : AppTheme.lightNavInactive;
    final accentColor = isDark ? AppTheme.darkNavActive : AppTheme.lightNavActive;
    final buttonBg = isDark ? AppTheme.darkFabBg : AppTheme.lightFabBg;
    final buttonText = isDark ? AppTheme.darkDarkText : AppTheme.lightLightText;
    final dividerColor = isDark
        ? Colors.white.withOpacity(0.06)
        : Colors.black.withOpacity(0.06);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: isDark ? AppTheme.darkAppBarBg : AppTheme.lightAppBarBg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Disappearing messages',
          style: TextStyle(
            color: textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
              child: Text(
                'Disappearing messages',
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'All new messages in this chat will disappear after the selected duration.',
                style: TextStyle(
                  color: textSecondary,
                  fontSize: 13,
                  fontFamily: 'Poppins',
                  height: 1.4,
                ),
              ),
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Enable disappearing messages',
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                  Switch(
                    value: _isEnabled,
                    onChanged: (value) => setState(() => _isEnabled = value),
                    activeColor: isDark ? AppTheme.darkLightText : Colors.white,
                    activeTrackColor: isDark 
                        ? AppTheme.darkNavActive.withOpacity(0.6) 
                        : AppTheme.lightNavActive.withOpacity(0.6),
                    inactiveThumbColor: Colors.white,
                    inactiveTrackColor: isDark 
                        ? Colors.white.withOpacity(0.2) 
                        : Colors.black.withOpacity(0.2),
                  ),
                ],
              ),
            ),

            Divider(color: dividerColor, height: 24, indent: 20, endIndent: 20),

            Center(
              child: AnimatedOpacity(
                opacity: _isEnabled ? 1.0 : 0.3,
                duration: const Duration(milliseconds: 200),
                child: Column(
                  children: [
                    Text(
                      '${_selectedDays.toInt()}',
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 72,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Poppins',
                        height: 1,
                      ),
                    ),
                    Text(
                      'days',
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: AnimatedOpacity(
                opacity: _isEnabled ? 1.0 : 0.3,
                duration: const Duration(milliseconds: 200),
                child: Column(
                  children: [
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: accentColor,
                        inactiveTrackColor: isDark
                            ? Colors.white.withOpacity(0.1)
                            : Colors.black.withOpacity(0.1),
                        thumbColor: Colors.white,
                        overlayColor: accentColor.withOpacity(0.1),
                        trackHeight: 4,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                        overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
                      ),
                      child: Slider(
                        value: _selectedDays,
                        min: 1,
                        max: 90,
                        divisions: 89,
                        onChanged: _isEnabled
                            ? (value) => setState(() => _selectedDays = value)
                            : null,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '1 day',
                          style: TextStyle(
                            color: textSecondary,
                            fontSize: 12,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        Text(
                          '90 days',
                          style: TextStyle(
                            color: textSecondary,
                            fontSize: 12,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AnimatedOpacity(
                opacity: _isEnabled ? 1.0 : 0.3,
                duration: const Duration(milliseconds: 200),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _durationOptions.map((days) {
                    final isSelected = _selectedDays.toInt() == days;
                    return GestureDetector(
                      onTap: () => _setDuration(days),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? textPrimary.withOpacity(0.1)
                              : Colors.transparent,
                          border: Border.all(
                            color: isSelected
                                ? textPrimary
                                : (isDark
                                    ? Colors.white.withOpacity(0.3)
                                    : Colors.black.withOpacity(0.2)),
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$days ${days == 1 ? 'day' : 'days'}',
                          style: TextStyle(
                            color: isSelected ? textPrimary : textSecondary,
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 40),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(
                    context,
                    {'days': _isEnabled ? _selectedDays.toInt() : null},
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonBg,
                    foregroundColor: buttonText,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}