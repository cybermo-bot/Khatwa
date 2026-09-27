/// Khatwa localisation.
/// Order of every entry: [العربية, تونسي (derja), Français, English].
/// Tunisian derja is the default language of the app.
class S {
  static const List<String> languages = ['تونسي', 'العربية', 'Français', 'English'];
  static const String fallback = 'تونسي';

  static int _index(String lang) {
    switch (lang) {
      case 'العربية':
        return 0;
      case 'تونسي':
        return 1;
      case 'Français':
        return 2;
      case 'English':
        return 3;
      default:
        return 1;
    }
  }

  static bool isRtl(String lang) => lang == 'العربية' || lang == 'تونسي';

  static String t(String lang, String key) {
    final row = _map[key];
    if (row == null) return key;
    final i = _index(lang);
    if (i < row.length && row[i].isNotEmpty) return row[i];
    return row[1];
  }

  static const Map<String, List<String>> _map = {
    'app.name': ['خطوة', 'خطوة', 'Khatwa', 'Khatwa'],
    'app.tagline': [
      'متابعة ذكية للقدم السكرية',
      'نتبّعو صحّة ساقيك كل يوم',
      'Surveillance guidée du pied diabétique',
      'Guided diabetic foot monitoring'
    ],
    'app.language': ['اللغة', 'اللغة', 'Langue', 'Language'],
    'role.patient': ['مريض', 'مريض', 'Patient', 'Patient'],
    'role.doctor': ['طبيب', 'طبيب', 'Professionnel de santé', 'Health professional'],
    'role.choose': ['اختر نوع الحساب', 'شكون إنت؟', 'Choisissez votre profil', 'Choose your profile'],
    'auth.signin': ['تسجيل الدخول', 'دخول', 'Se connecter', 'Sign in'],
    'auth.signup': ['إنشاء حساب', 'حساب جديد', 'Créer un compte', 'Create account'],
    'auth.phone': ['رقم الهاتف', 'نمرة التليفون', 'Numéro de téléphone', 'Phone number'],
    'auth.password': ['كلمة السر', 'كلمة السر', 'Mot de passe', 'Password'],
    'auth.confirm': ['تأكيد كلمة السر', 'عاود كلمة السر', 'Confirmer le mot de passe', 'Confirm password'],
    'auth.name': ['الاسم الكامل', 'الاسم', 'Nom complet', 'Full name'],
    'auth.speciality': ['الاختصاص', 'الاختصاص', 'Spécialité', 'Speciality'],
    'auth.facility': ['المؤسسة الصحية', 'المركز', 'Structure de soins', 'Care facility'],
    'auth.have': ['عندك حساب؟', 'عندك حساب؟', 'Déjà un compte ?', 'Already have an account?'],
    'auth.none': ['ما عندكش حساب؟', 'مازال ما عملتش حساب؟', 'Pas encore de compte ?', 'No account yet?'],
    'auth.logout': ['خروج', 'خروج', 'Déconnexion', 'Sign out'],
    'auth.err.fields': ['عمّر كل الخانات', 'لازم تعمّر الكل', 'Veuillez remplir tous les champs', 'Please fill in all fields'],
    'auth.err.phone': ['رقم الهاتف غير صحيح', 'النمرة موش صحيحة', 'Numéro invalide (8 chiffres)', 'Invalid phone number (8 digits)'],
    'auth.err.short': ['كلمة السر قصيرة (8 أحرف على الأقل)', 'كلمة السر قصيرة برشة (8 حروف على الأقل)', 'Mot de passe trop court (8 caractères min.)', 'Password too short (8 characters min.)'],
    'auth.err.match': ['كلمتا السر غير متطابقتين', 'الكلمتين موش كيف كيف', 'Les mots de passe ne correspondent pas', 'Passwords do not match'],
    'auth.err.exists': ['هذا الرقم مسجل من قبل', 'النمرة هذي مسجلة', 'Ce numéro est déjà enregistré', 'This number is already registered'],
    'auth.err.bad': ['البريد أو كلمة السر خاطئة', 'الإيمايل ولا كلمة السر غالطين', 'E-mail ou mot de passe incorrect', 'Wrong e-mail or password'],
    'auth.welcome': ['مرحبا', 'أهلا', 'Bonjour', 'Welcome'],
    'onb.skip': ['تخطي', 'فوّت', 'Passer', 'Skip'],
    'onb.next': ['التالي', 'اللي بعدو', 'Suivant', 'Next'],
    'onb.start': ['ابدأ', 'يلّا نبداو', 'Commencer', 'Get started'],
    'onb.1.title': ['قدماك، كل يوم', 'ساقيك، كل يوم', 'Vos pieds, chaque jour', 'Your feet, every day'],
    'onb.1.body': [
      'فحص قصير كل يوم بالصور وبعض الأسئلة. عند أي علامة مقلقة، يطّلع عليها طبيب. خطوة لا تشخّص: هي تساعدك على الانتباه مبكرا.',
      'فحص قصير كل يوم بالتصاور وشوية أسئلة. كي تبان علامة تقلق، يشوفها طبيب. خطوة ما تشخّصش: تعاونك تنتبه بكري.',
      'Un contrôle court chaque jour, avec des photos et quelques questions. Au moindre signe inquiétant, un soignant regarde. Khatwa ne pose pas de diagnostic : elle vous aide à voir tôt.',
      'A short check every day, with photos and a few questions. At any worrying sign, a health professional looks. Khatwa does not diagnose: it helps you notice early.'
    ],
    'onb.2.title': ['قدمك ثلاثية الأبعاد', 'ساقك في 3D', 'Votre pied en 3D', 'Your foot in 3D'],
    'onb.2.body': [
      'دوّر القدم بإصبعك. العلامات التي تسجّلها تظهر في مكانها، ويرى الطبيب الشيء نفسه.',
      'دوّر الساق بصبعك. العلامات اللي تسجّلها تبان في بلاصتها، والطبيب يشوف نفس الحاجة.',
      'Tournez le pied du doigt. Les signes que vous notez apparaissent à leur place, et le soignant voit la même chose.',
      'Turn the foot with your finger. The signs you note appear in their place, and the health professional sees the same.'
    ],
    'onb.3.title': ['تحدّث مع خطوة', 'احكي مع خطوة', 'Parlez à Khatwa', 'Talk to Khatwa'],
    'onb.3.body': [
      'اضغط على الزر وتكلّم بالدارجة أو العربية أو الفرنسية. خطوة تجيبك بصوتها، وعند علامة خطيرة تقول لك اتصل بـ 190.',
      'شدّ الزر واحكي بالتونسي ولا بالعربية ولا بالفرنسية. خطوة تجاوبك بالصوت، وكي تكون علامة خطيرة تقلك اطلب 190.',
      'Maintenez le bouton et parlez en derja, en arabe ou en français. Khatwa vous répond à voix haute, et devant un signe grave vous dit d’appeler le 190.',
      'Hold the button and speak in derja, Arabic or French. Khatwa answers out loud, and for a serious sign tells you to call 190.'
    ],
    'demo.noRealData': [
      'نسخة تجريبية: لا تُدخل بيانات حقيقية.',
      'نسخة تجريبية: ما تدخّلش معلومات حقيقية.',
      'Démo : n’entrez pas de données réelles.',
      'Demo: do not enter real data.'
    ],
    'auth.email': ['البريد الإلكتروني', 'الإيمايل', 'E-mail', 'E-mail'],
    'auth.identifier': [
      'البريد الإلكتروني (أو رقم الهاتف لحساب قديم)',
      'الإيمايل (ولا النمرة لحساب قديم)',
      'E-mail (ou numéro pour un ancien compte)',
      'E-mail (or phone number for an older account)'
    ],
    'auth.phoneOptional': ['رقم الهاتف (اختياري)', 'نمرة التليفون (موش لازم)', 'Numéro de téléphone (facultatif)', 'Phone number (optional)'],
    'auth.stay': ['البقاء متصلا', 'خليني داخل', 'Rester connecté', 'Stay signed in'],
    'auth.stayHint': [
      'على هذا الجهاز فقط: لا قفل بعد 10 دقائق، ولا رمز بالبريد لمدة 30 يوما.',
      'في التليفون هذا برك: ما يتسكرش بعد 10 دقايق، وما يلزمكش كود بالإيمايل 30 يوم.',
      'Sur cet appareil seulement : pas de verrouillage après 10 minutes, pas de code par e-mail pendant 30 jours.',
      'On this device only: no lock after 10 minutes, no e-mail code for 30 days.'
    ],
    'auth.err.email': ['البريد الإلكتروني غير صحيح', 'الإيمايل موش صحيح', 'Adresse e-mail invalide', 'Invalid e-mail address'],
    'auth.err.emailExists': [
      'هذا البريد مسجل من قبل على هذا الجهاز',
      'الإيمايل هذا مسجّل من قبل في التليفون',
      'Cet e-mail a déjà un compte sur cet appareil',
      'This e-mail already has an account on this device'
    ],
    'auth.err.needPin': [
      'أدخل رمزك السري القديم، مرة أخيرة فقط.',
      'دخّل الكود السري القديم متاعك، آخر مرة برك.',
      'Entrez votre ancien code PIN, une dernière fois seulement.',
      'Enter your old PIN, one last time only.'
    ],
    'auth.oldPin': ['الرمز السري القديم', 'الكود السري القديم', 'Ancien code PIN', 'Old PIN'],
    'auth.err.codeSend': [
      'لم نتمكن من إرسال الرمز الآن (إرسالات كثيرة أو لا يوجد اتصال). حاول بعد قليل، أو واصل كضيف.',
      'ما نجمناش نبعثو الكود توّا (برشة إرسالات ولا ما فماش كونكسيون). عاود بعد شوية، ولا كمّل كضيف.',
      'Nous n’avons pas pu envoyer le code pour le moment (trop d’envois ou pas de connexion). Réessayez dans un moment, ou continuez en invité.',
      'We could not send the code right now (too many e-mails or no connection). Try again in a moment, or continue as a guest.'
    ],
    'auth.err.code': [
      'الرمز غير صحيح أو انتهت صلاحيته',
      'الكود غالط ولا وفى وقتو',
      'Code incorrect ou expiré',
      'Wrong or expired code'
    ],
    'auth.code.title': ['رمز التحقق', 'كود التأكيد', 'Code de vérification', 'Verification code'],
    'auth.code.sent': [
      'أرسلنا رمزا من 6 أرقام إلى',
      'بعثنالك كود فيه 6 أرقام لـ',
      'Nous avons envoyé un code à 6 chiffres à',
      'We sent a 6-digit code to'
    ],
    'auth.code.sending': ['جار إرسال الرمز…', 'قاعدين نبعثو في الكود…', 'Envoi du code…', 'Sending the code…'],
    'auth.code.label': ['الرمز (6 أرقام)', 'الكود (6 أرقام)', 'Code à 6 chiffres', '6-digit code'],
    'auth.code.verify': ['تحقق', 'تأكّد', 'Vérifier', 'Verify'],
    'auth.code.resend': ['إعادة إرسال الرمز', 'عاود ابعث الكود', 'Renvoyer le code', 'Send the code again'],
    'auth.code.spam': [
      'لم يصلك؟ تحقق من البريد غير المرغوب فيه.',
      'ما وصلكش؟ شوف في البريد المزعج.',
      'Rien reçu ? Regardez dans les courriers indésirables.',
      'Nothing received? Check your spam folder.'
    ],
    'auth.guest': ['المتابعة كضيف', 'كمّل كضيف', 'Continuer en invité', 'Continue as a guest'],
    'auth.guestNote': [
      'بدون إدخال أي معلومات. يمكنك إنشاء حسابك لاحقا.',
      'بلا ما تكتب حتى شي. تنجم تعمل حسابك من بعد.',
      'Aucune donnée à saisir. Vous pourrez créer votre compte plus tard.',
      'Nothing to type. You can create your account later.'
    ],
    'auth.guestName': ['ضيف', 'ضيف', 'Invité', 'Guest'],
    'auth.guestBadge': ['حساب ضيف', 'حساب ضيف', 'Compte invité', 'Guest account'],
    'auth.guestUpgrade': ['إنشاء حسابي', 'اعمل حسابي', 'Créer mon compte', 'Create my account'],
    'auth.guestUpgradeSub': [
      'احتفظ بمتابعتك: أضف بريدا إلكترونيا وكلمة سر.',
      'حافظ على المتابعة متاعك: زيد إيمايل وكلمة سر.',
      'Gardez votre suivi : ajoutez un e-mail et un mot de passe.',
      'Keep your follow-up: add an e-mail and a password.'
    ],
    'auth.guestLeave': [
      'عند الخروج، تُحذف بيانات الضيف من هذا الجهاز. هل تريد الخروج؟',
      'كي تخرج، المعلومات متاع الضيف تتفسخ من التليفون. تحب تخرج؟',
      'En vous déconnectant, les données de l’invité seront effacées de cet appareil. Vous déconnecter ?',
      'Signing out erases the guest data from this device. Sign out?'
    ],
    'auth.back': ['رجوع', 'ارجع', 'Retour', 'Back'],
    'auth.promise': [
      'نظرة على قدميك كل يوم، وطبيب وراء كل تنبيه',
      'تشوف ساقيك كل يوم، وطبيب معاك كي يلزم',
      'Un regard sur vos pieds chaque jour, un soignant derrière chaque alerte',
      'A look at your feet every day, a health professional behind every alert'
    ],
    'auth.iam': ['أنا', 'أنا', 'Je suis', 'I am'],
    'role.doctorShort': ['طبيب أو ممرض', 'طبيب ولا فرملي', 'Soignant', 'Health professional'],
    'auth.welcomeBack': ['مرحبا بعودتك', 'مرحبا بيك من جديد', 'Content de vous revoir', 'Welcome back'],
    'auth.signinSub': [
      'أدخل معلوماتك لتجد متابعتك.',
      'دخّل المعلومات متاعك باش تلقى المتابعة متاعك.',
      'Entrez vos identifiants pour retrouver votre suivi.',
      'Enter your details to find your follow-up.'
    ],
    'auth.signupSub': [
      'بضع معلومات فقط، ثم نبدأ.',
      'شوية معلومات برك، ومبعد نبداو.',
      'Quelques informations, puis on commence.',
      'A few details, then we start.'
    ],
    'auth.show': ['إظهار كلمة السر', 'ورّي كلمة السر', 'Afficher le mot de passe', 'Show password'],
    'auth.hide': ['إخفاء كلمة السر', 'خبّي كلمة السر', 'Masquer le mot de passe', 'Hide password'],
    'auth.secure': [
      'بياناتك محفوظة على هذا الجهاز، وكلمة السر مشفّرة.',
      'المعلومات متاعك تقعد في التليفون، وكلمة السر مشفّرة.',
      'Vos données restent sur cet appareil, mot de passe chiffré.',
      'Your data stays on this device, password is hashed.'
    ],
    'home.hello': ['أهلا', 'أهلا', 'Bonjour', 'Hello'],
    'twin.title': ['قدمي ثلاثية الأبعاد', 'ساقي في 3D', 'Mon jumeau 3D', 'My 3D twin'],
    'twin.left': ['اليسرى', 'اليسار', 'Gauche', 'Left'],
    'twin.right': ['اليمنى', 'اليمين', 'Droit', 'Right'],
    'twin.top': ['من الأعلى', 'من الفوق', 'Dessus', 'Top'],
    'twin.sole': ['باطن القدم', 'من تحت', 'Plante', 'Sole'],
    'twin.hint': ['اسحب للتدوير', 'اسحب باش تدوّر', 'Glissez pour tourner', 'Drag to turn'],
    'twin.care': ['العناية اليوم', 'العناية اليوم', 'Soins du jour', 'Today’s care'],
    'zone.hallux': ['إبهام القدم', 'الصبع الكبير', 'Gros orteil', 'Big toe'],
    'zone.lesser_toes': ['أصابع القدم', 'الصوابع', 'Orteils', 'Toes'],
    'zone.interdigital': ['بين الأصابع', 'بين الصوابع', 'Entre les orteils', 'Between toes'],
    'zone.forefoot_plantar': ['مقدمة القدم', 'قدّام الساق', 'Avant-pied', 'Ball of foot'],
    'zone.midfoot_plantar': ['قوس القدم', 'وسط الساق', 'Voûte', 'Arch'],
    'zone.heel_plantar': ['الكعب', 'الكعب', 'Talon', 'Heel'],
    'zone.heel_posterior': ['خلف الكعب', 'ورا الكعب', 'Arrière du talon', 'Back of heel'],
    'zone.dorsum': ['ظهر القدم', 'فوق الساق', 'Dessus du pied', 'Top of foot'],
    'zone.medial_side': ['الحافة الداخلية', 'الجنب الداخلي', 'Bord interne', 'Inner edge'],
    'zone.lateral_side': ['الحافة الخارجية', 'الجنب البرّاني', 'Bord externe', 'Outer edge'],
    'zone.ankle': ['الكاحل', 'الكاحل', 'Cheville', 'Ankle'],
    'home.todayTitle': ['فحص اليوم', 'فحص اليوم', 'Contrôle du jour', 'Today check'],
    'home.todaySub': [
      'صور رجليك وجاوب على أسئلة قصيرة',
      'صوّر ساقيك وجاوب شوية أسئلة',
      'Photographiez vos pieds et répondez à quelques questions',
      'Photograph your feet and answer a few questions'
    ],
    'home.start': ['ابدأ الفحص', 'ابدا الفحص', 'Démarrer le contrôle', 'Start check'],
    'home.done': ['تم فحص اليوم ✓', 'عملت فحص اليوم ✓', 'Contrôle du jour effectué ✓', 'Today check done ✓'],
    'home.lastResult': ['آخر نتيجة', 'آخر نتيجة', 'Dernier résultat', 'Last result'],
    'home.noCheck': ['ما عندكش فحوصات بعد', 'مازال ما عملت حتى فحص', 'Aucun contrôle enregistré', 'No checks recorded yet'],
    'home.history': ['السجل', 'السجل', 'Historique', 'History'],
    'home.tools': ['المتابعة اليومية', 'المتابعة', 'Suivi quotidien', 'Daily follow-up'],
    'home.profile': ['ملفي الطبي', 'الملف متاعي', 'Mon dossier médical', 'My medical record'],
    // Monday first, one entry per day, comma separated.
    'week.initials': ['ن,ث,ر,خ,ج,س,ح', 'ن,ث,ر,خ,ج,س,ح', 'L,M,M,J,V,S,D', 'M,T,W,T,F,S,S'],
    'week.names': [
      'الإثنين,الثلاثاء,الأربعاء,الخميس,الجمعة,السبت,الأحد',
      'الاثنين,الثلاثاء,الاربعاء,الخميس,الجمعة,السبت,الأحد',
      'Lundi,Mardi,Mercredi,Jeudi,Vendredi,Samedi,Dimanche',
      'Monday,Tuesday,Wednesday,Thursday,Friday,Saturday,Sunday'
    ],
    // Tunisia uses the French-derived month names in Arabic and derja.
    'month.names': [
      'جانفي,فيفري,مارس,أفريل,ماي,جوان,جويلية,أوت,سبتمبر,أكتوبر,نوفمبر,ديسمبر',
      'جانفي,فيفري,مارس,أفريل,ماي,جوان,جويلية,أوت,سبتمبر,أكتوبر,نوفمبر,ديسمبر',
      'Janvier,Février,Mars,Avril,Mai,Juin,Juillet,Août,Septembre,Octobre,Novembre,Décembre',
      'January,February,March,April,May,June,July,August,September,October,November,December'
    ],
    'home.nextTomorrow': ['الفحص القادم غدا', 'الفحص الجاي غدوة', 'Prochain contrôle demain', 'Next check tomorrow'],
    'home.seeToday': ['عرض نتيجة اليوم', 'شوف نتيجة اليوم', 'Voir le résultat du jour', "See today's result"],
    'home.week': ['هذا الأسبوع', 'الجمعة هاذي', 'Cette semaine', 'This week'],
    'home.group.track': ['المتابعة', 'المتابعة', 'Suivi', 'Tracking'],
    'home.group.learn': ['تعلّم', 'تعلّم', 'Apprendre', 'Learn'],
    'home.group.care': ['التواصل مع الفريق الطبي', 'الطبة والمساعدة', 'Équipe de soins', 'Care team'],
    'tab.today': ['اليوم', 'اليوم', 'Aujourd’hui', 'Today'],
    'tab.check': ['الفحص', 'الفحص', 'Contrôle', 'Check'],
    'tab.journal': ['السجل', 'السجل', 'Journal', 'Journal'],
    'tab.learn': ['تعلّم', 'تعلّم', 'Apprendre', 'Learn'],
    'tab.me': ['أنا', 'أنا', 'Moi', 'Me'],
    'today.care': ['عنايتك اليوم', 'العناية متاعك اليوم', 'Vos soins du jour', 'Your care today'],
    'today.care.check': ['فحص القدمين', 'فحص الساقين', 'Examiner les pieds', 'Check your feet'],
    'today.care.wash': ['الغسل بماء فاتر', 'الغسيل بماء دافي', 'Laver à l’eau tiède', 'Wash in lukewarm water'],
    'today.care.dry': ['التجفيف بين الأصابع', 'التنشيف بين الصوابع', 'Sécher entre les orteils', 'Dry between the toes'],
    'today.care.cream': ['الترطيب، ليس بين الأصابع', 'الكريمة، موش بين الصوابع', 'Hydrater, pas entre les orteils', 'Moisturise, not between the toes'],
    'today.care.shoes': ['تفقد الحذاء من الداخل', 'شوف الصباط من الداخل', 'Vérifier l’intérieur des chaussures', 'Check inside your shoes'],
    'today.care.done': ['تم', 'تعمل', 'Fait', 'Done'],
    'today.glucose': ['آخر قياس للسكر', 'آخر قيس للسكر', 'Dernière glycémie', 'Last blood sugar'],
    'today.glucose.none': ['لم تسجل أي قياس بعد', 'مازال ما سجلت حتى قيس', 'Aucune mesure enregistrée', 'No reading yet'],
    'today.glucose.add': ['إضافة قياس', 'زيد قيس', 'Ajouter une mesure', 'Add a reading'],
    'today.photosOf': ['صور من 4', 'تصاور من 4', 'photos sur 4', 'of 4 photos'],
    'check.daily': ['الفحص اليومي', 'الفحص اليومي', 'Contrôle du jour', 'Daily check'],
    'check.daily.what': [
      '4 صور للقدمين، ثم أسئلة قصيرة',
      '4 تصاور للساقين، ومن بعد شوية أسئلة',
      '4 photos des pieds, puis quelques questions',
      '4 photos of your feet, then a few short questions'
    ],
    'check.positions': ['ماذا نصوّر', 'شنوّة نصوّرو', 'Ce que l’on photographie', 'What we photograph'],
    'check.more': ['اختبارات أخرى', 'اختبارات أخرى', 'Autres examens', 'Other checks'],
    'check.soon': [
      'قريبا: صور بين الأصابع والكعب من الخلف، وفحص أسبوعي كامل.',
      'قريب: تصاور بين الصوابع والكعب من تالي، وفحص كامل كل جمعة.',
      'Bientôt : photos entre les orteils et du talon, et un contrôle complet chaque semaine.',
      'Coming next: photos between the toes and of the heel, and a full weekly check.'
    ],
    'journal.empty': [
      'لا شيء في هذا اليوم',
      'ما فمّا شي في النهار هذا',
      'Rien ce jour-là',
      'Nothing on this day'
    ],
    'journal.check': ['فحص القدمين', 'فحص الساقين', 'Contrôle des pieds', 'Foot check'],
    'journal.glucose': ['السكر', 'السكر', 'Glycémie', 'Blood sugar'],
    'journal.log': ['سجّل حال قدميك', 'سجّل كيفاش ساقيك', 'Noter l’état de mes pieds', 'Log how my feet feel'],
    'journal.logShort': ['ملاحظة', 'ملاحظة', 'Note', 'Log'],
    'journal.logTitle': ['كيف حال قدميك اليوم؟', 'كيفاش ساقيك اليوم؟', 'Comment vont vos pieds aujourd’hui ?', 'How do your feet feel today?'],
    'journal.logHint': ['اختر كل ما ينطبق', 'اختار الكل اللي صحيح', 'Choisissez tout ce qui s’applique', 'Choose all that apply'],
    'journal.none': ['لا شيء غير عادي', 'ما فمّا حتى شي', 'Rien de particulier', 'Nothing unusual'],
    'journal.note': ['ملاحظة (اختياري)', 'ملاحظة (موش لازم)', 'Note (facultatif)', 'Note (optional)'],
    'journal.saved': ['تم الحفظ', 'تسجّل', 'Enregistré', 'Saved'],
    'journal.flag': [
      'علامة جديدة أو انتفاخ: افحص قدميك اليوم.',
      'علامة جديدة ولا نفخة: أفحص ساقيك اليوم.',
      'Nouvelle marque ou gonflement : faites un contrôle aujourd’hui.',
      'A new mark or swelling: check your feet today.'
    ],
    'journal.checkNow': ['افحص الآن', 'أفحص توّا', 'Contrôler', 'Check now'],
    'sym.pain': ['ألم', 'وجيعة', 'Douleur', 'Pain'],
    'sym.tingling': ['تنميل أو حرقة', 'تنميل ولا حرقان', 'Fourmillements, brûlures', 'Tingling or burning'],
    'sym.numbness': ['نقص الإحساس', 'ما نحسّش', 'Engourdissement', 'Numbness'],
    'sym.swelling': ['انتفاخ', 'نفخة', 'Gonflement', 'Swelling'],
    'sym.newMark': ['علامة أو بقعة جديدة', 'علامة جديدة', 'Nouvelle marque ou tache', 'New mark or spot'],
    'sym.rubbing': ['الحذاء يحتك', 'الصباط يحكّ', 'La chaussure frotte', 'Shoe rubbing'],
    'sym.cold': ['قدم باردة', 'ساق باردة', 'Pied froid', 'Cold feet'],
    'sym.itching': ['حكة', 'حكّان', 'Démangeaisons', 'Itching'],
    'me.health': ['صحتي', 'صحتي', 'Ma santé', 'My health'],
    'me.record': ['ملفي الطبي', 'الملف متاعي', 'Mon dossier médical', 'My medical record'],
    'me.team': ['فريقي الطبي', 'الطبة متاعي', 'Mon équipe de soins', 'My care team'],
    'me.more': ['أدوات أخرى', 'حاجات أخرى', 'Autres outils', 'More tools'],
    'me.app': ['التطبيق', 'التطبيق', 'Application', 'App'],
    'me.privacy': ['الخصوصية والأمان', 'الخصوصية والأمان', 'Confidentialité et sécurité', 'Privacy and security'],
    'settings.skin': ['لون البشرة في الرسوم', 'لون الجلد في الرسومات', 'Teinte de peau des dessins', 'Skin tone in the drawings'],
    'settings.skinHint': [
      'اختر اللون الأقرب لقدميك: الاحمرار وتغيّر اللون يظهران بشكل مختلف حسب البشرة.',
      'اختار اللون الأقرب لساقيك: الحمورية وتبديل اللون يبانو بطريقة مختلفة.',
      'Choisissez la teinte la plus proche de vos pieds : rougeur et changement de couleur ne se voient pas de la même façon.',
      'Pick the tone closest to your feet: redness and colour change look different on different skin.'
    ],
    'settings.skin.fair': ['فاتحة', 'فاتح', 'Claire', 'Fair'],
    'settings.skin.medium': ['متوسطة', 'متوسط', 'Moyenne', 'Medium'],
    'settings.skin.deep': ['داكنة', 'غامق', 'Foncée', 'Deep'],
    'settings.theme': ['المظهر', 'الشكل', 'Apparence', 'Appearance'],
    'settings.theme.system': ['حسب الهاتف', 'كيف التليفون', 'Téléphone', 'Match phone'],
    'settings.theme.light': ['فاتح', 'فاتح', 'Clair', 'Light'],
    'settings.theme.dark': ['داكن', 'غامق', 'Sombre', 'Dark'],
    'home.streak': ['أيام متتالية', 'أيام متواصلة', 'jours de suite', 'day streak'],
    'tool.glycemia': ['السكري في الدم', 'السكر', 'Glycémie', 'Blood glucose'],
    'tool.temperature': ['الحرارة', 'الحرارة', 'Température', 'Temperature'],
    'tool.sensory': ['اختبار الإحساس', 'الإحساس', 'Test de sensibilité', 'Sensation test'],
    'tool.wellbeing': ['الحالة النفسية', 'كيفاش راك', 'Bien-être', 'Wellbeing'],
    'tool.activity': ['النشاط البدني', 'الحركة', 'Activité', 'Activity'],
    'tool.food': ['التغذية', 'الماكلة', 'Alimentation', 'Food'],
    'tool.exercises': ['تمارين القدم', 'تمارين', 'Exercices', 'Exercises'],
    'tool.tips': ['نصائح', 'نصائح', 'Conseils', 'Tips'],
    'tool.videos': ['فيديوهات', 'فيديوهات', 'Vidéos', 'Videos'],
    'tool.appointments': ['المواعيد', 'الموعيد', 'Rendez-vous', 'Appointments'],
    'tool.chat': ['المساعد الذكي', 'المساعد', 'Assistant', 'Assistant'],
    'tool.doctors': ['الأطباء', 'الطبة', 'Professionnels', 'Professionals'],
    'check.step': ['الخطوة', 'الخطوة', 'Étape', 'Step'],
    'check.photos': ['الصور', 'التصاور', 'Photos', 'Photos'],
    'check.questions': ['الأسئلة', 'الأسئلة', 'Questionnaire', 'Questionnaire'],
    'check.result': ['النتيجة', 'النتيجة', 'Résultat', 'Result'],
    'check.guideTitle': ['كيفاش تصور', 'كيفاش تصوّر', 'Guide de prise de vue', 'How to take the photo'],
    'check.guide': [
      'اجلس، ضع الهاتف أمام قدمك، تأكد من الإضاءة، وصوّر باطن القدم كاملا.',
      'أقعد، حط التليفون قدام ساقك، خلي الضو باهي، وصوّر باطن الساق الكل.',
      'Asseyez-vous, posez le téléphone face au pied, bonne lumière, plante entière visible.',
      'Sit down, place the phone facing your foot, good light, whole sole visible.'
    ],
    'check.rightSole': ['باطن القدم اليمنى', 'باطن الساق اليمين', 'Plante du pied droit', 'Right sole'],
    'check.leftSole': ['باطن القدم اليسرى', 'باطن الساق اليسار', 'Plante du pied gauche', 'Left sole'],
    'check.rightTop': ['ظهر القدم اليمنى', 'فوق الساق اليمين', 'Dessus du pied droit', 'Right top'],
    'check.leftTop': ['ظهر القدم اليسرى', 'فوق الساق اليسار', 'Dessus du pied gauche', 'Left top'],
    'check.camera': ['كاميرا', 'كاميرا', 'Caméra', 'Camera'],
    'check.gallery': ['المعرض', 'التصاور', 'Galerie', 'Gallery'],
    'check.needPhoto': ['صورة واحدة على الأقل مطلوبة', 'لازم صورة وحدة على الأقل', 'Au moins une photo est requise', 'At least one photo is required'],
    'check.next': ['التالي', 'التالي', 'Suivant', 'Next'],
    'check.analyze': ['حلّل الفحص', 'حلّل', 'Analyser', 'Analyse'],
    'check.analyzing': ['جاري التحليل...', 'قاعد نحلّل...', 'Analyse en cours...', 'Analysing...'],
    'q.pain': ['هل تشعر بألم في القدم؟', 'تحس بوجيعة في ساقك؟', 'Avez-vous une douleur au pied ?', 'Any foot pain?'],
    'q.wound': ['هل يوجد جرح جديد؟', 'ثمة جرح جديد؟', 'Une nouvelle plaie ?', 'Any new wound?'],
    'q.swelling': ['هل يوجد انتفاخ؟', 'ثمة نفخة؟', 'Un gonflement ?', 'Any swelling?'],
    'q.color': ['هل تغيّر لون الجلد؟', 'اللون تبدل؟', 'Changement de couleur ?', 'Colour change?'],
    'q.smell': ['هل توجد رائحة كريهة؟', 'ريحة موش باهية؟', 'Une mauvaise odeur ?', 'Bad smell?'],
    'q.fever': ['هل عندك حمى؟', 'عندك سخانة؟', 'De la fièvre ?', 'Fever?'],
    'q.numbness': ['هل تشعر بخدر أو نقص إحساس؟', 'ما تحسش بساقك مليح؟', 'Engourdissement ou perte de sensation ?', 'Numbness or loss of feeling?'],
    'q.barefoot': ['هل مشيت حافيا هذا الأسبوع؟', 'مشيت حافي هالجمعة؟', 'Marché pieds nus cette semaine ?', 'Walked barefoot this week?'],
    'q.yes': ['نعم', 'إيه', 'Oui', 'Yes'],
    'q.no': ['لا', 'لا', 'Non', 'No'],
    'q.glucose': ['آخر قياس للسكري (mg/dL)', 'آخر قياس سكر (mg/dL)', 'Dernière glycémie (mg/dL)', 'Last glucose (mg/dL)'],
    'q.optional': ['اختياري', 'اختياري', 'Optionnel', 'Optional'],
    'capture.guided': ['تصوير موجّه', 'تصوير موجّه', 'Prise de vue guidée', 'Guided capture'],
    'capture.open': ['افتح الكاميرا', 'حل الكاميرا', 'Ouvrir la caméra', 'Open camera'],
    'capture.continue': ['واصل التصوير', 'كمّل التصوير', 'Continuer la prise de vue', 'Continue capture'],
    'capture.remove': ['حذف الصورة', 'إمسح التصويرة', 'Supprimer la photo', 'Remove photo'],
    'capture.starting': ['جاري تشغيل الكاميرا...', 'الكاميرا قاعدة تخدم...', 'Démarrage de la caméra...', 'Starting the camera...'],
    'capture.noCamera': [
      'تعذر الوصول إلى الكاميرا. يمكنك اختيار صورة من المعرض.',
      'ما نجمناش نحلو الكاميرا. تنجم تاخو تصويرة من المعرض.',
      'Caméra indisponible. Vous pouvez choisir une photo dans la galerie.',
      'Camera unavailable. You can pick a photo from the gallery.'
    ],
    'capture.hold': ['ثبّت الهاتف...', 'ثبّت التليفون...', 'Ne bougez plus...', 'Hold still...'],
    'capture.tip': [
      'ضع القدم داخل الشكل، مع إضاءة جيدة',
      'حط الساق في وسط الشكل، والضو باهي',
      'Placez le pied dans la forme, avec une bonne lumière',
      'Place the foot inside the shape, in good light'
    ],
    'capture.done': ['تم', 'سالم', 'Terminé', 'Done'],
    'capture.adjust': ['حرّك الإطار بإصبع واحد وغيّر حجمه بإصبعين حتى يناسب قدمك', 'حرّك الرسمة بصبعك، وكبّرها ولا صغّرها بزوز صوابع باش توافق رجلك', 'Déplacez le repère avec un doigt, redimensionnez-le avec deux', 'Drag the outline with one finger, pinch with two to resize'],
    'capture.reset': ['إعادة الضبط', 'رجّعها كيف كانت', 'Réinitialiser', 'Reset'],
    'analyse.s1': [
      'تحضير الصور',
      'نحضّرو التصاور',
      'Préparation des photos',
      'Preparing the photos'
    ],
    'analyse.s2': [
      'قراءة الصور بالذكاء الاصطناعي',
      'قراية التصاور بالذكاء الاصطناعي',
      'Lecture des images par l’IA',
      'Reading the images with AI'
    ],
    'analyse.s2offline': [
      'بدون اتصال: تخطي طبقة الذكاء الاصطناعي',
      'بلا إنترنت: نتخطاو الذكاء الاصطناعي',
      'Hors ligne : couche IA ignorée',
      'Offline: AI layer skipped'
    ],
    'analyse.s3': [
      'تطبيق القواعد السريرية',
      'نطبّقو القواعد الطبية',
      'Application des règles cliniques',
      'Applying the clinical rules'
    ],
    'analyse.s4': [
      'تحرير التقرير',
      'نكتبو التقرير',
      'Rédaction du compte rendu',
      'Writing the report'
    ],
    'level.none': ['لا توجد إشارات إنذار', 'ما فماش علامات إنذار', 'Aucun signe d’alerte', 'No warning sign'],
    'level.yellow': ['يحتاج متابعة', 'لازم تتبّع', 'Surveillance rapprochée', 'Needs monitoring'],
    'level.red': ['استشر طبيبا بسرعة', 'أمشي للطبيب فيسع', 'Consultez rapidement', 'See a professional quickly'],
    'level.label.none': ['أخضر', 'أخضر', 'Vert', 'Green'],
    'level.label.yellow': ['أصفر', 'أصفر', 'Orange', 'Amber'],
    'level.label.red': ['أحمر', 'أحمر', 'Rouge', 'Red'],
    'sens.subtitle': ['اختبار الإحساس في 10 نقاط', 'إختبار الإحساس في 10 نقاط', 'Test de sensibilité, 10 points', 'Sensation test, 10 points'],
    'sens.how': [
      'اطلب من شخص أن يلمس كل نقطة بلطف وأنت مغمض العينين، ثم اضغط على النقطة: ضغطة = أحسست، ضغطتان = لم أحس.',
      'خلي حد يلمسك في كل نقطة وإنت غامض عينيك، وبعد أضغط على النقطة: ضغطة = حسّيت، زوز = ما حسّيتش.',
      'Demandez à quelqu un de toucher chaque point pendant que vous fermez les yeux, puis appuyez sur le point : une fois = senti, deux fois = non senti.',
      'Ask someone to touch each point while your eyes are closed, then tap the point: once = felt, twice = not felt.'
    ],
    'sens.felt': ['أحسست', 'حسّيت', 'Senti', 'Felt'],
    'sens.notFelt': ['لم أحس', 'ما حسّيتش', 'Non senti', 'Not felt'],
    'sens.untested': ['لم يُختبر', 'ما تجرّبش', 'Non testé', 'Not tested'],
    'sens.hallux': ['إبهام القدم', 'الصبع الكبير', 'Gros orteil', 'Big toe'],
    'sens.met1': ['مشط القدم 1', 'تحت الصبع الكبير', 'Tête du 1er métatarsien', '1st metatarsal head'],
    'sens.met3': ['مشط القدم 3', 'وسط القدم', 'Tête du 3e métatarsien', '3rd metatarsal head'],
    'sens.met5': ['مشط القدم 5', 'الجيهة الخارجية', 'Tête du 5e métatarsien', '5th metatarsal head'],
    'sens.heel': ['الكعب', 'الكعب', 'Talon', 'Heel'],
    'sens.numbFound': [
      'نقاط دون إحساس، تحدث مع طبيبك',
      'ثمة نقاط ما تحسّش بيهم، أحكي مع الطبيب',
      'Points sans sensation, parlez-en à votre médecin',
      'Points without sensation, talk to your doctor'
    ],
    'sens.allFelt': [
      'الإحساس محفوظ في كل النقاط المختبرة',
      'الإحساس موجود في الكل',
      'Sensation conservée sur tous les points testés',
      'Sensation preserved on every tested point'
    ],
    'sens.note': [
      'هذا اختبار توجيهي، لا يعوض اختبار الخيط أحادي الشعيرة عند الطبيب.',
      'هذا إختبار توجيهي برك، ما يعوضش الإختبار متاع الطبيب.',
      'Test indicatif, il ne remplace pas le monofilament chez le professionnel.',
      'Indicative test, it does not replace the monofilament test with a professional.'
    ],
    'glu.subtitle': ['تتبّع قياساتك', 'تبّع القياسات متاعك', 'Suivez vos mesures', 'Track your readings'],
    'glu.latest': ['آخر قياس', 'آخر قياس', 'Dernière mesure', 'Latest reading'],
    'glu.trend': ['التطور', 'التطور', 'Évolution', 'Trend'],
    'glu.add': ['قياس جديد', 'قياس جديد', 'Nouvelle mesure', 'New reading'],
    'glu.value': ['القيمة', 'القيمة', 'Valeur', 'Value'],
    'glu.unit': ['الوحدة', 'الوحدة', 'Unité', 'Unit'],
    'glu.moment': ['وقت القياس', 'وقت القياس', 'Moment', 'When'],
    'glu.fasting': ['على الريق', 'على الريق', 'À jeun', 'Fasting'],
    'glu.afterMeal': ['بعد الأكل', 'بعد الماكلة', 'Après le repas', 'After meal'],
    'glu.bedtime': ['قبل النوم', 'قبل الرقاد', 'Au coucher', 'Bedtime'],
    'glu.random': ['وقت آخر', 'وقت آخر', 'Autre moment', 'Other time'],
    'glu.note': ['ملاحظة', 'ملاحظة', 'Note', 'Note'],
    'glu.target': ['المجال المستهدف', 'المجال المطلوب', 'Cible', 'Target range'],
    'glu.readings': ['قياسات', 'قياسات', 'mesures', 'readings'],
    'glu.invalid': ['أدخل قيمة صحيحة', 'حط قيمة صحيحة', 'Entrez une valeur valide', 'Enter a valid value'],
    'glu.savedIn': ['تم الحفظ ✓ القيمة في المجال', 'تسجل ✓ القيمة مليحة', 'Enregistré ✓ valeur dans la cible', 'Saved ✓ value in range'],
    'glu.savedOut': ['تم الحفظ · القيمة خارج المجال', 'تسجل · القيمة برا المجال', 'Enregistré · valeur hors cible', 'Saved · value out of range'],
    'glu.status.in': ['في المجال', 'في المجال', 'Dans la cible', 'In range'],
    'glu.status.out': ['خارج المجال', 'برا المجال', 'Hors cible', 'Out of range'],
    'glu.status.critical': ['قيمة حرجة، استشر', 'قيمة خطيرة، شوف طبيب', 'Valeur critique, consultez', 'Critical value, consult'],
    'well.subtitle': ['كيف تشعر اليوم', 'كيفاش راك اليوم', 'Comment vous sentez-vous', 'How you feel today'],
    'well.question': ['كيف حالك اليوم؟', 'كيفاش راك اليوم؟', 'Comment allez-vous aujourd’hui ?', 'How are you today?'],
    'well.mood0': ['صعب جدا', 'صعيبة برشة', 'Très difficile', 'Very hard'],
    'well.mood1': ['صعب', 'صعيبة', 'Difficile', 'Hard'],
    'well.mood2': ['عادي', 'عادي', 'Moyen', 'Okay'],
    'well.mood3': ['جيد', 'باهي', 'Bien', 'Good'],
    'well.mood4': ['ممتاز', 'باهي برشة', 'Très bien', 'Very good'],
    'well.feelings': ['ما تشعر به', 'إلي تحس بيه', 'Ce que vous ressentez', 'What you feel'],
    'well.tired': ['متعب', 'عيان', 'Fatigué', 'Tired'],
    'well.pain': ['عندي ألم', 'عندي وجيعة', 'J’ai mal', 'In pain'],
    'well.worried': ['قلق', 'قلقان', 'Inquiet', 'Worried'],
    'well.motivated': ['متحفز', 'عندي إرادة', 'Motivé', 'Motivated'],
    'well.calm': ['هادئ', 'مرتاح', 'Calme', 'Calm'],
    'well.alone': ['وحيد', 'وحدي', 'Seul', 'Alone'],
    'well.note': ['ملاحظة', 'ملاحظة', 'Note', 'Note'],
    'well.recent': ['الأيام الأخيرة', 'الأيام لي فاتوا', 'Ces derniers jours', 'Recent days'],
    'well.pickMood': ['اختر حالتك أولا', 'إختار كيفاش راك', 'Choisissez d’abord votre état', 'Pick how you feel first'],
    'well.saved': ['تم الحفظ ✓', 'تسجل ✓', 'Enregistré ✓', 'Saved ✓'],
    'well.support': [
      'إذا كانت الأيام صعبة باستمرار، تحدث مع طبيبك أو شخص تثق به.',
      'كان الأيام صعيبة ديما، أحكي مع الطبيب ولا مع حد تثق فيه.',
      'Si les journées sont difficiles longtemps, parlez-en à votre médecin ou à un proche.',
      'If the hard days keep coming, talk to your doctor or someone you trust.'
    ],
    'report.title': ['تقرير الفحص', 'تقرير الفحص', 'Compte rendu du contrôle', 'Check report'],
    'report.findings': ['ما تمت ملاحظته', 'إلي تلاحظ', 'Observations', 'Observations'],
    'report.advice': ['ما العمل الآن', 'شنوا تعمل توا', 'Que faire maintenant', 'What to do now'],
    'report.send': ['أرسل إلى طبيب', 'إبعثها للطبيب', 'Envoyer à un professionnel', 'Send to a professional'],
    'report.sent': ['تم الإرسال ✓ سيراجع الطبيب الحالة', 'تبعثت ✓ الطبيب باش يشوفها', 'Envoyé ✓ un professionnel va l’examiner', 'Sent ✓ a professional will review it'],
    'report.sentAlready': ['أُرسل إلى الطبيب', 'تبعثت للطبيب', 'Envoyé au professionnel', 'Sent to professional'],
    'report.source.ai': ['تحليل بالذكاء الاصطناعي + قواعد سريرية', 'تحليل ذكي + قواعد طبية', 'Analyse IA + règles cliniques', 'AI analysis + clinical rules'],
    'report.source.rules': ['قواعد سريرية فقط (بدون اتصال)', 'قواعد طبية برك (ما فماش إنترنت)', 'Règles cliniques seules (hors ligne)', 'Clinical rules only (offline)'],
    'report.disclaimer': [
      'هذا ليس تشخيصا. التطبيق يساعد على الرصد والفرز فقط، والقرار النهائي للطبيب.',
      'هذا موش تشخيص. التطبيق يعاون على الرصد برك، والقرار يرجع للطبيب.',
      'Ceci n’est pas un diagnostic. L’outil aide au repérage et au triage ; la décision revient au professionnel.',
      'This is not a diagnosis. The tool supports detection and triage; the decision belongs to the professional.'
    ],
    'report.quality': ['جودة الصور', 'جودة التصاور', 'Qualité des photos', 'Photo quality'],
    'report.confidence': ['درجة الثقة', 'درجة الثقة', 'Confiance', 'Confidence'],
    'report.none': ['لا توجد تقارير', 'ما فماش تقارير', 'Aucun compte rendu', 'No reports yet'],
    'doctor.queue': ['قائمة الحالات', 'الحالات', 'File de cas', 'Case queue'],
    'doctor.empty': ['لا توجد حالات مرسلة', 'ما فماش حالات', 'Aucun cas transmis', 'No submitted cases'],
    'doctor.new': ['جديد', 'جديد', 'Nouveau', 'New'],
    'doctor.reviewed': ['تمت المراجعة', 'تراجعت', 'Validé', 'Reviewed'],
    'doctor.decision': ['قرار الطبيب', 'قرار الطبيب', 'Décision du professionnel', 'Clinician decision'],
    'doctor.confirm': ['تأكيد مستوى الخطورة', 'تأكيد المستوى', 'Confirmer le niveau', 'Confirm level'],
    'doctor.orientation': ['التوجيه', 'التوجيه', 'Orientation', 'Referral'],
    'doctor.ssb': ['مركز صحة أساسية', 'مركز صحة', 'Centre SSB', 'Primary care (SSB)'],
    'doctor.hospital': ['المستشفى الجهوي', 'السبيطار الجهوي', 'Hôpital régional', 'Regional hospital'],
    'doctor.followup': ['متابعة منزلية', 'متابعة في الدار', 'Suivi à domicile', 'Home follow-up'],
    'doctor.note': ['ملاحظة للمريض', 'كلمة للمريض', 'Note au patient', 'Note to patient'],
    'doctor.save': ['حفظ القرار', 'سجّل القرار', 'Enregistrer la décision', 'Save decision'],
    'doctor.saved': ['تم حفظ القرار ✓', 'تسجل القرار ✓', 'Décision enregistrée ✓', 'Decision saved ✓'],
    'doctor.aiSays': ['اقتراح النظام', 'إلي قالو النظام', 'Proposition du système', 'System proposal'],
    'doctor.patientSays': ['إجابات المريض', 'إجابات المريض', 'Réponses du patient', 'Patient answers'],
    'doctor.photos': ['الصور', 'التصاور', 'Photos', 'Photos'],
    'doctor.fhir': ['تصدير FHIR', 'تصدير FHIR', 'Export FHIR', 'FHIR export'],
    'doctor.fhirSub': [
      'حزمة FHIR R4 جاهزة للإرسال إلى النظام الصحي',
      'حزمة FHIR R4 للنظام الصحي',
      'Bundle FHIR R4 prêt pour le SIH',
      'FHIR R4 bundle ready for the hospital system'
    ],
    'doctor.copy': ['نسخ', 'نسخ', 'Copier', 'Copy'],
    'doctor.copied': ['تم النسخ ✓', 'تنسخ ✓', 'Copié ✓', 'Copied ✓'],
    'doctor.case': ['حالة', 'حالة', 'Cas', 'Case'],
    'doctor.waiting': ['في انتظار المراجعة', 'يستنى المراجعة', 'En attente de revue', 'Awaiting review'],
    'settings.title': ['الإعدادات', 'الإعدادات', 'Paramètres', 'Settings'],
    'settings.key': ['مفتاح Gemini API', 'مفتاح Gemini API', 'Clé API Gemini', 'Gemini API key'],
    'settings.keyHint': [
      'يُحفظ على هذا الجهاز فقط. بدونه يعمل التطبيق بالقواعد السريرية.',
      'يتحفظ في التليفون برك. من غيرو التطبيق يخدم بالقواعد الطبية.',
      'Stockée uniquement sur cet appareil. Sans clé, l’app fonctionne avec les règles cliniques.',
      'Stored on this device only. Without it the app runs on clinical rules.'
    ],
    'settings.keyMissing': [
      'لم يتم إعداد مفتاح الذكاء الاصطناعي',
      'مفتاح الذكاء الاصطناعي ما تحطش',
      'Clé IA non configurée',
      'AI key not configured'
    ],
    'settings.test': ['اختبار الاتصال', 'جرب الاتصال', 'Tester la connexion', 'Test connection'],
    'settings.ok': ['الاتصال يعمل ✓', 'الاتصال يخدم ✓', 'Connexion réussie ✓', 'Connection works ✓'],
    'auth.pin': ['رمز سري (4 إلى 6 أرقام)', 'كود سري (4 حتى 6 أرقام)', 'Code PIN (4 à 6 chiffres)', 'PIN code (4 to 6 digits)'],
    'auth.pinHint': [
      'عامل ثان للتحقق. يستعمل أيضا لفك تشفير بياناتك على هذا الجهاز.',
      'عامل ثاني للتأكد. ويفك التشفير متاع المعلومات في التليفون.',
      'Second facteur de connexion. Il déverrouille aussi le chiffrement de vos données sur cet appareil.',
      'Second sign-in factor. It also unlocks the encryption of your data on this device.'
    ],
    'auth.err.pin': ['الرمز السري غير صحيح', 'الكود السري غالط', 'Code PIN incorrect', 'Wrong PIN code'],
    'auth.err.locked': [
      'تم قفل الحساب مؤقتا بعد عدة محاولات خاطئة',
      'الحساب تسكّر شوية بعد محاولات غالطة',
      'Compte bloqué temporairement après plusieurs tentatives',
      'Account temporarily locked after several failed attempts'
    ],
    'auth.lockedFor': ['ثانية متبقية', 'ثانية باقية', 'secondes restantes', 'seconds remaining'],
    'consent.title': ['الموافقة قبل الإرسال', 'الموافقة قبل ما تبعث', 'Consentement avant envoi', 'Consent before sending'],
    'consent.body': [
      'سيطلع الطبيب على صورك وإجاباتك لمراجعة الحالة.',
      'الطبيب باش يشوف تصاورك وإجاباتك باش يراجع الحالة.',
      'Le professionnel verra vos photos et vos réponses pour examiner le cas.',
      'The professional will see your photos and answers to review the case.'
    ],
    'consent.share': [
      'أوافق على إرسال هذا الفحص إلى طبيب',
      'نوافق باش يتبعث الفحص هذا لطبيب',
      'J’accepte de transmettre ce contrôle à un professionnel',
      'I agree to send this check to a professional'
    ],
    'consent.identity': [
      'أوافق على إظهار اسمي (بدونه يظهر رمز فقط)',
      'نوافق باش يبان إسمي (كان لا يبان كود برك)',
      'J’accepte d’être identifié (sinon un pseudonyme est affiché)',
      'I agree to be identified (otherwise a pseudonym is shown)'
    ],
    'security.title': ['الأمان', 'الأمان', 'Sécurité', 'Security'],
    'security.encrypted': [
      'البيانات مشفّرة على هذا الجهاز، والمفتاح يُفتح بكلمة السر',
      'المعلومات مشفّرة في التليفون، والمفتاح يتحل بكلمة السر متاعك',
      'Données chiffrées sur cet appareil, clé déverrouillée par votre mot de passe',
      'Data encrypted on this device, key unlocked by your password'
    ],
    'security.notEncrypted': [
      'التشفير غير مفعّل لهذا الحساب',
      'التشفير موش مفعّل للحساب هذا',
      'Chiffrement non actif pour ce compte',
      'Encryption not active for this account'
    ],
    'security.idle': [
      'يتم تسجيل الخروج تلقائيا بعد 10 دقائق دون نشاط',
      'يخرجك تلقائي بعد 10 دقايق بلا حركة',
      'Déconnexion automatique après 10 minutes d’inactivité',
      'Automatic sign out after 10 minutes of inactivity'
    ],
    'security.audit': ['سجل الوصول', 'سجل الوصول', 'Traçabilité des accès', 'Access trail'],
    'security.reveal': ['إظهار الهوية', 'ورّي الهوية', 'Révéler l’identité', 'Reveal identity'],
    'security.masked': ['هوية مخفية', 'الهوية مخفية', 'Identité masquée', 'Identity masked'],
    'audit.submit': ['إرسال من المريض', 'تبعثت من المريض', 'Transmis par le patient', 'Submitted by patient'],
    'audit.open': ['فتح الملف', 'حل الملف', 'Consultation du dossier', 'Case opened'],
    'audit.validate': ['تأكيد القرار', 'تأكيد القرار', 'Décision validée', 'Decision validated'],
    'audit.reveal': ['إظهار الهوية', 'ورّي الهوية', 'Identité révélée', 'Identity revealed'],
    'risk.title': ['مستوى الخطر', 'مستوى الخطر', 'Niveau de risque', 'Risk level'],
    'risk.subtitle': ['تصنيف IWGDF في 4 أسئلة', 'تصنيف IWGDF في 4 أسئلة', 'Classification IWGDF en 4 questions', 'IWGDF classification in 4 questions'],
    'risk.cta': ['حدد مستوى خطرك', 'حدد مستوى الخطر متاعك', 'Déterminez votre niveau de risque', 'Set your risk level'],
    'risk.intro': [
      'هذه الأسئلة الأربعة تحدد عدد مرات فحص القدم الموصى بها. جاوب حسب ما قاله لك طبيبك.',
      'الأربع أسئلة هاذوما يحددو قداش مرة لازم تتفحص. جاوب كيما قالك الطبيب.',
      'Ces quatre questions déterminent la fréquence de surveillance recommandée. Répondez selon ce que votre médecin vous a dit.',
      'These four questions set the recommended screening frequency. Answer based on what your doctor told you.'
    ],
    'risk.q1': [
      'هل قال لك طبيبك إنك فقدت الإحساس الواقي في قدميك؟',
      'الطبيب قالك إلي ما تحسش مليح بساقيك؟',
      'Votre médecin vous a-t-il dit que vous avez perdu la sensibilité protectrice ?',
      'Has your doctor told you that you lost protective sensation?'
    ],
    'risk.q2': [
      'هل عندك مشكل في الدورة الدموية في الساقين (شرايين)؟',
      'عندك مشكل في الدورة الدموية في ساقيك؟',
      'Avez-vous une artérite des membres inférieurs ?',
      'Do you have peripheral arterial disease?'
    ],
    'risk.q3': [
      'هل عندك تشوه في القدم أو جلد متصلب تحت الضغط؟',
      'عندك تشوه في الساق ولا جلد قاسي؟',
      'Avez-vous une déformation du pied ou une corne sous appui ?',
      'Do you have a foot deformity or callus under pressure?'
    ],
    'risk.q4': [
      'هل سبق أن كان عندك قرحة في القدم أو بتر؟',
      'سبق وكان عندك جرح كبير في ساقك ولا بتر؟',
      'Avez-vous déjà eu un ulcère du pied ou une amputation ?',
      'Have you ever had a foot ulcer or an amputation?'
    ],
    'risk.result': ['النتيجة', 'النتيجة', 'Résultat', 'Result'],
    'risk.cat0': ['الفئة 0 · خطر منخفض', 'الفئة 0 · خطر قليل', 'Catégorie 0 · risque faible', 'Category 0 · low risk'],
    'risk.cat1': ['الفئة 1 · خطر متوسط', 'الفئة 1 · خطر متوسط', 'Catégorie 1 · risque modéré', 'Category 1 · moderate risk'],
    'risk.cat2': ['الفئة 2 · خطر مرتفع', 'الفئة 2 · خطر عالي', 'Catégorie 2 · risque élevé', 'Category 2 · high risk'],
    'risk.cat3': ['الفئة 3 · خطر مرتفع جدا', 'الفئة 3 · خطر عالي برشة', 'Catégorie 3 · risque très élevé', 'Category 3 · very high risk'],
    'risk.freq0': ['فحص مرة في السنة', 'فحص مرة في العام', 'Examen une fois par an', 'Examination once a year'],
    'risk.freq1': ['فحص كل 6 إلى 12 شهرا', 'فحص كل 6 حتى 12 شهر', 'Examen tous les 6 à 12 mois', 'Examination every 6 to 12 months'],
    'risk.freq2': ['فحص كل 3 إلى 6 أشهر', 'فحص كل 3 حتى 6 شهور', 'Examen tous les 3 à 6 mois', 'Examination every 3 to 6 months'],
    'risk.freq3': ['فحص كل شهر إلى 3 أشهر', 'فحص كل شهر حتى 3 شهور', 'Examen tous les 1 à 3 mois', 'Examination every 1 to 3 months'],
    'risk.note': [
      'التصنيف حسب توصيات IWGDF 2023. يبقى تأكيده من قبل الطبيب.',
      'التصنيف حسب توصيات IWGDF 2023. الطبيب هو إلي يأكدو.',
      'Classification selon les recommandations IWGDF 2023, à confirmer par le professionnel.',
      'Classification per the IWGDF 2023 guidelines, to be confirmed by the professional.'
    ],
    'compare.title': ['المقارنة مع الفحص السابق', 'المقارنة مع الفحص لي قبل', 'Comparaison avec le contrôle précédent', 'Compared with the previous check'],
    'compare.since': ['الفحص السابق:', 'الفحص لي قبل:', 'Contrôle précédent :', 'Previous check:'],
    'compare.before': ['سابقا', 'قبل', 'Avant', 'Before'],
    'compare.now': ['اليوم', 'اليوم', 'Aujourd’hui', 'Today'],
    'report.copy': ['نسخ التقرير', 'أنسخ التقرير', 'Copier le compte rendu', 'Copy the report'],
    'doctor.delay': [
      'متوسط زمن المراجعة',
      'متوسط وقت المراجعة',
      'Délai médian de revue',
      'Median review delay'
    ],
    'settings.textSize': ['حجم النص', 'كبر الكتابة', 'Taille du texte', 'Text size'],
    'settings.textSize.1.0': ['عادي', 'عادي', 'Normal', 'Normal'],
    'settings.textSize.1.15': ['كبير', 'كبير', 'Grand', 'Large'],
    'settings.textSize.1.3': ['كبير جدًا', 'كبير برشة', 'Très grand', 'Extra large'],
    'settings.about': [
      'Future Health Connectathon 2026، التحدّي 3.1\nاكتشاف علامات الإنذار في القدم السكرية مبكرًا',
      'Future Health Connectathon 2026، التحدّي 3.1\nنلقاو علامات الخطر في ساق السكّري بكري',
      'Future Health Connectathon 2026, défi 3.1\nRepérer plus tôt les signes d’alerte du pied diabétique',
      'Future Health Connectathon 2026, challenge 3.1\nSpot diabetic foot warning signs earlier'
    ],
    'settings.dev': ['خيارات المطوّر', 'خيارات المطوّر', 'Options développeur', 'Developer options'],
    'settings.devOn': [
      'تم تفعيل خيارات المطوّر',
      'خيارات المطوّر تحلّت',
      'Options développeur activées',
      'Developer options on'
    ],
    'settings.textSizeHint': [
      'للأشخاص الذين يجدون صعوبة في القراءة',
      'للي يقراو بصعوبة',
      'Pour les personnes qui lisent difficilement',
      'For people who find reading difficult'
    ],
    'common.save': ['حفظ', 'سجّل', 'Enregistrer', 'Save'],
    'common.cancel': ['إلغاء', 'بطّل', 'Annuler', 'Cancel'],
    'common.close': ['إغلاق', 'سكّر', 'Fermer', 'Close'],
    'common.retry': ['إعادة المحاولة', 'عاود', 'Réessayer', 'Retry'],
    'common.today': ['اليوم', 'اليوم', 'Aujourd’hui', 'Today'],
    'common.open': ['فتح', 'حلّ', 'Ouvrir', 'Open'],
    'common.error': ['حدث خطأ', 'صار مشكل', 'Une erreur est survenue', 'Something went wrong'],
  };
}
