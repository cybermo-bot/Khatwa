# Product

<!-- impeccable:product-schema 1 -->

## Platform

android

## Users

**Patients.** People living with diabetes who need to watch their feet every day. Anyone with a diabetic foot can use Khatwa, but it is built first for the hardest case:

- older, often 55 and over, slower with phones, sometimes helped by family to take the photos;
- limited literacy, including in derja;
- reduced vision, retinopathy being common;
- rural, on low-end phones with weak or patchy data.

Their job: check both feet, soles and insteps, in a few minutes at home, answer a few questions, and know what to do next without having to interpret anything medical themselves. Priority within that group is people already at risk: neuropathy, poor circulation, foot deformity, or a previous ulcer.

**Health professionals.** SSB nurses, general practitioners and diabetologists who receive the cases. Their job: work a queue sorted most serious first, open a case, see the photos, the AI proposal, the patient's answers and risk category, confirm or override the level, choose an orientation, and leave a note. The code assumes a shared clinician workstation may be involved (idle sign out).

## Product Purpose

Khatwa (خطوة, "a step") helps a person with diabetes check their feet every day with their phone, and puts a real health professional at the end of every case.

It exists because the early signs of a diabetic foot (redness, dry skin, a callus, a crack) are visible long before an ulcer, but nobody looks at the bottom of their own feet every day, and many patients physically cannot. Lost sensation means the patient does not feel the injury either.

Success means an early sign reaches a professional while it is still early, and the patient keeps checking daily because it is easy.

Built for the Future Health Connectathon 2026, Tunis, under the patronage of the Tunisian Ministry of Health, Défi 3.1: *repérer plus tôt les signes d'alerte du pied diabétique*. Team NextGen Care owns the product.

## Positioning

Khatwa spots and sorts. A health professional decides. It is never a diagnosis.

The mechanism a neighbouring product cannot truthfully copy is the two-layer triage: deterministic clinical rules that run offline, merged with a multimodal AI read by keeping the **higher** level. The rules can raise the level, never lower it. If the patient reports an open wound, the case is red whatever the model saw. With no key or no network the AI is skipped and the report says so in plain words.

> "The AI can be wrong, so we designed as if it will be. Nothing in the safety path depends on the model or on the network."

Against "send a photo on WhatsApp": guided capture so the photo is usable, structured questions so the professional has context, a severity-sorted queue instead of a chat, a FHIR export with a traceable record of who saw what.

## Operating Context

- **Care pathway:** home, then SSB (basic health centre), then regional hospital. Orientation choices in the app are exactly those: home follow-up, SSB, regional hospital.
- **Patient session:** risk profile once (4 questions, IWGDF 2023 category 0 to 3 and screening frequency), then each check: four guided photos (right sole, left sole, right instep, left instep), eight yes/no red-flag questions plus optional glucose, a result in green, amber or red with what to do next, a same-position comparison with the previous check, consent, send.
- **Patient extras:** 10-point monofilament sensation self-test on two foot maps, glucose log with the target range behind the line, daily streak strip, three text sizes.
- **Clinician session:** queue with counts and median review delay, case review, decision, HL7 FHIR R4 transaction Bundle export.
- **Regulatory frame (Tunisia):** INPDP and law 2004-63 for personal data, Decree 2022-318 for telemedicine, INS and Sahetna.tn for national identity.
- **Evaluation context:** a jury pitch and live demo. The demo runs in Chrome on a laptop and on an Android phone. Demo order is in `RUN_AND_DEMO.md`.

## Capabilities and Constraints

**Real and working:** accounts with hashed passwords and a PIN; encryption at rest (encrypt-then-MAC, key unlocked by the PIN, DEK only in memory); lockout after 5 wrong attempts; sign out after 10 minutes idle; consent required before sending; identity masked to initials plus case number unless the patient consented to be named, with every reveal written to the access trail; the Gemini multimodal call with model fallback; the clinical rule engine; the full path from photo to clinician decision back to the patient; FHIR R4 export (Patient, QuestionnaireResponse, Observation, Media, RiskAssessment, ServiceRequest, Provenance); guided capture on a real camera; four languages with RTL.

**Not real, and must never be described as real:**

- The AI is a general vision model with a clinical prompt, not trained on diabetic foot images, and its accuracy has not been measured.
- The capture guide does not detect a foot. It is a template the patient drags and resizes onto their own foot. Never call it detection.
- Storage is device only. Deployment needs a server, INPDP authorisation and the national health identifier.
- Medical codes in the FHIR export are indicative until SNOMED licensing for Tunisia is confirmed.

**Wording rules:**

- Never say the app diagnoses.
- Never tell a patient their foot is fine. Only that nothing was detected in these photos.
- Never state an accuracy figure.
- Foot photos are sent to Google (Gemini) when the AI layer runs. This must be disclosed, not hidden.

**Terminology:** levels are green, amber, red. "Health professional" or "clinician", not only "doctor". "Check" for a patient session, "case" once it is sent. IWGDF category 0 to 3.

**Technical constraints:**

- Flutter, Dart 3.11 on the owner's machine. `pubspec.yaml` is deliberately loose (`>=3.4.0 <4.0.0`, relaxed carets). Do not tighten it.
- The theme avoids `cardTheme`, `appBarTheme`, `inputDecorationTheme`, `withOpacity` and `withValues` because of SDK version drift. Do not reintroduce them.
- The Gemini API key is never hardcoded or committed. It comes from `--dart-define=GEMINI_API_KEY` or the in-app Settings screen.
- Foot geometry is drawn in code as a closed Catmull-Rom spline (tension 0.85) in `lib/ui/foot_shapes.dart`. Do not replace it with a midpoint smoother.

**Open decisions:**

- Whether the clinician side is used mainly on a phone, a tablet or a desktop workstation.
- An explicit AI consent toggle with a rules-only mode the patient can choose.
- On-device change detection between checks beyond side-by-side comparison.

## Brand Commitments

- **Name:** Khatwa · خطوة, "a step". Arabic and Latin forms are both first-class.
- **Languages:** Tunisian derja is the default, then Arabic, French, English. Layout flips for Arabic and derja.
- **Voice:** plain, calm, direct, honest about limits. Speaks derja the way people speak it, not formal Arabic translated. No alarmism, no false reassurance.
- **Assets:** launcher icon of two footprints stepping forward (`brand/khatwa_icon_1024.png`, Android mipmaps, `web/icons`, `web/favicon.png`); the wordmark on the landing screen built from the plantar print; the foot geometry in `lib/ui/foot_shapes.dart`, shared by the capture guide, the sensation map, the logo and the history rows.
- **Standing visual preference:** the category standard, executed at full craft, with no real-world theme or metaphor (chosen 26 September 2026 after two direction rounds). Craft bar: a mix of Headspace / Calm and Oura, light first rather than dark first, with some of Apple Health's clarity. Calm, soft, premium, smooth motion, easy on the eye every day.
- **Visual identity is open.** The whole look, including the icon, wordmark and palette, may be replaced in the redesign (confirmed 25 September 2026). Only the name carries over as a commitment. The foot geometry stays functional for the capture guide and sensation map until a replacement is built.

## Evidence on Hand

- One Tunisian study (Mahdia, 220 diabetic patients): around 27% already at risk of a foot ulcer. Cited in `README.md`.
- IWGDF 2023 risk categories and screening frequencies, implemented in `lib/data/risk_profile.dart`.
- A working end-to-end build that can be demonstrated live, including the FHIR export.

**Absent, and must not be fabricated:**

- No clinical validator yet (name, role, quote). This is the first jury criterion.
- No accuracy or agreement measurement.
- No real patient photos with consent yet. No data provenance sheet yet.
- No testimonials, users, pilots or partner institutions.

Simulated or generated patient data, photos or results are forbidden by the competition rules and disqualifying. That includes UI mockups, screenshots and demo states: use empty states or the team's own consented test photos, never invented patients.

## Product Principles

1. **The professional decides.** Every screen reinforces that Khatwa spots and sorts, and that a human validates. Nothing reads as a verdict.
2. **Safety never depends on the model or the network.** The rules path works offline and is the floor. Any AI output is additive and labelled as such.
3. **Built for the hardest patient.** If an older person with poor vision and limited reading can complete a check alone on a cheap phone with weak data, everyone can.
4. **Honest by default.** Limits are said out loud, in the app and in the pitch, before anyone asks. No claim without evidence behind it.
5. **Fit the system, not an island.** Cases follow the real Tunisian care pathway and leave as FHIR.

## Accessibility & Inclusion

- **Reduced vision:** three text sizes exist and every layout must survive the largest. High contrast and large touch targets are requirements, not polish.
- **Limited literacy:** meaning cannot depend on reading alone. Level, next step and progress must be carried by shape, icon, position and colour together.
- **Colour:** triage status is never carried by colour alone.
- **Languages and direction:** four languages, full RTL for Arabic and derja, including numerals, icons with direction, and the foot maps.
- **Low-end devices and weak network:** the core check must complete offline through the rules path, and slow or failed AI calls must degrade in plain words, never a spinner without end.
- **Motor and help from others:** capture must work with one hand or with a family member holding the phone.
