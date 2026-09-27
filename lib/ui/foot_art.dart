import 'package:flutter/material.dart';

import 'app_state.dart';
import 'app_theme.dart';
import 'foot_map.dart';
import 'foot_shapes.dart';

/// Skin tones the patient can pick in Settings. Since design v3 the feet are
/// images, not drawings, so the tone only colours the swatch in Settings;
/// the choice is kept so nothing the patient set is lost.
class SkinTone {
  final String name;
  final Color base;
  final Color light;
  final Color shade;
  final Color pad;
  final Color nail;

  const SkinTone({
    required this.name,
    required this.base,
    required this.light,
    required this.shade,
    required this.pad,
    required this.nail,
  });

  static const fair = SkinTone(
    name: 'fair',
    base: Color(0xFFF0CBAE),
    light: Color(0xFFF8DECA),
    shade: Color(0xFFD1A07F),
    pad: Color(0xFFF8D5C2),
    nail: Color(0xFFFBEADF),
  );

  static const medium = SkinTone(
    name: 'medium',
    base: Color(0xFFE2AE88),
    light: Color(0xFFF0C9A8),
    shade: Color(0xFFBF855F),
    pad: Color(0xFFF2C2A6),
    nail: Color(0xFFF7DDCD),
  );

  static const deep = SkinTone(
    name: 'deep',
    base: Color(0xFF9C6644),
    light: Color(0xFFB57C57),
    shade: Color(0xFF74472C),
    pad: Color(0xFFB98163),
    nail: Color(0xFFD7B19A),
  );

  static const all = [fair, medium, deep];

  /// The tone the patient chose in Settings.
  static SkinTone get current =>
      all.firstWhere((t) => t.name == appSkinTone.value, orElse: () => medium);

  bool get isDeep => name == 'deep';
}

/// Places on the foot the app talks about. On the maps they light up the
/// zones listed in [FootZoneRegions].
enum FootZone {
  toes,
  betweenToes,
  nails,
  ball,
  arch,
  heel,
  top,
  outerEdge,
  innerEdge
}

/// The four photos of a daily check, in capture order: right sole, left sole,
/// right top, left top. Taken ones carry a check; the next one breathes.
/// Each position shows the map image of that foot and view.
class PhotoPositions extends StatelessWidget {
  final int taken;
  final double pulse;
  final double footHeight;
  final Color ground;
  final List<String> labels;
  final bool showNext;

  const PhotoPositions({
    super.key,
    required this.taken,
    required this.ground,
    required this.labels,
    this.pulse = 0,
    this.footHeight = 128,
    this.showNext = true,
  });

  static const order = [
    (FootSide.right, FootView.sole),
    (FootSide.left, FootView.sole),
    (FootSide.right, FootView.top),
    (FootSide.left, FootView.top),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (var i = 0; i < order.length; i++)
          Expanded(
            child: Semantics(
              label: labels.length > i ? labels[i] : '${i + 1}',
              checked: i < taken,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: KMotion.standard,
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(K.r14),
                        color: showNext && i == taken
                            ? K.glow.withAlpha((18 + 30 * pulse).round())
                            : Colors.transparent,
                        border: Border.all(
                          width: 1.5,
                          color: showNext && i == taken
                              ? K.glow.withAlpha((120 + 135 * pulse).round())
                              : Colors.transparent,
                        ),
                      ),
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.bottomCenter,
                        children: [
                          SizedBox(
                            height: footHeight,
                            child:
                                FootMap(side: order[i].$1, view: order[i].$2),
                          ),
                          if (i < taken)
                            Positioned(
                              bottom: -4,
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: K.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: ground, width: 2.5),
                                ),
                                child: Icon(Icons.check_rounded,
                                    size: 17, color: K.onPrimary),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${i + 1}',
                      style: K.label.copyWith(
                        color: i <= taken ? K.primaryStrong : K.inkSoft,
                        fontFeatures: const [FontFeature.tabularFigures()],
                        fontWeight: showNext && i == taken
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
