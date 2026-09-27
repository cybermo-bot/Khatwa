import 'dart:async';

import 'package:flutter/material.dart';

import '../data/demo_repository.dart';
import '../data/doctor_repository.dart';
import '../data/models.dart';
import '../ui/style.dart';
import 'fhir_export.dart';
import 'patient_view.dart';
import 'public_health.dart';
import 'scope.dart';
import 'triage_board.dart';

/// Doctor dashboard v2: triage board, patient view and public health view.
/// Three panes from 1100 px wide, two on a tablet, one on a phone.
class DoctorDashboard extends StatefulWidget {
  /// Null: a [DemoDoctorRepository] owned by the dashboard.
  final DoctorRepository? repository;
  final bool clinician;
  final bool enable3d;
  final String? subtitle;
  /// Extra buttons for the top bar (settings, sign out...).
  final List<Widget> actions;
  final void Function(BuildContext context, Patient patient)? onExportFhir;
  final bool startDark;
  /// Fixes "today" for the KPIs (tests).
  final DateTime? today;

  const DoctorDashboard({
    super.key,
    this.repository,
    this.clinician = true,
    this.enable3d = true,
    this.subtitle,
    this.actions = const [],
    this.onExportFhir,
    this.startDark = true,
    this.today,
  });

  @override
  State<DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {
  late DoctorRepository repo;
  bool _ownsRepo = false;
  final board = ValueNotifier(const BoardData());
  final _subs = <StreamSubscription<Object?>>[];
  Set<String>? _knownAlerts;
  final fresh = <String>{};
  String? selectedId;
  int tab = 0;
  late bool dark = widget.startDark;

  @override
  void initState() {
    super.initState();
    _ownsRepo = widget.repository == null;
    repo = widget.repository ?? DemoDoctorRepository();
    _listen();
  }

  void _listen() {
    _subs.addAll([
      repo.patients().listen((v) => _update(board.value.copyWith(patients: v))),
      repo.alerts().listen((v) {
        final ids = {for (final a in v) a.id};
        if (_knownAlerts == null) {
          _knownAlerts = ids;
        } else {
          fresh.addAll(ids.difference(_knownAlerts!));
          _knownAlerts = ids;
        }
        _update(board.value.copyWith(alerts: v));
      }),
      repo.findings().listen((v) => _update(board.value.copyWith(findings: v))),
      repo.checks().listen((v) => _update(board.value.copyWith(checks: v))),
    ]);
  }

  void _update(BoardData data) {
    board.value = data;
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    for (final s in _subs) {
      s.cancel();
    }
    board.dispose();
    if (_ownsRepo) repo.dispose();
    super.dispose();
  }

  void _select(Patient patient, {required bool push}) {
    setState(() {
      selectedId = patient.id;
      // Opening a patient calms its pulse.
      fresh.removeWhere((id) => board.value.alerts.any((a) => a.id == id && a.patientId == patient.id));
    });
    if (!push) return;
    final theme = (dark ? DPalette.dark : DPalette.light).theme();
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => Theme(
        data: theme,
        child: _scope(
          ValueListenableBuilder<BoardData>(
            valueListenable: board,
            builder: (context, data, _) {
              final current = data.patients.where((p) => p.id == patient.id).firstOrNull ?? patient;
              return Scaffold(
                backgroundColor: Colors.transparent,
                appBar: AppBar(
                  backgroundColor: DPalette.of(context).groundDeep,
                  foregroundColor: DPalette.of(context).ink,
                  title: Text(current.displayName),
                ),
                body: DBackground(child: PatientView(patient: current, data: data)),
              );
            },
          ),
        ),
      ),
    ));
  }

  void _export(BuildContext context, Patient patient) {
    final export = widget.onExportFhir;
    if (export != null) {
      export(context, patient);
    } else {
      showFhirExport(context, repo, patient);
    }
  }

  Widget _scope(Widget child) => DoctorScope(
        repository: repo,
        clinician: widget.clinician,
        enable3d: widget.enable3d,
        onExportFhir: _export,
        child: child,
      );

  @override
  Widget build(BuildContext context) {
    final palette = dark ? DPalette.dark : DPalette.light;
    return Theme(
      data: palette.theme(),
      child: _scope(
        Builder(builder: (context) {
          final p = DPalette.of(context);
          return Scaffold(
            backgroundColor: p.groundDeep,
            body: DBackground(
              child: SafeArea(
                child: LayoutBuilder(builder: (context, box) {
                  final width = box.maxWidth;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _TopBar(
                        subtitle: widget.subtitle,
                        tab: tab,
                        onTab: (t) => setState(() => tab = t),
                        dark: dark,
                        onDark: (v) => setState(() => dark = v),
                        repository: repo,
                        actions: widget.actions,
                        compact: width < 1100,
                      ),
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: dMotion,
                          child: tab == 1
                              ? const PublicHealthView(key: ValueKey('public'))
                              : KeyedSubtree(key: const ValueKey('triage'), child: _triage(width)),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _triage(double width) {
    final data = board.value;
    final panes = width >= 1100 ? 3 : (width >= 700 ? 2 : 1);
    Patient? selected = data.patients.where((p) => p.id == selectedId).firstOrNull;
    if (selected == null && panes > 1 && data.patients.isNotEmpty) {
      selected = data.sorted(data.patients).first;
    }
    final list = TriageBoard(
      data: data,
      selectedId: panes > 1 ? selected?.id : null,
      freshAlertIds: fresh,
      today: widget.today,
      onSelect: (p) => _select(p, push: panes == 1),
    );
    if (panes == 1) return list;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: panes == 3 ? 420 : 340, child: list),
        Expanded(
          child: selected == null
              ? const SizedBox.shrink()
              : PatientView(
                  key: ValueKey(selected.id),
                  patient: selected,
                  data: data,
                  columns: panes == 3 ? 2 : 1,
                ),
        ),
      ],
    );
  }
}

class _TopBar extends StatelessWidget {
  final String? subtitle;
  final int tab;
  final ValueChanged<int> onTab;
  final bool dark;
  final ValueChanged<bool> onDark;
  final DoctorRepository repository;
  final List<Widget> actions;
  final bool compact;

  const _TopBar({
    required this.subtitle,
    required this.tab,
    required this.onTab,
    required this.dark,
    required this.onDark,
    required this.repository,
    required this.actions,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    final p = DPalette.of(context);
    final demo = repository is DemoDoctorRepository ? repository as DemoDoctorRepository : null;
    final tabs = SegmentedButton<int>(
      showSelectedIcon: false,
      segments: const [
        ButtonSegment(value: 0, icon: Icon(Icons.monitor_heart_outlined, size: 18), label: Text('Triage')),
        ButtonSegment(value: 1, icon: Icon(Icons.public_rounded, size: 18), label: Text('Santé publique')),
      ],
      selected: {tab},
      onSelectionChanged: (s) => onTab(s.first),
    );
    final tools = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (demo != null)
          ValueListenableBuilder<bool>(
            valueListenable: demo.liveDemo,
            builder: (context, live, _) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (live) LivePulse(color: p.glow, size: 8),
                Text('Démo live', style: DText.small(p).copyWith(color: p.inkSoft)),
                Switch(value: live, onChanged: demo.setLiveDemo),
              ],
            ),
          ),
        IconButton(
          tooltip: dark ? 'Thème clair' : 'Thème sombre',
          icon: Icon(dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined, color: p.inkSoft),
          onPressed: () => onDark(!dark),
        ),
        ...actions,
      ],
    );
    final title = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Tableau de bord clinique', style: DText.title(p)),
        if (subtitle != null) Text(subtitle!, style: DText.small(p), maxLines: 1, overflow: TextOverflow.ellipsis),
      ],
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
      child: IconTheme(
        data: IconThemeData(color: p.inkSoft),
        child: compact
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(children: [Expanded(child: title), ...actions]),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(children: [
                      tabs,
                      const SizedBox(width: 8),
                      tools.children.length > actions.length
                          ? Row(mainAxisSize: MainAxisSize.min, children: tools.children.take(tools.children.length - actions.length).toList())
                          : const SizedBox.shrink(),
                    ]),
                  ),
                ],
              )
            : Row(
                children: [
                  Expanded(child: title),
                  tabs,
                  const SizedBox(width: 12),
                  tools,
                ],
              ),
      ),
    );
  }
}
