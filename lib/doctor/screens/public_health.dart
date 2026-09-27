import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../data/models.dart';
import '../ui/foot_view.dart';
import '../ui/labels.dart';
import '../ui/style.dart';
import 'scope.dart';

/// "Vue santé publique", for decision makers: aggregates only, no patient.
class PublicHealthView extends StatefulWidget {
  const PublicHealthView({super.key});

  @override
  State<PublicHealthView> createState() => _PublicHealthViewState();
}

class _PublicHealthViewState extends State<PublicHealthView> {
  Stream<PopulationStats>? stats;
  Object? _repo;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final repo = DoctorScope.of(context).repository;
    if (!identical(repo, _repo)) {
      _repo = repo;
      stats = repo.populationStats();
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = DPalette.of(context);
    final scope = DoctorScope.of(context);
    return StreamBuilder<PopulationStats>(
      stream: stats,
      builder: (context, snap) {
        final s = snap.data;
        if (s == null) return Center(child: CircularProgressIndicator(color: p.primary));
        final lesions = s.findingsByRegion.values.fold<int>(0, (a, b) => a + b);
        final foot = GlassPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DSectionTitle('Lésions actives, tous patients', trailing: Text('$lesions', style: DText.small(p))),
              FootView(
                enable3d: scope.enable3d,
                sizeByCount: true,
                height: 380,
                pins: [
                  for (final e in s.findingsByRegion.entries)
                    if (e.value > 0)
                      FootPin(region: e.key, level: 'soon', count: e.value, label: '${e.value}'),
                ],
              ),
              const SizedBox(height: 8),
              Text('Les deux pieds sont réunis sur un pied de référence. Taille du repère : nombre de lésions.',
                  style: DText.small(p)),
              const SizedBox(height: 10),
              for (final e in (s.findingsByRegion.entries.where((e) => e.value > 0).toList()
                ..sort((a, b) => b.value.compareTo(a.value))))
                _Bar(label: regionLabels[e.key] ?? e.key, value: e.value, max: lesions, color: p.soon),
            ],
          ),
        );
        final risk = GlassPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DSectionTitle('Catégories de risque IWGDF', trailing: Text('${s.patients} patients', style: DText.small(p))),
              for (final r in [0, 1, 2, 3])
                _Bar(label: 'IWGDF $r', value: s.patientsByRisk[r] ?? 0, max: s.patients, color: p.risk(r)),
            ],
          ),
        );
        final weeks = s.alertsByWeek.entries.toList();
        final alerts = GlassPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const DSectionTitle('Alertes par semaine'),
              SizedBox(
                height: 180,
                child: BarChart(
                  BarChartData(
                    gridData: FlGridData(
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (_) => FlLine(color: p.glassBorder, strokeWidth: 1),
                    ),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 28,
                          interval: 2,
                          getTitlesWidget: (v, _) => Text(v.toInt().toString(), style: DText.small(p)),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (v, _) {
                            final i = v.toInt();
                            if (i < 0 || i >= weeks.length || i.isOdd) return const SizedBox.shrink();
                            return Text(shortDate(weeks[i].key), style: DText.small(p).copyWith(fontSize: 11));
                          },
                        ),
                      ),
                    ),
                    barGroups: [
                      for (var i = 0; i < weeks.length; i++)
                        BarChartGroupData(x: i, barRods: [
                          BarChartRodData(
                            toY: weeks[i].value.toDouble(),
                            width: 16,
                            color: p.primary,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                          ),
                        ]),
                    ],
                  ),
                  duration: dMotion,
                ),
              ),
            ],
          ),
        );
        final gov = GlassPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const DSectionTitle('Patients par gouvernorat'),
              _GovernorateGrid(stats: s),
            ],
          ),
        );
        final note = Text(
          'Données de démonstration, synthétiques et pseudonymisées. Recherche, seuils provisoires.',
          style: DText.small(p).copyWith(fontStyle: FontStyle.italic),
        );

        return LayoutBuilder(builder: (context, box) {
          const gap = SizedBox(height: 14, width: 14);
          if (box.maxWidth >= 1000) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: foot),
                    gap,
                    Expanded(child: Column(children: [risk, gap, alerts])),
                  ],
                ),
                gap,
                gov,
                gap,
                note,
              ],
            );
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [foot, gap, risk, gap, alerts, gap, gov, gap, note],
          );
        });
      },
    );
  }
}

class _Bar extends StatelessWidget {
  final String label;
  final int value;
  final int max;
  final Color color;

  const _Bar({required this.label, required this.value, required this.max, required this.color});

  @override
  Widget build(BuildContext context) {
    final p = DPalette.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(children: [
            Expanded(child: Text(label, style: DText.body(p))),
            Text('$value', style: DText.strong(p).copyWith(fontFeatures: DText.tabular)),
          ]),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: max == 0 ? 0 : value / max),
              duration: dMotion,
              builder: (context, t, _) => LinearProgressIndicator(
                value: t,
                minHeight: 8,
                color: color,
                backgroundColor: p.glass,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The 24 governorates as a styled grid: patients, and urgent alerts in red.
class _GovernorateGrid extends StatelessWidget {
  final PopulationStats stats;

  const _GovernorateGrid({required this.stats});

  @override
  Widget build(BuildContext context) {
    final p = DPalette.of(context);
    final max = stats.patientsByGovernorate.values.fold<int>(1, (a, b) => b > a ? b : a);
    return LayoutBuilder(builder: (context, box) {
      final columns = box.maxWidth >= 900 ? 6 : (box.maxWidth >= 560 ? 4 : 2);
      const gap = 8.0;
      final w = (box.maxWidth - gap * (columns - 1)) / columns;
      return Wrap(
        spacing: gap,
        runSpacing: gap,
        children: [
          for (final g in governorates)
            Builder(builder: (context) {
              final n = stats.patientsByGovernorate[g] ?? 0;
              final urgent = stats.urgentByGovernorate[g] ?? 0;
              return Container(
                width: w,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: n == 0 ? p.glass : p.primary.withValues(alpha: 0.10 + 0.35 * n / max),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: urgent > 0 ? p.urgent : p.glassBorder),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(g, maxLines: 1, overflow: TextOverflow.ellipsis, style: DText.small(p).copyWith(color: p.ink)),
                    ),
                    if (urgent > 0) ...[
                      Icon(Icons.warning_amber_rounded, size: 14, color: p.urgent),
                      const SizedBox(width: 2),
                    ],
                    Text('$n', style: DText.strong(p).copyWith(fontFeatures: DText.tabular)),
                  ],
                ),
              );
            }),
        ],
      );
    });
  }
}
