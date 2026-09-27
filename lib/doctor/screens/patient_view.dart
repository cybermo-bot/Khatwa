import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../data/doctor_repository.dart';
import '../data/models.dart';
import '../ui/foot_view.dart';
import '../ui/labels.dart';
import '../ui/style.dart';
import 'scope.dart';

/// Everything about one patient. [columns] 2 splits it for the three pane
/// layout; 1 is a single scroll.
class PatientView extends StatefulWidget {
  final Patient patient;
  final BoardData data;
  final int columns;

  const PatientView({super.key, required this.patient, required this.data, this.columns = 1});

  @override
  State<PatientView> createState() => _PatientViewState();
}

class _PatientViewState extends State<PatientView> {
  late DoctorRepository repo;
  List<Scan>? scans;
  List<Message>? messages;
  List<Finding>? findings;
  List<Check>? checks;
  List<Share>? shares;
  final _subs = <StreamSubscription<Object?>>[];
  String? _for;

  String side = 'L';
  int? visit; // index in the scans of [side]; null = latest
  String measure = 'foot_length_mm';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _bind();
  }

  @override
  void didUpdateWidget(PatientView old) {
    super.didUpdateWidget(old);
    if (old.patient.id != widget.patient.id) {
      side = 'L';
      visit = null;
    }
    _bind();
  }

  void _bind() {
    final r = DoctorScope.of(context).repository;
    final key = '${identityHashCode(r)}|${widget.patient.id}';
    if (key == _for) return;
    _for = key;
    repo = r;
    final id = widget.patient.id;
    for (final sub in _subs) {
      sub.cancel();
    }
    _subs
      ..clear()
      ..addAll([
        repo.scans(id).listen((v) => setState(() => scans = v)),
        repo.messages(id).listen((v) => setState(() => messages = v)),
        repo.findings(patientId: id).listen((v) => setState(() => findings = v)),
        repo.checks(patientId: id).listen((v) => setState(() => checks = v)),
        repo.shares(id).listen((v) => setState(() => shares = v)),
      ]);
  }

  @override
  void dispose() {
    for (final sub in _subs) {
      sub.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final patient = widget.patient;
    final left = <Widget>[
      _Header(patient: patient, shares: shares),
      _OpenAlerts(alerts: widget.data.openAlertsOf(patient.id)),
      _twinCard(),
      _Trends(scans: scans, measure: measure, onMeasure: (m) => setState(() => measure = m)),
      _SolePhotos(scans: scans),
    ];
    final right = <Widget>[
      _Findings(findings: findings),
      _CheckHistory(checks: checks),
      _Messages(patientId: patient.id, messages: messages),
    ];
    Widget column(List<Widget> items) => ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 14),
          itemBuilder: (_, i) => items[i],
        );
    if (widget.columns >= 2) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 3, child: column(left)),
          Expanded(flex: 2, child: column(right)),
        ],
      );
    }
    return column([...left, ...right]);
  }

  Widget _twinCard() {
    final p = DPalette.of(context);
    final scope = DoctorScope.of(context);
    return _Latest<List<Scan>>(
      value: scans,
      builder: (context, scanSnap) => _Latest<List<Finding>>(
        value: findings,
        builder: (context, findSnap) {
          final ofSide = (scanSnap.data ?? const <Scan>[]).where((s) => s.side == side).toList();
          final index = ofSide.isEmpty ? null : (visit ?? ofSide.length - 1).clamp(0, ofSide.length - 1);
          final scan = index == null ? null : ofSide[index];
          final latest = index == null || index == ofSide.length - 1;
          final shown = (findSnap.data ?? const <Finding>[]).where((f) {
            if (f.side != side) return false;
            if (latest) return f.isActive;
            final at = scan!.createdAt;
            return !f.day.isAfter(DateTime(at.year, at.month, at.day));
          }).toList();
          return GlassPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DSectionTitle('Jumeau 3D', trailing: _SideToggle(
                  side: side,
                  onChanged: (s) => setState(() {
                    side = s;
                    visit = null;
                  }),
                )),
                FutureBuilder<String?>(
                  future: scan == null ? Future.value(null) : repo.glbUrl(scan),
                  builder: (context, url) => FootView(
                    side: side,
                    src: url.data,
                    enable3d: scope.enable3d,
                    pins: [
                      for (final f in shown)
                        FootPin(region: f.region, level: f.level, label: kindLabels[f.kind] ?? f.kind),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                if (ofSide.length > 1) ...[
                  Row(
                    children: [
                      Text('Visite', style: DText.small(p)),
                      Expanded(
                        child: Slider(
                          min: 0,
                          max: (ofSide.length - 1).toDouble(),
                          divisions: ofSide.length - 1,
                          value: index!.toDouble(),
                          label: shortDate(scan!.createdAt),
                          onChanged: (v) => setState(() => visit = v.round()),
                        ),
                      ),
                      Text(shortDate(scan.createdAt), style: DText.small(p)),
                    ],
                  ),
                ] else
                  Text(
                    scan == null ? 'Pas encore de scan pour ce pied : modèle de référence.' : 'Une visite : ${shortDate(scan.createdAt)}',
                    style: DText.small(p),
                  ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  children: [
                    for (final l in ['urgent', 'soon', 'none'])
                      Row(mainAxisSize: MainAxisSize.min, children: [
                        Container(width: 10, height: 10, decoration: BoxDecoration(shape: BoxShape.circle, color: p.level(l))),
                        const SizedBox(width: 6),
                        Text(findingLevelLabels[l]!, style: DText.small(p)),
                      ]),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SideToggle extends StatelessWidget {
  final String side;
  final ValueChanged<String> onChanged;

  const _SideToggle({required this.side, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<String>(
      showSelectedIcon: false,
      style: const ButtonStyle(visualDensity: VisualDensity.compact),
      segments: const [
        ButtonSegment(value: 'L', label: Text('Gauche')),
        ButtonSegment(value: 'R', label: Text('Droit')),
      ],
      selected: {side},
      onSelectionChanged: (s) => onChanged(s.first),
    );
  }
}

class _Header extends StatelessWidget {
  final Patient patient;
  final List<Share>? shares;

  const _Header({required this.patient, required this.shares});

  @override
  Widget build(BuildContext context) {
    final p = DPalette.of(context);
    final scope = DoctorScope.of(context);
    final check = patient.lastCheck;
    return GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(patient.displayName, style: DText.title(p))),
              DTag(riskLabel(patient.iwgdfRisk),
                  color: p.risk(patient.iwgdfRisk), background: p.risk(patient.iwgdfRisk).withValues(alpha: 0.14)),
            ],
          ),
          const SizedBox(height: 4),
          SelectableText(patient.ref, style: DText.small(p)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Fact(Icons.cake_outlined, '${patient.age ?? '?'} ans${patient.sex == null ? '' : ' · ${patient.sex}'}'),
              _Fact(Icons.bloodtype_outlined, typeLabel(patient.diabetesType)),
              _Fact(Icons.place_outlined, patient.governorate ?? 'Gouvernorat inconnu'),
              _Fact(Icons.fact_check_outlined,
                  check == null ? 'Pas de contrôle' : 'Dernier contrôle : ${checkLabels[check]}',
                  color: check == null ? null : p.level(check)),
              _Fact(Icons.event_outlined,
                  patient.nextVisit == null ? 'Pas de visite prévue' : 'Visite le ${shortDate(patient.nextVisit!)}'),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              OutlinedButton.icon(
                icon: const Icon(Icons.event_available_outlined, size: 18),
                label: const Text('Prochaine visite'),
                onPressed: () async {
                  final now = DateTime.now();
                  final picked = await showDatePicker(
                    context: context,
                    firstDate: now,
                    lastDate: now.add(const Duration(days: 365)),
                    initialDate: patient.nextVisit != null && patient.nextVisit!.isAfter(now)
                        ? patient.nextVisit!
                        : now.add(const Duration(days: 14)),
                    helpText: 'Prochaine visite',
                  );
                  if (picked != null) await scope.repository.setNextVisit(patient.id, picked);
                },
              ),
              FilledButton.icon(
                icon: const Icon(Icons.ios_share_rounded, size: 18),
                label: const Text('Exporter FHIR'),
                onPressed: scope.onExportFhir == null ? null : () => scope.onExportFhir!(context, patient),
              ),
              _Latest<List<Share>>(
                value: shares,
                builder: (context, snap) {
                  final validated = (snap.data ?? const <Share>[]).any((s) => (s.gazelleReport ?? '').toUpperCase().contains('PASS'));
                  return DTag(
                    validated ? 'Validé sur IHE Gazelle' : 'Validation IHE Gazelle à venir',
                    icon: validated ? Icons.verified_rounded : Icons.hourglass_empty_rounded,
                    color: validated ? p.ok : p.muted,
                    background: validated ? p.okSoft : p.glass,
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? color;

  const _Fact(this.icon, this.text, {this.color});

  @override
  Widget build(BuildContext context) {
    final p = DPalette.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: p.glass,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: p.glassBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color ?? p.muted),
          const SizedBox(width: 6),
          Flexible(child: Text(text, style: DText.small(p).copyWith(color: color ?? p.inkSoft))),
        ],
      ),
    );
  }
}

class _OpenAlerts extends StatelessWidget {
  final List<Alert> alerts;

  const _OpenAlerts({required this.alerts});

  @override
  Widget build(BuildContext context) {
    final p = DPalette.of(context);
    final repo = DoctorScope.of(context).repository;
    if (alerts.isEmpty) {
      return GlassPanel(
        padding: const EdgeInsets.all(14),
        child: Row(children: [
          Icon(Icons.check_circle_outline_rounded, color: p.ok, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text('Aucune alerte ouverte.', style: DText.body(p))),
        ]),
      );
    }
    final sorted = [...alerts]..sort((a, b) {
        final u = (a.urgent ? 0 : 1).compareTo(b.urgent ? 0 : 1);
        return u != 0 ? u : b.createdAt.compareTo(a.createdAt);
      });
    return Column(
      children: [
        for (final a in sorted)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: GlassPanel(
              padding: const EdgeInsets.all(14),
              tint: a.urgent ? p.urgentSoft : null,
              borderColor: a.urgent ? p.urgent : null,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(a.urgent ? Icons.warning_amber_rounded : Icons.notifications_none_rounded, color: p.level(a.level)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(a.title, style: DText.strong(p)),
                        if (a.body.isNotEmpty) Text(a.body, style: DText.body(p)),
                        const SizedBox(height: 4),
                        Text('${alertLevelLabels[a.level]} · ${sourceLabels[a.source] ?? a.source} · ${ago(a.createdAt)}',
                            style: DText.small(p)),
                        if (a.urgent) ...[
                          const SizedBox(height: 4),
                          Text('Signe urgent : le patient est orienté vers le 190.',
                              style: DText.small(p).copyWith(color: p.urgent, fontWeight: FontWeight.w600)),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () => repo.acknowledgeAlert(a.id),
                    child: const Text('Acquitter'),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _Trends extends StatelessWidget {
  final List<Scan>? scans;
  final String measure;
  final ValueChanged<String> onMeasure;

  const _Trends({required this.scans, required this.measure, required this.onMeasure});

  @override
  Widget build(BuildContext context) {
    final p = DPalette.of(context);
    return GlassPanel(
      child: _Latest<List<Scan>>(
        value: scans,
        builder: (context, snap) {
          final all = snap.data ?? const <Scan>[];
          final (label, unit) = measurementLabels[measure]!;
          List<FlSpot> spots(String s) {
            final list = all.where((x) => x.side == s).toList();
            return [
              for (var i = 0; i < list.length; i++)
                if (list[i].measurements[measure] != null) FlSpot(i.toDouble(), list[i].measurements[measure]!),
            ];
          }

          final left = spots('L');
          final right = spots('R');
          final values = [...left, ...right].map((s) => s.y).toList();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const DSectionTitle('Mesures'),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final e in measurementLabels.entries)
                    ChoiceChip(
                      label: Text(e.value.$1, style: const TextStyle(fontSize: 12)),
                      selected: e.key == measure,
                      onSelected: (_) => onMeasure(e.key),
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
              const SizedBox(height: 14),
              Text('$label ($unit)', style: DText.strong(p)),
              const SizedBox(height: 10),
              SizedBox(
                height: 170,
                child: values.isEmpty
                    ? Center(child: Text('Pas encore mesuré.', style: DText.small(p)))
                    : LineChart(
                        LineChartData(
                          minY: values.reduce((a, b) => a < b ? a : b) - 3,
                          maxY: values.reduce((a, b) => a > b ? a : b) + 3,
                          gridData: FlGridData(
                            drawVerticalLine: false,
                            getDrawingHorizontalLine: (_) => FlLine(color: p.glassBorder, strokeWidth: 1),
                          ),
                          borderData: FlBorderData(show: false),
                          titlesData: FlTitlesData(
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: 1,
                                getTitlesWidget: (v, _) => Text('V${v.toInt() + 1}', style: DText.small(p)),
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 44,
                                getTitlesWidget: (v, _) => Text(v.toStringAsFixed(0), style: DText.small(p)),
                              ),
                            ),
                          ),
                          lineBarsData: [
                            for (final (data, color) in [(left, p.primary), (right, p.mint)])
                              if (data.isNotEmpty)
                                LineChartBarData(
                                  spots: data,
                                  color: color,
                                  barWidth: 3,
                                  isCurved: true,
                                  preventCurveOverShooting: true,
                                  dotData: const FlDotData(show: true),
                                ),
                          ],
                        ),
                        duration: dMotion,
                      ),
              ),
              const SizedBox(height: 8),
              Wrap(spacing: 14, children: [
                _Legend(color: p.primary, text: 'Pied gauche'),
                _Legend(color: p.mint, text: 'Pied droit'),
              ]),
              const SizedBox(height: 8),
              Text('Recherche, seuils provisoires. Aucune mesure ne pose un diagnostic.',
                  style: DText.small(p).copyWith(fontStyle: FontStyle.italic)),
            ],
          );
        },
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String text;

  const _Legend({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    final p = DPalette.of(context);
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 14, height: 3, color: color),
      const SizedBox(width: 6),
      Text(text, style: DText.small(p)),
    ]);
  }
}

class _SolePhotos extends StatelessWidget {
  final List<Scan>? scans;

  const _SolePhotos({required this.scans});

  @override
  Widget build(BuildContext context) {
    final p = DPalette.of(context);
    final repo = DoctorScope.of(context).repository;
    return GlassPanel(
      child: _Latest<List<Scan>>(
        value: scans,
        builder: (context, snap) {
          final list = (snap.data ?? const <Scan>[]).reversed.toList();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const DSectionTitle('Photos de la plante'),
              if (list.isEmpty)
                Text('Pas encore de photo.', style: DText.small(p))
              else
                SizedBox(
                  height: 132,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, i) {
                      final scan = list[i];
                      final path = scan.solePhotoPath;
                      return SizedBox(
                        width: 104,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: FutureBuilder<String?>(
                                future: path == null ? Future.value(null) : repo.photoUrl(path),
                                builder: (context, url) => ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: url.data != null
                                      ? Image.network(url.data!, fit: BoxFit.cover, width: 104,
                                          errorBuilder: (_, __, ___) => const _PhotoPlaceholder(taken: true))
                                      : _PhotoPlaceholder(taken: path != null),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text('${scan.side == 'L' ? 'G' : 'D'} · ${shortDate(scan.createdAt)}', style: DText.small(p)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _PhotoPlaceholder extends StatelessWidget {
  final bool taken;

  const _PhotoPlaceholder({required this.taken});

  @override
  Widget build(BuildContext context) {
    final p = DPalette.of(context);
    return Container(
      width: 104,
      decoration: BoxDecoration(
        color: p.glass,
        border: Border.all(color: p.glassBorder),
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(taken ? Icons.photo_outlined : Icons.hide_image_outlined, color: p.muted),
          const SizedBox(height: 4),
          Text(taken ? 'Photo' : 'Pas de photo', textAlign: TextAlign.center, style: DText.small(p)),
        ],
      ),
    );
  }
}

class _Findings extends StatelessWidget {
  final List<Finding>? findings;

  const _Findings({required this.findings});

  @override
  Widget build(BuildContext context) {
    final p = DPalette.of(context);
    final scope = DoctorScope.of(context);
    return GlassPanel(
      child: _Latest<List<Finding>>(
        value: findings,
        builder: (context, snap) {
          final list = [...(snap.data ?? const <Finding>[])]..sort((a, b) {
              final active = (a.isActive ? 0 : 1).compareTo(b.isActive ? 0 : 1);
              return active != 0 ? active : b.day.compareTo(a.day);
            });
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DSectionTitle('Lésions et signes', trailing: Text('${list.where((f) => f.isActive).length} actives', style: DText.small(p))),
              if (list.isEmpty) Text('Rien de signalé.', style: DText.small(p)),
              for (final f in list)
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: f.isActive ? p.levelSoft(f.level) : p.glass,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: f.isActive ? p.level(f.level).withValues(alpha: 0.5) : p.glassBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Expanded(
                          child: Text('${kindLabels[f.kind] ?? f.kind} · ${regionLabels[f.region] ?? f.region}',
                              style: DText.strong(p)),
                        ),
                        DTag(findingLevelLabels[f.level] ?? f.level,
                            color: p.level(f.level), background: p.levelSoft(f.level)),
                      ]),
                      const SizedBox(height: 4),
                      Text(
                        '${sideLabel(f.side)} · ${shortDate(f.day)} · ${statusLabels[f.status] ?? f.status}'
                        '${f.areaMm2 == null ? '' : ' · ${f.areaMm2!.round()} mm²'}'
                        ' · ${sourceLabels[f.source] ?? f.source}',
                        style: DText.small(p),
                      ),
                      if (f.note.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(f.note, style: DText.body(p)),
                      ],
                      if (f.reviewedBy != null) ...[
                        const SizedBox(height: 4),
                        Row(children: [
                          Icon(Icons.verified_outlined, size: 14, color: p.ok),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text('Revu par le clinicien', style: DText.small(p).copyWith(color: p.ok)),
                          ),
                        ]),
                      ],
                      if (scope.clinician && f.isActive) ...[
                        const SizedBox(height: 8),
                        Wrap(spacing: 8, children: [
                          if (f.reviewedBy == null)
                            OutlinedButton(
                              onPressed: () => scope.repository.markFindingReviewed(f.id),
                              child: const Text('Marquer revu'),
                            ),
                          OutlinedButton(
                            onPressed: () => scope.repository.markFindingHealed(f.id),
                            child: const Text('Marquer guéri'),
                          ),
                        ]),
                      ],
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _CheckHistory extends StatelessWidget {
  final List<Check>? checks;

  const _CheckHistory({required this.checks});

  @override
  Widget build(BuildContext context) {
    final p = DPalette.of(context);
    return GlassPanel(
      child: _Latest<List<Check>>(
        value: checks,
        builder: (context, snap) {
          final byDay = {for (final c in snap.data ?? const <Check>[]) c.day: c};
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          final days = [for (var d = 29; d >= 0; d--) DateTime(today.year, today.month, today.day - d)];
          final done = days.where(byDay.containsKey).length;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DSectionTitle('Contrôles quotidiens', trailing: Text('$done / 30 jours', style: DText.small(p))),
              Wrap(
                spacing: 5,
                runSpacing: 5,
                children: [
                  for (final d in days)
                    Tooltip(
                      message: '${shortDate(d)} : ${byDay[d] == null ? 'pas de contrôle' : checkLabels[byDay[d]!.result]}',
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: byDay[d] == null ? Colors.transparent : p.level(byDay[d]!.result),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: byDay[d] == null ? p.glassBorder : Colors.transparent),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text('30 derniers jours, le plus récent à droite.', style: DText.small(p)),
            ],
          );
        },
      ),
    );
  }
}

class _Messages extends StatefulWidget {
  final String patientId;
  final List<Message>? messages;

  const _Messages({required this.patientId, required this.messages});

  @override
  State<_Messages> createState() => _MessagesState();
}

class _MessagesState extends State<_Messages> {
  final reply = TextEditingController();

  @override
  void dispose() {
    reply.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = reply.text.trim();
    if (text.isEmpty) return;
    reply.clear();
    await DoctorScope.of(context).repository.sendMessage(widget.patientId, text);
  }

  @override
  Widget build(BuildContext context) {
    final p = DPalette.of(context);
    return GlassPanel(
      child: _Latest<List<Message>>(
        value: widget.messages,
        builder: (context, snap) {
          final list = snap.data ?? const <Message>[];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const DSectionTitle('Messages'),
              if (list.isEmpty) Text('Pas encore de message.', style: DText.small(p)),
              for (final m in list)
                Align(
                  alignment: m.fromDoctor ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 360),
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: m.fromDoctor ? p.primary.withValues(alpha: 0.22) : p.glass,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: p.glassBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(m.body, style: DText.body(p).copyWith(color: p.ink)),
                        const SizedBox(height: 2),
                        Text('${m.fromDoctor ? 'Vous' : 'Patient'} · ${dateTime(m.createdAt)}', style: DText.small(p)),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: reply,
                      maxLength: 2000,
                      minLines: 1,
                      maxLines: 4,
                      style: DText.body(p).copyWith(color: p.ink),
                      decoration: const InputDecoration(hintText: 'Répondre', counterText: ''),
                      onSubmitted: (_) => unawaited(_send()),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    tooltip: 'Envoyer',
                    onPressed: _send,
                    icon: const Icon(Icons.send_rounded),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

/// The latest value of a repository stream, held by [PatientView], given to
/// a section as a snapshot (null until the first value arrives).
class _Latest<T> extends StatelessWidget {
  final T? value;
  final AsyncWidgetBuilder<T> builder;

  const _Latest({super.key, required this.value, required this.builder});

  @override
  Widget build(BuildContext context) => builder(
        context,
        value == null
            ? AsyncSnapshot<T>.waiting()
            : AsyncSnapshot<T>.withData(ConnectionState.active, value as T),
      );
}
