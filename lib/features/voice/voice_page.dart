import 'dart:async';
import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:image_picker/image_picker.dart' show XFile;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../data/khatwa_server.dart';
import '../../ui/app_theme.dart';
import '../common.dart';

class _Msg {
  final bool mine;
  String text;
  final String urgency; // none | soon | urgent
  final List<String> articles;
  bool pending; // a voice message sent, its words not back yet
  _Msg(this.mine, this.text, {this.urgency = 'none', this.articles = const [], this.pending = false});
}

/// Voice first: hold the big button, speak, release (or tap once to start and
/// once to send). Answers come in the patient's language, Tunisian derja by
/// default, with a Tunisian voice. Once any answer is urgent, the 190 banner
/// stays for the session, and the doctor gets an alert.
class VoicePage extends StatefulWidget {
  const VoicePage({super.key});

  @override
  State<VoicePage> createState() => _VoicePageState();
}

class _VoicePageState extends State<VoicePage> {
  final _server = KhatwaServer();
  final _recorder = AudioRecorder();
  final _player = AudioPlayer();
  final _tts = FlutterTts();
  final _stt = SpeechToText();
  final _msgs = <_Msg>[];
  final _history = <Map<String, String>>[];
  final _scroll = ScrollController();
  final _text = TextEditingController();

  bool _recording = false;
  bool _starting = false;
  bool _pressed = false;
  bool _tapMode = false;
  bool _thinking = false;
  bool _speaking = false;
  bool _urgentSeen = false;
  bool _deviceStt = false;
  String _sttText = '';
  DateTime? _pressAt;
  Timer? _limit;

  static const _locales = {'aeb': 'ar_TN', 'ar': 'ar_SA', 'fr': 'fr_FR', 'en': 'en_GB'};
  static const _ttsLang = {'aeb': 'ar', 'ar': 'ar', 'fr': 'fr-FR', 'en': 'en-GB'};
  static const _shortPress = Duration(milliseconds: 600);

  String get _lang => langCode();

  @override
  void dispose() {
    _limit?.cancel();
    _recorder.dispose();
    _player.dispose();
    _tts.stop();
    _stt.stop();
    _scroll.dispose();
    _text.dispose();
    super.dispose();
  }

  // Raw pointer events: a shaky finger that slides a little does not cancel.
  void _down() {
    if (_thinking) return;
    if (_recording && _tapMode) {
      _stop();
      return;
    }
    _pressed = true;
    _pressAt = DateTime.now();
    _start();
  }

  void _up() {
    _pressed = false;
    if (!_recording) return;
    final held = DateTime.now().difference(_pressAt ?? DateTime.now());
    if (held < _shortPress && !_tapMode) {
      setState(() => _tapMode = true);
      return;
    }
    if (!_tapMode) _stop();
  }

  Future<void> _start() async {
    if (_starting || _recording) return;
    _starting = true;
    try {
      await _player.stop();
      await _tts.stop();
      if (_deviceStt) {
        if (!await _stt.initialize()) {
          if (mounted) kToast(context, 'Reconnaissance vocale indisponible sur ce téléphone.', error: true);
          return;
        }
        _sttText = '';
        await _stt.listen(
          onResult: (r) => _sttText = r.recognizedWords,
          listenOptions: SpeechListenOptions(partialResults: true, localeId: _locales[_lang]),
        );
      } else {
        if (!await _recorder.hasPermission()) {
          if (mounted) kToast(context, 'Autorisez le micro pour parler à Khatwa.', error: true);
          return;
        }
        // WAV everywhere: every phone and browser records it, and the AI reads it.
        const config = RecordConfig(encoder: AudioEncoder.wav, sampleRate: 16000, numChannels: 1);
        final path = kIsWeb
            ? ''
            : '${(await getTemporaryDirectory()).path}/khatwa_voice_${DateTime.now().millisecondsSinceEpoch}.wav';
        await _recorder.start(config, path: path);
      }
      HapticFeedback.mediumImpact();
      _limit = Timer(const Duration(seconds: 60), _stop);
      if (!mounted) return;
      setState(() {
        _recording = true;
        _tapMode = !_pressed;
      });
    } finally {
      _starting = false;
    }
  }

  Future<void> _stop() async {
    if (!_recording) return;
    _limit?.cancel();
    HapticFeedback.lightImpact();
    setState(() {
      _recording = false;
      _tapMode = false;
    });
    if (_deviceStt) {
      await _stt.stop();
      await Future.delayed(const Duration(milliseconds: 400));
      if (_sttText.trim().isNotEmpty) await _send(text: _sttText.trim());
      return;
    }
    final path = await _recorder.stop();
    if (path == null) return;
    final bytes = await XFile(path).readAsBytes();
    if (bytes.length < 16000) {
      if (mounted) kToast(context, 'Message trop court. Parlez après la vibration.');
      return;
    }
    await _send(audio: bytes);
  }

  Future<void> _send({Uint8List? audio, String? text}) async {
    final mine = audio != null ? _Msg(true, 'Message vocal envoyé', pending: true) : _Msg(true, text ?? '');
    setState(() {
      _thinking = true;
      _msgs.add(mine);
    });
    _toBottom();
    try {
      final r = await _server.voiceTurn(audio: audio, audioMime: 'audio/wav', text: text, history: _history, language: _lang);
      final heard = (r['transcript'] ?? '') as String;
      final reply = (r['reply'] ?? '') as String;
      final urgency = (r['urgency'] ?? 'none') as String;
      final lang = (r['language'] ?? _lang) as String;
      final arts = [for (final a in (r['articles'] as List? ?? [])) (a as Map)['title'] as String];
      if (!mounted) return;
      setState(() {
        if (mine.pending) {
          mine.pending = false;
          if (heard.isNotEmpty) mine.text = heard;
        }
        _msgs.add(_Msg(false, reply, urgency: urgency, articles: arts));
        if (urgency == 'urgent') _urgentSeen = true;
        _thinking = false;
      });
      _history
        ..add({'role': 'user', 'text': heard.isNotEmpty ? heard : (text ?? '')})
        ..add({'role': 'model', 'text': reply});
      _toBottom();
      unawaited(_say(reply, lang));
    } on ServerError catch (e) {
      if (!mounted) return;
      _failed(mine, audio != null);
      if (e.status == 503 && audio != null) {
        setState(() => _deviceStt = true);
        kToast(context, 'Mode sans IA : parlez, le téléphone écrit pour vous.');
      } else {
        kToast(context, 'Khatwa n’a pas pu répondre. Réessayez.', error: true);
      }
    } catch (_) {
      if (!mounted) return;
      _failed(mine, audio != null);
      kToast(context, 'Pas de connexion au serveur Khatwa.', error: true);
    }
  }

  void _failed(_Msg mine, bool voice) => setState(() {
        _thinking = false;
        mine.pending = false;
        if (voice) mine.text = 'Message vocal non envoyé';
      });

  Future<void> _say(String text, String lang) async {
    setState(() => _speaking = true);
    try {
      final audio = await _server.speak(text, lang);
      if (audio != null) {
        final source = kIsWeb
            ? UrlSource('data:${audio.mime};base64,${base64Encode(audio.bytes)}')
            : BytesSource(audio.bytes, mimeType: audio.mime);
        await _player.play(source);
        await _player.onPlayerComplete.first.timeout(const Duration(minutes: 2), onTimeout: () {});
        return;
      }
      await _tts.setLanguage(_ttsLang[lang] ?? 'ar');
      await _tts.setSpeechRate(0.45);
      await _tts.awaitSpeakCompletion(true);
      await _tts.speak(text);
    } catch (_) {
      // Speaking is a convenience: the text is already on screen.
    } finally {
      if (mounted) setState(() => _speaking = false);
    }
  }

  void _toBottom() => WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scroll.hasClients) {
          _scroll.animateTo(_scroll.position.maxScrollExtent + 200,
              duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
        }
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: K.ground,
      appBar: AppBar(title: const Text('Parler à Khatwa'), backgroundColor: K.ground, foregroundColor: K.ink),
      body: Column(children: [
        if (_urgentSeen) const UrgentBanner(),
        Expanded(
          child: _msgs.isEmpty
              ? const _Welcome()
              : ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  itemCount: _msgs.length + (_thinking ? 1 : 0),
                  itemBuilder: (_, i) => i == _msgs.length ? const _Typing() : _Bubble(_msgs[i]),
                ),
        ),
        _Controls(
          recording: _recording,
          tapMode: _tapMode,
          busy: _thinking,
          speaking: _speaking,
          deviceStt: _deviceStt,
          onDown: _down,
          onUp: _up,
          onStopVoice: () async {
            await _player.stop();
            await _tts.stop();
            setState(() => _speaking = false);
          },
          text: _text,
          onSendText: () {
            final t = _text.text.trim();
            if (t.isEmpty || _thinking) return;
            _text.clear();
            _send(text: t);
          },
        ),
      ]),
    );
  }
}

class _Welcome extends StatelessWidget {
  const _Welcome();
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.record_voice_over_rounded, size: 64, color: K.primary),
          const SizedBox(height: 16),
          Text('اضغط على الزر و احكي', textDirection: TextDirection.rtl, style: K.h2),
          const SizedBox(height: 8),
          Text('Maintenez le bouton et parlez, relâchez pour envoyer.\nOu touchez une fois pour commencer, une fois pour envoyer.',
              textAlign: TextAlign.center, style: K.body.copyWith(color: K.muted)),
        ]),
      );
}

class _Bubble extends StatelessWidget {
  final _Msg m;
  const _Bubble(this.m);
  @override
  Widget build(BuildContext context) {
    final bg = m.mine ? K.primarySoft : (m.urgency == 'urgent' ? K.dangerSoft : (m.urgency == 'soon' ? K.warnSoft : K.surface));
    return Align(
      alignment: m.mine ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(14),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.82),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          if (!m.mine && m.urgency != 'none') ...[_UrgencyTag(m.urgency), const SizedBox(height: 8)],
          if (m.mine && m.pending)
            Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.mic_rounded, size: 18, color: K.primary),
              const SizedBox(width: 6),
              Flexible(child: Text('Message vocal envoyé', style: K.body.copyWith(color: K.inkSoft))),
              const SizedBox(width: 10),
              const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
            ])
          else
            Text(m.text, textDirection: dirOf(m.text), style: K.body.copyWith(fontSize: 17, height: 1.5)),
          if (m.articles.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(spacing: 6, runSpacing: 6, children: [
              for (final a in m.articles)
                Chip(
                  label: Text(a, textDirection: dirOf(a), style: const TextStyle(fontSize: 13)),
                  avatar: Icon(Icons.menu_book_rounded, size: 16, color: K.primary),
                  visualDensity: VisualDensity.compact,
                ),
            ]),
          ],
        ]),
      ),
    );
  }
}

class _UrgencyTag extends StatelessWidget {
  final String urgency;
  const _UrgencyTag(this.urgency);
  @override
  Widget build(BuildContext context) {
    final urgent = urgency == 'urgent';
    final colour = urgent ? K.danger : K.warn;
    return Row(children: [
      Icon(urgent ? Icons.emergency_rounded : Icons.schedule_rounded, size: 20, color: colour),
      const SizedBox(width: 6),
      Flexible(
        child: Text(urgent ? 'Urgent : 190 / عاجل' : 'À voir dans les 24 h / في ظرف 24 ساعة',
            style: TextStyle(color: colour, fontWeight: FontWeight.w700, fontSize: 14)),
      ),
    ]);
  }
}

class _Typing extends StatelessWidget {
  const _Typing();
  @override
  Widget build(BuildContext context) => Align(
        alignment: AlignmentDirectional.centerStart,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
            const SizedBox(width: 10),
            Text('Khatwa écoute et réfléchit…', style: K.body.copyWith(color: K.muted)),
          ]),
        ),
      );
}

class _Controls extends StatelessWidget {
  final bool recording, tapMode, busy, speaking, deviceStt;
  final VoidCallback onDown, onUp, onStopVoice, onSendText;
  final TextEditingController text;
  const _Controls({
    required this.recording,
    required this.tapMode,
    required this.busy,
    required this.speaking,
    required this.deviceStt,
    required this.onDown,
    required this.onUp,
    required this.onStopVoice,
    required this.text,
    required this.onSendText,
  });

  @override
  Widget build(BuildContext context) {
    final hint = recording
        ? (tapMode ? 'J’écoute… touchez pour envoyer' : 'J’écoute… relâchez pour envoyer')
        : busy
            ? 'Khatwa prépare la réponse…'
            : (deviceStt ? 'Maintenez et parlez (sans IA)' : 'Maintenez pour parler, ou touchez une fois');
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        color: K.surface,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          if (speaking)
            TextButton.icon(onPressed: onStopVoice, icon: const Icon(Icons.volume_off_rounded), label: const Text('Arrêter la voix')),
          Semantics(
            button: true,
            label: 'Parler à Khatwa',
            child: Listener(
              onPointerDown: (_) => onDown(),
              onPointerUp: (_) => onUp(),
              onPointerCancel: (_) => onUp(),
              child: SizedBox(
                width: 116,
                height: 116,
                child: Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    width: recording ? 112 : 96,
                    height: recording ? 112 : 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: busy ? K.control : (recording ? K.danger : K.primary),
                      boxShadow: [
                        BoxShadow(
                            color: (recording ? K.danger : K.primary).withValues(alpha: 0.45),
                            blurRadius: recording ? 36 : 22,
                            spreadRadius: recording ? 4 : 0),
                      ],
                    ),
                    child: Icon(recording ? Icons.graphic_eq_rounded : Icons.mic_rounded, color: Colors.white, size: 44),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(hint, style: K.small.copyWith(color: K.muted)),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(
              child: TextField(
                controller: text,
                minLines: 1,
                maxLines: 3,
                maxLength: 2000,
                decoration: const InputDecoration(hintText: 'Ou écrivez ici', isDense: true, counterText: ''),
                onSubmitted: (_) => onSendText(),
              ),
            ),
            IconButton(onPressed: onSendText, tooltip: 'Envoyer', icon: Icon(Icons.send_rounded, color: K.primary)),
          ]),
        ]),
      ),
    );
  }
}
