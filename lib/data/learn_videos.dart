/// Short, trustworthy YouTube videos for the Learn articles.
///
/// A video is shown only once `verified` is true: its oEmbed address
/// (https://www.youtube.com/oembed?url=https://www.youtube.com/watch?v=ID&format=json)
/// answered 200, so it exists and can be embedded. `dart run tool/verify_videos.dart`
/// checks every id, writes the real title and channel here and sets the flag.
///
/// The candidates below were found by web search on 27 September 2026 from a
/// session that could not reach YouTube, so none is verified yet and the
/// Learn pages keep the "video in preparation" slot until the script runs.
/// Order of preference: Arabic or Tunisian speakers, then French (Fédération
/// Française des Diabétiques, Assurance Maladie, HAS, hospitals), then English
/// (NHS, Diabetes UK, IWGDF, ADA, Mayo Clinic). No advertising, no miracle cures.
library;

class LearnVideo {
  final String id;

  /// Language spoken in the video: 'ar', 'fr' or 'en'.
  final String lang;
  final String title;
  final String channel;
  final bool verified;

  const LearnVideo(this.id, this.lang, {required this.title, required this.channel, this.verified = false});

  String get thumbnail => 'https://img.youtube.com/vi/$id/hqdefault.jpg';
  String get watchUrl => 'https://www.youtube.com/watch?v=$id';
}

// Candidates, by the article they fit. Titles and channels as the search
// showed them; "?" means the channel is still to be confirmed.
const _dailyCheckEn = LearnVideo('jC9hXPURsQA', 'en',
    title: 'How to perform a daily diabetes foot check | #PuttingFeetFirst | Diabetes UK', channel: 'Diabetes UK');
const _dailyCheckAr = LearnVideo('GwFs0Oyv1hc', 'ar', title: 'فحص القدم يومياً ضروري لمرضى السكري', channel: '?');
const _careAr = LearnVideo('f5r7vIUnA2E', 'ar', title: 'العناية بالقدم السكرية', channel: '?');
const _careFr = LearnVideo('tnnDL7njfjg', 'fr', title: 'Le soin des pieds', channel: '?');
const _preventionFr =
    LearnVideo('Emf3JnugSjw', 'fr', title: 'Le pied du diabétique, prévention et soins', channel: '?');
const _fiveStepsEn = LearnVideo('SulNOSMMNLY', 'en',
    title: 'Mayo Clinic Minute: 5 steps to diabetic foot care', channel: 'Mayo Clinic');
const _woundFr = LearnVideo('av5kVBQ2WdE', 'fr',
    title: 'Petite plaie, grand danger : Ensemble pour soigner le pied diabétique', channel: '?');
const _nailsEn = LearnVideo('MBM_mjUHQL0', 'en', title: 'Guide to Cutting Your Toenails - Foot Care', channel: '?');

/// Videos of each article, best language first.
const learnVideos = <String, List<LearnVideo>>{
  'healthy': [_careAr, _preventionFr, _fiveStepsEn],
  'howto-check': [_dailyCheckAr, _preventionFr, _dailyCheckEn],
  'dry-skin': [_careAr, _careFr, _fiveStepsEn],
  'heel-cracks': [_careAr, _careFr, _fiveStepsEn],
  'callus': [_careFr, _fiveStepsEn],
  'corn': [_careFr, _fiveStepsEn],
  'blister': [_woundFr, _fiveStepsEn],
  'fungus': [_careFr, _fiveStepsEn],
  'nails': [_careFr, _nailsEn],
  'redness': [_woundFr, _dailyCheckEn],
  'swelling': [_woundFr, _dailyCheckEn],
  'colour': [_woundFr, _dailyCheckEn],
  'wound': [_woundFr, _fiveStepsEn],
  'numbness': [_preventionFr, _fiveStepsEn],
  'when-doctor': [_woundFr, _dailyCheckEn],
  'wash': [_careAr, _careFr, _fiveStepsEn],
  'dry': [_careAr, _careFr, _fiveStepsEn],
  'moisturise': [_careAr, _careFr, _fiveStepsEn],
  'nail-care': [_careFr, _nailsEn],
  'socks-shoes': [_careFr, _fiveStepsEn],
  'move': [_preventionFr, _fiveStepsEn],
};

/// The video to show for an article in the app's language code ('aeb', 'ar',
/// 'fr', 'en'): the same language when there is one, else the closest one
/// (French before English for a Latin-script page, before Arabic). Null while
/// none is verified.
LearnVideo? videoFor(String articleId, String appLang) {
  final list = [for (final v in learnVideos[articleId] ?? const <LearnVideo>[]) if (v.verified) v];
  if (list.isEmpty) return null;
  final want = appLang == 'aeb' ? 'ar' : appLang;
  final order = want == 'ar' ? const ['ar', 'fr', 'en'] : (want == 'fr' ? const ['fr', 'en', 'ar'] : const ['en', 'fr', 'ar']);
  for (final l in order) {
    for (final v in list) {
      if (v.lang == l) return v;
    }
  }
  return list.first;
}
