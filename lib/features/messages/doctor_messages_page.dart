import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/cloud.dart';
import '../../data/reminders.dart';
import '../../ui/app_theme.dart';
import '../common.dart';

String _title() => tr('Messages du médecin', aeb: 'رسائل الطبيب', ar: 'رسائل الطبيب', en: 'Messages from your doctor');

String _date(DateTime d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

String _time(DateTime d) => '${_date(d)} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

DateTime? _parse(Object? v) => v == null ? null : DateTime.tryParse('$v')?.toLocal();

/// On Today: the next visit and the doctor's last message, live.
class DoctorMessagesCard extends StatefulWidget {
  const DoctorMessagesCard({super.key});

  @override
  State<DoctorMessagesCard> createState() => _DoctorMessagesCardState();
}

class _DoctorMessagesCardState extends State<DoctorMessagesCard> {
  Stream<List<Map<String, dynamic>>> _messages = const Stream.empty();
  Stream<Map<String, dynamic>?> _record = const Stream.empty();

  bool _connected = false;

  @override
  void initState() {
    super.initState();
    KhatwaCloud.instance.addListener(_connect);
    _connect();
  }

  @override
  void dispose() {
    KhatwaCloud.instance.removeListener(_connect);
    super.dispose();
  }

  /// Only for a patient already on the shared data: the home screen never
  /// creates a record there by itself.
  void _connect() {
    final cloud = KhatwaCloud.instance;
    if (_connected || !cloud.ready || !cloud.hasPatient || !mounted) return;
    _connected = true;
    setState(() {
      _messages = cloud.messages().handleError((Object _) {});
      _record = cloud.myRecord().handleError((Object _) {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final rtl = Directionality.of(context) == TextDirection.rtl;
    return KCard(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DoctorMessagesPage())),
      padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(color: K.primarySoft, borderRadius: BorderRadius.circular(K.r12)),
            child: Icon(Icons.forum_outlined, color: K.primaryStrong),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_title(), style: K.bodyStrong),
                StreamBuilder<Map<String, dynamic>?>(
                  stream: _record,
                  builder: (context, snap) {
                    final visit = _parse(snap.data?['next_visit']);
                    if (visit == null) return const SizedBox.shrink();
                    return Text(
                        '${tr('Prochaine visite', aeb: 'الموعد الجاي', ar: 'الموعد القادم', en: 'Next visit')} : ${_date(visit)}',
                        style: K.small.copyWith(color: K.primaryStrong, fontWeight: FontWeight.w600));
                  },
                ),
                StreamBuilder<List<Map<String, dynamic>>>(
                  stream: _messages,
                  builder: (context, snap) {
                    final fromDoctor = (snap.data ?? const []).where((m) => m['sender'] == 'doctor').toList();
                    final last = fromDoctor.isEmpty ? null : '${fromDoctor.last['body']}';
                    return Text(
                      last ?? tr('Pas de message pour l’instant', aeb: 'حتى رسالة للتوّا', ar: 'لا رسائل حاليًا', en: 'No message yet'),
                      style: K.small,
                      textDirection: last == null ? null : dirOf(last),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    );
                  },
                ),
              ],
            ),
          ),
          Icon(rtl ? Icons.chevron_left_rounded : Icons.chevron_right_rounded, color: K.muted),
        ],
      ),
    );
  }
}

/// The conversation with the doctor, live, and the next visit they set.
class DoctorMessagesPage extends StatefulWidget {
  const DoctorMessagesPage({super.key});

  @override
  State<DoctorMessagesPage> createState() => _DoctorMessagesPageState();
}

class _DoctorMessagesPageState extends State<DoctorMessagesPage> {
  final _text = TextEditingController();
  Stream<List<Map<String, dynamic>>>? _messages;
  Stream<Map<String, dynamic>?> _record = const Stream.empty();
  bool _connecting = true;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _connect();
    Reminders.instance.messagesSeen();
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _connect() async {
    setState(() => _connecting = true);
    final cloud = KhatwaCloud.instance;
    final ok = cloud.ready &&
        await cloud.ensurePatient().timeout(const Duration(seconds: 10), onTimeout: () => false);
    if (!mounted) return;
    setState(() {
      _connecting = false;
      _messages = ok ? cloud.messages() : null;
      _record = ok ? cloud.myRecord().handleError((Object _) {}) : const Stream.empty();
    });
  }

  Future<void> _send() async {
    final body = _text.text.trim();
    if (body.isEmpty || _sending) return;
    setState(() => _sending = true);
    try {
      await KhatwaCloud.instance.sendMessage(body).timeout(const Duration(seconds: 15));
      _text.clear();
    } catch (_) {
      if (mounted) {
        kToast(
            context,
            tr('Message non envoyé. Vérifiez la connexion.',
                aeb: 'الرسالة ما تبعثتش. ثبّت في الكونكسيون.', ar: 'لم تُرسل الرسالة. تحقّق من الاتصال.', en: 'Message not sent. Check the connection.'),
            error: true);
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Widget _offline() => ListView(padding: const EdgeInsets.all(20), children: [
        KCard(
          color: K.warnSoft,
          child: Row(children: [
            Icon(Icons.cloud_off_rounded, color: K.warn),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                  tr('Pas de connexion pour le moment. Les messages de votre médecin apparaîtront ici.',
                      aeb: 'ما فمّاش كونكسيون توّا. رسائل الطبيب باش يبانو هنا.',
                      ar: 'لا يوجد اتصال حاليًا. ستظهر رسائل طبيبك هنا.',
                      en: 'No connection for now. Messages from your doctor will appear here.'),
                  style: K.body),
            ),
          ]),
        ),
        const SizedBox(height: 12),
        OutlinedButton(onPressed: _connect, child: Text(tr('Réessayer', aeb: 'عاود', ar: 'أعد المحاولة', en: 'Try again'))),
      ]);

  @override
  Widget build(BuildContext context) {
    final messages = _messages;
    return Scaffold(
      backgroundColor: K.ground,
      appBar: AppBar(title: Text(_title()), backgroundColor: K.ground, foregroundColor: K.ink),
      body: _connecting
          ? const Center(child: CircularProgressIndicator())
          : messages == null
              ? _offline()
              : Column(children: [
                  StreamBuilder<Map<String, dynamic>?>(
                    stream: _record,
                    builder: (context, snap) {
                      final visit = _parse(snap.data?['next_visit']);
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                        child: KBanner(
                          icon: Icons.event_outlined,
                          text: visit == null
                              ? tr('Pas de visite prévue pour l’instant.',
                                  aeb: 'حتى موعد للتوّا.', ar: 'لا يوجد موعد حاليًا.', en: 'No visit planned yet.')
                              : '${tr('Prochaine visite', aeb: 'الموعد الجاي', ar: 'الموعد القادم', en: 'Next visit')} : ${_date(visit)}',
                        ),
                      );
                    },
                  ),
                  Expanded(
                    child: StreamBuilder<List<Map<String, dynamic>>>(
                      stream: messages,
                      builder: (context, snap) {
                        if (snap.hasError) return _offline();
                        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                        final list = snap.data!;
                        if (list.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Text(
                                  tr('Pas encore de message. Vous pouvez écrire à votre médecin ci-dessous.',
                                      aeb: 'مازال حتى رسالة. تنجم تكتب لطبيبك لوطة.',
                                      ar: 'لا رسائل بعد. يمكنك الكتابة لطبيبك أدناه.',
                                      en: 'No message yet. You can write to your doctor below.'),
                                  textAlign: TextAlign.center,
                                  style: K.body.copyWith(color: K.muted)),
                            ),
                          );
                        }
                        return ListView.builder(
                          reverse: true,
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                          itemCount: list.length,
                          itemBuilder: (_, i) => _Bubble(list[list.length - 1 - i]),
                        );
                      },
                    ),
                  ),
                  SafeArea(
                    top: false,
                    child: Container(
                      color: K.surface,
                      padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
                      child: Row(children: [
                        Expanded(
                          child: TextField(
                            controller: _text,
                            minLines: 1,
                            maxLines: 4,
                            maxLength: 2000,
                            decoration: InputDecoration(
                                hintText: tr('Écrire à votre médecin', aeb: 'اكتب لطبيبك', ar: 'اكتب لطبيبك', en: 'Write to your doctor'),
                                counterText: '',
                                isDense: true),
                          ),
                        ),
                        IconButton(
                          tooltip: tr('Envoyer', aeb: 'ابعث', ar: 'إرسال', en: 'Send'),
                          onPressed: _sending ? null : _send,
                          icon: Icon(Icons.send_rounded, color: K.primary),
                        ),
                      ]),
                    ),
                  ),
                ]),
    );
  }
}

class _Bubble extends StatelessWidget {
  final Map<String, dynamic> m;
  const _Bubble(this.m);

  @override
  Widget build(BuildContext context) {
    final mine = m['sender'] == 'patient';
    final body = '${m['body'] ?? ''}';
    final at = _parse(m['created_at']);
    return Align(
      alignment: mine ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        decoration: BoxDecoration(
          color: mine ? K.primarySoft : K.surface,
          borderRadius: BorderRadius.circular(18),
          border: mine ? null : Border.all(color: K.line),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (!mine)
            Text(tr('Votre médecin', aeb: 'طبيبك', ar: 'طبيبك', en: 'Your doctor'),
                style: K.label.copyWith(color: K.primaryStrong)),
          Text(body, textDirection: dirOf(body), style: K.body),
          if (at != null) Text(_time(at), style: K.small.copyWith(fontFeatures: const [FontFeature.tabularFigures()])),
        ]),
      ),
    );
  }
}
