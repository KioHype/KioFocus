import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'theme/app_theme.dart';
import 'services/storage_service.dart';
import 'services/accessibility_channel.dart';
import 'screens/tutorial_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  final tutorialDone = await StorageService.isTutorialDone();
  final savedAccent  = await loadAccentColor();

  initAccessibilityChannel(savedAccent);

  runApp(KioFocusApp(
    tutorialDone: tutorialDone,
    initialAccent: savedAccent,
  ));
}

class KioFocusApp extends StatefulWidget {
  final bool tutorialDone;
  final AccentColor initialAccent;

  const KioFocusApp({
    super.key,
    required this.tutorialDone,
    required this.initialAccent,
  });

  @override
  State<KioFocusApp> createState() => _KioFocusAppState();
}

class _KioFocusAppState extends State<KioFocusApp> {
  late AccentColor _accentColor;
  late bool _tutorialDone;

  @override
  void initState() {
    super.initState();
    _accentColor  = widget.initialAccent;
    _tutorialDone = widget.tutorialDone;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Permission.notification.request();
      checkPendingBlock(_accentColor);
    });
  }

  void _onTutorialFinish(AccentColor color) {
    setState(() {
      _accentColor  = color;
      _tutorialDone = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final accent = accentColors[_accentColor]!;

    return MaterialApp(
      title: 'KioFocus',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(accent),
      navigatorKey: navigatorKey,
      home: _tutorialDone
          ? HomeScreen(accent: accent)
          : TutorialScreen(onFinish: _onTutorialFinish),
    );
  }
}