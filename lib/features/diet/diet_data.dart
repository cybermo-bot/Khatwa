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

  /// The portion without scales: a hand size, spoons or a count.
  final L? hand;

  /// For foods one counts (dates, fruits, pieces): how many make a portion,
  /// and the word for one and for several.
  final int? count;
  final L? one;
  final L? many;

  const Food({
    required this.id,
    required this.name,
    required this.portion,
    required this.grams,
    required this.carbs,
    required this.level,
    required this.swap,
    this.aliases = const [],
    this.hand,
    this.count,
    this.one,
    this.many,
  });

  /// Carbohydrate for a number of portions, rounded to the gram.
  int carbsFor(double portions) => (carbs * portions).round();

  /// "6 dattes" for a number of portions (to the half), or null when the food
  /// is not counted. Arabic keeps the singular from 11 on, as in "15 حبة".
  String? countFor(double portions) {
    final c = count;
    if (c == null || one == null || many == null) return null;
    final n = (c * portions * 2).round() / 2;
    final whole = n == n.roundToDouble();
    final shown = whole ? '${n.round()}' : n.toStringAsFixed(1).replaceAll('.', ',');
    final arabic = langCode() == 'ar' || langCode() == 'aeb';
    final singular = n <= 1 || (arabic && whole && n >= 11);
    return '$shown ${(singular ? one! : many!).text}';
  }
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
    hand: L('Grand comme la paume de votre main', aeb: 'قد كف يدك', ar: 'بحجم كف يدك', en: 'The size of your palm'),
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
    hand: L('Un morceau long comme votre main', aeb: 'طرف طولو قد يدك', ar: 'قطعة بطول يدك', en: 'A piece as long as your hand'),
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
    hand: L('Chaque tranche : la paume de votre main', aeb: 'كل طرف قد كف يدك', ar: 'كل شريحة بحجم كف يدك', en: 'Each slice: the size of your palm'),
    count: 2,
    one: L('tranche', aeb: 'طرف', ar: 'شريحة', en: 'slice'),
    many: L('tranches', aeb: 'طرفات', ar: 'شرائح', en: 'slices'),
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
    hand: L('La taille de votre poing fermé, environ 5 cuillères à soupe', aeb: 'قد قبضة يدك، قريب 5 مغارف كبار', ar: 'بحجم قبضة يدك، نحو 5 ملاعق كبيرة', en: 'The size of your fist, about 5 tablespoons'),
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
    hand: L('La taille de votre poing fermé, environ 5 cuillères à soupe', aeb: 'قد قبضة يدك، قريب 5 مغارف كبار', ar: 'بحجم قبضة يدك، نحو 5 ملاعق كبيرة', en: 'The size of your fist, about 5 tablespoons'),
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
    hand: L('La taille de votre poing fermé, environ 5 cuillères à soupe', aeb: 'قد قبضة يدك، قريب 5 مغارف كبار', ar: 'بحجم قبضة يدك، نحو 5 ملاعق كبيرة', en: 'The size of your fist, about 5 tablespoons'),
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
    hand: L('Un bol comme vos deux mains en creux', aeb: 'زلافة قد يديك الزوز ملمومين', ar: 'وعاء بحجم كفّيك مضمومتين', en: 'A bowl the size of your two cupped hands'),
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
    hand: L('Un bol moyen', aeb: 'زلافة متوسطة', ar: 'وعاء متوسط', en: 'A medium bowl'),
  ),
  Food(
    id: 'brik',
    // Estimate: one malsouka sheet of 25 g (USDA Phyllo dough: 52.6 g/100 g), egg and tuna.
    name: L('Brik', aeb: 'بريك', ar: 'البريك', en: 'Brik'),
    portion: L('1 brik', aeb: 'بريكة وحدة', ar: 'بريكة واحدة', en: '1 brik'),
    grams: 90,
    carbs: 14,
    level: FoodLevel.rarely,
    swap: L('Frite : une seule, bien égouttée, pour le plaisir. L’œuf et le thon avec une salade font aussi un bon repas.', aeb: 'مقلية: وحدة، مصفّية مليح، للبنّة. العظم والتن مع سلاطة ماكلة باهية زادة.', ar: 'مقلية: واحدة مصفّاة جيدًا للمتعة. البيض والتونة مع سلطة وجبة جيدة أيضًا.', en: 'Fried: just one, well drained, for pleasure. Egg and tuna with a salad also make a good meal.'),
    aliases: ['brick', 'brik a l oeuf'],
    hand: L('Une seule, grande comme votre main', aeb: 'وحدة، قد يدك', ar: 'واحدة بحجم يدك', en: 'One, the size of your hand'),
    count: 1,
    one: L('brik', aeb: 'بريكة', ar: 'بريكة', en: 'brik'),
    many: L('briks', aeb: 'بريكات', ar: 'بريكات', en: 'briks'),
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
    swap: L('Pain frit : un seul, de temps en temps. Un sandwich de pain complet au thon et aux légumes est une bonne alternative.', aeb: 'خبز مقلي: واحد، من وقت لوقت. كسكروت خبز كامل بالتن والخضرة بديل باهي.', ar: 'خبز مقلي: واحد من حين لآخر. شطيرة خبز كامل بالتونة والخضار بديل جيد.', en: 'Fried bread: one, now and then. A wholemeal sandwich with tuna and vegetables is a good alternative.'),
    aliases: ['fricasse', 'friccassee'],
    hand: L('Un seul, petit comme votre poing', aeb: 'واحد صغير قد قبضة يدك', ar: 'واحد صغير بحجم قبضة يدك', en: 'One small one, the size of your fist'),
  ),
  Food(
    id: 'mlawi',
    // Estimate: about 60 g of flour per mlawi (USDA Wheat flour, white, all-purpose: 76.3 g/100 g), cooked with oil.
    name: L('Mlawi', aeb: 'ملاوي', ar: 'الملاوي', en: 'Mlawi (flatbread)'),
    portion: L('1 mlawi', aeb: 'ملاوي واحد', ar: 'ملاوي واحد', en: '1 mlawi'),
    grams: 100,
    carbs: 46,
    level: FoodLevel.rarely,
    swap: L('Farine blanche et huile : un demi, avec une garniture de légumes et d’œuf.', aeb: 'فارينة بيضاء وزيت: نص، بالخضرة والعظم.', ar: 'دقيق أبيض وزيت: نصف واحد مع حشوة خضار وبيض.', en: 'White flour and oil: half of one, filled with vegetables and egg.'),
    aliases: ['mlaoui', 'malawi'],
    hand: L('Un demi, grand comme votre main', aeb: 'نص، قد يدك', ar: 'نصف واحد بحجم يدك', en: 'Half of one, the size of your hand'),
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
    hand: L('Un demi, grand comme votre main', aeb: 'نص، قد يدك', ar: 'نصف واحد بحجم يدك', en: 'Half of one, the size of your hand'),
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
    hand: L('3 cuillères à soupe', aeb: '3 مغارف كبار', ar: '3 ملاعق كبيرة', en: '3 tablespoons'),
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
    hand: L('La taille de votre poing fermé', aeb: 'قد قبضة يدك', ar: 'بحجم قبضة يدك', en: 'The size of your fist'),
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
    hand: L('La taille de votre poing fermé', aeb: 'قد قبضة يدك', ar: 'بحجم قبضة يدك', en: 'The size of your fist'),
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
    hand: L('4 cuillères à soupe, le creux de votre main', aeb: '4 مغارف كبار، قد كف يدك', ar: '4 ملاعق كبيرة، بحجم راحة يدك', en: '4 tablespoons, one cupped hand'),
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
    hand: L('La taille de votre poing fermé', aeb: 'قد قبضة يدك', ar: 'بحجم قبضة يدك', en: 'The size of your fist'),
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
    hand: L('La taille de votre poing fermé', aeb: 'قد قبضة يدك', ar: 'بحجم قبضة يدك', en: 'The size of your fist'),
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
    hand: L('2 œufs', aeb: 'زوز عظمات', ar: 'بيضتان', en: '2 eggs'),
    count: 2,
    one: L('œuf', aeb: 'عظمة', ar: 'بيضة', en: 'egg'),
    many: L('œufs', aeb: 'عظمات', ar: 'بيضات', en: 'eggs'),
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
    hand: L('La taille et l’épaisseur de la paume de votre main', aeb: 'قد كف يدك في الطول والغلظ', ar: 'بحجم كف يدك وسُمكه', en: 'The size and thickness of your palm'),
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
    hand: L('La taille et l’épaisseur de la paume de votre main', aeb: 'قد كف يدك في الطول والغلظ', ar: 'بحجم كف يدك وسُمكه', en: 'The size and thickness of your palm'),
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
    hand: L('Un verre à eau', aeb: 'كاس ماء', ar: 'كوب ماء', en: 'A water glass'),
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
    hand: L('Un pot', aeb: 'ياغورت واحد', ar: 'علبة واحدة', en: 'One pot'),
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
    hand: L('La taille de vos deux pouces', aeb: 'قد صبعيك الكبار الزوز', ar: 'بحجم إبهاميك', en: 'The size of your two thumbs'),
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
    hand: L('1 cuillère à soupe, la taille de votre pouce', aeb: 'مغرفة كبيرة، قد صبعك الكبير', ar: 'ملعقة كبيرة، بحجم إبهامك', en: '1 tablespoon, the size of your thumb'),
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
    swap: L('Deux ou trois à la fois font une portion. Avec quelques amandes ou un verre de lait, c’est encore mieux.', aeb: 'زوز ولا ثلاثة في المرة هوما كمية. مع شوية لوز ولا كاس حليب خير.', ar: 'تمرتان أو ثلاث في المرة تعادل حصة. مع بعض اللوز أو كوب حليب أفضل.', en: 'Two or three at a time make one portion. With a few almonds or a glass of milk, even better.'),
    aliases: ['tmar', 'deglet', 'datte'],
    hand: L('3 dattes', aeb: '3 تمرات', ar: '3 تمرات', en: '3 dates'),
    count: 3,
    one: L('datte', aeb: 'تمرة', ar: 'تمرة', en: 'date'),
    many: L('dattes', aeb: 'تمرات', ar: 'تمرات', en: 'dates'),
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
    hand: L('2 figues', aeb: 'زوز كرموسات', ar: 'تينتان', en: '2 figs'),
    count: 2,
    one: L('figue', aeb: 'كرموسة', ar: 'تينة', en: 'fig'),
    many: L('figues', aeb: 'كرموسات', ar: 'تينات', en: 'figs'),
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
    hand: L('Environ 15 grains, ce qui tient dans votre main', aeb: 'قريب 15 حبة، اللي يشدّو كفّك', ar: 'نحو 15 حبة، ما يسعه كف يدك', en: 'About 15 grapes, what fits in your hand'),
  ),
  Food(
    id: 'watermelon',
    // USDA: Watermelon, raw: 7.55 g/100 g.
    name: L('Pastèque', aeb: 'دلاع', ar: 'البطيخ الأحمر', en: 'Watermelon'),
    portion: L('1 tranche (250 g)', aeb: 'طرف (250 غ)', ar: 'شريحة (250 غ)', en: '1 slice (250 g)'),
    grams: 250,
    carbs: 19,
    level: FoodLevel.measured,
    swap: L('Rafraîchissante et pleine d’eau : une belle tranche fait une portion. Au repas, elle fait monter le sucre moins vite que seule.', aeb: 'تبرّد وفيها برشا ماء: طرف مزيان هو كمية. مع الماكلة يطلّع السكر بشوية أكثر ملي وحدها.', ar: 'منعشة وغنية بالماء: شريحة جيدة تعادل حصة. مع الوجبة ترفع السكر أبطأ مما لو أُكلت وحدها.', en: 'Refreshing and full of water: a good slice is one portion. With a meal it raises sugar more slowly than on its own.'),
    aliases: ['dellaa', 'dala', 'pasteque'],
    hand: L('Une tranche comme vos deux mains ouvertes', aeb: 'طرف قد يديك الزوز محلولين', ar: 'شريحة بحجم يديك مفتوحتين', en: 'A slice the size of your two open hands'),
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
    hand: L('Une tranche comme votre main ouverte', aeb: 'طرف قد يدك محلولة', ar: 'شريحة بحجم يدك المفتوحة', en: 'A slice the size of your open hand'),
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
    hand: L('1 orange, comme votre poing', aeb: 'برتقالة قد قبضة يدك', ar: 'برتقالة بحجم قبضة يدك', en: '1 orange, the size of your fist'),
    count: 1,
    one: L('orange', aeb: 'برتقالة', ar: 'برتقالة', en: 'orange'),
    many: L('oranges', aeb: 'برتقالات', ar: 'برتقالات', en: 'oranges'),
  ),
  Food(
    id: 'apple',
    // USDA: Apples, raw, with skin: 13.8 g/100 g. A small apple ≈ 130 g.
    name: L('Pomme', aeb: 'تفاح', ar: 'التفاح', en: 'Apple'),
    portion: L('1 petite pomme (130 g)', aeb: 'تفاحة صغيرة (130 غ)', ar: 'تفاحة صغيرة (130 غ)', en: '1 small apple (130 g)'),
    grams: 130,
    carbs: 18,
    level: FoodLevel.measured,
    swap: L('Un bon fruit à croquer, avec la peau bien lavée : ses fibres ralentissent le sucre.', aeb: 'غلة باهية تتقرمش، بقشرتها مغسولة مليح: الألياف يخلّيو السكر يطلع بشوية.', ar: 'فاكهة جيدة تؤكل بقشرها المغسول جيدًا: أليافها تبطئ السكر.', en: 'A good fruit to crunch, with the skin well washed: its fibre slows the sugar.'),
    aliases: ['toffeh', 'tfeh', 'pomme'],
    hand: L('1 pomme, comme votre poing', aeb: 'تفاحة قد قبضة يدك', ar: 'تفاحة بحجم قبضة يدك', en: '1 apple, the size of your fist'),
    count: 1,
    one: L('pomme', aeb: 'تفاحة', ar: 'تفاحة', en: 'apple'),
    many: L('pommes', aeb: 'تفاحات', ar: 'تفاحات', en: 'apples'),
  ),
  Food(
    id: 'pear',
    // USDA: Pears, raw: 15.2 g/100 g. A small pear ≈ 140 g.
    name: L('Poire', aeb: 'إنجاص', ar: 'الإجاص', en: 'Pear'),
    portion: L('1 petite poire (140 g)', aeb: 'إنجاصة صغيرة (140 غ)', ar: 'إجاصة صغيرة (140 غ)', en: '1 small pear (140 g)'),
    grams: 140,
    carbs: 21,
    level: FoodLevel.measured,
    swap: L('Avec la peau, mûre à point : un bon dessert.', aeb: 'بقشرتها، طايبة على قدّها: ديسار باهي.', ar: 'بقشرها وناضجة باعتدال: تحلية جيدة.', en: 'With the skin, just ripe: a good dessert.'),
    aliases: ['inges', 'anjas', 'poire'],
    hand: L('1 poire, comme votre poing', aeb: 'إنجاصة قد قبضة يدك', ar: 'إجاصة بحجم قبضة يدك', en: '1 pear, the size of your fist'),
    count: 1,
    one: L('poire', aeb: 'إنجاصة', ar: 'إجاصة', en: 'pear'),
    many: L('poires', aeb: 'إنجاصات', ar: 'إجاصات', en: 'pears'),
  ),
  Food(
    id: 'banana',
    // USDA: Bananas, raw: 22.8 g/100 g. A small banana ≈ 100 g peeled.
    name: L('Banane', aeb: 'بنان', ar: 'الموز', en: 'Banana'),
    portion: L('1 petite banane (100 g)', aeb: 'بنانة صغيرة (100 غ)', ar: 'موزة صغيرة (100 غ)', en: '1 small banana (100 g)'),
    grams: 100,
    carbs: 23,
    level: FoodLevel.measured,
    swap: L('Plus sucrée que d’autres fruits : une petite fait une portion, un peu verte c’est encore mieux.', aeb: 'أحلى من غلال أخرى: وحدة صغيرة هي كمية، وكي تكون شوية خضراء خير.', ar: 'أحلى من فواكه أخرى: واحدة صغيرة حصة، والأقل نضجًا أفضل.', en: 'Sweeter than some fruits: a small one is a portion, a little green is even better.'),
    aliases: ['banan', 'mouz', 'banane'],
    hand: L('1 petite banane, ou la moitié d’une grande', aeb: 'بنانة صغيرة، ولا نص كبيرة', ar: 'موزة صغيرة أو نصف كبيرة', en: '1 small banana, or half a large one'),
    count: 1,
    one: L('banane', aeb: 'بنانة', ar: 'موزة', en: 'banana'),
    many: L('bananes', aeb: 'بنانات', ar: 'موزات', en: 'bananas'),
  ),
  Food(
    id: 'pomegranate',
    // USDA: Pomegranates, raw: 18.7 g/100 g. Seeds of half a fruit ≈ 100 g.
    name: L('Grenade', aeb: 'رمان', ar: 'الرمان', en: 'Pomegranate'),
    portion: L('Les grains d’½ grenade (100 g)', aeb: 'حب نص رمانة (100 غ)', ar: 'حبوب نصف رمانة (100 غ)', en: 'Seeds of ½ pomegranate (100 g)'),
    grams: 100,
    carbs: 19,
    level: FoodLevel.measured,
    swap: L('Plein de bonnes choses : les grains valent mieux que le jus.', aeb: 'فيه برشا خير: الحب خير من العصير.', ar: 'مليء بالفوائد: الحبوب أفضل من العصير.', en: 'Full of good things: the seeds are better than the juice.'),
    aliases: ['roummen', 'romman', 'grenade'],
    hand: L('Une demi-grenade, ce qui tient dans votre main en creux', aeb: 'نص رمانة، اللي يشدّو كفّك', ar: 'نصف رمانة، ما تسعه راحة يدك', en: 'Half a pomegranate, what fits in your cupped hand'),
  ),
  Food(
    id: 'clementine',
    // USDA: Clementines, raw: 12.0 g/100 g. Two small ones ≈ 150 g.
    name: L('Clémentines', aeb: 'مندارين', ar: 'اليوسفي', en: 'Clementines'),
    portion: L('2 petites clémentines (150 g)', aeb: 'زوز مندارين صغار (150 غ)', ar: 'حبتا يوسفي صغيرتان (150 غ)', en: '2 small clementines (150 g)'),
    grams: 150,
    carbs: 18,
    level: FoodLevel.measured,
    swap: L('Deux petites font une portion. Parfaites en collation l’hiver.', aeb: 'زوز صغار هوما كمية. باهيين بين الماكلات في الشتاء.', ar: 'اثنتان صغيرتان حصة. مثاليتان كوجبة خفيفة في الشتاء.', en: 'Two small ones make a portion. Perfect as a winter snack.'),
    aliases: ['mandarine', 'mandarin', 'clementine', 'youssefi'],
    hand: L('2 clémentines', aeb: 'زوز مندارين', ar: 'حبتا يوسفي', en: '2 clementines'),
    count: 2,
    one: L('clémentine', aeb: 'مندارينة', ar: 'حبة يوسفي', en: 'clementine'),
    many: L('clémentines', aeb: 'مندارينات', ar: 'حبات يوسفي', en: 'clementines'),
  ),
  Food(
    id: 'peach',
    // USDA: Peaches, yellow, raw: 9.5 g/100 g. A medium peach ≈ 150 g.
    name: L('Pêche', aeb: 'خوخ', ar: 'الخوخ', en: 'Peach'),
    portion: L('1 pêche moyenne (150 g)', aeb: 'خوخة متوسطة (150 غ)', ar: 'خوخة متوسطة (150 غ)', en: '1 medium peach (150 g)'),
    grams: 150,
    carbs: 14,
    level: FoodLevel.measured,
    swap: L('Un fruit d’été léger : une pêche moyenne fait une portion.', aeb: 'غلة صيف خفيفة: خوخة متوسطة هي كمية.', ar: 'فاكهة صيفية خفيفة: خوخة متوسطة حصة.', en: 'A light summer fruit: one medium peach is a portion.'),
    aliases: ['khoukh', 'peche'],
    hand: L('1 pêche, comme votre poing', aeb: 'خوخة قد قبضة يدك', ar: 'خوخة بحجم قبضة يدك', en: '1 peach, the size of your fist'),
    count: 1,
    one: L('pêche', aeb: 'خوخة', ar: 'خوخة', en: 'peach'),
    many: L('pêches', aeb: 'خوخات', ar: 'خوخات', en: 'peaches'),
  ),
  Food(
    id: 'apricot',
    // USDA: Apricots, raw: 11.1 g/100 g. One apricot ≈ 35 g.
    name: L('Abricots', aeb: 'مشماش', ar: 'المشمش', en: 'Apricots'),
    portion: L('3 abricots (105 g)', aeb: '3 مشماشات (105 غ)', ar: '3 حبات مشمش (105 غ)', en: '3 apricots (105 g)'),
    grams: 105,
    carbs: 12,
    level: FoodLevel.measured,
    swap: L('Trois frais font une portion. Secs, ils sont bien plus sucrés : deux suffisent.', aeb: 'ثلاثة طريين هوما كمية. الشايح أحلى برشا: زوز يكفيو.', ar: 'ثلاث حبات طازجة حصة. المجفف أحلى بكثير: حبتان تكفيان.', en: 'Three fresh ones make a portion. Dried, they are much sweeter: two are enough.'),
    aliases: ['mechmech', 'abricot'],
    hand: L('3 abricots', aeb: '3 مشماشات', ar: '3 حبات مشمش', en: '3 apricots'),
    count: 3,
    one: L('abricot', aeb: 'مشماشة', ar: 'حبة مشمش', en: 'apricot'),
    many: L('abricots', aeb: 'مشماشات', ar: 'حبات مشمش', en: 'apricots'),
  ),
  Food(
    id: 'plum',
    // USDA: Plums, raw: 11.4 g/100 g. One plum ≈ 65 g.
    name: L('Prunes', aeb: 'عوينة', ar: 'البرقوق', en: 'Plums'),
    portion: L('2 prunes (130 g)', aeb: 'زوز عوينات (130 غ)', ar: 'حبتا برقوق (130 غ)', en: '2 plums (130 g)'),
    grams: 130,
    carbs: 15,
    level: FoodLevel.measured,
    swap: L('Deux font une portion, un bon fruit d’été.', aeb: 'زوز هوما كمية، غلة صيف باهية.', ar: 'حبتان حصة، فاكهة صيفية جيدة.', en: 'Two make a portion, a good summer fruit.'),
    aliases: ['3wina', 'awina', 'prune', 'barkouk'],
    hand: L('2 prunes', aeb: 'زوز عوينات', ar: 'حبتا برقوق', en: '2 plums'),
    count: 2,
    one: L('prune', aeb: 'عوينة', ar: 'حبة برقوق', en: 'plum'),
    many: L('prunes', aeb: 'عوينات', ar: 'حبات برقوق', en: 'plums'),
  ),
  Food(
    id: 'strawberries',
    // USDA: Strawberries, raw: 7.7 g/100 g. Ten strawberries ≈ 150 g.
    name: L('Fraises', aeb: 'فراولو', ar: 'الفراولة', en: 'Strawberries'),
    portion: L('1 bol, environ 10 fraises (150 g)', aeb: 'زلافة، قريب 10 حبات (150 غ)', ar: 'وعاء، نحو 10 حبات (150 غ)', en: '1 bowl, about 10 strawberries (150 g)'),
    grams: 150,
    carbs: 12,
    level: FoodLevel.measured,
    swap: L('Peu sucrées : un bol, sans sucre ajouté, c’est une portion.', aeb: 'موش حلوة برشا: زلافة بلا سكر زايد هي كمية.', ar: 'قليلة السكر: وعاء دون سكر مضاف حصة.', en: 'Not very sweet: a bowl, with no added sugar, is a portion.'),
    aliases: ['fraise', 'fraoula', 'frawla'],
    hand: L('Un bol, environ 10 fraises', aeb: 'زلافة، قريب 10 حبات', ar: 'وعاء، نحو 10 حبات', en: 'A bowl, about 10 strawberries'),
    count: 10,
    one: L('fraise', aeb: 'حبة', ar: 'حبة', en: 'strawberry'),
    many: L('fraises', aeb: 'حبات', ar: 'حبات', en: 'strawberries'),
  ),
  Food(
    id: 'prickly_pear',
    // USDA: Prickly pears, raw: 9.6 g/100 g. One fruit ≈ 100 g peeled.
    name: L('Figues de Barbarie', aeb: 'هندي', ar: 'التين الشوكي', en: 'Prickly pears'),
    portion: L('2 figues de Barbarie (200 g)', aeb: 'زوز هنديات (200 غ)', ar: 'حبتا تين شوكي (200 غ)', en: '2 prickly pears (200 g)'),
    grams: 200,
    carbs: 19,
    level: FoodLevel.measured,
    swap: L('Le fruit de l’été tunisien, riche en fibres : deux à la fois font une portion.', aeb: 'غلة الصيف التونسي، فيها برشا ألياف: زوز في المرة هوما كمية.', ar: 'فاكهة الصيف التونسي الغنية بالألياف: حبتان في المرة حصة.', en: 'The Tunisian summer fruit, rich in fibre: two at a time make a portion.'),
    aliases: ['hindi', 'figue de barbarie', 'karmous hindi'],
    hand: L('2 fruits épluchés', aeb: 'زوز هنديات مقشّرين', ar: 'حبتان مقشرتان', en: '2 peeled fruits'),
    count: 2,
    one: L('figue de Barbarie', aeb: 'هندية', ar: 'حبة تين شوكي', en: 'prickly pear'),
    many: L('figues de Barbarie', aeb: 'هنديات', ar: 'حبات تين شوكي', en: 'prickly pears'),
  ),
  Food(
    id: 'cherries',
    // USDA: Cherries, sweet, raw: 16.0 g/100 g. Fifteen cherries ≈ 100 g.
    name: L('Cerises', aeb: 'حب الملوك', ar: 'الكرز', en: 'Cherries'),
    portion: L('15 cerises (100 g)', aeb: '15 حبة حب ملوك (100 غ)', ar: '15 حبة كرز (100 غ)', en: '15 cherries (100 g)'),
    grams: 100,
    carbs: 16,
    level: FoodLevel.measured,
    swap: L('Une quinzaine font une portion. Servez-les dans un bol : on en mange moins sans compter.', aeb: 'قريب 15 هوما كمية. حطّهم في زلافة: تاكل أقل بلا ما تحسب.', ar: 'نحو 15 حبة حصة. قدّمها في وعاء لتأكل أقل دون عدّ.', en: 'About fifteen make a portion. Serve them in a bowl: you eat fewer without counting.'),
    aliases: ['hab el molouk', 'cerise'],
    hand: L('Une quinzaine, dans un petit bol', aeb: 'قريب 15، في زلافة صغيرة', ar: 'نحو 15 حبة في وعاء صغير', en: 'About 15, in a small bowl'),
    count: 15,
    one: L('cerise', aeb: 'حبة', ar: 'حبة', en: 'cherry'),
    many: L('cerises', aeb: 'حبات', ar: 'حبات', en: 'cherries'),
  ),
  Food(
    id: 'olives',
    // USDA: Olives, ripe, canned: 6.3 g/100 g. Ten olives ≈ 40 g.
    name: L('Olives', aeb: 'زيتون', ar: 'الزيتون', en: 'Olives'),
    portion: L('10 olives (40 g)', aeb: '10 حبات زيتون (40 غ)', ar: '10 حبات زيتون (40 غ)', en: '10 olives (40 g)'),
    grams: 40,
    carbs: 3,
    level: FoodLevel.measured,
    swap: L('Presque sans glucides, mais salées : une dizaine accompagne bien un repas.', aeb: 'تقريب بلا سكريات، أما فيها الملح: قريب 10 يمشيو مع الماكلة.', ar: 'شبه خالية من السكريات لكنها مالحة: نحو عشر حبات ترافق الوجبة جيدًا.', en: 'Almost no carbohydrate, but salty: about ten go well with a meal.'),
    aliases: ['zitoun', 'zaytoun', 'olive'],
    hand: L('Une dizaine', aeb: 'قريب 10 حبات', ar: 'نحو 10 حبات', en: 'About ten'),
    count: 10,
    one: L('olive', aeb: 'حبة', ar: 'حبة', en: 'olive'),
    many: L('olives', aeb: 'حبات', ar: 'حبات', en: 'olives'),
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
    swap: L('Le fruit entier rassasie plus que le jus. Un verre de temps en temps, et le jus est très utile en cas d’hypoglycémie.', aeb: 'الغلة كاملة تشبّع أكثر من العصير. كاس من وقت لوقت، والعصير ينفع برشا كي يطيح السكر.', ar: 'الفاكهة كاملة تشبع أكثر من العصير. كوب من حين لآخر، والعصير مفيد جدًا عند هبوط السكر.', en: 'The whole fruit fills you more than juice. A glass now and then, and juice is very useful for a low.'),
    aliases: ['jus', 'aasir', 'citronnade'],
    hand: L('Un verre à eau', aeb: 'كاس ماء', ar: 'كوب ماء', en: 'A water glass'),
  ),
  Food(
    id: 'soda',
    // USDA: Beverages, carbonated, cola, contains caffeine: 10.6 g/100 g. Can of 330 mL.
    name: L('Boissons gazeuses', aeb: 'قازوز', ar: 'المشروبات الغازية', en: 'Fizzy drinks'),
    portion: L('1 canette (330 mL)', aeb: 'كانات (330 مل)', ar: 'علبة (330 مل)', en: '1 can (330 mL)'),
    grams: 330,
    carbs: 35,
    level: FoodLevel.rarely,
    swap: L('Une canette contient l’équivalent de 7 morceaux de sucre. L’eau gazeuse avec du citron ou de la menthe fait plaisir sans sucre.', aeb: 'الكانات فيها قد 7 طوابع سكر. الماء الغازية بالقارص ولا النعناع تفرّح بلا سكر.', ar: 'العلبة تحتوي ما يعادل 7 قطع سكر. الماء الفوار بالليمون أو النعناع ممتع بلا سكر.', en: 'A can holds the equivalent of 7 sugar cubes. Sparkling water with lemon or mint is a treat without sugar.'),
    aliases: ['soda', 'coca', 'gazouz', 'boisson'],
    hand: L('Une canette', aeb: 'كانات وحدة', ar: 'علبة واحدة', en: 'One can'),
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
    hand: L('Un petit verre à thé', aeb: 'كاس تاي صغير', ar: 'كأس شاي صغير', en: 'A small tea glass'),
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
    hand: L('Une tasse', aeb: 'فنجان', ar: 'فنجان', en: 'One cup'),
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
    hand: L('Deux mains pleines, ou plus', aeb: 'ملو يديك الزوز ولا أكثر', ar: 'ملء اليدين أو أكثر', en: 'Two handfuls, or more'),
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
    hand: L('Deux mains pleines', aeb: 'ملو يديك الزوز', ar: 'ملء اليدين', en: 'Two handfuls'),
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
    hand: L('Une pièce', aeb: 'حبة وحدة', ar: 'قطعة واحدة', en: 'One piece'),
    count: 1,
    one: L('pièce', aeb: 'حبة', ar: 'قطعة', en: 'piece'),
    many: L('pièces', aeb: 'حبات', ar: 'قطع', en: 'pieces'),
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
    hand: L('Une pièce', aeb: 'حبة وحدة', ar: 'قطعة واحدة', en: 'One piece'),
    count: 1,
    one: L('pièce', aeb: 'حبة', ar: 'قطعة', en: 'piece'),
    many: L('pièces', aeb: 'حبات', ar: 'قطع', en: 'pieces'),
  ),
  Food(
    id: 'bambalouni',
    // USDA: Doughnuts, yeast-leavened, glazed, enriched: 44.3 g/100 g; one bambalouni ≈ 80 g.
    name: L('Bambalouni', aeb: 'بمبالوني', ar: 'البمبالوني', en: 'Bambalouni (doughnut)'),
    portion: L('1 bambalouni (80 g)', aeb: 'بمبالوني واحد (80 غ)', ar: 'بمبالوني واحد (80 غ)', en: '1 bambalouni (80 g)'),
    grams: 80,
    carbs: 35,
    level: FoodLevel.rarely,
    swap: L('Frit et sucré : pour le plaisir, sans le sucre dessus, et à partager.', aeb: 'مقلي ومسكّر: للبنّة، بلا السكر اللي فوقو، وقسّمو.', ar: 'مقلي ومحلى: للمتعة، دون السكر فوقه، وتقاسمه.', en: 'Fried and sweet: for pleasure, without the sugar on top, and shared.'),
    aliases: ['bambaloni', 'beignet'],
    hand: L('Un, à partager', aeb: 'واحد، تقسمو', ar: 'واحدة للمشاركة', en: 'One, to share'),
  ),
  Food(
    id: 'zlabia',
    // Estimate from the recipe (fried batter soaked in syrup): about 65 g/100 g; one piece ≈ 30 g.
    name: L('Zlabia', aeb: 'زلابية', ar: 'الزلابية', en: 'Zlabia'),
    portion: L('1 pièce (30 g)', aeb: 'حبة (30 غ)', ar: 'قطعة (30 غ)', en: '1 piece (30 g)'),
    grams: 30,
    carbs: 20,
    level: FoodLevel.rarely,
    swap: L('Très sucrée (sirop) : une pièce pour le plaisir, de temps en temps pendant le Ramadan.', aeb: 'مسكّرة برشا (شحور): حبة للبنّة، من وقت لوقت في رمضان.', ar: 'حلوة جدًا (شراب): قطعة للمتعة، من حين لآخر في رمضان.', en: 'Very sweet (syrup): one piece for pleasure, now and then during Ramadan.'),
    aliases: ['zlebia', 'zalabia'],
    hand: L('Une pièce', aeb: 'حبة وحدة', ar: 'قطعة واحدة', en: 'One piece'),
    count: 1,
    one: L('pièce', aeb: 'حبة', ar: 'قطعة', en: 'piece'),
    many: L('pièces', aeb: 'حبات', ar: 'قطع', en: 'pieces'),
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
    hand: L('Une pièce', aeb: 'حبة وحدة', ar: 'قطعة واحدة', en: 'One piece'),
    count: 1,
    one: L('pièce', aeb: 'حبة', ar: 'قطعة', en: 'piece'),
    many: L('pièces', aeb: 'حبات', ar: 'قطع', en: 'pieces'),
  ),
  Food(
    id: 'samsa',
    // Estimate from the recipe (malsouka, almonds, syrup): about 50 g/100 g; one piece ≈ 30 g.
    name: L('Samsa', aeb: 'صمصة', ar: 'الصمصة', en: 'Samsa'),
    portion: L('1 pièce (30 g)', aeb: 'حبة (30 غ)', ar: 'قطعة (30 غ)', en: '1 piece (30 g)'),
    grams: 30,
    carbs: 15,
    level: FoodLevel.rarely,
    swap: L('Une pièce pour le plaisir. Les amandes sont bonnes ; c’est le sirop qui sucre.', aeb: 'حبة للبنّة. اللوز باهي؛ الشحور هو اللي يسكّر.', ar: 'قطعة للمتعة. اللوز مفيد؛ الشراب هو الذي يُحلّي.', en: 'One piece for pleasure. The almonds are good; the syrup is what makes it sweet.'),
    aliases: ['samssa'],
    hand: L('Une pièce', aeb: 'حبة وحدة', ar: 'قطعة واحدة', en: 'One piece'),
    count: 1,
    one: L('pièce', aeb: 'حبة', ar: 'قطعة', en: 'piece'),
    many: L('pièces', aeb: 'حبات', ar: 'قطع', en: 'pieces'),
  ),
  Food(
    id: 'ghraiba',
    // USDA: Cookies, shortbread, commercially prepared, plain: 64.5 g/100 g; one piece ≈ 25 g.
    name: L('Ghraïba', aeb: 'غريبة', ar: 'الغريبة', en: 'Ghraiba (shortbread)'),
    portion: L('1 pièce (25 g)', aeb: 'حبة (25 غ)', ar: 'قطعة (25 غ)', en: '1 piece (25 g)'),
    grams: 25,
    carbs: 16,
    level: FoodLevel.rarely,
    swap: L('Une pièce avec le thé, pour le plaisir.', aeb: 'حبة مع التاي، للبنّة.', ar: 'قطعة مع الشاي للمتعة.', en: 'One piece with tea, for pleasure.'),
    aliases: ['ghriba', 'ghraiba', 'ghoriba'],
    hand: L('Une pièce', aeb: 'حبة وحدة', ar: 'قطعة واحدة', en: 'One piece'),
    count: 1,
    one: L('pièce', aeb: 'حبة', ar: 'قطعة', en: 'piece'),
    many: L('pièces', aeb: 'حبات', ar: 'قطع', en: 'pieces'),
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
    hand: L('Une pièce', aeb: 'حبة وحدة', ar: 'قطعة واحدة', en: 'One piece'),
    count: 1,
    one: L('pièce', aeb: 'حبة', ar: 'قطعة', en: 'piece'),
    many: L('pièces', aeb: 'حبات', ar: 'قطع', en: 'pieces'),
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
    hand: L('4 cuillères à soupe, une petite coupe', aeb: '4 مغارف كبار', ar: '4 ملاعق كبيرة', en: '4 tablespoons, a small cup'),
  ),
  Food(
    id: 'halwa',
    // USDA (FNDDS): Halvah, plain: about 60 g/100 g; portion ≈ 30 g.
    name: L('Halwa chamia', aeb: 'حلوى شامية', ar: 'الحلوى الشامية', en: 'Halva'),
    portion: L('1 petit morceau (30 g)', aeb: 'طرف صغير (30 غ)', ar: 'قطعة صغيرة (30 غ)', en: '1 small piece (30 g)'),
    grams: 30,
    carbs: 18,
    level: FoodLevel.rarely,
    swap: L('Sucrée et grasse : un petit morceau pour le plaisir. Un peu de tahini sur du pain complet est aussi délicieux.', aeb: 'حلوة وفيها شحم: طرف صغير للبنّة. شوية طحينة على خبز كامل بنينة زادة.', ar: 'حلوة ودسمة: قطعة صغيرة للمتعة. قليل من الطحينة على خبز كامل لذيذ أيضًا.', en: 'Sweet and rich: a small piece for pleasure. A little tahini on wholemeal bread is delicious too.'),
    aliases: ['halwa', 'halva', 'halawa'],
    hand: L('Un morceau de la taille de votre pouce', aeb: 'طرف قد صبعك الكبير', ar: 'قطعة بحجم إبهامك', en: 'A piece the size of your thumb'),
  ),
  Food(
    id: 'honey',
    // USDA: Honey: 82.4 g/100 g; one tablespoon ≈ 21 g.
    name: L('Miel', aeb: 'عسل', ar: 'العسل', en: 'Honey'),
    portion: L('1 cuillère à soupe (21 g)', aeb: 'مغرفة كبيرة (21 غ)', ar: 'ملعقة كبيرة (21 غ)', en: '1 tablespoon (21 g)'),
    grams: 21,
    carbs: 17,
    level: FoodLevel.rarely,
    swap: L('Le miel sucre comme le sucre : une petite cuillère pour le plaisir. Très utile en cas d’hypoglycémie.', aeb: 'العسل يسكّر كيف السكر: مغرفة صغيرة للبنّة. ينفع برشا كي يطيح السكر.', ar: 'العسل يرفع السكر مثل السكر: ملعقة صغيرة للمتعة. مفيد جدًا عند هبوط السكر.', en: 'Honey raises sugar like sugar does: a teaspoon for pleasure. Very useful for a low.'),
    aliases: ['assel', 'asal'],
    hand: L('1 cuillère à soupe, la taille de votre pouce', aeb: 'مغرفة كبيرة، قد صبعك الكبير', ar: 'ملعقة كبيرة، بحجم إبهامك', en: '1 tablespoon, the size of your thumb'),
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
    hand: L('1 cuillère à soupe, la taille de votre pouce', aeb: 'مغرفة كبيرة، قد صبعك الكبير', ar: 'ملعقة كبيرة، بحجم إبهامك', en: '1 tablespoon, the size of your thumb'),
  ),
];
