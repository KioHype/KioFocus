import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/storage_service.dart';

class TutorialScreen extends StatefulWidget {
  final Function(AccentColor) onFinish;
  const TutorialScreen({super.key, required this.onFinish});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  final _controller = PageController();
  int _page = 0;
  AccentColor _selectedColor = AccentColor.blue;

  void _next() {
    if (_page < 2) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _finish();
    }
  }

  void _finish() async {
    await saveAccentColor(_selectedColor);
    await StorageService.markTutorialDone();
    widget.onFinish(_selectedColor);
  }

  @override
  Widget build(BuildContext context) {
    final accent = accentColors[_selectedColor]!;

    return Scaffold(
      backgroundColor: KioColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(3, (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.only(right: 6),
                      width: _page == i ? 20 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _page == i ? accent : KioColors.divider,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    )),
                  ),
                  TextButton(
                    onPressed: _finish,
                    child: Text(
                      'Pular',
                      style: TextStyle(
                        color: KioColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (i) => setState(() => _page = i),
                children: [
                  _PageHowItWorks(accent: accent),
                  _PageHowToConfig(accent: accent),
                  _PageChooseColor(
                    selected: _selectedColor,
                    onSelect: (c) => setState(() => _selectedColor = c),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: accent),
                  onPressed: _next,
                  child: Text(_page == 2 ? 'Começar' : 'Próximo'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PageHowItWorks extends StatelessWidget {
  final Color accent;
  const _PageHowItWorks({required this.accent});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.shield_outlined, size: 56, color: accent),
          const SizedBox(height: 28),
          const Text('Como funciona', style: TextStyle(
            fontSize: 26, fontWeight: FontWeight.w700,
            color: KioColors.textPrimary,
          )),
          const SizedBox(height: 16),
          _InfoItem(accent: accent, text:
            'Quando você tentar abrir um app bloqueado, o KioFocus aparece automaticamente.'),
          _InfoItem(accent: accent, text:
            'Um timer começa a contar. Você precisa esperar antes de abrir o app.'),
          _InfoItem(accent: accent, text:
            'Durante a espera, o KioFocus sugere alternativas mais saudáveis para você.'),
          _InfoItem(accent: accent, text:
            'Quando o timer acabar, o botão de abrir fica disponível.'),
        ],
      ),
    );
  }
}

class _PageHowToConfig extends StatelessWidget {
  final Color accent;
  const _PageHowToConfig({required this.accent});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.tune_outlined, size: 56, color: accent),
          const SizedBox(height: 28),
          const Text('Como configurar', style: TextStyle(
            fontSize: 26, fontWeight: FontWeight.w700,
            color: KioColors.textPrimary,
          )),
          const SizedBox(height: 16),
          _InfoItem(accent: accent, text:
            'Na aba "Barrar", toque em + para adicionar um app que quer controlar.'),
          _InfoItem(accent: accent, text:
            'Defina o tempo de espera rolando os minutos e segundos como um tambor.'),
          _InfoItem(accent: accent, text:
            'Na aba "Recomendar", adicione apps que prefere usar no lugar dos bloqueados.'),
          _InfoItem(accent: accent, text:
            'Ative o serviço de acessibilidade quando solicitado.'),
        ],
      ),
    );
  }
}

class _PageChooseColor extends StatelessWidget {
  final AccentColor selected;
  final Function(AccentColor) onSelect;
  const _PageChooseColor({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.palette_outlined, size: 56,
              color: accentColors[selected]),
          const SizedBox(height: 28),
          const Text('Escolha sua cor', style: TextStyle(
            fontSize: 26, fontWeight: FontWeight.w700,
            color: KioColors.textPrimary,
          )),
          const SizedBox(height: 8),
          const Text(
            'Você pode mudar isso depois nas configurações.',
            style: TextStyle(color: KioColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: AccentColor.values.map((c) {
              final isSelected = c == selected;
              return GestureDetector(
                onTap: () => onSelect(c),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: accentColors[c],
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? KioColors.textPrimary
                          : Colors.transparent,
                      width: 3,
                    ),
                    boxShadow: isSelected ? [
                      BoxShadow(
                        color: accentColors[c]!.withOpacity(0.4),
                        blurRadius: 12,
                        spreadRadius: 2,
                      )
                    ] : [],
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 28)
                      : null,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(
              accentNames[selected]!,
              key: ValueKey(selected),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: accentColors[selected],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final Color accent;
  final String text;
  const _InfoItem({required this.accent, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6, right: 12),
            width: 8, height: 8,
            decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
          ),
          Expanded(
            child: Text(text, style: const TextStyle(
              fontSize: 15,
              color: KioColors.textPrimary,
              height: 1.5,
            )),
          ),
        ],
      ),
    );
  }
}