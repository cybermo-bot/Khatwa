# Cloud tasks for the Telehealth Connect demo (29 Sep 2026)

Two tasks run in parallel in Claude Code cloud sessions while the local session
builds the server, the 3D twin, the sole mapping and the voice assistant
inside the app. Read this whole file, then do only your task.

## Rules for every task

- Start from branch `redesign/phase-0`. Work on your own branch (named in the
  task) and push it when done. Commit in small steps with clear messages.
- Flutter 3.41.1 is installed by the environment's setup script. If `flutter`
  is not on PATH, run `export PATH="$HOME/flutter/bin:$PATH"`.
- Before you finish: `flutter analyze` shows no issues, `flutter test` passes,
  and `flutter build web --release` succeeds. Say in your final message what
  you could not finish.
- Touch only the files your task owns. Do **not** edit `pubspec.yaml` (every
  package you may use is already there: `supabase_flutter`, `model_viewer_plus`,
  `fl_chart`, `qr_flutter`, plus the existing ones), `supabase/`, `lib/data/`,
  or files owned by the other task.
- `supabase/migrations/0001_khatwa_demo.sql` is the data contract: model
  classes must match its tables and columns.
- User-facing text in French (keep existing Arabic and derja strings). No long
  dashes in user-facing text. Never show a real name: patients have pseudonyms
  ("Patient 07") and a reference like `k-7f3a9c2b1d`.
- Health wording: the app never diagnoses. Measurements are "recherche, seuils
  provisoires". Urgent signs always point to 190.
- Match the surrounding code style. No secrets in the code.

## Design direction (both tasks)

"Clinical futuristic", for an audience of ministers, doctors and international
decision makers, still readable by older patients:

- Dark by default (deep navy, around #07131A to #0C1F29), with the existing
  light theme kept as an option. Teal primary (#0E5A66 family, brighter
  #19C3B5 for glows on dark), mint and soft white text. Red only for urgent.
- Frosted glass cards (BackdropFilter blur, 1 px light border, subtle inner
  glow), soft radial gradient lights in the background, bento grids for
  dashboards, generous spacing, rounded 24 px.
- Readex Pro (bundled). Large clear numbers (tabular figures). Contrast at
  least 4.5:1, works at text scale 1.3, right-to-left for Arabic.
- Motion: short (200 to 300 ms) implicit animations, no gimmicks.
- 3D: `model_viewer_plus` with `assets/models/foot_model.glb` (a model left
  foot, glTF, metres, y up, sole on y = 0). `assets/models/foot_regions.json`
  gives the 3D position and normal of each foot zone on that model, for pins
  (model-viewer hotspots: `data-position="x y z"`, `data-normal="x y z"`).

---

## Task A: doctor dashboard v2 (branch `demo/doctor-dashboard`)

Owns: `lib/doctor/**` (new), `lib/screens/doctor_home.dart`,
`lib/screens/doctor_network.dart` (may be replaced), `test/doctor_*_test.dart`.

1. **Data layer** in `lib/doctor/data/`:
   - `models.dart`: Patient, Scan, Finding, Check, Alert, Message, Share,
     matching the SQL contract.
   - `doctor_repository.dart`: an abstract `DoctorRepository` with streams
     (patients, alerts, messages of a patient) and actions (acknowledge an
     alert, mark a finding reviewed or healed, send a message, set the next
     visit, population statistics). The local session will add the Supabase
     implementation, so keep it stream based.
   - `demo_repository.dart`: `DemoDoctorRepository`, deterministic synthetic
     data: 16 patients (pseudonyms, ages 38 to 81, types 1 and 2, IWGDF risk
     0 to 3, spread over Tunisian governorates), 1 to 4 scans each with
     plausible measurement trends, findings in several zones and levels,
     30 days of daily checks, a few messages, and alerts including two urgent
     ones (a blackened toe reported by voice, a wound under the ball of the
     foot). A "Démo live" switch makes a new alert arrive every 40 s, so the
     live board can be shown even without a network.
2. **Screens**, responsive (three panes from 1100 px wide, two on a tablet,
   one on a phone):
   - **Triage board**: bento KPIs (patients suivis, alertes urgentes, lésions
     actives, contrôles du jour), urgent-first list with a live pulse on new
     alerts, filters (risk, governorate, level) and search by pseudonym or
     reference.
   - **Patient view**: header (pseudonym, age, type, IWGDF risk, governorate,
     last check); the 3D foot with finding pins placed from
     `foot_regions.json`, left/right toggle, a visit timeline slider over the
     scans (use a scan's `glb_path` URL when the repository gives one, else the
     model foot); measurement trends (fl_chart) marked "recherche, seuils
     provisoires"; sole photo gallery (placeholder tiles when missing);
     findings with status and level; daily check history; messages. Actions:
     acknowledge an alert, mark a finding reviewed or healed (clinician only),
     reply, set the next visit, "Exporter FHIR" (a callback) with a
     "Validé sur IHE Gazelle" badge area.
   - **Vue santé publique** (for decision makers): lesions of all patients on
     one 3D foot (pins sized by count per zone), risk category distribution,
     alerts per week, counts by governorate (a styled grid or list of the 24
     governorates; a map only if it needs no heavy dependency).
   - `doctor_home.dart` opens the new dashboard; keep any existing doctor
     sign-in step working.
3. **Tests**: the demo repository's invariants (ids unique, urgent alerts
   present, every finding's zone exists in `foot_regions.json`) and a widget
   test that the triage board renders the KPIs and the urgent patients first.

---

## Task B: new look (branch `demo/new-look`)

Owns: `lib/ui/**`, `DESIGN.md`, and the visual code of these screens:
`shell.dart`, `tabs/check_tab.dart`, `tabs/learn_tab.dart`,
`tabs/journal_tab.dart`, `tabs/me_tab.dart`, `article_page.dart`,
`auth_pages.dart`, `create_account.dart`, `capture_guide.dart`,
`foot_check.dart`, `sensory_check.dart`, `settings_page.dart`,
`glycemia.dart`, `wellbeing.dart`, `medical_information.dart`,
`risk_profile_page.dart`, `report_view.dart`, `saved_ai_report.dart`,
`feature_pages.dart`.
Does **not** touch: `tabs/today_tab.dart` (the new 3D home, local session),
`ai_chatbot.dart`, `foot_photo.dart`, `lib/data/**`, anything doctor.

1. **Theme v3** in `app_theme.dart`: dark default plus the light theme, new
   tokens added next to the existing ones (keep existing public names so the
   rest of the app still compiles), a `GlassCard` widget, background gradient
   lights, a bento grid helper, restyled buttons, chips, inputs and a frosted
   bottom navigation bar. Update `DESIGN.md` to describe v3.
2. **No more hand-drawn feet.** Replace every use of `FootArtPainter`,
   `FootMapPainter`, `SignArt`, `FootGuidePainter`, `FootBadgePainter`,
   `FeetPair` and the drawings in `foot_shapes.dart` with images from
   `assets/images/`. Names: `sign_dry_skin`, `sign_heel_cracks`,
   `sign_callus`, `sign_corn`, `sign_blister`, `sign_fungus`,
   `sign_ingrown_nail`, `sign_nail_fungus`, `sign_redness`, `sign_swelling`,
   `sign_black_toe`, `sign_wound`, `sign_healthy`, `care_check_mirror`,
   `care_wash`, `care_dry_toes`, `care_moisturise`, `care_nails`,
   `care_shoes`, `care_socks`, `care_no_barefoot`, `care_move`,
   `care_touch_test`, `scan_setup`, `scan_helper`, `scan_sole`, `hero_twin`,
   `hero_doctor` (all `.png`). The images are being generated now and may not
   exist yet: add a `KImage` widget that shows the asset, or a tasteful
   placeholder (glass tile, icon, short label) when the file is missing, so the
   app builds and looks finished either way.
3. **Tap maps.** Where the patient taps a zone of the foot (daily check), use
   `assets/images/map_sole.png` and `map_top.png` (rendered from the 3D model
   by the local session; placeholder until then) with tappable zones from a
   new `assets/images/map_zones.json` (normalised polygons, zone names as in
   `foot_regions.json`; make a sensible first version).
4. Behaviour and texts stay the same: this task changes looks only.
