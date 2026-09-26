import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'data/ai_gateway.dart';
import 'data/auth_store.dart';
import 'data/case_store.dart';
import 'data/khatwa_store.dart';
import 'screens/auth_pages.dart';
import 'screens/doctor_home.dart';
import 'screens/shell.dart';
import 'ui/app_state.dart';
import 'ui/app_theme.dart';
import 'ui/strings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await KhatwaStore.instance.init();
  await AuthStore.instance.init();
  await CaseStore.instance.init();
  await ApiConfig.load();
  await loadTextScale();
  await loadThemeMode();
  await loadSkinTone();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  runApp(const KhatwaApp());
}

class KhatwaApp extends StatefulWidget {
  const KhatwaApp({super.key});

  @override
  State<KhatwaApp> createState() => _KhatwaAppState();
}

class _KhatwaAppState extends State<KhatwaApp> with WidgetsBindingObserver {
  String _paintedLanguage = appLanguage.value;
  bool? _paintedDark;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    appThemeMode.addListener(_changed);
    appLanguage.addListener(_changed);
    appTextScale.addListener(_changed);
    appSkinTone.addListener(_changedTone);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    appThemeMode.removeListener(_changed);
    appLanguage.removeListener(_changed);
    appTextScale.removeListener(_changed);
    appSkinTone.removeListener(_changedTone);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() => _changed();

  void _changed() {
    if (mounted) setState(() {});
  }

  bool _toneChanged = false;

  void _changedTone() {
    _toneChanged = true;
    _changed();
  }

  bool _wantsDark() {
    switch (appThemeMode.value) {
      case ThemeMode.light:
        return false;
      case ThemeMode.dark:
        return true;
      case ThemeMode.system:
        return WidgetsBinding.instance.platformDispatcher.platformBrightness ==
            Brightness.dark;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = _wantsDark();
    final language = appLanguage.value;
    final repaint = (_paintedDark != null && _paintedDark != dark) ||
        _paintedLanguage != language ||
        _toneChanged;
    _toneChanged = false;
    K.setDark(dark);
    _paintedDark = dark;
    _paintedLanguage = language;
    SystemChrome.setSystemUIOverlayStyle(K.overlay);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Khatwa',
      theme: K.theme(),
      themeAnimationDuration: KMotion.standard,
      builder: (context, child) {
        if (repaint) {
          // Widgets that read the palette or the language directly would
          // otherwise keep their old values until their own state changed.
          WidgetsBinding.instance.addPostFrameCallback((_) => kRebuildAll(context));
        }
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(appTextScale.value),
          ),
          child: Directionality(
            textDirection: S.isRtl(language) ? TextDirection.rtl : TextDirection.ltr,
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
      home: const RootGate(),
    );
  }
}

/// Decides where the app opens, and enforces the idle timeout.
///
/// A shared clinician workstation must not stay open on a patient record, so
/// after ten minutes without interaction the session is closed and the
/// decrypted records are dropped from memory.
class RootGate extends StatefulWidget {
  const RootGate({super.key});

  @override
  State<RootGate> createState() => _RootGateState();
}

class _RootGateState extends State<RootGate> {
  Timer? _idleTimer;

  @override
  void initState() {
    super.initState();
    _idleTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (AuthStore.instance.idleExpired) {
        CaseStore.instance.lock();
        AuthStore.instance.signOut();
        if (mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      }
    });
  }

  @override
  void dispose() {
    _idleTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => AuthStore.instance.touch(),
      onPointerSignal: (_) => AuthStore.instance.touch(),
      child: AnimatedBuilder(
        animation: AuthStore.instance,
        builder: (context, _) {
          final account = AuthStore.instance.current;
          if (account == null) return const LandingPage();
          if (account.role == 'doctor') {
            return DoctorHomePage(language: appLanguage.value);
          }
          return const AppShell();
        },
      ),
    );
  }
}
