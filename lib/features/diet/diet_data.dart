/// Tunisian foods with a usual portion, the grams of carbohydrate in that
/// portion, and plain advice.
///
/// Sources of the carbohydrate values, per 100 g, are cited next to each food:
/// USDA FoodData Central (SR Legacy unless said otherwise). For Tunisian
/// dishes and pastries with no entry, the value is an estimate from their
/// usual recipe, built from the USDA values of the ingredients, and says so.
/// The Tunisian INNTA food composition table should replace these values when
/// it is available to the team.
///
/// All of this is still to be validated by a dietitian ([dietReviewed]).
library;

import '../common.dart';

/// False until a dietitian has reviewed this content; the pages say so.
const dietReviewed = false;

/// A text in the four languages of the app.
class L {
  final String fr;
  final String aeb;
  final String ar;
  final String en;
  const L(this.fr, {required this.aeb, required this.ar, required this.en});

  /// In the app's language.
  String get text => tr(fr, aeb: aeb, ar: ar, en: en);

  List<String> get all => [fr, aeb, ar, en];
}

/// How often and how much: never a ban, always a practical way to eat it.
enum FoodLevel {
  /// Librement.
  free,

  /// En portion mesurée.
  measured,

  /// Rarement, petite part.
  rarely,
}

class Food {
  final String id;
  final L name;
  final L portion;

  /// Grams (or millilitres for drinks) of the usual portion.
  final int grams;

  /// Grams of carbohydrate in the usual portion.
  final double carbs;
  final FoodLevel level;

  /// A better choice, or the way to eat it.
  final L swap;

  /// Other spellings people search with (transliterations).
  final List<String> aliases;

  const Food({
    required this.id,
    required this.name,
    required this.portion,
    required this.grams,
    required this.carbs,
    required this.level,
    required this.swap,
    this.aliases = const [],
  });

  /// Carbohydrate for a number of portions, rounded to the gram.
  int carbsFor(double portions) => (carbs * portions).round();
}

/// Folds accents, Arabic vowel marks and letter variants, so "fève",
/// "feve", "فول" and "الفول" all match.
String foldForSearch(String s) {
  var out = s.toLowerCase().trim();
  const accents = {
    'à': 'a', 'â': 'a', 'ä': 'a', 'á': 'a', 'ç': 'c', 'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e',
    'î': 'i', 'ï': 'i', 'í': 'i', 'ô': 'o', 'ö': 'o', 'ó': 'o', 'ù': 'u', 'û': 'u', 'ü': 'u',
    'œ': 'oe', 'æ': 'ae', '’': "'",
  };
  accents.forEach((k, v) => out = out.replaceAll(k, v));
  out = out
      .replaceAll(RegExp('[ً-ْـ]'), '') // vowel marks, tatweel
      .replaceAll(RegExp('[أإآ]'), 'ا')
      .replaceAll('ة', 'ه')
      .replaceAll('ى', 'ي');
  return out;
}

/// Foods whose name in any language, or any alias, contains the query.
List<Food> searchFoods(String query, {FoodLevel? level}) {
  final q = foldForSearch(query);
  return [
    for (final f in tunisianFoods)
      if ((level == null || f.level == level) &&
          (q.isEmpty ||
              [...f.name.all, ...f.aliases].any((n) {
                final name = foldForSearch(n);
                return name.contains(q) || (name.startsWith('ال') && name.substring(2).contains(q));
              })))
        f,
  ];
}

const tunisianFoods = <Food>[
  // ---------------------------------------------------------------- breads
  Food(
    id: 'tabouna',
    // USDA: Bread, pita, white, enriched: 55.7 g/100 g. Quarter tabouna ≈ 50 g.
    name: L('Tabouna', aeb: 'طابونة', ar: 'خبز الطابونة', en: 'Tabouna bread'),
    portion: L('¼ de tabouna (50 g)', aeb: 'ربع طابونة (50 غ)', ar: 'ربع خبزة طابونة (50 غ)', en: '¼ tabouna (50 g)'),
    grams: 50,
    carbs: 28,
    level: FoodLevel.measured,
    swap: L('Un quart par repas, avec beaucoup de légumes. Le pain complet est encore mieux.',
        aeb: 'ربع في الماكلة، مع برشا خضرة. الخبز الكامل خير.',
        ar: 'ربع في الوجبة مع كثير من الخضار. الخبز الكامل أفضل.',
        en: 'A quarter per meal, with plenty of vegetables. Wholemeal bread is even better.'),
    aliases: ['tabona', 'tabounna'],
  ),
  Food(
    id: 'baguette',
    // USDA: Bread, french or vienna (includes sourdough): 51.9 g/100 g. Quarter baguette ≈ 60 g.
    name: L('Baguette', aeb: 'خبز باقات', ar: 'خبز الباقات', en: 'Baguette'),
    portion: L('¼ de baguette (60 g)', aeb: 'ربع باقات (60 غ)', ar: 'ربع خبزة باقات (60 غ)', en: '¼ baguette (60 g)'),
    grams: 60,
    carbs: 31,
    level: FoodLevel.measured,
    swap: L('Préférez le pain complet ou d’orge, en même quantité.',
        aeb: 'خير الخبز الكامل ولا خبز الشعير، بنفس الكمية.',
        ar: 'فضّل الخبز الكامل أو خبز الشعير بنفس الكمية.',
        en: 'Prefer wholemeal or barley bread, in the same amount.'),
    aliases: ['pain blanc', 'bagett', 'baget'],
  ),
  Food(
    id: 'whole_bread',
    // USDA: Bread, whole-wheat, commercially prepared: 41.3 g/100 g. Two slices ≈ 60 g.
    name: L('Pain complet', aeb: 'خبز كامل', ar: 'خبز القمح الكامل', en: 'Wholemeal bread'),
    portion: L('2 tranches (60 g)', aeb: 'زوز طرف (60 غ)', ar: 'شريحتان (60 غ)', en: '2 slices (60 g)'),
    grams: 60,
    carbs: 25,
    level: FoodLevel.measured,
    swap: L('Le meilleur choix de pain : ses fibres font monter la glycémie plus lentement.',
        aeb: 'أحسن خبز: الألياف متاعو يخلّيو السكر يطلع بشوية.',
        ar: 'أفضل خبز: أليافه تجعل السكر يرتفع ببطء.',
        en: 'The best bread: its fibre makes blood sugar rise more slowly.'),
    aliases: ['pain integral', 'pain d orge', 'khobz kamel'],
  ),
  // ---------------------------------------------------------------- dishes
  Food(
    id: 'couscous',
    // USDA: Couscous, cooked: 23.2 g/100 g.
    name: L('Couscous', aeb: 'كسكسي', ar: 'الكسكسي', en: 'Couscous'),
    portion: L('1 petite assiette cuite (150 g)', aeb: 'صحفة صغيرة طايبة (150 غ)', ar: 'صحن صغير مطبوخ (150 غ)', en: '1 small plate, cooked (150 g)'),
    grams: 150,
    carbs: 35,
    level: FoodLevel.measured,
    swap: L('Une petite assiette, avec beaucoup de légumes et la viande ou le poisson. Le couscous d’orge (belboula) est mieux.',
        aeb: 'صحفة صغيرة، مع برشا خضرة واللحم ولا الحوت. كسكسي الشعير (بلبولة) خير.',
        ar: 'صحن صغير مع كثير من الخضار واللحم أو السمك. كسكسي الشعير (البلبولة) أفضل.',
        en: 'A small plate, with plenty of vegetables and the meat or fish. Barley couscous (belboula) is better.'),
    aliases: ['kouskous', 'kousksi', 'couscous orge', 'belboula'],
  ),
  Food(
    id: 'makrouna',
    // USDA: Pasta, cooked, enriched, without added salt: 30.9 g/100 g.
    name: L('Makrouna (pâtes)', aeb: 'مقرونة', ar: 'المعكرونة', en: 'Makrouna (pasta)'),
    portion: L('1 petite assiette cuite (150 g)', aeb: 'صحفة صغيرة طايبة (150 غ)', ar: 'صحن صغير مطبوخ (150 غ)', en: '1 small plate, cooked (150 g)'),
    grams: 150,
    carbs: 46,
    level: FoodLevel.measured,
    swap: L('Une petite assiette « al dente », avec une salade avant. Les pâtes complètes sont mieux.',
        aeb: 'صحفة صغيرة موش طايبة برشا، وسلاطة قبلها. المقرونة الكاملة خير.',
        ar: 'صحن صغير غير مطهو كثيرًا، مع سلطة قبله. المعكرونة الكاملة أفضل.',
        en: 'A small plate cooked al dente, with a salad first. Wholemeal pasta is better.'),
    aliases: ['macaroni', 'pates', 'makarouna', 'spaghetti'],
  ),
  Food(
    id: 'rice',
    // USDA: Rice, white, long-grain, regular, enriched, cooked: 28.2 g/100 g.
    name: L('Riz', aeb: 'روز', ar: 'الأرز', en: 'Rice'),
    portion: L('1 petite assiette cuite (150 g)', aeb: 'صحفة صغيرة طايبة (150 غ)', ar: 'صحن صغير مطبوخ (150 غ)', en: '1 small plate, cooked (150 g)'),
    grams: 150,
    carbs: 42,
    level: FoodLevel.measured,
    swap: L('Une petite assiette, avec des légumes. Le riz complet ou le boulgour sont mieux.',
        aeb: 'صحفة صغيرة، مع الخضرة. الروز الكامل ولا البرغل خير.',
        ar: 'صحن صغير مع الخضار. الأرز البني أو البرغل أفضل.',
        en: 'A small plate, with vegetables. Brown rice or bulgur is better.'),
    aliases: ['rouz', 'roz'],
  ),
  Food(
    id: 'lablabi',
    // USDA: Chickpeas, mature seeds, cooked, boiled, without salt: 27.4 g/100 g.
    // Bowl of 150 g chickpeas, without the bread (bread adds about 26 g per 50 g).
    name: L('Lablabi', aeb: 'لبلابي', ar: 'اللبلابي', en: 'Lablabi (chickpea soup)'),
    portion: L('1 bol sans pain (150 g de pois chiches)', aeb: 'زلافة بلا خبز (150 غ حمص)', ar: 'وعاء دون خبز (150 غ حمص)', en: '1 bowl without bread (150 g chickpeas)'),
    grams: 150,
    carbs: 41,
    level: FoodLevel.measured,
    swap: L('Bon plat de légumineuses : mettez peu de pain dedans, un petit morceau suffit.',
        aeb: 'ماكلة باهية بالحمص: حط شوية خبز برك، طرف صغير يكفي.',
        ar: 'طبق بقوليات جيد: ضع قليلًا من الخبز، قطعة صغيرة تكفي.',
        en: 'A good legume dish: put little bread in it, a small piece is enough.'),
    aliases: ['leblebi', 'lablebi'],
  ),
  Food(
    id: 'chorba',
    // Estimate from the usual recipe: 25 g dry orzo or frik (USDA Pasta, dry,
    // enriched: 74.7 g/100 g) plus tomato and onion, per bowl of 300 mL.
    name: L('Chorba', aeb: 'شربة', ar: 'الشوربة', en: 'Chorba (soup)'),
    portion: L('1 bol (300 mL)', aeb: 'زلافة (300 مل)', ar: 'وعاء (300 مل)', en: '1 bowl (300 mL)'),
    grams: 300,
    carbs: 24,
    level: FoodLevel.measured,
    swap: L('Une bonne entrée, surtout avec des légumes et de la viande maigre. Sans pain en plus.',
        aeb: 'بداية باهية، خاصة بالخضرة واللحم بلا شحم. بلا خبز زايد.',
        ar: 'مقبلات جيدة، خاصة مع الخضار واللحم قليل الدهن. دون خبز إضافي.',
        en: 'A good starter, especially with vegetables and lean meat. No extra bread.'),
    aliases: ['chorba frik', 'shorba', 'soupe'],
  ),
  Food(
    id: 'brik',
    // Estimate: one malsouka sheet of 25 g (USDA Phyllo dough: 52.6 g/100 g), egg and tuna.
    name: L('Brik', aeb: 'بريك', ar: 'البريك', en: 'Brik'),
    portion: L('1 brik', aeb: 'بريكة وحدة', ar: 'بريكة واحدة', en: '1 brik'),
    grams: 90,
    carbs: 14,
    level: FoodLevel.rarely,
    swap: L('Frite, elle est riche en huile : une seule, rarement, bien égouttée. Mieux : l’œuf et le thon avec une salade.',
        aeb: 'مقلية وفيها برشا زيت: وحدة برك، مرة مرة، مصفّية مليح. خير: العظم والتن مع سلاطة.',
        ar: 'مقلية وغنية بالزيت: واحدة فقط ونادرًا، مصفّاة جيدًا. الأفضل: البيض والتونة مع سلطة.',
        en: 'Fried, so rich in oil: just one, rarely, well drained. Better: the egg and tuna with a salad.'),
    aliases: ['brick', 'brik a l oeuf'],
  ),
  Food(
    id: 'fricasse',
    // Estimate: fried roll of 70 g of dough (like white bread, about 50 g/100 g)
    // with a little potato (USDA Potatoes, boiled: 20 g/100 g).
    name: L('Fricassé', aeb: 'فريكاسي', ar: 'الفريكاسي', en: 'Fricassé (fried sandwich)'),
    portion: L('1 fricassé', aeb: 'فريكاسي واحد', ar: 'فريكاسي واحد', en: '1 fricassé'),
    grams: 120,
    carbs: 40,
    level: FoodLevel.rarely,
    swap: L('Pain frit : rarement, un seul. Mieux : un sandwich de pain complet au thon et aux légumes.',
        aeb: 'خبز مقلي: مرة مرة، واحد برك. خير: كسكروت خبز كامل بالتن والخضرة.',
        ar: 'خبز مقلي: نادرًا وواحد فقط. الأفضل: شطيرة خبز كامل بالتونة والخضار.',
        en: 'Fried bread: rarely, just one. Better: a wholemeal sandwich with tuna and vegetables.'),
    aliases: ['fricasse', 'friccassee'],
  ),
  Food(
    id: 'mlawi',
    // Estimate: about 60 g of flour per mlawi (USDA Wheat flour, white, all-purpose: 76.3 g/100 g), cooked with oil.
    name: L('Mlawi', aeb: 'ملاوي', ar: 'الملاوي', en: 'Mlawi (flatbread)'),
    portion: L('1 mlawi', aeb: 'ملاوي واحد', ar: 'ملاوي واحد', en: '1 mlawi'),
    grams: 100,
    carbs: 46,
    level: FoodLevel.rarely,
    swap: L('Riche en farine blanche et en huile : un demi, rarement, avec une garniture de légumes et d’œuf.',
        aeb: 'فيه برشا فارينة وزيت: نص، مرة مرة، بالخضرة والعظم.',
        ar: 'غني بالدقيق الأبيض والزيت: نصف واحد نادرًا، مع حشوة خضار وبيض.',
        en: 'Rich in white flour and oil: half of one, rarely, filled with vegetables and egg.'),
    aliases: ['mlaoui', 'malawi'],
  ),
  Food(
    id: 'chapati',
    // Estimate: about 80 g of bread (like white bread, about 50 g/100 g) plus the filling.
    name: L('Chapati tunisien', aeb: 'شباتي', ar: 'الشباتي التونسي', en: 'Tunisian chapati'),
    portion: L('1 chapati garni', aeb: 'شباتي معمّر', ar: 'شباتي محشو', en: '1 filled chapati'),
    grams: 150,
    carbs: 45,
    level: FoodLevel.rarely,
    swap: L('Un demi, avec plus de salade et d’œuf, moins de frites et de mayonnaise.',
        aeb: 'نصّو، بسلاطة وعظم أكثر، وبطاطا مقلية ومايونيز أقل.',
        ar: 'نصفه، مع سلطة وبيض أكثر، وبطاطا مقلية ومايونيز أقل.',
        en: 'Half of one, with more salad and egg, fewer chips and less mayonnaise.'),
    aliases: ['chapatti', 'chappati'],
  ),
  Food(
    id: 'bsissa',
    // Estimate: roasted barley and chickpea flour, about 65 g/100 g (USDA Barley flour or meal: 74.5 g/100 g;
    // Chickpea flour: 57.8 g/100 g), without added sugar.
    name: L('Bsissa', aeb: 'بسيسة', ar: 'البسيسة', en: 'Bsissa'),
    portion: L('3 cuillères à soupe (40 g)', aeb: '3 مغارف كبار (40 غ)', ar: '3 ملاعق كبيرة (40 غ)', en: '3 tablespoons (40 g)'),
    grams: 40,
    carbs: 26,
    level: FoodLevel.measured,
    swap: L('Sans sucre ajouté, avec un filet d’huile d’olive : un bon petit-déjeuner, en portion mesurée.',
        aeb: 'بلا سكر، بشوية زيت زيتونة: فطور صباح باهي، بكمية محسوبة.',
        ar: 'دون سكر مضاف ومع قليل من زيت الزيتون: فطور جيد بكمية محسوبة.',
        en: 'With no added sugar and a drizzle of olive oil: a good breakfast, in a measured portion.'),
    aliases: ['bsisa', 'bssissa'],
  ),
  Food(
    id: 'assida',
    // Estimate: semolina or flour cooked with sugar or honey, about 30 g/100 g.
    name: L('Assida', aeb: 'عصيدة', ar: 'العصيدة', en: 'Assida'),
    portion: L('1 petit bol (150 g)', aeb: 'زلافة صغيرة (150 غ)', ar: 'وعاء صغير (150 غ)', en: '1 small bowl (150 g)'),
    grams: 150,
    carbs: 45,
    level: FoodLevel.rarely,
    swap: L('Pour les fêtes : quelques cuillères, sans ajouter de miel ni de sucre.',
        aeb: 'للمناسبات: شوية مغارف، بلا عسل ولا سكر زايد.',
        ar: 'للمناسبات: بضع ملاعق دون إضافة عسل أو سكر.',
        en: 'For celebrations: a few spoonfuls, without extra honey or sugar.'),
    aliases: ['assida zgougou', 'aassida'],
  ),
  Food(
    id: 'potato',
    // USDA: Potatoes, boiled, cooked without skin, flesh, without salt: 20.0 g/100 g.
    name: L('Pomme de terre', aeb: 'بطاطا', ar: 'البطاطس', en: 'Potato'),
    portion: L('1 moyenne cuite à l’eau (150 g)', aeb: 'حبة متوسطة مسلوقة (150 غ)', ar: 'حبة متوسطة مسلوقة (150 غ)', en: '1 medium, boiled (150 g)'),
    grams: 150,
    carbs: 30,
    level: FoodLevel.measured,
    swap: L('Compte comme un féculent, pas comme un légume. Cuite à l’eau ou au four plutôt que frite.',
        aeb: 'تتحسب نشويات موش خضرة. مسلوقة ولا في الفور خير من المقلية.',
        ar: 'تُحسب من النشويات لا من الخضار. مسلوقة أو في الفرن أفضل من المقلية.',
        en: 'It counts as a starch, not a vegetable. Boiled or baked rather than fried.'),
    aliases: ['batata', 'patate', 'frites'],
  ),
  // ---------------------------------------------------------------- legumes
  Food(
    id: 'chickpeas',
    // USDA: Chickpeas (garbanzo beans), mature seeds, cooked, boiled, without salt: 27.4 g/100 g.
    name: L('Pois chiches', aeb: 'حمص', ar: 'الحمص', en: 'Chickpeas'),
    portion: L('½ bol cuit (100 g)', aeb: 'نص زلافة طايبة (100 غ)', ar: 'نصف وعاء مطبوخ (100 غ)', en: '½ bowl, cooked (100 g)'),
    grams: 100,
    carbs: 27,
    level: FoodLevel.measured,
    swap: L('Riches en fibres et en protéines : un bon féculent, à la place du pain.',
        aeb: 'فيه برشا ألياف وبروتين: نشويات باهية، في بلاصة الخبز.',
        ar: 'غني بالألياف والبروتين: نشويات جيدة بدل الخبز.',
        en: 'Rich in fibre and protein: a good starch, instead of bread.'),
    aliases: ['hommos', 'hummus', 'hommes'],
  ),
  Food(
    id: 'lentils',
    // USDA: Lentils, mature seeds, cooked, boiled, without salt: 20.1 g/100 g.
    name: L('Lentilles', aeb: 'عدس', ar: 'العدس', en: 'Lentils'),
    portion: L('1 bol cuit (150 g)', aeb: 'زلافة طايبة (150 غ)', ar: 'وعاء مطبوخ (150 غ)', en: '1 bowl, cooked (150 g)'),
    grams: 150,
    carbs: 30,
    level: FoodLevel.measured,
    swap: L('Excellent : fibres et protéines. Avec des légumes, sans trop de pain.',
        aeb: 'ممتاز: ألياف وبروتين. مع الخضرة، بلا برشا خبز.',
        ar: 'ممتاز: ألياف وبروتين. مع الخضار ودون كثير من الخبز.',
        en: 'Excellent: fibre and protein. With vegetables, without much bread.'),
    aliases: ['adas', 'ades'],
  ),
  Food(
    id: 'fava',
    // USDA: Broadbeans (fava beans), mature seeds, cooked, boiled, without salt: 19.6 g/100 g.
    name: L('Fèves', aeb: 'فول', ar: 'الفول', en: 'Broad beans'),
    portion: L('1 bol cuit (150 g)', aeb: 'زلافة طايبة (150 غ)', ar: 'وعاء مطبوخ (150 غ)', en: '1 bowl, cooked (150 g)'),
    grams: 150,
    carbs: 29,
    level: FoodLevel.measured,
    swap: L('Un bon féculent riche en fibres, avec un filet d’huile d’olive et du cumin.',
        aeb: 'نشويات باهية فيها ألياف، بشوية زيت زيتونة وكمون.',
        ar: 'نشويات جيدة غنية بالألياف، مع قليل من زيت الزيتون والكمون.',
        en: 'A good fibre-rich starch, with a drizzle of olive oil and cumin.'),
    aliases: ['foul', 'ful', 'feves', 'fava'],
  ),
  // ---------------------------------------------------------------- proteins
  Food(
    id: 'eggs',
    // USDA: Egg, whole, raw, fresh: 0.72 g/100 g.
    name: L('Œufs', aeb: 'عظم', ar: 'البيض', en: 'Eggs'),
    portion: L('2 œufs (100 g)', aeb: 'زوز عظمات (100 غ)', ar: 'بيضتان (100 غ)', en: '2 eggs (100 g)'),
    grams: 100,
    carbs: 1,
    level: FoodLevel.free,
    swap: L('Presque sans glucides. Durs, pochés ou en omelette avec des légumes plutôt que frits.',
        aeb: 'تقريب بلا سكر. مسلوق ولا عجة بالخضرة خير من المقلي.',
        ar: 'تقريبًا دون سكريات. مسلوق أو عجة بالخضار أفضل من المقلي.',
        en: 'Almost no carbohydrate. Boiled, poached or in an omelette with vegetables rather than fried.'),
    aliases: ['oeuf', 'oeufs', 'adhm', 'bid'],
  ),
  Food(
    id: 'fish',
    // USDA: Fish, cod, Atlantic, cooked, dry heat: 0 g/100 g (fish has no carbohydrate).
    name: L('Poisson', aeb: 'حوت', ar: 'السمك', en: 'Fish'),
    portion: L('1 part (120 g)', aeb: 'حصّة (120 غ)', ar: 'حصة (120 غ)', en: '1 serving (120 g)'),
    grams: 120,
    carbs: 0,
    level: FoodLevel.free,
    swap: L('Sans glucides. Grillé ou au four, deux fois par semaine ou plus (sardines, maquereau).',
        aeb: 'بلا سكر. مشوي ولا في الفور، مرتين في الجمعة ولا أكثر (سردينة، مكرو).',
        ar: 'دون سكريات. مشوي أو في الفرن، مرتين في الأسبوع أو أكثر (سردين، إسقمري).',
        en: 'No carbohydrate. Grilled or baked, twice a week or more (sardines, mackerel).'),
    aliases: ['hout', 'sardine', 'thon'],
  ),
  Food(
    id: 'chicken',
    // USDA: Chicken, broilers or fryers, breast, meat only, cooked, roasted: 0 g/100 g.
    name: L('Poulet', aeb: 'دجاج', ar: 'الدجاج', en: 'Chicken'),
    portion: L('1 part (120 g)', aeb: 'حصّة (120 غ)', ar: 'حصة (120 غ)', en: '1 serving (120 g)'),
    grams: 120,
    carbs: 0,
    level: FoodLevel.free,
    swap: L('Sans glucides. Sans la peau, grillé ou en sauce légère.',
        aeb: 'بلا سكر. بلا جلدة، مشوي ولا بصلصة خفيفة.',
        ar: 'دون سكريات. دون الجلد، مشوي أو بصلصة خفيفة.',
        en: 'No carbohydrate. Without the skin, grilled or in a light sauce.'),
    aliases: ['djej', 'dajaj', 'volaille'],
  ),
  // ---------------------------------------------------------------- dairy, fats
  Food(
    id: 'milk',
    // USDA: Milk, lowfat, fluid, 1% milkfat: 5.0 g/100 g.
    name: L('Lait', aeb: 'حليب', ar: 'الحليب', en: 'Milk'),
    portion: L('1 verre (200 mL)', aeb: 'كاس (200 مل)', ar: 'كوب (200 مل)', en: '1 glass (200 mL)'),
    grams: 200,
    carbs: 10,
    level: FoodLevel.measured,
    swap: L('Demi-écrémé, sans sucre ajouté. Il contient du sucre naturel (lactose).',
        aeb: 'نص دسم، بلا سكر. فيه سكر طبيعي (لاكتوز).',
        ar: 'نصف دسم ودون سكر مضاف. فيه سكر طبيعي (اللاكتوز).',
        en: 'Semi-skimmed, with no added sugar. It contains natural sugar (lactose).'),
    aliases: ['halib', 'lben'],
  ),
  Food(
    id: 'yogurt',
    // USDA: Yogurt, plain, whole milk: 4.7 g/100 g.
    name: L('Yaourt nature', aeb: 'ياغورت', ar: 'الزبادي', en: 'Plain yogurt'),
    portion: L('1 pot (125 g)', aeb: 'علبة (125 غ)', ar: 'علبة (125 غ)', en: '1 pot (125 g)'),
    grams: 125,
    carbs: 6,
    level: FoodLevel.free,
    swap: L('Nature plutôt que sucré ou aux fruits (qui en contient 2 à 3 fois plus).',
        aeb: 'طبيعي خير من المسكّر ولا بالغلة (فيه 2 ولا 3 مرات أكثر).',
        ar: 'الطبيعي أفضل من المحلى أو بالفواكه (فيه ضعفان إلى ثلاثة أضعاف).',
        en: 'Plain rather than sweetened or fruit yogurt (which has 2 to 3 times more).'),
    aliases: ['yaourt', 'yoghourt', 'rayeb'],
  ),
  Food(
    id: 'cheese',
    // USDA: Cheese, mozzarella, whole milk: 2.2 g/100 g.
    name: L('Fromage', aeb: 'فرماج', ar: 'الجبن', en: 'Cheese'),
    portion: L('1 morceau (30 g)', aeb: 'طرف (30 غ)', ar: 'قطعة (30 غ)', en: '1 piece (30 g)'),
    grams: 30,
    carbs: 1,
    level: FoodLevel.measured,
    swap: L('Peu de glucides, mais du sel et du gras : un morceau par jour.',
        aeb: 'فيه شوية سكر، أما فيه ملح وشحم: طرف في النهار.',
        ar: 'قليل السكريات لكنه غني بالملح والدهون: قطعة في اليوم.',
        en: 'Little carbohydrate, but salt and fat: one piece a day.'),
    aliases: ['fromaj', 'jben', 'ricotta'],
  ),
  Food(
    id: 'olive_oil',
    // USDA: Oil, olive, salad or cooking: 0 g/100 g.
    name: L('Huile d’olive', aeb: 'زيت زيتونة', ar: 'زيت الزيتون', en: 'Olive oil'),
    portion: L('1 cuillère à soupe (10 g)', aeb: 'مغرفة كبيرة (10 غ)', ar: 'ملعقة كبيرة (10 غ)', en: '1 tablespoon (10 g)'),
    grams: 10,
    carbs: 0,
    level: FoodLevel.measured,
    swap: L('La meilleure graisse, mais très riche en calories : mesurez à la cuillère.',
        aeb: 'أحسن دهن، أما فيه برشا كالوري: قيس بالمغرفة.',
        ar: 'أفضل دهون، لكنها غنية جدًا بالسعرات: قِس بالملعقة.',
        en: 'The best fat, but very rich in calories: measure it by the spoon.'),
    aliases: ['huile', 'zit', 'zitouna'],
  ),
  // ---------------------------------------------------------------- fruits
  Food(
    id: 'dates',
    // USDA: Dates, deglet noor: 75.0 g/100 g. One date ≈ 7 g.
    name: L('Dattes (deglet nour)', aeb: 'دقلة نور', ar: 'تمر دقلة النور', en: 'Dates (deglet nour)'),
    portion: L('3 dattes (21 g)', aeb: '3 تمرات (21 غ)', ar: '3 تمرات (21 غ)', en: '3 dates (21 g)'),
    grams: 21,
    carbs: 16,
    level: FoodLevel.measured,
    swap: L('Très sucrées : 2 ou 3, pas plus, de préférence avec des amandes ou un verre de lait.',
        aeb: 'حلوة برشا: 2 ولا 3، موش أكثر، خير مع لوز ولا كاس حليب.',
        ar: 'حلوة جدًا: 2 أو 3 لا أكثر، ويفضل مع اللوز أو كوب حليب.',
        en: 'Very sweet: 2 or 3, no more, ideally with almonds or a glass of milk.'),
    aliases: ['tmar', 'deglet', 'datte'],
  ),
  Food(
    id: 'figs',
    // USDA: Figs, raw: 19.2 g/100 g.
    name: L('Figues fraîches', aeb: 'كرموس', ar: 'التين الطازج', en: 'Fresh figs'),
    portion: L('2 figues (100 g)', aeb: 'زوز كرموسات (100 غ)', ar: 'تينتان (100 غ)', en: '2 figs (100 g)'),
    grams: 100,
    carbs: 19,
    level: FoodLevel.measured,
    swap: L('Deux fraîches font un fruit. Les figues sèches sont bien plus sucrées : une seule.',
        aeb: 'زوز طريين يساويو غلة. الكرموس الشايح أحلى برشا: وحدة برك.',
        ar: 'تينتان طازجتان تعادلان حصة فاكهة. التين المجفف أحلى بكثير: واحدة فقط.',
        en: 'Two fresh ones make one fruit. Dried figs are much sweeter: just one.'),
    aliases: ['karmous', 'figue'],
  ),
  Food(
    id: 'grapes',
    // USDA: Grapes, red or green (European type, such as Thompson seedless), raw: 18.1 g/100 g.
    name: L('Raisin', aeb: 'عنب', ar: 'العنب', en: 'Grapes'),
    portion: L('1 petite grappe (100 g)', aeb: 'عنقود صغير (100 غ)', ar: 'عنقود صغير (100 غ)', en: '1 small bunch (100 g)'),
    grams: 100,
    carbs: 18,
    level: FoodLevel.measured,
    swap: L('Une petite grappe, après le repas plutôt que seule.',
        aeb: 'عنقود صغير، بعد الماكلة خير من وحدو.',
        ar: 'عنقود صغير، بعد الوجبة أفضل من تناوله وحده.',
        en: 'A small bunch, after a meal rather than on its own.'),
    aliases: ['aneb', 'raisins'],
  ),
  Food(
    id: 'watermelon',
    // USDA: Watermelon, raw: 7.55 g/100 g.
    name: L('Pastèque', aeb: 'دلاع', ar: 'البطيخ الأحمر', en: 'Watermelon'),
    portion: L('1 tranche (250 g)', aeb: 'طرف (250 غ)', ar: 'شريحة (250 غ)', en: '1 slice (250 g)'),
    grams: 250,
    carbs: 19,
    level: FoodLevel.measured,
    swap: L('Pleine d’eau, mais elle fait monter vite la glycémie : une tranche, pas la moitié du fruit.',
        aeb: 'فيه برشا ماء، أما يطلّع السكر بالخف: طرف برك، موش نص دلاعة.',
        ar: 'غني بالماء لكنه يرفع السكر بسرعة: شريحة واحدة لا نصف البطيخة.',
        en: 'Full of water, but it raises blood sugar fast: one slice, not half the fruit.'),
    aliases: ['dellaa', 'dala', 'pasteque'],
  ),
  Food(
    id: 'melon',
    // USDA: Melons, cantaloupe, raw: 8.16 g/100 g.
    name: L('Melon', aeb: 'بطيخ', ar: 'الشمام', en: 'Melon'),
    portion: L('1 tranche (200 g)', aeb: 'طرف (200 غ)', ar: 'شريحة (200 غ)', en: '1 slice (200 g)'),
    grams: 200,
    carbs: 16,
    level: FoodLevel.measured,
    swap: L('Une tranche comme dessert, c’est un fruit.',
        aeb: 'طرف في الديسار، يتحسب غلة.',
        ar: 'شريحة كتحلية تعادل حصة فاكهة.',
        en: 'One slice as dessert counts as a fruit.'),
    aliases: ['batikh'],
  ),
  Food(
    id: 'orange',
    // USDA: Oranges, raw, all commercial varieties: 11.8 g/100 g. Medium orange ≈ 130 g.
    name: L('Orange', aeb: 'برتقال', ar: 'البرتقال', en: 'Orange'),
    portion: L('1 orange moyenne (130 g)', aeb: 'برتقالة متوسطة (130 غ)', ar: 'برتقالة متوسطة (130 غ)', en: '1 medium orange (130 g)'),
    grams: 130,
    carbs: 15,
    level: FoodLevel.measured,
    swap: L('Mangez le fruit entier plutôt que le jus : les fibres ralentissent le sucre.',
        aeb: 'كول البرتقالة كاملة خير من العصير: الألياف يبطّؤو السكر.',
        ar: 'تناول الثمرة كاملة بدل العصير: الألياف تبطئ السكر.',
        en: 'Eat the whole fruit rather than juice: the fibre slows the sugar down.'),
    aliases: ['bordgan', 'burtugal', 'clementine'],
  ),
  // ---------------------------------------------------------------- drinks
  Food(
    id: 'fruit_juice',
    // USDA: Orange juice, raw: 10.4 g/100 g.
    name: L('Jus de fruits', aeb: 'عصير غلال', ar: 'عصير الفواكه', en: 'Fruit juice'),
    portion: L('1 verre (200 mL)', aeb: 'كاس (200 مل)', ar: 'كوب (200 مل)', en: '1 glass (200 mL)'),
    grams: 200,
    carbs: 21,
    level: FoodLevel.rarely,
    swap: L('Même « 100 % pur jus », c’est du sucre rapide. Mieux : le fruit entier et de l’eau. Utile seulement en cas d’hypoglycémie.',
        aeb: 'حتى «عصير طبيعي 100 %» هو سكر سريع. خير: الغلة كاملة والماء. ينفع كان كي يطيح السكر.',
        ar: 'حتى العصير الطبيعي 100 % سكر سريع. الأفضل: الفاكهة كاملة والماء. مفيد فقط عند هبوط السكر.',
        en: 'Even 100 % pure juice is fast sugar. Better: the whole fruit and water. Useful only for a low.'),
    aliases: ['jus', 'aasir', 'citronnade'],
  ),
  Food(
    id: 'soda',
    // USDA: Beverages, carbonated, cola, contains caffeine: 10.6 g/100 g. Can of 330 mL.
    name: L('Boissons gazeuses', aeb: 'قازوز', ar: 'المشروبات الغازية', en: 'Fizzy drinks'),
    portion: L('1 canette (330 mL)', aeb: 'كانات (330 مل)', ar: 'علبة (330 مل)', en: '1 can (330 mL)'),
    grams: 330,
    carbs: 35,
    level: FoodLevel.rarely,
    swap: L('Environ 7 morceaux de sucre par canette. Mieux : de l’eau, de l’eau gazeuse avec du citron.',
        aeb: 'تقريب 7 طوابع سكر في الكانات. خير: الماء، ولا ماء غازية بالقارص.',
        ar: 'نحو 7 قطع سكر في العلبة. الأفضل: الماء أو الماء الفوار بالليمون.',
        en: 'About 7 sugar cubes per can. Better: water, or sparkling water with lemon.'),
    aliases: ['soda', 'coca', 'gazouz', 'boisson'],
  ),
  Food(
    id: 'mint_tea',
    // USDA: Sugars, granulated: 100 g/100 g. A small glass with two teaspoons of sugar ≈ 10 g.
    name: L('Thé à la menthe sucré', aeb: 'تاي بالنعناع بالسكر', ar: 'الشاي بالنعناع المحلى', en: 'Sweet mint tea'),
    portion: L('1 petit verre (2 cuillères de sucre)', aeb: 'كاس صغير (زوز مغارف سكر)', ar: 'كوب صغير (ملعقتا سكر)', en: '1 small glass (2 teaspoons of sugar)'),
    grams: 100,
    carbs: 10,
    level: FoodLevel.rarely,
    swap: L('Réduisez le sucre peu à peu, jusqu’à une demi-cuillère ou sans sucre. Le thé lui-même n’a pas de glucides.',
        aeb: 'نقّص السكر شوية بشوية، لين نص مغرفة ولا بلا سكر. التاي وحدو ما فيهش سكر.',
        ar: 'قلّل السكر تدريجيًا حتى نصف ملعقة أو دون سكر. الشاي نفسه لا يحتوي سكريات.',
        en: 'Cut the sugar down little by little, to half a spoon or none. Tea itself has no carbohydrate.'),
    aliases: ['the', 'tay', 'chay', 'the vert'],
  ),
  Food(
    id: 'coffee',
    // USDA: Beverages, coffee, brewed, prepared with tap water: 0 g/100 g.
    name: L('Café', aeb: 'قهوة', ar: 'القهوة', en: 'Coffee'),
    portion: L('1 tasse sans sucre', aeb: 'فنجان بلا سكر', ar: 'فنجان دون سكر', en: '1 cup without sugar'),
    grams: 100,
    carbs: 0,
    level: FoodLevel.free,
    swap: L('Sans sucre, pas de glucides. Chaque cuillère de sucre ajoute 5 g.',
        aeb: 'بلا سكر، ما فيهاش سكريات. كل مغرفة سكر تزيد 5 غ.',
        ar: 'دون سكر لا تحتوي سكريات. كل ملعقة سكر تضيف 5 غ.',
        en: 'Without sugar, no carbohydrate. Each spoon of sugar adds 5 g.'),
    aliases: ['kahwa', 'express', 'capucin'],
  ),
  // ---------------------------------------------------------------- vegetables
  Food(
    id: 'salad',
    // USDA: Tomatoes, red, ripe, raw: 3.9 g/100 g; Cucumber, with peel, raw: 3.6 g/100 g.
    name: L('Salade tunisienne', aeb: 'سلاطة تونسية', ar: 'السلطة التونسية', en: 'Tunisian salad'),
    portion: L('1 assiette (200 g)', aeb: 'صحفة (200 غ)', ar: 'صحن (200 غ)', en: '1 plate (200 g)'),
    grams: 200,
    carbs: 8,
    level: FoodLevel.free,
    swap: L('La moitié de l’assiette : à volonté, avec une cuillère d’huile d’olive.',
        aeb: 'نص الصحفة: كول قد ما تحب، بمغرفة زيت زيتونة.',
        ar: 'نصف الصحن: بلا حدود، مع ملعقة زيت زيتون.',
        en: 'Half the plate: as much as you like, with one spoon of olive oil.'),
    aliases: ['slata', 'salade', 'tomate', 'concombre'],
  ),
  Food(
    id: 'mechouia',
    // USDA: Peppers, sweet, green, cooked: 6.7 g/100 g; Tomatoes, red, ripe, cooked: 4.0 g/100 g.
    name: L('Slata mechouia', aeb: 'سلاطة مشوية', ar: 'السلطة المشوية', en: 'Grilled pepper salad (mechouia)'),
    portion: L('1 assiette (150 g)', aeb: 'صحفة (150 غ)', ar: 'صحن (150 غ)', en: '1 plate (150 g)'),
    grams: 150,
    carbs: 8,
    level: FoodLevel.free,
    swap: L('Légumes grillés : à volonté. Attention seulement à la quantité d’huile.',
        aeb: 'خضرة مشوية: كول قد ما تحب. رد بالك كان من الزيت.',
        ar: 'خضار مشوية: بلا حدود. انتبه فقط لكمية الزيت.',
        en: 'Grilled vegetables: as much as you like. Just watch the oil.'),
    aliases: ['mechouia', 'mechwiya', 'salade mechouia'],
  ),
  // ---------------------------------------------------------------- sweets
  Food(
    id: 'makroudh',
    // Estimate from the recipe (semolina, date paste, fried, dipped in syrup): about 60 g/100 g; one piece ≈ 40 g.
    name: L('Makroudh', aeb: 'مقروض', ar: 'المقروض', en: 'Makroudh'),
    portion: L('1 pièce (40 g)', aeb: 'حبة (40 غ)', ar: 'قطعة (40 غ)', en: '1 piece (40 g)'),
    grams: 40,
    carbs: 24,
    level: FoodLevel.rarely,
    swap: L('Une pièce, lors d’une fête, à la fin du repas plutôt qu’entre les repas.',
        aeb: 'حبة وحدة، في مناسبة، في آخر الماكلة خير من بين الماكلات.',
        ar: 'قطعة واحدة في المناسبات، في آخر الوجبة لا بين الوجبات.',
        en: 'One piece, at a celebration, at the end of a meal rather than between meals.'),
    aliases: ['makroud', 'maqrouth'],
  ),
  Food(
    id: 'baklawa',
    // USDA (FNDDS): Baklava: about 37 g/100 g; one Tunisian piece ≈ 40 g.
    name: L('Baklawa', aeb: 'بقلاوة', ar: 'البقلاوة', en: 'Baklawa'),
    portion: L('1 pièce (40 g)', aeb: 'حبة (40 غ)', ar: 'قطعة (40 غ)', en: '1 piece (40 g)'),
    grams: 40,
    carbs: 15,
    level: FoodLevel.rarely,
    swap: L('Une petite pièce, rarement. Une poignée d’amandes nature fait un meilleur plaisir.',
        aeb: 'حبة صغيرة، مرة مرة. شوية لوز طبيعي خير.',
        ar: 'قطعة صغيرة نادرًا. حفنة لوز طبيعي خيار أفضل.',
        en: 'One small piece, rarely. A handful of plain almonds is a better treat.'),
    aliases: ['baklava', 'baqlawa'],
  ),
  Food(
    id: 'bambalouni',
    // USDA: Doughnuts, yeast-leavened, glazed, enriched: 44.3 g/100 g; one bambalouni ≈ 80 g.
    name: L('Bambalouni', aeb: 'بمبالوني', ar: 'البمبالوني', en: 'Bambalouni (doughnut)'),
    portion: L('1 bambalouni (80 g)', aeb: 'بمبالوني واحد (80 غ)', ar: 'بمبالوني واحد (80 غ)', en: '1 bambalouni (80 g)'),
    grams: 80,
    carbs: 35,
    level: FoodLevel.rarely,
    swap: L('Frit et sucré : rarement, sans le sucre dessus, et à partager.',
        aeb: 'مقلي ومسكّر: مرة مرة، بلا السكر اللي فوقو، وقسّمو.',
        ar: 'مقلي ومحلى: نادرًا، دون السكر فوقه، وتقاسمه.',
        en: 'Fried and sweet: rarely, without the sugar on top, and shared.'),
    aliases: ['bambaloni', 'beignet'],
  ),
  Food(
    id: 'zlabia',
    // Estimate from the recipe (fried batter soaked in syrup): about 65 g/100 g; one piece ≈ 30 g.
    name: L('Zlabia', aeb: 'زلابية', ar: 'الزلابية', en: 'Zlabia'),
    portion: L('1 pièce (30 g)', aeb: 'حبة (30 غ)', ar: 'قطعة (30 غ)', en: '1 piece (30 g)'),
    grams: 30,
    carbs: 20,
    level: FoodLevel.rarely,
    swap: L('Du sirop de sucre presque pur : une seule pièce, pas tous les soirs de Ramadan.',
        aeb: 'تقريب سكر صافي: حبة وحدة، موش كل ليلة في رمضان.',
        ar: 'شبه شراب سكر خالص: قطعة واحدة، لا كل ليلة في رمضان.',
        en: 'Almost pure sugar syrup: a single piece, not every night of Ramadan.'),
    aliases: ['zlebia', 'zalabia'],
  ),
  Food(
    id: 'mkharek',
    // Estimate from the recipe (fried dough dipped in honey or syrup): about 60 g/100 g; one piece ≈ 25 g.
    name: L('Mkharek', aeb: 'مخارق', ar: 'المخارق', en: 'Mkharek'),
    portion: L('1 pièce (25 g)', aeb: 'حبة (25 غ)', ar: 'قطعة (25 غ)', en: '1 piece (25 g)'),
    grams: 25,
    carbs: 15,
    level: FoodLevel.rarely,
    swap: L('Une pièce, rarement, après un repas.',
        aeb: 'حبة وحدة، مرة مرة، بعد الماكلة.',
        ar: 'قطعة واحدة نادرًا، بعد وجبة.',
        en: 'One piece, rarely, after a meal.'),
    aliases: ['mkhareq', 'makhareq'],
  ),
  Food(
    id: 'samsa',
    // Estimate from the recipe (malsouka, almonds, syrup): about 50 g/100 g; one piece ≈ 30 g.
    name: L('Samsa', aeb: 'صمصة', ar: 'الصمصة', en: 'Samsa'),
    portion: L('1 pièce (30 g)', aeb: 'حبة (30 غ)', ar: 'قطعة (30 غ)', en: '1 piece (30 g)'),
    grams: 30,
    carbs: 15,
    level: FoodLevel.rarely,
    swap: L('Une pièce, rarement. Les amandes sont bonnes, le sirop non.',
        aeb: 'حبة، مرة مرة. اللوز باهي، الشحور لا.',
        ar: 'قطعة نادرًا. اللوز جيد، أما الشراب فلا.',
        en: 'One piece, rarely. The almonds are good, the syrup is not.'),
    aliases: ['samssa'],
  ),
  Food(
    id: 'ghraiba',
    // USDA: Cookies, shortbread, commercially prepared, plain: 64.5 g/100 g; one piece ≈ 25 g.
    name: L('Ghraïba', aeb: 'غريبة', ar: 'الغريبة', en: 'Ghraiba (shortbread)'),
    portion: L('1 pièce (25 g)', aeb: 'حبة (25 غ)', ar: 'قطعة (25 غ)', en: '1 piece (25 g)'),
    grams: 25,
    carbs: 16,
    level: FoodLevel.rarely,
    swap: L('Une pièce avec le thé, pas le plateau.',
        aeb: 'حبة مع التاي، موش الصينية الكل.',
        ar: 'قطعة مع الشاي، لا الصينية كلها.',
        en: 'One piece with tea, not the whole tray.'),
    aliases: ['ghriba', 'ghraiba', 'ghoriba'],
  ),
  Food(
    id: 'kaak_warka',
    // Estimate from the recipe (almond paste with sugar in a thin dough): about 60 g/100 g; one piece ≈ 30 g.
    name: L('Kaak warka', aeb: 'كعك ورقة', ar: 'كعك الورقة', en: 'Kaak warka'),
    portion: L('1 pièce (30 g)', aeb: 'حبة (30 غ)', ar: 'قطعة (30 غ)', en: '1 piece (30 g)'),
    grams: 30,
    carbs: 18,
    level: FoodLevel.rarely,
    swap: L('Une pièce, pour les fêtes.',
        aeb: 'حبة وحدة، في المناسبات.',
        ar: 'قطعة واحدة في المناسبات.',
        en: 'One piece, for celebrations.'),
    aliases: ['kaak', 'kaak warqa'],
  ),
  Food(
    id: 'bouza',
    // Estimate from the recipe (sorghum or hazelnut cream with sugar and milk): about 25 g/100 g; small cup ≈ 120 g.
    name: L('Bouza', aeb: 'بوزة', ar: 'البوزة', en: 'Bouza (sorghum cream)'),
    portion: L('1 petite coupe (120 g)', aeb: 'كاس صغير (120 غ)', ar: 'كأس صغيرة (120 غ)', en: '1 small cup (120 g)'),
    grams: 120,
    carbs: 30,
    level: FoodLevel.rarely,
    swap: L('Une petite coupe, rarement. Le yaourt nature avec quelques noisettes est une meilleure idée.',
        aeb: 'كاس صغير، مرة مرة. ياغورت طبيعي مع شوية بندق خير.',
        ar: 'كأس صغيرة نادرًا. الزبادي الطبيعي مع بعض البندق أفضل.',
        en: 'A small cup, rarely. Plain yogurt with a few hazelnuts is a better idea.'),
    aliases: ['bouza sorgho', 'bouza noisette'],
  ),
  Food(
    id: 'halwa',
    // USDA (FNDDS): Halvah, plain: about 60 g/100 g; portion ≈ 30 g.
    name: L('Halwa chamia', aeb: 'حلوى شامية', ar: 'الحلوى الشامية', en: 'Halva'),
    portion: L('1 petit morceau (30 g)', aeb: 'طرف صغير (30 غ)', ar: 'قطعة صغيرة (30 غ)', en: '1 small piece (30 g)'),
    grams: 30,
    carbs: 18,
    level: FoodLevel.rarely,
    swap: L('Sucrée et grasse : un petit morceau, rarement. Mieux : un peu de tahini sur du pain complet.',
        aeb: 'حلوة وفيها شحم: طرف صغير، مرة مرة. خير: شوية طحينة على خبز كامل.',
        ar: 'حلوة ودسمة: قطعة صغيرة نادرًا. الأفضل: قليل من الطحينة على خبز كامل.',
        en: 'Sweet and fatty: a small piece, rarely. Better: a little tahini on wholemeal bread.'),
    aliases: ['halwa', 'halva', 'halawa'],
  ),
  Food(
    id: 'honey',
    // USDA: Honey: 82.4 g/100 g; one tablespoon ≈ 21 g.
    name: L('Miel', aeb: 'عسل', ar: 'العسل', en: 'Honey'),
    portion: L('1 cuillère à soupe (21 g)', aeb: 'مغرفة كبيرة (21 غ)', ar: 'ملعقة كبيرة (21 غ)', en: '1 tablespoon (21 g)'),
    grams: 21,
    carbs: 17,
    level: FoodLevel.rarely,
    swap: L('Le miel est du sucre, comme le sucre blanc : une petite cuillère au plus. Utile en cas d’hypoglycémie.',
        aeb: 'العسل سكر كيف السكر الأبيض: مغرفة صغيرة أكثر حاجة. ينفع كي يطيح السكر.',
        ar: 'العسل سكر مثل السكر الأبيض: ملعقة صغيرة على الأكثر. مفيد عند هبوط السكر.',
        en: 'Honey is sugar, like white sugar: one teaspoon at most. Useful for a low.'),
    aliases: ['assel', 'asal'],
  ),
  Food(
    id: 'jam',
    // USDA: Jams and preserves: 68.9 g/100 g; one tablespoon ≈ 20 g.
    name: L('Confiture', aeb: 'معجون', ar: 'المربى', en: 'Jam'),
    portion: L('1 cuillère à soupe (20 g)', aeb: 'مغرفة كبيرة (20 غ)', ar: 'ملعقة كبيرة (20 غ)', en: '1 tablespoon (20 g)'),
    grams: 20,
    carbs: 14,
    level: FoodLevel.rarely,
    swap: L('Une fine couche. Mieux : du fromage frais ou un œuf au petit-déjeuner.',
        aeb: 'شوية برك. خير: فرماج طري ولا عظمة في فطور الصباح.',
        ar: 'طبقة رقيقة. الأفضل: جبن طري أو بيضة في الفطور.',
        en: 'A thin layer. Better: fresh cheese or an egg at breakfast.'),
    aliases: ['confiture', 'maajoun', 'konfitir'],
  ),
];
