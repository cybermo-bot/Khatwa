import 'dart:math';

import 'package:flutter/material.dart';

import '../../ui/app_theme.dart';
import '../../ui/k_image.dart';
import '../common.dart';
import 'diet_data.dart';
import 'diet_topics.dart';

String _pending() => tr(
    'À valider par un diététicien. Glucides : USDA FoodData Central, et estimations à partir des recettes pour les plats et pâtisseries.',
    aeb: 'مازال يلزم يراجعو مختص تغذية. السكريات: USDA FoodData Central، وتقديرات من الوصفات للماكلة والحلو.',
    ar: 'في انتظار مراجعة مختص تغذية. السكريات: USDA FoodData Central، وتقديرات من الوصفات للأطباق والحلويات.',
    en: 'To be validated by a dietitian. Carbohydrate: USDA FoodData Central, and recipe estimates for dishes and pastries.');

String _carbsLabel(num grams) =>
    tr('$grams g de glucides', aeb: '$grams غ سكريات', ar: '$grams غ من السكريات', en: '$grams g of carbohydrate');

void _open(BuildContext context, Widget page) =>
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));

/// "Alimentation": what to eat, and how much. Four languages, design A.
class DietPage extends StatelessWidget {
  const DietPage({super.key});

  @override
  Widget build(BuildContext context) {
    final rtl = Directionality.of(context) == TextDirection.rtl;
    Widget row(IconData icon, String title, String subtitle, Widget page) => KGroupRow(
          icon: icon,
          title: title,
          subtitle: subtitle,
          onTap: () => _open(context, page),
        );
    return KPage(
      title: tr('Alimentation', aeb: 'الماكلة', ar: 'التغذية', en: 'Food'),
      subtitle: tr('Quoi manger, et combien', aeb: 'شنوّة تاكل، وقدّاش', ar: 'ماذا تأكل وكم', en: 'What to eat, and how much'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 6),
          KNote(
            icon: Icons.favorite_outline_rounded,
            text: tr(
                'Aucun aliment n’est interdit. Ces repères aident à trouver la bonne portion, et votre médecin ou diététicien(ne) les adapte à vous. Ne sautez pas de repas.',
                aeb: 'حتى ماكلة موش ممنوعة. هالعلامات تعاونك تلقى الكمية المناسبة، وطبيبك ولا أخصائي التغذية يعدّلها ليك. ما تفوّتش الماكلة.',
                ar: 'لا يوجد طعام ممنوع. هذه الإرشادات تساعدك على إيجاد الحصة المناسبة، ويكيّفها طبيبك أو أخصائي التغذية لك. لا تفوّت الوجبات.',
                en: 'No food is forbidden. These guides help you find the right portion, and your doctor or dietitian adapts them to you. Do not skip meals.'),
          ),
          const SizedBox(height: 14),
          KCard(
            onTap: () => _open(context, DietTopicPage(topic: dietTopic('plate'))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(children: [
                  Expanded(child: Text(dietTopic('plate').title.text, style: K.h2)),
                  Icon(rtl ? Icons.chevron_left_rounded : Icons.chevron_right_rounded, color: K.muted),
                ]),
                const SizedBox(height: 14),
                const PlateFigure(),
              ],
            ),
          ),
          const SizedBox(height: 26),
          KGroup(children: [
            row(
              Icons.search_rounded,
              tr('Aliments tunisiens', aeb: 'الماكلة التونسية', ar: 'الأطعمة التونسية', en: 'Tunisian foods'),
              tr('${tunisianFoods.length} aliments : portion et glucides',
                  aeb: '${tunisianFoods.length} ماكلة: الكمية والسكريات',
                  ar: '${tunisianFoods.length} طعامًا: الحصة والسكريات',
                  en: '${tunisianFoods.length} foods: portion and carbohydrate'),
              const FoodListPage(),
            ),
            for (final id in const ['ramadan', 'hypo', 'feet'])
              row(dietTopic(id).icon, dietTopic(id).title.text, dietTopic(id).summary.text,
                  DietTopicPage(topic: dietTopic(id))),
          ]),
          const SizedBox(height: 20),
          KNote(text: _pending(), icon: Icons.fact_check_outlined),
        ],
      ),
    );
  }
}

/// The plate, drawn: half vegetables, a quarter protein, a quarter starch,
/// with the hand portions, and a glass of water beside it.
class PlateFigure extends StatelessWidget {
  const PlateFigure({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = [K.primary, K.mint, K.primarySoft];
    final legend = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < plateParts.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                width: 14,
                height: 14,
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  color: colors[i],
                  shape: BoxShape.circle,
                  border: Border.all(color: K.primary, width: 1.2),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text.rich(TextSpan(children: [
                  TextSpan(text: '${plateParts[i].name.text}\n', style: K.bodyStrong),
                  TextSpan(text: plateParts[i].hand.text, style: K.small),
                ])),
              ),
            ]),
          ),
        Row(children: [
          Icon(Icons.water_drop_outlined, size: 18, color: K.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(tr('L’eau, la meilleure boisson', aeb: 'الماء، أحسن شراب', ar: 'الماء، أفضل مشروب', en: 'Water, the best drink'),
                style: K.small),
          ),
        ]),
      ],
    );
    return LayoutBuilder(builder: (context, box) {
      final size = min(150.0, box.maxWidth * 0.42);
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Semantics(
            label: dietTopic('plate').summary.text,
            child: SizedBox(
              width: size,
              height: size,
              child: CustomPaint(painter: _PlatePainter(colors, K.surface, K.line, K.primary)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(child: legend),
        ],
      );
    });
  }
}

class _PlatePainter extends CustomPainter {
  final List<Color> colors;
  final Color rim;
  final Color edge;
  final Color stroke;
  _PlatePainter(this.colors, this.rim, this.edge, this.stroke);

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2;
    canvas.drawCircle(c, r, Paint()..color = rim);
    canvas.drawCircle(c, r, Paint()
      ..color = edge
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5);
    final inner = Rect.fromCircle(center: c, radius: r * 0.82);
    var start = -pi / 2;
    for (var i = 0; i < plateParts.length; i++) {
      final sweep = 2 * pi * plateParts[i].share;
      canvas.drawArc(inner, start, sweep, true, Paint()..color = colors[i]);
      canvas.drawArc(inner, start, sweep, true, Paint()
        ..color = rim
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3);
      start += sweep;
    }
    canvas.drawCircle(c, r * 0.82, Paint()
      ..color = stroke.withAlpha(90)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1);
  }

  @override
  bool shouldRepaint(covariant _PlatePainter old) => old.colors != colors || old.rim != rim;
}

String levelName(FoodLevel level) => switch (level) {
      FoodLevel.free => tr('Au quotidien', aeb: 'كل نهار', ar: 'يوميًا', en: 'Every day'),
      FoodLevel.measured => tr('Une portion à la fois', aeb: 'كمية وحدة في المرة', ar: 'حصة واحدة في كل مرة', en: 'One portion at a time'),
      FoodLevel.rarely => tr('Pour le plaisir, petite part', aeb: 'للبنّة، شوية', ar: 'للمتعة، بكمية صغيرة', en: 'A treat, a small share'),
    };

IconData levelIcon(FoodLevel level) => switch (level) {
      FoodLevel.free => Icons.check_circle_outline_rounded,
      FoodLevel.measured => Icons.balance_rounded,
      FoodLevel.rarely => Icons.hourglass_bottom_rounded,
    };

/// The advice level, never in triage colours: an icon and words.
class LevelTag extends StatelessWidget {
  final FoodLevel level;
  const LevelTag(this.level, {super.key});

  @override
  Widget build(BuildContext context) =>
      KTag(levelName(level), icon: levelIcon(level), background: level == FoodLevel.free ? K.primarySoft : null);
}

/// A searchable list of Tunisian foods.
class FoodListPage extends StatefulWidget {
  const FoodListPage({super.key});

  @override
  State<FoodListPage> createState() => _FoodListPageState();
}

class _FoodListPageState extends State<FoodListPage> {
  final _query = TextEditingController();
  FoodLevel? _level;

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final foods = searchFoods(_query.text, level: _level);
    return KPage(
      title: tr('Aliments tunisiens', aeb: 'الماكلة التونسية', ar: 'الأطعمة التونسية', en: 'Tunisian foods'),
      subtitle: tr('Portion usuelle et glucides', aeb: 'الكمية العادية والسكريات', ar: 'الحصة المعتادة والسكريات', en: 'Usual portion and carbohydrate'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 10),
          TextField(
            controller: _query,
            onChanged: (_) => setState(() {}),
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: tr('Chercher : couscous, dattes…', aeb: 'لوّج: كسكسي، تمر…', ar: 'ابحث: كسكسي، تمر…', en: 'Search: couscous, dates…'),
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _query.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: tr('Effacer', aeb: 'افسخ', ar: 'مسح', en: 'Clear'),
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => setState(_query.clear),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: [
            ChoiceChip(
              label: Text(tr('Tous', aeb: 'الكل', ar: 'الكل', en: 'All')),
              selected: _level == null,
              onSelected: (_) => setState(() => _level = null),
            ),
            for (final level in FoodLevel.values)
              ChoiceChip(
                avatar: Icon(levelIcon(level), size: 18),
                label: Text(levelName(level)),
                selected: _level == level,
                onSelected: (_) => setState(() => _level = level),
              ),
          ]),
          const SizedBox(height: 16),
          if (foods.isEmpty)
            KCard(
              child: Text(
                  tr('Aucun aliment trouvé. Essayez un autre nom.', aeb: 'ما لقينا حتى ماكلة. جرّب اسم آخر.', ar: 'لم يُعثر على أي طعام. جرّب اسمًا آخر.', en: 'No food found. Try another name.'),
                  style: K.body),
            )
          else
            KGroup(children: [
              for (final f in foods)
                KGroupRow(
                  icon: levelIcon(f.level),
                  title: f.name.text,
                  subtitle: '${f.hand?.text ?? f.portion.text} · ${_carbsLabel(f.carbs.round())}',
                  onTap: () => showFoodSheet(context, f),
                ),
            ]),
          const SizedBox(height: 20),
          KNote(text: _pending(), icon: Icons.fact_check_outlined),
        ],
      ),
    );
  }
}

Future<void> showFoodSheet(BuildContext context, Food food) => showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: K.surface,
      builder: (_) => FoodSheet(food: food),
    );

/// One food: the usual portion, its carbohydrate, the advice and a better
/// swap, and a calculator for the number of portions.
class FoodSheet extends StatefulWidget {
  final Food food;
  const FoodSheet({super.key, required this.food});

  @override
  State<FoodSheet> createState() => _FoodSheetState();
}

class _FoodSheetState extends State<FoodSheet> {
  double portions = 1;

  String _count(double v) => v == v.roundToDouble() ? '${v.round()}' : v.toStringAsFixed(1).replaceAll('.', ',');

  @override
  Widget build(BuildContext context) {
    final f = widget.food;
    const tabular = [FontFeature.tabularFigures()];
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(f.name.text, style: K.h1),
            const SizedBox(height: 12),
            if (f.hand != null)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: K.primarySoft, borderRadius: BorderRadius.circular(K.r20)),
                child: Row(children: [
                  Icon(Icons.front_hand_outlined, color: K.primaryStrong, size: 30),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(tr('Une portion', aeb: 'كمية وحدة', ar: 'حصة واحدة', en: 'One portion'),
                          style: K.small.copyWith(color: K.primaryStrong)),
                      Text(f.hand!.text, style: K.h2.copyWith(color: K.primaryStrong)),
                    ]),
                  ),
                ]),
              ),
            const SizedBox(height: 8),
            Text(f.portion.text, style: K.body.copyWith(color: K.inkSoft)),
            const SizedBox(height: 16),
            Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('${f.carbs.round()}', style: K.number.copyWith(fontFeatures: tabular)),
              const SizedBox(width: 6),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                      tr('g de glucides par portion', aeb: 'غ سكريات في الكمية', ar: 'غ من السكريات في الحصة', en: 'g of carbohydrate per portion'),
                      style: K.body),
                ),
              ),
            ]),
            const SizedBox(height: 14),
            Align(alignment: AlignmentDirectional.centerStart, child: LevelTag(f.level)),
            const SizedBox(height: 10),
            Text(f.swap.text, style: K.body),
            const SizedBox(height: 22),
            KCard(
              color: K.primarySoft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(tr('Combien de portions ?', aeb: 'قدّاش من كمية؟', ar: 'كم حصة؟', en: 'How many portions?'),
                      style: K.bodyStrong.copyWith(color: K.primaryStrong)),
                  Slider(
                    value: portions,
                    min: 0.5,
                    max: 4,
                    divisions: 7,
                    label: _count(portions),
                    semanticFormatterCallback: (v) => _count(v),
                    onChanged: (v) => setState(() => portions = v),
                  ),
                  if (f.countFor(portions) != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text('= ${f.countFor(portions)}',
                          style: K.h2.copyWith(color: K.primaryStrong, fontFeatures: tabular)),
                    ),
                  Row(children: [
                    Text('${_count(portions)} ×', style: K.bodyStrong.copyWith(color: K.primaryStrong, fontFeatures: tabular)),
                    const Spacer(),
                    Flexible(
                      child: Text(
                        '= ${_carbsLabel(f.carbsFor(portions))}',
                        textAlign: TextAlign.end,
                        style: K.h2.copyWith(color: K.primaryStrong, fontFeatures: tabular),
                      ),
                    ),
                  ]),
                ],
              ),
            ),
            const SizedBox(height: 14),
            KNote(text: _pending(), icon: Icons.fact_check_outlined),
          ],
        ),
      ),
    );
  }
}

/// A teaching page: sections of short points, and when it is urgent, 190.
class DietTopicPage extends StatelessWidget {
  final DietTopic topic;
  const DietTopicPage({super.key, required this.topic});

  @override
  Widget build(BuildContext context) {
    return KPage(
      title: topic.title.text,
      subtitle: topic.summary.text,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 10),
          // A picture for the topic when it has been made (diet_ramadan, ...).
          if (topic.id != 'plate')
            KImage('diet_${topic.id}',
                height: 180, width: double.infinity, radius: K.r20, placeholder: const SizedBox.shrink()),
          if (topic.id == 'plate') ...[
            const KCard(child: PlateFigure()),
            const SizedBox(height: 14),
          ],
          if (topic.urgent != null && topic.id == 'hypo') ...[
            _Urgent(topic.urgent!),
            const SizedBox(height: 14),
          ],
          for (final s in topic.sections) ...[
            KCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(s.heading.text, style: K.h2),
                  const SizedBox(height: 10),
                  for (final p in s.points)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 9),
                          child: Container(
                              width: 6, height: 6, decoration: BoxDecoration(color: K.primary, shape: BoxShape.circle)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Text(p.text, style: K.body)),
                      ]),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],
          if (topic.urgent != null && topic.id != 'hypo') ...[
            _Urgent(topic.urgent!),
            const SizedBox(height: 14),
          ],
          if (topic.id == 'plate' || topic.id == 'ramadan')
            OutlinedButton.icon(
              onPressed: () => _open(context, const FoodListPage()),
              icon: const Icon(Icons.search_rounded),
              label: Text(tr('Voir les aliments tunisiens', aeb: 'شوف الماكلة التونسية', ar: 'اعرض الأطعمة التونسية', en: 'See Tunisian foods')),
            ),
          const SizedBox(height: 16),
          KNote(text: _pending(), icon: Icons.fact_check_outlined),
        ],
      ),
    );
  }
}

class _Urgent extends StatelessWidget {
  final L text;
  const _Urgent(this.text);

  @override
  Widget build(BuildContext context) => KCard(
        color: K.dangerSoft,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(Icons.emergency_rounded, color: K.danger),
            const SizedBox(width: 12),
            Expanded(child: Text(text.text, style: K.bodyStrong.copyWith(color: K.danger))),
          ]),
          const SizedBox(height: 12),
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: K.danger),
            onPressed: call190,
            icon: const Icon(Icons.call_rounded),
            label: Text(tr('Appeler le 190', aeb: 'اطلب 190', ar: 'اتصل بـ 190', en: 'Call 190')),
          ),
        ]),
      );
}
