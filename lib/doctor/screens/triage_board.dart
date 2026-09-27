import 'package:flutter/material.dart';

import '../data/models.dart';
import '../ui/labels.dart';
import '../ui/style.dart';
import 'scope.dart' show BoardData;

/// Bento KPIs, filters and the urgent-first patient list.
class TriageBoard extends StatefulWidget {
  final BoardData data;
  final String? selectedId;
  final ValueChanged<Patient> onSelect;
  /// Alerts that arrived while the board was open: their patient pulses.
  final Set<String> freshAlertIds;
  final DateTime? today;

  const TriageBoard({
    super.key,
    required this.data,
    required this.onSelect,
    this.selectedId,
    this.freshAlertIds = const {},
    this.today,
  });

  @override
  State<TriageBoard> createState() => _TriageBoardState();
}

class _TriageBoardState extends State<TriageBoard> {
  int? risk;
  String? governorate;
  String? level; // urgent | soon | info | calm
  final search = TextEditingController();

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  bool _matches(Patient p) {
    final data = widget.data;
    if (risk != null && p.iwgdfRisk != risk) return false;
    if (governorate != null && p.governorate != governorate) return false;
    if (level != null) {
      const levels = ['urgent', 'soon', 'info', 'calm'];
      if (levels[data.priority(p)] != level) return false;
    }
    final q = search.text.trim().toLowerCase();
    if (q.isNotEmpty && !p.displayName.toLowerCase().contains(q) && !p.ref.toLowerCase().contains(q)) {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final p = DPalette.of(context);
    final data = widget.data;
    final now = widget.today ?? DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final urgentOpen = data.alerts.where((a) => a.urgent && !a.acknowledged).length;
    final activeFindings = data.findings.where((f) => f.isActive).length;
    final checksToday = data.checks.where((c) => c.day == today).length;
    final list = data.sorted(data.patients.where(_matches));
    final govs = {for (final p in data.patients) p.governorate}.whereType<String>().toList()..sort();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        _KpiGrid(tiles: [
          _Kpi('Patients suivis', '${data.patients.length}', Icons.people_alt_outlined, p.primary),
          _Kpi('Alertes urgentes', '$urgentOpen', Icons.priority_high_rounded, urgentOpen > 0 ? p.urgent : p.ok),
          _Kpi('Lésions actives', '$activeFindings', Icons.healing_outlined, p.soon),
          _Kpi('Contrôles du jour', '$checksToday', Icons.fact_check_outlined, p.mint),
        ]),
        const SizedBox(height: 16),
        TextField(
          controller: search,
          onChanged: (_) => setState(() {}),
          style: DText.body(p).copyWith(color: p.ink),
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.search_rounded, color: p.muted),
            hintText: 'Pseudonyme ou référence',
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _Choice('Tous risques', risk == null, () => setState(() => risk = null)),
            for (final r in [3, 2, 1, 0])
              _Choice('IWGDF $r', risk == r, () => setState(() => risk = risk == r ? null : r), color: p.risk(r)),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            for (final (value, text) in [
              ('urgent', 'Urgent'),
              ('soon', 'Bientôt'),
              ('info', 'Info'),
              ('calm', 'Calme'),
            ])
              _Choice(text, level == value, () => setState(() => level = level == value ? null : value),
                  color: value == 'calm' ? p.ok : p.level(value)),
            _GovernorateMenu(
              value: governorate,
              options: govs,
              onChanged: (g) => setState(() => governorate = g),
            ),
          ],
        ),
        const SizedBox(height: 16),
        DSectionTitle('Patients, urgents en premier', trailing: Text('${list.length}', style: DText.small(p))),
        if (list.isEmpty)
          GlassPanel(child: Text('Aucun patient ne correspond aux filtres.', style: DText.body(p)))
        else
          for (final patient in list)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: PatientRow(
                key: ValueKey('patient-${patient.id}'),
                patient: patient,
                data: data,
                selected: patient.id == widget.selectedId,
                fresh: data.openAlertsOf(patient.id).any((a) => widget.freshAlertIds.contains(a.id)),
                onTap: () => widget.onSelect(patient),
              ),
            ),
      ],
    );
  }
}

class _Kpi {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _Kpi(this.label, this.value, this.icon, this.color);
}

/// Bento grid: two columns on narrow panes, four when wide enough.
class _KpiGrid extends StatelessWidget {
  final List<_Kpi> tiles;

  const _KpiGrid({required this.tiles});

  @override
  Widget build(BuildContext context) {
    final p = DPalette.of(context);
    return LayoutBuilder(builder: (context, box) {
      final columns = box.maxWidth >= 640 ? 4 : 2;
      const gap = 10.0;
      final w = (box.maxWidth - gap * (columns - 1)) / columns;
      return Wrap(
        spacing: gap,
        runSpacing: gap,
        children: [
          for (final t in tiles)
            SizedBox(
              width: w,
              child: GlassPanel(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(t.icon, size: 20, color: t.color),
                    const SizedBox(height: 10),
                    AnimatedSwitcher(
                      duration: dMotion,
                      child: Text(t.value, key: ValueKey(t.value), style: DText.kpi(p, t.color)),
                    ),
                    const SizedBox(height: 4),
                    Text(t.label, maxLines: 2, style: DText.small(p).copyWith(color: p.inkSoft)),
                  ],
                ),
              ),
            ),
        ],
      );
    });
  }
}

class _Choice extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? color;

  const _Choice(this.label, this.selected, this.onTap, {this.color});

  @override
  Widget build(BuildContext context) {
    final p = DPalette.of(context);
    final c = color ?? p.primary;
    return Semantics(
      selected: selected,
      button: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: AnimatedContainer(
          duration: dMotion,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: selected ? c.withValues(alpha: 0.22) : p.glass,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: selected ? c : p.glassBorder),
          ),
          child: Text(label,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: selected ? p.ink : p.inkSoft)),
        ),
      ),
    );
  }
}

class _GovernorateMenu extends StatelessWidget {
  final String? value;
  final List<String> options;
  final ValueChanged<String?> onChanged;

  const _GovernorateMenu({required this.value, required this.options, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final p = DPalette.of(context);
    return PopupMenuButton<String>(
      tooltip: 'Gouvernorat',
      onSelected: (g) => onChanged(g.isEmpty ? null : g),
      itemBuilder: (context) => [
        const PopupMenuItem(value: '', child: Text('Tous les gouvernorats')),
        for (final g in options) PopupMenuItem(value: g, child: Text(g)),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: value != null ? p.primary.withValues(alpha: 0.22) : p.glass,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: value != null ? p.primary : p.glassBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.place_outlined, size: 15, color: p.inkSoft),
            const SizedBox(width: 4),
            Text(value ?? 'Gouvernorat',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: p.inkSoft)),
            Icon(Icons.arrow_drop_down_rounded, size: 18, color: p.inkSoft),
          ],
        ),
      ),
    );
  }
}

class PatientRow extends StatelessWidget {
  final Patient patient;
  final BoardData data;
  final bool selected;
  final bool fresh;
  final VoidCallback onTap;

  const PatientRow({
    super.key,
    required this.patient,
    required this.data,
    required this.selected,
    required this.fresh,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = DPalette.of(context);
    final priority = data.priority(patient);
    final open = data.openAlertsOf(patient.id)..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    open.sort((a, b) => (a.urgent ? 0 : 1).compareTo(b.urgent ? 0 : 1));
    final top = open.isEmpty ? null : open.first;
    final color = switch (priority) { 0 => p.urgent, 1 => p.soon, 2 => p.primary, _ => p.ok };

    return GlassPanel(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      borderColor: selected ? p.primary : (priority == 0 ? p.urgent.withValues(alpha: 0.6) : null),
      tint: selected ? p.primary.withValues(alpha: 0.10) : null,
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: fresh
                ? LivePulse(color: color)
                : Center(
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
                    ),
                  ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(child: Text(patient.displayName, style: DText.h2(p), maxLines: 1, overflow: TextOverflow.ellipsis)),
                    const SizedBox(width: 8),
                    DTag(riskLabel(patient.iwgdfRisk),
                        color: p.risk(patient.iwgdfRisk), background: p.risk(patient.iwgdfRisk).withValues(alpha: 0.14)),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${patient.ref} · ${patient.age ?? '?'} ans · ${patient.governorate ?? ''}',
                  style: DText.small(p),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (top != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(top.urgent ? Icons.warning_amber_rounded : Icons.notifications_none_rounded,
                          size: 16, color: p.level(top.level)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(top.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: DText.strong(p).copyWith(fontSize: 14, color: p.level(top.level))),
                      ),
                      Text(ago(top.createdAt), style: DText.small(p)),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 6),
          Icon(Icons.chevron_right_rounded, color: p.muted),
        ],
      ),
    );
  }
}
