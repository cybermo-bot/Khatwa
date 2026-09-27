import 'package:diabetic_foot_app/screens/onboarding.dart';
import 'package:diabetic_foot_app/ui/app_state.dart';
import 'package:diabetic_foot_app/ui/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    appLanguage.value = 'Français';
    await loadOnboarded();
  });

  testWidgets('three cards, then the app never shows them again', (tester) async {
    expect(appOnboarded.value, isFalse);
    await tester.pumpWidget(MaterialApp(theme: K.theme(), home: const OnboardingPage()));
    expect(find.text('Vos pieds, chaque jour'), findsOneWidget);
    await tester.tap(find.text('Suivant'));
    await tester.pumpAndSettle();
    expect(find.text('Votre pied en 3D'), findsOneWidget);
    await tester.tap(find.text('Suivant'));
    await tester.pumpAndSettle();
    expect(find.text('Parlez à Khatwa'), findsOneWidget);
    await tester.tap(find.text('Commencer'));
    await tester.pump();
    expect(appOnboarded.value, isTrue);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('khatwa_onboarded'), isTrue);
  });

  testWidgets('the cards can be skipped', (tester) async {
    await tester.pumpWidget(MaterialApp(theme: K.theme(), home: const OnboardingPage()));
    await tester.tap(find.text('Passer'));
    await tester.pump();
    expect(appOnboarded.value, isTrue);
  });
}
