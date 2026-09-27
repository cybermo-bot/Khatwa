import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../features/diet/diet_page.dart';
import '../../features/common.dart';
import '../../data/learn_content.dart';
import '../../ui/app_state.dart';
import '../../ui/app_theme.dart';
import '../../ui/k_image.dart';
import '../../ui/strings.dart';
import '../article_page.dart';

class LearnTab extends StatelessWidget {
  const LearnTab({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = appLanguage.value;
    void open(LearnArticle a) => Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => ArticlePage(article: a)));
    LearnSectionInfo info(LearnSection s) =>
        learnSections.firstWhere((i) => i.section == s);

    final healthy = articleById('healthy')!;
    final howTo = articleById('howto-check')!;
    final whenDoctor = articleById('when-doctor')!;

    return KPage(
      title: S.t(lang, 'tab.learn'),
      showBack: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 6),
          // The one thing no one should miss: urgent signs point to 190.
          KPressable(
            onTap: () => open(whenDoctor),
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
              decoration: BoxDecoration(
                color: K.dangerSoft,
                borderRadius: BorderRadius.circular(K.r24),
                border: Border.all(color: K.danger.withAlpha(60)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.local_hospital_outlined,
                          color: K.danger, size: 26),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(whenDoctor.title.of(lang),
                                style: K.h2.copyWith(color: K.danger)),
                            const SizedBox(height: 2),
                            Text(whenDoctor.summary.of(lang),
                                style: K.small.copyWith(color: K.ink)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: K.danger,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(48),
                    ),
                    onPressed: () => launchUrl(Uri(scheme: 'tel', path: '190')),
                    icon: const Icon(Icons.call_rounded, size: 20),
                    label: Text(LearnLabels.callEmergency.of(lang)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),
          // Know your feet: the healthy foot is the reference for everything else.
          KSectionLabel(info(LearnSection.know).title.of(lang)),
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 4, bottom: 14),
            child:
                Text(info(LearnSection.know).subtitle.of(lang), style: K.body),
          ),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _FeatureCard(
                    image: 'sign_healthy',
                    icon: Icons.favorite_outline_rounded,
                    title: healthy.title.of(lang),
                    onTap: () => open(healthy),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _FeatureCard(
                    image: 'care_check_mirror',
                    icon: Icons.search_rounded,
                    title: S.t(lang, 'today.care.check'),
                    onTap: () => open(howTo),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          KSectionLabel(info(LearnSection.signs).title.of(lang)),
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 4, bottom: 14),
            child:
                Text(info(LearnSection.signs).subtitle.of(lang), style: K.body),
          ),
          _SignsGrid(lang: lang, onOpen: open),
          const SizedBox(height: 32),
          KSectionLabel(info(LearnSection.care).title.of(lang)),
          KGroup(children: [
            for (final a in articlesIn(LearnSection.care))
              KGroupRow(
                icon: a.icon,
                leading: ArticleArt(article: a, size: 48),
                title: a.title.of(lang),
                subtitle: a.summary.of(lang),
                onTap: () => open(a),
              ),
          ]),
          const SizedBox(height: 32),
          KSectionLabel(info(LearnSection.life).title.of(lang)),
          KGroup(children: [
            for (final a in articlesIn(LearnSection.life))
              KGroupRow(
                icon: a.icon,
                title: a.title.of(lang),
                subtitle: a.summary.of(lang),
                onTap: () => open(a),
              ),
          ]),
          const SizedBox(height: 32),
          KSectionLabel(info(LearnSection.food).title.of(lang)),
          KGroup(children: [
            KGroupRow(
              icon: Icons.restaurant_rounded,
              title: tr('Alimentation : quoi manger, et combien',
                  aeb: 'الماكلة: شنوّة تاكل، وقدّاش', ar: 'التغذية: ماذا تأكل وكم', en: 'Food: what to eat, and how much'),
              subtitle: tr('Assiette, aliments tunisiens, Ramadan, hypoglycémie',
                  aeb: 'الصحفة، الماكلة التونسية، رمضان، هبوط السكر',
                  ar: 'الطبق، الأطعمة التونسية، رمضان، انخفاض السكر',
                  en: 'The plate, Tunisian foods, Ramadan, low blood sugar'),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DietPage())),
            ),
            for (final a in articlesIn(LearnSection.food))
              KGroupRow(
                icon: a.icon,
                title: a.title.of(lang),
                subtitle: a.summary.of(lang),
                onTap: () => open(a),
              ),
          ]),
          const SizedBox(height: 24),
          KNote(
              text: LearnLabels.pending.of(lang),
              icon: Icons.fact_check_outlined),
        ],
      ),
    );
  }
}

class _SignsGrid extends StatelessWidget {
  final String lang;
  final ValueChanged<LearnArticle> onOpen;

  const _SignsGrid({required this.lang, required this.onOpen});

  Widget _tile(LearnArticle a) {
    final urgent = a.urgentNow.isNotEmpty;
    return KPressable(
      onTap: () => onOpen(a),
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 14),
        decoration: K.glassDecoration(
            radius: K.r20, border: urgent ? K.danger.withAlpha(90) : null),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              children: [
                ArticleArt(article: a, height: 116),
                if (urgent)
                  PositionedDirectional(
                    top: 8,
                    end: 8,
                    child: Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                          color: K.danger, shape: BoxShape.circle),
                      child: Icon(Icons.priority_high_rounded,
                          size: 17, color: K.isDark ? K.ground : Colors.white),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(a.title.of(lang), style: K.bodyStrong),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final signs = articlesIn(LearnSection.signs);
    return LayoutBuilder(builder: (context, constraints) {
      final columns = constraints.maxWidth > 560 ? 3 : 2;
      const gap = 12.0;
      final rows = <Widget>[];
      for (var i = 0; i < signs.length; i += columns) {
        final cells = <Widget>[];
        for (var c = 0; c < columns; c++) {
          if (c > 0) cells.add(const SizedBox(width: gap));
          final index = i + c;
          cells.add(Expanded(
            child: index < signs.length
                ? _tile(signs[index])
                : const SizedBox.shrink(),
          ));
        }
        // Tiles in a row share one height, whatever the title length or text size.
        rows.add(Padding(
          padding:
              EdgeInsets.only(bottom: i + columns < signs.length ? gap : 0),
          child: IntrinsicHeight(
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: cells),
          ),
        ));
      }
      return Column(children: rows);
    });
  }
}

/// A picture card: the illustration on top, the title under it.
class _FeatureCard extends StatelessWidget {
  final String image;
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.image,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      radius: K.r20,
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 116,
            child: KImage(image, icon: icon, radius: K.r14),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(title, style: K.bodyStrong),
          ),
        ],
      ),
    );
  }
}
