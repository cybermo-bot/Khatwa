import 'package:diabetic_foot_app/data/auth_store.dart';
import 'package:diabetic_foot_app/data/case_store.dart';
import 'package:diabetic_foot_app/data/khatwa_store.dart';
import 'package:diabetic_foot_app/screens/auth_pages.dart';
import 'package:diabetic_foot_app/screens/create_account.dart';
import 'package:diabetic_foot_app/ui/app_state.dart';
import 'package:diabetic_foot_app/ui/app_theme.dart';
import 'package:diabetic_foot_app/ui/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _app(String lang, Widget home, {double scale = 1}) => MaterialApp(
      theme: K.theme(),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
        child: Directionality(
          textDirection: S.isRtl(lang) ? TextDirection.rtl : TextDirection.ltr,
          child: child!,
        ),
      ),
      home: home,
    );

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await KhatwaStore.instance.init();
    await AuthStore.instance.init();
    await CaseStore.instance.init();
  });

  for (final lang in S.languages) {
    for (final size in const [Size(360, 740), Size(1280, 800)]) {
      testWidgets('landing renders in $lang at ${size.width}', (tester) async {
        appLanguage.value = lang;
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(_app(lang, const LandingPage(), scale: 1.3));
        await tester.pump();
        expect(tester.takeException(), isNull);
        expect(find.text(S.t(lang, 'auth.promise')), findsOneWidget);
        expect(find.byType(LanguagePill), findsOneWidget);
        expect(find.byType(RoleChoice), findsOneWidget);
      });
    }
  }

  for (final lang in S.languages) {
    for (final role in const ['patient', 'doctor']) {
      testWidgets('sign-in and sign-up render in $lang for $role on a phone', (tester) async {
        appLanguage.value = lang;
        tester.view.physicalSize = const Size(360, 740);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(_app(lang, AuthPage(role: role), scale: 1.3));
        await tester.pump();
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(_app(lang, CreateAccountPage(role: role), scale: 1.3));
        await tester.pump();
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('choosing health professional opens the professional sign-in', (tester) async {
    appLanguage.value = 'Français';
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_app('Français', const LandingPage()));
    await tester.tap(find.text('Soignant'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Se connecter'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Soignant'), findsWidgets);
    expect(find.byType(AuthPage), findsOneWidget);
  });
}
