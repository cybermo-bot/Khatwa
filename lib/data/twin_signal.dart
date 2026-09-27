import 'dart:async';

import 'khatwa_server.dart';

/// What the 3D twin adds to a daily check: a measured growth of the foot
/// since the first scan, beyond the measurement noise (the server's MDC95
/// thresholds). The scan sees shape only, never colour or warmth, so it is
/// supporting context for the rules and the AI, not a finding on its own.
///
/// Fails softly: no server, no scans or a slow answer give no signal.
class TwinSignal {
  /// Measurements whose growth means the foot is more swollen.
  static const swellingKeys = {
    'volume_to_8cm_ml': 'volume up to 8 cm',
    'ball_girth_mm': 'ball girth',
    'ball_width_mm': 'ball width',
    'heel_width_mm': 'heel width',
    'instep_height_mm': 'instep height',
  };

  /// Answers to merge into the check: `twin_swelling` (bool) and, when true,
  /// `twin_detail`, one English line per foot for the clinician and the AI.
  static Future<Map<String, dynamic>> answers({KhatwaServer? server}) async {
    final s = server ?? KhatwaServer();
    final lines = <String>[];
    Future<void> side(String code, String name) async {
      try {
        final c = await s.change(code).timeout(const Duration(seconds: 6));
        final line = describe(c);
        if (line != null) lines.add('$name foot: $line');
      } catch (_) {
        // No server, a single scan so far, or a timeout: nothing to add.
      }
    }

    await Future.wait([side('L', 'Left'), side('R', 'Right')]);
    return {
      'twin_swelling': lines.isNotEmpty,
      if (lines.isNotEmpty) 'twin_detail': '${lines.join('; ')} (3D scan, since the first scan, beyond measurement noise)',
    };
  }

  /// The swelling part of one change report, or null when there is none.
  static String? describe(Map<String, dynamic> change) {
    final significant = ((change['significant_measurements'] as List?) ?? const []).cast<String>();
    final values = (change['measurements'] as Map?) ?? const {};
    final parts = <String>[];
    for (final key in significant) {
      final v = values[key];
      final name = swellingKeys[key];
      if (name == null || v is! num || v <= 0) continue;
      parts.add('$name +${v.round()} ${key.endsWith('_ml') ? 'mL' : 'mm'}');
    }
    return parts.isEmpty ? null : parts.join(', ');
  }
}
