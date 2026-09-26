---
version: 1
slug: "lib-screens-shell-dart"
primary_target: "lib/screens/shell.dart"
related_targets: ["lib/screens/tabs/today_tab.dart","lib/screens/tabs/learn_tab.dart","lib/screens/patient_home.dart"]
---

# Patient app (five-tab shell)

**Scope:** `lib/screens/shell.dart` and `lib/screens/tabs/` (Today, Check, Journal, Learn, Me), plus `lib/screens/article_page.dart`, `lib/ui/foot_art.dart`, `lib/ui/app_theme.dart`. Phase 0 of the full-app redesign; supersedes the single-page patient home and its brief. Phase 1 (new check flow and report) and later phases inherit this system.
**Mode:** Operate (Today, Check, Journal, Me) and Read (Learn, articles).
**Audience and job:** older Tunisian patients with diabetes at home, often low vision and limited literacy, low-end Android. Daily: know whether today's check is done and start it, tick the care routine, read one tip, log blood sugar. Occasionally: look back in the journal, learn to recognise early warning signs and when to see a doctor.
**Constraints:** no invented patient data, scores, durations or accuracy; green, amber and red only ever mean a triage level; three text sizes; RTL for Arabic and derja; light and dark; education content from IWGDF 2023, marked pending clinical review; videos are honest placeholders until the care team records them.
**Unresolved:** new wordmark and launcher icon; derja copy for Learn (falls back to Arabic); full weekly photo protocol (between toes, heel) arrives in Phase 1.

## Direction contract

THESIS: A foot care companion, not a single scrolling page. The patient's own feet, drawn in skin tone, carry the identity: every task and warning sign is shown on the foot where it happens. Refuses the category kit of identical icon tiles, progress rings and stat cards.

OWN-WORLD: Petrol and skin. Morning ground (#F2F4F5), white surfaces, deep ink (#14232A), one petrol blue (#0E5A66) for action with a tide wash (#DDECEE) for hero fields; skin tones only inside illustrations. Readex Pro alone, body at 17. Radius hierarchy: 28 hero fields, 20 surfaces, 16 controls, pills. Soft single low shadow in light; tone in dark. Night is deep petrol (#0C1417) with lifted roles.

STORY: Open the app, see today's check and start it in one tap; tick today's care routine; read today's tip; find any warning sign in the atlas, see where it shows on the foot, what to do at home, when to see a professional, and call 190 in one tap when it is urgent.

FIRST VIEWPORT: Today tab. Greeting and date small at the top. The check panel (tide field) takes most of the screen: both soles in skin tone with breathing markers on the zones to check, the photo count, one full-width Start button. "Your care today" begins at the fold. Five-destination navigation bar always visible.

FORM: Category standard (canon) at full craft, chosen after two rounds; seed key 4f115a82. Craft bar: Headspace / Calm with Oura, light first, Apple Health clarity, Flo-style journal. Signature interaction: zone markers breathe on the drawn feet (check panel, articles) and settle when the task is done; routine ticks spring in; predictive back; reduced motion makes all of it still.

FINISH: unreviewed and undocumented is unfinished; this build ends with the finish review, the verdict, DESIGN.md, and every shipping raster carrying its provenance
