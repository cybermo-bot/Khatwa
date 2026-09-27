---
name: Khatwa
description: Daily diabetic foot checks at home, with a health professional at the end of every case.
colors:
  ground: "#F2F4F5"
  surface: "#FFFFFF"
  surface-muted: "#E8EDEF"
  ink: "#14232A"
  ink-soft: "#3F5058"
  muted: "#5F6F76"
  line: "#DDE4E7"
  control: "#76878E"
  primary: "#0E5A66"
  primary-strong: "#0A434D"
  primary-soft: "#DDECEE"
  on-primary: "#FFFFFF"
  accent: "#7A4A88"
  accent-soft: "#F2EAF5"
  ok: "#3A7D1F"
  ok-soft: "#E6F2DC"
  warn: "#9A5E00"
  warn-soft: "#FBEDD5"
  danger: "#C0352B"
  danger-soft: "#FBE7E4"
  shadow: "#14323A"
  night-ground: "#07131A"
  night-surface: "#0D2029"
  night-surface-muted: "#132C37"
  night-ink: "#EAF6F3"
  night-ink-soft: "#BCD2D0"
  night-muted: "#93ADB0"
  night-line: "#1E3B46"
  night-control: "#62868E"
  night-primary: "#19C3B5"
  night-primary-strong: "#8CEBDD"
  night-primary-soft: "#0F3A3E"
  night-on-primary: "#03211F"
  night-accent: "#CBA8E8"
  night-accent-soft: "#261F36"
  night-ok: "#8BD68A"
  night-ok-soft: "#15301C"
  night-warn: "#F0B85C"
  night-warn-soft: "#33280F"
  night-danger: "#FF7D72"
  night-danger-soft: "#3D1716"
  night-glass: "#0F2430 at 62%"
  night-glass-border: "#E6FFFB at 14%"
  night-glow: "#19C3B5"
  night-mint: "#8CEBDD"
  night-light-a: "#19C3B5 at 25%"
  night-light-b: "#0E5A66 at 20%"
  glass: "#FFFFFF at 78%"
  glass-border: "#DDE4E7"
  glow: "#0E5A66"
  mint: "#1F7A6E"
  skin-fair: "#F0CBAE"
  skin-medium: "#E2AE88"
  skin-deep: "#9C6644"
  marker-on-skin: "#0B4F5A"
  urgent-on-skin: "#A8231B"
typography:
  display:
    fontFamily: "Readex Pro"
    fontSize: "34px"
    fontWeight: 600
    lineHeight: 1.12
  headline:
    fontFamily: "Readex Pro"
    fontSize: "26px"
    fontWeight: 600
    lineHeight: 1.2
  title:
    fontFamily: "Readex Pro"
    fontSize: "19px"
    fontWeight: 600
    lineHeight: 1.3
  body:
    fontFamily: "Readex Pro"
    fontSize: "17px"
    fontWeight: 400
    lineHeight: 1.5
  body-strong:
    fontFamily: "Readex Pro"
    fontSize: "17px"
    fontWeight: 500
    lineHeight: 1.45
  small:
    fontFamily: "Readex Pro"
    fontSize: "14.5px"
    fontWeight: 400
    lineHeight: 1.4
  label:
    fontFamily: "Readex Pro"
    fontSize: "13.5px"
    fontWeight: 500
    lineHeight: 1.3
  button:
    fontFamily: "Readex Pro"
    fontSize: "17px"
    fontWeight: 600
rounded:
  well: "12px"
  control: "16px"
  button: "20px"
  surface: "24px"
  hero: "28px"
  pill: "999px"
spacing:
  gutter: "20px"
  card: "18px"
  hero: "22px"
  section: "30px"
  tile-gap: "12px"
  choice-gap: "10px"
  touch: "48px"
  row: "64px"
components:
  button-primary:
    backgroundColor: "{colors.primary}"
    textColor: "{colors.on-primary}"
    typography: "{typography.button}"
    rounded: "{rounded.button}"
    height: "56px"
  button-primary-disabled:
    backgroundColor: "{colors.surface-muted}"
    textColor: "{colors.muted}"
    rounded: "{rounded.button}"
    height: "56px"
  button-tonal-on-hero:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.primary-strong}"
    rounded: "{rounded.button}"
    height: "56px"
  button-tonal:
    backgroundColor: "{colors.primary-soft}"
    textColor: "{colors.primary-strong}"
    rounded: "{rounded.button}"
    height: "56px"
  button-outlined:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.ink}"
    rounded: "{rounded.button}"
    height: "56px"
  button-text:
    textColor: "{colors.primary}"
    height: "48px"
  card:
    backgroundColor: "{colors.surface}"
    rounded: "{rounded.surface}"
    padding: "18px"
  hero-panel:
    backgroundColor: "{colors.primary-soft}"
    textColor: "{colors.primary-strong}"
    rounded: "{rounded.hero}"
    padding: "22px"
  group-row:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.ink}"
    typography: "{typography.body-strong}"
    padding: "10px 12px 10px 16px"
    height: "64px"
  field:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.ink}"
    rounded: "{rounded.control}"
    padding: "16px"
  banner:
    backgroundColor: "{colors.primary-soft}"
    textColor: "{colors.primary-strong}"
    rounded: "{rounded.control}"
    padding: "14px 16px"
  tag:
    backgroundColor: "{colors.surface-muted}"
    textColor: "{colors.ink-soft}"
    rounded: "{rounded.pill}"
    padding: "5px 10px"
  choice-tile:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.ink}"
    typography: "{typography.label}"
    rounded: "{rounded.surface}"
    padding: "12px 6px"
    height: "108px"
  choice-tile-selected:
    backgroundColor: "{colors.primary-soft}"
    textColor: "{colors.primary-strong}"
    rounded: "{rounded.surface}"
  nav-bar:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.muted}"
    typography: "{typography.label}"
    height: "74px"
  nav-bar-selected:
    backgroundColor: "{colors.primary-soft}"
    textColor: "{colors.primary-strong}"
---

# Design System: Khatwa

## v3 "Clinical futuristic" (demo, September 2026)

v3 is the look of the Telehealth Connect demo, for an audience of ministers,
doctors and international decision makers, still readable by older patients.
It changes looks only: behaviour and texts are those of v2. Where this section
and the v2 text below disagree, **v3 wins**; the v2 text is kept for the rules
that still hold (triage colours, control edges, sentence case, tabular
figures, nav scale cap, full width labels, one trailing affordance).

### Theme
- **Dark by default.** `appThemeMode` starts at dark (`lib/ui/app_state.dart`).
  Light (the v2 day palette, unchanged) and "follow the phone" stay in Settings.
- **Night palette v3:** deep navy ground `#07131A`, surfaces `#0D2029`, soft
  white ink `#EAF6F3`, bright teal `#19C3B5` for action and glow, mint
  `#8CEBDD` for text on teal washes. Red only for urgent. All body text pairs
  clear 4.5:1 on ground and surface.
- **New tokens** in `KPalette` and `K` (the v2 names are all kept):
  `glass`, `glassBorder`, `glow`, `mint`, `lightA`, `lightB`, `K.r24`,
  `K.number` (34, 600, tabular figures), `K.glassDecoration()`.

### Surfaces
- **`KBackdrop`:** the ground lit by two soft radial teal lights (top start,
  low end). Every `KPage`, the shell and `BasePage` sit on it. Decorative only.
- **`GlassCard`:** frosted glass: background blur (18), translucent fill with a
  faint top light, 1 px light edge, rounded 24, a deep soft shadow at night.
  `glow: true` adds a teal halo for the one thing that matters most on a
  screen (the daily check card, the Learn hero). `tint` makes a flat tinted
  card (triage panels). Blur uses `BackdropFilter.grouped` inside the
  backdrop's `BackdropGroup`, so many cards cost one blur pass.
- **`KCard` and `KGroup`** are now glass cards, same API.
- **`KFrosted`:** a frosted strip; used by the page bottom bar and by
  **`KFrostedNavBar`**, the patient app's navigation bar (text scale capped
  at 1.0 as before, indicator rounded 16 on primary-soft).
- **`KBento` / `KBentoTile` / `KStat`:** bento grid for dashboards: two
  columns on a phone, four from 700 px, tiles span 1 or 2, a row shares the
  tallest height; `KStat` is a glass number tile (big tabular number, label,
  icon).
- Buttons round 20, outlined buttons, chips, fields and segmented buttons
  are glass at night with the glass edge; focus is teal.

### Motion
200 to 300 ms implicit animations (`KMotion.standard` 280, `gentle` now 300).
No gimmicks; everything still goes still with reduced motion.

### Illustrations: no more drawn feet
All code-drawn feet are gone (`FootArtPainter`, `FeetPair`, `SignArt`,
`SignPainter`, `FootShape`, `FootGuidePainter`, `FootBadgePainter`).
Illustrations are images in `assets/images/*.png`, shown by **`KImage`**
(`lib/ui/k_image.dart`). While an image does not exist yet, `KImage` shows a
glass tile with a soft teal light, an icon and an optional short label, so
every screen looks finished either way.

| Where | Image |
| --- | --- |
| Articles (`articleImages()` in `lib/ui/sign_art.dart`) | `sign_*`, `care_*` (nails adds `sign_nail_fungus`, socks and shoes adds `care_socks`, beach uses `care_no_barefoot`) |
| Learn hero | `sign_healthy` |
| Daily check banner | `scan_setup` |
| Logo | `khatwa_logo` (brand icon) |
| Photo positions, slots, capture chips, capture ghost | `map_sole`, `map_top` via `FootMap` |

Not yet placed: `scan_helper`, `scan_sole`, `hero_twin`, `hero_doctor`
(`hero_twin` is meant for the 3D Today tab, owned by the local session).

### Tap maps
**`FootMap`** (`lib/ui/foot_map.dart`) shows `map_sole.png` or `map_top.png`
(rendered from the 3D model) with zones from `assets/images/map_zones.json`:
normalised polygons named as in `assets/models/foot_regions.json`, for a
LEFT foot with the big toe on the right edge, 1:2 portrait; the right foot is
the mirror. Zones can be highlighted (breathing with a pulse), selected, and
tapped (`onZoneTap`, with semantics buttons per zone), and markers can be
placed on the map. While the images are missing, the zones draw a quiet
mosaic of the foot. `FootMapPair` shows both feet, left on the left; feet
never mirror for right-to-left. App teaching zones map to map zones through
`FootZone.regions`. The sensory check places its test points on the sole map
and lights the zone of any point not felt.

The skin tone setting is kept; it now shows round skin swatches.

---


This file records the patient app as built at the end of Phase 0 (the five-tab shell, articles, settings). It is derived from the shipped code in `lib/ui/app_theme.dart`, `lib/ui/foot_art.dart`, `lib/ui/sign_art.dart`, `lib/ui/foot_shapes.dart`, `lib/screens/shell.dart`, `lib/screens/tabs/`, `lib/screens/article_page.dart` and `lib/screens/settings_page.dart`. Phases 1 to 5 build on it. The finish review passed with disposition "ship" after four rounds; the current captures are `.impeccable/review/round4` (160 renders from the Flutter test renderer, light and dark, four languages).

**Not yet verified on a device.** The test renderer does not run real motion or render shadows the way a phone does. Motion timing, the breathing markers, the press spring and the soft lift shadow are recorded here from code, not from a device capture. A capture on a real Android phone is still owed.

## Overview

**Creative North Star: "Petrol and Skin"**

A calm foot care companion in the category standard of good health apps, executed at full craft: a cool morning ground, white surfaces, deep ink, and one petrol blue that means "act here". The one thing that is Khatwa's own is the patient's feet, drawn in code in the skin tone the patient chose, carrying every task and every warning sign at the place on the foot where it happens. Skin colour lives only inside those drawings; the interface never borrows it.

The world has no real-world theme or metaphor, by the user's choice (seed 4f115a82, category standard, 26 September 2026). The craft bar is Headspace and Calm with Oura, light first, with Apple Health clarity. Density is low: one idea per surface, large type (body at 17), 48 px minimum touch targets, 56 px buttons, and three text sizes that every layout must survive. Four languages (Tunisian derja by default, Arabic, French, English) with full right-to-left layout for Arabic and derja.

Night is not an inverted day. It is a deep petrol dark with the same roles lifted, flat, with hairline borders where day uses a shadow.

**Key Characteristics:**
- One petrol action colour; green, amber and red are reserved for triage.
- Feet drawn in skin tone are the identity and the main illustration system.
- Soft, rounded surfaces on a pale ground, one low shadow in day, tone and hairlines at night.
- Readex Pro alone, sentence case everywhere, no tracked labels.
- Motion is soft and short, and all of it goes still when the phone asks for less motion.

## Colors

A cool, low-chroma neutral ground with one saturated petrol for action, a tide wash for hero fields, and a triage trio held back for meaning.

### Primary
- **Deep Petrol** (primary): every primary action, selected states, focus, links, the routine tick when done, the next-photo ring. Night: Lifted Petrol (night-primary) on dark text (night-on-primary).
- **Harbour Petrol** (primary-strong): text and icons that sit on the tide wash (hero panel titles and body, banner text, selected nav label and icon, selected choice tile label, tabular counts).
- **Tide Wash** (primary-soft): the hero field behind the Today check panel and article heroes, the nav indicator, selected choice tiles, the default banner, icon wells, tonal buttons.

### Tertiary
- **Clinician Plum** (accent, accent-soft): set as the Material 3 tertiary role so stock components never derive colour from elsewhere. It does not appear on patient Phase 0 surfaces. Do not introduce it into patient screens without a system decision.

### Triage (reserved)
- **Leaf** (ok, ok-soft), **Amber** (warn, warn-soft), **Signal Red** (danger, danger-soft): triage levels green, amber and red. The strong tone carries icons and headings, the soft tone is the panel behind them. On soft panels each strong tone clears 4.3:1 or better. Level is never shown by colour alone: `LevelDot` pairs the colour with a level icon, and the headline names the level.

### Neutral
- **Morning Ground** (ground): the page background behind everything.
- **Surface White** (surface): cards, grouped lists, fields, the navigation bar, the bottom action bar.
- **Mist** (surface-muted): tags, the video placeholder slot, disabled button fill.
- **Deep Ink** (ink): titles, strong body, icons.
- **Slate Ink** (ink-soft): running body text.
- **Muted Slate** (muted): small text, secondary lines, chevrons and quiet icons on ground or surface only.
- **Hairline** (line): dividers inside grouped lists, the nav bar top edge, the header edge once content scrolls, and night-mode surface borders. It is 1.3:1 against white; it separates, it never outlines a control.
- **Control Edge** (control): the border of anything the patient must find and operate (tick circles, text fields, choice tiles, chips). 3.7:1 on surface and 3.4:1 on ground in day; 3.5:1 and 4.0:1 at night.

### Skin (illustrations only)
- **Fair, Medium, Deep** (skin-fair, skin-medium, skin-deep): the base tone of each skin set. Each set also has light, shade, pad and nail tones (see `SkinTone` in `lib/ui/foot_art.dart` and the sidecar). Medium is the default; the patient picks in Settings.
- **Marker Petrol** (marker-on-skin) and **Marker Red** (urgent-on-skin): fixed, unthemed colours for zone markers painted on skin, because skin does not change with the theme.

### Named Rules
**The Triage Colour Rule.** Green, amber and red only ever mean a triage level. Nothing decorative, no status that is not a level, and no success toast borrows them as a hue. If a new screen needs "done" or "ok", use petrol.

**The Control Edge Rule.** A control's border uses `K.control`, never `K.line`. The hairline is for separation; anything the patient must find at a glance needs 3:1 against both surface and ground.

**The Tinted Panel Rule.** Small text on a tinted panel (tide wash, triage soft panels) uses `inkSoft`, the panel's strong tone, or ink. Never `muted`: it falls to 4.3:1 on the tide wash and 4.4:1 on the red panel.

**The Skin Stays in the Feet Rule.** Skin tones never appear in interface chrome, and interface colours never tint skin.

## Typography

**Display Font:** Readex Pro (bundled, weights 400, 500, 600, 700; no fallback is relied on)
**Body Font:** Readex Pro
**Label Font:** Readex Pro

**Character:** one humanist family that sets Arabic and Latin with the same voice, so derja, Arabic, French and English sit on the same rhythm. Weight does the hierarchy work; there is no second family.

### Hierarchy
- **Display** (600, 34, 1.12): large numbers only, for example the latest glucose reading on Today, with tabular figures.
- **Headline** (600, 26, 1.2): page titles in the header and hero panel titles.
- **Title** (600, 19, 1.3): section labels, card titles, article summaries (set at 500, 1.4 there).
- **Body** (400, 17, 1.5): running text, in ink-soft.
- **Body strong** (500, 17, 1.45): row titles, field labels, sign tile titles, "read more" links.
- **Small** (400, 14.5, 1.4): subtitles, dates, notes, hints, in muted on ground or surface.
- **Label** (500, 13.5, 1.3): photo numbers, nav labels, choice tile names, calendar initials, counts.
- **Button** (600, 17): filled buttons; outlined and text buttons use 500 at 16.

### Named Rules
**The Sentence Case Rule.** Section headings are set like titles in sentence case. There are no tracked, uppercase labels or eyebrows above headings anywhere in the build, and none should be added.

**The Tabular Figures Rule.** Counts, dates, glucose values and calendar days use tabular figures so they do not jitter.

**The Nav Scale Cap Rule.** The navigation bar clamps its own text scale to 1.0 so five labels fit on a narrow phone in every language. Page content always keeps the patient's full text size (1.0, 1.15 or 1.3). Nothing else caps text scale.

## Layout

Single column, phone first. `KPage` gives every screen the same frame: a header (headline title, optional small subtitle, back button when the route can pop, trailing actions), a scrolling body with 20 px side gutters (4 top, 36 bottom), and an optional bottom action bar on surface with a hairline top edge. Content is capped at 720 px wide and centred on large screens.

Rhythm on the tabs: 10 px from header to the first panel, about 30 px between sections on Today (26 to 32 elsewhere), section labels with 6 px above and 10 px below, 18 px inside cards, 22 px inside hero panels. Grouped rows are at least 64 px tall (routine rows 66 px). Tiles in a grid use a 12 px gap; Settings choice rows use 10 px.

Grids: the warning-sign atlas is two columns, three above 560 px of width. Tiles in the same row share one height whatever the title length or text size. Settings choices are always three equal tiles side by side, all as tall as the tallest.

Direction: text and layout flip for Arabic and derja using directional padding and alignment. The feet never flip: they are anatomy, drawn left foot on the left as the person looks down.

The Today first viewport is the check panel on the tide wash, taking most of the screen, with the five-destination navigation bar always visible. Each tab keeps its own scroll position; detail screens open above the bar.

### Named Rules
**The Full Width Label Rule.** A tile's name gets the full tile width under its picture, never a column squeezed beside an icon, so it never breaks mid-word at the largest text size.

**The One Trailing Affordance Rule.** A row carries at most one trailing element: a chevron when the whole row opens something, or one text button, or one value. Never a chevron and a button together.

## Elevation & Depth

Hybrid, and deliberately quiet. In day, raised white surfaces (cards, grouped lists, the sign tiles, the Check and Journal panels) carry one soft, low shadow in two layers. Tinted panels (the tide hero, triage panels, banners) are flat: their colour is their depth. At night there are no shadows; raised surfaces get a 1 px hairline border in night-line and rely on the surface-over-ground tone step.

The page header has no shadow. It gains a hairline bottom edge only once the content scrolls, and loses it at the top.

### Shadow Vocabulary
- **Lift** (two layers in `shadow` #14323A: alpha 14/255, blur 24, offset 0 8; and alpha 10/255, blur 3, offset 0 1): every raised white surface in day. Not verified on a device yet.

### Named Rules
**The One Lift Rule.** There is one shadow in the system. No second elevation step, no coloured shadows, no hard offset shadows. A surface with its own colour gets no shadow.

## Shapes

Soft, generous corners in a clear hierarchy from large to small: hero fields 28, surfaces 24, buttons 18, controls and inset thumbnails 16, icon wells 12, and pills fully round for tags. The triage `LevelDot` is a rounded square at 36 percent of its size. Tick circles, the avatar, the taken-photo badge and calendar day selections are circles.

Note for developers: the constants in `K` are named `r12`, `r14`, `r20`, `r28` but `r14` is 16 and `r20` is 24. Use the values in the frontmatter as the truth. The direction contract planned 20 for surfaces; the build shipped 24.

The foot outline is a closed Catmull-Rom spline (tension 0.85) in `lib/ui/foot_shapes.dart`, shared by the illustrations, the capture guide, the sensation map and history rows. Do not replace it with a different smoother.

## Components

### Buttons
Full width, tall and plain.
- **Shape:** gently rounded (18).
- **Primary (filled):** petrol with white text, 56 tall, full width, no elevation. Disabled is mist with muted text. Usually carries a leading icon (camera for Start).
- **Tonal:** harbour petrol text on tide wash (Check tab, after today's check), or on white when the button sits inside the tide hero (Today, "see today's result").
- **Outlined:** ink on white, 56 tall, 16 at weight 500. Destructive outlined (sign out) currently uses danger text; see the drift note in Do's and Don'ts.
- **Text:** petrol, 48 by 48 minimum, 16 at weight 500. Used as the one trailing action in a row (add a glucose reading, "check now" on a flagged journal entry).
- **Press:** platform ripple (InkSparkle) with no highlight fill.

### Pressable surfaces (`KPressable`)
Anything tappable that is not a stock button: a soft spring down to 0.975 scale on press (140 ms), a spring back (280 ms, ease out back), a petrol ripple at low alpha, a petrol focus fill for keyboard and switch access, and button semantics. No scale when reduced motion is on.

### Cards and grouped lists
- **Card (`KCard`):** white, 24 corners, 18 padding, the lift in day, a hairline at night. A card given its own colour is flat. A card with `onTap` becomes pressable.
- **Group (`KGroup`):** rows share one white surface divided by hairlines inset 68 px from the start edge.
- **Group row (`KGroupRow`):** at least 64 tall; a 38 px icon well at 12 corners tinted from the row colour, body strong title, optional small subtitle, then one trailing affordance (chevron if tappable).
- **Section label (`KSectionLabel`):** title style, sentence case, optional trailing value (for example "3 / 5").

### Hero panel (Today check panel)
Tide wash at 28 corners, 22 padding. Headline and body in harbour petrol, the four photo positions drawn as feet, a label count, and one full-width button. The Check tab repeats the structure on white with the lift.

### Inputs / Fields (`KField`)
- **Style:** body strong label above, 8 gap; white fill, 16 corners, 16 padding, 17 ink text, muted hint at 16; border 1.2 in control.
- **Focus:** border 2 in primary, petrol cursor.
- **Error:** border in danger (2 when focused), error text 13.5 in danger.

### Banners, notes and tags
- **Banner (`KBanner`):** a soft panel at 16 corners with an icon and 14.5 text at weight 500 in the panel's strong tone. Default is tide wash with harbour petrol. Triage-coloured banners are for triage-level messages only.
- **Note (`KNote`):** a quiet footnote with no container: an 18 px muted icon and small text. Used for "pending clinical review", security and disclaimer lines.
- **Tag (`KTag`):** a pill on mist, 13 at weight 500 in ink-soft, optional 14 px icon. On the tide hero it sits on white in harbour petrol.

### Choice tiles (Settings)
Three equal tiles in a row: a 64 px picture of the option on top (an "Aa" sample at its real size, a theme icon, or a foot in that skin tone), the name below at full width. Unselected: white with a 1 px control border. Selected: tide wash, 2 px primary border, name in harbour petrol at 700. At least 108 tall. Pressable.

### Routine rows (Today)
A 34 px tick circle (2 px control border when open, petrol fill with a white check when done, the check scales in) as its own target, then the title, which opens the matching article with one chevron. Done titles fall to muted. The check step is ticked by the app when today's check is done and cannot be toggled by hand.

### Navigation
A Material 3 navigation bar, 74 tall, on white with a hairline top edge. Five destinations (Today, Check, Journal, Learn, Me), labels always shown. Icons 25, outlined when idle and filled when selected. Idle in muted; selected in harbour petrol at 600 on a tide wash indicator. Label 13.5, text scale capped at 1.0. Android back from any tab returns to Today first. Page transitions use predictive back on Android.

### Foot illustrations (signature)
- **Feet (`FootArtPainter`, `FeetPair`):** sole or top view in the chosen skin tone: a soft top-to-heel gradient from light to base, a blurred shade rim for volume, pads and creases on the sole, nails and a tendon highlight on the top, a crisp shade edge.
- **Zone markers:** a white separation ring around a petrol ring with a petrol centre, so a marker can never be read as a mark on the skin. Nothing filled across the skin, nothing blurred. While a task is pending, a thin echo ring grows and fades (the breath); it settles when the task is done and is still under reduced motion.
- **Photo positions (`PhotoPositions`):** the four photos of a check in capture order (right sole, left sole, right top, left top). Taken ones carry a petrol check badge; the next one gets a breathing petrol outline. Pending feet keep full skin colour and are told apart by the number label, not by fading.
- **Sign drawings (`SignArt`, `lib/ui/sign_art.dart`):** 12 authored warning-sign drawings (dry skin, heel cracks, callus, corn, blister, fungus, nails, redness, swelling, colour change, wound, numbness) and 6 care acts (wash, dry, moisturise, nail care, socks and shoes, move), drawn in code on the patient's skin tone inside a tide or red-soft well. They are teaching drawings, never presented as patient photographs.

### Named Rules
**The Full Skin Rule.** Illustrations never fade or wash out skin. A faded foot reads as discoloured skin, which is itself a warning sign. Show state with rings, badges and labels.

**The Drawn Not Photographed Rule.** No invented patient data anywhere: no sample names, scores, readings, photos, streaks or results in the UI or in demo states. Empty states say so plainly. Teaching drawings are the only depiction of a foot until the team has consented photos.

### Motion
Tokens (`KMotion`): quick 140 ms, standard 280 ms, gentle 460 ms; emphasized curve (0.05, 0.7, 0.1, 1.0) for entrances, standard curve (0.2, 0, 0, 1) for state changes, exit curve (0.3, 0, 0.8, 0.15). `KReveal` is a one-time entrance: content rises 14 px and fades in over 460 ms, staggered 60 ms by order. Every animation checks `KMotion.reduced` and becomes an instant change when the phone asks for less motion. Motion is recorded from code only; device verification is owed.

## Do's and Don'ts

### Do:
- **Do** build every new screen on `KPage`, `KCard`, `KGroup`, `KGroupRow`, `KField`, `KBanner`, `KNote`, `KTag` and `KPressable`, and read colours from `K`, never hex literals.
- **Do** use petrol for every action and every "done"; keep one filled primary button per surface.
- **Do** carry triage level with colour, icon and words together (`LevelDot` plus the level headline).
- **Do** border controls with `K.control`, and give focus a 2 px primary border.
- **Do** use `inkSoft` or stronger for small text on tinted panels.
- **Do** keep touch targets at 48 px or more and primary buttons at 56 px.
- **Do** test every new layout at text scale 1.3, in Arabic right to left, and in night mode.
- **Do** give tile labels the full tile width and let tiles in a row share one height.
- **Do** keep skin at full colour in every drawing, and show state with rings, badges and labels.
- **Do** gate every animation on `KMotion.reduced`.

### Don't:
- **Don't** use green, amber or red for anything that is not a triage level, including success toasts, API status, legends and destructive actions.
- **Don't** invent patient data, sample values, streaks, scores or photos, even in empty or demo states.
- **Don't** put more than one trailing affordance on a row.
- **Don't** border a control with `K.line`.
- **Don't** set `muted` small text on the tide wash or on triage soft panels.
- **Don't** cap text scale anywhere except the navigation bar (capped at 1.0).
- **Don't** fade, tint or lower the opacity of skin in illustrations.
- **Don't** add tracked uppercase labels or eyebrows above headings, a second shadow, or a second typeface.
- **Don't** mirror the feet for right-to-left languages.
- **Don't** reintroduce `cardTheme`, `appBarTheme`, `inputDecorationTheme`, `withOpacity` or `withValues` in the theme (SDK drift).

### Known drift and deferred work (not part of the system)
These exist in the Phase 0 build and are recorded so nobody copies them:
- Non-triage uses of the triage hues: the Journal legend marks a done check with a green dot; the hidden developer section shows API key status in green or amber; the Me tab sign-out button uses red text; the Journal symptom flag uses amber for a logged red-flag symptom. Each should be reviewed against the Triage Colour Rule.
- The breathing loops use literal durations (2200 ms on Today, 2000 ms in articles); `KMotion.breath` (4200 ms) is defined but unused. Pick one token.
- Phase 2: the "Quand consulter" article hero is still a 64 px icon tile instead of a drawing.
- Phase 2: the heel-cracks drawing is the weakest of the sign drawings and should be redrawn.
- Owed: a device capture to verify motion and the lift shadow.
