---
version: 1
slug: "lib-screens-patient-home-dart"
primary_target: "lib/screens/patient_home.dart"
related_targets: []
---

# Patient home

**Scope:** `lib/screens/patient_home.dart`, the first surface of the full-app redesign. Every later screen inherits the system this one establishes.
**Mode:** Operate. The patient completes one task a day and checks one status.
**Audience and job:** older patients with diabetes at home, often with low vision and limited literacy, on a low-end Android. Each day: see whether today's check is done, start it in one tap, see the last result and whether a professional has reviewed it, reach the tools.
**Constraints:** no invented scores, durations or accuracy; the traffic colours only ever mean a triage level; three text sizes must reflow cleanly; RTL for Arabic and derja; light and dark themes.
**Unresolved:** a wordmark and launcher icon for the new identity (the old ones are replaceable, not yet replaced).

## Direction contract

THESIS: One calm daily moment. Today's check is drawn as the patient's own two feet and nothing competes with it. Refuses the category's default arrangement: a greeting over a progress ring, stat cards and a grid of identical tool tiles.

OWN-WORLD: Soft daylight. A cool pale ground (never cream), white surfaces, deep slate ink, one calm indigo primary with a soft periwinkle tint; depth from tonal fills and one soft low shadow, never hairline boxes everywhere. Generous continuous radii. Readex Pro for Arabic and Latin. Green, amber and red appear only as triage levels. Night is a deep blue-slate with the same roles, lifted.

STORY: The patient understands at a glance whether today is done, starts the check with one tap, sees their last result and whether a professional has looked at it, and finds every tool in a quiet grouped list.

FIRST VIEWPORT: Date and greeting at the top, small. The Today panel takes roughly half the screen: both feet drawn large with the four photo positions, one legend, one full-width Start button at thumb height. The week as seven days below it. The last result row begins at the fold.

FORM: The category standard, played straight at full craft (chosen after two direction rounds; seed key 4f115a82). Signature interaction: the feet breathe slowly while today's check waits and fill in, position by position, when it is done. Motion grammar: soft emphasized-decelerate entrances once per screen, spring press feedback, predictive back.

FINISH: unreviewed and undocumented is unfinished; this build ends with the finish review, the verdict, DESIGN.md, and every shipping raster carrying its provenance
