import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const PlantWaterReminderApp());
}

const kSkyLight = Color(0xFFE3F6FF);
const kSkyMid = Color(0xFF4FC3F7);
const kSkyDeep = Color(0xFF0288D1);
const kInk = Color(0xFF0D2436);
const kAccentGreen = Color(0xFF43A047);
const kAccentOrange = Color(0xFFFF7A45);

class ThemeController extends ValueNotifier<ThemeMode> {
  ThemeController() : super(ThemeMode.light);
  void toggle() =>
      value = value == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
}

final themeController = ThemeController();

class PlantWaterReminderApp extends StatelessWidget {
  const PlantWaterReminderApp({super.key});

  ThemeData _theme(Brightness b) {
    final scheme = ColorScheme.fromSeed(seedColor: kSkyMid, brightness: b);
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      brightness: b,
      scaffoldBackgroundColor: b == Brightness.light
          ? kSkyLight
          : const Color(0xFF071824),
      cardColor: b == Brightness.light ? Colors.white : const Color(0xFF102C3B),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: Colors.white,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor:
            (b == Brightness.light ? Colors.white : const Color(0xFF102C3B))
                .withValues(alpha: 0.96),
        indicatorColor: kSkyMid.withValues(alpha: 0.18),
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      textTheme: ThemeData(brightness: b).textTheme.apply(
        bodyColor: b == Brightness.light ? kInk : Colors.white,
        displayColor: b == Brightness.light ? kInk : Colors.white,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeController,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'Plant Water Reminder',
          debugShowCheckedModeBanner: false,
          themeMode: mode,
          theme: _theme(Brightness.light),
          darkTheme: _theme(Brightness.dark),
          home: const SplashScreen(),
        );
      },
    );
  }
}

class AnimatedGradientBackground extends StatefulWidget {
  final Widget child;
  const AnimatedGradientBackground({super.key, required this.child});

  @override
  State<AnimatedGradientBackground> createState() =>
      _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: dark
                  ? [const Color(0xFF071824), const Color(0xFF0B2436)]
                  : [kSkyLight, Colors.white],
            ),
          ),
        ),
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final t = _controller.value;
            return Align(
              alignment: Alignment(-0.8 + 1.6 * t, -1.1 + 0.3 * sin(t * pi)),
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      kSkyMid.withValues(alpha: 0.28),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        widget.child,
      ],
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _fade;
  late final Animation<double> _rotate;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _scale = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _fade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.6, curve: Curves.easeIn),
    );
    _rotate = Tween<double>(
      begin: -0.35,
      end: 0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
    Future.delayed(const Duration(milliseconds: 2100), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (_, anim, _) => const HomeShell(),
          transitionsBuilder: (_, anim, _, child) => FadeTransition(
            opacity: anim,
            child: ScaleTransition(
              scale: Tween(begin: 0.97, end: 1.0).animate(anim),
              child: child,
            ),
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedGradientBackground(
        child: Center(
          child: FadeTransition(
            opacity: _fade,
            child: ScaleTransition(
              scale: _scale,
              child: RotationTransition(
                turns: _rotate,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(26),
                      decoration: BoxDecoration(
                        color: kSkyDeep.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: kSkyMid.withValues(alpha: 0.25),
                            blurRadius: 30,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.eco_rounded,
                        size: 72,
                        color: kSkyDeep,
                      ),
                    ),
                    const SizedBox(height: 22),
                    Text(
                      'Plant Water Reminder',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w700,
                        color: kInk.withValues(alpha: 0.85),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Simple. Clean. Green.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PlantModel {
  final String id;
  String name;
  String species;
  int intervalDays;
  DateTime lastWatered;
  IconData icon;
  Color color;
  String sunlight;

  PlantModel({
    required this.id,
    required this.name,
    required this.species,
    required this.intervalDays,
    required this.lastWatered,
    required this.icon,
    required this.color,
    this.sunlight = 'Medium',
  });

  DateTime get nextDate => lastWatered.add(Duration(days: intervalDays));

  int get daysLeft {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final next = DateTime(nextDate.year, nextDate.month, nextDate.day);
    return next.difference(today).inDays;
  }

  bool get isDue => daysLeft <= 0;

  double get progress {
    final elapsedHours = DateTime.now().difference(lastWatered).inHours;
    final totalHours = intervalDays * 24;
    if (totalHours <= 0) return 1;
    return (elapsedHours / totalHours).clamp(0.0, 1.3);
  }
}

class PlantStore extends ChangeNotifier {
  final List<PlantModel> _plants = [
    PlantModel(
      id: '1',
      name: 'Monstera',
      species: 'Monstera Deliciosa',
      intervalDays: 7,
      lastWatered: DateTime.now().subtract(const Duration(days: 5)),
      icon: Icons.eco_rounded,
      color: kAccentGreen,
      sunlight: 'Medium',
    ),
    PlantModel(
      id: '2',
      name: 'Echeveria',
      species: 'Succulent',
      intervalDays: 14,
      lastWatered: DateTime.now().subtract(const Duration(days: 15)),
      icon: Icons.grass_rounded,
      color: kAccentOrange,
      sunlight: 'High',
    ),
    PlantModel(
      id: '3',
      name: 'Boston Fern',
      species: 'Nephrolepis exaltata',
      intervalDays: 3,
      lastWatered: DateTime.now().subtract(const Duration(days: 1)),
      icon: Icons.local_florist_rounded,
      color: kSkyDeep,
      sunlight: 'Low',
    ),
  ];

  final List<DateTime> _history = [];

  List<PlantModel> get plants => List.unmodifiable(_plants);
  List<DateTime> get history => List.unmodifiable(_history);

  void addPlant(PlantModel plant) {
    _plants.add(plant);
    notifyListeners();
  }

  void removePlant(String id) {
    _plants.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  void waterPlant(String id) {
    final plant = _plants.firstWhere((p) => p.id == id);
    plant.lastWatered = DateTime.now();
    _history.add(DateTime.now());
    notifyListeners();
  }

  int get total => _plants.length;
  int get dueCount => _plants.where((p) => p.isDue).length;
  int get loggedCount => _history.length;

  double get careScore {
    if (_plants.isEmpty) return 0;
    final healthy = _plants.where((p) => !p.isDue).length;
    return (healthy / _plants.length) * 100;
  }

  Map<String, int> last7Days() {
    final map = <String, int>{};
    final now = DateTime.now();
    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final key = '${day.day}/${day.month}';
      map[key] = _history
          .where(
            (d) =>
                d.year == day.year && d.month == day.month && d.day == day.day,
          )
          .length;
    }
    return map;
  }
}

final plantStore = PlantStore();

class FadeSlideIn extends StatefulWidget {
  final Widget child;
  final int index;
  const FadeSlideIn({super.key, required this.child, this.index = 0});
  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    Future.delayed(Duration(milliseconds: 50 * widget.index), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

class AnimatedCounter extends StatelessWidget {
  final double value;
  final int decimals;
  final String suffix;
  final TextStyle? style;
  const AnimatedCounter({
    super.key,
    required this.value,
    this.decimals = 0,
    this.suffix = '',
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, val, _) =>
          Text('${val.toStringAsFixed(decimals)}$suffix', style: style),
    );
  }
}

class RingProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;
  RingProgressPainter({
    required this.progress,
    required this.color,
    this.strokeWidth = 6,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - strokeWidth) / 2;
    final bgPaint = Paint()
      ..color = color.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    final fgPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);
    final sweep = 2 * pi * progress.clamp(0.0, 1.0);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweep,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(covariant RingProgressPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}

class AnimatedRing extends StatelessWidget {
  final double progress;
  final Color color;
  final double size;
  final double strokeWidth;
  final Widget? child;
  const AnimatedRing({
    super.key,
    required this.progress,
    required this.color,
    this.size = 46,
    this.strokeWidth = 5,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: progress.clamp(0.0, 1.0)),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
      builder: (context, val, _) => SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: Size(size, size),
              painter: RingProgressPainter(
                progress: val,
                color: color,
                strokeWidth: strokeWidth,
              ),
            ),
            ?child,
          ],
        ),
      ),
    );
  }
}

class GaugePainter extends CustomPainter {
  final double value;
  final Color color;
  GaugePainter({required this.value, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2 - 12;
    final bg = Paint()
      ..color = color.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;
    final fg = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi,
      pi,
      false,
      bg,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi,
      pi * value,
      false,
      fg,
    );
  }

  @override
  bool shouldRepaint(covariant GaugePainter oldDelegate) =>
      oldDelegate.value != value;
}

class BarChartPainter extends CustomPainter {
  final List<int> values;
  final double progress;
  BarChartPainter({required this.values, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final maxVal = values.isEmpty
        ? 1
        : (values.reduce(max) == 0 ? 1 : values.reduce(max));
    final barWidth = size.width / (values.length * 2);
    double x = barWidth / 2;
    for (final v in values) {
      final h = max(6.0, (v / maxVal) * size.height * progress);
      final rect = Rect.fromLTWH(x, size.height - h, barWidth, h);
      final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(7));
      final paint = Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [kSkyMid, kSkyDeep],
        ).createShader(rect);
      canvas.drawRRect(rrect, paint);
      x += barWidth * 2;
    }
  }

  @override
  bool shouldRepaint(covariant BarChartPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.values != values;
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          _index == 0 ? 'My Plants' : 'Analytics',
          style: TextStyle(color: Colors.cyan),
        ),
        actions: [
          IconButton(
            onPressed: themeController.toggle,
            icon: ValueListenableBuilder<ThemeMode>(
              valueListenable: themeController,
              builder: (context, mode, _) => Icon(
                mode == ThemeMode.light
                    ? Icons.dark_mode_outlined
                    : Icons.light_mode_outlined,
              ),
            ),
          ),
        ],
      ),
      body: AnimatedGradientBackground(
        child: SafeArea(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _index == 0
                ? const PlantsPage(key: ValueKey('plants'))
                : const AnalyticsPage(key: ValueKey('analytics')),
          ),
        ),
      ),
      floatingActionButton: AnimatedScale(
        scale: _index == 0 ? 1 : 0,
        duration: const Duration(milliseconds: 250),
        child: FloatingActionButton.extended(
          onPressed: () => _showAddSheet(context),
          backgroundColor: kSkyDeep,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add_rounded),
          label: const Text('Add Plant'),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.yard_outlined),
            selectedIcon: Icon(Icons.yard_rounded),
            label: 'Plants',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights_rounded),
            label: 'Analytics',
          ),
        ],
      ),
    );
  }

  void _showAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddPlantSheet(),
    );
  }
}

class EmptyPlantsState extends StatefulWidget {
  const EmptyPlantsState({super.key});
  @override
  State<EmptyPlantsState> createState() => _EmptyPlantsStateState();
}

class _EmptyPlantsStateState extends State<EmptyPlantsState>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) => Transform.translate(
              offset: Offset(0, -8 * _controller.value),
              child: child,
            ),
            child: Icon(
              Icons.local_florist_outlined,
              size: 88,
              color: kSkyDeep.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'No plants match here',
            style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

class PlantsPage extends StatefulWidget {
  const PlantsPage({super.key});
  @override
  State<PlantsPage> createState() => _PlantsPageState();
}

class _PlantsPageState extends State<PlantsPage> {
  String _query = '';
  String _filter = 'All';

  List<PlantModel> get _filtered {
    var list = plantStore.plants.where((p) {
      final q = _query.toLowerCase();
      return p.name.toLowerCase().contains(q) ||
          p.species.toLowerCase().contains(q);
    }).toList();
    if (_filter == 'Due') list = list.where((p) => p.isDue).toList();
    if (_filter == 'Healthy') list = list.where((p) => !p.isDue).toList();
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: plantStore,
      builder: (context, _) {
        final plants = _filtered;
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 90, 20, 8),
              child: _SearchBar(onChanged: (v) => setState(() => _query = v)),
            ),
            _FilterChips(
              selected: _filter,
              onSelected: (f) => setState(() => _filter = f),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: plants.isEmpty
                  ? const EmptyPlantsState()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 120),
                      itemCount: plants.length,
                      itemBuilder: (context, index) {
                        final plant = plants[index];
                        return FadeSlideIn(
                          index: index,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: PlantCard(
                              key: ValueKey(plant.id),
                              plant: plant,
                              onTap: () => _openDetail(context, plant),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  void _openDetail(BuildContext context, PlantModel plant) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 320),
        pageBuilder: (_, anim, _) => PlantDetailPage(plant: plant),
        transitionsBuilder: (_, anim, _, child) => FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position:
                Tween<Offset>(
                  begin: const Offset(0, 0.05),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(parent: anim, curve: Curves.easeOutCubic),
                ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;
  const _SearchBar({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
          ),
        ],
      ),
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Search plants...',
          prefixIcon: const Icon(Icons.search_rounded, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelected;
  const _FilterChips({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final items = ['All', 'Due', 'Healthy'];
    return SizedBox(
      height: 42,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: items.length,
        itemBuilder: (context, i) {
          final label = items[i];
          final active = label == selected;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () => onSelected(label),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: active ? kSkyDeep : Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: active
                      ? [
                          BoxShadow(
                            color: kSkyDeep.withValues(alpha: 0.3),
                            blurRadius: 10,
                          ),
                        ]
                      : [],
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: active ? Colors.white : Colors.grey.shade600,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class PlantCard extends StatelessWidget {
  final PlantModel plant;
  final VoidCallback onTap;
  const PlantCard({super.key, required this.plant, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final due = plant.isDue;
    final ringColor = due ? kAccentOrange : kSkyDeep;
    return Dismissible(
      key: ValueKey('dismiss_${plant.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 26),
        decoration: BoxDecoration(
          color: Colors.redAccent.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(22),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
      ),
      onDismissed: (_) {
        HapticFeedback.lightImpact();
        plantStore.removePlant(plant.id);
      },
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: plant.color.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(plant.icon, color: plant.color, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plant.name,
                        style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        plant.species,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        due ? 'Water me today' : 'Water in ${plant.daysLeft}d',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: ringColor,
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedRing(
                  progress: plant.progress,
                  color: ringColor,
                  size: 44,
                  strokeWidth: 4.5,
                  child: Icon(
                    due
                        ? Icons.priority_high_rounded
                        : Icons.water_drop_rounded,
                    size: 16,
                    color: ringColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PlantDetailPage extends StatefulWidget {
  final PlantModel plant;
  const PlantDetailPage({super.key, required this.plant});
  @override
  State<PlantDetailPage> createState() => _PlantDetailPageState();
}

class _PlantDetailPageState extends State<PlantDetailPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _burst;

  @override
  void initState() {
    super.initState();
    _burst = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
  }

  @override
  void dispose() {
    _burst.dispose();
    super.dispose();
  }

  void _water() {
    HapticFeedback.mediumImpact();
    plantStore.waterPlant(widget.plant.id);
    _burst.forward(from: 0);
  }

  String _formatDate(DateTime d) {
    final diff = DateTime.now().difference(d).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return '$diff days ago';
  }

  @override
  Widget build(BuildContext context) {
    final plant = widget.plant;
    return AnimatedBuilder(
      animation: plantStore,
      builder: (context, _) {
        final due = plant.isDue;
        final color = due ? kAccentOrange : kSkyDeep;
        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(title: Text(plant.name)),
          body: AnimatedGradientBackground(
            child: SafeArea(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 100, 24, 40),
                children: [
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        AnimatedRing(
                          progress: plant.progress,
                          color: color,
                          size: 180,
                          strokeWidth: 10,
                        ),
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: Colors.black12, blurRadius: 20),
                            ],
                          ),
                          child: Icon(plant.icon, size: 54, color: plant.color),
                        ),
                        ScaleTransition(
                          scale: Tween(begin: 1.0, end: 1.9).animate(
                            CurvedAnimation(
                              parent: _burst,
                              curve: Curves.easeOut,
                            ),
                          ),
                          child: FadeTransition(
                            opacity: Tween(
                              begin: 0.6,
                              end: 0.0,
                            ).animate(_burst),
                            child: Container(
                              width: 180,
                              height: 180,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: kSkyDeep, width: 3),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Text(
                      due
                          ? 'Time to water!'
                          : '${plant.daysLeft} days until next watering',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _infoRow(Icons.eco_outlined, 'Species', plant.species),
                        const Divider(height: 24),
                        _infoRow(
                          Icons.calendar_today_outlined,
                          'Interval',
                          '${plant.intervalDays} days',
                        ),
                        const Divider(height: 24),
                        _infoRow(
                          Icons.wb_sunny_outlined,
                          'Sunlight',
                          plant.sunlight,
                        ),
                        const Divider(height: 24),
                        _infoRow(
                          Icons.history_rounded,
                          'Last watered',
                          _formatDate(plant.lastWatered),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: _water,
                      icon: const Icon(Icons.water_drop_rounded),
                      label: const Text('Mark as Watered'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kSkyDeep,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: kSkyDeep),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label, style: TextStyle(color: Colors.grey.shade600)),
        ),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class AddPlantSheet extends StatefulWidget {
  const AddPlantSheet({super.key});
  @override
  State<AddPlantSheet> createState() => _AddPlantSheetState();
}

class _AddPlantSheetState extends State<AddPlantSheet> {
  final _nameController = TextEditingController();
  final _speciesController = TextEditingController();
  int _interval = 7;
  IconData _icon = Icons.eco_rounded;
  Color _color = kAccentGreen;
  String _sunlight = 'Medium';

  final _icons = [
    Icons.eco_rounded,
    Icons.grass_rounded,
    Icons.local_florist_rounded,
    Icons.spa_rounded,
    Icons.park_rounded,
  ];
  final _colors = [
    kAccentGreen,
    kSkyDeep,
    kAccentOrange,
    Colors.purple,
    Colors.teal,
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _speciesController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_nameController.text.trim().isEmpty) return;
    plantStore.addPlant(
      PlantModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        species: _speciesController.text.trim().isEmpty
            ? 'Unknown species'
            : _speciesController.text.trim(),
        intervalDays: _interval,
        lastWatered: DateTime.now(),
        icon: _icon,
        color: _color,
        sunlight: _sunlight,
      ),
    );
    HapticFeedback.selectionClick();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Add New Plant',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _nameController,
                decoration: _inputDecoration('Plant name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _speciesController,
                decoration: _inputDecoration('Species'),
              ),
              const SizedBox(height: 18),
              Text(
                'Icon',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
              const SizedBox(height: 8),
              Row(children: _icons.map(_iconOption).toList()),
              const SizedBox(height: 16),
              Text(
                'Color',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
              const SizedBox(height: 8),
              Row(children: _colors.map(_colorOption).toList()),
              const SizedBox(height: 18),
              Text(
                'Sunlight',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  'Low',
                  'Medium',
                  'High',
                ].map(_sunlightOption).toList(),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Text(
                    'Watering interval',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                  const Spacer(),
                  Text(
                    '$_interval days',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: kSkyDeep,
                    ),
                  ),
                ],
              ),
              Slider(
                value: _interval.toDouble(),
                min: 1,
                max: 30,
                divisions: 29,
                activeColor: kSkyDeep,
                onChanged: (v) => setState(() => _interval = v.round()),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kSkyDeep,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    'Add Plant',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Theme.of(context).cardColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  Widget _iconOption(IconData icon) {
    final active = icon == _icon;
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: GestureDetector(
        onTap: () => setState(() => _icon = icon),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: active
                ? _color.withValues(alpha: 0.18)
                : Theme.of(context).cardColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: active ? _color : Colors.transparent,
              width: 2,
            ),
          ),
          child: Icon(icon, color: active ? _color : Colors.grey.shade500),
        ),
      ),
    );
  }

  Widget _colorOption(Color color) {
    final active = color == _color;
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: GestureDetector(
        onTap: () => setState(() => _color = color),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: active ? Colors.black87 : Colors.transparent,
              width: 2,
            ),
          ),
          child: active
              ? const Icon(Icons.check, size: 16, color: Colors.white)
              : null,
        ),
      ),
    );
  }

  Widget _sunlightOption(String label) {
    final active = label == _sunlight;
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: GestureDetector(
        onTap: () => setState(() => _sunlight = label),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: active ? kSkyDeep : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: active ? Colors.white : Colors.grey.shade600,
            ),
          ),
        ),
      ),
    );
  }
}

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: plantStore,
      builder: (context, _) {
        final history = plantStore.last7Days();
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 100, 20, 120),
          children: [
            Row(
              children: [
                _statTile(
                  'Total',
                  plantStore.total.toDouble(),
                  kSkyDeep,
                  Icons.spa_rounded,
                ),
                const SizedBox(width: 12),
                _statTile(
                  'Due',
                  plantStore.dueCount.toDouble(),
                  kAccentOrange,
                  Icons.water_drop_rounded,
                ),
                const SizedBox(width: 12),
                _statTile(
                  'Logged',
                  plantStore.loggedCount.toDouble(),
                  kAccentGreen,
                  Icons.history_rounded,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: _cardDecoration(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Watering activity',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    height: 110,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 900),
                      curve: Curves.easeOutCubic,
                      builder: (context, t, _) => CustomPaint(
                        size: const Size(double.infinity, 110),
                        painter: BarChartPainter(
                          values: history.values.toList(),
                          progress: t,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: history.keys
                        .map(
                          (k) => Text(
                            k,
                            style: TextStyle(
                              fontSize: 10.5,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: _cardDecoration(context),
              child: Column(
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Care score',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: plantStore.careScore / 100),
                    duration: const Duration(milliseconds: 900),
                    curve: Curves.easeOutCubic,
                    builder: (context, t, _) => SizedBox(
                      width: 200,
                      height: 110,
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          CustomPaint(
                            size: const Size(200, 110),
                            painter: GaugePainter(value: t, color: kSkyDeep),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: AnimatedCounter(
                              value: plantStore.careScore,
                              decimals: 0,
                              suffix: '%',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: kSkyDeep,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: _cardDecoration(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Plant status',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  ...plantStore.plants.map((p) {
                    final due = p.isDue;
                    final color = due ? kAccentOrange : kAccentGreen;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          AnimatedRing(
                            progress: p.progress,
                            color: color,
                            size: 30,
                            strokeWidth: 3,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              p.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              due ? 'Needs water' : '${p.daysLeft}d left',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: color,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  BoxDecoration _cardDecoration(BuildContext context) {
    return BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }

  Widget _statTile(String label, double value, Color color, IconData icon) {
    return Expanded(
      child: Builder(
        builder: (context) => Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: _cardDecoration(context),
          child: Column(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 8),
              AnimatedCounter(
                value: value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(fontSize: 11.5, color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
