import 'package:flutter/material.dart';

import '../../data/auth_store.dart';
import '../../data/case_store.dart';
import '../../data/risk_profile.dart';
import '../../ui/app_state.dart';
import '../../ui/app_theme.dart';
import '../../ui/foot_map.dart';
import '../../ui/foot_shapes.dart';
import '../../ui/strings.dart';
import '../feature_pages.dart';
import '../foot_check.dart';
import '../patient_home.dart';
import '../report_view.dart';
import '../risk_profile_page.dart';
import '../sensory_check.dart';

class CheckTab extends StatelessWidget {
  const CheckTab({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = appLanguage.value;
    final patientId = AuthStore.instance.current?.id ?? '';
    void open(Widget page) =>
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));

    return AnimatedBuilder(
      animation: CaseStore.instance,
      builder: (context, _) {
        final cases = CaseStore.instance.forPatient(patientId);
        final doneToday = CaseStore.instance.hasCheckToday(patientId);
        final profile = RiskProfile.latest();
        final taken = doneToday && cases.isNotEmpty
            ? cases.first.photos.length.clamp(0, 4)
            : 0;

        return KPage(
          title: S.t(lang, 'tab.check'),
          showBack: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.only(start: 4, bottom: 14),
                child: Text(S.t(lang, 'check.daily.what'), style: K.body),
              ),
              KCard(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                            child: Text(S.t(lang, 'check.daily'), style: K.h2)),
                        Text(
                          '$taken / 4',
                          style: K.label.copyWith(
                            color: K.primary,
                            fontWeight: FontWeight.w600,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(end: taken / 4),
                        duration: KMotion.standard,
                        builder: (context, v, _) => LinearProgressIndicator(
                          value: v == 0 ? 0.03 : v,
                          minHeight: 6,
                          backgroundColor: K.surfaceMuted,
                          color: K.glow,
                        ),
                      ),
                    ),
                    if (profile != null) ...[
                      const SizedBox(height: 12),
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: KTag(S.t(lang, profile.frequencyKey),
                            icon: Icons.shield_outlined),
                      ),
                    ],
                    const SizedBox(height: 16),
                    _PositionsGrid(taken: taken, showNext: !doneToday),
                    const SizedBox(height: 16),
                    if (doneToday && cases.isNotEmpty)
                      FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: K.primarySoft,
                          foregroundColor: K.primaryStrong,
                        ),
                        onPressed: () => open(
                            ReportPage(caseId: cases.first.id, language: lang)),
                        icon: const Icon(Icons.description_outlined),
                        label: Text(S.t(lang, 'home.seeToday')),
                      )
                    else
                      FilledButton.icon(
                        onPressed: () => open(FootCheckPage(language: lang)),
                        icon: const Icon(Icons.photo_camera_outlined),
                        label: Text(S.t(lang, 'home.start')),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              KNote(
                  text: S.t(lang, 'check.soon'), icon: Icons.upcoming_outlined),
              const SizedBox(height: 26),
              KSectionLabel(S.t(lang, 'check.more')),
              KGroup(children: [
                KGroupRow(
                  icon: Icons.touch_app_outlined,
                  title: S.t(lang, 'tool.sensory'),
                  onTap: () => open(SensoryCheckPage(language: lang)),
                ),
                KGroupRow(
                  icon: Icons.shield_outlined,
                  title: profile == null
                      ? S.t(lang, 'risk.cta')
                      : S.t(lang, 'risk.title'),
                  subtitle: profile == null
                      ? S.t(lang, 'risk.subtitle')
                      : S.t(lang, profile.labelKey),
                  onTap: () => open(RiskProfilePage(language: lang)),
                ),
                KGroupRow(
                  icon: Icons.thermostat_outlined,
                  title: S.t(lang, 'tool.temperature'),
                  onTap: () => open(TemperaturePage(language: lang)),
                ),
              ]),
              if (cases.isNotEmpty) ...[
                const SizedBox(height: 26),
                KSectionLabel(S.t(lang, 'home.history')),
                KGroup(children: [
                  for (final c in cases.take(3))
                    KGroupRow(
                      icon: levelIcon(c.triage.level),
                      tint: levelColor(c.triage.level),
                      title: levelHeadline(lang, c.triage.level),
                      subtitle: formatDate(c.date),
                      onTap: () =>
                          open(ReportPage(caseId: c.id, language: lang)),
                    ),
                ]),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _PositionsGrid extends StatelessWidget {
  final int taken;
  final bool showNext;
  const _PositionsGrid({required this.taken, required this.showNext});

  @override
  Widget build(BuildContext context) {
    final lang = appLanguage.value;
    final positions = [
      (FootSide.right, FootView.sole, 'check.rightSole'),
      (FootSide.left, FootView.sole, 'check.leftSole'),
      (FootSide.right, FootView.top, 'check.rightTop'),
      (FootSide.left, FootView.top, 'check.leftTop'),
    ];
    return LayoutBuilder(builder: (context, constraints) {
      const gap = 10.0;
      final width = (constraints.maxWidth - gap) / 2;
      return Wrap(
        spacing: gap,
        runSpacing: gap,
        children: [
          for (var i = 0; i < positions.length; i++)
            _Slot(
              width: width,
              number: i + 1,
              label: S.t(lang, positions[i].$3),
              side: positions[i].$1,
              view: positions[i].$2,
              done: i < taken,
              next: showNext && i == taken,
            ),
        ],
      );
    });
  }
}

class _Slot extends StatelessWidget {
  final double width;
  final int number;
  final String label;
  final FootSide side;
  final FootView view;
  final bool done;
  final bool next;

  const _Slot({
    required this.width,
    required this.number,
    required this.label,
    required this.side,
    required this.view,
    required this.done,
    required this.next,
  });

  @override
  Widget build(BuildContext context) {
    final active = next || done;
    return Semantics(
      label: label,
      checked: done,
      child: AnimatedContainer(
        duration: KMotion.standard,
        width: width,
        constraints: const BoxConstraints(minHeight: 112),
        padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
        decoration: BoxDecoration(
          color: active ? K.primarySoft : K.ground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: next ? K.glow : (done ? K.primarySoft : K.glassBorder),
            width: next ? 2 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: active ? K.primary : K.surfaceMuted,
                      shape: BoxShape.circle,
                    ),
                    child: done
                        ? Icon(Icons.check_rounded,
                            size: 16, color: K.onPrimary)
                        : Text('$number',
                            style: K.label.copyWith(
                                color: active ? K.onPrimary : K.inkSoft,
                                fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 10),
                  Text(label,
                      style: K.bodyStrong.copyWith(
                          fontSize: 15, color: active ? K.ink : K.inkSoft)),
                ],
              ),
            ),
            SizedBox(
              height: 72,
              child: Opacity(
                opacity: active ? 1 : 0.55,
                child: FootMap(side: side, view: view),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
