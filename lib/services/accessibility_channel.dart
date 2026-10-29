import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../screens/blocker_screen.dart';
import '../theme/app_theme.dart';

const _channel = MethodChannel('com.kiohype.kiofocus/accessibility');
final navigatorKey = GlobalKey<NavigatorState>();

void initAccessibilityChannel(AccentColor accentColor) {
  _channel.setMethodCallHandler((call) async {
    if (call.method == 'blockApp') {
      _showBlocker(
        Map<String, dynamic>.from(call.arguments as Map),
        accentColors[accentColor]!,
      );
    }
  });
}

// Chamado quando o app abre: pega um bloqueio que chegou antes do Flutter ficar pronto
Future<void> checkPendingBlock(AccentColor accentColor) async {
  try {
    final res = await _channel.invokeMethod('getPending');
    if (res != null) {
      _showBlocker(
        Map<String, dynamic>.from(res as Map),
        accentColors[accentColor]!,
      );
    }
  } catch (_) {}
}

void _showBlocker(Map<String, dynamic> args, Color accent, [int attempt = 0]) {
  final nav = navigatorKey.currentState;
  if (nav == null) {
    if (attempt < 10) {
      Future.delayed(const Duration(milliseconds: 200),
          () => _showBlocker(args, accent, attempt + 1));
    }
    return;
  }

  nav.popUntil((route) => route.isFirst);
  nav.push(
    PageRouteBuilder(
      pageBuilder: (_, __, ___) => BlockerScreen(
        packageName: args['packageName'] as String,
        appName: args['appName'] as String,
        totalSeconds: (args['totalSeconds'] as num).toInt(),
        endTimeMs: (args['endTimeMs'] as num).toInt(),
        accent: accent,
      ),
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 200),
    ),
  );
}