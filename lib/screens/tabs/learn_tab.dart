import 'package:flutter/material.dart';

import '../../data/learn_content.dart';
import '../../ui/app_state.dart';
import '../../ui/app_theme.dart';
import '../../ui/foot_art.dart';
import '../../ui/foot_shapes.dart';
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
          const SizedBox(height: 10),
          // Know your feet: the healthy foot is the reference for everything else.
          Container(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
            decoration: BoxDecoration(
              color: K.primarySoft,
              borderRadius: BorderRadius.circular(K.r28),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(info(LearnSection.know).title.of(lang),
                    style: K.h1.copyWith(color: K.primaryStrong)),
                const SizedBox(height: 4),
                Text(info(LearnSection.know).subtitle.of(lang),
                    style: K.body.copyWith(color: K.primaryStrong)),
                const SizedBox(height: 18),
                const FeetPair(height: 170, view: FootView.top),
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: () => open(healthy),
                  icon: const Icon(Icons.favorite_outline_rounded, size: 21),
                  label: Text(healthy.title.of(lang)),
                ),
                const SizedBox(height: 10),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: K.surface,
                    foregroundColor: K.primaryStrong,
                  ),
                  onPressed: () => open(howTo),
                  icon: const Icon(Icons.search_rounded, size: 21),
                  label: Text(S.t(lang, 'today.care.check')),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // The one thing no one should miss.
          KPressable(
            onTap: () => open(whenDoctor),
            child: Container(
              padding: const EdgeInsets.fromLTRB(18, 16, 14, 16),
              decoration: BoxDecoration(
                color: K.dangerSoft,
                borderRadius: BorderRadius.circular(K.r20),
              ),
              child: Row(
                children: [
                  Icon(Icons.local_hospital_outlined,
                      color: K.danger, size: 28),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(whenDoctor.title.of(lang),
                            style: K.h2.copyWith(color: K.danger)),
                        const SizedBox(height: 2),
                        Text(whenDoctor.summary.of(lang),
                            style: K.body.copyWith(color: K.ink)),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: K.danger,
                  ),
                ],
              ),
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
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
        decoration: BoxDecoration(
          color: K.surface,
          borderRadius: BorderRadius.circular(K.r20),
          border: K.isDark ? Border.all(color: K.line) : null,
          boxShadow: K.lift,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              children: [
                ArticleArt(article: a, height: 128),
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
