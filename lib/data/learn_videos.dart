/// Short, trustworthy YouTube videos for the Learn articles.
///
/// A video is shown only once `verified` is true: its oEmbed address
/// (https://www.youtube.com/oembed?url=https://www.youtube.com/watch?v=ID&format=json)
/// answered 200, so it exists and can be embedded. `dart run tool/verify_videos.dart`
/// checks every id, writes the real title and channel here and sets the flag.
///
/// Each article has its own videos (27 September 2026), checked one by one.
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

// By the article they fit, one video per language where a specific one exists.
// Found with YouTube searches on 27/09/2026, preferring health bodies,
// hospitals and clinicians. Titles and channels come from the oEmbed answer
// (tool/verify_videos.dart).
const _vOeq0GRu4diw = LearnVideo('Oeq0GRu4diw', 'ar', title: 'العناية بالقدمين لمريض السكري', channel: 'MOHAP UAE وزارة الصحة ووقاية المجتمع الإماراتية', verified: true);
const _vd21R8G2M4nI = LearnVideo('d21R8G2M4nI', 'fr', title: 'Le pied diabétique : physiopathologie et prévention - Dr Taieb Ach', channel: 'Taïeb Ach', verified: true);
const _vSulNOSMMNLY = LearnVideo('SulNOSMMNLY', 'en', title: 'Mayo Clinic Minute: 5 steps to diabetic foot care', channel: 'Mayo Clinic', verified: true);
const _vVuYFQzIyiIE = LearnVideo('VuYFQzIyiIE', 'ar', title: 'الفحص اليومي لقدم مريض السكر', channel: 'د. محمد على مطر أستشاري علاج القدم السكرى', verified: true);
const _vNgiKk7Sx8I = LearnVideo('NgiK_k7Sx8I', 'fr', title: 'Diabète : le pied diabétique expliqué en 2 minutes', channel: 'AP-HM - Hôpitaux Universitaires de Marseille', verified: true);
const _vjC9hXPURsQA = LearnVideo('jC9hXPURsQA', 'en', title: 'How to perform a daily diabetes foot check | #PuttingFeetFirst​ | Diabetes UK', channel: 'Diabetes UK', verified: true);
const _vTD0m6ewNJgA = LearnVideo('TD0m6ewNJgA', 'ar', title: 'علاج جفاف البشره لمريض السكري', channel: 'Diabetes Association رابطة مرضي السكري', verified: true);
const _vMOKS1D0giM = LearnVideo('MOK_S1D0giM', 'fr', title: 'Santé : prendre soins de ses pieds lorsque l\'on est diabétique', channel: 'France 3 Hauts-de-France', verified: true);
const _vhkS854eeos4 = LearnVideo('hkS854eeos4', 'en', title: 'Thick Dead Skin on Feet & Dry Skin on Feet [Diabetes Skin Conditions]', channel: 'Michigan Foot Doctors', verified: true);
const _vlGaWTnU2hsE = LearnVideo('lGaWTnU2hsE', 'ar', title: 'تشققات الكعبين فى قدم مريض السكر', channel: 'د. محمد على مطر أستشاري علاج القدم السكرى', verified: true);
const _vLVfghY1f7O0 = LearnVideo('LVfghY1f7O0', 'en', title: 'Dry, Cracked Heels: Foot-Care Tips', channel: 'Bayshore Podiatry Center', verified: true);
const _vqLsh4GuB7dk = LearnVideo('qLsh4GuB7dk', 'fr', title: 'Cor VS Durillon VS Verrue au pied : Comment les reconnaitre ?', channel: 'Dr. Walid MEKEDDEM', verified: true);
const _vrf2t3NVraA = LearnVideo('rf2t3NVr-aA', 'en', title: 'How are foot calluses and foot ulcers treated in people with diabetes? - Reston Hospital Center', channel: 'Reston Hospital Center', verified: true);
const _vWDwxkESMjY8 = LearnVideo('WDwxkESMjY8', 'ar', title: 'هل مسمار القدم خطير لمرضى السكري؟ وكيف نعالجه؟', channel: 'OTV Lebanon', verified: true);
const _vop7giew3YE0 = LearnVideo('op7giew3YE0', 'en', title: 'Diabetic Corns and Calluses - Senior Podiatrist Elliott Yeldham, East Coast Podiatry', channel: 'East Coast Podiatry', verified: true);
const _vav5kVBQ2WdE = LearnVideo('av5kVBQ2WdE', 'fr', title: 'Petite plaie, grand danger : Ensemble pour soigner le pied diabétique', channel: 'Spitalzentrum Biel (SZB) / Centre hospitalier Bienne (CHB)', verified: true);
const _v6ayB7MjgMQ = LearnVideo('6ayB_7MjgMQ', 'en', title: 'Blister on your foot? Don’t pop it! As a podiatrist I’ll explain why it risks infection #podiatrist', channel: 'Modern Podiatry Care', verified: true);
const _vNT6Bj3KgrOs = LearnVideo('NT6Bj3KgrOs', 'ar', title: 'مصر احلى | نصائح علاج " التهابات بين اصابع الاقدام " مع " د/ هاني الناظر "', channel: 'Mehwar TV', verified: true);
const _vQT5rYfPJSww = LearnVideo('QT5rYfPJSww', 'fr', title: 'Pied d\'athlète : toutes les précautions à prendre pour ne pas attraper cette mycose', channel: 'Allo Docteurs', verified: true);
const _vwPzJvDKUm0 = LearnVideo('-wPzJvDKUm0', 'en', title: 'Athlete\'s Foot: Symptoms, Causes & Treatments - Ask A Nurse | @LevelUpRN', channel: 'Level Up RN', verified: true);
const _vWtJ5vveGQ = LearnVideo('-WtJ5v_veGQ', 'ar', title: 'فطريات الأظافر .. الأسباب والمضاعفات وطرق العلاج', channel: 'العربي 2', verified: true);
const _vbAfuE7gtIMk = LearnVideo('bAfuE7gtIMk', 'fr', title: 'Conseils pour le traitement de l\'ongle incarné et le guérir - Expliqué par un podiatre', channel: 'Podformance - Clinique Podiatrique', verified: true);
const _vT4DzMZ2aFGg = LearnVideo('T4DzMZ2aFGg', 'en', title: 'Ingrown Toenails Explained - Senior Podiatrist Elliott Yeldham, East Coast Podiatry', channel: 'East Coast Podiatry', verified: true);
const _vdWAuSjIhsU = LearnVideo('dW_AuSjIhsU', 'ar', title: 'القدم السكري أحد مضاعفات مرض السكر تعرف على أعراضه الأولية واستشر طبيبك فورًا عند الشعور بها', channel: 'وزارة الصحة والسكان المصرية', verified: true);
const _vhGP3uNx8s3s = LearnVideo('hGP3uNx8s3s', 'en', title: 'Medical Index - Diabetic Foot Infections', channel: 'Dr. Robert Gullberg', verified: true);
const _vJH5ey0CNuk = LearnVideo('JH5_ey0CNuk', 'ar', title: 'معلومات هامة عن مفصل شاركوت معدكتور محمد على مطر أستشارى علاج القدم السكرى', channel: 'د. محمد على مطر أستشاري علاج القدم السكرى', verified: true);
const _vToEpIh187as = LearnVideo('ToEpIh187as', 'en', title: 'Diabetic Foot Complications and Charcot Foot - Podiatrist Georgina Tay, East Coast Podiatry', channel: 'East Coast Podiatry', verified: true);
const _v1jvNQT0PK4 = LearnVideo('_1jvNQT0PK4', 'ar', title: 'اعراض انسداد الشرايين عند مرضي القدم السكري ونتائج اهمالها | دكتور حسام المهدي', channel: 'Dr. Hossam ElMahdy - دكتور حسام المهدي', verified: true);
const _vUChySmARD1g = LearnVideo('UChySmARD1g', 'en', title: 'Peripheral Artery Disease - Signs & Symptoms', channel: 'UNC Health Rex', verified: true);
const _vbfup9sRCdI4 = LearnVideo('bfup9sRCdI4', 'ar', title: '" القدم السكرية "', channel: 'Hamad Medical Corporation - Media', verified: true);
const _vjkak6OD4o2U = LearnVideo('jkak6OD4o2U', 'en', title: 'Diabetic Foot Wounds Treatment | FAQ', channel: 'Johns Hopkins Medicine', verified: true);
const _vdojelcZja0E = LearnVideo('dojelcZja0E', 'ar', title: 'أسباب وطرق تشخيص مرض اعتلال الأعصاب الطرفية', channel: 'Taiba Hospital | مستشفى طيبة', verified: true);
const _volljM03R8o = LearnVideo('olljM03R8-o', 'fr', title: 'Vlogue #13 - La Neuropathie Diabétique Expliquée Par Une Podiatre', channel: 'Clinique Podiatrique de Trois-Rivières', verified: true);
const _vzuST4gNwFwk = LearnVideo('zuST4gNwFwk', 'en', title: 'Your Diabetes Health Checks: Feet and nerves | Learning Zone | Diabetes UK', channel: 'Diabetes UK', verified: true);
const _vO3YE2F4FSg = LearnVideo('O3Y-E2F4FSg', 'ar', title: 'متى يجب عليك زيارة الطبيب لعلاج القدم السكري؟', channel: 'وزارة الصحة والسكان المصرية', verified: true);
const _vknklUbsRE5I = LearnVideo('knklUbsRE5I', 'fr', title: 'Diabète : attention aux complications au niveau du pied ! - Le Magazine de la Santé', channel: 'Allo Docteurs', verified: true);
const _vnGBqKSEsWKE = LearnVideo('nGBqKSEsWKE', 'en', title: 'What to expect at the foot clinic | Diabetes foot problems | Diabetes UK', channel: 'Diabetes UK', verified: true);
const _v0d1UrOgmrik = LearnVideo('0d1UrOgmrik', 'ar', title: 'الطريقة الصحيحة لغسل قدم مريض السكر | أزاى مريض السكر يغسل قدمه بطريقه صحيحه', channel: 'قناه دكتور طارق تركى - Dr Tarik Torki Channel', verified: true);
const _vIZI2oyRXUo = LearnVideo('IZI2oyRXU_o', 'fr', title: 'Hygiene des pieds chez le diabétique', channel: 'PIED OUTAOUAIS', verified: true);
const _vRTA3ukb5W6A = LearnVideo('RTA3ukb5W6A', 'en', title: 'Diabetes and your feet', channel: 'Lewisham and Greenwich NHS Trust', verified: true);
const _vz5ao973Tvg = LearnVideo('z5ao9_73Tvg', 'ar', title: 'Alyaa Gad - Diabetic Foot Care | العناية بقدم مريض السكر', channel: 'Alyaa Gad علياء جاد', verified: true);
const _vtnnDL7njfjg = LearnVideo('tnnDL7njfjg', 'fr', title: 'Le soin des pieds', channel: 'Diabète Québec', verified: true);
const _v07utx3CzLUg = LearnVideo('07utx3CzLUg', 'en', title: 'Diabetes Series: Daily Foot Care', channel: 'Riverside Health Care', verified: true);
const _vF7YD44AhQbQ = LearnVideo('F7YD44AhQbQ', 'ar', title: 'جفاف كعب القدم عن مريض السكر', channel: 'Dr. Osama Migahid | د. أسامة مجاهد', verified: true);
const _vvJiqlyeZwFc = LearnVideo('vJiqlyeZwFc', 'fr', title: 'Des crèmes pour les pieds (cors, durillons, callosités..)', channel: 'Dr. Walid MEKEDDEM', verified: true);
const _vijt59s97IKA = LearnVideo('ijt59s97IKA', 'ar', title: 'كيفية قص الأظافر بطريقة صحيحة لمرضي السكر و القزم السكري', channel: 'أ.د أحمد المحروقي', verified: true);
const _vsGU4ZhKp9hY = LearnVideo('sGU4ZhKp9hY', 'fr', title: 'Comment couper les ongles d’un pied 🦶 diabétique ?', channel: 'Clinique Carthagène', verified: true);
const _vya4BRGx26H4 = LearnVideo('ya4BRGx26H4', 'en', title: 'How To Cut Your Diabetic Toenails Correctly. 4 Easy Tips', channel: 'FootWellnessDiabetes', verified: true);
const _vBuxtpQ9Bpto = LearnVideo('BuxtpQ9Bpto', 'ar', title: '١٠ احذيه ممنوعه لمرضى السكر |  أخطر ١٠ احذيه لمريض السكر', channel: 'قناه دكتور طارق تركى - Dr Tarik Torki Channel', verified: true);
const _vl0EPW7emqg = LearnVideo('l0EPW7emq_g', 'en', title: 'Choosing the right footwear if you have diabetes or a high-risk foot condition', channel: 'Northamptonshire Healthcare NHS Foundation Trust (NHFT)', verified: true);
const _v59rUiONxGcw = LearnVideo('59rUiONxGcw', 'ar', title: 'تمارين القدم الاساسيه لمرضي السكر', channel: 'Diabetic Corner ', verified: true);
const _vdCP0jAlzF0 = LearnVideo('dCP0-jAlzF0', 'fr', title: '5 exercices pour les douleurs au pied-Diabète Drummond', channel: 'Diabète Drummond', verified: true);

/// Videos of each article.
const learnVideos = <String, List<LearnVideo>>{
  'healthy': [_vOeq0GRu4diw, _vd21R8G2M4nI, _vSulNOSMMNLY],
  'howto-check': [_vVuYFQzIyiIE, _vNgiKk7Sx8I, _vjC9hXPURsQA],
  'dry-skin': [_vTD0m6ewNJgA, _vMOKS1D0giM, _vhkS854eeos4],
  'heel-cracks': [_vlGaWTnU2hsE, _vLVfghY1f7O0],
  'callus': [_vqLsh4GuB7dk, _vrf2t3NVraA],
  'corn': [_vWDwxkESMjY8, _vqLsh4GuB7dk, _vop7giew3YE0],
  'blister': [_vav5kVBQ2WdE, _v6ayB7MjgMQ],
  'fungus': [_vNT6Bj3KgrOs, _vQT5rYfPJSww, _vwPzJvDKUm0],
  'nails': [_vWtJ5vveGQ, _vbAfuE7gtIMk, _vT4DzMZ2aFGg],
  'redness': [_vdWAuSjIhsU, _vhGP3uNx8s3s],
  'swelling': [_vJH5ey0CNuk, _vToEpIh187as],
  'colour': [_v1jvNQT0PK4, _vUChySmARD1g],
  'wound': [_vbfup9sRCdI4, _vav5kVBQ2WdE, _vjkak6OD4o2U],
  'numbness': [_vdojelcZja0E, _volljM03R8o, _vzuST4gNwFwk],
  'when-doctor': [_vO3YE2F4FSg, _vknklUbsRE5I, _vnGBqKSEsWKE],
  'wash': [_v0d1UrOgmrik, _vIZI2oyRXUo, _vRTA3ukb5W6A],
  'dry': [_vz5ao973Tvg, _vtnnDL7njfjg, _v07utx3CzLUg],
  'moisturise': [_vF7YD44AhQbQ, _vvJiqlyeZwFc, _vSulNOSMMNLY],
  'nail-care': [_vijt59s97IKA, _vsGU4ZhKp9hY, _vya4BRGx26H4],
  'socks-shoes': [_vBuxtpQ9Bpto, _vl0EPW7emqg],
  'move': [_v59rUiONxGcw, _vdCP0jAlzF0],
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
