import 'package:flutter/material.dart';

import '../../data/auth_store.dart';
import '../../data/case_store.dart';
import '../../data/khatwa_store.dart';
import '../../ui/app_state.dart';
import '../../ui/app_theme.dart';
import '../../ui/strings.dart';
import '../glycemia.dart';
import '../patient_home.dart';
import '../report_view.dart';
import '../shell.dart';

/// What a patient can log about their feet on a given day. The two red flags
/// prompt a foot check the same day.
const kSymptoms = [
  'pain',
  'tingling',
  'numbness',
  'swelling',
  'newMark',
  'rubbing',
  'cold',
  'itching'
];
const kRedFlags = {'swelling', 'newMark'};

class JournalTab extends StatefulWidget {
  const JournalTab({super.key});

  @override
  State<JournalTab> createState() => _JournalTabState();
}

class _JournalTabState extends State<JournalTab> {
  late final DateTime _thisMonth =
      DateTime(DateTime.now().year, DateTime.now().month);
  late DateTime _month = _thisMonth;
  late DateTime _selected = _dayOf(DateTime.now());

  static DateTime _dayOf(DateTime d) => DateTime(d.year, d.month, d.day);

  void _shiftMonth(int delta) {
    final next = DateTime(_month.year, _month.month + delta);
    if (next.isAfter(_thisMonth)) return;
    setState(() => _month = next);
  }

  Future<void> _openLog() async {
    final lang = appLanguage.value;
    final saved = await showModalBottomSheet<Set<String>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: K.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(K.r28)),
      ),
      builder: (_) => _LogSheet(lang: lang),
    );
    if (!mounted || saved == null) return;
    setState(() {
      _month = _thisMonth;
      _selected = _dayOf(DateTime.now());
    });
    final flagged = saved.any(kRedFlags.contains);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: flagged ? 8 : 3),
        content: Text(
            flagged ? S.t(lang, 'journal.flag') : S.t(lang, 'journal.saved')),
        action: flagged
            ? SnackBarAction(
                label: S.t(lang, 'journal.checkNow'),
                onPressed: () => AppShell.goTo(context, 1),
              )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = appLanguage.value;
    final patientId = AuthStore.instance.current?.id ?? '';

    return AnimatedBuilder(
      animation: Listenable.merge([CaseStore.instance, KhatwaStore.instance]),
      builder: (context, _) {
        final cases = CaseStore.instance.forPatient(patientId);
        List<Map<String, dynamic>> dated(String type) => KhatwaStore.instance
            .entriesOfType(type)
            .where((e) => DateTime.tryParse('${e['date']}') != null)
            .toList();
        final glucose =
            dated('glycemia').where((e) => e['value'] != null).toList();
        final logs = dated('daylog');

        final casesByDay = <DateTime, List<FootCase>>{};
        for (final c in cases) {
          casesByDay.putIfAbsent(_dayOf(c.date), () => []).add(c);
        }
        Map<DateTime, List<Map<String, dynamic>>> byDay(
            List<Map<String, dynamic>> list) {
          final map = <DateTime, List<Map<String, dynamic>>>{};
          for (final e in list) {
            map
                .putIfAbsent(_dayOf(DateTime.parse('${e['date']}')), () => [])
                .add(e);
          }
          return map;
        }

        final glucoseByDay = byDay(glucose);
        final logsByDay = byDay(logs);

        final dayCases = casesByDay[_selected] ?? const <FootCase>[];
        final dayGlucose = [...?glucoseByDay[_selected]]
          ..sort((a, b) => '${b['date']}'.compareTo('${a['date']}'));
        final dayLogs = [...?logsByDay[_selected]]
          ..sort((a, b) => '${b['date']}'.compareTo('${a['date']}'));
        final empty = dayCases.isEmpty && dayGlucose.isEmpty && dayLogs.isEmpty;

        return KPage(
          title: S.t(lang, 'tab.journal'),
          showBack: false,
          fab: FloatingActionButton.extended(
            onPressed: _openLog,
            backgroundColor: K.primary,
            foregroundColor: K.onPrimary,
            elevation: 2,
            icon: const Icon(Icons.edit_note_rounded),
            label: Text(
              S.t(lang, 'journal.log'),
              style: const TextStyle(
                  fontFamily: K.family,
                  fontSize: 16,
                  fontWeight: FontWeight.w600),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              GlassCard(
                radius: K.r28,
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
                child: _MonthGrid(
                  month: _month,
                  canGoNext: _month.isBefore(_thisMonth),
                  selected: _selected,
                  lang: lang,
                  casesByDay: casesByDay,
                  glucoseDays: glucoseByDay.keys.toSet(),
                  logDays: logsByDay.keys.toSet(),
                  onPrev: () => _shiftMonth(-1),
                  onNext: () => _shiftMonth(1),
                  onSelect: (d) => setState(() => _selected = d),
                ),
              ),
              const SizedBox(height: 26),
              KSectionLabel(_longDate(lang, _selected)),
              AnimatedSwitcher(
                duration: KMotion.standard,
                switchInCurve: KMotion.emphasized,
                child: KeyedSubtree(
                  key: ValueKey(_selected),
                  child: empty
                      ? KCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.event_note_outlined,
                                      color: K.muted),
                                  const SizedBox(width: 14),
                                  Expanded(
                                      child: Text(S.t(lang, 'journal.empty'),
                                          style: K.body)),
                                ],
                              ),
                            ],
                          ),
                        )
                      : KGroup(children: [
                          for (final l in dayLogs)
                            _LogRow(entry: l, lang: lang),
                          for (final c in dayCases)
                            KGroupRow(
                              icon: levelIcon(c.triage.level),
                              tint: levelColor(c.triage.level),
                              title: levelHeadline(lang, c.triage.level),
                              subtitle:
                                  '${S.t(lang, 'journal.check')}, ${_time(c.date)}',
                              onTap: () =>
                                  Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) =>
                                    ReportPage(caseId: c.id, language: lang),
                              )),
                            ),
                          for (final g in dayGlucose)
                            KGroupRow(
                              icon: Icons.water_drop_outlined,
                              title: '${g['value']} ${g['unit'] ?? 'mg/dL'}',
                              subtitle:
                                  '${S.t(lang, 'journal.glucose')}, ${_time(DateTime.parse('${g['date']}'))}',
                              onTap: () =>
                                  Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => GlycemiaPage(language: lang),
                              )),
                            ),
                        ]),
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        );
      },
    );
  }

  String _longDate(String lang, DateTime d) {
    final names = S.t(lang, 'week.names').split(',');
    final day = names.length == 7 ? names[d.weekday - 1] : '';
    return '$day ${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }
}

String _time(DateTime d) =>
    '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

class _LogRow extends StatelessWidget {
  final Map<String, dynamic> entry;
  final String lang;

  const _LogRow({required this.entry, required this.lang});

  @override
  Widget build(BuildContext context) {
    final symptoms = [
      for (final s in (entry['symptoms'] as List? ?? const [])) '$s'
    ];
    final flagged = symptoms.any(kRedFlags.contains);
    final note = '${entry['note'] ?? ''}'.trim();
    final title = symptoms.isEmpty
        ? S.t(lang, 'journal.none')
        : symptoms.map((s) => S.t(lang, 'sym.$s')).join(', ');
    final time = _time(DateTime.parse('${entry['date']}'));
    return KGroupRow(
      icon: flagged ? Icons.priority_high_rounded : Icons.edit_note_rounded,
      tint: flagged ? K.warn : K.primary,
      title: title,
      subtitle: note.isEmpty ? time : '$time, $note',
      trailing: flagged
          ? TextButton(
              onPressed: () => AppShell.goTo(context, 1),
              child: Text(S.t(lang, 'journal.checkNow')),
            )
          : null,
    );
  }
}

class _LogSheet extends StatefulWidget {
  final String lang;
  const _LogSheet({required this.lang});

  @override
  State<_LogSheet> createState() => _LogSheetState();
}

class _LogSheetState extends State<_LogSheet> {
  final Set<String> _picked = {};
  bool _nothing = false;
  final _note = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _note.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await KhatwaStore.instance.addEntry({
      'type': 'daylog',
      'date': DateTime.now().toIso8601String(),
      'symptoms': _picked.toList(),
      'note': _note.text.trim(),
    });
    if (mounted) Navigator.of(context).pop(Set<String>.from(_picked));
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.lang;
    final canSave =
        (_picked.isNotEmpty || _nothing || _note.text.trim().isNotEmpty) &&
            !_saving;

    Widget chip(String label, bool selected, VoidCallback onTap) => FilterChip(
          label: Text(label),
          selected: selected,
          onSelected: (_) => onTap(),
          showCheckmark: true,
          labelStyle: TextStyle(
            fontFamily: K.family,
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: selected ? K.primaryStrong : K.ink,
          ),
          backgroundColor: K.surface,
          selectedColor: K.primarySoft,
          checkmarkColor: K.primaryStrong,
          side: BorderSide(
              color: selected ? K.primary : K.control,
              width: selected ? 1.6 : 1.2),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        );

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 0, 22, 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(S.t(lang, 'journal.logTitle'), style: K.h1),
            const SizedBox(height: 4),
            Text(S.t(lang, 'journal.logHint'), style: K.body),
            const SizedBox(height: 18),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final s in kSymptoms)
                  chip(S.t(lang, 'sym.$s'), _picked.contains(s), () {
                    setState(() {
                      _nothing = false;
                      if (!_picked.remove(s)) _picked.add(s);
                    });
                  }),
                chip(S.t(lang, 'journal.none'), _nothing, () {
                  setState(() {
                    _nothing = !_nothing;
                    if (_nothing) _picked.clear();
                  });
                }),
              ],
            ),
            if (_picked.any(kRedFlags.contains)) ...[
              const SizedBox(height: 16),
              KBanner(
                text: S.t(lang, 'journal.flag'),
                icon: Icons.priority_high_rounded,
                color: K.warn,
                background: K.warnSoft,
              ),
            ],
            const SizedBox(height: 20),
            KField(
              label: S.t(lang, 'journal.note'),
              controller: _note,
              maxLines: 3,
            ),
            OutlinedButton.icon(
              onPressed: () {
                final navigator = Navigator.of(context);
                navigator.pop();
                navigator.push(MaterialPageRoute(
                    builder: (_) => GlycemiaPage(language: lang)));
              },
              icon: const Icon(Icons.water_drop_outlined),
              label: Text(S.t(lang, 'today.glucose.add')),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: canSave ? _save : null,
              child: Text(S.t(lang, 'common.save')),
            ),
          ],
        ),
      ),
    );
  }
}

String _monthTitle(String lang, DateTime month) {
  final names = S.t(lang, 'month.names').split(',');
  final name = names.length == 12 ? names[month.month - 1] : '${month.month}';
  return '$name ${month.year}';
}

class _MonthGrid extends StatelessWidget {
  final DateTime month;
  final bool canGoNext;
  final DateTime selected;
  final String lang;
  final Map<DateTime, List<FootCase>> casesByDay;
  final Set<DateTime> glucoseDays;
  final Set<DateTime> logDays;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final ValueChanged<DateTime> onSelect;

  const _MonthGrid({
    required this.month,
    required this.canGoNext,
    required this.selected,
    required this.lang,
    required this.casesByDay,
    required this.glucoseDays,
    required this.logDays,
    required this.onPrev,
    required this.onNext,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final initials = S.t(lang, 'week.initials').split(',');
    final first = DateTime(month.year, month.month);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final lead = first.weekday - 1; // Monday first
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    Widget marks(DateTime day) {
      final dayCases = casesByDay[day];
      final items = <Widget>[
        if (dayCases != null)
          _Mark.check(levelColor(dayCases.first.triage.level)),
        if (glucoseDays.contains(day)) _Mark.glucose(K.primary),
        if (logDays.contains(day)) _Mark.log(K.primary),
      ];
      return SizedBox(
        height: 8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < items.length; i++) ...[
              if (i > 0) const SizedBox(width: 3),
              items[i],
            ],
          ],
        ),
      );
    }

    final cells = <Widget>[
      for (var i = 0; i < lead; i++) const SizedBox.shrink(),
      for (var d = 1; d <= daysInMonth; d++)
        Builder(builder: (context) {
          final day = DateTime(month.year, month.month, d);
          final isSelected = day == selected;
          final isToday = day == today;
          final future = day.isAfter(today);
          return Semantics(
            button: !future,
            selected: isSelected,
            label: '$d',
            child: InkResponse(
              onTap: future ? null : () => onSelect(day),
              radius: 26,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: KMotion.standard,
                    curve: KMotion.emphasized,
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? K.primary : Colors.transparent,
                      border: isToday && !isSelected
                          ? Border.all(color: K.primary, width: 2)
                          : null,
                    ),
                    child: Text(
                      '$d',
                      style: K.bodyStrong.copyWith(
                        fontSize: 16,
                        color: isSelected
                            ? K.onPrimary
                            : future
                                ? K.muted.withAlpha(120)
                                : K.ink,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                  const SizedBox(height: 3),
                  marks(day),
                ],
              ),
            ),
          );
        }),
    ];

    return Column(
      children: [
        Row(
          children: [
            IconButton(
              onPressed: onPrev,
              tooltip: MaterialLocalizations.of(context).previousMonthTooltip,
              icon: const Icon(Icons.chevron_left_rounded),
            ),
            Expanded(
              child: Text(
                _monthTitle(lang, month),
                textAlign: TextAlign.center,
                style: K.h2.copyWith(
                    fontFeatures: const [FontFeature.tabularFigures()]),
              ),
            ),
            IconButton(
              onPressed: canGoNext ? onNext : null,
              tooltip: MaterialLocalizations.of(context).nextMonthTooltip,
              icon: const Icon(Icons.chevron_right_rounded),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            for (final i in initials)
              Expanded(
                child: Text(i, textAlign: TextAlign.center, style: K.label),
              ),
          ],
        ),
        const SizedBox(height: 8),
        GridView.count(
          crossAxisCount: 7,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 0.82,
          children: cells,
        ),
        const SizedBox(height: 6),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 18,
          runSpacing: 6,
          children: [
            _Legend(mark: _Mark.check(K.ok), label: S.t(lang, 'journal.check')),
            _Legend(
                mark: _Mark.glucose(K.primary),
                label: S.t(lang, 'journal.glucose')),
            _Legend(
                mark: _Mark.log(K.primary),
                label: S.t(lang, 'journal.logShort')),
          ],
        ),
      ],
    );
  }
}

class _Mark extends StatelessWidget {
  final Color color;
  final int shape; // 0 dot, 1 ring, 2 square

  const _Mark._(this.color, this.shape);
  factory _Mark.check(Color c) => _Mark._(c, 0);
  factory _Mark.glucose(Color c) => _Mark._(c, 1);
  factory _Mark.log(Color c) => _Mark._(c, 2);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(
        shape: shape == 2 ? BoxShape.rectangle : BoxShape.circle,
        borderRadius: shape == 2 ? BorderRadius.circular(1.5) : null,
        color: shape == 1 ? null : color,
        border: shape == 1 ? Border.all(color: color, width: 1.6) : null,
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Widget mark;
  final String label;
  const _Legend({required this.mark, required this.label});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          mark,
          const SizedBox(width: 6),
          Flexible(child: Text(label, style: K.label)),
        ],
      );
}
