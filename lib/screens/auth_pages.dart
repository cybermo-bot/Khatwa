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
  bool busy = false;

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
        if (role == 'patient') ...[
          const SizedBox(height: 6),
          TextButton.icon(
            onPressed: busy
                ? null
                : () async {
                    setState(() => busy = true);
                    await continueAsGuest(context);
                    if (mounted) setState(() => busy = false);
                  },
            icon: const Icon(Icons.person_outline_rounded),
            label: Text(S.t(lang, 'auth.guest')),
          ),
          Text(S.t(lang, 'auth.guestNote'), textAlign: TextAlign.center, style: K.small),
        ],
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

/// Starts a guest session and opens the app.
Future<void> continueAsGuest(BuildContext context) async {
  await AuthStore.instance.signInGuest();
  if (!context.mounted) return;
  await finishSignIn(context);
}

/// "Rester connecté": a checkbox with its meaning under it.
class StaySignedIn extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  const StaySignedIn({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final lang = appLanguage.value;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: KPressable(
        onTap: () => onChanged(!value),
        borderRadius: BorderRadius.circular(K.r14),
        semanticsLabel: S.t(lang, 'auth.stay'),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ExcludeSemantics(
                child: Checkbox(value: value, onChanged: (v) => onChanged(v ?? false)),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(S.t(lang, 'auth.stay'), style: K.bodyStrong),
                      const SizedBox(height: 2),
                      Text(S.t(lang, 'auth.stayHint'), style: K.small),
                    ],
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

/// Sign in: e-mail and password, then the e-mail code unless this device is
/// trusted. An older account signs in once with its PIN.
class AuthPage extends StatefulWidget {
  final String role;

  const AuthPage({super.key, required this.role});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool busy = false;
  bool askPin = false;
  late bool stay = AuthStore.instance.stayChoice;
  String? error;

  final identifier = TextEditingController();
  final password = TextEditingController();
  final pin = TextEditingController();

  bool get isDoctor => widget.role == 'doctor';

  @override
  void dispose() {
    identifier.dispose();
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
    await store.setStayChoice(stay);
    final result = await store.signIn(
      identifier: identifier.text,
      password: password.text,
      pin: pin.text,
      role: widget.role,
      stay: stay,
    );

    if (!mounted) return;

    if (result == AuthError.none) {
      await finishSignIn(context);
      return;
    }
    if (result == AuthError.needCode) {
      setState(() => busy = false);
      await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EmailCodePage()));
      return;
    }

    var message = S.t(lang, store.errorKey(result));
    if (result == AuthError.locked) {
      final seconds = store.lockedSeconds(identifier.text, widget.role);
      message = '$message · $seconds ${S.t(lang, 'auth.lockedFor')}';
    }

    setState(() {
      busy = false;
      if (result == AuthError.needPin) askPin = true;
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
          label: S.t(lang, 'auth.identifier'),
          hint: 'nom@exemple.tn',
          controller: identifier,
          keyboard: TextInputType.emailAddress,
        ),
        PasswordField(label: S.t(lang, 'auth.password'), controller: password),
        if (askPin)
          KField(
            label: S.t(lang, 'auth.oldPin'),
            controller: pin,
            obscure: true,
            keyboard: TextInputType.number,
            hint: '••••',
          ),
        StaySignedIn(value: stay, onChanged: (v) => setState(() => stay = v)),
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

/// The 6-digit code sent by e-mail. Sends it on open; if it cannot be sent,
/// says so kindly and offers to continue as a guest.
class EmailCodePage extends StatefulWidget {
  const EmailCodePage({super.key});

  @override
  State<EmailCodePage> createState() => _EmailCodePageState();
}

class _EmailCodePageState extends State<EmailCodePage> {
  final code = TextEditingController();
  bool sending = true;
  bool sent = false;
  bool busy = false;
  String? error;

  @override
  void initState() {
    super.initState();
    _send();
  }

  @override
  void dispose() {
    code.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    setState(() {
      sending = true;
      error = null;
    });
    final result = await AuthStore.instance.sendCode();
    if (!mounted) return;
    setState(() {
      sending = false;
      sent = result == AuthError.none;
      if (!sent) error = S.t(appLanguage.value, AuthStore.instance.errorKey(result));
    });
  }

  Future<void> _verify() async {
    setState(() {
      busy = true;
      error = null;
    });
    final result = await AuthStore.instance.confirmCode(code.text);
    if (!mounted) return;
    if (result == AuthError.none) {
      await finishSignIn(context);
      return;
    }
    setState(() {
      busy = false;
      error = S.t(appLanguage.value, AuthStore.instance.errorKey(result));
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = appLanguage.value;
    final email = AuthStore.instance.pendingEmail ?? '';
    final signedIn = AuthStore.instance.isSignedIn;
    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) AuthStore.instance.cancelPending();
      },
      child: AuthFrame(
        title: S.t(lang, 'auth.code.title'),
        subtitle: email,
        children: [
          if (sending)
            Row(children: [
              SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.4, color: K.primary)),
              const SizedBox(width: 12),
              Expanded(child: Text(S.t(lang, 'auth.code.sending'), style: K.body)),
            ])
          else if (sent) ...[
            Text(S.t(lang, 'auth.code.sent'), style: K.body.copyWith(color: K.inkSoft)),
            const SizedBox(height: 2),
            Text(email, textDirection: TextDirection.ltr, style: K.bodyStrong),
          ],
          const SizedBox(height: 20),
          if (sent) ...[
            Text(S.t(lang, 'auth.code.label'), style: K.bodyStrong),
            const SizedBox(height: 8),
            Directionality(
              textDirection: TextDirection.ltr,
              child: TextField(
                controller: code,
                autofocus: true,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                autofillHints: const [AutofillHints.oneTimeCode],
                style: K.number.copyWith(letterSpacing: 10),
                decoration: const InputDecoration(counterText: '', hintText: '000000'),
                onChanged: (v) {
                  if (v.length == 6 && !busy) _verify();
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (error != null) AuthErrorLine(error!),
          if (sent)
            FilledButton(
              onPressed: busy ? null : _verify,
              child: authButtonChild(busy, S.t(lang, 'auth.code.verify')),
            ),
          if (!sending) ...[
            const SizedBox(height: 8),
            TextButton(onPressed: busy ? null : _send, child: Text(S.t(lang, 'auth.code.resend'))),
          ],
          if (!sending && !sent) ...[
            const SizedBox(height: 4),
            if (signedIn)
              OutlinedButton(
                onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                child: Text(S.t(lang, 'auth.back')),
              )
            else
              OutlinedButton.icon(
                onPressed: () {
                  AuthStore.instance.cancelPending();
                  continueAsGuest(context);
                },
                icon: const Icon(Icons.person_outline_rounded),
                label: Text(S.t(lang, 'auth.guest')),
              ),
          ],
          if (sent) ...[
            const SizedBox(height: 14),
            KNote(text: S.t(lang, 'auth.code.spam'), icon: Icons.mail_outline_rounded),
          ],
        ],
      ),
    );
  }
}
