import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

import '../data/auth_store.dart';
import '../data/case_store.dart';
import '../data/khatwa_store.dart';
import '../ui/app_state.dart';
import '../ui/app_theme.dart';
import '../ui/foot_twin.dart';
import '../ui/k_image.dart';
import '../ui/strings.dart';
import 'create_account.dart';

/// First screen: the mark, one promise, who you are, one clear action.
/// Two columns on a wide screen (the demo laptop), one on a phone.
class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  String role = 'patient';

  void _open(Widget page) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));

  @override
  Widget build(BuildContext context) {
    final lang = appLanguage.value;

    final actions = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(S.t(lang, 'auth.promise'),
            textAlign: TextAlign.center, style: K.h1.copyWith(height: 1.3)),
        const SizedBox(height: 10),
        Text(S.t(lang, 'app.tagline'),
            textAlign: TextAlign.center, style: K.body.copyWith(color: K.muted)),
        const SizedBox(height: 28),
        Text(S.t(lang, 'auth.iam'), style: K.bodyStrong),
        const SizedBox(height: 10),
        RoleChoice(value: role, onChanged: (v) => setState(() => role = v)),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: () => _open(AuthPage(role: role)),
          child: Text(S.t(lang, 'auth.signin')),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () => _open(CreateAccountPage(role: role)),
          child: Text(S.t(lang, 'auth.signup')),
        ),
        const SizedBox(height: 22),
        KNote(text: S.t(lang, 'report.disclaimer'), icon: Icons.info_outline_rounded),
      ],
    );

    return Scaffold(
      backgroundColor: K.ground,
      body: SafeArea(
        child: LayoutBuilder(builder: (context, box) {
          final wide = box.maxWidth >= 900;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 16, 0),
                child: Row(
                  children: [
                    const KhatwaMark(size: 40),
                    const SizedBox(width: 10),
                    Expanded(child: Text('Khatwa', style: K.h2, maxLines: 1, overflow: TextOverflow.ellipsis)),
                    const SizedBox(width: 8),
                    const Flexible(child: LanguagePill()),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                  child: Center(
                    child: wide
                        ? ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1040),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Expanded(child: LandingVisual(height: 460)),
                                const SizedBox(width: 48),
                                Expanded(child: actions),
                              ],
                            ),
                          )
                        : ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 460),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                LandingVisual(height: box.maxHeight < 700 ? 190 : 240),
                                const SizedBox(height: 22),
                                actions,
                              ],
                            ),
                          ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

/// The brand icon, with a quiet teal square behind it while the image loads.
class KhatwaMark extends StatelessWidget {
  final double size;
  const KhatwaMark({super.key, this.size = 40});

  @override
  Widget build(BuildContext context) {
    final r = size * 0.26;
    return SizedBox(
      width: size,
      height: size,
      child: KImage('khatwa_logo',
          radius: r,
          placeholder: Container(
            decoration: BoxDecoration(color: K.primary, borderRadius: BorderRadius.circular(r)),
            child: Icon(Icons.directions_walk_rounded, color: K.onPrimary, size: size * 0.55),
          )),
    );
  }
}

/// The model foot turning slowly in a soft teal light. Where no 3D view is
/// possible (tests, desktop) the twin illustration stands in.
class LandingVisual extends StatelessWidget {
  final double height;
  const LandingVisual({super.key, required this.height});

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(K.r28),
          gradient: RadialGradient(
            center: const Alignment(0, -0.1),
            radius: 0.9,
            colors: [K.primarySoft, K.ground],
          ),
        ),
        child: FootTwin.supported
            ? ModelViewer(
                key: ValueKey('landing-${K.isDark}'),
                src: 'assets/models/foot_holo.glb',
                alt: 'Khatwa',
                backgroundColor: Colors.transparent,
                cameraControls: false,
                disableZoom: true,
                interactionPrompt: InteractionPrompt.none,
                autoRotate: true,
                autoRotateDelay: 0,
                rotationPerSecond: '14deg',
                cameraOrbit: '-150deg 60deg 105%',
                exposure: 1.1,
                shadowIntensity: 0,
                relatedCss: 'model-viewer { --poster-color: transparent; background: transparent; }',
              )
            : Center(
                child: KImage('hero_twin',
                    fit: BoxFit.contain,
                    height: height,
                    radius: K.r28,
                    placeholder: Icon(Icons.view_in_ar_rounded, size: height * 0.3, color: K.primary)),
              ),
      ),
    );
  }
}

/// Patient or health professional: two tiles side by side.
class RoleChoice extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  const RoleChoice({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final lang = appLanguage.value;
    Widget tile(String role, String label, IconData icon) {
      final on = value == role;
      return Expanded(
        child: Semantics(
          selected: on,
          button: true,
          label: label,
          excludeSemantics: true,
          child: KPressable(
            onTap: () => onChanged(role),
            borderRadius: BorderRadius.circular(K.r20),
            child: AnimatedContainer(
              duration: KMotion.standard,
              curve: KMotion.standardCurve,
              constraints: const BoxConstraints(minHeight: 76),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: on ? K.primarySoft : K.surface,
                borderRadius: BorderRadius.circular(K.r20),
                border: Border.all(color: on ? K.primary : K.control, width: on ? 2 : 1.2),
              ),
              child: Row(
                children: [
                  Icon(icon, color: on ? K.primaryStrong : K.inkSoft, size: 26),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(label,
                        style: K.bodyStrong.copyWith(
                            color: on ? K.primaryStrong : K.ink,
                            fontWeight: on ? FontWeight.w700 : FontWeight.w500)),
                  ),
                  AnimatedOpacity(
                    duration: KMotion.quick,
                    opacity: on ? 1 : 0,
                    child: Icon(Icons.check_circle_rounded, color: K.primary, size: 20),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        tile('patient', S.t(lang, 'role.patient'), Icons.person_outline_rounded),
        const SizedBox(width: 12),
        tile('doctor', S.t(lang, 'role.doctorShort'), Icons.medical_services_outlined),
      ],
    );
  }
}

/// A password field with a show/hide eye.
class PasswordField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final String? hint;
  const PasswordField({super.key, required this.label, required this.controller, this.hint});

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool shown = false;

  @override
  Widget build(BuildContext context) {
    final lang = appLanguage.value;
    return KField(
      label: widget.label,
      controller: widget.controller,
      hint: widget.hint,
      obscure: !shown,
      suffix: IconButton(
        tooltip: S.t(lang, shown ? 'auth.hide' : 'auth.show'),
        icon: Icon(shown ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: K.muted),
        onPressed: () => setState(() => shown = !shown),
      ),
    );
  }
}

/// The frame of the sign-in and sign-up pages: a light page, a narrow column,
/// the language always at hand.
class AuthFrame extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> children;
  const AuthFrame({super.key, required this.title, required this.subtitle, required this.children});

  @override
  Widget build(BuildContext context) {
    return KPage(
      title: title,
      subtitle: subtitle,
      actions: const [LanguagePill(), SizedBox(width: 4)],
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [const SizedBox(height: 10), ...children],
          ),
        ),
      ),
    );
  }
}

/// Error line above the main button.
class AuthErrorLine extends StatelessWidget {
  final String text;
  const AuthErrorLine(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: KBanner(
          text: text,
          icon: Icons.error_outline_rounded,
          color: K.danger,
          background: K.dangerSoft,
        ),
      );
}

/// Busy spinner or label, for the main button.
Widget authButtonChild(bool busy, String label) => busy
    ? SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(strokeWidth: 2.4, color: K.onPrimary),
      )
    : Text(label);

/// Loads the stores once the data key is in memory, then goes home.
Future<void> finishSignIn(BuildContext context) async {
  await CaseStore.instance.unlock();
  await KhatwaStore.instance.reload();
  if (!context.mounted) return;
  Navigator.of(context).popUntil((route) => route.isFirst);
}

/// Sign in, with real credential checks.
class AuthPage extends StatefulWidget {
  final String role;

  const AuthPage({super.key, required this.role});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool busy = false;
  String? error;

  final phone = TextEditingController();
  final password = TextEditingController();
  final pin = TextEditingController();

  bool get isDoctor => widget.role == 'doctor';

  @override
  void dispose() {
    phone.dispose();
    password.dispose();
    pin.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    final lang = appLanguage.value;
    setState(() {
      busy = true;
      error = null;
    });

    final store = AuthStore.instance;
    final result = await store.signIn(
      phone: phone.text,
      password: password.text,
      pin: pin.text,
      role: widget.role,
    );

    if (!mounted) return;

    if (result == AuthError.none) {
      await finishSignIn(context);
      return;
    }

    var message = S.t(lang, store.errorKey(result));
    if (result == AuthError.locked) {
      final seconds = store.lockedSeconds(phone.text, widget.role);
      message = '$message · $seconds ${S.t(lang, 'auth.lockedFor')}';
    }

    setState(() {
      busy = false;
      error = message;
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = appLanguage.value;

    return AuthFrame(
      title: S.t(lang, 'auth.welcomeBack'),
      subtitle: '${S.t(lang, 'auth.signin')} · ${S.t(lang, isDoctor ? 'role.doctorShort' : 'role.patient')}',
      children: [
        Text(S.t(lang, 'auth.signinSub'), style: K.body.copyWith(color: K.inkSoft)),
        const SizedBox(height: 18),
        KField(
          label: S.t(lang, 'auth.phone'),
          hint: '20 000 000',
          controller: phone,
          keyboard: TextInputType.phone,
        ),
        PasswordField(label: S.t(lang, 'auth.password'), controller: password),
        KField(
          label: S.t(lang, 'auth.pin'),
          controller: pin,
          obscure: true,
          keyboard: TextInputType.number,
          hint: '••••',
        ),
        if (error != null) AuthErrorLine(error!),
        FilledButton(
          onPressed: busy ? null : submit,
          child: authButtonChild(busy, S.t(lang, 'auth.signin')),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: busy
              ? null
              : () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => CreateAccountPage(role: widget.role))),
          child: Text(S.t(lang, 'auth.none')),
        ),
        const SizedBox(height: 18),
        KNote(text: S.t(lang, 'auth.secure'), icon: Icons.lock_outline_rounded),
      ],
    );
  }
}
