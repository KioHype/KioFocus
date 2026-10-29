import 'dart:async';
import 'package:flutter/material.dart';
import 'package:installed_apps/installed_apps.dart';
import '../theme/app_theme.dart';
import '../models/app_model.dart';
import '../services/storage_service.dart';
import '../services/phrases.dart';

class BlockerScreen extends StatefulWidget {
  final String packageName;
  final String appName;
  final int totalSeconds;
  final int endTimeMs; // momento em que o timer termina (milissegundos)
  final Color accent;

  const BlockerScreen({
    super.key,
    required this.packageName,
    required this.appName,
    required this.totalSeconds,
    required this.endTimeMs,
    required this.accent,
  });

  @override
  State<BlockerScreen> createState() => _BlockerScreenState();
}

class _BlockerScreenState extends State<BlockerScreen>
    with WidgetsBindingObserver {
  int _remainingSeconds = 0;
  Timer? _timer;
  bool _done = false;

  int _phraseIndex = 0;
  Timer? _phraseTimer;
  bool _phraseVisible = true;

  List<RecommendedApp> _recommended = [];

  int _calcRemaining() {
    final ms = widget.endTimeMs - DateTime.now().millisecondsSinceEpoch;
    return ms <= 0 ? 0 : (ms / 1000).ceil();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tick();
    _startTimer();
    _startPhraseRotation();
    _loadRecommendations();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _tick();
      _startTimer();
    }
  }

  void _tick() {
    final r = _calcRemaining();
    setState(() {
      _remainingSeconds = r;
      _done = r == 0;
    });
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _tick();
      if (_done) _timer?.cancel();
    });
  }

  void _startPhraseRotation() {
    _phraseTimer = Timer.periodic(const Duration(seconds: 20), (_) {
      setState(() => _phraseVisible = false);
      Future.delayed(const Duration(milliseconds: 600), () {
        if (!mounted) return;
        setState(() {
          _phraseIndex = (_phraseIndex + 1) % motivationalPhrases.length;
          _phraseVisible = true;
        });
      });
    });
  }

  Future<void> _loadRecommendations() async {
    final r = await StorageService.loadRecommendedApps();
    if (mounted) setState(() => _recommended = r);
  }

  void _openApp(String packageName) {
    InstalledApps.startApp(packageName);
  }

  void _openBlockedApp() {
    InstalledApps.startApp(widget.packageName);
    Navigator.pop(context);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _phraseTimer?.cancel();
    super.dispose();
  }

  String get _timeLabel {
    final m = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  double get _progress => widget.totalSeconds > 0
      ? (1 - (_remainingSeconds / widget.totalSeconds)).clamp(0.0, 1.0)
      : 1.0;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: KioColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 48),
                Text(
                  widget.appName,
                  style: const TextStyle(
                    fontSize: 15,
                    color: KioColors.textSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Respira um momento',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: KioColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: 180,
                  height: 180,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox.expand(
                        child: CircularProgressIndicator(
                          value: _progress,
                          strokeWidth: 6,
                          backgroundColor: KioColors.divider,
                          valueColor: AlwaysStoppedAnimation(widget.accent),
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: _done
                            ? Icon(Icons.check_circle_outline,
                                size: 56,
                                color: widget.accent,
                                key: const ValueKey('done'))
                            : Text(
                                _timeLabel,
                                key: const ValueKey('timer'),
                                style: const TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.w200,
                                  color: KioColors.textPrimary,
                                  letterSpacing: -1,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 36),
                SizedBox(
                  height: 60,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 600),
                    opacity: _phraseVisible ? 1.0 : 0.0,
                    child: Text(
                      motivationalPhrases[_phraseIndex],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        color: KioColors.textSecondary,
                        height: 1.5,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                if (_recommended.isNotEmpty) ...[
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Enquanto isso...',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: KioColors.textSecondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _recommended.length,
                      itemBuilder: (_, i) => _RecommendedChip(
                        app: _recommended[i],
                        accent: widget.accent,
                        onTap: () => _openApp(_recommended[i].packageName),
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: _done
                      ? SizedBox(
                          key: const ValueKey('open'),
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: widget.accent,
                            ),
                            icon: const Icon(Icons.open_in_new, size: 18),
                            label: Text('Abrir ${widget.appName}'),
                            onPressed: _openBlockedApp,
                          ),
                        )
                      : SizedBox(
                          key: const ValueKey('waiting'),
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: KioColors.surface,
                              foregroundColor: KioColors.textHint,
                              elevation: 0,
                            ),
                            onPressed: null,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.lock_outline,
                                    size: 16, color: KioColors.textHint),
                                const SizedBox(width: 8),
                                const Text('Aguarde o timer...'),
                              ],
                            ),
                          ),
                        ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RecommendedChip extends StatelessWidget {
  final RecommendedApp app;
  final Color accent;
  final VoidCallback onTap;

  const _RecommendedChip({
    required this.app,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 70,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: accent.withOpacity(0.3)),
              ),
              child: Icon(Icons.apps, color: accent, size: 26),
            ),
            const SizedBox(height: 4),
            Text(
              app.appName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                color: KioColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}