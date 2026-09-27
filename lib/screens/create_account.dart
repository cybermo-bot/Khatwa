import 'package:flutter/material.dart';

import '../data/auth_store.dart';
import '../ui/app_state.dart';
import '../ui/app_theme.dart';
import '../ui/strings.dart';
import 'auth_pages.dart';

/// Sign up: a patient or a health professional account on this device.
class CreateAccountPage extends StatefulWidget {
  final String role;

  const CreateAccountPage({super.key, required this.role});

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  bool busy = false;
  String? error;

  final name = TextEditingController();
  final phone = TextEditingController();
  final password = TextEditingController();
  final confirm = TextEditingController();
  final speciality = TextEditingController();
  final facility = TextEditingController();
  final pin = TextEditingController();

  bool get isDoctor => widget.role == 'doctor';

  @override
  void dispose() {
    for (final c in [name, phone, password, confirm, speciality, facility, pin]) {
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
    final result = await store.signUp(
      name: name.text,
      phone: phone.text,
      password: password.text,
      confirm: confirm.text,
      pin: pin.text,
      role: widget.role,
      speciality: speciality.text,
      facility: facility.text,
    );

    if (!mounted) return;
    if (result == AuthError.none) {
      await finishSignIn(context);
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
      title: S.t(lang, 'auth.signup'),
      subtitle: S.t(lang, isDoctor ? 'role.doctorShort' : 'role.patient'),
      children: [
        Text(S.t(lang, 'auth.signupSub'), style: K.body.copyWith(color: K.inkSoft)),
        const SizedBox(height: 18),
        KField(label: S.t(lang, 'auth.name'), controller: name),
        KField(
          label: S.t(lang, 'auth.phone'),
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
        KField(
          label: S.t(lang, 'auth.pin'),
          controller: pin,
          obscure: true,
          keyboard: TextInputType.number,
          hint: '••••',
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(S.t(lang, 'auth.pinHint'), style: K.small),
        ),
        if (error != null) AuthErrorLine(error!),
        FilledButton(
          onPressed: busy ? null : submit,
          child: authButtonChild(busy, S.t(lang, 'auth.signup')),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: busy
              ? null
              : () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => AuthPage(role: widget.role))),
          child: Text(S.t(lang, 'auth.have')),
        ),
        const SizedBox(height: 18),
        KNote(text: S.t(lang, 'security.encrypted'), icon: Icons.enhanced_encryption_outlined),
      ],
    );
  }
}
