import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Khatwa design system.
///
/// Petrol and skin: a cool morning ground, white surfaces, deep ink and one
/// petrol blue for action. Skin tones live only in the foot illustrations.
/// Night is a deep petrol dark with the same roles, lifted.
/// Green, amber and red only ever mean a triage level; nothing decorative
/// borrows them. Everything the app draws goes through these tokens.
class KPalette {
  final Color ground;
  final Color surface;
  final Color surfaceMuted;
  final Color ink;
  final Color inkSoft;
  final Color muted;
  final Color line;
  /// Border of a control the patient must find (tick circle, field, chip):
  /// at least 3:1 against surface and ground.
  final Color control;
  final Color primary;
  final Color primaryStrong;
  final Color primarySoft;
  final Color onPrimary;
  final Color accent;
  final Color accentSoft;
  final Color ok;
  final Color okSoft;
  final Color warn;
  final Color warnSoft;
  final Color danger;
  final Color dangerSoft;
  final Color shadow;

  const KPalette({
    required this.ground,
    required this.surface,
    required this.surfaceMuted,
    required this.ink,
    required this.inkSoft,
    required this.muted,
    required this.line,
    required this.control,
    required this.primary,
    required this.primaryStrong,
    required this.primarySoft,
    required this.onPrimary,
    required this.accent,
    required this.accentSoft,
    required this.ok,
    required this.okSoft,
    required this.warn,
    required this.warnSoft,
    required this.danger,
    required this.dangerSoft,
    required this.shadow,
  });

  static const light = KPalette(
    ground: Color(0xFFF2F4F5),
    surface: Color(0xFFFFFFFF),
    surfaceMuted: Color(0xFFE8EDEF),
    ink: Color(0xFF14232A),
    inkSoft: Color(0xFF3F5058),
    muted: Color(0xFF5F6F76),
    line: Color(0xFFDDE4E7),
    control: Color(0xFF76878E),
    primary: Color(0xFF0E5A66),
    primaryStrong: Color(0xFF0A434D),
    primarySoft: Color(0xFFDDECEE),
    onPrimary: Color(0xFFFFFFFF),
    accent: Color(0xFF7A4A88),
    accentSoft: Color(0xFFF2EAF5),
    ok: Color(0xFF3A7D1F),
    okSoft: Color(0xFFE6F2DC),
    warn: Color(0xFF9A5E00),
    warnSoft: Color(0xFFFBEDD5),
    danger: Color(0xFFC0352B),
    dangerSoft: Color(0xFFFBE7E4),
    shadow: Color(0xFF14323A),
  );

  static const dark = KPalette(
    ground: Color(0xFF0C1417),
    surface: Color(0xFF132126),
    surfaceMuted: Color(0xFF1A2B31),
    ink: Color(0xFFE9F0F1),
    inkSoft: Color(0xFFB3C2C6),
    muted: Color(0xFF8CA0A5),
    line: Color(0xFF22363C),
    control: Color(0xFF5E7880),
    primary: Color(0xFF6FC3CE),
    primaryStrong: Color(0xFF9ADBE3),
    primarySoft: Color(0xFF173B42),
    onPrimary: Color(0xFF062A30),
    accent: Color(0xFFD2A6E0),
    accentSoft: Color(0xFF2F2437),
    ok: Color(0xFF8BD06A),
    okSoft: Color(0xFF1C2E14),
    warn: Color(0xFFEAB55A),
    warnSoft: Color(0xFF33280F),
    danger: Color(0xFFF2857B),
    dangerSoft: Color(0xFF3A1C1A),
    shadow: Color(0xFF000000),
  );
}

class K {
  static KPalette _p = KPalette.light;
  static bool _dark = false;

  static bool get isDark => _dark;

  /// Switches the palette. Call [kRebuildAll] afterwards so widgets that read
  /// the tokens directly pick up the new values.
  static void setDark(bool dark) {
    _dark = dark;
    _p = dark ? KPalette.dark : KPalette.light;
  }

  // ---- palette ----
  static Color get ground => _p.ground;
  static Color get surface => _p.surface;
  static Color get surfaceMuted => _p.surfaceMuted;
  static Color get ink => _p.ink;
  static Color get inkSoft => _p.inkSoft;
  static Color get muted => _p.muted;
  static Color get line => _p.line;
  static Color get control => _p.control;
  static Color get primary => _p.primary;
  static Color get primaryStrong => _p.primaryStrong;
  static Color get primarySoft => _p.primarySoft;
  static Color get onPrimary => _p.onPrimary;
  static Color get accent => _p.accent;
  static Color get accentSoft => _p.accentSoft;
  static Color get ok => _p.ok;
  static Color get okSoft => _p.okSoft;
  static Color get warn => _p.warn;
  static Color get warnSoft => _p.warnSoft;
  static Color get danger => _p.danger;
  static Color get dangerSoft => _p.dangerSoft;

  // Earlier names, kept so every screen keeps compiling during the redesign.
  static Color get paper => _p.ground;
  static Color get card => _p.surface;
  static Color get primaryDark => _p.primaryStrong;

  /// One soft, low shadow for raised surfaces. Night uses tone instead.
  static List<BoxShadow> get lift => _dark
      ? const []
      : [
          BoxShadow(
              color: _p.shadow.withAlpha(14),
              blurRadius: 24,
              offset: const Offset(0, 8)),
          BoxShadow(
              color: _p.shadow.withAlpha(10),
              blurRadius: 3,
              offset: const Offset(0, 1)),
        ];

  // ---- radius ----
  static const r8 = 8.0;
  static const r12 = 12.0;
  static const r14 = 16.0;
  static const r20 = 24.0;
  static const r28 = 28.0;

  // ---- type ----
  static const family = 'ReadexPro';

  static TextStyle get display => TextStyle(
      fontFamily: family,
      fontSize: 34,
      height: 1.12,
      fontWeight: FontWeight.w600,
      color: ink);
  static TextStyle get h1 => TextStyle(
      fontFamily: family,
      fontSize: 26,
      height: 1.2,
      fontWeight: FontWeight.w600,
      color: ink);
  static TextStyle get h2 => TextStyle(
      fontFamily: family,
      fontSize: 19,
      height: 1.3,
      fontWeight: FontWeight.w600,
      color: ink);
  static TextStyle get body =>
      TextStyle(fontFamily: family, fontSize: 17, height: 1.5, color: inkSoft);
  static TextStyle get bodyStrong => TextStyle(
      fontFamily: family,
      fontSize: 17,
      height: 1.45,
      fontWeight: FontWeight.w500,
      color: ink);
  static TextStyle get small =>
      TextStyle(fontFamily: family, fontSize: 14.5, height: 1.4, color: muted);
  static TextStyle get label => TextStyle(
      fontFamily: family,
      fontSize: 13.5,
      height: 1.3,
      fontWeight: FontWeight.w500,
      color: muted);

  static ThemeData theme() {
    // Every Material 3 role is set, so stock components (chips, sheets,
    // segmented buttons, the FAB) resolve to petrol and tide instead of
    // colours derived from the clinician accent.
    final scheme = ColorScheme(
      brightness: _dark ? Brightness.dark : Brightness.light,
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: primarySoft,
      onPrimaryContainer: primaryStrong,
      secondary: primary,
      onSecondary: onPrimary,
      secondaryContainer: primarySoft,
      onSecondaryContainer: primaryStrong,
      tertiary: accent,
      onTertiary: onPrimary,
      tertiaryContainer: accentSoft,
      onTertiaryContainer: accent,
      surface: surface,
      onSurface: ink,
      onSurfaceVariant: inkSoft,
      surfaceDim: ground,
      surfaceBright: surface,
      surfaceContainerLowest: surface,
      surfaceContainerLow: surface,
      surfaceContainer: surface,
      surfaceContainerHigh: surfaceMuted,
      surfaceContainerHighest: surfaceMuted,
      surfaceTint: Colors.transparent,
      outline: control,
      outlineVariant: line,
      shadow: _p.shadow,
      scrim: Colors.black,
      inverseSurface: ink,
      onInverseSurface: surface,
      inversePrimary: _dark ? KPalette.light.primary : KPalette.dark.primary,
      error: danger,
      onError: _dark ? const Color(0xFF2A0D0A) : Colors.white,
      errorContainer: dangerSoft,
      onErrorContainer: danger,
    );

    final buttonShape =
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(18));

    return ThemeData(
      useMaterial3: true,
      brightness: scheme.brightness,
      colorScheme: scheme,
      fontFamily: family,
      scaffoldBackgroundColor: ground,
      splashFactory: InkSparkle.splashFactory,
      highlightColor: Colors.transparent,
      dividerColor: line,
      textTheme: TextTheme(
        headlineMedium: display,
        titleLarge: h1,
        titleMedium: h2,
        bodyLarge: body,
        bodyMedium: body,
        bodySmall: small,
        labelLarge: bodyStrong,
      ),
      iconTheme: IconThemeData(color: ink),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          disabledBackgroundColor: surfaceMuted,
          disabledForegroundColor: muted,
          minimumSize: const Size.fromHeight(56),
          shape: buttonShape,
          textStyle: const TextStyle(
              fontFamily: family, fontSize: 17, fontWeight: FontWeight.w600),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ink,
          backgroundColor: surface,
          minimumSize: const Size.fromHeight(56),
          side: BorderSide(color: control, width: 1.2),
          shape: buttonShape,
          textStyle: const TextStyle(
              fontFamily: family, fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          minimumSize: const Size(48, 48),
          textStyle: const TextStyle(
              fontFamily: family, fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: ink,
          minimumSize: const Size(48, 48),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: primary),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: _dark ? surfaceMuted : ink,
        contentTextStyle: TextStyle(
          fontFamily: family,
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: _dark ? ink : surface,
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(r14)),
        textStyle: bodyStrong,
      ),
    );
  }

  /// Status and navigation bar icons that match the current palette.
  static SystemUiOverlayStyle get overlay => SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: _dark ? Brightness.light : Brightness.dark,
        statusBarBrightness: _dark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness:
            _dark ? Brightness.light : Brightness.dark,
        systemNavigationBarContrastEnforced: false,
      );
}

/// Motion grammar. Entrances decelerate softly, exits accelerate, and every
/// animation collapses to an instant change when the phone asks for less motion.
class KMotion {
  static const quick = Duration(milliseconds: 140);
  static const standard = Duration(milliseconds: 280);
  static const gentle = Duration(milliseconds: 460);
  static const breath = Duration(milliseconds: 4200);

  static const emphasized = Cubic(0.05, 0.7, 0.1, 1.0);
  static const standardCurve = Cubic(0.2, 0.0, 0.0, 1.0);
  static const exit = Cubic(0.3, 0.0, 0.8, 0.15);

  static bool reduced(BuildContext context) =>
      MediaQuery.maybeOf(context)?.disableAnimations ?? false;
}

/// Marks every element dirty so widgets that read [K] directly repaint after a
/// theme or language change, without losing navigation or form state.
void kRebuildAll(BuildContext context) {
  void rebuild(Element element) {
    element.markNeedsBuild();
    element.visitChildren(rebuild);
  }

  (context as Element).visitChildren(rebuild);
}

/// Page shell: header that separates from the content only once it scrolls,
/// scrollable body, max content width for large screens.
class KPage extends StatefulWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final List<Widget> actions;
  final bool showBack;
  final Widget? bottom;
  final Color? background;
  final Widget? fab;

  const KPage({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.actions = const [],
    this.showBack = true,
    this.bottom,
    this.background,
    this.fab,
  });

  @override
  State<KPage> createState() => _KPageState();
}

class _KPageState extends State<KPage> {
  bool _scrolled = false;

  @override
  Widget build(BuildContext context) {
    final background = widget.background ?? K.ground;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: K.overlay,
      child: Scaffold(
        backgroundColor: background,
        floatingActionButton: widget.fab,
        body: SafeArea(
          bottom: widget.bottom == null,
          child: Column(
            children: [
              _Header(
                title: widget.title,
                subtitle: widget.subtitle,
                actions: widget.actions,
                showBack: widget.showBack,
                background: background,
                separated: _scrolled,
              ),
              Expanded(
                child: NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    if (notification.depth == 0) {
                      final scrolled = notification.metrics.pixels > 2;
                      if (scrolled != _scrolled) {
                        setState(() => _scrolled = scrolled);
                      }
                    }
                    return false;
                  },
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 720),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 36),
                        child: widget.child,
                      ),
                    ),
                  ),
                ),
              ),
              if (widget.bottom != null)
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: K.surface,
                    border: Border(top: BorderSide(color: K.line)),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 720),
                          child: widget.bottom,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget> actions;
  final bool showBack;
  final Color background;
  final bool separated;

  const _Header({
    required this.title,
    required this.subtitle,
    required this.actions,
    required this.showBack,
    required this.background,
    required this.separated,
  });

  @override
  Widget build(BuildContext context) {
    final canPop = showBack && Navigator.of(context).canPop();
    return AnimatedContainer(
      duration: KMotion.standard,
      curve: KMotion.standardCurve,
      width: double.infinity,
      decoration: BoxDecoration(
        color: background,
        border: Border(
          bottom: BorderSide(color: separated ? K.line : background),
        ),
      ),
      padding: EdgeInsetsDirectional.fromSTEB(canPop ? 6 : 20, 8, 10, 12),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (canPop) ...[
                IconButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: Icon(Icons.arrow_back_rounded, color: K.ink),
                  tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                ),
                const SizedBox(width: 2),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(title,
                        style: K.h1,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(subtitle!, style: K.small),
                    ],
                  ],
                ),
              ),
              ...actions,
            ],
          ),
        ),
      ),
    );
  }
}

/// Anything tappable: a soft spring down on press, the platform ripple, and a
/// focus ring for keyboard and switch access.
class KPressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final BorderRadius borderRadius;
  final String? semanticsLabel;

  const KPressable({
    super.key,
    required this.child,
    required this.onTap,
    this.borderRadius = const BorderRadius.all(Radius.circular(K.r20)),
    this.semanticsLabel,
  });

  @override
  State<KPressable> createState() => _KPressableState();
}

class _KPressableState extends State<KPressable> {
  bool _down = false;

  void _set(bool value) {
    if (_down != value) setState(() => _down = value);
  }

  @override
  Widget build(BuildContext context) {
    final reduced = KMotion.reduced(context);
    return Semantics(
      button: true,
      label: widget.semanticsLabel,
      child: AnimatedScale(
        scale: _down && !reduced ? 0.975 : 1,
        duration: _down ? KMotion.quick : KMotion.standard,
        curve: _down ? KMotion.standardCurve : Curves.easeOutBack,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: widget.borderRadius,
            onTap: widget.onTap,
            onTapDown: (_) => _set(true),
            onTapUp: (_) => _set(false),
            onTapCancel: () => _set(false),
            splashColor: K.primary.withAlpha(24),
            focusColor: K.primary.withAlpha(28),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

/// A one-time soft entrance: content rises a few pixels and fades in. Content
/// is visible immediately when the phone asks for less motion.
class KReveal extends StatefulWidget {
  final Widget child;
  final int order;

  const KReveal({super.key, required this.child, this.order = 0});

  @override
  State<KReveal> createState() => _KRevealState();
}

class _KRevealState extends State<KReveal> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: KMotion.gentle);
  late final Animation<double> _t =
      CurvedAnimation(parent: _controller, curve: KMotion.emphasized);
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (KMotion.reduced(context)) {
      _controller.value = 1;
    } else {
      Future.delayed(Duration(milliseconds: 60 * widget.order), () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _t,
      child: widget.child,
      builder: (context, child) => Opacity(
        opacity: _t.value,
        child: Transform.translate(
            offset: Offset(0, 14 * (1 - _t.value)), child: child),
      ),
    );
  }
}

class KCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final Color? color;
  final Color? borderColor;
  final VoidCallback? onTap;

  const KCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.color,
    this.borderColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final body = Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? K.surface,
        borderRadius: BorderRadius.circular(K.r20),
        border: borderColor != null
            ? Border.all(color: borderColor!, width: 1.4)
            : (K.isDark ? Border.all(color: K.line) : null),
        boxShadow: color == null ? K.lift : const [],
      ),
      child: child,
    );
    if (onTap == null) return body;
    return KPressable(onTap: onTap, child: body);
  }
}

/// Section heading: sentence case, set like a title, never a tracked label.
class KSectionLabel extends StatelessWidget {
  final String text;
  final Widget? trailing;
  const KSectionLabel(this.text, {super.key, this.trailing});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsetsDirectional.only(start: 4, bottom: 10, top: 6),
        child: Row(
          children: [
            Expanded(child: Text(text, style: K.h2)),
            if (trailing != null) trailing!,
          ],
        ),
      );
}

/// A grouped list: rows share one surface, divided by inset hairlines.
class KGroup extends StatelessWidget {
  final List<Widget> children;
  const KGroup({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      rows.add(children[i]);
      if (i != children.length - 1) {
        rows.add(Padding(
          padding: const EdgeInsetsDirectional.only(start: 68),
          child: Divider(height: 1, thickness: 1, color: K.line),
        ));
      }
    }
    return Container(
      decoration: BoxDecoration(
        color: K.surface,
        borderRadius: BorderRadius.circular(K.r20),
        border: K.isDark ? Border.all(color: K.line) : null,
        boxShadow: K.lift,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: rows),
    );
  }
}

class KGroupRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? tint;
  final Widget? trailing;
  final Widget? leading;
  final VoidCallback? onTap;

  const KGroupRow({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.tint,
    this.trailing,
    this.leading,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = tint ?? K.primary;
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        splashColor: K.primary.withAlpha(20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 64),
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 10, 12, 10),
            child: Row(
              children: [
                leading ??
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: color.withAlpha(K.isDark ? 40 : 26),
                        borderRadius: BorderRadius.circular(K.r12),
                      ),
                      child: Icon(icon, size: 21, color: color),
                    ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(title, style: K.bodyStrong),
                      if (subtitle != null) ...[
                        const SizedBox(height: 1),
                        Text(subtitle!, style: K.small),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) trailing!,
                if (onTap != null)
                  Icon(
                    Icons.chevron_right_rounded,
                    color: K.muted,
                    size: 22,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class KField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final bool obscure;
  final TextInputType? keyboard;
  final String? errorText;
  final Widget? suffix;
  final int maxLines;

  const KField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.obscure = false,
    this.keyboard,
    this.errorText,
    this.suffix,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border(Color color, [double width = 1.2]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(K.r14),
          borderSide: BorderSide(color: color, width: width),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 4),
          child: Text(label, style: K.bodyStrong),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboard,
          maxLines: obscure ? 1 : maxLines,
          cursorColor: K.primary,
          style: TextStyle(fontFamily: K.family, fontSize: 17, color: K.ink),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                TextStyle(fontFamily: K.family, color: K.muted, fontSize: 16),
            errorText: errorText,
            errorStyle: TextStyle(
                fontFamily: K.family, color: K.danger, fontSize: 13.5),
            filled: true,
            fillColor: K.surface,
            suffixIcon: suffix,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            enabledBorder: border(K.control),
            focusedBorder: border(K.primary, 2),
            errorBorder: border(K.danger),
            focusedErrorBorder: border(K.danger, 2),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class KBanner extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color? color;
  final Color? background;

  const KBanner({
    super.key,
    required this.text,
    this.icon = Icons.info_outline_rounded,
    this.color,
    this.background,
  });

  @override
  Widget build(BuildContext context) {
    final fg = color ?? K.primaryStrong;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: background ?? K.primarySoft,
        borderRadius: BorderRadius.circular(K.r14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Icon(icon, size: 20, color: fg),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text,
                style: TextStyle(
                    fontFamily: K.family,
                    fontSize: 14.5,
                    height: 1.45,
                    color: fg,
                    fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}

/// Quiet footnote line: an icon and a sentence, no container.
class KNote extends StatelessWidget {
  final String text;
  final IconData icon;
  const KNote({super.key, required this.text, required this.icon});

  @override
  Widget build(BuildContext context) => Padding(
        padding:
            const EdgeInsetsDirectional.symmetric(horizontal: 6, vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: K.muted),
            const SizedBox(width: 10),
            Expanded(child: Text(text, style: K.small)),
          ],
        ),
      );
}

class KTag extends StatelessWidget {
  final String text;
  final Color? color;
  final Color? background;
  final IconData? icon;
  const KTag(this.text, {super.key, this.color, this.background, this.icon});

  @override
  Widget build(BuildContext context) {
    final fg = color ?? K.inkSoft;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background ?? K.surfaceMuted,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: fg),
            const SizedBox(width: 5),
          ],
          Text(text,
              style: TextStyle(
                  fontFamily: K.family,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: fg)),
        ],
      ),
    );
  }
}

void kToast(BuildContext context, String message, {bool error = false}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(
            error
                ? Icons.error_outline_rounded
                : Icons.check_circle_outline_rounded,
            size: 20,
            color: error ? Colors.white : (K.isDark ? K.ok : K.okSoft),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(message)),
        ],
      ),
      backgroundColor: error ? K.danger : null,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(K.r14)),
      margin: const EdgeInsets.all(16),
    ),
  );
}
