import 'package:flutter/material.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:installed_apps/app_info.dart';
import '../theme/app_theme.dart';
import '../models/app_model.dart';
import '../services/storage_service.dart';
import '../widgets/timer_picker.dart';

class HomeScreen extends StatefulWidget {
  final Color accent;
  const HomeScreen({super.key, required this.accent});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<BlockedApp>     _blocked     = [];
  List<RecommendedApp> _recommended = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _load();
  }

  Future<void> _load() async {
    final b = await StorageService.loadBlockedApps();
    final r = await StorageService.loadRecommendedApps();
    setState(() { _blocked = b; _recommended = r; });
  }

  Future<void> _addBlockedApp() async {
    final app = await _pickApp(context);
    if (app == null) return;

    await showTimerPicker(
      context: context,
      initialMinutes: 3,
      initialSeconds: 0,
      accent: widget.accent,
      onConfirm: (min, sec) async {
        final newApp = BlockedApp(
          packageName:  app.packageName,
          appName:      app.name,
          timerMinutes: min,
          timerSeconds: sec,
        );
        setState(() => _blocked.add(newApp));
        await StorageService.saveBlockedApps(_blocked);
      },
    );
  }

  Future<void> _addRecommendedApp() async {
    final app = await _pickApp(context);
    if (app == null) return;

    final newApp = RecommendedApp(
      packageName: app.packageName,
      appName:     app.name,
    );
    setState(() => _recommended.add(newApp));
    await StorageService.saveRecommendedApps(_recommended);
  }

  Future<void> _removeBlocked(int index) async {
    setState(() => _blocked.removeAt(index));
    await StorageService.saveBlockedApps(_blocked);
  }

  Future<void> _removeRecommended(int index) async {
    setState(() => _recommended.removeAt(index));
    await StorageService.saveRecommendedApps(_recommended);
  }

  Future<void> _editTimer(int index) async {
    final app = _blocked[index];
    await showTimerPicker(
      context: context,
      initialMinutes: app.timerMinutes,
      initialSeconds: app.timerSeconds,
      accent: widget.accent,
      onConfirm: (min, sec) async {
        setState(() {
          _blocked[index] = app.copyWith(
            timerMinutes: min,
            timerSeconds: sec,
          );
        });
        await StorageService.saveBlockedApps(_blocked);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KioColors.background,
      appBar: AppBar(
        title: RichText(
          text: TextSpan(
            children: [
              const TextSpan(
                text: 'Kio',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: KioColors.textPrimary,
                ),
              ),
              TextSpan(
                text: 'Focus',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w300,
                  color: widget.accent,
                ),
              ),
            ],
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: KioColors.surface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: widget.accent,
                borderRadius: BorderRadius.circular(12),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.white,
              unselectedLabelColor: KioColors.textSecondary,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: 'Barrar'),
                Tab(text: 'Recomendar'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _BlockedTab(
            apps: _blocked,
            accent: widget.accent,
            onRemove: _removeBlocked,
            onEditTimer: _editTimer,
          ),
          _RecommendedTab(
            apps: _recommended,
            accent: widget.accent,
            onRemove: _removeRecommended,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _tabController.index == 0
            ? _addBlockedApp()
            : _addRecommendedApp(),
        backgroundColor: widget.accent,
        elevation: 2,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _BlockedTab extends StatelessWidget {
  final List<BlockedApp> apps;
  final Color accent;
  final Function(int) onRemove;
  final Function(int) onEditTimer;

  const _BlockedTab({
    required this.apps,
    required this.accent,
    required this.onRemove,
    required this.onEditTimer,
  });

  @override
  Widget build(BuildContext context) {
    if (apps.isEmpty) {
      return _EmptyState(
        accent: accent,
        icon: Icons.block_outlined,
        title: 'Nenhum app barrado',
        subtitle: 'Toque em + para adicionar um app\nque você quer controlar.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: apps.length,
      itemBuilder: (_, i) {
        final app = apps[i];
        final timerLabel = '${app.timerMinutes.toString().padLeft(2,'0')}:'
            '${app.timerSeconds.toString().padLeft(2,'0')}';
        return _AppCard(
          appName: app.appName,
          accent: accent,
          trailing: GestureDetector(
            onTap: () => onEditTimer(i),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: accent.withOpacity(0.3)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.timer_outlined, size: 14, color: accent),
                const SizedBox(width: 4),
                Text(timerLabel, style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600, color: accent,
                )),
              ]),
            ),
          ),
          onDelete: () => onRemove(i),
        );
      },
    );
  }
}

class _RecommendedTab extends StatelessWidget {
  final List<RecommendedApp> apps;
  final Color accent;
  final Function(int) onRemove;

  const _RecommendedTab({
    required this.apps,
    required this.accent,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (apps.isEmpty) {
      return _EmptyState(
        accent: accent,
        icon: Icons.recommend_outlined,
        title: 'Nenhuma recomendação',
        subtitle: 'Toque em + para adicionar apps\nque você prefere usar.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: apps.length,
      itemBuilder: (_, i) => _AppCard(
        appName: apps[i].appName,
        accent: accent,
        onDelete: () => onRemove(i),
      ),
    );
  }
}

class _AppCard extends StatelessWidget {
  final String appName;
  final Color accent;
  final Widget? trailing;
  final VoidCallback onDelete;

  const _AppCard({
    required this.appName,
    required this.accent,
    required this.onDelete,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(appName),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red.shade300,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) => onDelete(),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: KioColors.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: const Border.fromBorderSide(
            BorderSide(color: KioColors.divider),
          ),
          boxShadow: const [
            BoxShadow(color: KioColors.shadow, blurRadius: 8, offset: Offset(0,2)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.apps, color: accent, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(appName, style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: KioColors.textPrimary,
              )),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final Color accent;
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyState({
    required this.accent,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: accent.withOpacity(0.4)),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(
            fontSize: 18, fontWeight: FontWeight.w600,
            color: KioColors.textPrimary,
          )),
          const SizedBox(height: 8),
          Text(subtitle, textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14, color: KioColors.textSecondary, height: 1.5,
            )),
        ],
      ),
    );
  }
}

Future<AppInfo?> _pickApp(BuildContext context) async {
  final apps = await InstalledApps.getInstalledApps(true, true);
  apps.sort((a, b) => a.name.compareTo(b.name));

  if (!context.mounted) return null;

  return showModalBottomSheet<AppInfo>(
    context: context,
    backgroundColor: KioColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    isScrollControlled: true,
    builder: (_) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      builder: (_, scrollController) => Column(
        children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 4,
            decoration: BoxDecoration(
              color: KioColors.divider,
              borderRadius: BorderRadius.circular(2),
            )),
          const SizedBox(height: 16),
          const Text('Selecionar app', style: TextStyle(
            fontSize: 17, fontWeight: FontWeight.w600,
            color: KioColors.textPrimary,
          )),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              itemCount: apps.length,
              itemBuilder: (_, i) => ListTile(
                leading: apps[i].icon != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.memory(
                          apps[i].icon!,
                          width: 40, height: 40,
                        ),
                      )
                    : const Icon(Icons.apps),
                title: Text(apps[i].name),
                onTap: () => Navigator.pop(context, apps[i]),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}