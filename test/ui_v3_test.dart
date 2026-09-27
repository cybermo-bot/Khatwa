import 'dart:convert';
import 'dart:io';

import 'package:diabetic_foot_app/ui/app_theme.dart';
import 'package:diabetic_foot_app/ui/foot_map.dart';
import 'package:diabetic_foot_app/ui/foot_shapes.dart';
import 'package:diabetic_foot_app/ui/k_image.dart';
import 'package:diabetic_foot_app/ui/sign_art.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('map zones use the zone names of foot_regions.json', () {
    final regions = (jsonDecode(
                File('assets/models/foot_regions.json').readAsStringSync())
            as Map<String, dynamic>)['regions'] as Map<String, dynamic>;
    final zones = FootMapZones.parse(
        File('assets/images/map_zones.json').readAsStringSync());
    for (final view in FootView.values) {
      final byName = zones.zones[view]!;
      expect(byName, isNotEmpty, reason: view.name);
      for (final entry in byName.entries) {
        expect(regions.keys, contains(entry.key));
        expect(entry.value.length, greaterThanOrEqualTo(3));
        for (final p in entry.value) {
          expect(p.dx, inInclusiveRange(0, 1));
          expect(p.dy, inInclusiveRange(0, 1));
        }
      }
    }
  });

  test('right foot zones are the mirror of the left', () {
    final zones = FootMapZones.parse(
        File('assets/images/map_zones.json').readAsStringSync());
    final left = zones.of(FootView.sole, FootSide.left)['hallux']!;
    final right = zones.of(FootView.sole, FootSide.right)['hallux']!;
    expect(right.first.dx, closeTo(1 - left.first.dx, 1e-9));
  });

  test('every article image has a known illustration name', () {
    const names = {
      'sign_dry_skin', 'sign_heel_cracks', 'sign_callus', 'sign_corn',
      'sign_blister', 'sign_fungus', 'sign_ingrown_nail', 'sign_nail_fungus',
      'sign_redness', 'sign_swelling', 'sign_black_toe', 'sign_wound',
      'sign_healthy', 'care_check_mirror', 'care_wash', 'care_dry_toes',
      'care_moisturise', 'care_nails', 'care_shoes', 'care_socks',
      'care_no_barefoot', 'care_move', 'care_touch_test',
    };
    for (final id in ['healthy', 'nails', 'socks-shoes', 'colour', 'beach']) {
      for (final name in articleImages(id)) {
        expect(names, contains(name));
      }
    }
  });

  testWidgets('a missing image shows the placeholder with its label',
      (tester) async {
    K.setDark(true);
    await tester.pumpWidget(MaterialApp(
      theme: K.theme(),
      home: const Scaffold(
        body: SizedBox(
          width: 240,
          height: 200,
          child: KImage('not_there_yet', label: 'Peau sèche'),
        ),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(KImagePlaceholder), findsOneWidget);
    expect(find.text('Peau sèche'), findsOneWidget);
  });

  testWidgets('tapping a zone of the map reports its name', (tester) async {
    K.setDark(true);
    String? tapped;
    await tester.pumpWidget(MaterialApp(
      theme: K.theme(),
      home: Scaffold(
        body: Center(
          child: SizedBox(
            height: 400,
            child: FootMap(
              side: FootSide.left,
              view: FootView.sole,
              onZoneTap: (zone) => tapped = zone,
            ),
          ),
        ),
      ),
    ));
    // The zones load from the asset bundle.
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 200)));
    await tester.pump();
    final box = tester.getRect(find.byType(FootMap));
    // The middle of the heel on a left sole.
    await tester.tapAt(Offset(box.left + box.width * 0.5,
        box.top + box.height * 0.85));
    expect(tapped, 'heel_plantar');
  });
}
