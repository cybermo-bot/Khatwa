import 'dart:ui';

import 'package:flutter/material.dart';

/// "Clinical futuristic" look of the doctor dashboard: deep navy, teal glows,
/// frosted glass cards. Dark by default, light as an option. Self contained
/// so it does not depend on the patient app theme.
class DPalette {
  final Brightness brightness;
  final Color ground;
  final Color groundDeep;
  final Color glass;
  final Color glassBorder;
  final Color ink;
  final Color inkSoft;
  final Color muted;
  final Color primary;
  final Color glow;
  final Color mint;
  final Color onPrimary;
  final Color urgent;
  final Color urgentSoft;
  final Color soon;
  final Color soonSoft;
  final Color ok;
  final Color okSoft;

  const DPalette({
    required this.brightness,
    required this.ground,
    required this.groundDeep,
    required this.glass,
    required this.glassBorder,
    required this.ink,
    required this.inkSoft,
    required this.muted,
    required this.primary,
    required this.glow,
    required this.mint,
    required this.onPrimary,
    required this.urgent,
    required this.urgentSoft,
    required this.soon,
    required this.soonSoft,
    required this.ok,
    required this.okSoft,
  });

  bool get isDark => brightness == Brightness.dark;

  static const dark = DPalette(
    brightness: Brightness.dark,
    ground: Color(0xFF0C1F29),
    groundDeep: Color(0xFF07131A),
    glass: Color(0x1FFFFFFF),
    glassBorder: Color(0x2EFFFFFF),
    ink: Color(0xFFF1F7F6),
    inkSoft: Color(0xFFC9DAD9),
    muted: Color(0xFF93AAAE),
    primary: Color(0xFF19C3B5),
    glow: Color(0xFF19C3B5),
    mint: Color(0xFF9FE8D8),
    onPrimary: Color(0xFF03211F),
    urgent: Color(0xFFFF7A6E),
    urgentSoft: Color(0x33FF5A4E),
    soon: Color(0xFFF2C063),
    soonSoft: Color(0x2EF2B23D),
    ok: Color(0xFF8FDCA0),
    okSoft: Color(0x2659C477),
  );

  static const light = DPalette(
    brightness: Brightness.light,
    ground: Color(0xFFEFF4F5),
    groundDeep: Color(0xFFE2ECEE),
    glass: Color(0xB3FFFFFF),
    glassBorder: Color(0xFFD4E0E2),
    ink: Color(0xFF10232B),
    inkSoft: Color(0xFF34494F),
    muted: Color(0xFF55696F),
    primary: Color(0xFF0E5A66),
    glow: Color(0xFF19C3B5),
    mint: Color(0xFF0B6B5F),
    onPrimary: Color(0xFFFFFFFF),
    urgent: Color(0xFFB8322A),
    urgentSoft: Color(0xFFFBE4E1),
    soon: Color(0xFF8A5500),
    soonSoft: Color(0xFFFBEDD5),
    ok: Color(0xFF2F6F1A),
    okSoft: Color(0xFFE3F1DA),
  );

  static DPalette of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;

  Color level(String level) => switch (level) {
        'urgent' || 'red' => urgent,
        'soon' || 'amber' => soon,
        'green' || 'none' => ok,
        _ => muted,
      };

  Color levelSoft(String level) => switch (level) {
        'urgent' || 'red' => urgentSoft,
        'soon' || 'amber' => soonSoft,
        'green' || 'none' => okSoft,
        _ => glass,
      };

  Color risk(int? risk) => switch (risk) {
        3 => urgent,
        2 => soon,
        1 => mint,
        _ => ok,
      };

  ThemeData theme() {
    final scheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: brightness,
      primary: primary,
      onPrimary: onPrimary,
      surface: ground,
      onSurface: ink,
      error: urgent,
    );
    const family = 'ReadexPro';
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      fontFamily: family,
      scaffoldBackgroundColor: groundDeep,
      textTheme: ThemeData(brightness: brightness).textTheme.apply(
            fontFamily: family,
            bodyColor: ink,
            displayColor: ink,
          ),
      dividerColor: glassBorder,
      sliderTheme: SliderThemeData(
        activeTrackColor: primary,
        thumbColor: primary,
        inactiveTrackColor: glassBorder,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: glass,
        hintStyle: TextStyle(color: muted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: glassBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: glassBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          textStyle: const TextStyle(fontFamily: family, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ink,
          side: BorderSide(color: glassBorder),
          textStyle: const TextStyle(fontFamily: family, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      dialogTheme: DialogThemeData(backgroundColor: ground),
    );
  }
}

class DText {
  static const tabular = [FontFeature.tabularFigures()];

  static TextStyle kpi(DPalette p, Color color) => TextStyle(
      fontSize: 34, height: 1.05, fontWeight: FontWeight.w700, color: color, fontFeatures: tabular);
  static TextStyle title(DPalette p) =>
      TextStyle(fontSize: 22, height: 1.25, fontWeight: FontWeight.w600, color: p.ink);
  static TextStyle h2(DPalette p) =>
      TextStyle(fontSize: 17, height: 1.3, fontWeight: FontWeight.w600, color: p.ink);
  static TextStyle body(DPalette p) => TextStyle(fontSize: 15, height: 1.45, color: p.inkSoft);
  static TextStyle strong(DPalette p) =>
      TextStyle(fontSize: 15, height: 1.4, fontWeight: FontWeight.w600, color: p.ink);
  static TextStyle small(DPalette p) =>
      TextStyle(fontSize: 13, height: 1.35, color: p.muted, fontFeatures: tabular);
  static TextStyle label(DPalette p) => TextStyle(
      fontSize: 12, height: 1.3, fontWeight: FontWeight.w600, letterSpacing: 0.6, color: p.muted);
}

const dRadius = 24.0;
const dMotion = Duration(milliseconds: 240);

/// Deep background with two soft radial lights.
class DBackground extends StatelessWidget {
  final Widget child;

  const DBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final p = DPalette.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [p.ground, p.groundDeep],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(-0.85, -0.9),
                    radius: 0.9,
                    colors: [p.glow.withValues(alpha: p.isDark ? 0.18 : 0.12), p.glow.withValues(alpha: 0)],
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0.9, 0.8),
                    radius: 0.8,
                    colors: [p.mint.withValues(alpha: p.isDark ? 0.10 : 0.08), p.mint.withValues(alpha: 0)],
                  ),
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

/// Frosted glass card: blur, 1 px light border, soft inner glow.
class GlassPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? tint;
  final Color? borderColor;
  final VoidCallback? onTap;
  final double radius;

  const GlassPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.tint,
    this.borderColor,
    this.onTap,
    this.radius = dRadius,
  });

  @override
  Widget build(BuildContext context) {
    final p = DPalette.of(context);
    final shape = BorderRadius.circular(radius);
    Widget content = Padding(padding: padding, child: child);
    if (onTap != null) {
      content = Material(
        type: MaterialType.transparency,
        child: InkWell(borderRadius: shape, onTap: onTap, child: content),
      );
    }
    return ClipRRect(
      borderRadius: shape,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: AnimatedContainer(
          duration: dMotion,
          decoration: BoxDecoration(
            borderRadius: shape,
            border: Border.all(color: borderColor ?? p.glassBorder),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.alphaBlend(tint ?? Colors.transparent, p.glass),
                p.glass.withValues(alpha: p.glass.a * (p.isDark ? 0.55 : 0.9)),
              ],
            ),
          ),
          child: content,
        ),
      ),
    );
  }
}

/// Small rounded tag.
class DTag extends StatelessWidget {
  final String text;
  final Color color;
  final Color background;
  final IconData? icon;

  const DTag(this.text, {super.key, required this.color, required this.background, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color),
            ),
          ),
        ],
      ),
    );
  }
}

class DSectionTitle extends StatelessWidget {
  final String text;
  final Widget? trailing;

  const DSectionTitle(this.text, {super.key, this.trailing});

  @override
  Widget build(BuildContext context) {
    final p = DPalette.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(child: Text(text.toUpperCase(), style: DText.label(p))),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// A pulsing dot, for new alerts.
class LivePulse extends StatefulWidget {
  final Color color;
  final double size;

  const LivePulse({super.key, required this.color, this.size = 10});

  @override
  State<LivePulse> createState() => _LivePulseState();
}

class _LivePulseState extends State<LivePulse> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
      _c.stop();
    } else if (!_c.isAnimating) {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.size;
    return SizedBox(
      width: s * 2.4,
      height: s * 2.4,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) => Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: s * (1 + 1.4 * _c.value),
              height: s * (1 + 1.4 * _c.value),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color.withValues(alpha: 0.45 * (1 - _c.value)),
              ),
            ),
            Container(
              width: s,
              height: s,
              decoration: BoxDecoration(shape: BoxShape.circle, color: widget.color),
            ),
          ],
        ),
      ),
    );
  }
}
