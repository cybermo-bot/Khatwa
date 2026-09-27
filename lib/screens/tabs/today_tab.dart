import 'package:flutter/material.dart';

import '../../data/auth_store.dart';
import '../../data/case_store.dart';
import '../../data/khatwa_store.dart';
import '../../data/learn_content.dart';
import '../../data/routine_store.dart';
import '../../ui/app_state.dart';
import '../../ui/app_theme.dart';
import '../../ui/foot_art.dart';
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
        final name = _firstName(account?.name ?? '');
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
              const SizedBox(height: 10),
              KReveal(
                child: _CheckPanel(
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
              const SizedBox(height: 30),
              KSectionLabel(S.t(lang, 'today.glucose')),
              _GlucoseRow(
                  lang: lang, onAdd: () => _open(GlycemiaPage(language: lang))),
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

// ---------------------------------------------------------------- check panel

class _CheckPanel extends StatefulWidget {
  final String lang;
  final bool done;
  final int streak;
  final int photos;
  final VoidCallback onStart;
  final VoidCallback? onSeeResult;

  const _CheckPanel({
    required this.lang,
    required this.done,
    required this.streak,
    required this.photos,
    required this.onStart,
    required this.onSeeResult,
  });

  @override
  State<_CheckPanel> createState() => _CheckPanelState();
}

class _CheckPanelState extends State<_CheckPanel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 2200));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(covariant _CheckPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  void _sync() {
    final run = !widget.done && !KMotion.reduced(context);
    if (run && !_pulse.isAnimating) {
      _pulse.repeat(reverse: true);
    } else if (!run && _pulse.isAnimating) {
      _pulse.stop();
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.lang;
    final done = widget.done;
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
      decoration: BoxDecoration(
        color: K.primarySoft,
        borderRadius: BorderRadius.circular(K.r28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  S.t(lang, 'home.todayTitle'),
                  style: K.h1.copyWith(color: K.primaryStrong),
                ),
              ),
              if (widget.streak > 0)
                KTag(
                  '${widget.streak} ${S.t(lang, 'home.streak')}',
                  icon: Icons.event_available_rounded,
                  color: K.primaryStrong,
                  background: K.surface,
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            done ? S.t(lang, 'home.nextTomorrow') : S.t(lang, 'home.todaySub'),
            style: K.body.copyWith(color: K.primaryStrong),
          ),
          const SizedBox(height: 18),
          AnimatedBuilder(
            animation: _pulse,
            builder: (context, _) => PhotoPositions(
              taken: widget.photos.clamp(0, 4),
              showNext: !done,
              pulse: Curves.easeInOut.transform(_pulse.value),
              ground: K.primarySoft,
              labels: [
                for (final key in const [
                  'check.rightSole',
                  'check.leftSole',
                  'check.rightTop',
                  'check.leftTop'
                ])
                  S.t(lang, key),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: Text(
              '${widget.photos.clamp(0, 4)} ${S.t(lang, 'today.photosOf')}',
              style: K.label.copyWith(color: K.primaryStrong),
            ),
          ),
          const SizedBox(height: 16),
          if (done)
            FilledButton.tonalIcon(
              onPressed: widget.onSeeResult,
              style: FilledButton.styleFrom(
                backgroundColor: K.surface,
                foregroundColor: K.primaryStrong,
                minimumSize: const Size.fromHeight(56),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18)),
              ),
              icon: const Icon(Icons.description_outlined, size: 21),
              label: Text(S.t(lang, 'home.seeToday')),
            )
          else
            FilledButton.icon(
              onPressed: widget.onStart,
              icon: const Icon(Icons.photo_camera_outlined, size: 22),
              label: Text(S.t(lang, 'home.start')),
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
                    border:
                        Border.all(color: done ? K.primary : K.control, width: 2),
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

// ---------------------------------------------------------------- tip and glucose

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

class _GlucoseRow extends StatelessWidget {
  final String lang;
  final VoidCallback onAdd;

  const _GlucoseRow({required this.lang, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final readings = KhatwaStore.instance
        .entriesOfType('glycemia')
        .where((e) => e['value'] != null)
        .toList()
      ..sort((a, b) => '${b['date']}'.compareTo('${a['date']}'));
    final latest = readings.isEmpty ? null : readings.first;
    final date = latest == null ? null : DateTime.tryParse('${latest['date']}');

    return KCard(
      padding: const EdgeInsets.fromLTRB(20, 18, 14, 18),
      child: Row(
        children: [
          Expanded(
            child: latest == null
                ? Text(S.t(lang, 'today.glucose.none'), style: K.body)
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '${latest['value']}',
                            style: K.display.copyWith(
                              fontFeatures: const [
                                FontFeature.tabularFigures()
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text('${latest['unit'] ?? 'mg/dL'}', style: K.small),
                        ],
                      ),
                      if (date != null) Text(formatDate(date), style: K.small),
                    ],
                  ),
          ),
          TextButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded),
            label: Text(S.t(lang, 'today.glucose.add')),
          ),
        ],
      ),
    );
  }
}
