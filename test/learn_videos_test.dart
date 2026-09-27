import 'package:diabetic_foot_app/data/learn_content.dart';
import 'package:diabetic_foot_app/data/learn_videos.dart';
import 'package:diabetic_foot_app/screens/learn_video.dart';
import 'package:diabetic_foot_app/ui/app_state.dart';
import 'package:diabetic_foot_app/ui/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every video has a YouTube id, a language, a title and belongs to a real article', () {
    for (final entry in learnVideos.entries) {
      expect(articleById(entry.key), isNotNull, reason: entry.key);
      for (final v in entry.value) {
        expect(RegExp(r'^[\w-]{11}$').hasMatch(v.id), isTrue, reason: v.id);
        expect(const ['ar', 'fr', 'en'], contains(v.lang));
        expect(v.title.trim(), isNotEmpty);
        expect(v.thumbnail, 'https://img.youtube.com/vi/${v.id}/hqdefault.jpg');
      }
    }
  });

  test('a video that is not verified is never shown', () {
    for (final id in learnVideos.keys) {
      final shown = videoFor(id, 'fr');
      expect(shown == null || shown.verified, isTrue);
    }
  });

  testWidgets('without a verified video the slot keeps its placeholder', (tester) async {
    await tester.pumpWidget(MaterialApp(
        theme: K.theme(),
        home: const Scaffold(body: ArticleVideo(articleId: 'no-such-article', placeholder: Text('placeholder')))));
    expect(find.text('placeholder'), findsOneWidget);
  });

  Future<void> show(WidgetTester tester, LearnVideo v) async {
    await tester.pumpWidget(MaterialApp(
        theme: K.theme(),
        home: Scaffold(
            body: SingleChildScrollView(child: ArticleVideo(articleId: 'x', placeholder: const Text('placeholder'), video: v)))));
    await tester.pump();
  }

  testWidgets('a verified video in the page language shows its title and the external note', (tester) async {
    appLanguage.value = 'Français';
    await show(tester, const LearnVideo('abcdefghijk', 'fr', title: 'Le soin des pieds', channel: 'Test', verified: true));
    expect(find.text('placeholder'), findsNothing);
    expect(find.text('Le soin des pieds'), findsOneWidget);
    expect(find.text('Vidéo externe, choisie par l’équipe Khatwa'), findsOneWidget);
    expect(find.text('Ouvrir sur YouTube'), findsOneWidget);
  });

  testWidgets('a video in another language shows its language, not its title', (tester) async {
    appLanguage.value = 'Français';
    await show(tester, const LearnVideo('abcdefghijk', 'en', title: 'Daily foot check', channel: 'Test', verified: true));
    expect(find.text('Daily foot check'), findsNothing);
    expect(find.text('Vidéo en anglais'), findsOneWidget);
    expect(find.text('Vidéo externe, choisie par l’équipe Khatwa'), findsOneWidget);
  });
}
