import 'package:flutter/material.dart';

import '../data/auth_store.dart';
import '../ui/app_state.dart';
import '../ui/app_theme.dart';
import '../ui/strings.dart';
import 'auth_pages.dart';

/// Sign up: name, e-mail and password, the phone number optional; the e-mail
/// is confirmed with a 6-digit code. Opened from the Me tab by a guest, it
/// turns the guest into a real account and keeps their data.
class CreateAccountPage extends StatefulWidget {
  final String role;

  const CreateAccountPage({super.key, required this.role});

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  bool busy = false;
  late bool stay = AuthStore.instance.stayChoice;
  String? error;

  final name = TextEditingController();
  final email = TextEditingController();
  final phone = TextEditingController();
  final password = TextEditingController();
  final confirm = TextEditingController();
  final speciality = TextEditingController();
  final facility = TextEditingController();

  bool get isDoctor => widget.role == 'doctor';
  bool get upgrading => AuthStore.instance.isGuest;

  @override
  void dispose() {
    for (final c in [name, email, phone, password, confirm, speciality, facility]) {
      c.dispose();
    }
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
    final result = await store.beginSignUp(
      name: name.text,
      email: email.text,
      phone: phone.text,
      password: password.text,
      confirm: confirm.text,
      role: widget.role,
      speciality: speciality.text,
      facility: facility.text,
      stay: stay,
    );

    if (!mounted) return;
    if (result == AuthError.none) {
      setState(() => busy = false);
      await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EmailCodePage()));
      return;
    }
    setState(() {
      busy = false;
      error = S.t(lang, store.errorKey(result));
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = appLanguage.value;

    return AuthFrame(
      title: S.t(lang, upgrading ? 'auth.guestUpgrade' : 'auth.signup'),
      subtitle: S.t(lang, isDoctor ? 'role.doctorShort' : 'role.patient'),
      children: [
        Text(S.t(lang, upgrading ? 'auth.guestUpgradeSub' : 'auth.signupSub'),
            style: K.body.copyWith(color: K.inkSoft)),
        const SizedBox(height: 18),
        KField(label: S.t(lang, 'auth.name'), controller: name),
        KField(
          label: S.t(lang, 'auth.email'),
          hint: 'nom@exemple.tn',
          controller: email,
          keyboard: TextInputType.emailAddress,
        ),
        KField(
          label: S.t(lang, 'auth.phoneOptional'),
          hint: '20 000 000',
          controller: phone,
          keyboard: TextInputType.phone,
        ),
        if (isDoctor) ...[
          KField(label: S.t(lang, 'auth.speciality'), controller: speciality),
          KField(label: S.t(lang, 'auth.facility'), controller: facility),
        ],
        PasswordField(label: S.t(lang, 'auth.password'), controller: password),
        PasswordField(label: S.t(lang, 'auth.confirm'), controller: confirm),
        StaySignedIn(value: stay, onChanged: (v) => setState(() => stay = v)),
        if (error != null) AuthErrorLine(error!),
        FilledButton(
          onPressed: busy ? null : submit,
          child: authButtonChild(busy, S.t(lang, upgrading ? 'auth.guestUpgrade' : 'auth.signup')),
        ),
        if (!upgrading) ...[
          const SizedBox(height: 8),
          TextButton(
            onPressed: busy
                ? null
                : () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => AuthPage(role: widget.role))),
            child: Text(S.t(lang, 'auth.have')),
          ),
        ],
        const SizedBox(height: 18),
        KNote(text: S.t(lang, 'security.encrypted'), icon: Icons.enhanced_encryption_outlined),
      ],
    );
  }
}
