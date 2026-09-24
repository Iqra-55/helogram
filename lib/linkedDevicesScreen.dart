import 'package:flutter/material.dart';

class LinkedDevicesScreen extends StatelessWidget {
  const LinkedDevicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color lightPrimary = const Color(0xFFE0E3E8);
    final Color darkText = const Color(0xFF2D3142);
    // FIXED: Text color - navy blue/black in light theme, white in dark theme
    final Color textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Linked devices',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: textColor, // FIXED
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 60),

            Image.asset(
              isDark 
                  ? 'assets/images/dark.png'
                  : 'assets/images/light.png',
              height: 200,
              width: 400,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  width: 200,
                  color: colorScheme.surface,
                  child: Icon(
                    Icons.link,
                    size: 80,
                    color: lightPrimary,
                  ),
                );
              },
            ),

            const SizedBox(height: 32),

            Text(
              'You can link other devices to this account.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 15,
                color: textColor, // FIXED: Dynamic color instead of hardcoded white
                height: 1.5,
              ),
            ),

            const SizedBox(height: 8),

            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Learn more',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: textColor, // FIXED: Dynamic color instead of hardcoded white
                ),
              ),
            ),

            const SizedBox(height: 24),

            GestureDetector(
              onTap: () {
                // TODO: Open QR scanner
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: lightPrimary,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Text(
                  'Link a device',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: darkText,
                  ),
                ),
              ),
            ),

            const Spacer(),
            const SizedBox(height: 40),

            Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    color: textColor, // FIXED: Dynamic color instead of hardcoded white
                    height: 1.5,
                  ),
                  children: [
                    WidgetSpan(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Icon(Icons.lock_outline, size: 13, color: textColor), // FIXED
                      ),
                    ),
                    const TextSpan(text: 'Your personal messages are '),
                    TextSpan(
                      text: 'end-to-end encrypted',
                      style: TextStyle(
                        color: textColor, // FIXED: Dynamic color
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const TextSpan(text: '\non all your devices.'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
