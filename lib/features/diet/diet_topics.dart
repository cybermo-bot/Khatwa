/// The teaching pages of "Alimentation": the plate, Ramadan, low blood sugar,
/// and why steady glucose matters for the feet.
///
/// Sources: ADA Standards of Care in Diabetes 2025, section 5 (the plate
/// method, hypoglycaemia treatment with 15 g of fast carbohydrate, checked
/// again after 15 minutes); IDF and DAR International Alliance, Diabetes and
/// Ramadan: Practical Guidelines 2021 (preparing with the doctor, iftar and
/// suhoor, glucose checks do not break the fast, when to break the fast);
/// IWGDF 2023 (glucose and wound healing). Still to be validated by a
/// dietitian and the team clinician ([dietReviewed]).
library;

import 'package:flutter/material.dart';

import 'diet_data.dart';

class DietSection {
  final L heading;
  final List<L> points;
  const DietSection(this.heading, this.points);
}

class DietTopic {
  final String id;
  final IconData icon;
  final L title;
  final L summary;
  final List<DietSection> sections;

  /// When to call 190, shown in red with the call button.
  final L? urgent;

  const DietTopic({
    required this.id,
    required this.icon,
    required this.title,
    required this.summary,
    required this.sections,
    this.urgent,
  });
}

/// The plate: half vegetables, a quarter protein, a quarter starch.
const plateParts = [
  (
    share: 0.5,
    name: L('Légumes', aeb: 'خضرة', ar: 'خضار', en: 'Vegetables'),
    hand: L('2 poings', aeb: 'زوز كفوف مسكرين', ar: 'قبضتان', en: '2 fists'),
  ),
  (
    share: 0.25,
    name: L('Protéines', aeb: 'بروتين', ar: 'بروتين', en: 'Protein'),
    hand: L('la paume de la main', aeb: 'قد الكف', ar: 'بحجم راحة اليد', en: 'the palm of your hand'),
  ),
  (
    share: 0.25,
    name: L('Féculents', aeb: 'نشويات', ar: 'نشويات', en: 'Starch'),
    hand: L('1 poing', aeb: 'كف مسكّر', ar: 'قبضة واحدة', en: '1 fist'),
  ),
];

const dietTopics = <DietTopic>[
  DietTopic(
    id: 'plate',
    icon: Icons.pie_chart_outline_rounded,
    title: L('L’assiette équilibrée', aeb: 'الصحفة المتوازنة', ar: 'الطبق المتوازن', en: 'The balanced plate'),
    summary: L('Moitié légumes, un quart protéines, un quart féculents',
        aeb: 'نص خضرة، ربع بروتين، ربع نشويات',
        ar: 'نصف خضار، ربع بروتين، ربع نشويات',
        en: 'Half vegetables, a quarter protein, a quarter starch'),
    sections: [
      DietSection(L('Remplir l’assiette', aeb: 'كيفاش تعمّر الصحفة', ar: 'كيف تملأ الطبق', en: 'Filling the plate'), [
        L('La moitié en légumes : salade, slata mechouia, légumes du couscous, haricots verts, courgettes.',
            aeb: 'النص خضرة: سلاطة، سلاطة مشوية، خضرة الكسكسي، لوبيا خضراء، قرع.',
            ar: 'النصف خضار: سلطة، سلطة مشوية، خضار الكسكسي، فاصوليا خضراء، كوسة.',
            en: 'Half vegetables: salad, mechouia, couscous vegetables, green beans, courgettes.'),
        L('Un quart en protéines : poisson, poulet, œufs, viande maigre, ou légumineuses.',
            aeb: 'الربع بروتين: حوت، دجاج، عظم، لحم بلا شحم، ولا حمص وعدس.',
            ar: 'الربع بروتين: سمك، دجاج، بيض، لحم قليل الدهن، أو بقوليات.',
            en: 'A quarter protein: fish, chicken, eggs, lean meat, or legumes.'),
        L('Un quart en féculents : pain complet, couscous, riz, pâtes ou pomme de terre, pas plusieurs à la fois.',
            aeb: 'الربع نشويات: خبز كامل، كسكسي، روز، مقرونة ولا بطاطا، موش برشا مع بعضهم.',
            ar: 'الربع نشويات: خبز كامل، كسكسي، أرز، معكرونة أو بطاطس، لا عدة أنواع معًا.',
            en: 'A quarter starch: wholemeal bread, couscous, rice, pasta or potato, not several at once.'),
      ]),
      DietSection(L('Les portions avec la main', aeb: 'الكميات باليد', ar: 'الحصص باليد', en: 'Portions with your hand'), [
        L('Légumes : deux poings. Féculents : un poing. Protéines : la paume. Matière grasse : le pouce.',
            aeb: 'الخضرة: زوز كفوف مسكرين. النشويات: كف. البروتين: قد الكف. الدهن: قد الصبع الكبير.',
            ar: 'الخضار: قبضتان. النشويات: قبضة. البروتين: راحة اليد. الدهون: بحجم الإبهام.',
            en: 'Vegetables: two fists. Starch: one fist. Protein: your palm. Fat: your thumb.'),
        L('Votre main grandit avec vous : c’est une mesure qui vous va.',
            aeb: 'يدّك على قدّك: هي القياس اللي يناسبك.',
            ar: 'يدك على مقاسك: إنها مقياس يناسبك.',
            en: 'Your hand is your own size: it is a measure that fits you.'),
      ]),
      DietSection(L('Boire', aeb: 'الشراب', ar: 'الشرب', en: 'Drinks'), [
        L('De l’eau à chaque repas. Pas de boissons sucrées ni de jus, sauf pour corriger une hypoglycémie.',
            aeb: 'الماء في كل ماكلة. لا قازوز لا عصير، كان كي يطيح السكر.',
            ar: 'الماء مع كل وجبة. لا مشروبات محلاة ولا عصير، إلا لتصحيح هبوط السكر.',
            en: 'Water with every meal. No sweet drinks or juice, except to treat a low.'),
        L('Thé et café : sans sucre, ou en le réduisant peu à peu.',
            aeb: 'التاي والقهوة: بلا سكر، ولا نقّصو شوية بشوية.',
            ar: 'الشاي والقهوة: دون سكر، أو قلّله تدريجيًا.',
            en: 'Tea and coffee: without sugar, or cut it down little by little.'),
      ]),
    ],
  ),
  DietTopic(
    id: 'ramadan',
    icon: Icons.nightlight_outlined,
    title: L('Ramadan et diabète', aeb: 'رمضان والسكّر', ar: 'رمضان والسكري', en: 'Ramadan and diabetes'),
    summary: L('Jeûner en sécurité, et savoir quand rompre le jeûne',
        aeb: 'صوم بلا خطر، واعرف وقتاش تفطر',
        ar: 'الصيام بأمان، ومعرفة متى تفطر',
        en: 'Fasting safely, and knowing when to break the fast'),
    sections: [
      DietSection(L('Avant Ramadan', aeb: 'قبل رمضان', ar: 'قبل رمضان', en: 'Before Ramadan'), [
        L('Parlez à votre médecin 6 à 8 semaines avant : il dit si vous pouvez jeûner et adapte vos médicaments.',
            aeb: 'احكي مع طبيبك 6 ولا 8 جمعات قبل: هو يقلك تنجم تصوم ولا لا ويبدّل الدواء.',
            ar: 'تحدّث مع طبيبك قبل 6 إلى 8 أسابيع: يحدد إن كان بإمكانك الصيام ويعدّل أدويتك.',
            en: 'Talk to your doctor 6 to 8 weeks before: they say whether you can fast and adjust your medicines.'),
        L('L’insuline et certains comprimés doivent être changés d’heure ou de dose : ne le faites jamais seul.',
            aeb: 'الأنسولين وبعض الحبوب يلزمهم يتبدّل الوقت ولا الكمية: ما تعملهاش وحدك.',
            ar: 'الأنسولين وبعض الأقراص تحتاج تغيير الوقت أو الجرعة: لا تفعل ذلك وحدك أبدًا.',
            en: 'Insulin and some tablets need a new time or dose: never do this on your own.'),
      ]),
      DietSection(L('À l’iftar', aeb: 'في الفطور', ar: 'عند الإفطار', en: 'At iftar'), [
        L('Rompez le jeûne avec 1 à 3 dattes et de l’eau, puis un repas équilibré.',
            aeb: 'افطر بتمرة ولا 3 وماء، ومبعد ماكلة متوازنة.',
            ar: 'أفطر على 1 إلى 3 تمرات وماء، ثم وجبة متوازنة.',
            en: 'Break the fast with 1 to 3 dates and water, then a balanced meal.'),
        L('Chorba, salade, une portion de féculent : l’assiette équilibrée vaut aussi en Ramadan.',
            aeb: 'شربة، سلاطة، شوية نشويات: الصحفة المتوازنة حتى في رمضان.',
            ar: 'شوربة، سلطة، حصة نشويات: الطبق المتوازن ينطبق في رمضان أيضًا.',
            en: 'Chorba, salad, one portion of starch: the balanced plate holds in Ramadan too.'),
        L('Zlabia, mkharek et autres douceurs : une petite pièce, pas chaque soir.',
            aeb: 'الزلابية والمخارق والحلو: حبة صغيرة، موش كل ليلة.',
            ar: 'الزلابية والمخارق والحلويات: قطعة صغيرة، لا كل ليلة.',
            en: 'Zlabia, mkharek and other sweets: one small piece, not every night.'),
        L('Buvez de l’eau entre l’iftar et le shour, pas de boissons sucrées.',
            aeb: 'اشرب الماء بين الفطور والسحور، بلا مشروبات مسكّرة.',
            ar: 'اشرب الماء بين الإفطار والسحور، دون مشروبات محلاة.',
            en: 'Drink water between iftar and suhoor, no sweet drinks.'),
      ]),
      DietSection(L('Le shour', aeb: 'السحور', ar: 'السحور', en: 'Suhoor'), [
        L('Prenez-le le plus tard possible, juste avant l’aube.',
            aeb: 'تسحّر قد ما تنجم متأخر، قبل الفجر بشوية.',
            ar: 'تسحّر في أقرب وقت ممكن من الفجر.',
            en: 'Eat it as late as possible, just before dawn.'),
        L('Des féculents lents (pain complet, bsissa sans sucre, légumineuses), du lait ou du yaourt, et de l’eau.',
            aeb: 'نشويات بطيئة (خبز كامل، بسيسة بلا سكر، حمص وعدس)، حليب ولا ياغورت، وماء.',
            ar: 'نشويات بطيئة (خبز كامل، بسيسة دون سكر، بقوليات)، حليب أو زبادي، وماء.',
            en: 'Slow starches (wholemeal bread, bsissa without sugar, legumes), milk or yogurt, and water.'),
      ]),
      DietSection(L('Mesurer la glycémie', aeb: 'قيس السكّر', ar: 'قياس السكر', en: 'Checking your glucose'), [
        L('Mesurer sa glycémie au doigt ne rompt pas le jeûne. Mesurez plus souvent pendant Ramadan.',
            aeb: 'قيس السكر في الصبع ما يفطّرش. قيس أكثر في رمضان.',
            ar: 'قياس السكر بوخز الإصبع لا يفطر. قِس أكثر خلال رمضان.',
            en: 'A finger-prick glucose check does not break the fast. Check more often during Ramadan.'),
      ]),
      DietSection(L('Rompez le jeûne tout de suite si', aeb: 'افطر توّا كان', ar: 'أفطر فورًا إذا', en: 'Break the fast at once if'), [
        L('La glycémie est sous 70 mg/dL (3,9 mmol/L).',
            aeb: 'السكر تحت 70 mg/dL (3,9 mmol/L).',
            ar: 'السكر أقل من 70 mg/dL (3,9 mmol/L).',
            en: 'Glucose is below 70 mg/dL (3.9 mmol/L).'),
        L('La glycémie est au-dessus de 300 mg/dL (16,7 mmol/L).',
            aeb: 'السكر فوق 300 mg/dL (16,7 mmol/L).',
            ar: 'السكر أعلى من 300 mg/dL (16,7 mmol/L).',
            en: 'Glucose is above 300 mg/dL (16.7 mmol/L).'),
        L('Vous tremblez, transpirez, êtes confus, ou vous sentez malade ou très assoiffé.',
            aeb: 'ترعش، تعرق، مخلوط، ولا تحس روحك مريض ولا عطشان برشا.',
            ar: 'ترتجف أو تتعرق أو تشعر بالارتباك، أو تشعر بالمرض أو بعطش شديد.',
            en: 'You shake, sweat, feel confused, or feel ill or very thirsty.'),
        L('Rompre le jeûne pour votre santé est permis : votre vie passe d’abord.',
            aeb: 'تفطر على خاطر صحتك حاجة مسموحة: صحتك قبل كل شي.',
            ar: 'الإفطار من أجل صحتك مباح: حياتك أولًا.',
            en: 'Breaking the fast for your health is allowed: your life comes first.'),
      ]),
    ],
    urgent: L('Malaise, confusion ou perte de connaissance : appelez le 190.',
        aeb: 'دوخة قوية، تخلويض ولا غيبوبة: اطلب 190.',
        ar: 'إغماء أو ارتباك أو فقدان للوعي: اتصل بالرقم 190.',
        en: 'Fainting, confusion or loss of consciousness: call 190.'),
  ),
  DietTopic(
    id: 'hypo',
    icon: Icons.bolt_outlined,
    title: L('Hypoglycémie', aeb: 'هبوط السكّر', ar: 'انخفاض السكر', en: 'Low blood sugar'),
    summary: L('Les signes, et la règle des 15 g et 15 minutes',
        aeb: 'العلامات، وقاعدة 15 غ و15 دقيقة',
        ar: 'العلامات، وقاعدة 15 غ و15 دقيقة',
        en: 'The signs, and the 15 g, 15 minutes rule'),
    sections: [
      DietSection(L('Les signes', aeb: 'العلامات', ar: 'العلامات', en: 'The signs'), [
        L('Tremblements, sueurs, cœur qui bat vite, faim soudaine.',
            aeb: 'رعشة، عرق، القلب يضرب بالخف، جوع فجأة.',
            ar: 'ارتجاف، تعرّق، تسارع ضربات القلب، جوع مفاجئ.',
            en: 'Shaking, sweating, a fast heartbeat, sudden hunger.'),
        L('Vertiges, vision floue, maux de tête, irritabilité ou confusion.',
            aeb: 'دوخة، الشوفة مضبّبة، وجيعة راس، نرفزة ولا تخلويض.',
            ar: 'دوار، رؤية ضبابية، صداع، عصبية أو ارتباك.',
            en: 'Dizziness, blurred vision, headache, irritability or confusion.'),
        L('C’est une glycémie sous 70 mg/dL (3,9 mmol/L). Si vous pouvez, mesurez.',
            aeb: 'هذا كي يكون السكر تحت 70 mg/dL (3,9 mmol/L). كان تنجم، قيس.',
            ar: 'هذا يعني أن السكر أقل من 70 mg/dL (3,9 mmol/L). إن أمكن، قِس.',
            en: 'It means glucose under 70 mg/dL (3.9 mmol/L). If you can, check.'),
      ]),
      DietSection(L('La règle des 15/15', aeb: 'قاعدة 15/15', ar: 'قاعدة 15/15', en: 'The 15/15 rule'), [
        L('1. Prenez 15 g de sucre rapide : 3 morceaux de sucre, ou un demi-verre (150 mL) de jus ou de soda non light, ou 1 cuillère à soupe de miel.',
            aeb: '1. خوذ 15 غ سكر سريع: 3 طوابع سكر، ولا نص كاس (150 مل) عصير ولا قازوز موش لايت، ولا مغرفة كبيرة عسل.',
            ar: '1. تناول 15 غ من السكر السريع: 3 قطع سكر، أو نصف كوب (150 مل) عصير أو مشروب غازي غير خفيف، أو ملعقة كبيرة عسل.',
            en: '1. Take 15 g of fast sugar: 3 sugar cubes, or half a glass (150 mL) of juice or regular soda, or 1 tablespoon of honey.'),
        L('2. Attendez 15 minutes, assis, puis mesurez de nouveau.',
            aeb: '2. استنى 15 دقيقة قاعد، ومبعد عاود قيس.',
            ar: '2. انتظر 15 دقيقة جالسًا، ثم قِس من جديد.',
            en: '2. Wait 15 minutes, sitting down, then check again.'),
        L('3. Toujours sous 70 mg/dL : reprenez 15 g et attendez encore 15 minutes.',
            aeb: '3. مازال تحت 70 mg/dL: عاود 15 غ واستنى 15 دقيقة أخرى.',
            ar: '3. ما زال أقل من 70 mg/dL: تناول 15 غ مرة أخرى وانتظر 15 دقيقة.',
            en: '3. Still under 70 mg/dL: take 15 g again and wait another 15 minutes.'),
        L('4. Ensuite, si le repas est loin, mangez un féculent (un morceau de pain, un fruit).',
            aeb: '4. مبعد، كان الماكلة بعيدة، كول نشويات (طرف خبز، غلة).',
            ar: '4. بعد ذلك، إذا كانت الوجبة بعيدة، تناول نشويات (قطعة خبز، فاكهة).',
            en: '4. Then, if the next meal is far off, eat a starch (a piece of bread, a fruit).'),
      ]),
      DietSection(L('Pour éviter', aeb: 'باش تتجنّب', ar: 'للوقاية', en: 'To prevent it'), [
        L('Ne sautez pas de repas, surtout avec l’insuline ou certains comprimés.',
            aeb: 'ما تفلّتش ماكلة، خاصة مع الأنسولين ولا بعض الحبوب.',
            ar: 'لا تفوّت الوجبات، خاصة مع الأنسولين أو بعض الأقراص.',
            en: 'Do not skip meals, especially with insulin or some tablets.'),
        L('Gardez toujours 3 morceaux de sucre sur vous.',
            aeb: 'ديما خلّي معاك 3 طوابع سكر.',
            ar: 'احمل دائمًا 3 قطع سكر معك.',
            en: 'Always keep 3 sugar cubes with you.'),
        L('Parlez à votre médecin de chaque hypoglycémie : le traitement peut être à ajuster.',
            aeb: 'قول لطبيبك على كل هبوط سكر: يمكن الدواء يلزمو يتبدّل.',
            ar: 'أخبر طبيبك بكل انخفاض للسكر: قد يلزم تعديل العلاج.',
            en: 'Tell your doctor about every low: the treatment may need adjusting.'),
      ]),
    ],
    urgent: L('La personne ne peut plus avaler ou perd connaissance : ne donnez rien par la bouche, appelez le 190.',
        aeb: 'الشخص ما عادش ينجم يبلع ولا طاح في غيبوبة: ما تعطيه حتى شي في فمّو، اطلب 190.',
        ar: 'إذا لم يعد الشخص قادرًا على البلع أو فقد وعيه: لا تعطه شيئًا عبر الفم، واتصل بالرقم 190.',
        en: 'The person can no longer swallow or loses consciousness: give nothing by mouth, call 190.'),
  ),
  DietTopic(
    id: 'feet',
    icon: Icons.healing_outlined,
    title: L('Pourquoi c’est important pour vos pieds', aeb: 'علاش هذا مهم لساقيك', ar: 'لماذا هذا مهم لقدميك', en: 'Why it matters for your feet'),
    summary: L('Une glycémie stable aide les plaies à guérir',
        aeb: 'السكر المستقر يعاون الجروح يبراو',
        ar: 'استقرار السكر يساعد الجروح على الشفاء',
        en: 'Steady glucose helps wounds heal'),
    sections: [
      DietSection(L('Ce que fait le sucre en trop', aeb: 'شنوّة يعمل السكر الزايد', ar: 'ماذا يفعل السكر الزائد', en: 'What too much sugar does'), [
        L('Avec le temps, il abîme les nerfs des pieds : on sent moins une blessure ou une chaussure qui serre.',
            aeb: 'مع الوقت يضرّ أعصاب الساقين: ما عادش تحس بالجرح ولا بالصبّاط اللي يضيّق.',
            ar: 'مع الوقت يتلف أعصاب القدمين: فلا تشعر جيدًا بجرح أو بحذاء ضيق.',
            en: 'Over time it damages the nerves of the feet: you feel a cut or a tight shoe less.'),
        L('Il abîme aussi les petits vaisseaux : le sang arrive moins bien aux pieds.',
            aeb: 'ويضرّ العروق الصغار: الدم ما يوصلش مليح للساقين.',
            ar: 'ويتلف الأوعية الصغيرة أيضًا: فيصل الدم إلى القدمين بصعوبة.',
            en: 'It also damages small blood vessels: less blood reaches the feet.'),
        L('Une plaie guérit plus lentement et s’infecte plus facilement quand la glycémie est haute.',
            aeb: 'الجرح يبطى باش يبرا ويتعفّن بالسهل كي يكون السكر عالي.',
            ar: 'يلتئم الجرح ببطء ويلتهب بسهولة عندما يكون السكر مرتفعًا.',
            en: 'A wound heals more slowly and gets infected more easily when glucose is high.'),
      ]),
      DietSection(L('Ce qui aide', aeb: 'شنوّة يعاون', ar: 'ما الذي يساعد', en: 'What helps'), [
        L('Des repas réguliers selon l’assiette équilibrée, et moins de sucres rapides.',
            aeb: 'ماكلة في وقتها كيف الصحفة المتوازنة، وسكر سريع أقل.',
            ar: 'وجبات منتظمة وفق الطبق المتوازن، وسكريات سريعة أقل.',
            en: 'Regular meals following the balanced plate, and fewer fast sugars.'),
        L('Marcher chaque jour avec de bonnes chaussures, si vos pieds n’ont pas de plaie.',
            aeb: 'امشي كل يوم بصبّاط مليح، كان ساقيك ما فيهمش جرح.',
            ar: 'المشي كل يوم بحذاء مناسب، إذا لم يكن في قدميك جرح.',
            en: 'Walking every day in good shoes, if your feet have no wound.'),
        L('Votre objectif d’HbA1c est à fixer avec votre médecin.',
            aeb: 'الهدف متاع HbA1c تحددو مع طبيبك.',
            ar: 'هدف HbA1c يُحدَّد مع طبيبك.',
            en: 'Your HbA1c target is set with your doctor.'),
        L('Et chaque jour, le contrôle des pieds dans Khatwa.',
            aeb: 'وكل يوم، فحص الساقين في خطوة.',
            ar: 'وكل يوم، فحص القدمين في خطوة.',
            en: 'And every day, the foot check in Khatwa.'),
      ]),
    ],
  ),
];

DietTopic dietTopic(String id) => dietTopics.firstWhere((t) => t.id == id);
