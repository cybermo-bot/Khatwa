import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_theme.dart';

/// An illustration from `assets/images/<name>.webp`.
///
/// The images are made outside the code and some may not be there yet, so a
/// missing file never breaks a screen: it shows a quiet glass tile with an
/// icon and, when given, a short label. The app looks finished either way.
class KImage extends StatelessWidget {
  final String name;
  final String? label;
  final IconData? icon;
  final BoxFit fit;
  final double? width;
  final double? height;
  final double radius;
  final bool mirror;
  final Alignment alignment;

  /// Draws nothing behind a missing image instead of the glass tile, for
  /// callers that bring their own placeholder.
  final Widget? placeholder;

  const KImage(
    this.name, {
    super.key,
    this.label,
    this.icon,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.radius = K.r20,
    this.mirror = false,
    this.alignment = Alignment.center,
    this.placeholder,
  });

  static String path(String name) => 'assets/images/$name.webp';

  /// The bundled asset paths, read once from the asset manifest.
  static final ValueNotifier<Set<String>?> _assets = ValueNotifier(null);
  static bool _loading = false;

  /// The bundled asset paths, null until read. Listen to it to react when a
  /// placeholder can become an image.
  static ValueListenable<Set<String>?> get assets {
    _load();
    return _assets;
  }

  static void _load() {
    if (_loading) return;
    _loading = true;
    AssetManifest.loadFromAssetBundle(rootBundle).then(
      (manifest) => _assets.value = manifest.listAssets().toSet(),
      onError: (Object _) => _assets.value = const {},
    );
  }

  /// Whether `assets/images/<name>.webp` is bundled. Null until the manifest
  /// has been read.
  static bool? exists(String name) => _assets.value?.contains(path(name));

  static IconData iconFor(String name) {
    const specific = {
      'sign_dry_skin': Icons.water_drop_outlined,
      'sign_heel_cracks': Icons.texture_rounded,
      'sign_callus': Icons.layers_outlined,
      'sign_corn': Icons.adjust_rounded,
      'sign_blister': Icons.bubble_chart_outlined,
      'sign_fungus': Icons.grain_rounded,
      'sign_ingrown_nail': Icons.content_cut_rounded,
      'sign_nail_fungus': Icons.content_cut_rounded,
      'sign_redness': Icons.local_fire_department_outlined,
      'sign_swelling': Icons.expand_rounded,
      'sign_black_toe': Icons.contrast_rounded,
      'sign_wound': Icons.healing_outlined,
      'sign_healthy': Icons.favorite_outline_rounded,
      'care_check_mirror': Icons.search_rounded,
      'care_wash': Icons.shower_outlined,
      'care_dry_toes': Icons.dry_outlined,
      'care_moisturise': Icons.spa_outlined,
      'care_nails': Icons.content_cut_rounded,
      'care_shoes': Icons.checkroom_outlined,
      'care_socks': Icons.checkroom_outlined,
      'care_no_barefoot': Icons.do_not_step_rounded,
      'care_move': Icons.directions_walk_rounded,
      'care_touch_test': Icons.touch_app_outlined,
      'scan_setup': Icons.phone_android_rounded,
      'scan_helper': Icons.people_outline_rounded,
      'scan_sole': Icons.photo_camera_outlined,
      'hero_twin': Icons.view_in_ar_outlined,
      'hero_doctor': Icons.medical_services_outlined,
    };
    return specific[name] ?? Icons.image_outlined;
  }

  @override
  Widget build(BuildContext context) {
    _load();
    return ValueListenableBuilder<Set<String>?>(
      valueListenable: _assets,
      builder: (context, assets, _) {
        final fallback = placeholder ??
            KImagePlaceholder(
              icon: icon ?? iconFor(name),
              label: label,
              radius: radius,
            );
        Widget child;
        if (assets == null || !assets.contains(path(name))) {
          child =
              KeyedSubtree(key: const ValueKey('placeholder'), child: fallback);
        } else {
          child = ClipRRect(
            key: const ValueKey('image'),
            borderRadius: BorderRadius.circular(radius),
            child: Image.asset(
              path(name),
              fit: fit,
              alignment: alignment,
              width: width,
              height: height,
              semanticLabel: label,
              errorBuilder: (context, _, __) => fallback,
            ),
          );
          if (mirror) child = Transform.flip(flipX: true, child: child);
        }
        return SizedBox(
          width: width,
          height: height,
          child: AnimatedSwitcher(
            duration: KMotion.standard,
            child: child,
          ),
        );
      },
    );
  }
}

/// The stand-in for an image that is not there yet: a glass tile with a soft
/// teal light, an icon, and an optional short label.
class KImagePlaceholder extends StatelessWidget {
  final IconData icon;
  final String? label;
  final double radius;

  const KImagePlaceholder(
      {super.key, required this.icon, this.label, this.radius = K.r20});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final shortest = constraints.biggest.shortestSide.isFinite
          ? constraints.biggest.shortestSide
          : 120.0;
      final iconSize = (shortest * 0.34).clamp(16.0, 56.0);
      final showLabel = label != null && shortest >= 96;
      return Semantics(
        image: true,
        label: label,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            gradient: RadialGradient(
              center: const Alignment(-0.4, -0.6),
              radius: 1.2,
              colors: [K.glow.withAlpha(K.isDark ? 46 : 34), K.glass],
            ),
            border: Border.all(color: K.glassBorder),
          ),
          alignment: Alignment.center,
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: iconSize, color: K.primary),
              if (showLabel) ...[
                const SizedBox(height: 8),
                Text(
                  label!,
                  style: K.small.copyWith(color: K.inkSoft),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      );
    });
  }
}
