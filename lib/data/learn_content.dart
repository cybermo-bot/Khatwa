import 'package:flutter/material.dart';

import '../ui/foot_art.dart';
import '../ui/foot_shapes.dart';

/// Patient education content.
///
/// Source: IWGDF 2023 guidelines on the prevention of foot ulcers in persons
/// with diabetes, written in plain language. Every item must be reviewed by
/// the team's clinical validator before release; [LearnArticle.reviewed]
/// stays false until then and the app says so on the page.
///
/// Derja text is left empty where a native speaker has not written it yet;
/// the app then shows the Arabic text.
class T {
  final String ar;
  final String dz;
  final String fr;
  final String en;

  const T(this.ar, this.fr, this.en, {this.dz = ''});

  String of(String lang) {
    switch (lang) {
      case 'Français':
        return fr;
      case 'English':
        return en;
      case 'تونسي':
        return dz.isNotEmpty ? dz : ar;
      default:
        return ar;
    }
  }
}

enum LearnSection { know, signs, care, urgent, life, food }

class LearnArticle {
  final String id;
  final LearnSection section;
  final IconData icon;
  final T title;
  final T summary;
  final List<FootZone> zones;
  final FootView view;
  final List<T> lookFor;
  final List<T> atHome;
  final List<T> seeDoctor;
  final List<T> urgentNow;
  final bool hasVideo;
  final bool reviewed;

  const LearnArticle({
    required this.id,
    required this.section,
    required this.icon,
    required this.title,
    required this.summary,
    this.zones = const [],
    this.view = FootView.top,
    this.lookFor = const [],
    this.atHome = const [],
    this.seeDoctor = const [],
    this.urgentNow = const [],
    this.hasVideo = false,
    this.reviewed = false,
  });
}

class LearnSectionInfo {
  final LearnSection section;
  final T title;
  final T subtitle;
  final IconData icon;

  const LearnSectionInfo(this.section, this.title, this.subtitle, this.icon);
}

class LearnLabels {
  static const lookFor = T('كيف تبدو', 'À quoi ça ressemble', 'What it looks like', dz: 'كيفاش تبان');
  static const steps = T('الخطوات', 'Les étapes', 'Step by step', dz: 'الخطوات');
  static const atHome = T('ماذا تفعل في البيت', 'Ce que vous pouvez faire', 'What you can do at home', dz: 'شنوّة تعمل في الدار');
  static const seeDoctor = T('راجع الطبيب إذا', 'Consultez un professionnel si', 'See a professional if', dz: 'أمشي للطبيب كان');
  static const urgentNow = T('اذهب إلى الطوارئ فورا إذا', 'Allez aux urgences tout de suite si', 'Go to emergency now if', dz: 'أمشي للاستعجالي توّا كان');
  static const pending = T(
    'هذا المحتوى مبني على توصيات IWGDF 2023 وينتظر مراجعة طبيب الفريق.',
    'Contenu fondé sur les recommandations IWGDF 2023, en attente de relecture par le clinicien de l’équipe.',
    'Based on the IWGDF 2023 guidelines, awaiting review by the team clinician.',
  );
  static const video = T(
    'الفيديو مع الفريق الطبي قيد التحضير.',
    'La vidéo avec l’équipe soignante est en préparation.',
    'The video with the care team is being prepared.',
  );
  static const callEmergency = T('اتصل بالإسعاف 190', 'Appeler le SAMU 190', 'Call the ambulance, 190', dz: 'كلّم الإسعاف 190');
  static const readMore = T('اقرأ', 'Lire', 'Read', dz: 'أقرا');
  static const tipOfDay = T('نصيحة اليوم', 'Conseil du jour', "Today's tip", dz: 'نصيحة اليوم');
}

const learnSections = <LearnSectionInfo>[
  LearnSectionInfo(
    LearnSection.know,
    T('اعرف قدميك', 'Connaître vos pieds', 'Know your feet', dz: 'أعرف ساقيك'),
    T('القدم السليمة وكيف تفحصها', 'Le pied sain et comment l’examiner', 'A healthy foot, and how to check it'),
    Icons.visibility_outlined,
  ),
  LearnSectionInfo(
    LearnSection.signs,
    T('علامات الإنذار المبكرة', 'Signes d’alerte précoces', 'Early warning signs', dz: 'علامات الخطر'),
    T('تعرّف عليها واعرف ماذا تفعل', 'Les reconnaître et savoir quoi faire', 'Recognise them and know what to do'),
    Icons.report_gmailerrorred_outlined,
  ),
  LearnSectionInfo(
    LearnSection.urgent,
    T('متى تذهب إلى الطبيب', 'Quand consulter', 'When to see a doctor', dz: 'وقتاش تمشي للطبيب'),
    T('العلامات التي لا تنتظر', 'Les signes qui n’attendent pas', 'The signs that cannot wait'),
    Icons.local_hospital_outlined,
  ),
  LearnSectionInfo(
    LearnSection.care,
    T('العناية اليومية', 'Soins de chaque jour', 'Daily care', dz: 'العناية كل يوم'),
    T('الغسل، التجفيف، الترطيب، الأظافر، الأحذية', 'Laver, sécher, hydrater, ongles, chaussures', 'Wash, dry, moisturise, nails, shoes'),
    Icons.spa_outlined,
  ),
  LearnSectionInfo(
    LearnSection.life,
    T('في حياتك اليومية', 'Dans votre vie de tous les jours', 'In everyday life', dz: 'في حياتك'),
    T('الحمّام، البحر، رمضان، الصيف', 'Hammam, plage, Ramadan, été', 'Hammam, beach, Ramadan, summer'),
    Icons.wb_sunny_outlined,
  ),
  LearnSectionInfo(
    LearnSection.food,
    T('الأكل والسكر', 'Alimentation et glycémie', 'Food and blood sugar', dz: 'الماكلة والسكر'),
    T('لماذا يحمي توازن السكر قدميك', 'Pourquoi une glycémie équilibrée protège vos pieds', 'Why balanced blood sugar protects your feet'),
    Icons.restaurant_outlined,
  ),
];

const learnArticles = <LearnArticle>[
  // ------------------------------------------------------------ know
  LearnArticle(
    id: 'healthy',
    section: LearnSection.know,
    icon: Icons.favorite_outline_rounded,
    title: T('القدم السليمة', 'Le pied sain', 'A healthy foot', dz: 'الساق السليمة'),
    summary: T(
      'اعرف كيف تبدو قدمك عادة، حتى تلاحظ أي تغيير بسرعة.',
      'Connaître l’aspect habituel de votre pied permet de voir vite ce qui change.',
      'Knowing how your foot normally looks helps you spot any change quickly.',
    ),
    lookFor: [
      T('جلد سليم بلا شقوق ولا جروح', 'Une peau entière, sans fissure ni plaie', 'Skin in one piece, no cracks or wounds'),
      T('لون متساو بين القدمين', 'La même couleur sur les deux pieds', 'The same colour on both feet'),
      T('لا احمرار ولا انتفاخ', 'Pas de rougeur, pas de gonflement', 'No redness, no swelling'),
      T('القدمان بنفس الحرارة عند اللمس', 'Les deux pieds à la même température au toucher', 'Both feet feel the same temperature'),
      T('أظافر قصيرة وردية', 'Des ongles courts et rosés', 'Short, pinkish nails'),
      T('تحسّ باللمس الخفيف', 'Vous sentez un toucher léger', 'You can feel a light touch'),
    ],
  ),
  LearnArticle(
    id: 'howto-check',
    section: LearnSection.know,
    icon: Icons.search_rounded,
    title: T('كيف تفحص قدميك كل يوم', 'Examiner vos pieds chaque jour', 'How to check your feet every day', dz: 'كيفاش تفحص ساقيك كل يوم'),
    summary: T(
      'دقيقتان كل يوم، في ضوء جيد، وأنت جالس.',
      'Deux minutes par jour, bien éclairé, assis.',
      'Two minutes a day, in good light, sitting down.',
    ),
    zones: [FootZone.toes, FootZone.betweenToes, FootZone.heel],
    view: FootView.sole,
    hasVideo: true,
    atHome: [
      T('اجلس في مكان مضاء جيدا', 'Asseyez-vous dans un endroit bien éclairé', 'Sit somewhere with good light'),
      T('انظر إلى أعلى القدم ثم إلى باطنها، استعمل مرآة أو اطلب المساعدة', 'Regardez le dessus puis la plante, avec un miroir ou une aide', 'Look at the top, then the sole, with a mirror or a helper'),
      T('افتح أصابع قدمك وانظر بين كل إصبعين', 'Écartez les orteils et regardez entre chacun', 'Spread your toes and look between each one'),
      T('انظر إلى الكعب من الخلف والجانبين', 'Regardez le talon, derrière et sur les côtés', 'Look at the heel, from behind and the sides'),
      T('تفقد الأظافر', 'Vérifiez les ongles', 'Check the nails'),
      T('المس القدمين: هل واحدة أسخن من الأخرى؟', 'Touchez vos pieds : l’un est-il plus chaud que l’autre ?', 'Touch both feet: is one warmer than the other?'),
      T('تفقد داخل الحذاء قبل لبسه', 'Vérifiez l’intérieur des chaussures avant de les mettre', 'Check inside your shoes before putting them on'),
    ],
  ),

  // ------------------------------------------------------------ signs
  LearnArticle(
    id: 'dry-skin',
    section: LearnSection.signs,
    icon: Icons.grain_rounded,
    title: T('الجلد الجاف', 'Peau sèche', 'Dry skin', dz: 'الجلد الناشف'),
    summary: T(
      'شائع مع السكري، ويمكن أن يتشقق ويفتح بابا للجراثيم.',
      'Fréquente avec le diabète, elle peut se fendre et laisser entrer les microbes.',
      'Common with diabetes; it can split and let germs in.',
    ),
    zones: [FootZone.heel, FootZone.ball],
    view: FootView.sole,
    lookFor: [
      T('جلد خشن يتقشر', 'Peau rugueuse qui pèle', 'Rough skin that flakes'),
      T('إحساس بشد الجلد وخطوط رفيعة', 'Sensation de tiraillement, fines lignes', 'A tight feeling, fine lines'),
    ],
    atHome: [
      T('ضع كريما مرطبا كل يوم على أعلى القدم وباطنها', 'Appliquez une crème hydratante chaque jour, dessus et plante', 'Apply moisturising cream every day, top and sole'),
      T('لا تضع الكريم بين الأصابع', 'Jamais de crème entre les orteils', 'Never put cream between the toes'),
      T('اغسل بماء فاتر لا ساخن', 'Lavez à l’eau tiède, pas chaude', 'Wash with lukewarm, not hot, water'),
    ],
    seeDoctor: [
      T('إذا انفتح الجلد أو نزف', 'Si la peau s’ouvre ou saigne', 'The skin opens or bleeds'),
      T('إذا ظهر احمرار حوله', 'Si une rougeur apparaît autour', 'Redness appears around it'),
    ],
  ),
  LearnArticle(
    id: 'heel-cracks',
    section: LearnSection.signs,
    icon: Icons.texture_rounded,
    title: T('تشققات الكعب', 'Crevasses du talon', 'Cracked heels', dz: 'تشقق الكعب'),
    summary: T(
      'شقوق في الجلد السميك للكعب. العميقة منها قد تصبح جرحا.',
      'Des fentes dans la peau épaisse du talon. Profondes, elles deviennent des plaies.',
      'Splits in the thick skin of the heel. Deep ones can become wounds.',
    ),
    zones: [FootZone.heel],
    view: FootView.sole,
    lookFor: [
      T('خطوط أو شقوق حول حافة الكعب', 'Des lignes ou fentes au bord du talon', 'Lines or splits around the rim of the heel'),
      T('جلد سميك مصفر حولها', 'Une peau épaisse et jaunâtre autour', 'Thick, yellowish skin around them'),
    ],
    atHome: [
      T('رطّب الكعب مرتين في اليوم', 'Hydratez le talon deux fois par jour', 'Moisturise the heel twice a day'),
      T('البس حذاء مغلقا من الخلف', 'Portez des chaussures fermées à l’arrière', 'Wear shoes closed at the back'),
      T('لا تقص الجلد ولا تحكه بقوة', 'Ne coupez pas et ne râpez pas fort la peau', 'Do not cut or rasp the skin hard'),
    ],
    seeDoctor: [
      T('إذا كان الشق عميقا أو ينزف', 'Si la fente est profonde ou saigne', 'The crack is deep or bleeds'),
      T('إذا كان حوله احمرار أو حرارة أو قيح', 'S’il y a rougeur, chaleur ou pus autour', 'There is redness, warmth or pus around it'),
    ],
  ),
  LearnArticle(
    id: 'callus',
    section: LearnSection.signs,
    icon: Icons.layers_outlined,
    title: T('الجلد القاسي (الكالو)', 'Callosité (corne)', 'Callus (hard skin)', dz: 'الجلدة القاسحة'),
    summary: T(
      'جلد سميك في أماكن الضغط. قد يخفي تحته جرحا.',
      'Une peau épaisse aux points d’appui. Elle peut cacher une plaie dessous.',
      'Thick skin where pressure is highest. It can hide a wound underneath.',
    ),
    zones: [FootZone.ball, FootZone.heel],
    view: FootView.sole,
    lookFor: [
      T('جلد سميك صلب مصفر', 'Peau épaisse, dure, jaunâtre', 'Thick, hard, yellowish skin'),
      T('في مقدمة القدم أو الكعب أو أطراف الأصابع', 'Sous l’avant-pied, le talon ou le bout des orteils', 'Under the ball, the heel or the toe tips'),
    ],
    atHome: [
      T('لا تقصه بنفسك', 'Ne la coupez pas vous-même', 'Do not cut it yourself'),
      T('لا تستعمل لصقات أو مواد كيميائية لإزالته', 'N’utilisez ni pansement coricide ni produit chimique', 'Do not use corn plasters or chemical removers'),
      T('تأكد أن حذاءك لا يضغط', 'Vérifiez que la chaussure ne serre pas', 'Make sure your shoes do not press'),
    ],
    seeDoctor: [
      T('لإزالته عند مختص', 'Pour le faire enlever par un professionnel', 'To have it removed by a professional'),
      T('إذا ظهرت بقعة داكنة أو دم تحته', 'Si une tache sombre ou du sang apparaît dessous', 'A dark spot or blood appears under it'),
    ],
  ),
  LearnArticle(
    id: 'corn',
    section: LearnSection.signs,
    icon: Icons.circle_outlined,
    title: T('مسمار القدم', 'Cor', 'Corn', dz: 'المسمار'),
    summary: T(
      'نقطة صلبة صغيرة ومؤلمة على الأصابع أو بينها بسبب الاحتكاك.',
      'Un petit point dur et douloureux sur ou entre les orteils, dû au frottement.',
      'A small, hard, painful spot on or between the toes, from rubbing.',
    ),
    zones: [FootZone.toes],
    lookFor: [
      T('نقطة مستديرة صلبة', 'Un point rond et dur', 'A round, hard spot'),
      T('ألم عند الضغط أو في الحذاء', 'Douleur à la pression ou dans la chaussure', 'Pain when pressed or in shoes'),
    ],
    atHome: [
      T('البس حذاء أوسع عند الأصابع', 'Portez des chaussures plus larges à l’avant', 'Wear shoes that are wider at the toes'),
      T('لا لصقات ولا أحماض', 'Pas de pansement coricide ni d’acide', 'No corn plasters or acids'),
    ],
    seeDoctor: [
      T('إذا صار أحمر أو مفتوحا أو مؤلما جدا', 'S’il devient rouge, ouvert ou très douloureux', 'It becomes red, open or very painful'),
    ],
  ),
  LearnArticle(
    id: 'blister',
    section: LearnSection.signs,
    icon: Icons.bubble_chart_outlined,
    title: T('الفقاعة', 'Ampoule', 'Blister', dz: 'الفقاعة'),
    summary: T(
      'فقاعة ماء من الاحتكاك. إذا فقدت الإحساس قد لا تشعر بها.',
      'Une bulle de liquide due au frottement. Sans sensibilité, vous pouvez ne pas la sentir.',
      'A fluid bubble from rubbing. With lost feeling you may not notice it.',
    ),
    zones: [FootZone.heel, FootZone.toes],
    lookFor: [
      T('انتفاخ صغير فيه سائل', 'Une petite bulle remplie de liquide', 'A small raised bubble with fluid'),
      T('بقعة على الجوارب', 'Une tache sur la chaussette', 'A stain on your sock'),
    ],
    atHome: [
      T('لا تفقأها', 'Ne la percez pas', 'Do not pop it'),
      T('غطها بضمادة نظيفة وجافة', 'Couvrez-la d’un pansement propre et sec', 'Cover it with a clean, dry dressing'),
      T('لا تلبس الحذاء الذي سببها', 'Ne remettez pas la chaussure en cause', 'Stop wearing the shoe that caused it'),
    ],
    seeDoctor: [
      T('خلال يوم أو يومين إذا كان إحساسك ضعيفا', 'Dans un ou deux jours si votre sensibilité est diminuée', 'Within a day or two if your feeling is reduced'),
      T('اليوم إذا ظهر احمرار أو حرارة أو قيح', 'Le jour même si rougeur, chaleur ou pus', 'Today if there is redness, warmth or pus'),
    ],
  ),
  LearnArticle(
    id: 'fungus',
    section: LearnSection.signs,
    icon: Icons.water_drop_outlined,
    title: T('فطريات بين الأصابع', 'Mycose entre les orteils', 'Fungus between the toes', dz: 'الفطريات بين الصوابع'),
    summary: T(
      'جلد أبيض رطب يتقشر بين الأصابع، ويمكن أن يتشقق.',
      'Une peau blanche, humide, qui pèle entre les orteils et peut se fendre.',
      'White, soggy, peeling skin between the toes that can crack.',
    ),
    zones: [FootZone.betweenToes],
    lookFor: [
      T('جلد أبيض طري بين الأصابع', 'Peau blanche et ramollie entre les orteils', 'White, softened skin between the toes'),
      T('حكة، شقوق صغيرة، رائحة', 'Démangeaisons, petites fissures, odeur', 'Itching, small cracks, a smell'),
    ],
    atHome: [
      T('جفف جيدا بين كل إصبعين', 'Séchez bien entre chaque orteil', 'Dry well between every toe'),
      T('غيّر الجوارب كل يوم', 'Changez de chaussettes chaque jour', 'Change socks every day'),
      T('اسأل الصيدلي عن كريم مضاد للفطريات', 'Demandez une crème antifongique au pharmacien', 'Ask the pharmacist for an antifungal cream'),
    ],
    seeDoctor: [
      T('إذا تشقق الجلد أو امتد الاحمرار', 'Si la peau se fend ou si la rougeur s’étend', 'The skin cracks or redness spreads'),
      T('إذا لم يتحسن خلال أسبوعين', 'Sans amélioration en deux semaines', 'No improvement within two weeks'),
    ],
  ),
  LearnArticle(
    id: 'nails',
    section: LearnSection.signs,
    icon: Icons.content_cut_rounded,
    title: T('مشاكل الأظافر', 'Problèmes d’ongles', 'Nail problems', dz: 'مشاكل الظوافر'),
    summary: T(
      'ظفر يدخل في الجلد، أو أظافر سميكة صفراء.',
      'Un ongle qui s’enfonce dans la peau, ou des ongles épais et jaunes.',
      'A nail growing into the skin, or thick yellow nails.',
    ),
    zones: [FootZone.nails],
    lookFor: [
      T('حافة الظفر تدخل في الجلد مع احمرار وانتفاخ', 'Le bord de l’ongle rentre dans la peau, rouge et gonflée', 'The nail edge digs into red, swollen skin'),
      T('أظافر سميكة صفراء تتفتت', 'Ongles épais, jaunes, qui s’effritent', 'Thick, yellow, crumbly nails'),
    ],
    atHome: [
      T('قص الأظافر بشكل مستقيم، لا تقصرها كثيرا', 'Coupez droit, pas trop court', 'Cut straight across, not too short'),
      T('برد الحواف', 'Limez les bords', 'File the edges'),
      T('لا تحفر في الزوايا', 'Ne creusez pas les coins', 'Do not dig into the corners'),
    ],
    seeDoctor: [
      T('إذا كان حول الظفر احمرار أو قيح', 'S’il y a rougeur ou pus autour de l’ongle', 'There is redness or pus around the nail'),
      T('إذا كانت الأظافر سميكة جدا أو لا تستطيع الوصول إليها', 'Si les ongles sont trop épais ou difficiles à atteindre', 'The nails are too thick or hard to reach'),
    ],
  ),
  LearnArticle(
    id: 'redness',
    section: LearnSection.signs,
    icon: Icons.local_fire_department_outlined,
    title: T('احمرار وحرارة', 'Rougeur et chaleur', 'Redness and warmth', dz: 'حمورية وسخانة'),
    summary: T(
      'منطقة حمراء أو أسخن من القدم الأخرى قد تعني التهابا.',
      'Une zone rouge ou plus chaude que l’autre pied peut signaler une inflammation.',
      'An area that is red or warmer than the other foot can mean inflammation.',
    ),
    zones: [FootZone.ball, FootZone.top],
    lookFor: [
      T('بقعة حمراء', 'Une zone rouge', 'A red area'),
      T('أسخن عند اللمس من نفس المكان في القدم الأخرى', 'Plus chaude au toucher que le même endroit de l’autre pied', 'Warmer to touch than the same spot on the other foot'),
    ],
    atHome: [
      T('أرح قدمك وأبعد عنها الضغط', 'Reposez le pied, retirez la pression', 'Rest the foot, take the pressure off'),
    ],
    seeDoctor: [
      T('اليوم إذا استمرت أكثر من يوم أو كانت تمتد', 'Le jour même si cela dure plus d’un jour ou s’étend', 'Today if it lasts more than a day or is spreading'),
    ],
    urgentNow: [
      T('إذا كانت معها حمى أو قشعريرة', 'Si elle s’accompagne de fièvre ou de frissons', 'It comes with fever or chills'),
    ],
  ),
  LearnArticle(
    id: 'swelling',
    section: LearnSection.signs,
    icon: Icons.open_in_full_rounded,
    title: T('انتفاخ القدم', 'Pied gonflé', 'A swollen foot', dz: 'الساق منفوخة'),
    summary: T(
      'انتفاخ جديد في قدم واحدة، حتى بدون ألم، يحتاج فحصا سريعا.',
      'Un gonflement nouveau d’un seul pied, même sans douleur, doit être vu vite.',
      'New swelling of one foot, even without pain, needs to be seen quickly.',
    ),
    zones: [FootZone.top, FootZone.innerEdge],
    lookFor: [
      T('قدم أو كاحل أكبر من الآخر', 'Un pied ou une cheville plus gros que l’autre', 'One foot or ankle bigger than the other'),
      T('الحذاء صار ضيقا', 'La chaussure serre soudain', 'A shoe suddenly feels tight'),
    ],
    seeDoctor: [
      T('اليوم إذا كان الانتفاخ في قدم واحدة وجديدا، خاصة مع حرارة واحمرار', 'Le jour même si c’est un seul pied et récent, surtout chaud et rouge', 'Today if it is one foot and new, especially if warm and red'),
    ],
  ),
  LearnArticle(
    id: 'colour',
    section: LearnSection.signs,
    icon: Icons.palette_outlined,
    title: T('تغيّر اللون', 'Changement de couleur', 'Colour change', dz: 'اللون تبدّل'),
    summary: T(
      'لون شاحب أو أزرق أو أسود قد يعني أن الدم لا يصل جيدا.',
      'Une peau pâle, bleue ou noire peut signifier que le sang circule mal.',
      'Pale, blue or black skin can mean blood is not reaching well.',
    ),
    zones: [FootZone.toes, FootZone.heel],
    lookFor: [
      T('مناطق شاحبة أو زرقاء أو بنفسجية أو سوداء', 'Zones pâles, bleues, violettes ou noires', 'Pale, blue, purple or black areas'),
      T('قدم باردة', 'Un pied froid', 'A cold foot'),
      T('ألم في الساق عند المشي يزول بالراحة', 'Douleur au mollet à la marche qui passe au repos', 'Calf pain when walking that goes away at rest'),
    ],
    seeDoctor: [
      T('قريبا إذا كان لديك ألم عند المشي', 'Rapidement si vous avez mal en marchant', 'Soon if walking hurts'),
    ],
    urgentNow: [
      T('إذا ظهرت منطقة سوداء أو زرقاء', 'Si une zone devient noire ou bleue', 'An area turns black or blue'),
      T('إذا صارت القدم فجأة باردة ومؤلمة', 'Si le pied devient soudain froid et douloureux', 'The foot suddenly turns cold and painful'),
    ],
  ),
  LearnArticle(
    id: 'wound',
    section: LearnSection.signs,
    icon: Icons.healing_outlined,
    title: T('الجرح أو القرحة', 'Plaie ou ulcère', 'A wound or ulcer', dz: 'الجرح'),
    summary: T(
      'أي جلد مفتوح في القدم يجب أن يراه مختص، حتى لو كان صغيرا وبدون ألم.',
      'Toute peau ouverte au pied doit être vue par un professionnel, même petite et indolore.',
      'Any open skin on the foot must be seen by a professional, even if small and painless.',
    ),
    zones: [FootZone.ball, FootZone.heel],
    view: FootView.sole,
    lookFor: [
      T('جلد مفتوح أو ثقب أو جرح لا يلتئم', 'Peau ouverte, trou ou plaie qui ne guérit pas', 'Open skin, a hole, or a sore that does not heal'),
      T('بقعة دم أو سائل على الجوارب', 'Une tache de sang ou de liquide sur la chaussette', 'A blood or fluid stain on your sock'),
    ],
    atHome: [
      T('نظّفه بماء نظيف أو محلول ملحي', 'Nettoyez à l’eau propre ou au sérum physiologique', 'Clean it with clean water or saline'),
      T('غطه بضمادة نظيفة وجافة', 'Couvrez d’un pansement propre et sec', 'Cover it with a clean, dry dressing'),
      T('لا تمش عليه قدر الإمكان', 'Marchez le moins possible dessus', 'Keep weight off it as much as you can'),
    ],
    seeDoctor: [
      T('خلال 24 ساعة، في كل الحالات', 'Dans les 24 heures, dans tous les cas', 'Within 24 hours, in every case'),
    ],
    urgentNow: [
      T('إذا كانت معه حمى أو قشعريرة', 'Avec fièvre ou frissons', 'With fever or chills'),
      T('إذا امتد الاحمرار بسرعة', 'Si la rougeur s’étend vite', 'Redness is spreading fast'),
      T('إذا كانت رائحته كريهة أو فيه قيح', 'S’il sent mauvais ou contient du pus', 'It smells bad or has pus'),
    ],
  ),
  LearnArticle(
    id: 'numbness',
    section: LearnSection.signs,
    icon: Icons.sensors_off_outlined,
    title: T('نقص الإحساس', 'Perte de sensibilité', 'Loss of feeling', dz: 'ما تحسّش بساقك'),
    summary: T(
      'السكري قد يضعف أعصاب القدم فلا تشعر بالجروح أو بالحرارة.',
      'Le diabète peut abîmer les nerfs du pied : on ne sent plus les blessures ni la chaleur.',
      'Diabetes can damage the foot nerves, so you stop feeling injuries or heat.',
    ),
    zones: [FootZone.toes, FootZone.ball, FootZone.heel],
    view: FootView.sole,
    lookFor: [
      T('تنميل أو حرقة أو وخز', 'Fourmillements, brûlures, picotements', 'Tingling, burning or pins and needles'),
      T('إحساس بالمشي على قطن', 'Impression de marcher sur du coton', 'Feeling like walking on cotton'),
      T('لا تحس بحرارة الماء', 'Vous ne sentez pas la chaleur de l’eau', 'You cannot feel how hot water is'),
    ],
    atHome: [
      T('لا تمش حافيا أبدا، لا في البيت ولا خارجه', 'Ne marchez jamais pieds nus, dedans comme dehors', 'Never walk barefoot, indoors or outdoors'),
      T('اختبر حرارة الماء بالمرفق أو بميزان حرارة', 'Testez l’eau avec le coude ou un thermomètre', 'Test water with your elbow or a thermometer'),
      T('افحص قدميك كل يوم لأنك قد لا تشعر بالجرح', 'Examinez vos pieds chaque jour : vous pourriez ne rien sentir', 'Check your feet every day: you may not feel a wound'),
    ],
    seeDoctor: [
      T('اطلب اختبار الإحساس في موعدك القادم', 'Demandez un test de sensibilité à votre prochain rendez-vous', 'Ask for a sensation test at your next visit'),
      T('قريبا إذا تغيّر الإحساس فجأة', 'Rapidement si la sensibilité change soudain', 'Soon if the feeling changes suddenly'),
    ],
  ),

  // ------------------------------------------------------------ urgent
  LearnArticle(
    id: 'when-doctor',
    section: LearnSection.urgent,
    icon: Icons.local_hospital_outlined,
    title: T('متى تذهب إلى الطبيب', 'Quand consulter', 'When to see a doctor', dz: 'وقتاش تمشي للطبيب'),
    summary: T(
      'بعض العلامات لا تنتظر الموعد القادم.',
      'Certains signes n’attendent pas le prochain rendez-vous.',
      'Some signs cannot wait for your next appointment.',
    ),
    urgentNow: [
      T('جرح مع حمى أو قشعريرة', 'Une plaie avec fièvre ou frissons', 'A wound with fever or chills'),
      T('احمرار يمتد بسرعة', 'Une rougeur qui s’étend vite', 'Redness spreading fast'),
      T('منطقة سوداء أو زرقاء', 'Une zone noire ou bleue', 'A black or blue area'),
      T('قدم باردة ومؤلمة فجأة', 'Un pied soudain froid et douloureux', 'A foot suddenly cold and painful'),
      T('رائحة كريهة أو قيح', 'Mauvaise odeur ou pus', 'A bad smell or pus'),
    ],
    seeDoctor: [
      T('خلال 24 ساعة: أي جرح أو فقاعة جديدة', 'Sous 24 heures : toute plaie ou ampoule nouvelle', 'Within 24 hours: any new wound or blister'),
      T('خلال 24 ساعة: انتفاخ جديد في قدم واحدة', 'Sous 24 heures : un pied qui gonfle', 'Within 24 hours: new swelling of one foot'),
      T('خلال 24 ساعة: احمرار أو حرارة أكثر من يوم', 'Sous 24 heures : rougeur ou chaleur depuis plus d’un jour', 'Within 24 hours: redness or warmth for more than a day'),
      T('قريبا: ظفر ملتهب، كالو مع بقعة داكنة', 'Bientôt : ongle enflammé, corne avec tache sombre', 'Soon: an inflamed nail, a callus with a dark spot'),
    ],
  ),

  // ------------------------------------------------------------ care
  LearnArticle(
    id: 'wash',
    section: LearnSection.care,
    icon: Icons.water_rounded,
    title: T('غسل القدمين', 'Laver ses pieds', 'Washing your feet', dz: 'غسيل الساقين'),
    summary: T(
      'كل يوم، بماء فاتر، بدون نقع طويل.',
      'Chaque jour, à l’eau tiède, sans bain prolongé.',
      'Every day, in lukewarm water, without long soaking.',
    ),
    hasVideo: true,
    atHome: [
      T('اختبر الماء بمرفقك أو بميزان حرارة، أقل من 37 درجة', 'Testez l’eau avec le coude ou un thermomètre, moins de 37 °C', 'Test the water with your elbow or a thermometer, below 37 °C'),
      T('لا تختبر الماء بقدمك', 'Ne testez jamais l’eau avec le pied', 'Never test the water with your foot'),
      T('صابون لطيف، ودلك بلطف', 'Un savon doux, frottez doucement', 'Mild soap, rub gently'),
      T('لا تنقع قدميك لمدة طويلة', 'Ne laissez pas tremper longtemps', 'Do not soak for a long time'),
    ],
  ),
  LearnArticle(
    id: 'dry',
    section: LearnSection.care,
    icon: Icons.dry_outlined,
    title: T('التجفيف بين الأصابع', 'Sécher entre les orteils', 'Drying between the toes', dz: 'نشّف بين الصوابع'),
    summary: T(
      'الرطوبة بين الأصابع تجلب الفطريات والشقوق.',
      'L’humidité entre les orteils favorise mycoses et fissures.',
      'Moisture between the toes brings fungus and cracks.',
    ),
    zones: [FootZone.betweenToes],
    hasVideo: true,
    atHome: [
      T('استعمل منشفة ناعمة ونظيفة', 'Une serviette douce et propre', 'Use a soft, clean towel'),
      T('ربّت ولا تفرك', 'Tamponnez, ne frottez pas', 'Pat, do not rub'),
      T('افتح الأصابع وجفف بين كل إصبعين', 'Écartez les orteils, séchez entre chacun', 'Spread the toes and dry between each one'),
      T('لا تستعمل مجفف الشعر الساخن', 'Pas de sèche-cheveux chaud', 'No hot hair dryer'),
    ],
  ),
  LearnArticle(
    id: 'moisturise',
    section: LearnSection.care,
    icon: Icons.opacity_rounded,
    title: T('الترطيب', 'Hydrater la peau', 'Moisturising', dz: 'الترطيب'),
    summary: T(
      'الكريم يحمي من الجفاف والتشقق، لكن ليس بين الأصابع.',
      'La crème protège de la sécheresse et des fissures, mais pas entre les orteils.',
      'Cream protects against dryness and cracks, but not between the toes.',
    ),
    zones: [FootZone.heel, FootZone.top],
    hasVideo: true,
    atHome: [
      T('بعد الغسل والتجفيف', 'Après lavage et séchage', 'After washing and drying'),
      T('على أعلى القدم وباطنها والكعب', 'Sur le dessus, la plante et le talon', 'On the top, the sole and the heel'),
      T('دلّك بلطف بحركات دائرية صغيرة', 'Massez doucement en cercles', 'Massage gently in small circles'),
      T('ليس بين الأصابع، وليس على جرح أو احمرار', 'Pas entre les orteils, ni sur une plaie ou une rougeur', 'Not between the toes, and not on a wound or redness'),
    ],
  ),
  LearnArticle(
    id: 'nail-care',
    section: LearnSection.care,
    icon: Icons.content_cut_rounded,
    title: T('قص الأظافر', 'Couper ses ongles', 'Cutting your nails', dz: 'قص الظوافر'),
    summary: T(
      'بعد الغسل، بشكل مستقيم، مرة في الأسبوع.',
      'Après la toilette, bien droit, une fois par semaine.',
      'After washing, straight across, once a week.',
    ),
    zones: [FootZone.nails],
    hasVideo: true,
    atHome: [
      T('بعد الغسل تكون الأظافر أطرى', 'Après la toilette, les ongles sont plus tendres', 'Nails are softer after washing'),
      T('قص بشكل مستقيم، لا تقصر كثيرا', 'Coupez droit, pas trop court', 'Cut straight across, not too short'),
      T('برد الحواف الحادة', 'Limez les bords coupants', 'File any sharp edges'),
      T('إذا كان نظرك ضعيفا اطلب مساعدة مختص', 'Si vous voyez mal, faites-vous aider par un professionnel', 'If your eyesight is poor, ask a professional'),
    ],
  ),
  LearnArticle(
    id: 'socks-shoes',
    section: LearnSection.care,
    icon: Icons.checkroom_outlined,
    title: T('الجوارب والأحذية', 'Chaussettes et chaussures', 'Socks and shoes', dz: 'الكلسات والصباط'),
    summary: T(
      'أغلب الجروح تبدأ من حذاء غير مناسب.',
      'La plupart des plaies commencent par une chaussure inadaptée.',
      'Most wounds start with an unsuitable shoe.',
    ),
    hasVideo: true,
    atHome: [
      T('جوارب نظيفة كل يوم، بلا خياطة من الداخل ولا مطاط ضيق', 'Chaussettes propres chaque jour, sans couture intérieure ni élastique serré', 'Clean socks every day, no inside seams, no tight elastic'),
      T('مرر يدك داخل الحذاء قبل لبسه', 'Passez la main dans la chaussure avant de la mettre', 'Run your hand inside the shoe before putting it on'),
      T('حذاء مغلق بالمقاس، اشتره بعد الظهر', 'Chaussures fermées à la bonne taille, achetées l’après-midi', 'Closed shoes that fit, bought in the afternoon'),
      T('البس الحذاء الجديد لوقت قصير في البداية', 'Portez une chaussure neuve peu de temps au début', 'Wear new shoes for short periods at first'),
      T('لا تمش حافيا', 'Ne marchez pas pieds nus', 'Do not walk barefoot'),
    ],
  ),
  LearnArticle(
    id: 'move',
    section: LearnSection.care,
    icon: Icons.directions_walk_rounded,
    title: T('الحركة والدورة الدموية', 'Bouger et circulation', 'Movement and circulation', dz: 'الحركة ودوران الدم'),
    summary: T(
      'الحركة اليومية تساعد الدم على الوصول إلى القدمين.',
      'Bouger chaque jour aide le sang à atteindre les pieds.',
      'Moving every day helps blood reach your feet.',
    ),
    hasVideo: true,
    atHome: [
      T('امش كل يوم إذا لم يكن لديك جرح', 'Marchez chaque jour si vous n’avez pas de plaie', 'Walk every day if you have no wound'),
      T('وأنت جالس: أدر الكاحل 10 مرات في كل اتجاه', 'Assis : tournez la cheville 10 fois dans chaque sens', 'Sitting: circle each ankle 10 times each way'),
      T('اثن أصابع القدم وافتحها 10 مرات', 'Pliez et étirez les orteils 10 fois', 'Curl and stretch your toes 10 times'),
      T('لا تضع رجلا على رجل لمدة طويلة', 'Ne croisez pas les jambes longtemps', 'Do not cross your legs for long'),
      T('التوقف عن التدخين يحسن الدورة الدموية', 'Arrêter de fumer améliore la circulation', 'Stopping smoking improves circulation'),
    ],
  ),

  // ------------------------------------------------------------ life
  LearnArticle(
    id: 'hammam',
    section: LearnSection.life,
    icon: Icons.hot_tub_outlined,
    title: T('الحمّام والماء الساخن', 'Hammam et eau chaude', 'Hammam and hot water', dz: 'الحمّام والماء السخون'),
    summary: T(
      'إذا ضعف إحساسك قد تحترق قدمك دون أن تشعر.',
      'Avec une sensibilité diminuée, on peut se brûler sans le sentir.',
      'With reduced feeling you can burn your foot without noticing.',
    ),
    atHome: [
      T('اختبر الماء بيدك أو بمرفقك قبل وضع قدميك', 'Testez l’eau avec la main ou le coude avant d’y mettre les pieds', 'Test the water with your hand or elbow first'),
      T('لا تجلس طويلا على الأرضية الساخنة', 'Ne restez pas longtemps assis sur le sol chaud', 'Do not sit long on the hot floor'),
      T('البس صندلا بلاستيكيا', 'Portez des sandales en plastique', 'Wear plastic sandals'),
      T('جفف بين الأصابع جيدا بعد الحمّام', 'Séchez bien entre les orteils après', 'Dry well between the toes afterwards'),
    ],
  ),
  LearnArticle(
    id: 'beach',
    section: LearnSection.life,
    icon: Icons.beach_access_outlined,
    title: T('البحر والرمل الساخن', 'Plage et sable chaud', 'Beach and hot sand', dz: 'البحر والرملة السخونة'),
    summary: T(
      'الرمل في الصيف يحرق، والصخور والأصداف تجرح.',
      'L’été, le sable brûle ; rochers et coquillages blessent.',
      'Summer sand burns, and rocks and shells cut.',
    ),
    atHome: [
      T('لا تمش حافيا على الرمل', 'Ne marchez pas pieds nus sur le sable', 'Do not walk barefoot on the sand'),
      T('البس حذاء خاصا بالماء', 'Portez des chaussures d’eau', 'Wear water shoes'),
      T('ضع واقي الشمس على أعلى القدم', 'Mettez de la crème solaire sur le dessus du pied', 'Put sunscreen on the top of your feet'),
      T('افحص قدميك عند العودة', 'Examinez vos pieds au retour', 'Check your feet when you get home'),
    ],
  ),
  LearnArticle(
    id: 'ramadan',
    section: LearnSection.life,
    icon: Icons.nightlight_outlined,
    title: T('الصيام في رمضان', 'Jeûne du Ramadan', 'Fasting in Ramadan', dz: 'الصيام في رمضان'),
    summary: T(
      'تحدث مع طبيبك قبل رمضان، واستمر في فحص قدميك.',
      'Parlez à votre médecin avant le Ramadan et continuez à examiner vos pieds.',
      'Talk to your doctor before Ramadan, and keep checking your feet.',
    ),
    atHome: [
      T('استشر طبيبك قبل الصيام لتعديل الدواء', 'Voyez votre médecin avant de jeûner pour adapter le traitement', 'See your doctor before fasting to adjust treatment'),
      T('قس السكر كما نصحك الطبيب', 'Mesurez la glycémie comme conseillé', 'Measure your blood sugar as advised'),
      T('اشرب الماء بين الإفطار والسحور', 'Buvez de l’eau entre la rupture et le shour', 'Drink water between iftar and suhoor'),
      T('افحص قدميك كل يوم، خاصة قبل الصلاة وبعد الوضوء', 'Examinez vos pieds chaque jour, par exemple après les ablutions', 'Check your feet every day, for example after ablutions'),
    ],
  ),
  LearnArticle(
    id: 'summer',
    section: LearnSection.life,
    icon: Icons.wb_sunny_outlined,
    title: T('الصيف والصنادل', 'Été et sandales', 'Summer and sandals', dz: 'الصيف والشلاكة'),
    summary: T(
      'الصنادل المفتوحة تعرض القدم للجروح والحروق.',
      'Les sandales ouvertes exposent aux blessures et aux brûlures.',
      'Open sandals expose your feet to cuts and burns.',
    ),
    atHome: [
      T('فضّل الحذاء المغلق', 'Préférez les chaussures fermées', 'Prefer closed shoes'),
      T('إذا لبست صندلا فليكن بشريط خلفي، بدون خيط بين الأصابع', 'Si sandale, avec bride arrière, sans lanière entre les orteils', 'If you wear sandals, choose a back strap and no strap between the toes'),
      T('تجنب البلغة والشلاكة للمشي الطويل', 'Évitez babouches et tongs pour marcher longtemps', 'Avoid slippers and flip-flops for long walks'),
    ],
  ),

  // ------------------------------------------------------------ food
  LearnArticle(
    id: 'food',
    section: LearnSection.food,
    icon: Icons.restaurant_outlined,
    title: T('صحن متوازن', 'Une assiette équilibrée', 'A balanced plate', dz: 'صحن متوازن'),
    summary: T(
      'السكر المتوازن يحمي أعصاب القدم ويساعد الجروح على الالتئام.',
      'Une glycémie équilibrée protège les nerfs du pied et aide les plaies à guérir.',
      'Balanced blood sugar protects foot nerves and helps wounds heal.',
    ),
    atHome: [
      T('نصف الصحن خضر', 'La moitié de l’assiette en légumes', 'Half the plate vegetables'),
      T('ربع خبز أو كسكسي أو معكرونة، ويفضل الكامل', 'Un quart de pain, couscous ou pâtes, complets de préférence', 'A quarter bread, couscous or pasta, wholegrain if possible'),
      T('ربع بروتين: سمك، دجاج، بيض، بقول', 'Un quart de protéines : poisson, poulet, œufs, légumineuses', 'A quarter protein: fish, chicken, eggs, pulses'),
      T('قلل المشروبات المحلاة والحلويات', 'Limitez boissons sucrées et pâtisseries', 'Cut down on sugary drinks and pastries'),
      T('وجبات في مواعيد منتظمة، واشرب الماء', 'Des repas à heures régulières, et de l’eau', 'Regular mealtimes, and water to drink'),
    ],
    seeDoctor: [
      T('اطلب مقابلة مختص تغذية لخطة تناسبك', 'Demandez un diététicien pour un plan adapté', 'Ask for a dietitian for a plan that suits you'),
    ],
  ),
];

List<LearnArticle> articlesIn(LearnSection section) =>
    learnArticles.where((a) => a.section == section).toList();

LearnArticle? articleById(String id) {
  for (final a in learnArticles) {
    if (a.id == id) return a;
  }
  return null;
}

/// One care tip per day, rotating through the daily care and everyday life
/// articles so the same person sees a different one each morning.
LearnArticle tipFor(DateTime day) {
  final pool = learnArticles
      .where((a) => a.section == LearnSection.care || a.section == LearnSection.life)
      .toList();
  final index = DateTime(day.year, day.month, day.day).difference(DateTime(2026)).inDays;
  return pool[index.abs() % pool.length];
}
