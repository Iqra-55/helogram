import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme.dart';
import 'apptheme.dart';
import 'mainscreen.dart';
import 'updatescreen.dart';
import 'callScreen.dart';
import 'navButton.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'HeloGram',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.followSystem 
              ? ThemeMode.system
              : (themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light),
          builder: (context, child) {
            return Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: child,
            );
          },
          home: const SystemThemeWrapper(),
        );
      },
    );
  }
}

class SystemThemeWrapper extends StatelessWidget {
  const SystemThemeWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final brightness = MediaQuery.platformBrightnessOf(context);
    themeProvider.setSystemTheme(brightness);

    return const BaseScreen();
  }
}

final ValueNotifier<bool> searchNotifier = ValueNotifier<bool>(false);
final ValueNotifier<bool> offlineModeNotifier = ValueNotifier<bool>(false);

class BaseScreen extends StatefulWidget {
  const BaseScreen({super.key});

  @override
  State<BaseScreen> createState() => _BaseScreenState();
}

class _BaseScreenState extends State<BaseScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _screens = [
    const ChatScreen(),
    const UpdatesScreen(),
    const CallsScreen(),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onNavTap(int index) {
    _pageController.jumpToPage(index);
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return WillPopScope(
      onWillPop: () async {
        if (searchNotifier.value) {
          searchNotifier.value = false;
          return false;
        }

        if (_currentIndex != 0) {
          _onNavTap(0);
          return false;
        }

        return true;
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: PageView(
          controller: _pageController,
          onPageChanged: _onPageChanged,
          children: _screens,
        ),
        bottomNavigationBar: Container(
          color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
          child: SafeArea(
            top: false,
            child: Container(
              height: 52,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CustomNavButton(
                    icon: Icons.chat,
                    label: 'Chat',
                    isSelected: _currentIndex == 0,
                    onTap: () => _onNavTap(0),
                  ),
                  CustomNavButton(
                    icon: Icons.update,
                    label: 'Updates',
                    isSelected: _currentIndex == 1,
                    onTap: () => _onNavTap(1),
                  ),
                  CustomNavButton(
                    icon: Icons.call,
                    label: 'Calls',
                    isSelected: _currentIndex == 2,
                    onTap: () => _onNavTap(2),
                  ),
                  ValueListenableBuilder<bool>(
                    valueListenable: offlineModeNotifier,
                    builder: (context, isOffline, child) {
                      return GestureDetector(
                        onTap: () {
                          offlineModeNotifier.value = !isOffline;
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                          decoration: BoxDecoration(
                            color: isOffline 
                                ? colorScheme.onSurface.withOpacity(0.15)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isOffline ? Icons.wifi_off_rounded : Icons.wifi_rounded,
                                size: 26,
                                color: isOffline 
                                    ? colorScheme.onSurface
                                    : colorScheme.onSurface
                              ),
                              const SizedBox(height: 1),
                              Text(
                                isOffline ? 'Offline' : 'Online',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}