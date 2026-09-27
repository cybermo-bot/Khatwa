# Night tasks (cloud session), before the Telehealth Connect demo

One session does everything below, in this order, on **one branch
`demo/night`** started from `redesign/phase-0` (fetch it first). Commit after
each task with a clear message. Nobody else edits the app tonight, so you may
touch any file under `lib/`, `test/`, `web/`, `assets/` and `pubspec.yaml`.
Do not touch `supabase/migrations/` (the live database follows them).

When you finish, or if you run out of time, push the branch. If you cannot
push, make a git bundle (`git bundle create demo-night.bundle redesign/phase-0..demo/night`)
and say where it is. End with a short report: what is done, what is not, and
the list "À faire par Mozart" (settings only he can change, see task 2).

## Context

Khatwa is a Flutter app (Android + web) for people with diabetes in Tunisia:
daily foot check, a 3D twin of the foot, a voice assistant in Tunisian derja,
a doctor dashboard, all on Supabase (URL and publishable key are in
`lib/data/cloud.dart`). Languages: derja (default, Arabic script), Arabic,
French, English; strings live in `lib/ui/strings.dart` (`S.t(lang, key)`) and
in `LearnLabels`/`T(...)` in `lib/data/learn_content.dart`; the new features
use `tr(fr, aeb:, ar:, en:)` in `lib/features/common.dart`. Design: see
`DESIGN.md` ("design A": light by default, white cards with thin borders, pill
buttons, floating labelled tab bar). The doctor dashboard (`lib/doctor/`) has
its own dark palette and must stay dark by default.

The compute server (3D reconstruction, voice) runs on a laptop and is not
reachable from the cloud: code that calls it must compile and fail softly.

Rules: `flutter analyze` with no issues (fix the existing warnings in
`lib/data/ai_engine.dart` too), `flutter test` green, `flutter build web
--release` succeeds. User-facing text in the four languages, no long dashes in
user text, never a real name in demo data, the app never diagnoses, urgent
signs always lead to 190. Match the surrounding code style.

---

## 1. The sign-in screens, modern and light

`lib/screens/auth_pages.dart` (landing, sign-in) and `create_account.dart`
still have the old look. Redesign them in design A: generous white space, the
Khatwa mark, a short promise line, one clear primary action, big touch
targets, a language switch always visible, right-to-left for Arabic scripts.
Keep the patient/doctor choice but make it lighter (two tiles or a segmented
choice). A soft visual (the 3D model foot `assets/models/foot_holo.glb`
turning slowly, or an image from `assets/images/` with the KImage fallback)
is welcome if it stays fast.

## 2. Guest, "stay signed in", and an e-mail code instead of the PIN

- **Continuer en invité** on the landing page: creates a guest patient on the
  spot (see `_demoQuickStart` in `lib/main.dart`, move that logic into the
  auth store and reuse it), no data typed, clearly labelled "invité", with a
  way to turn it into a real account later.
- **Rester connecté** checkbox on sign-in: when ticked, the account stays
  signed in across app restarts and the 10 minute idle lock is not applied
  (see `AuthStore.idleTimeout`, `idleExpired`, `lock`). Unticked keeps today's
  behaviour. Remember the choice per device.
- **Remove the PIN** ("second password"). Replace it with a **6-digit code
  sent by e-mail** through Supabase Auth: `signInWithOtp(email:)` then
  `verifyOTP(email:, token:, type: OtpType.email)`.
  - Sign-up asks for name, e-mail and password; the e-mail is confirmed with
    the code. The phone number becomes optional.
  - Sign-in is e-mail + password, then the code, except on a device where
    "Rester connecté" was ticked in the last 30 days.
  - The local data key is today wrapped with the PIN (`auth_store.dart`,
    `crypto_box.dart`): wrap it with a key derived from the password instead
    (same PBKDF2 style), and keep existing PIN accounts able to sign in.
  - If the code cannot be sent (Supabase's built-in mail allows only a few
    e-mails an hour), say so kindly and offer "Continuer en invité".
  - Doctors: signing in with the demo doctor's e-mail and password should
    also sign in to Supabase, so the dashboard shows live data without the
    separate "Connecter aux données" dialog (keep the dialog as a fallback).
- Put in your final report, under "À faire par Mozart":
  Supabase → Authentication → Emails → "Magic Link" template must contain
  `{{ .Token }}` (for example "Votre code Khatwa : {{ .Token }}"); a custom
  SMTP (for example Resend or Brevo, free tiers) so codes reach any address;
  OTP length 6.
- Tests for: guest creation, stay-signed-in skipping the idle lock, the
  sign-up form validation.

## 3. One language per page

Some pages mix languages (for example the 3D foot stage shows derja zone
labels after switching to English). Audit every screen in the four languages
and fix it: widgets that captured the language once must rebuild when
`appLanguage` changes; every visible string goes through `S.t`, `T` or `tr`.
The pages in `lib/features/` (scan, twin, sole photo, sign photo, voice) are
mostly French: translate them fully. The doctor dashboard may stay French but
must follow the app language for French and English at least. Add a test that
renders the main tabs in each language and fails if a Latin-script string
appears in an Arabic-script page (allowing numbers, "3D", "SAMU 190", brand
names).

## 4. Nutrition: what to eat, and how much

A new feature "Alimentation" (entry from the Today tiles and from Learn),
four languages, design A, `lib/features/diet/`:

- **Assiette équilibrée**: the plate method (half vegetables, a quarter
  protein, a quarter starch), hand-size portions, water not sugary drinks.
- **Aliments tunisiens**: a searchable list with, for each food, a usual
  portion, grams of carbohydrate per portion, and advice in three levels
  (librement / en portion mesurée / rarement, petite part) with a better swap.
  At least: tabouna, baguette, pain complet, couscous, makrouna, riz,
  lablabi, chorba, brik, fricassé, mlawi, chapati, bsissa, assida, dattes
  (deglet nour), figues, raisin, pastèque, melon, orange, jus de fruits,
  boissons gazeuses, thé à la menthe sucré, café, lait, yaourt, fromage,
  huile d'olive, pois chiches, lentilles, fèves, œufs, poisson, poulet,
  makroudh, baklawa, bambalouni, zlabia, mkharek, samsa, ghraïba, kaak warka,
  bouza, halwa chamia, miel, confiture. A portion calculator (slider for the
  number of portions shows the carbohydrate total).
- **Ramadan**: fasting safely with diabetes (IDF-DAR practical guidelines):
  talk to the doctor before, iftar with dates in small number and water,
  sweets at iftar in small portions, suhoor late, glucose checks do not break
  the fast, when to break the fast (hypoglycaemia or very high glucose).
- **Hypoglycémie**: signs and the 15 g / 15 minutes rule.
- **Why it matters for the feet**: steady glucose helps wounds heal.
- Carbohydrate values from a reliable table (USDA FoodData Central, or the
  Tunisian INNTA food composition table when available); cite the source of
  each value in a code comment. Mark the content "à valider par un
  diététicien" like the Learn articles (`reviewed: false`).
- Tests: every food has all four languages, a portion and a carb value; the
  search finds foods by any language name.

## 5. Real videos in the Learn video slots

Each Learn article shows `LearnLabels.video` ("La vidéo avec l'équipe
soignante est en préparation") in `_VideoSlot` (`lib/screens/article_page.dart`).
Replace it with a specific, short, trustworthy YouTube video per article
(foot care for diabetes, the precise topic of that article):

- Prefer, in order: Arabic or Tunisian speakers, French (Fédération Française
  des Diabétiques, Assurance Maladie / ameli, HAS, hospitals), then English
  (NHS, Diabetes UK, IWGDF/D-Foot, ADA, Mayo Clinic, university hospitals).
  No product advertising, no miracle cures.
- **Verify every video exists and can be embedded**:
  `https://www.youtube.com/oembed?url=https://www.youtube.com/watch?v=ID&format=json`
  must return 200. Record title and channel next to each id.
- Store the ids with the articles (per language where you find good ones,
  falling back to another language with a note "vidéo en français/anglais").
- Show a thumbnail (`https://img.youtube.com/vi/ID/hqdefault.jpg`) with a play
  button; play inline with `youtube_player_iframe` (works on Android and web)
  or open YouTube with `url_launcher` if embedding fails.
- Keep a line under the video: "Vidéo externe, choisie par l'équipe Khatwa".

## 6. Recheck everything

Run the app in the web build and go through every screen and flow in the four
languages, light and dark, text scale 1.3, a narrow phone and a wide screen.
Fix errors, overflows, dead buttons, placeholder text, mixed languages.
Make sure nothing crashes when the compute server or Supabase is unreachable.

## 7. If time remains

- **Messages du médecin** for the patient: a card on Today and a screen that
  shows the doctor's replies live (`KhatwaCloud.messages()`, `sendMessage`),
  and the next visit date set by the doctor (`patients.next_visit`).
- **First launch**: three short onboarding cards (what Khatwa does, the 3D
  foot, the voice assistant), skippable, four languages.
- **Web app polish**: `web/manifest.json` name "Khatwa", theme colour, icons,
  page title, so it looks like an app when opened from the QR code; a small
  "Démo : n'entrez pas de données réelles" note on web.
- Accessibility labels on the main buttons, visible focus, contrast checks.
