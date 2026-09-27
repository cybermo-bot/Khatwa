import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../features/common.dart';
import 'auth_store.dart';
import 'case_store.dart';
import 'cloud.dart';
import 'triage.dart';

/// What the patient wants to be reminded of, and when.
class ReminderSettings {
  final bool check;
  final TimeOfDay checkAt;
  final bool care;
  final TimeOfDay careAt;
  final bool glucose;
  final TimeOfDay glucoseAt;

  /// A recheck after an amber or red check, a visit the day before, and a
  /// new message from the doctor.
  final bool followUp;
  final bool visit;
  final bool messages;

  const ReminderSettings({
    this.check = true,
    this.checkAt = const TimeOfDay(hour: 19, minute: 0),
    this.care = false,
    this.careAt = const TimeOfDay(hour: 21, minute: 30),
    this.glucose = false,
    this.glucoseAt = const TimeOfDay(hour: 8, minute: 0),
    this.followUp = true,
    this.visit = true,
    this.messages = true,
  });

  ReminderSettings copyWith({
    bool? check,
    TimeOfDay? checkAt,
    bool? care,
    TimeOfDay? careAt,
    bool? glucose,
    TimeOfDay? glucoseAt,
    bool? followUp,
    bool? visit,
    bool? messages,
  }) =>
      ReminderSettings(
        check: check ?? this.check,
        checkAt: checkAt ?? this.checkAt,
        care: care ?? this.care,
        careAt: careAt ?? this.careAt,
        glucose: glucose ?? this.glucose,
        glucoseAt: glucoseAt ?? this.glucoseAt,
        followUp: followUp ?? this.followUp,
        visit: visit ?? this.visit,
        messages: messages ?? this.messages,
      );

  static String _t(TimeOfDay t) => '${t.hour}:${t.minute}';
  static TimeOfDay _p(Object? s, TimeOfDay fallback) {
    final parts = '$s'.split(':');
    final h = int.tryParse(parts.first), m = parts.length > 1 ? int.tryParse(parts[1]) : null;
    return h == null || m == null ? fallback : TimeOfDay(hour: h, minute: m);
  }

  Map<String, Object> toJson() => {
        'check': check,
        'checkAt': _t(checkAt),
        'care': care,
        'careAt': _t(careAt),
        'glucose': glucose,
        'glucoseAt': _t(glucoseAt),
        'followUp': followUp,
        'visit': visit,
        'messages': messages,
      };

  factory ReminderSettings.fromJson(Map<String, dynamic> j) {
    const d = ReminderSettings();
    return ReminderSettings(
      check: j['check'] as bool? ?? d.check,
      checkAt: _p(j['checkAt'], d.checkAt),
      care: j['care'] as bool? ?? d.care,
      careAt: _p(j['careAt'], d.careAt),
      glucose: j['glucose'] as bool? ?? d.glucose,
      glucoseAt: _p(j['glucoseAt'], d.glucoseAt),
      followUp: j['followUp'] as bool? ?? d.followUp,
      visit: j['visit'] as bool? ?? d.visit,
      messages: j['messages'] as bool? ?? d.messages,
    );
  }
}

/// One thing to do now, shown on the home screen (phone and web alike).
class Nudge {
  final String kind; // 'recheck' | 'message' | 'visit'
  final String title;
  final String body;
  const Nudge(this.kind, this.title, this.body);
}

/// Reminders: phone notifications on Android (daily check, care, glucose,
/// recheck after a worrying check, visit the day before, doctor messages),
/// and the same things as nudges inside the app, which is what the web gets.
class Reminders extends ChangeNotifier {
  Reminders._();
  static final Reminders instance = Reminders._();

  static const _kSettings = 'khatwa_reminders';
  static const _kAsked = 'khatwa_reminders_asked';
  static const _kSeenMessage = 'khatwa_seen_message';
  static const _kNotifiedMessage = 'khatwa_notified_message';

  // Notification ids.
  static const _idCheck = 1, _idCare = 2, _idGlucose = 3, _idRecheck = 100, _idVisit = 200, _idMessage = 300;

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;
  ReminderSettings settings = const ReminderSettings();

  /// The doctor's latest message not yet opened, and the next visit.
  Map<String, dynamic>? unreadMessage;
  DateTime? nextVisit;
  StreamSubscription<Object?>? _messagesSub, _recordSub;

  /// System notifications work on Android only; the web keeps the nudges.
  static bool get systemNotifications => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  Future<void> init() async {
    try {
      final raw = (await SharedPreferences.getInstance()).getString(_kSettings);
      if (raw != null) settings = ReminderSettings.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {}
    if (!systemNotifications) return;
    try {
      tzdata.initializeTimeZones();
      try {
        tz.setLocalLocation(tz.getLocation((await FlutterTimezone.getLocalTimezone()).identifier));
      } catch (_) {
        tz.setLocalLocation(tz.getLocation('Africa/Tunis'));
      }
      await _plugin.initialize(settings: const InitializationSettings(android: AndroidInitializationSettings('@mipmap/ic_launcher')));
      _ready = true;
    } catch (_) {
      _ready = false;
    }
  }

  /// After sign-in: asks once for the permission, sets the daily reminders
  /// and listens to the doctor's messages and visit date.
  Future<void> start() async {
    if (AuthStore.instance.current == null || AuthStore.instance.current?.role == 'doctor') return;
    if (_ready) {
      final prefs = await SharedPreferences.getInstance();
      if (!(prefs.getBool(_kAsked) ?? false)) {
        await prefs.setBool(_kAsked, true);
        await requestPermission();
      }
      await sync();
    }
    _watchCloud();
  }

  Future<bool> requestPermission() async {
    if (!_ready) return false;
    try {
      return await _plugin
              .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
              ?.requestNotificationsPermission() ??
          false;
    } catch (_) {
      return false;
    }
  }

  Future<void> save(ReminderSettings next) async {
    settings = next;
    notifyListeners();
    try {
      await (await SharedPreferences.getInstance()).setString(_kSettings, jsonEncode(next.toJson()));
    } catch (_) {}
    await sync();
  }

  // ------------------------------------------------------------ texts
  // Built when scheduled, in the app's language at that moment; sync() runs
  // again when the language changes.

  static String get _checkTitle => tr('Le contrôle de vos pieds', aeb: 'فحص ساقيك', ar: 'فحص قدميك', en: 'Your foot check');
  static String get _checkBody => tr('Deux minutes ce soir : regardez vos pieds, entre les orteils et sous le talon.',
      aeb: 'دقيقتين الليلة: شوف ساقيك، بين الصوابع وتحت الكعبة.',
      ar: 'دقيقتان هذا المساء: انظر إلى قدميك، بين الأصابع وتحت الكعب.',
      en: 'Two minutes tonight: look at your feet, between the toes and under the heel.');
  static String get _careTitle => tr('Le soin du soir', aeb: 'عناية الليل', ar: 'عناية المساء', en: 'Evening care');
  static String get _careBody => tr('Crème sur les talons, jamais entre les orteils. Des chaussettes propres pour demain.',
      aeb: 'كريمة على الكعبة، موش بين الصوابع. كلسيطات نظاف لغدوة.',
      ar: 'كريم على الكعبين، لا بين الأصابع. جوارب نظيفة للغد.',
      en: 'Cream on the heels, never between the toes. Clean socks for tomorrow.');
  static String get _glucoseTitle => tr('Votre glycémie', aeb: 'السكر متاعك', ar: 'سكر الدم', en: 'Your blood sugar');
  static String get _glucoseBody => tr('Notez votre glycémie du matin dans Khatwa.',
      aeb: 'سجّل السكر متاع الصباح في خطوة.', ar: 'سجّل سكر الصباح في خطوة.', en: 'Log your morning blood sugar in Khatwa.');

  // ------------------------------------------------------------ scheduling

  NotificationDetails get _details => const NotificationDetails(
        android: AndroidNotificationDetails('khatwa_reminders', 'Khatwa',
            channelDescription: 'Rappels du contrôle des pieds', importance: Importance.high, priority: Priority.high),
      );

  tz.TZDateTime _nextAt(TimeOfDay t, {int addDays = 0}) {
    final now = tz.TZDateTime.now(tz.local);
    var at = tz.TZDateTime(tz.local, now.year, now.month, now.day, t.hour, t.minute).add(Duration(days: addDays));
    if (addDays == 0 && !at.isAfter(now)) at = at.add(const Duration(days: 1));
    return at;
  }

  Future<void> _daily(int id, bool on, TimeOfDay at, String title, String body) async {
    await _plugin.cancel(id: id);
    if (!on) return;
    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: _nextAt(at),
      notificationDetails: _details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Sets the daily reminders again from the settings.
  Future<void> sync() async {
    if (!_ready) return;
    try {
      await _daily(_idCheck, settings.check, settings.checkAt, _checkTitle, _checkBody);
      await _daily(_idCare, settings.care, settings.careAt, _careTitle, _careBody);
      await _daily(_idGlucose, settings.glucose, settings.glucoseAt, _glucoseTitle, _glucoseBody);
    } catch (_) {}
  }

  /// After a check: amber asks for a recheck in two days, red the next day
  /// (after seeing a professional). Green cancels a pending recheck.
  Future<void> afterCheck(TriageResult triage) async {
    notifyListeners();
    if (!_ready) return;
    try {
      await _plugin.cancel(id: _idRecheck);
      if (!settings.followUp || triage.level == TriageLevel.green) return;
      final red = triage.level == TriageLevel.red;
      final sign = triage.findings.isEmpty ? '' : triage.findings.first.label;
      await _plugin.zonedSchedule(
        id: _idRecheck,
        title: red
            ? tr('Avez-vous pu consulter ?', aeb: 'مشيت للطبيب؟', ar: 'هل استشرت الطبيب؟', en: 'Did you see a professional?')
            : tr('Un nouveau contrôle aujourd’hui', aeb: 'فحص جديد اليوم', ar: 'فحص جديد اليوم', en: 'A new check today'),
        body: red
            ? tr('Faites un nouveau contrôle aujourd’hui pour suivre l’évolution.', aeb: 'اعمل فحص جديد اليوم باش تتبّع.', ar: 'قم بفحص جديد اليوم لمتابعة التطور.', en: 'Do a new check today to follow how it changes.')
            : tr('Regardez à nouveau : $sign.', aeb: 'عاود شوف: $sign.', ar: 'انظر مجددًا: $sign.', en: 'Look again: $sign.'),
        scheduledDate: _nextAt(settings.checkAt, addDays: red ? 1 : 2),
        notificationDetails: _details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } catch (_) {}
  }

  Future<void> _scheduleVisit(DateTime visit) async {
    if (!_ready) return;
    try {
      await _plugin.cancel(id: _idVisit);
      if (!settings.visit) return;
      final eve = tz.TZDateTime(tz.local, visit.year, visit.month, visit.day, 18).subtract(const Duration(days: 1));
      if (!eve.isAfter(tz.TZDateTime.now(tz.local))) return;
      await _plugin.zonedSchedule(
        id: _idVisit,
        title: tr('Rendez-vous demain', aeb: 'موعد غدوة', ar: 'موعد غدًا', en: 'Appointment tomorrow'),
        body: tr('Emportez vos chaussures habituelles et la liste de vos médicaments.',
            aeb: 'هز صبابطك العاديين وليستة الدواء متاعك.',
            ar: 'أحضر حذاءك المعتاد وقائمة أدويتك.',
            en: 'Bring your usual shoes and the list of your medicines.'),
        scheduledDate: eve,
        notificationDetails: _details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } catch (_) {}
  }

  // ------------------------------------------------------------ the doctor

  void _watchCloud() {
    final cloud = KhatwaCloud.instance;
    _messagesSub?.cancel();
    _recordSub?.cancel();
    _messagesSub = cloud.messages().listen((rows) async {
      final fromDoctor = rows.where((m) => m['sender'] == 'doctor').toList();
      if (fromDoctor.isEmpty) return;
      final last = fromDoctor.last;
      final prefs = await SharedPreferences.getInstance();
      final id = '${last['id']}';
      final isNew = id != prefs.getString(_kSeenMessage);
      unreadMessage = isNew ? last : null;
      notifyListeners();
      // One phone notification per message, not one per app start.
      if (isNew && id != prefs.getString(_kNotifiedMessage) && _ready && settings.messages) {
        await prefs.setString(_kNotifiedMessage, id);
        try {
          await _plugin.show(
            id: _idMessage,
            title: tr('Message de votre médecin', aeb: 'مساج من الطبيب متاعك', ar: 'رسالة من طبيبك', en: 'Message from your doctor'),
            body: '${last['body'] ?? ''}',
            notificationDetails: _details,
          );
        } catch (_) {}
      }
    }, onError: (Object _) {});
    _recordSub = cloud.myRecord().listen((row) {
      final v = DateTime.tryParse('${row?['next_visit'] ?? ''}');
      if (v == nextVisit) return;
      nextVisit = v;
      notifyListeners();
      if (v != null) _scheduleVisit(v);
    }, onError: (Object _) {});
  }

  /// The messages page was opened: the latest message is read.
  Future<void> messagesSeen() async {
    final m = unreadMessage;
    unreadMessage = null;
    notifyListeners();
    if (m == null) return;
    try {
      await (await SharedPreferences.getInstance()).setString(_kSeenMessage, '${m['id']}');
    } catch (_) {}
  }

  // ------------------------------------------------------------ in the app

  /// What to do now, most important first.
  List<Nudge> nudges(String patientId, {DateTime? now}) {
    final today = now ?? DateTime.now();
    final out = <Nudge>[];
    final cases = CaseStore.instance.forPatient(patientId);
    if (cases.isNotEmpty) {
      final last = cases.first;
      final days = DateTime(today.year, today.month, today.day)
          .difference(DateTime(last.date.year, last.date.month, last.date.day))
          .inDays;
      final level = last.triage.level;
      if (level != TriageLevel.green && days >= (level == TriageLevel.red ? 1 : 2) && days <= 7) {
        final sign = last.triage.findings.isEmpty ? '' : last.triage.findings.first.label;
        out.add(Nudge(
          'recheck',
          tr('Un nouveau contrôle aujourd’hui', aeb: 'فحص جديد اليوم', ar: 'فحص جديد اليوم', en: 'A new check today'),
          sign.isEmpty
              ? tr('Votre dernier contrôle demandait un suivi.', aeb: 'الفحص اللي فات يستحق متابعة.', ar: 'فحصك الأخير يحتاج إلى متابعة.', en: 'Your last check needed a follow-up.')
              : tr('Il y a $days jours : $sign. Regardez à nouveau.', aeb: 'من $days أيام: $sign. عاود شوف.', ar: 'قبل $days أيام: $sign. انظر مجددًا.', en: '$days days ago: $sign. Look again.'),
        ));
      }
    }
    final m = unreadMessage;
    if (m != null) {
      out.add(Nudge('message', tr('Message de votre médecin', aeb: 'مساج من الطبيب متاعك', ar: 'رسالة من طبيبك', en: 'Message from your doctor'),
          '${m['body'] ?? ''}'));
    }
    final v = nextVisit;
    if (v != null) {
      final d = DateTime(v.year, v.month, v.day).difference(DateTime(today.year, today.month, today.day)).inDays;
      if (d >= 0 && d <= 3) {
        final when = d == 0
            ? tr('aujourd’hui', aeb: 'اليوم', ar: 'اليوم', en: 'today')
            : d == 1
                ? tr('demain', aeb: 'غدوة', ar: 'غدًا', en: 'tomorrow')
                : '${v.day.toString().padLeft(2, '0')}/${v.month.toString().padLeft(2, '0')}';
        out.add(Nudge('visit', tr('Rendez-vous $when', aeb: 'موعد $when', ar: 'موعد $when', en: 'Appointment $when'),
            tr('Emportez vos chaussures habituelles.', aeb: 'هز صبابطك العاديين.', ar: 'أحضر حذاءك المعتاد.', en: 'Bring your usual shoes.')));
      }
    }
    return out;
  }

  /// A reminder now, to see how it looks (the Reminders page).
  Future<bool> test() async {
    if (!_ready) return false;
    try {
      await _plugin.show(id: 9, title: _checkTitle, body: _checkBody, notificationDetails: _details);
      return true;
    } catch (_) {
      return false;
    }
  }
}
