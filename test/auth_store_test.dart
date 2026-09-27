import 'dart:convert';

import 'package:diabetic_foot_app/data/auth_store.dart';
import 'package:diabetic_foot_app/data/crypto_box.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Codes that always reach the inbox: the code is 123456.
class _FakeCodes extends EmailCodes {
  final bool canSend;
  final List<String> sentTo = [];
  _FakeCodes({this.canSend = true});

  @override
  Future<bool> send(String email) async {
    if (!canSend) return false;
    sentTo.add(email);
    return true;
  }

  @override
  Future<bool> verify(String email, String code) async => code == '123456';
}

Future<AuthStore> _fresh([Map<String, Object> prefs = const {}]) async {
  SharedPreferences.setMockInitialValues(prefs);
  final store = AuthStore.instance..resetForTest();
  await store.init();
  return store;
}

/// Simulates an app restart: memory is lost, the device storage stays.
Future<AuthStore> _restart() async {
  final store = AuthStore.instance..resetForTest();
  await store.init();
  return store;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('sign-up form validation', () {
    AuthError check({
      String name = 'Amel',
      String email = 'amel@exemple.tn',
      String phone = '',
      String password = 'motdepasse',
      String? confirm,
    }) =>
        AuthStore.validateSignUp(
            name: name, email: email, phone: phone, password: password, confirm: confirm ?? password);

    test('a complete form passes, the phone is optional', () {
      expect(check(), AuthError.none);
      expect(check(phone: '20 123 456'), AuthError.none);
      expect(check(phone: '+216 20 123 456'), AuthError.none);
    });
    test('name, e-mail and password are required', () {
      expect(check(name: ' '), AuthError.fields);
      expect(check(email: ''), AuthError.fields);
      expect(check(password: '', confirm: ''), AuthError.fields);
    });
    test('the e-mail must look like one', () {
      for (final bad in ['amel', 'amel@', '@exemple.tn', 'amel@exemple', 'a b@exemple.tn']) {
        expect(check(email: bad), AuthError.email, reason: bad);
      }
    });
    test('a phone number, when given, has 8 digits', () {
      expect(check(phone: '1234'), AuthError.phone);
    });
    test('the password has 8 characters or more and is confirmed', () {
      expect(check(password: 'court'), AuthError.short);
      expect(check(confirm: 'autrechose'), AuthError.match);
    });
  });

  group('guest', () {
    test('a guest patient is made on the spot, with no data typed', () async {
      final store = await _fresh();
      expect(await store.signInGuest(), AuthError.none);
      expect(store.isSignedIn, isTrue);
      expect(store.isGuest, isTrue);
      expect(store.current!.role, 'patient');
      expect(store.current!.email, isEmpty);
      expect(store.current!.phone, isEmpty);
      expect(store.encryptionActive, isTrue);
    });

    test('a guest stays signed in across a restart and is never idle-locked', () async {
      final store = await _fresh();
      await store.signInGuest();
      final id = store.current!.id;
      final key = List<int>.from(store.dek!);
      store.lastActivity = DateTime.now().subtract(const Duration(hours: 2));
      expect(store.idleExpired, isFalse);

      final after = await _restart();
      expect(after.current?.id, id);
      expect(after.dek, key);
    });

    test('a guest becomes a real account and keeps the same id and key', () async {
      final store = await _fresh();
      store.codes = _FakeCodes();
      await store.signInGuest();
      final id = store.current!.id;
      final key = List<int>.from(store.dek!);

      expect(
          await store.beginSignUp(
              name: 'Amel', email: 'Amel@Exemple.tn', password: 'motdepasse', confirm: 'motdepasse', role: 'patient'),
          AuthError.none);
      expect(await store.sendCode(), AuthError.none);
      expect(await store.confirmCode('123456'), AuthError.none);
      expect(store.isGuest, isFalse);
      expect(store.current!.id, id);
      expect(store.current!.email, 'amel@exemple.tn');
      expect(store.dek, key);
    });
  });

  group('stay signed in', () {
    Future<AuthStore> withAccount({required bool stay}) async {
      final store = await _fresh();
      store.codes = _FakeCodes();
      await store.beginSignUp(
          name: 'Amel', email: 'amel@exemple.tn', password: 'motdepasse', confirm: 'motdepasse', role: 'patient',
          stay: stay);
      await store.sendCode();
      expect(await store.confirmCode('123456'), AuthError.none);
      return store;
    }

    test('unticked keeps the 10 minute idle lock and forgets the session on restart', () async {
      final store = await withAccount(stay: false);
      store.lastActivity = DateTime.now().subtract(const Duration(minutes: 11));
      expect(store.idleExpired, isTrue);
      final after = await _restart();
      expect(after.isSignedIn, isFalse);
    });

    test('ticked skips the idle lock and survives a restart', () async {
      final store = await withAccount(stay: true);
      final key = List<int>.from(store.dek!);
      store.lastActivity = DateTime.now().subtract(const Duration(hours: 5));
      expect(store.idleExpired, isFalse);
      final after = await _restart();
      expect(after.isSignedIn, isTrue);
      expect(after.staySignedIn, isTrue);
      expect(after.dek, key);
      expect(after.idleExpired, isFalse);
    });

    test('the choice is remembered per device', () async {
      final store = await _fresh();
      await store.setStayChoice(true);
      final after = await _restart();
      expect(after.stayChoice, isTrue);
    });

    test('a trusted device skips the e-mail code, another sign-in needs it', () async {
      final store = await withAccount(stay: true);
      await store.signOut();
      expect(await store.signIn(identifier: 'amel@exemple.tn', password: 'motdepasse', role: 'patient'),
          AuthError.none);

      final other = await withAccount(stay: false);
      await other.signOut();
      expect(await other.signIn(identifier: 'amel@exemple.tn', password: 'motdepasse', role: 'patient'),
          AuthError.needCode);
      expect(await other.confirmCode('000000'), AuthError.code);
      expect(await other.confirmCode('123 456'), AuthError.none);
      expect(other.isSignedIn, isTrue);
    });
  });

  test('when the code cannot be sent, the sign-up says so', () async {
    final store = await _fresh();
    store.codes = _FakeCodes(canSend: false);
    await store.beginSignUp(
        name: 'Amel', email: 'amel@exemple.tn', password: 'motdepasse', confirm: 'motdepasse', role: 'patient');
    expect(await store.sendCode(), AuthError.codeSend);
    expect(store.isSignedIn, isFalse);
  });

  test('the key is sealed with the password: a wrong password cannot open it', () async {
    final store = await _fresh();
    store.codes = _FakeCodes();
    await store.beginSignUp(
        name: 'Amel', email: 'amel@exemple.tn', password: 'motdepasse', confirm: 'motdepasse', role: 'patient',
        stay: true);
    await store.sendCode();
    await store.confirmCode('123456');
    final account = store.current!;
    expect(CryptoBox.open(account.wrappedKey, CryptoBox.deriveKey('motdepasse', account.keySalt)), isNotNull);
    expect(CryptoBox.open(account.wrappedKey, CryptoBox.deriveKey('autre', account.keySalt)), isNull);
    expect(await store.signIn(identifier: 'amel@exemple.tn', password: 'mauvais1', role: 'patient'), AuthError.bad);
  });

  test('an account made with a PIN signs in once with it, then with the password only', () async {
    // The shape of an account from before the e-mail code.
    final key = CryptoBox.randomBytes(32);
    String hash(String secret, String salt) {
      // Same as AuthStore._hash: 4000 rounds of SHA-256.
      var d = CryptoBox.deriveKey(secret, salt, iterations: 4000);
      return d.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    }

    final legacy = Account(
      id: 'pat_20123456_1',
      phone: '20123456',
      name: 'Amel',
      role: 'patient',
      salt: 's1',
      hash: hash('motdepasse', 's1'),
      pinSalt: 's2',
      pinHash: hash('2468', 's2'),
      wrappedDek: CryptoBox.seal(base64Encode(key), CryptoBox.deriveKey('2468', 's2')),
      createdAt: '2026-01-01',
    );
    final store = await _fresh({
      'khatwa_accounts_v2': jsonEncode([legacy.toJson()])
    });

    expect(await store.signIn(identifier: '20 12 34 56', password: 'motdepasse', role: 'patient'), AuthError.needPin);
    expect(await store.signIn(identifier: '20123456', password: 'motdepasse', pin: '1111', role: 'patient'),
        AuthError.pin);
    expect(await store.signIn(identifier: '20123456', password: 'motdepasse', pin: '2468', role: 'patient'),
        AuthError.none);
    expect(store.dek, key);
    await store.signOut();

    final after = await _restart();
    expect(await after.signIn(identifier: '20123456', password: 'motdepasse', role: 'patient'), AuthError.none);
    expect(after.dek, key);
    expect(after.current!.hasPin, isFalse);
  });
}
