import 'package:diabetic_foot_app/features/diet/diet_data.dart';
import 'package:diabetic_foot_app/features/diet/diet_page.dart';
import 'package:diabetic_foot_app/features/diet/diet_topics.dart';
import 'package:diabetic_foot_app/ui/app_state.dart';
import 'package:diabetic_foot_app/ui/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

final _arabic = RegExp(r'[؀-ۿ]');

void main() {
  const required = [
    'tabouna', 'baguette', 'whole_bread', 'couscous', 'makrouna', 'rice', 'lablabi', 'chorba', 'brik',
    'fricasse', 'mlawi', 'chapati', 'bsissa', 'assida', 'dates', 'figs', 'grapes', 'watermelon', 'melon',
    'orange', 'fruit_juice', 'soda', 'mint_tea', 'coffee', 'milk', 'yogurt', 'cheese', 'olive_oil',
    'chickpeas', 'lentils', 'fava', 'eggs', 'fish', 'chicken', 'makroudh', 'baklawa', 'bambalouni',
    'zlabia', 'mkharek', 'samsa', 'ghraiba', 'kaak_warka', 'bouza', 'halwa', 'honey', 'jam',
  ];

  test('every food of the brief is there, once', () {
    final ids = tunisianFoods.map((f) => f.id).toList();
    expect(ids.toSet().length, ids.length);
    for (final id in required) {
      expect(ids, contains(id));
    }
  });

  test('every food has all four languages, a portion and a carbohydrate value', () {
    for (final f in tunisianFoods) {
      for (final text in [f.name, f.portion, f.swap]) {
        for (final s in text.all) {
          expect(s.trim(), isNotEmpty, reason: f.id);
          expect(s.contains('—'), isFalse, reason: '${f.id}: no long dash');
        }
        // French and English in Latin script, derja and Arabic in Arabic script.
        expect(_arabic.hasMatch(text.fr), isFalse, reason: f.id);
        expect(_arabic.hasMatch(text.en), isFalse, reason: f.id);
        expect(_arabic.hasMatch(text.aeb), isTrue, reason: f.id);
        expect(_arabic.hasMatch(text.ar), isTrue, reason: f.id);
      }
      expect(f.grams, greaterThan(0), reason: f.id);
      expect(f.carbs, inInclusiveRange(0, 100), reason: f.id);
    }
  });

  test('the search finds a food by any of its names', () {
    for (final f in tunisianFoods) {
      for (final name in f.name.all) {
        expect(searchFoods(name).map((x) => x.id), contains(f.id), reason: '${f.id}: $name');
      }
    }
    expect(searchFoods('feve').map((f) => f.id), contains('fava'));
    expect(searchFoods('فول').map((f) => f.id), contains('fava'));
    expect(searchFoods('COUSCOUS').map((f) => f.id), contains('couscous'));
    expect(searchFoods('كسكسي').map((f) => f.id), contains('couscous'));
    expect(searchFoods('dates').map((f) => f.id), contains('dates'));
    expect(searchFoods('tabona').map((f) => f.id), contains('tabouna'));
    expect(searchFoods('zzzz'), isEmpty);
  });

  test('the search can keep one advice level', () {
    final rare = searchFoods('', level: FoodLevel.rarely);
    expect(rare, isNotEmpty);
    expect(rare.every((f) => f.level == FoodLevel.rarely), isTrue);
    expect(rare.map((f) => f.id), containsAll(['soda', 'zlabia', 'honey']));
  });

  test('the portion calculator multiplies the carbohydrate', () {
    final couscous = tunisianFoods.firstWhere((f) => f.id == 'couscous');
    expect(couscous.carbsFor(1), 35);
    expect(couscous.carbsFor(2), 70);
    expect(couscous.carbsFor(0.5), 18);
  });

  test('the content is marked as awaiting a dietitian', () {
    expect(dietReviewed, isFalse);
  });

  test('every topic is in the four languages, and the urgent ones lead to 190', () {
    for (final t in dietTopics) {
      for (final text in [t.title, t.summary, for (final s in t.sections) ...[s.heading, ...s.points]]) {
        for (final s in text.all) {
          expect(s.trim(), isNotEmpty, reason: t.id);
        }
      }
      if (t.urgent != null) {
        for (final s in t.urgent!.all) {
          expect(s, contains('190'), reason: t.id);
        }
      }
    }
    expect(dietTopic('hypo').urgent, isNotNull);
    expect(dietTopic('ramadan').urgent, isNotNull);
  });

  testWidgets('the portion calculator shows the total', (tester) async {
    appLanguage.value = 'Français';
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final dates = tunisianFoods.firstWhere((f) => f.id == 'dates');
    await tester.pumpWidget(MaterialApp(theme: K.theme(), home: Scaffold(body: FoodSheet(food: dates))));
    expect(find.text('= 16 g de glucides'), findsOneWidget);
    final slider = tester.widget<Slider>(find.byType(Slider));
    slider.onChanged!(2);
    await tester.pump();
    expect(find.text('= 32 g de glucides'), findsOneWidget);
  });

  testWidgets('searching the list narrows it', (tester) async {
    appLanguage.value = 'English';
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(theme: K.theme(), home: const FoodListPage()));
    await tester.enterText(find.byType(TextField), 'lentil');
    await tester.pump();
    expect(find.text('Lentils'), findsOneWidget);
    expect(find.text('Couscous'), findsNothing);
  });
}
