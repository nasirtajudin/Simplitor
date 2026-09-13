import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

void main() => runApp(const SpatialApp());

/* ---------------- shared brand colors ---------------- */
const Color kAccent = Color(0xFFF15523);
const Color kAccent2 = Color(0xFFFF7A45);
const Color kNavyA = Color(0xFF2C345E);
const Color kNavyB = Color(0xFF20264A);
const Color kNavyC = Color(0xFF181D3C);
const Color kTileA = Color(0xFF2A3157);
const Color kTileB = Color(0xFF1B2036);
const Color kAvatarFg = Color(0xFFF4EDE4);
const Color kCubeFg = Color(0xFFFFB39A);
const Color kNextEyebrow = Color(0xFFFF9E7E);
const Color kNextSub = Color(0xFFA7ADC9);
const Color kToastBg = Color(0xF0151828);

TextStyle txt(double size, FontWeight w, Color c, {double ls = 0, double? h}) =>
    TextStyle(fontSize: size, fontWeight: w, color: c, letterSpacing: ls, height: h);

/* ---------------- light / dark palettes ---------------- */
class Palette {
  final Color bg, bgDot, card, cardBorder, ink, ink2, ink3;
  final Color track, lockBg, accentSoft, ok, okSoft, deco;
  final Color shadow, scrim, glassBorder, badgeDim;

  const Palette({
    required this.bg, required this.bgDot, required this.card, required this.cardBorder,
    required this.ink, required this.ink2, required this.ink3,
    required this.track, required this.lockBg, required this.accentSoft,
    required this.ok, required this.okSoft, required this.deco,
    required this.shadow, required this.scrim, required this.glassBorder, required this.badgeDim,
  });

  static const Palette light = Palette(
    bg: Color(0xFFEFEAE0), bgDot: Color(0x171B2036),
    card: Color(0xFFFFFFFF), cardBorder: Color(0xFFE7E1D2),
    ink: Color(0xFF1B2036), ink2: Color(0xFF575E76), ink3: Color(0xFF969BAC),
    track: Color(0xFFECE7D9), lockBg: Color(0xFFEFEBE0),
    accentSoft: Color(0xFFFBE4D8), ok: Color(0xFF1D9E5C), okSoft: Color(0xFFDDF3E6),
    deco: Color(0x17F15523),
    shadow: Color(0x331B2036), scrim: Color(0xA6FFFFFF),
    glassBorder: Color(0xCCFFFFFF), badgeDim: Color(0xB3EFEAE0),
  );

  static const Palette dark = Palette(
    bg: Color(0xFF14161D), bgDot: Color(0x1FFFFFFF),
    card: Color(0xFF1E2231), cardBorder: Color(0xFF2B303F),
    ink: Color(0xFFEDEAE0), ink2: Color(0xFFA9AEBC), ink3: Color(0xFF767B8C),
    track: Color(0xFF2A2E3C), lockBg: Color(0xFF262A36),
    accentSoft: Color(0xFF35251B), ok: Color(0xFF2FBE7B), okSoft: Color(0xFF173322),
    deco: Color(0x30F15523),
    shadow: Color(0x99000000), scrim: Color(0xA616191F),
    glassBorder: Color(0x3DFFFFFF), badgeDim: Color(0xB314161D),
  );

  static Palette of(Brightness b) => b == Brightness.dark ? dark : light;
}

/* ---------------- app root (theme switch) ---------------- */
class SpatialApp extends StatefulWidget {
  const SpatialApp({super.key});
  @override
  State<SpatialApp> createState() => _SpatialAppState();
}

class _SpatialAppState extends State<SpatialApp> {
  ThemeMode _mode = ThemeMode.light;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spatial · Syllabus',
      debugShowCheckedModeBanner: false,
      themeMode: _mode,
      theme: ThemeData(brightness: Brightness.light, useMaterial3: true),
      darkTheme: ThemeData(brightness: Brightness.dark, useMaterial3: true),
      home: SyllabusScreen(
        onToggleTheme: () => setState(() {
          _mode = _mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
        }),
      ),
    );
  }
}

/* ---------------- data model ---------------- */
class Mod {
  final String n, title, desc;
  final int pages, videos, initP, initV;
  int doneP, doneV;
  bool userDone = false;

  Mod({
    required this.n, required this.title, required this.desc,
    required this.pages, required this.videos,
    required this.doneP, required this.doneV,
  })  : initP = doneP, initV = doneV;

  bool get isDone => doneP >= pages && doneV >= videos;
}

/* ---------------- the screen ---------------- */
class SyllabusScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  const SyllabusScreen({super.key, required this.onToggleTheme});
  @override
  State<SyllabusScreen> createState() => _SyllabusScreenState();
}

class _SyllabusScreenState extends State<SyllabusScreen> with TickerProviderStateMixin {
  late final AnimationController _intro =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))..forward();
  late final AnimationController _ring =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
  late final AnimationController _eq =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 900));

  final List<Mod> mods = [
    Mod(n: '01', title: 'Mental Rotation', pages: 6, videos: 2, doneP: 6, doneV: 2,
        desc: 'Spin 3-D figures in your head, track axis shifts, and pick the matching orientation before the timer bites.'),
    Mod(n: '02', title: 'Paper Folding', pages: 5, videos: 2, doneP: 5, doneV: 2,
        desc: 'Follow hole punches through folded sheets, unfold mentally, and predict the final pattern.'),
    Mod(n: '03', title: 'Cube Counting', pages: 4, videos: 2, doneP: 4, doneV: 2,
        desc: 'Count hidden cubes in stacked structures without double-counting or losing your row.'),
    Mod(n: '04', title: 'Pattern Assembly', pages: 5, videos: 3, doneP: 2, doneV: 2,
        desc: 'Fold 2-D patterns into closed solids and learn to rule out impossible faces in seconds.'),
    Mod(n: '05', title: 'Mirror & Water Images', pages: 4, videos: 1, doneP: 0, doneV: 0,
        desc: 'Flip figures across mirror lines and water surfaces at speed — the highest-yield unit on the test.'),
  ];

  final Set<int> _open = {};
  final Map<int, int> _pop = {}, _shake = {};
  double _barP = 0;
  bool _playing = false, _bellDot = true;
  String _toastText = '';
  bool _toastOn = false;
  Timer? _toastTimer, _ringTimer;

  /* ---- course math (video counts as half a page → lands exactly on 72%) ---- */
  int get _doneP => mods.fold(0, (s, m) => s + m.doneP);
  int get _doneV => mods.fold(0, (s, m) => s + m.doneV);
  bool _isDone(Mod m) => m.isDone;
  int get _coursePct => (100 * (_doneP + 0.5 * _doneV) / (24 + 0.5 * 10)).round();
  bool _locked(int i) => i == 4 && !mods[3].isDone;

  @override
  void initState() {
    super.initState();
    _ringTimer = Timer(const Duration(milliseconds: 450), () {
      if (!mounted) return;
      setState(() => _barP = _coursePct / 100);
      _ring.animateTo(_coursePct / 100,
          duration: const Duration(milliseconds: 900), curve: Curves.easeOutCubic);
    });
  }

  @override
  void dispose() {
    _toastTimer?.cancel();
    _ringTimer?.cancel();
    _intro.dispose();
    _ring.dispose();
    _eq.dispose();
    super.dispose();
  }

  /* ---- actions ---- */
  void _toast(String msg) {
    setState(() {
      _toastText = msg;
      _toastOn = true;
    });
    _toastTimer?.cancel();
    _toastTimer = Timer(const Duration(milliseconds: 2400), () {
      if (mounted) setState(() => _toastOn = false);
    });
  }

  void _toggleModule(int i) {
    if (_locked(i)) {
      setState(() => _shake[i] = (_shake[i] ?? 0) + 1);
      _toast('Locked — finish ${mods[3].title} first');
      return;
    }
    setState(() => _open.contains(i) ? _open.remove(i) : _open.add(i));
  }

  void _completeModule(int i) {
    final wasLocked = _locked(4);
    final m = mods[i];
    setState(() {
      m.doneP = m.pages;
      m.doneV = m.videos;
      m.userDone = true;
      _pop[i] = (_pop[i] ?? 0) + 1;
      _barP = _coursePct / 100;
    });
    _ring.animateTo(_coursePct / 100,
        duration: const Duration(milliseconds: 900), curve: Curves.easeOutCubic);
    if (wasLocked) {
      _toast('${mods[3].title} complete — ${mods[4].title} unlocked');
    } else if (_coursePct >= 100) {
      _toast('Course complete — you’re set for the Theory Test');
    } else {
      _toast('${m.title} marked complete');
    }
  }

  void _undoModule(int i) {
    final m = mods[i];
    setState(() {
      m.doneP = m.initP;
      m.doneV = m.initV;
      m.userDone = false;
      _barP = _coursePct / 100;
    });
    _ring.animateTo(_coursePct / 100,
        duration: const Duration(milliseconds: 900), curve: Curves.easeOutCubic);
    _toast('Progress reset · ${m.title}');
  }

  void _review() => _toast('Lecture library opens on screen 02 — next in the series');

  void _togglePlay() {
    setState(() => _playing = !_playing);
    if (_playing) {
      _eq.repeat();
      _toast('Now playing · Folding Solids (demo)');
    } else {
      _eq.stop();
      _toast('Paused');
    }
  }

  Animation<double> _sec(double b) =>
      CurvedAnimation(parent: _intro, curve: Interval(b, b + 0.16, curve: Curves.easeOutCubic));

  /* ---- build ---- */
  @override
  Widget build(BuildContext context) {
    final pal = Palette.of(Theme.of(context).brightness);
    final hour = DateTime.now().hour;
    final greet = hour < 5
        ? 'Late-night session'
        : hour < 12 ? 'Good morning' : hour < 18 ? 'Good afternoon' : 'Good evening';

    return Scaffold(
      backgroundColor: pal.bg,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // dotted paper texture
            Positioned.fill(child: CustomPaint(painter: DotsPainter(color: pal.bgDot))),

            // scrolling content
            Positioned.fill(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 10, 22, 150),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Reveal(animation: _sec(0.0), child: _header(pal, greet)),
                    const SizedBox(height: 24),
                    Reveal(animation: _sec(0.06), child: _titleBlock(pal)),
                    const SizedBox(height: 16),
                    Reveal(animation: _sec(0.14), child: _banner(pal)),
                    const SizedBox(height: 14),
                    Reveal(animation: _sec(0.2), child: _hero(pal)),
                    const SizedBox(height: 14),
                    Reveal(animation: _sec(0.26), child: _nextCard(pal)),
                    const SizedBox(height: 24),
                    Reveal(animation: _sec(0.32), child: _modulesHead(pal)),
                    const SizedBox(height: 11),
                    for (var i = 0; i < mods.length; i++) ...[
                      Reveal(animation: _sec(0.38 + i * 0.06), child: _moduleCard(pal, i)),
                      const SizedBox(height: 10),
                    ],
                    const SizedBox(height: 10),
                    Reveal(animation: _sec(0.72), child: _foot(pal)),
                  ],
                ),
              ),
            ),

            // toast
            Positioned(top: 14, left: 22, right: 22, child: _toastWidget()),

            // floating glass bottom navigation
            Positioned(left: 18, right: 18, bottom: 18, child: GlassNav(pal: pal, onToast: _toast)),
          ],
        ),
      ),
    );
  }

  /* ---- header ---- */
  Widget _header(Palette pal, String greet) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Container(
          width: 46, height: 46,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [kTileA, kTileB]),
          ),
          child: Center(child: Text('AK', style: txt(14, FontWeight.w700, kAvatarFg, ls: 0.5))),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$greet,', style: txt(12.5, FontWeight.w400, pal.ink2)),
            Text('Alex Kim', style: txt(16, FontWeight.w700, pal.ink, ls: -0.2)),
          ],
        ),
        const Spacer(),
        _squareBtn(pal, isDark ? Icons.light_mode : Icons.dark_mode, widget.onToggleTheme),
        const SizedBox(width: 10),
        Stack(
          children: [
            _squareBtn(pal, Icons.notifications_none, () {
              setState(() => _bellDot = false);
              _toast('You’re all caught up');
            }),
            if (_bellDot)
              Positioned(
                top: 11, right: 12,
                child: Container(
                  width: 8, height: 8,
                  decoration: BoxDecoration(
                    color: kAccent, shape: BoxShape.circle,
                    border: Border.all(color: pal.card, width: 2),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _squareBtn(Palette pal, IconData icon, VoidCallback onTap) {
    return Container(
      width: 46, height: 46,
      decoration: BoxDecoration(
        color: pal.card, borderRadius: BorderRadius.circular(15),
        border: Border.all(color: pal.cardBorder),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: onTap,
          child: Center(child: Icon(icon, size: 21, color: pal.ink)),
        ),
      ),
    );
  }

  /* ---- title ---- */
  Widget _titleBlock(Palette pal) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(TextSpan(children: [
          TextSpan(text: 'Your Custom\n', style: txt(31, FontWeight.w800, pal.ink, ls: -0.6, h: 1.12)),
          TextSpan(
            text: 'Syllabus',
            style: txt(31, FontWeight.w600, kAccent, ls: -0.3, h: 1.12)
                .copyWith(fontStyle: FontStyle.italic),
          ),
        ])),
        const SizedBox(height: 6),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 300),
          child: Text('Built from your June diagnostic · Spatial Reasoning track',
              style: txt(12.5, FontWeight.w400, pal.ink2, h: 1.55)),
        ),
      ],
    );
  }

  /* ---- deadline banner ---- */
  Widget _banner(Palette pal) {
    return Container(
      decoration: BoxDecoration(
        color: pal.card, borderRadius: BorderRadius.circular(18),
        border: Border.all(color: pal.cardBorder),
        boxShadow: [BoxShadow(color: pal.shadow, blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _toast('Theory Test · Sun Jun 14 · Room 244 — full calendar is screen 03'),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 42, height: 42,
                  decoration: BoxDecoration(color: pal.accentSoft, borderRadius: BorderRadius.circular(13)),
                  child: Center(child: Icon(Icons.event_outlined, size: 20, color: kAccent)),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('NEXT DEADLINE', style: txt(9.5, FontWeight.w700, pal.ink3, ls: 1.5)),
                      const SizedBox(height: 2),
                      Text('Theory Test · Room 244', style: txt(14.5, FontWeight.w700, pal.ink)),
                      const SizedBox(height: 2),
                      Text('Sun, Jun 14 · 40 points', style: txt(11.5, FontWeight.w400, pal.ink2)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                  decoration: BoxDecoration(color: pal.ink, borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    children: [
                      Text('6', style: txt(18, FontWeight.w800, pal.bg, h: 1.0)),
                      Text('DAYS', style: txt(9, FontWeight.w600, pal.badgeDim, ls: 1.2)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /* ---- hero course card with the 72% ring ---- */
  Widget _hero(Palette pal) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: pal.shadow, blurRadius: 40, offset: const Offset(0, 18), spreadRadius: -18)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Positioned.fill(child: ColoredBox(color: pal.card)),
            Positioned(
              top: -40, right: -40,
              child: CustomPaint(size: const Size(170, 170), painter: CubePainter(color: pal.deco, strokeWidth: 1.5)),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 52, height: 52,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [kTileA, kTileB]),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(child: Icon(Icons.view_in_ar, size: 26, color: kCubeFg)),
                      ),
                      const SizedBox(width: 13),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('COURSE 01 · SPATIAL TRACK', style: txt(9.5, FontWeight.w700, kAccent, ls: 1.5)),
                            const SizedBox(height: 3),
                            Text('Spatial Aptitude', style: txt(21, FontWeight.w800, pal.ink, ls: -0.4)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _statRow(pal, Icons.description_outlined, '24 pages · full syllabus'),
                            const SizedBox(height: 7),
                            _statRow(pal, Icons.play_circle_outline, '10 videos · walkthroughs'),
                            const SizedBox(height: 7),
                            _statRow(pal, Icons.schedule, '≈ 55 min of study left'),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      _ringWidget(pal),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _heroBar(pal),
                  const SizedBox(height: 8),
                  Text('$_doneP of 24 pages · $_doneV of 10 videos', style: txt(11, FontWeight.w500, pal.ink3)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statRow(Palette pal, IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 13, color: pal.ink3),
        const SizedBox(width: 8),
        Flexible(child: Text(label, style: txt(12, FontWeight.w600, pal.ink2), maxLines: 1, overflow: TextOverflow.ellipsis)),
      ],
    );
  }

  Widget _ringWidget(Palette pal) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _toast('Progress $_coursePct% · ${24 - _doneP} pages and ${10 - _doneV} videos to go'),
      child: SizedBox(
        width: 88, height: 88,
        child: AnimatedBuilder(
          animation: _ring,
          builder: (context, _) => Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(painter: RingPainter(progress: _ring.value, track: pal.track, fill: kAccent), size: const Size(88, 88)),
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text('${(_ring.value * 100).round()}', style: txt(17, FontWeight.w800, pal.ink)),
                  const SizedBox(width: 1),
                  Text('%', style: txt(10, FontWeight.w700, pal.ink3)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _heroBar(Palette pal) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: _barP),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, v, _) => ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: Container(
          height: 6, color: pal.track,
          child: Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: v,
              child: Container(
                height: 6,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [kAccent, kAccent2]),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /* ---- continue card ---- */
  Widget _nextCard(Palette pal) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: pal.shadow, blurRadius: 40, offset: const Offset(0, 18), spreadRadius: -14)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                    stops: const [0.0, 0.55, 1.0],
                    colors: const [kNavyA, kNavyB, kNavyC],
                  ),
                ),
              ),
            ),
            Positioned(
              right: -46, bottom: -58,
              child: CustomPaint(size: const Size(190, 190), painter: CubePainter(color: const Color(0x1AFFFFFF), strokeWidth: 1.2)),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('CONTINUE · 12 MIN', style: txt(9.5, FontWeight.w700, kNextEyebrow, ls: 1.5)),
                        const SizedBox(height: 4),
                        Text('Pattern Assembly — Folding Solids', style: txt(15, FontWeight.w700, Colors.white, ls: -0.2, h: 1.25)),
                        const SizedBox(height: 4),
                        Text('Video 3 of 3 · then 3 pages close the module', style: txt(11.5, FontWeight.w400, kNextSub)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  GestureDetector(
                    onTap: _togglePlay,
                    child: Container(
                      width: 52, height: 52, alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: kAccent, shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: const Color(0x66F15523), blurRadius: 22, offset: const Offset(0, 10), spreadRadius: -8)],
                      ),
                      child: _playing
                          ? _Eq(animation: _eq)
                          : const Icon(Icons.play_arrow_rounded, size: 24, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /* ---- modules ---- */
  Widget _modulesHead(Palette pal) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Modules', style: txt(18, FontWeight.w800, pal.ink, ls: -0.3)),
        Text('5 units · ${mods.where(_isDone).length} done', style: txt(11.5, FontWeight.w500, pal.ink3)),
      ],
    );
  }

  Widget _moduleCard(Palette pal, int i) {
    final m = mods[i];
    return _ModuleCard(
      pal: pal, mod: m,
      expanded: _open.contains(i),
      locked: _locked(i),
      popId: _pop[i] ?? 0,
      shakeId: _shake[i] ?? 0,
      onToggle: () => _toggleModule(i),
      onComplete: () => _completeModule(i),
      onUndo: () => _undoModule(i),
      onReview: _review,
    );
  }

  Widget _foot(Palette pal) {
    return SizedBox(
      width: double.infinity,
      child: Text('Plan generated Jun 1 · re-balances every Sunday night',
          textAlign: TextAlign.center, style: txt(10.5, FontWeight.w400, pal.ink3)),
    );
  }

  /* ---- toast ---- */
  Widget _toastWidget() {
    return IgnorePointer(
      child: AnimatedSlide(
        offset: _toastOn ? Offset.zero : const Offset(0, -0.6),
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeOutCubic,
        child: AnimatedOpacity(
          opacity: _toastOn ? 1 : 0,
          duration: const Duration(milliseconds: 300),
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(color: kToastBg, borderRadius: BorderRadius.circular(100)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 6, height: 6, decoration: const BoxDecoration(color: kAccent, shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                  Flexible(child: Text(_toastText, maxLines: 1, overflow: TextOverflow.ellipsis, style: txt(12, FontWeight.w600, Colors.white))),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/* ---------------- module card ---------------- */
class _ModuleCard extends StatelessWidget {
  final Palette pal;
  final Mod mod;
  final bool expanded, locked;
  final int popId, shakeId;
  final VoidCallback onToggle, onComplete, onUndo, onReview;

  const _ModuleCard({
    required this.pal, required this.mod, required this.expanded, required this.locked,
    required this.popId, required this.shakeId,
    required this.onToggle, required this.onComplete, required this.onUndo, required this.onReview,
  });

  @override
  Widget build(BuildContext context) {
    final done = mod.isDone;
    final partial = !done && !locked && (mod.doneP + mod.doneV) > 0;
    final pct = (100 * (mod.doneP + 0.5 * mod.doneV) / (mod.pages + 0.5 * mod.videos)).round();

    final card = Container(
      decoration: BoxDecoration(
        color: pal.card, borderRadius: BorderRadius.circular(18),
        border: Border.all(color: pal.cardBorder),
        boxShadow: [BoxShadow(color: pal.shadow, blurRadius: 24, offset: const Offset(0, 12), spreadRadius: -12)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Material(
            type: MaterialType.transparency,
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: onToggle,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    _statusTile(pal, done, locked, popId),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('MODULE ${mod.n}', style: txt(9, FontWeight.w700, pal.ink3, ls: 1.2)),
                              _chip(pal, done, locked, pct),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(mod.title, style: txt(14.5, FontWeight.w700, pal.ink, ls: -0.2)),
                          const SizedBox(height: 2),
                          Text('${mod.pages} pages · ${mod.videos} videos', style: txt(11, FontWeight.w400, pal.ink2)),
                          AnimatedCrossFade(
                            duration: const Duration(milliseconds: 250),
                            sizeCurve: Curves.easeOutCubic,
                            crossFadeState: partial ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                            firstChild: Padding(
                              padding: const EdgeInsets.only(top: 9),
                              child: _miniBar(pal, pct / 100),
                            ),
                            secondChild: const SizedBox(width: double.infinity),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                    AnimatedRotation(
                      turns: expanded ? 0.25 : 0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                      child: Icon(Icons.chevron_right_rounded, size: 17, color: pal.ink3),
                    ),
                  ],
                ),
              ),
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 350),
            sizeCurve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            crossFadeState: expanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
            firstChild: _panel(),
            secondChild: const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );

    if (shakeId == 0) return card;
    return TweenAnimationBuilder<double>(
      key: ValueKey('shake$shakeId'),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 380),
      builder: (context, v, child) => Transform.translate(
        offset: Offset(math.sin(v * math.pi * 3) * 6 * (1 - v), 0),
        child: child,
      ),
      child: card,
    );
  }

  Widget _statusTile(Palette pal, bool done, bool locked, int popId) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: 42, height: 42,
      decoration: BoxDecoration(
        color: done ? pal.okSoft : locked ? pal.lockBg : pal.accentSoft,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Center(
        child: done
            ? TweenAnimationBuilder<double>(
                key: ValueKey('pop$popId'),
                tween: Tween<double>(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 450),
                curve: Curves.elasticOut,
                builder: (context, v, child) => Transform.scale(scale: v, child: child),
                child: Icon(Icons.check_rounded, size: 20, color: pal.ok),
              )
            : Icon(locked ? Icons.lock_outline : Icons.play_arrow_rounded, size: 20, color: locked ? pal.ink3 : kAccent),
      ),
    );
  }

  Widget _chip(Palette pal, bool done, bool locked, int pct) {
    final bg = done ? pal.okSoft : locked ? pal.lockBg : pal.accentSoft;
    final fg = done ? pal.ok : locked ? pal.ink3 : kAccent;
    final label = done ? 'Complete' : locked ? 'Locked' : '$pct%';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(100)),
      child: Text(label, style: txt(10, FontWeight.w700, fg)),
    );
  }

  Widget _miniBar(Palette pal, double fraction) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: fraction),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (context, v, _) => ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: Container(
          height: 4, color: pal.track,
          child: Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: v,
              child: Container(height: 4, color: kAccent),
            ),
          ),
        ),
      ),
    );
  }

  Widget _panel() {
    final done = mod.isDone;
    return Padding(
      padding: const EdgeInsets.only(left: 69, right: 14, bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(mod.desc, style: txt(12, FontWeight.w400, pal.ink2, h: 1.55)),
          const SizedBox(height: 11),
          if (locked)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lock_outline, size: 13, color: pal.ink3),
                const SizedBox(width: 7),
                Expanded(
                  child: Text.rich(TextSpan(
                    style: txt(11.5, FontWeight.w400, pal.ink3, h: 1.45),
                    children: [
                      const TextSpan(text: 'Finish '),
                      TextSpan(text: 'Pattern Assembly', style: txt(11.5, FontWeight.w600, pal.ink2)),
                      const TextSpan(text: ' to unlock this unit.'),
                    ],
                  )),
                ),
              ],
            )
          else
            Row(
              children: [
                if (!done) _btnPrimary() else _btnGhost(),
                if (done && mod.userDone)
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onUndo,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 9),
                      child: Text('Undo', style: txt(11.5, FontWeight.w600, pal.ink3)),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _btnPrimary() {
    return Material(
      color: kAccent,
      borderRadius: BorderRadius.circular(11),
      child: InkWell(
        borderRadius: BorderRadius.circular(11),
        onTap: onComplete,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          child: Text('Mark complete', style: txt(12, FontWeight.w700, Colors.white)),
        ),
      ),
    );
  }

  Widget _btnGhost() {
    return Container(
      decoration: BoxDecoration(
        color: pal.bg, borderRadius: BorderRadius.circular(11),
        border: Border.all(color: pal.cardBorder),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(11),
          onTap: onReview,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            child: Text('Review module', style: txt(12, FontWeight.w700, pal.ink)),
          ),
        ),
      ),
    );
  }
}

/* ---------------- floating glass bottom nav ---------------- */
class GlassNav extends StatelessWidget {
  final Palette pal;
  final void Function(String) onToast;

  const GlassNav({super.key, required this.pal, required this.onToast});

  static const List<(IconData, String)> _items = [
    (Icons.home_rounded, 'Home'),
    (Icons.event_outlined, 'Calendar'),
    (Icons.menu_book_outlined, 'Lectures'),
    (Icons.person_outline, 'You'),
  ];
  static const List<String> _toasts = [
    'Calendar & deadlines — that’s screen 03',
    'Lecture library — that’s screen 02',
    'Profile & settings — coming soon',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        boxShadow: [BoxShadow(color: pal.shadow, blurRadius: 24, offset: const Offset(0, 12))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: pal.scrim,
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: pal.glassBorder, width: 1),
            ),
            child: Row(
              children: [
                for (var j = 0; j < _items.length; j++)
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: j == 0 ? () {} : () => onToast(_toasts[j - 1]),
                      child: _navItem(_items[j].$1, _items[j].$2, j == 0),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, bool active) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: 46, height: 28,
          decoration: BoxDecoration(
            color: active ? pal.ink : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            boxShadow: active
                ? [BoxShadow(color: pal.shadow, blurRadius: 14, offset: const Offset(0, 6), spreadRadius: -6)]
                : null,
          ),
          child: Icon(icon, size: 17, color: active ? pal.bg : pal.ink3),
        ),
        const SizedBox(height: 3),
        Text(label, style: txt(10.5, FontWeight.w600, active ? pal.ink : pal.ink3)),
      ],
    );
  }
}

/* ---------------- equalizer (playing state) ---------------- */
class _Eq extends StatelessWidget {
  final Animation<double> animation;
  const _Eq({required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) => Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var j = 0; j < 3; j++)
            Container(
              width: 4,
              height: 6 + 12 * (0.5 + 0.5 * math.sin((animation.value + j * 0.22) * 2 * math.pi)),
              margin: EdgeInsets.only(right: j < 2 ? 3.5 : 0),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(2)),
            ),
        ],
      ),
    );
  }
}

/* ---------------- entrance animation ---------------- */
class Reveal extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;
  const Reveal({super.key, required this.animation, required this.child});

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(animation),
        child: child,
      ),
    );
  }
}

/* ---------------- painters ---------------- */
class RingPainter extends CustomPainter {
  final double progress;
  final Color track, fill;
  final double stroke;

  RingPainter({required this.progress, required this.track, required this.fill, this.stroke = 7});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = math.min(size.width, size.height) / 2 - stroke / 2;
    final p = progress < 0 ? 0.0 : (progress > 1 ? 1.0 : progress);

    canvas.drawCircle(c, r, Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = track);

    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      -math.pi / 2,
      2 * math.pi * p,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..color = fill,
    );
  }

  @override
  bool shouldRepaint(RingPainter old) =>
      old.progress != progress || old.track != track || old.fill != fill;
}

class CubePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  CubePainter({required this.color, this.strokeWidth = 1.5});

  @override
  void paint(Canvas canvas, Size size) {
    final s = math.min(size.width, size.height) / 150;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * s
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    final p = Path()
      ..moveTo(75 * s, 10 * s)
      ..lineTo(134 * s, 44 * s)
      ..lineTo(134 * s, 112 * s)
      ..lineTo(75 * s, 146 * s)
      ..lineTo(16 * s, 112 * s)
      ..lineTo(16 * s, 44 * s)
      ..close()
      ..moveTo(16 * s, 44 * s)
      ..lineTo(75 * s, 78 * s)
      ..lineTo(134 * s, 44 * s)
      ..moveTo(75 * s, 78 * s)
      ..lineTo(75 * s, 146 * s);

    canvas.drawPath(p, paint);
  }

  @override
  bool shouldRepaint(CubePainter old) =>
      old.color != color || old.strokeWidth != strokeWidth;
}

class DotsPainter extends CustomPainter {
  final Color color;
  DotsPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    const gap = 24.0, r = 1.1;
    for (double x = gap / 2; x < size.width; x += gap) {
      for (double y = gap / 2; y < size.height; y += gap) {
        canvas.drawCircle(Offset(x, y), r, paint);
      }
    }
  }

  @override
  bool shouldRepaint(DotsPainter old) => old.color != color;
}
