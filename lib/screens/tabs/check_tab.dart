import 'package:flutter/material.dart';

import '../../data/auth_store.dart';
import '../../data/case_store.dart';
import '../../data/risk_profile.dart';
import '../../ui/app_state.dart';
import '../../ui/app_theme.dart';
import '../../ui/foot_art.dart';
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

        return KPage(
          title: S.t(lang, 'tab.check'),
          showBack: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              GlassCard(
                glow: !doneToday,
                radius: K.r28,
                padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(S.t(lang, 'check.daily'), style: K.h1),
                    const SizedBox(height: 6),
                    Text(S.t(lang, 'check.daily.what'), style: K.body),
                    if (profile != null) ...[
                      const SizedBox(height: 12),
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: KTag(S.t(lang, profile.frequencyKey),
                            icon: Icons.shield_outlined),
                      ),
                    ],
                    const SizedBox(height: 20),
                    PhotoPositions(
                      taken: doneToday && cases.isNotEmpty
                          ? cases.first.photos.length.clamp(0, 4)
                          : 0,
                      showNext: !doneToday,
                      ground: K.surface,
                      footHeight: 110,
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
                    const SizedBox(height: 22),
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
              const SizedBox(height: 32),
              KSectionLabel(S.t(lang, 'check.positions')),
              const _PositionsGrid(),
              const SizedBox(height: 12),
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
  const _PositionsGrid();

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
      const gap = 12.0;
      final width = (constraints.maxWidth - gap) / 2;
      return Wrap(
        spacing: gap,
        runSpacing: gap,
        children: [
          for (var i = 0; i < positions.length; i++)
            SizedBox(
              width: width,
              child: GlassCard(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                child: Row(
                  children: [
                    SizedBox(
                      height: 78,
                      child:
                          FootMap(side: positions[i].$1, view: positions[i].$2),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${i + 1}',
                              style: K.label.copyWith(
                                  color: K.primary,
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(height: 2),
                          Text(S.t(lang, positions[i].$3),
                              style: K.bodyStrong.copyWith(fontSize: 15.5)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      );
    });
  }
}
