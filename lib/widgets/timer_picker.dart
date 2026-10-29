import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class TimerPickerSheet extends StatefulWidget {
  final int initialMinutes;
  final int initialSeconds;
  final Function(int minutes, int seconds) onConfirm;
  final Color accent;

  const TimerPickerSheet({
    super.key,
    this.initialMinutes = 3,
    this.initialSeconds = 0,
    required this.onConfirm,
    required this.accent,
  });

  @override
  State<TimerPickerSheet> createState() => _TimerPickerSheetState();
}

class _TimerPickerSheetState extends State<TimerPickerSheet> {
  late int _minutes;
  late int _seconds;
  late FixedExtentScrollController _minController;
  late FixedExtentScrollController _secController;

  @override
  void initState() {
    super.initState();
    _minutes = widget.initialMinutes;
    _seconds = widget.initialSeconds;
    _minController = FixedExtentScrollController(initialItem: _minutes);
    _secController = FixedExtentScrollController(initialItem: _seconds);
  }

  @override
  void dispose() {
    _minController.dispose();
    _secController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: KioColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: KioColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Tempo de espera', style: TextStyle(
            fontSize: 18, fontWeight: FontWeight.w600,
            color: KioColors.textPrimary,
          )),
          const SizedBox(height: 8),
          const Text('Arraste para cima ou para baixo', style: TextStyle(
            fontSize: 13, color: KioColors.textSecondary,
          )),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _Drum(
                controller: _minController,
                count: 60,
                label: 'min',
                accent: widget.accent,
                onChanged: (v) => setState(() => _minutes = v),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(':', style: TextStyle(
                  fontSize: 36, fontWeight: FontWeight.w300,
                  color: widget.accent,
                )),
              ),
              _Drum(
                controller: _secController,
                count: 60,
                label: 'seg',
                accent: widget.accent,
                onChanged: (v) => setState(() => _seconds = v),
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: widget.accent),
              onPressed: () {
                Navigator.pop(context);
                widget.onConfirm(_minutes, _seconds);
              },
              child: const Text('Confirmar'),
            ),
          ),
        ],
      ),
    );
  }
}

class _Drum extends StatelessWidget {
  final FixedExtentScrollController controller;
  final int count;
  final String label;
  final Color accent;
  final Function(int) onChanged;

  const _Drum({
    required this.controller,
    required this.count,
    required this.label,
    required this.accent,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(
          fontSize: 12, color: KioColors.textSecondary,
          letterSpacing: 0.5,
        )),
        const SizedBox(height: 8),
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              height: 52,
              width: 80,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: accent.withOpacity(0.3)),
              ),
            ),
            SizedBox(
              height: 160,
              width: 80,
              child: ListWheelScrollView.useDelegate(
                controller: controller,
                itemExtent: 52,
                perspective: 0.003,
                diameterRatio: 2.5,
                physics: const FixedExtentScrollPhysics(),
                onSelectedItemChanged: onChanged,
                childDelegate: ListWheelChildBuilderDelegate(
                  builder: (context, index) {
                    if (index < 0 || index >= count) return null;
                    return Center(
                      child: Text(
                        index.toString().padLeft(2, '0'),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w300,
                          color: KioColors.textPrimary,
                        ),
                      ),
                    );
                  },
                  childCount: count,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

Future<void> showTimerPicker({
  required BuildContext context,
  required int initialMinutes,
  required int initialSeconds,
  required Color accent,
  required Function(int, int) onConfirm,
}) async {
  await showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => TimerPickerSheet(
      initialMinutes: initialMinutes,
      initialSeconds: initialSeconds,
      accent: accent,
      onConfirm: onConfirm,
    ),
  );
}