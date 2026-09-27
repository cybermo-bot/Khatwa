import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/learn_content.dart';
import '../ui/app_state.dart';
import '../ui/app_theme.dart';
import '../ui/foot_map.dart';
import '../ui/k_image.dart';
import '../ui/sign_art.dart';

class ArticlePage extends StatefulWidget {
  final LearnArticle article;

  const ArticlePage({super.key, required this.article});

  @override
  State<ArticlePage> createState() => _ArticlePageState();
}

class _ArticlePageState extends State<ArticlePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final animated = widget.article.zones.isNotEmpty &&
        articleImages(widget.article.id).isEmpty;
    if (animated && !KMotion.reduced(context) && !_pulse.isAnimating) {
      _pulse.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = appLanguage.value;
    final a = widget.article;
    final images = articleImages(a.id);
    final urgent = a.urgentNow.isNotEmpty;
    final well = urgent ? K.dangerSoft : K.primarySoft;

    Widget hero;
    if (images.isNotEmpty) {
      // What the sign or the care act looks like.
      hero = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 250,
            child: KImage(images.first,
                icon: a.icon, label: a.title.of(lang), radius: K.r28),
          ),
          if (images.length > 1) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                for (final name in images.skip(1)) ...[
                  Expanded(
                    child: SizedBox(
                        height: 130,
                        child: KImage(name, icon: a.icon, radius: K.r20)),
                  ),
                ],
              ],
            ),
          ],
        ],
      );
    } else if (a.zones.isNotEmpty) {
      hero = GlassCard(
        padding: const EdgeInsets.symmetric(vertical: 22),
        tint: urgent ? well : null,
        child: AnimatedBuilder(
          animation: _pulse,
          builder: (context, _) => FootMapPair(
            height: 220,
            view: a.view,
            pulse: Curves.easeInOut.transform(_pulse.value),
            highlight: {for (final z in a.zones) ...z.regions},
          ),
        ),
      );
    } else {
      hero = Align(
        alignment: AlignmentDirectional.centerStart,
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color:
                a.section == LearnSection.urgent ? K.dangerSoft : K.primarySoft,
            borderRadius: BorderRadius.circular(K.r20),
          ),
          child: Icon(
            a.icon,
            size: 32,
            color: a.section == LearnSection.urgent ? K.danger : K.primary,
          ),
        ),
      );
    }

    return KPage(
      title: a.title.of(lang),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          hero,
          const SizedBox(height: 22),
          Text(a.summary.of(lang),
              style: K.h2.copyWith(fontWeight: FontWeight.w500, height: 1.4)),
          if (a.hasVideo) ...[
            const SizedBox(height: 22),
            _VideoSlot(label: LearnLabels.video.of(lang)),
          ],
          if (a.urgentNow.isNotEmpty) ...[
            const SizedBox(height: 26),
            _UrgentBlock(article: a, lang: lang),
          ],
          if (a.lookFor.isNotEmpty) ...[
            const SizedBox(height: 28),
            KSectionLabel(LearnLabels.lookFor.of(lang)),
            _BulletList(
                items: [for (final t in a.lookFor) t.of(lang)],
                icon: Icons.visibility_outlined),
          ],
          if (a.atHome.isNotEmpty) ...[
            const SizedBox(height: 28),
            KSectionLabel(
              a.section == LearnSection.care || a.section == LearnSection.know
                  ? LearnLabels.steps.of(lang)
                  : LearnLabels.atHome.of(lang),
            ),
            _StepList(
              items: [for (final t in a.atHome) t.of(lang)],
              numbered: a.section == LearnSection.care ||
                  a.section == LearnSection.know,
            ),
          ],
          if (a.seeDoctor.isNotEmpty) ...[
            const SizedBox(height: 28),
            KSectionLabel(LearnLabels.seeDoctor.of(lang)),
            Container(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
              decoration: BoxDecoration(
                color: K.warnSoft,
                borderRadius: BorderRadius.circular(K.r20),
              ),
              child: _BulletList(
                items: [for (final t in a.seeDoctor) t.of(lang)],
                icon: Icons.medical_services_outlined,
                color: K.warn,
                inset: false,
              ),
            ),
          ],
          const SizedBox(height: 28),
          KNote(
              text: LearnLabels.pending.of(lang),
              icon: Icons.fact_check_outlined),
        ],
      ),
    );
  }
}

class _UrgentBlock extends StatelessWidget {
  final LearnArticle article;
  final String lang;

  const _UrgentBlock({required this.article, required this.lang});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: K.dangerSoft,
        borderRadius: BorderRadius.circular(K.r20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.emergency_outlined, color: K.danger),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  LearnLabels.urgentNow.of(lang),
                  style: K.h2.copyWith(color: K.danger),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _BulletList(
            items: [for (final t in article.urgentNow) t.of(lang)],
            icon: Icons.priority_high_rounded,
            color: K.danger,
            inset: false,
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: K.danger,
              foregroundColor:
                  K.isDark ? const Color(0xFF2A0D0A) : Colors.white,
            ),
            onPressed: () => launchUrl(Uri(scheme: 'tel', path: '190')),
            icon: const Icon(Icons.call_rounded),
            label: Text(LearnLabels.callEmergency.of(lang)),
          ),
        ],
      ),
    );
  }
}

class _BulletList extends StatelessWidget {
  final List<String> items;
  final IconData icon;
  final Color? color;
  final bool inset;

  const _BulletList(
      {required this.items, required this.icon, this.color, this.inset = true});

  @override
  Widget build(BuildContext context) {
    final c = color ?? K.primary;
    return Padding(
      padding: EdgeInsetsDirectional.only(start: inset ? 4 : 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Icon(icon, size: 20, color: c),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Text(item, style: K.body.copyWith(color: K.ink))),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _StepList extends StatelessWidget {
  final List<String> items;
  final bool numbered;

  const _StepList({required this.items, required this.numbered});

  @override
  Widget build(BuildContext context) {
    if (!numbered) {
      return _BulletList(
          items: items, icon: Icons.check_circle_outline_rounded);
    }
    return KGroup(
      children: [
        for (var i = 0; i < items.length; i++)
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: K.primarySoft, shape: BoxShape.circle),
                  child: Text(
                    '${i + 1}',
                    style: K.bodyStrong.copyWith(
                        color: K.primaryStrong, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(items[i], style: K.body.copyWith(color: K.ink)),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Where the care-team video will play. Until the team records it, the slot
/// says so plainly instead of pretending.
class _VideoSlot extends StatelessWidget {
  final String label;
  const _VideoSlot({required this.label});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        decoration: BoxDecoration(
          color: K.surfaceMuted,
          borderRadius: BorderRadius.circular(K.r20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration:
                  BoxDecoration(color: K.surface, shape: BoxShape.circle),
              child: Icon(Icons.play_arrow_rounded, size: 34, color: K.muted),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(label, style: K.small, textAlign: TextAlign.center),
            ),
          ],
        ),
      ),
    );
  }
}

/// Thumbnail for lists: the article's illustration in a tinted well, or its icon
/// when the article is not about a place on the foot.
class ArticleArt extends StatelessWidget {
  final LearnArticle article;
  final double size;
  final double? height;

  const ArticleArt(
      {super.key, required this.article, this.size = 52, this.height});

  @override
  Widget build(BuildContext context) {
    final images = articleImages(article.id);
    final urgent = article.urgentNow.isNotEmpty;
    final well = urgent ? K.dangerSoft : K.primarySoft;
    return Container(
      width: height == null ? size : double.infinity,
      height: height ?? size,
      decoration: BoxDecoration(
          color: well, borderRadius: BorderRadius.circular(K.r14)),
      clipBehavior: Clip.antiAlias,
      child: images.isNotEmpty
          ? KImage(images.first,
              icon: article.icon, radius: K.r14, width: double.infinity)
          : Icon(article.icon,
              color: urgent ? K.danger : K.primary, size: size * 0.5),
    );
  }
}
