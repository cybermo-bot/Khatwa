import 'package:flutter/material.dart';

import '../../features/diet/diet_page.dart';
import '../../features/common.dart';
import '../../data/auth_store.dart';
import '../../data/case_store.dart';
import '../../data/khatwa_store.dart';
import '../../data/learn_content.dart';
import '../../data/routine_store.dart';
import '../../features/twin/twin_actions.dart';
import '../../ui/app_state.dart';
import '../../ui/app_theme.dart';
import '../../ui/foot_shapes.dart';
import '../../ui/foot_twin.dart';
import '../../ui/strings.dart';
import '../article_page.dart';
import '../foot_check.dart';
import '../glycemia.dart';
import '../patient_home.dart';
import '../report_view.dart';
import '../settings_page.dart';

class TodayTab extends StatefulWidget {
  const TodayTab({super.key});

  @override
  State<TodayTab> createState() => _TodayTabState();
}

class _TodayTabState extends State<TodayTab> {
  String get lang => appLanguage.value;

  @override
  void initState() {
    super.initState();
    RoutineStore.instance.load(AuthStore.instance.current?.id ?? '');
  }

  void _open(Widget page) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));

  @override
  Widget build(BuildContext context) {
    final account = AuthStore.instance.current;
    final patientId = account?.id ?? '';

    return AnimatedBuilder(
      animation: Listenable.merge(
          [CaseStore.instance, RoutineStore.instance, KhatwaStore.instance]),
      builder: (context, _) {
        final cases = CaseStore.instance.forPatient(patientId);
        final last = cases.isNotEmpty ? cases.first : null;
        final doneToday = CaseStore.instance.hasCheckToday(patientId);
        final todayCase = doneToday ? last : null;
        final streak = CaseStore.instance.streak(patientId);
        final now = DateTime.now();
        final name = (account?.guest ?? false) ? '' : _firstName(account?.name ?? '');
        final tip = tipFor(now);

        return KPage(
          title: name.isEmpty
              ? S.t(lang, 'home.hello')
              : '${S.t(lang, 'home.hello')} $name',
          subtitle: '${_dayName(now)} ${_shortDate(now)}',
          showBack: false,
          actions: [
            const LanguageButton(),
            IconButton(
              tooltip: S.t(lang, 'settings.title'),
              icon: const Icon(Icons.tune_rounded, size: 23),
              onPressed: () => _open(const SettingsPage()),
            ),
          ],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 6),
              KReveal(child: _TwinStage(lang: lang)),
              const SizedBox(height: 10),
              const KReveal(order: 1, child: TwinActions()),
              const SizedBox(height: 14),
              KReveal(
                order: 1,
                child: _CheckCard(
                  lang: lang,
                  done: doneToday,
                  streak: streak,
                  photos: todayCase?.photos.length ?? 0,
                  onStart: () => _open(FootCheckPage(language: lang)),
                  onSeeResult: todayCase == null
                      ? null
                      : () => _open(
                          ReportPage(caseId: todayCase.id, language: lang)),
                ),
              ),
              const SizedBox(height: 12),
              KReveal(
                order: 2,
                child: _Tiles(
                  lang: lang,
                  checkDone: doneToday,
                  onGlucose: () => _open(GlycemiaPage(language: lang)),
                ),
              ),
              const SizedBox(height: 12),
              KReveal(
                order: 3,
                child: KCard(
                  onTap: () => _open(const DietPage()),
                  padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
                  child: Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(color: K.primarySoft, borderRadius: BorderRadius.circular(K.r12)),
                        child: Icon(Icons.restaurant_rounded, color: K.primaryStrong),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(tr('Alimentation', aeb: 'الماكلة', ar: 'التغذية', en: 'Food'), style: K.bodyStrong),
                            Text(tr('Quoi manger, et combien', aeb: 'شنوّة تاكل، وقدّاش', ar: 'ماذا تأكل وكم', en: 'What to eat, and how much'),
                                style: K.small),
                          ],
                        ),
                      ),
                      Icon(S.isRtl(lang) ? Icons.chevron_left_rounded : Icons.chevron_right_rounded, color: K.muted),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              _Routine(
                  lang: lang,
                  checkDone: doneToday,
                  onOpen: (id) {
                    final article = articleById(id);
                    if (article != null) _open(ArticlePage(article: article));
                  }),
              const SizedBox(height: 30),
              KSectionLabel(LearnLabels.tipOfDay.of(lang)),
              _TipCard(
                  article: tip,
                  lang: lang,
                  onTap: () => _open(ArticlePage(article: tip))),
              if (last != null) ...[
                const SizedBox(height: 30),
                KSectionLabel(S.t(lang, 'home.lastResult')),
                KCard(
                  onTap: () =>
                      _open(ReportPage(caseId: last.id, language: lang)),
                  padding: const EdgeInsets.fromLTRB(18, 16, 14, 16),
                  child: Row(
                    children: [
                      LevelDot(level: last.triage.level, size: 48),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(levelHeadline(lang, last.triage.level),
                                style: K.h2),
                            const SizedBox(height: 3),
                            Text(formatDate(last.date), style: K.small),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: K.muted,
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  String _firstName(String name) {
    final parts = name.trim().split(' ');
    return parts.isEmpty ? '' : parts.first;
  }

  String _dayName(DateTime date) {
    final names = S.t(lang, 'week.names').split(',');
    return names.length == 7 ? names[date.weekday - 1] : '';
  }

  String _shortDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
}

// ---------------------------------------------------------------- 3D twin

/// The first thing the patient sees: their foot as a 3D hologram they can
/// turn and zoom, with the left/right switch and top/sole shortcuts.
class _TwinStage extends StatefulWidget {
  final String lang;
  const _TwinStage({required this.lang});

  @override
  State<_TwinStage> createState() => _TwinStageState();
}

class _TwinStageState extends State<_TwinStage> {
  FootSide _side = FootSide.left;
  TwinView _view = TwinView.free;
  final Map<FootSide, String?> _mine = {};

  @override
  void initState() {
    super.initState();
    _loadMine();
  }

  /// The patient's own scanned foot for each side, when there is one.
  Future<void> _loadMine() async {
    for (final side in FootSide.values) {
      final src = await myTwinSource(side == FootSide.left ? 'L' : 'R');
      if (!mounted) return;
      if (src != null) setState(() => _mine[side] = src);
    }
  }

  void _toggleView(TwinView v) =>
      setState(() => _view = _view == v ? TwinView.free : v);

  @override
  Widget build(BuildContext context) {
    final lang = widget.lang;
    return LayoutBuilder(builder: (context, box) {
      final height = (box.maxWidth * 1.08).clamp(340.0, 440.0);
      return Container(
        height: height,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: K.glassBorder),
          gradient: RadialGradient(
            center: const Alignment(0, -0.2),
            radius: 0.95,
            colors: [
              K.primarySoft,
              Color.lerp(K.primarySoft, K.surface, 0.6)!,
              K.surface,
            ],
            stops: const [0, 0.55, 1],
          ),
          boxShadow: K.lift,
        ),
        child: Stack(
          children: [
            Positioned.fill(
              top: 44,
              bottom: 52,
              child: FootTwin(
                side: _side,
                view: _view,
                src: _mine[_side],
                alt: S.t(lang, 'twin.title'),
                zoneLabel: (z) => S.t(lang, 'zone.$z'),
              ),
            ),
            PositionedDirectional(
              start: 14,
              top: 14,
              child: _Pill(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: K.glow,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                              color: K.glow.withAlpha(70), spreadRadius: 4),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(S.t(lang, 'twin.title'),
                        style: K.label.copyWith(
                            color: K.primary, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
            PositionedDirectional(
              end: 12,
              top: 10,
              child: _Segmented(
                options: [S.t(lang, 'twin.left'), S.t(lang, 'twin.right')],
                selected: _side == FootSide.left ? 0 : 1,
                onSelect: (i) => setState(
                    () => _side = i == 0 ? FootSide.left : FootSide.right),
              ),
            ),
            PositionedDirectional(
              start: 16,
              end: 12,
              bottom: 12,
              child: Row(
                children: [
                  Icon(Icons.threesixty_rounded, size: 18, color: K.muted),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(S.t(lang, 'twin.hint'),
                        style: K.label, overflow: TextOverflow.ellipsis),
                  ),
                  _ViewChip(
                    label: S.t(lang, 'twin.top'),
                    selected: _view == TwinView.top,
                    onTap: () => _toggleView(TwinView.top),
                  ),
                  const SizedBox(width: 6),
                  _ViewChip(
                    label: S.t(lang, 'twin.sole'),
                    selected: _view == TwinView.sole,
                    onTap: () => _toggleView(TwinView.sole),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _Pill extends StatelessWidget {
  final Widget child;
  const _Pill({required this.child});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: K.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: K.glassBorder),
        ),
        child: child,
      );
}

class _Segmented extends StatelessWidget {
  final List<String> options;
  final int selected;
  final ValueChanged<int> onSelect;

  const _Segmented(
      {required this.options, required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: K.surfaceMuted,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < options.length; i++)
            Semantics(
              button: true,
              selected: i == selected,
              child: GestureDetector(
                onTap: () => onSelect(i),
                child: AnimatedContainer(
                  duration: KMotion.standard,
                  constraints: const BoxConstraints(minHeight: 38),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: i == selected ? K.surface : Colors.transparent,
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: i == selected
                        ? [
                            BoxShadow(
                                color: Colors.black.withAlpha(18),
                                blurRadius: 4,
                                offset: const Offset(0, 1)),
                          ]
                        : const [],
                  ),
                  child: Text(
                    options[i],
                    style: K.label.copyWith(
                      color: i == selected ? K.ink : K.muted,
                      fontWeight:
                          i == selected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ViewChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ViewChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onTap,
          child: AnimatedContainer(
            duration: KMotion.standard,
            constraints: const BoxConstraints(minHeight: 38),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: selected ? K.primary : K.surface,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: selected ? K.primary : K.glassBorder),
            ),
            child: Text(
              label,
              style: K.label.copyWith(
                color: selected ? K.onPrimary : K.ink,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- daily check

class _CheckCard extends StatelessWidget {
  final String lang;
  final bool done;
  final int streak;
  final int photos;
  final VoidCallback onStart;
  final VoidCallback? onSeeResult;

  const _CheckCard({
    required this.lang,
    required this.done,
    required this.streak,
    required this.photos,
    required this.onStart,
    required this.onSeeResult,
  });

  @override
  Widget build(BuildContext context) {
    final sub = done
        ? S.t(lang, 'home.nextTomorrow')
        : '${photos.clamp(0, 4)} ${S.t(lang, 'today.photosOf')}';
    return KCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: done ? K.okSoft : K.primarySoft,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  done ? Icons.check_rounded : Icons.photo_camera_outlined,
                  color: done ? K.ok : K.primary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(S.t(lang, 'home.todayTitle'), style: K.h2),
                    const SizedBox(height: 2),
                    Text(sub, style: K.small),
                  ],
                ),
              ),
              if (streak > 0)
                KTag(
                  '$streak ${S.t(lang, 'home.streak')}',
                  icon: Icons.local_fire_department_outlined,
                  color: K.primaryStrong,
                  background: K.primarySoft,
                ),
            ],
          ),
          const SizedBox(height: 14),
          if (done)
            FilledButton.tonalIcon(
              onPressed: onSeeResult,
              style: FilledButton.styleFrom(
                backgroundColor: K.primarySoft,
                foregroundColor: K.primaryStrong,
                minimumSize: const Size.fromHeight(52),
              ),
              icon: const Icon(Icons.description_outlined, size: 21),
              label: Text(S.t(lang, 'home.seeToday')),
            )
          else
            FilledButton.icon(
              onPressed: onStart,
              style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52)),
              icon: const Icon(Icons.photo_camera_outlined, size: 21),
              label: Text(S.t(lang, 'home.start')),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------- tiles

class _Tiles extends StatelessWidget {
  final String lang;
  final bool checkDone;
  final VoidCallback onGlucose;

  const _Tiles(
      {required this.lang, required this.checkDone, required this.onGlucose});

  @override
  Widget build(BuildContext context) {
    final store = RoutineStore.instance;
    final doneSet = {...store.done, if (checkDone) 'check'};
    final count = RoutineStore.steps.where(doneSet.contains).length;
    final total = RoutineStore.steps.length;

    final readings = KhatwaStore.instance
        .entriesOfType('glycemia')
        .where((e) => e['value'] != null)
        .toList()
      ..sort((a, b) => '${b['date']}'.compareTo('${a['date']}'));
    final latest = readings.isEmpty ? null : readings.first;
    final date = latest == null ? null : DateTime.tryParse('${latest['date']}');
    const tabular = [FontFeature.tabularFigures()];

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: KCard(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  SizedBox(
                    width: 46,
                    height: 46,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(end: total == 0 ? 0 : count / total),
                      duration: KMotion.standard,
                      builder: (context, v, _) => CircularProgressIndicator(
                        value: v,
                        strokeWidth: 5,
                        strokeCap: StrokeCap.round,
                        backgroundColor: K.surfaceMuted,
                        color: K.glow,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('$count/$total',
                            style: K.h2
                                .copyWith(fontSize: 20, fontFeatures: tabular)),
                        Text(S.t(lang, 'twin.care'),
                            style: K.label, maxLines: 2),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: KCard(
              onTap: onGlucose,
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    date == null
                        ? S.t(lang, 'today.glucose')
                        : '${S.t(lang, 'today.glucose')} · ${formatDate(date)}',
                    style: K.label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  if (latest == null)
                    Row(
                      children: [
                        Icon(Icons.add_rounded, size: 20, color: K.primary),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(S.t(lang, 'today.glucose.add'),
                              style: K.bodyStrong.copyWith(color: K.primary)),
                        ),
                      ],
                    )
                  else
                    Text.rich(
                      TextSpan(children: [
                        TextSpan(
                            text: '${latest['value']} ',
                            style: K.h2
                                .copyWith(fontSize: 20, fontFeatures: tabular)),
                        TextSpan(
                            text: '${latest['unit'] ?? 'mg/dL'}',
                            style: K.label),
                      ]),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------- routine

class _Routine extends StatelessWidget {
  final String lang;
  final bool checkDone;
  final ValueChanged<String> onOpen;

  const _Routine(
      {required this.lang, required this.checkDone, required this.onOpen});

  static const _articles = {
    'check': 'howto-check',
    'wash': 'wash',
    'dry': 'dry',
    'cream': 'moisturise',
    'shoes': 'socks-shoes',
  };

  static const _icons = {
    'check': Icons.search_rounded,
    'wash': Icons.water_rounded,
    'dry': Icons.dry_outlined,
    'cream': Icons.opacity_rounded,
    'shoes': Icons.checkroom_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final store = RoutineStore.instance;
    final doneSet = {...store.done, if (checkDone) 'check'};
    final count = RoutineStore.steps.where(doneSet.contains).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        KSectionLabel(
          S.t(lang, 'today.care'),
          trailing: Text(
            '$count / ${RoutineStore.steps.length}',
            style: K.label.copyWith(
              color: K.primaryStrong,
              fontWeight: FontWeight.w600,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
        KGroup(
          children: [
            for (final step in RoutineStore.steps)
              _RoutineRow(
                title: S.t(lang, 'today.care.$step'),
                icon: _icons[step]!,
                done: doneSet.contains(step),
                locked: step == 'check',
                doneLabel: S.t(lang, 'today.care.done'),
                onToggle: step == 'check' ? null : () => store.toggle(step),
                onOpen: () => onOpen(_articles[step]!),
              ),
          ],
        ),
      ],
    );
  }
}

class _RoutineRow extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool done;
  final bool locked;
  final String doneLabel;
  final VoidCallback? onToggle;
  final VoidCallback onOpen;

  const _RoutineRow({
    required this.title,
    required this.icon,
    required this.done,
    required this.locked,
    required this.doneLabel,
    required this.onToggle,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 66),
      child: Row(
        children: [
          Semantics(
            button: onToggle != null,
            checked: done,
            label: '$title, $doneLabel',
            child: InkResponse(
              onTap: onToggle,
              radius: 30,
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(14, 10, 10, 10),
                child: AnimatedContainer(
                  duration: KMotion.standard,
                  curve: KMotion.emphasized,
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: done ? K.primary : Colors.transparent,
                    border: Border.all(
                        color: done ? K.primary : K.control, width: 2),
                  ),
                  child: AnimatedSwitcher(
                    duration: KMotion.standard,
                    transitionBuilder: (child, animation) =>
                        ScaleTransition(scale: animation, child: child),
                    child: done
                        ? Icon(Icons.check_rounded,
                            key: const ValueKey('on'),
                            size: 20,
                            color: K.onPrimary)
                        : const SizedBox(key: ValueKey('off')),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: onOpen,
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(2, 18, 12, 18),
                  child: Row(
                    children: [
                      Expanded(
                        child: AnimatedDefaultTextStyle(
                          duration: KMotion.standard,
                          style: K.bodyStrong
                              .copyWith(color: done ? K.muted : K.ink),
                          child: Text(title),
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded,
                          color: K.muted, size: 22),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------- tip

class _TipCard extends StatelessWidget {
  final LearnArticle article;
  final String lang;
  final VoidCallback onTap;

  const _TipCard(
      {required this.article, required this.lang, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return KCard(
      onTap: onTap,
      padding: const EdgeInsets.all(18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ArticleArt(article: article, size: 64),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(article.title.of(lang), style: K.h2),
                const SizedBox(height: 4),
                Text(article.summary.of(lang), style: K.body),
                const SizedBox(height: 10),
                Text(
                  LearnLabels.readMore.of(lang),
                  style: K.bodyStrong.copyWith(color: K.primary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
