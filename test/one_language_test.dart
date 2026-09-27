// One language per page: renders the main pages in each language and fails
// when a Latin-script word shows in an Arabic-script page, or Arabic script
// shows in a French or English page.
import 'package:diabetic_foot_app/data/auth_store.dart';
import 'package:diabetic_foot_app/data/case_store.dart';
import 'package:diabetic_foot_app/data/khatwa_store.dart';
import 'package:diabetic_foot_app/data/learn_content.dart';
import 'package:diabetic_foot_app/features/twin/photo_sign_page.dart';
import 'package:diabetic_foot_app/features/twin/scan_page.dart';
import 'package:diabetic_foot_app/features/twin/twin_page.dart';
import 'package:diabetic_foot_app/features/voice/voice_page.dart';
import 'package:diabetic_foot_app/screens/ai_chatbot.dart';
import 'package:diabetic_foot_app/screens/article_page.dart';
import 'package:diabetic_foot_app/screens/feature_pages.dart';
import 'package:diabetic_foot_app/screens/foot_check.dart';
import 'package:diabetic_foot_app/screens/glycemia.dart';
import 'package:diabetic_foot_app/screens/medical_information.dart';
import 'package:diabetic_foot_app/screens/risk_profile_page.dart';
import 'package:diabetic_foot_app/screens/sensory_check.dart';
import 'package:diabetic_foot_app/screens/wellbeing.dart';
import 'package:diabetic_foot_app/screens/auth_pages.dart';
import 'package:diabetic_foot_app/screens/create_account.dart';
import 'package:diabetic_foot_app/screens/settings_page.dart';
import 'package:diabetic_foot_app/screens/shell.dart';
import 'package:diabetic_foot_app/ui/app_state.dart';
import 'package:diabetic_foot_app/ui/app_theme.dart';
import 'package:diabetic_foot_app/ui/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Latin words allowed in an Arabic-script page: brands, units, standards.
const allowedLatin = {
  'Khatwa', 'D', 'SAMU', 'IWGDF', 'FHIR', 'IDF', 'DAR', 'mg', 'dL', 'mmol', 'L', 'HbA', 'c',
  'Future', 'Health', 'Connectathon', 'YouTube', 'USDA', 'INNTA', 'IHE', 'Gazelle', 'kg', 'g', 'cm', 'mm', 'ml', 'mL', 'kcal', 'min', 'h', 'C',
};

/// Arabic-script words allowed in a French or English page: the language
/// names in the language choice.
const allowedArabic = {'تونسي', 'العربية', 'خطوة'};

final _latinWord = RegExp(r'[A-Za-zÀ-ÿ]+');
final _arabicWord = RegExp(r'[؀-ۿ]+');

List<String> _visibleTexts(WidgetTester tester) => [
      for (final w in tester.widgetList<RichText>(find.byType(RichText, skipOffstage: true)))
        w.text.toPlainText(),
    ];

List<String> _mixed(WidgetTester tester, String lang) {
  final rtl = S.isRtl(lang);
  final bad = <String>[];
  for (final text in _visibleTexts(tester)) {
    // An e-mail address or a web address is Latin in every language.
    final cleaned = text.replaceAll(RegExp(r'\S+@\S+|https?://\S+'), '');
    final words = (rtl ? _latinWord : _arabicWord).allMatches(cleaned).map((m) => m.group(0)!);
    final allowed = rtl ? allowedLatin : allowedArabic;
    if (words.any((w) => !allowed.contains(w))) bad.add(text);
  }
  return bad;
}

Widget _app(String lang, Widget home) => MaterialApp(
      theme: K.theme(),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: true),
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
    await AuthStore.instance.init();
    await KhatwaStore.instance.init();
    await CaseStore.instance.init();
    // The voice page's audio plugins have no implementation in tests.
    final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    for (final name in [
      'com.llfbandit.record/messages',
      'xyz.luan/audioplayers',
      'xyz.luan/audioplayers.global',
      'xyz.luan/audioplayers.global/events',
      'flutter_tts',
      'plugin.csdcorp.com/speech_to_text',
    ]) {
      messenger.setMockMethodCallHandler(MethodChannel(name), (call) async => null);
    }
  });

  final pages = <String, Widget Function()>{
    'landing': () => const LandingPage(),
    'sign-in': () => const AuthPage(role: 'patient'),
    'sign-in doctor': () => const AuthPage(role: 'doctor'),
    'sign-up': () => const CreateAccountPage(role: 'patient'),
    'settings': () => const SettingsPage(),
    'article': () => ArticlePage(article: articleById('howto-check')!),
    'article wound': () => ArticlePage(article: articleById('wound')!),
    'voice': () => const VoicePage(),
    'scan': () => const ScanPage(),
    'sole photo': () => const PhotoSignPage(side: 'L', sole: true),
    'sign photo': () => const PhotoSignPage(side: 'L'),
    'sign photo side': () => const PhotoSignPage(),
    'twin': () => const TwinPage(),
    'foot check': () => FootCheckPage(language: appLanguage.value),
    'sensory check': () => SensoryCheckPage(language: appLanguage.value),
    'glycemia': () => GlycemiaPage(language: appLanguage.value),
    'wellbeing': () => WellbeingPage(language: appLanguage.value),
    'risk profile': () => RiskProfilePage(language: appLanguage.value),
    'medical information': () => MedicalInformationPage(language: appLanguage.value),
    'assistant': () => AiChatbotPage(language: appLanguage.value),
    'temperature': () => TemperaturePage(language: appLanguage.value),
    'activity': () => ActivityPage(language: appLanguage.value),
    'food': () => FoodPage(language: appLanguage.value),
    'appointments': () => AppointmentsPage(language: appLanguage.value),
  };

  for (final lang in S.languages) {
    testWidgets('main tabs speak one language: $lang', (tester) async {
      appLanguage.value = lang;
      tester.view.physicalSize = const Size(412, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(_app(lang, const AppShell()));
      await tester.pump(const Duration(milliseconds: 600));
      final problems = <String>[];
      for (final tab in ['tab.today', 'tab.check', 'tab.journal', 'tab.learn', 'tab.me']) {
        await tester.tap(find.text(S.t(lang, tab)).last);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 600));
        problems.addAll(_mixed(tester, lang).map((t) => '$tab: $t'));
      }
      expect(problems, isEmpty);
    });

    for (final page in pages.entries) {
      testWidgets('${page.key} speaks one language: $lang', (tester) async {
        appLanguage.value = lang;
        tester.view.physicalSize = const Size(412, 2400);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(_app(lang, page.value()));
        await tester.pump(const Duration(milliseconds: 300));
        // Pages that call the (absent) server settle on their offline state.
        await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
        await tester.pump(const Duration(milliseconds: 300));
        expect(_mixed(tester, lang), isEmpty);
      });
    }
  }

  testWidgets('switching the language rebuilds a page already on screen', (tester) async {
    appLanguage.value = 'تونسي';
    tester.view.physicalSize = const Size(412, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    // The app's root rebuilds every element when the language changes.
    await tester.pumpWidget(ValueListenableBuilder<String>(
      valueListenable: appLanguage,
      builder: (context, lang, _) => _app(lang, const PhotoSignPage(side: 'L')),
    ));
    await tester.pump();
    appLanguage.value = 'English';
    await tester.pump();
    kRebuildAll(tester.element(find.byType(Navigator)));
    await tester.pump();
    expect(_mixed(tester, 'English'), isEmpty);
    expect(find.text('What is it?'), findsOneWidget);
  });
}
