// The pages every screen check renders.
import 'package:diabetic_foot_app/data/auth_store.dart';
import 'package:diabetic_foot_app/data/case_store.dart';
import 'package:diabetic_foot_app/data/khatwa_store.dart';
import 'package:diabetic_foot_app/data/learn_content.dart';
import 'package:diabetic_foot_app/features/diet/diet_data.dart';
import 'package:diabetic_foot_app/features/diet/diet_page.dart';
import 'package:diabetic_foot_app/features/diet/diet_topics.dart';
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
import 'package:diabetic_foot_app/screens/onboarding.dart';
import 'package:diabetic_foot_app/screens/risk_profile_page.dart';
import 'package:diabetic_foot_app/screens/sensory_check.dart';
import 'package:diabetic_foot_app/screens/wellbeing.dart';
import 'package:diabetic_foot_app/screens/auth_pages.dart';
import 'package:diabetic_foot_app/screens/create_account.dart';
import 'package:diabetic_foot_app/screens/settings_page.dart';
import 'package:diabetic_foot_app/ui/app_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Empty stores, and the voice page's audio plugins answered in tests.
Future<void> setUpScreens() async {
  SharedPreferences.setMockInitialValues({});
  await AuthStore.instance.init();
  await KhatwaStore.instance.init();
  await CaseStore.instance.init();
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
}

Map<String, Widget Function()> screens() {
  return <String, Widget Function()>{
    'onboarding': () => const OnboardingPage(),
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
    'diet': () => const DietPage(),
    'diet foods': () => const FoodListPage(),
    'diet plate': () => DietTopicPage(topic: dietTopic('plate')),
    'diet ramadan': () => DietTopicPage(topic: dietTopic('ramadan')),
    'diet hypo': () => DietTopicPage(topic: dietTopic('hypo')),
    'diet feet': () => DietTopicPage(topic: dietTopic('feet')),
    'diet sheet': () => Scaffold(body: FoodSheet(food: tunisianFoods.first)),
  };
}
