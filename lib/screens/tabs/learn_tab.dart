import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../features/diet/diet_page.dart';
import '../../features/common.dart';
import '../../data/learn_content.dart';
import '../../ui/app_state.dart';
import '../../ui/app_theme.dart';
import '../article_page.dart';

/// The education centre: every article as a picture card with a one-line
/// description, grouped by section, with chips to show one section only.
/// Urgent signs always stay one tap from 190, above everything else.
class LearnTab extends StatefulWidget {
  const LearnTab({super.key});

  @override
  State<LearnTab> createState() => _LearnTabState();
}

class _LearnTabState extends State<LearnTab> {
  /// The section shown, or null for all of them.
  LearnSection? _only;

  static const _order = [LearnSection.know, LearnSection.signs, LearnSection.care, LearnSection.life, LearnSection.food];

  @override
  Widget build(BuildContext context) {
    final lang = appLanguage.value;
    void open(LearnArticle a) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ArticlePage(article: a)));
    LearnSectionInfo info(LearnSection s) => learnSections.firstWhere((i) => i.section == s);
    final whenDoctor = articleById('when-doctor')!;

    List<Widget> cards(LearnSection s) => [
          if (s == LearnSection.food)
            _LearnCard(
              art: Container(
                height: 110,
                decoration: BoxDecoration(color: K.primarySoft, borderRadius: BorderRadius.circular(K.r14)),
                child: Icon(Icons.restaurant_rounded, color: K.primary, size: 44),
              ),
              title: tr('Alimentation', aeb: 'الماكلة', ar: 'التغذية', en: 'Food'),
              teaser: tr('Quoi manger, et combien', aeb: 'شنوّة تاكل، وقدّاش', ar: 'ماذا تأكل وكم', en: 'What to eat, and how much'),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DietPage())),
            ),
          for (final a in articlesIn(s))
            if (a.id != 'when-doctor')
              _LearnCard(
                art: ArticleArt(article: a, height: 110),
                title: a.title.of(lang),
                teaser: _teaser(a.summary.of(lang)),
                urgent: a.urgentNow.isNotEmpty,
                onTap: () => open(a),
              ),
        ];

    final shown = _only == null ? _order : [_only!];
    return KPage(
      title: tr('Centre d’éducation', aeb: 'مركز التوعية', ar: 'مركز التوعية', en: 'Education centre'),
      showBack: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            tr('Reconnaître tôt les signes, et savoir quoi faire.',
                aeb: 'اعرف العلامات بكري، واعرف شنوّة تعمل.',
                ar: 'تعرّف على العلامات مبكرًا، واعرف ماذا تفعل.',
                en: 'Spot the signs early, and know what to do.'),
            style: K.body.copyWith(color: K.inkSoft),
          ),
          const SizedBox(height: 14),
          _UrgentStrip(article: whenDoctor, lang: lang, onOpen: () => open(whenDoctor)),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: [
              _Chip(label: tr('Tout', aeb: 'الكل', ar: 'الكل', en: 'All'), selected: _only == null, onTap: () => setState(() => _only = null)),
              for (final s in _order)
                _Chip(
                  label: info(s).title.of(lang),
                  selected: _only == s,
                  onTap: () => setState(() => _only = _only == s ? null : s),
                ),
            ]),
          ),
          for (final s in shown) ...[
            const SizedBox(height: 26),
            Text(info(s).title.of(lang), style: K.h2),
            const SizedBox(height: 2),
            Text(info(s).subtitle.of(lang), style: K.small.copyWith(color: K.inkSoft)),
            const SizedBox(height: 12),
            _Grid(children: cards(s)),
          ],
          const SizedBox(height: 24),
          KNote(text: LearnLabels.pending.of(lang), icon: Icons.fact_check_outlined),
        ],
      ),
    );
  }

  /// The first sentence of a summary: the card's one-line description.
  static String _teaser(String summary) {
    final m = RegExp(r'^(.+?[.!?؟])(\s|$)').firstMatch(summary.trim());
    return m?.group(1) ?? summary;
  }
}

/// Urgent signs point to 190, in one slim row that is always there.
class _UrgentStrip extends StatelessWidget {
  final LearnArticle article;
  final String lang;
  final VoidCallback onOpen;
  const _UrgentStrip({required this.article, required this.lang, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    return KPressable(
      onTap: onOpen,
      child: Container(
        padding: const EdgeInsetsDirectional.fromSTEB(14, 10, 10, 10),
        decoration: BoxDecoration(
          color: K.dangerSoft,
          borderRadius: BorderRadius.circular(K.r20),
          border: Border.all(color: K.danger.withAlpha(60)),
        ),
        child: Row(children: [
          Icon(Icons.local_hospital_outlined, color: K.danger, size: 24),
          const SizedBox(width: 10),
          Expanded(child: Text(article.title.of(lang), style: K.bodyStrong.copyWith(color: K.danger))),
          const SizedBox(width: 8),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: K.danger,
              foregroundColor: Colors.white,
              minimumSize: const Size(0, 48),
              padding: const EdgeInsets.symmetric(horizontal: 14),
            ),
            onPressed: () => launchUrl(Uri(scheme: 'tel', path: '190')),
            icon: const Icon(Icons.call_rounded, size: 18),
            label: const Text('190'),
          ),
        ]),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _Chip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: Semantics(
        selected: selected,
        button: true,
        child: KPressable(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: AnimatedContainer(
            duration: KMotion.quick,
            constraints: const BoxConstraints(minHeight: 44),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: selected ? K.primary : K.surface,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: selected ? K.primary : K.control),
            ),
            child: Text(label, style: K.label.copyWith(color: selected ? K.onPrimary : K.ink, fontWeight: FontWeight.w600)),
          ),
        ),
      ),
    );
  }
}

/// Two columns on a phone, three on a wide screen; the cards of a row share
/// one height, whatever the title length or text size.
class _Grid extends StatelessWidget {
  final List<Widget> children;
  const _Grid({required this.children});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final columns = constraints.maxWidth > 560 ? 3 : 2;
      const gap = 12.0;
      final rows = <Widget>[];
      for (var i = 0; i < children.length; i += columns) {
        rows.add(Padding(
          padding: EdgeInsets.only(bottom: i + columns < children.length ? gap : 0),
          child: IntrinsicHeight(
            child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              for (var c = 0; c < columns; c++) ...[
                if (c > 0) const SizedBox(width: gap),
                Expanded(child: i + c < children.length ? children[i + c] : const SizedBox.shrink()),
              ],
            ]),
          ),
        ));
      }
      return Column(children: rows);
    });
  }
}

/// A picture card: the illustration, the title, one line on what it is.
class _LearnCard extends StatelessWidget {
  final Widget art;
  final String title;
  final String teaser;
  final bool urgent;
  final VoidCallback onTap;

  const _LearnCard({required this.art, required this.title, required this.teaser, required this.onTap, this.urgent = false});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: title,
      excludeSemantics: true,
      child: KPressable(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 14),
          decoration: BoxDecoration(
            color: K.surface,
            borderRadius: BorderRadius.circular(K.r20),
            border: Border.all(color: urgent ? K.danger.withAlpha(90) : K.glassBorder),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Stack(children: [
              art,
              if (urgent)
                PositionedDirectional(
                  top: 8,
                  end: 8,
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(color: K.danger, shape: BoxShape.circle),
                    child: Icon(Icons.priority_high_rounded, size: 17, color: K.isDark ? K.ground : Colors.white),
                  ),
                ),
            ]),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: K.bodyStrong),
                const SizedBox(height: 4),
                Text(teaser, style: K.small.copyWith(color: K.inkSoft), maxLines: 3, overflow: TextOverflow.ellipsis),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}
