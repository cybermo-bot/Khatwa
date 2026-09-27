import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../data/learn_videos.dart';
import '../features/common.dart';
import '../ui/app_theme.dart';

/// The article's video: a thumbnail with a play button, then the video plays
/// inline (Android and web). Where it cannot play inline, YouTube opens.
/// Until a video is verified, the [placeholder] stays.
class ArticleVideo extends StatefulWidget {
  final String articleId;
  final Widget placeholder;

  /// For tests: a video list other than [learnVideos].
  final LearnVideo? video;

  const ArticleVideo({super.key, required this.articleId, required this.placeholder, this.video});

  @override
  State<ArticleVideo> createState() => _ArticleVideoState();
}

class _ArticleVideoState extends State<ArticleVideo> {
  YoutubePlayerController? _player;

  static bool get _inline {
    final binding = WidgetsBinding.instance.runtimeType.toString();
    if (binding.contains('Test')) return false;
    return kIsWeb || defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS;
  }

  @override
  void dispose() {
    _player?.close();
    super.dispose();
  }

  Future<void> _openYouTube(LearnVideo v) => launchUrl(Uri.parse(v.watchUrl), mode: LaunchMode.externalApplication);

  void _play(LearnVideo v) {
    if (!_inline) {
      _openYouTube(v);
      return;
    }
    setState(() {
      _player = YoutubePlayerController.fromVideoId(
        videoId: v.id,
        autoPlay: true,
        params: const YoutubePlayerParams(showFullscreenButton: true, strictRelatedVideos: true),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final v = widget.video ?? videoFor(widget.articleId, langCode());
    if (v == null) return widget.placeholder;
    final other = v.lang != (langCode() == 'aeb' ? 'ar' : langCode());
    final langNote = switch (v.lang) {
      'fr' => tr('vidéo en français', aeb: 'فيديو بالفرنسية', ar: 'فيديو بالفرنسية', en: 'video in French'),
      'en' => tr('vidéo en anglais', aeb: 'فيديو بالإنقليزية', ar: 'فيديو بالإنجليزية', en: 'video in English'),
      _ => tr('vidéo en arabe', aeb: 'فيديو بالعربية', ar: 'فيديو بالعربية', en: 'video in Arabic'),
    };
    final player = _player;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(K.r20),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: player != null
                ? YoutubePlayer(controller: player, aspectRatio: 16 / 9)
                : Semantics(
                    button: true,
                    label: '${tr('Lire la vidéo', aeb: 'شغّل الفيديو', ar: 'تشغيل الفيديو', en: 'Play the video')}: ${v.title}',
                    child: InkWell(
                      onTap: () => _play(v),
                      child: Stack(fit: StackFit.expand, children: [
                        Image.network(
                          v.thumbnail,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => ColoredBox(color: K.surfaceMuted),
                        ),
                        Center(
                          child: Container(
                            width: 68,
                            height: 68,
                            decoration: BoxDecoration(
                              color: K.primary,
                              shape: BoxShape.circle,
                              boxShadow: [BoxShadow(color: Colors.black.withAlpha(60), blurRadius: 18)],
                            ),
                            child: Icon(Icons.play_arrow_rounded, size: 42, color: K.onPrimary),
                          ),
                        ),
                      ]),
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Text(v.title, textDirection: dirOf(v.title), style: K.bodyStrong, maxLines: 2, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 2),
        Text(
          [
            tr('Vidéo externe, choisie par l’équipe Khatwa',
                aeb: 'فيديو من برّا، اختارو فريق خطوة', ar: 'فيديو خارجي اختاره فريق خطوة', en: 'External video, chosen by the Khatwa team'),
            if (other) langNote,
          ].join(' · '),
          style: K.small,
        ),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton.icon(
            onPressed: () => _openYouTube(v),
            icon: const Icon(Icons.open_in_new_rounded, size: 18),
            label: Text(tr('Ouvrir sur YouTube', aeb: 'حلّ في يوتيوب', ar: 'افتح في يوتيوب', en: 'Open on YouTube')),
          ),
        ),
      ],
    );
  }
}
