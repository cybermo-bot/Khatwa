// Renders every patient tab to PNG for visual review, without a device.
// Run: flutter test test/render_tabs_test.dart --dart-define=OUT=<folder>
// Uses empty stores: no patient data is created.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:diabetic_foot_app/data/auth_store.dart';
import 'package:diabetic_foot_app/data/case_store.dart';
import 'package:diabetic_foot_app/data/khatwa_store.dart';
import 'package:diabetic_foot_app/data/learn_content.dart';
import 'package:diabetic_foot_app/screens/article_page.dart';
import 'package:diabetic_foot_app/screens/settings_page.dart';
import 'package:diabetic_foot_app/screens/shell.dart';
import 'package:diabetic_foot_app/ui/app_state.dart';
import 'package:diabetic_foot_app/ui/app_theme.dart';
import 'package:diabetic_foot_app/ui/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _out = String.fromEnvironment('OUT', defaultValue: 'build/renders');
const _iconFont = String.fromEnvironment('ICONS');

Future<void> _loadFonts() async {
  final readex = FontLoader('ReadexPro');
  for (final w in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
    readex.addFont(Future.value(ByteData.view(
        File('assets/fonts/ReadexPro-$w.ttf').readAsBytesSync().buffer)));
  }
  await readex.load();
  if (_iconFont.isNotEmpty) {
    final icons = FontLoader('MaterialIcons')
      ..addFont(Future.value(ByteData.view(File(_iconFont).readAsBytesSync().buffer)));
    await icons.load();
  }
}

Future<void> _capture(WidgetTester tester, GlobalKey key, String name) async {
  await tester.runAsync(() async {
    final boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 2);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    Directory(_out).createSync(recursive: true);
    File('$_out/$name.png').writeAsBytesSync(bytes!.buffer.asUint8List());
  });
}

Widget _frame(GlobalKey key, String lang, Widget child, {double scale = 1}) {
  return RepaintBoundary(
    key: key,
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: K.theme(),
      builder: (context, c) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(disableAnimations: true, textScaler: TextScaler.linear(scale)),
        child: Directionality(
          textDirection: S.isRtl(lang) ? TextDirection.rtl : TextDirection.ltr,
          child: c!,
        ),
      ),
      home: child,
    ),
  );
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await KhatwaStore.instance.init();
    await AuthStore.instance.init();
    await CaseStore.instance.init();
    await _loadFonts();
  });

  final runs = [
    ('dz_light', 'تونسي', false, 1.0, 'medium'),
    ('dz_dark', 'تونسي', true, 1.0, 'medium'),
    ('fr_light', 'Français', false, 1.0, 'medium'),
    ('fr_large', 'Français', false, 1.3, 'medium'),
    ('fr_deep', 'Français', false, 1.0, 'deep'),
  ];
  const articleIds = [
    'dry-skin', 'heel-cracks', 'callus', 'corn', 'blister', 'fungus', 'nails', 'redness',
    'swelling', 'colour', 'wound', 'numbness', 'wash', 'dry', 'moisturise', 'nail-care',
    'socks-shoes', 'move', 'howto-check', 'when-doctor',
  ];
  const tabs = ['tab.today', 'tab.check', 'tab.journal', 'tab.learn', 'tab.me'];

  for (final (tag, lang, dark, scale, tone) in runs) {
    for (final full in [false, true]) {
      testWidgets('tabs $tag ${full ? 'full' : 'fold'}', (tester) async {
        K.setDark(dark);
        appLanguage.value = lang;
        appSkinTone.value = tone;
        tester.view.devicePixelRatio = 2;
        tester.view.physicalSize = Size(412 * 2, (full ? 2400 : 915) * 2.0);
        addTearDown(tester.view.reset);

        final key = GlobalKey();
        await tester.pumpWidget(_frame(key, lang, const AppShell(), scale: scale));
        await tester.pump(const Duration(milliseconds: 600));
        for (final t in tabs) {
          await tester.tap(find.text(S.t(lang, t)).last);
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 600));
          await tester.pump(const Duration(milliseconds: 600));
          await _capture(tester, key, '${tag}_${full ? 'full' : 'fold'}_${t.split('.').last}');
        }
        if (!full) {
          await tester.tap(find.text(S.t(lang, 'tab.journal')).last);
          await tester.pump(const Duration(milliseconds: 600));
          await tester.tap(find.text(S.t(lang, 'journal.log')).first);
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 800));
          await tester.tap(find.text(S.t(lang, 'sym.swelling')));
          await tester.tap(find.text(S.t(lang, 'sym.tingling')));
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 600));
          await tester.pump(const Duration(milliseconds: 600));
          await _capture(tester, key, '${tag}_journal_sheet');
        }
      });
    }

    testWidgets('articles $tag', (tester) async {
      K.setDark(dark);
      appLanguage.value = lang;
      appSkinTone.value = tone;
      tester.view.devicePixelRatio = 2;
      tester.view.physicalSize = const Size(412 * 2, 2000 * 2.0);
      addTearDown(tester.view.reset);
      for (final id in articleIds) {
        final key = GlobalKey();
        await tester.pumpWidget(_frame(key, lang, ArticlePage(article: articleById(id)!), scale: scale));
        await tester.pump(const Duration(milliseconds: 600));
        await _capture(tester, key, '${tag}_article_$id');
      }
      final key = GlobalKey();
      await tester.pumpWidget(_frame(key, lang, const SettingsPage(), scale: scale));
      await tester.pump(const Duration(milliseconds: 600));
      await _capture(tester, key, '${tag}_settings');
    });
  }
}
