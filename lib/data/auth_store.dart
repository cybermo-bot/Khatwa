import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cloud.dart';
import 'crypto_box.dart';

/// A real account, stored on the device.
///
/// Passwords are never stored: only salted, iterated SHA-256 hashes.
/// `wrappedKey` holds the data encryption key of the local store, sealed with
/// a key derived from the password (`keySalt`). Without the password the key
/// cannot be recovered, so the stored cases stay unreadable.
///
/// Accounts made before the e-mail code replaced the PIN keep their key in
/// `wrappedDek`, sealed with the PIN: they sign in once with the PIN, and the
/// key is then sealed with the password instead and the PIN is dropped.
class Account {
  final String id;
  final String phone;
  final String email;
  final String name;
  final String role; // 'patient' or 'doctor'
  final String speciality;
  final String facility;
  final String salt;
  final String hash;
  final String keySalt;
  final String wrappedKey;
  final String pinSalt;
  final String pinHash;
  final String wrappedDek;
  final bool guest;
  final String createdAt;

  const Account({
    required this.id,
    required this.phone,
    required this.name,
    required this.role,
    required this.salt,
    required this.hash,
    required this.createdAt,
    this.email = '',
    this.speciality = '',
    this.facility = '',
    this.keySalt = '',
    this.wrappedKey = '',
    this.pinSalt = '',
    this.pinHash = '',
    this.wrappedDek = '',
    this.guest = false,
  });

  /// A PIN account not yet moved to the password-sealed key.
  bool get hasPin => pinHash.isNotEmpty && wrappedKey.isEmpty;

  Account copyWith({
    String? phone,
    String? email,
    String? name,
    String? salt,
    String? hash,
    String? keySalt,
    String? wrappedKey,
    String? pinSalt,
    String? pinHash,
    String? wrappedDek,
    bool? guest,
  }) =>
      Account(
        id: id,
        phone: phone ?? this.phone,
        email: email ?? this.email,
        name: name ?? this.name,
        role: role,
        speciality: speciality,
        facility: facility,
        salt: salt ?? this.salt,
        hash: hash ?? this.hash,
        keySalt: keySalt ?? this.keySalt,
        wrappedKey: wrappedKey ?? this.wrappedKey,
        pinSalt: pinSalt ?? this.pinSalt,
        pinHash: pinHash ?? this.pinHash,
        wrappedDek: wrappedDek ?? this.wrappedDek,
        guest: guest ?? this.guest,
        createdAt: createdAt,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'phone': phone,
        'email': email,
        'name': name,
        'role': role,
        'speciality': speciality,
        'facility': facility,
        'salt': salt,
        'hash': hash,
        'keySalt': keySalt,
        'wrappedKey': wrappedKey,
        'pinSalt': pinSalt,
        'pinHash': pinHash,
        'wrappedDek': wrappedDek,
        'guest': guest,
        'createdAt': createdAt,
      };

  static Account fromJson(Map<String, dynamic> json) => Account(
        id: '${json['id'] ?? ''}',
        phone: '${json['phone'] ?? ''}',
        email: '${json['email'] ?? ''}',
        name: '${json['name'] ?? ''}',
        role: '${json['role'] ?? 'patient'}',
        speciality: '${json['speciality'] ?? ''}',
        facility: '${json['facility'] ?? ''}',
        salt: '${json['salt'] ?? ''}',
        hash: '${json['hash'] ?? ''}',
        keySalt: '${json['keySalt'] ?? ''}',
        wrappedKey: '${json['wrappedKey'] ?? ''}',
        pinSalt: '${json['pinSalt'] ?? ''}',
        pinHash: '${json['pinHash'] ?? ''}',
        wrappedDek: '${json['wrappedDek'] ?? ''}',
        guest: json['guest'] == true,
        createdAt: '${json['createdAt'] ?? ''}',
      );
}

enum AuthError {
  none,
  fields,
  phone,
  email,
  short,
  match,
  exists,
  bad,
  pin,
  locked,

  /// A PIN account signing in for the first time since the PIN was removed.
  needPin,

  /// The password was right; the 6-digit e-mail code comes next.
  needCode,

  /// The e-mail code could not be sent.
  codeSend,

  /// The e-mail code is wrong or expired.
  code,
}

/// Sends and checks the 6-digit e-mail codes. Replaced in tests.
abstract class EmailCodes {
  const EmailCodes();
  Future<bool> send(String email);
  Future<bool> verify(String email, String code);
}

/// Codes through Supabase Auth (`signInWithOtp`, then `verifyOTP`).
class CloudEmailCodes extends EmailCodes {
  const CloudEmailCodes();

  @override
  Future<bool> send(String email) => KhatwaCloud.instance.sendEmailCode(email);

  @override
  Future<bool> verify(String email, String code) =>
      KhatwaCloud.instance.verifyEmailCode(email, code);
}

/// A sign-in or sign-up waiting for its e-mail code.
class _Pending {
  final Account account;
  final List<int>? key;
  final bool stay;
  final bool isNew;
  final bool upgrade;
  const _Pending(this.account, this.key, this.stay, {this.isNew = false, this.upgrade = false});
}

class AuthStore extends ChangeNotifier {
  AuthStore._();

  static final AuthStore instance = AuthStore._();

  static const _kAccounts = 'khatwa_accounts_v2';
  static const _kSession = 'khatwa_session_v2';
  static const _kLockout = 'khatwa_lockout_v1';
  static const _kStayChoice = 'khatwa_stay_signed_in';
  static const _kTrusted = 'khatwa_trusted_v1';
  static const int _iterations = 4000;

  /// Brute force protection.
  static const int maxAttempts = 5;
  static const Duration lockDuration = Duration(minutes: 1);

  /// Idle timeout, mostly for the shared clinician workstation. Not applied
  /// when "Rester connecté" was ticked.
  static const Duration idleTimeout = Duration(minutes: 10);

  /// A device where "Rester connecté" was ticked skips the e-mail code for
  /// this long.
  static const Duration trustedFor = Duration(days: 30);

  /// Sends and checks the e-mail codes.
  EmailCodes codes = const CloudEmailCodes();

  SharedPreferences? _prefs;
  bool _ready = false;

  final List<Account> _accounts = [];
  Map<String, dynamic> _lockout = {};
  Map<String, dynamic> _trusted = {};

  Account? current;

  /// Data encryption key of the local store, only in memory while a session
  /// is open, unless "Rester connecté" keeps the session on this device.
  List<int>? dek;

  /// This session survives restarts and is not locked when idle.
  bool staySignedIn = false;

  /// The device's remembered "Rester connecté" choice, for the checkbox.
  bool stayChoice = false;

  _Pending? _pending;

  /// The e-mail the pending code was sent to.
  String? get pendingEmail => _pending?.account.email;

  DateTime lastActivity = DateTime.now();

  bool get isSignedIn => current != null;
  bool get isDoctor => current?.role == 'doctor';
  bool get isGuest => current?.guest ?? false;
  bool get encryptionActive => dek != null;

  Future<void> init() async {
    if (_ready) return;
    _prefs = await SharedPreferences.getInstance();

    final raw = _prefs!.getString(_kAccounts);
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          for (final item in decoded) {
            if (item is Map) {
              _accounts.add(Account.fromJson(Map<String, dynamic>.from(item)));
            }
          }
        }
      } catch (_) {}
    }

    _lockout = _readMap(_kLockout);
    _trusted = _readMap(_kTrusted);
    stayChoice = _prefs!.getBool(_kStayChoice) ?? false;

    // A session is restored only when "Rester connecté" was ticked (or for a
    // guest, who has no password): the key is then kept on this device.
    final session = _readMap(_kSession);
    final key = session['key'];
    final account = _byId('${session['id'] ?? ''}');
    if (account != null && key is String && session['stay'] == true) {
      try {
        current = account;
        dek = key.isEmpty ? null : base64Decode(key);
        staySignedIn = true;
      } catch (_) {
        current = null;
        dek = null;
      }
    }
    if (current == null) await _prefs!.remove(_kSession);

    _ready = true;
    notifyListeners();
  }

  Map<String, dynamic> _readMap(String key) {
    final raw = _prefs!.getString(key);
    if (raw == null || raw.isEmpty) return {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    } catch (_) {}
    return {};
  }

  Account? _byId(String id) {
    for (final a in _accounts) {
      if (a.id == id) return a;
    }
    return null;
  }

  void touch() => lastActivity = DateTime.now();

  bool get idleExpired =>
      isSignedIn && !staySignedIn && DateTime.now().difference(lastActivity) > idleTimeout;

  // ---------------------------------------------------------------- hashing

  String _newSalt() => base64Url.encode(CryptoBox.randomBytes(16));

  String _hash(String secret, String salt) {
    var digest = sha256.convert(utf8.encode('$salt|$secret'));
    for (var i = 1; i < _iterations; i++) {
      digest = sha256.convert(digest.bytes);
    }
    return digest.toString();
  }

  bool _constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return diff == 0;
  }

  // ------------------------------------------------------------------ utils

  String normalisePhone(String input) {
    final digits = input.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length > 8 && digits.startsWith('216')) {
      return digits.substring(digits.length - 8);
    }
    return digits;
  }

  static String normaliseEmail(String input) => input.trim().toLowerCase();

  static bool validEmail(String email) =>
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]{2,}$').hasMatch(email);

  static bool _validPhone(String phone) => RegExp(r'^[0-9]{8}$').hasMatch(phone);

  static bool _validPin(String pin) => RegExp(r'^[0-9]{4,6}$').hasMatch(pin);

  /// The checks of the sign-up form, in the order the patient reads it:
  /// name, e-mail, optional phone (8 digits), password of 8 or more, confirm.
  static AuthError validateSignUp({
    required String name,
    required String email,
    required String password,
    required String confirm,
    String phone = '',
  }) {
    if (name.trim().isEmpty || email.trim().isEmpty || password.isEmpty) {
      return AuthError.fields;
    }
    if (!validEmail(normaliseEmail(email))) return AuthError.email;
    final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final local = digits.length > 8 && digits.startsWith('216') ? digits.substring(digits.length - 8) : digits;
    if (local.isNotEmpty && !_validPhone(local)) return AuthError.phone;
    if (password.length < 8) return AuthError.short;
    if (password != confirm) return AuthError.match;
    return AuthError.none;
  }

  String _lockKey(String identifier, String role) => '$role:$identifier';

  String _identifier(String input) =>
      input.contains('@') ? normaliseEmail(input) : normalisePhone(input);

  /// Remaining lock time in seconds, 0 when not locked.
  int lockedSeconds(String identifier, String role) {
    final entry = _lockout[_lockKey(_identifier(identifier), role)];
    if (entry is! Map) return 0;
    final until = DateTime.tryParse('${entry['until'] ?? ''}');
    if (until == null) return 0;
    final remaining = until.difference(DateTime.now()).inSeconds;
    return remaining > 0 ? remaining : 0;
  }

  Future<void> _registerFailure(String identifier, String role) async {
    final key = _lockKey(identifier, role);
    final entry = _lockout[key] is Map
        ? Map<String, dynamic>.from(_lockout[key] as Map)
        : <String, dynamic>{'count': 0};

    final count = (entry['count'] is int ? entry['count'] as int : 0) + 1;
    entry['count'] = count;

    if (count >= maxAttempts) {
      entry['until'] = DateTime.now().add(lockDuration).toIso8601String();
      entry['count'] = 0;
    }

    _lockout[key] = entry;
    await _persistLockout();
  }

  Future<void> _clearFailures(String identifier, String role) async {
    _lockout.remove(_lockKey(identifier, role));
    await _persistLockout();
  }

  Future<void> _persistLockout() async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setString(_kLockout, jsonEncode(_lockout));
  }

  Future<void> _persist() async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setString(
      _kAccounts,
      jsonEncode(_accounts.map((account) => account.toJson()).toList()),
    );
  }

  void _replace(Account account) {
    final i = _accounts.indexWhere((a) => a.id == account.id);
    if (i >= 0) {
      _accounts[i] = account;
    } else {
      _accounts.add(account);
    }
  }

  /// The key that wraps the data encryption key, derived from a secret.
  List<int> _kek(String secret, String salt) => CryptoBox.deriveKey(secret, salt);

  /// Whether this device skips the e-mail code for this account.
  bool isTrusted(String accountId) {
    final at = DateTime.tryParse('${_trusted[accountId] ?? ''}');
    return at != null && DateTime.now().difference(at) < trustedFor;
  }

  Future<void> _trust(String accountId) async {
    _trusted[accountId] = DateTime.now().toIso8601String();
    await _prefs!.setString(_kTrusted, jsonEncode(_trusted));
  }

  /// Remembers the "Rester connecté" choice of this device.
  Future<void> setStayChoice(bool value) async {
    stayChoice = value;
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setBool(_kStayChoice, value);
  }

  // ------------------------------------------------------------------- open

  Future<void> _open(Account account, List<int>? key, {required bool stay}) async {
    current = account;
    dek = key;
    staySignedIn = stay || account.guest;
    _pending = null;
    if (staySignedIn) {
      await _prefs!.setString(
          _kSession,
          jsonEncode({
            'id': account.id,
            'key': key == null ? '' : base64Encode(key),
            'stay': true,
          }));
      if (!account.guest) await _trust(account.id);
    } else {
      await _prefs!.remove(_kSession);
    }
    touch();
    notifyListeners();
  }

  /// Used when a second account is created on a device that already holds
  /// encrypted cases: the key is already in memory from the open session.
  List<int> _storeKey() => dek ?? CryptoBox.randomBytes(32);

  Account _newAccount({
    required String role,
    required String name,
    required String email,
    required String phone,
    required String password,
    required List<int> key,
    String speciality = '',
    String facility = '',
    bool guest = false,
  }) {
    final salt = _newSalt();
    final keySalt = _newSalt();
    final stamp = DateTime.now().millisecondsSinceEpoch;
    final tag = guest ? 'guest' : (role == 'doctor' ? 'doc' : 'pat');
    return Account(
      id: '${tag}_${base64Url.encode(CryptoBox.randomBytes(6))}_$stamp',
      phone: phone,
      email: email,
      name: name.trim(),
      role: role,
      speciality: speciality.trim(),
      facility: facility.trim(),
      salt: salt,
      hash: _hash(password, salt),
      keySalt: keySalt,
      wrappedKey: CryptoBox.seal(base64Encode(key), _kek(password, keySalt)),
      guest: guest,
      createdAt: DateTime.now().toIso8601String(),
    );
  }

  // ------------------------------------------------------------------ guest

  /// A guest account made on the spot: nothing to type, no real data. It
  /// stays signed in on this device and can become a real account later.
  Future<AuthError> signInGuest({String role = 'patient'}) async {
    await init();
    // One guest per device: an older guest whose session is gone is removed.
    _accounts.removeWhere((a) => a.guest && a.role == role && a.id != current?.id);
    final key = CryptoBox.randomBytes(32);
    final password = base64Url.encode(CryptoBox.randomBytes(18));
    final account = _newAccount(
      role: role,
      name: role == 'doctor' ? 'Dr Démo' : 'Invité',
      email: '',
      phone: '',
      password: password,
      key: key,
      guest: true,
    );
    _accounts.add(account);
    await _persist();
    await _open(account, key, stay: true);
    return AuthError.none;
  }

  // ------------------------------------------------------------------ sign up

  /// Checks the form and prepares the account; the e-mail code comes next
  /// (`sendCode`, then `confirmCode`). A guest who signs up keeps their data.
  Future<AuthError> beginSignUp({
    required String name,
    required String email,
    required String password,
    required String confirm,
    required String role,
    String phone = '',
    String speciality = '',
    String facility = '',
    bool stay = false,
  }) async {
    await init();
    final check = validateSignUp(name: name, email: email, password: password, confirm: confirm, phone: phone);
    if (check != AuthError.none) return check;

    final cleanEmail = normaliseEmail(email);
    final cleanPhone = normalisePhone(phone);
    final taken = _accounts.any((a) => a.role == role && !a.guest && a.email == cleanEmail);
    if (taken) return AuthError.exists;

    final guest = current != null && current!.guest && current!.role == role ? current : null;
    final key = guest != null ? (dek ?? CryptoBox.randomBytes(32)) : _storeKey();
    var account = _newAccount(
      role: role,
      name: name,
      email: cleanEmail,
      phone: cleanPhone,
      password: password,
      key: key,
      speciality: speciality,
      facility: facility,
    );
    if (guest != null) {
      // Same id, so the routine, the checks and the cases stay with the person.
      account = guest.copyWith(
        name: account.name,
        email: account.email,
        phone: account.phone,
        salt: account.salt,
        hash: account.hash,
        keySalt: account.keySalt,
        wrappedKey: account.wrappedKey,
        guest: false,
      );
    }
    _pending = _Pending(account, key, stay, isNew: true, upgrade: guest != null);
    return AuthError.none;
  }

  // ------------------------------------------------------------------ sign in

  /// E-mail (or, for an older account, phone) and password. Returns
  /// [AuthError.needCode] when the e-mail code must follow, and
  /// [AuthError.needPin] once for an account that still has a PIN.
  Future<AuthError> signIn({
    required String identifier,
    required String password,
    required String role,
    String pin = '',
    bool stay = false,
  }) async {
    await init();

    final id = _identifier(identifier);
    if (id.isEmpty || password.isEmpty) return AuthError.fields;
    if (lockedSeconds(id, role) > 0) return AuthError.locked;

    Account? account;
    for (final a in _accounts) {
      if (a.role != role || a.guest) continue;
      if ((id.contains('@') && a.email == id) || (!id.contains('@') && a.phone == id && a.phone.isNotEmpty)) {
        account = a;
        break;
      }
    }

    // A doctor of the shared data signs in there with the same e-mail and
    // password, so the dashboard shows live data at once.
    var cloudVerified = false;
    if (role == 'doctor' && id.contains('@')) {
      cloudVerified = await KhatwaCloud.instance.signInDoctor(id, password) == null;
      if (account == null && cloudVerified) {
        final made = _newAccount(
          role: role,
          name: KhatwaCloud.instance.doctorName ?? id.split('@').first,
          email: id,
          phone: '',
          password: password,
          key: _storeKey(),
        );
        _accounts.add(made);
        await _persist();
        account = made;
      }
    }

    if (account == null) {
      await _registerFailure(id, role);
      return lockedSeconds(id, role) > 0 ? AuthError.locked : AuthError.bad;
    }

    if (!_constantTimeEquals(account.hash, _hash(password, account.salt))) {
      await _registerFailure(id, role);
      return lockedSeconds(id, role) > 0 ? AuthError.locked : AuthError.bad;
    }

    List<int>? key;
    if (account.wrappedKey.isNotEmpty) {
      final unwrapped = CryptoBox.open(account.wrappedKey, _kek(password, account.keySalt));
      key = unwrapped == null ? null : base64Decode(unwrapped);
    } else if (account.hasPin) {
      if (pin.isEmpty) return AuthError.needPin;
      if (!_validPin(pin) || !_constantTimeEquals(account.pinHash, _hash(pin, account.pinSalt))) {
        await _registerFailure(id, role);
        return lockedSeconds(id, role) > 0 ? AuthError.locked : AuthError.pin;
      }
      final unwrapped = CryptoBox.open(account.wrappedDek, _kek(pin, account.pinSalt));
      key = unwrapped == null ? null : base64Decode(unwrapped);
      if (key != null) {
        // From now on the key is sealed with the password; the PIN is gone.
        final keySalt = _newSalt();
        account = account.copyWith(
          keySalt: keySalt,
          wrappedKey: CryptoBox.seal(base64Encode(key), _kek(password, keySalt)),
          pinSalt: '',
          pinHash: '',
          wrappedDek: '',
        );
        _replace(account);
        await _persist();
      }
    } // else: a legacy account created before encryption was added.

    await _clearFailures(id, role);

    final needsCode = account.email.isNotEmpty && !cloudVerified && !isTrusted(account.id);
    if (needsCode) {
      _pending = _Pending(account, key, stay);
      return AuthError.needCode;
    }
    await _open(account, key, stay: stay);
    return AuthError.none;
  }

  // ------------------------------------------------------------------- codes

  /// Sends the 6-digit code for the pending sign-in or sign-up.
  Future<AuthError> sendCode() async {
    final email = _pending?.account.email;
    if (email == null || email.isEmpty) return AuthError.fields;
    return await codes.send(email) ? AuthError.none : AuthError.codeSend;
  }

  /// Checks the code and opens the session.
  Future<AuthError> confirmCode(String code) async {
    final pending = _pending;
    if (pending == null) return AuthError.fields;
    final clean = code.replaceAll(RegExp(r'\s'), '');
    if (!RegExp(r'^[0-9]{6}$').hasMatch(clean)) return AuthError.code;
    final ok = await codes.verify(pending.account.email, clean);
    if (!ok) return AuthError.code;
    if (pending.isNew) {
      _replace(pending.account);
      await _persist();
    }
    await _open(pending.account, pending.key, stay: pending.stay || pending.upgrade);
    return AuthError.none;
  }

  /// Drops a pending sign-in or sign-up (the patient went back).
  void cancelPending() => _pending = null;

  Future<void> signOut() async {
    final wasGuest = current?.guest ?? false;
    final id = current?.id;
    current = null;
    dek = null; // the store becomes unreadable again
    staySignedIn = false;
    _pending = null;
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.remove(_kSession);
    if (wasGuest) {
      // A guest has no password: once signed out, the account cannot be opened.
      _accounts.removeWhere((a) => a.id == id);
      await _persist();
    }
    await KhatwaCloud.instance.signOut();
    notifyListeners();
  }

  String errorKey(AuthError error) {
    switch (error) {
      case AuthError.fields:
        return 'auth.err.fields';
      case AuthError.phone:
        return 'auth.err.phone';
      case AuthError.email:
        return 'auth.err.email';
      case AuthError.short:
        return 'auth.err.short';
      case AuthError.match:
        return 'auth.err.match';
      case AuthError.exists:
        return 'auth.err.emailExists';
      case AuthError.bad:
        return 'auth.err.bad';
      case AuthError.pin:
        return 'auth.err.pin';
      case AuthError.locked:
        return 'auth.err.locked';
      case AuthError.needPin:
        return 'auth.err.needPin';
      case AuthError.needCode:
        return '';
      case AuthError.codeSend:
        return 'auth.err.codeSend';
      case AuthError.code:
        return 'auth.err.code';
      case AuthError.none:
        return '';
    }
  }

  /// Test hook: forget everything held in memory, as after a restart.
  @visibleForTesting
  void resetForTest() {
    _ready = false;
    _accounts.clear();
    _lockout = {};
    _trusted = {};
    current = null;
    dek = null;
    staySignedIn = false;
    _pending = null;
  }
}
