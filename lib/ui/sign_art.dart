/// Illustrations of what each warning sign and each care act looks like.
///
/// Since design v3 they are images in `assets/images/` (see [KImage]), not
/// drawings. They are teaching illustrations, never real patient photos.
library;

import 'k_image.dart';

enum ArtKind {
  dryskin,
  heelCracks,
  callus,
  corn,
  blister,
  fungus,
  nails,
  redness,
  swelling,
  colour,
  wound,
  numbness,
  wash,
  dry,
  moisturise,
  nailCare,
  shoes,
  move,
}

ArtKind? artFor(String articleId) {
  const map = {
    'dry-skin': ArtKind.dryskin,
    'heel-cracks': ArtKind.heelCracks,
    'callus': ArtKind.callus,
    'corn': ArtKind.corn,
    'blister': ArtKind.blister,
    'fungus': ArtKind.fungus,
    'nails': ArtKind.nails,
    'redness': ArtKind.redness,
    'swelling': ArtKind.swelling,
    'colour': ArtKind.colour,
    'wound': ArtKind.wound,
    'numbness': ArtKind.numbness,
    'wash': ArtKind.wash,
    'dry': ArtKind.dry,
    'moisturise': ArtKind.moisturise,
    'nail-care': ArtKind.nailCare,
    'socks-shoes': ArtKind.shoes,
    'move': ArtKind.move,
  };
  return map[articleId];
}

/// The illustrations of an article, first one as the hero. Empty when the
/// article is not about something you can see.
List<String> articleImages(String articleId) {
  const map = {
    'healthy': ['sign_healthy'],
    'howto-check': ['care_check_mirror'],
    'dry-skin': ['sign_dry_skin'],
    'heel-cracks': ['sign_heel_cracks'],
    'callus': ['sign_callus'],
    'corn': ['sign_corn'],
    'blister': ['sign_blister'],
    'fungus': ['sign_fungus'],
    'nails': ['sign_ingrown_nail', 'sign_nail_fungus'],
    'redness': ['sign_redness'],
    'swelling': ['sign_swelling'],
    'colour': ['sign_black_toe'],
    'wound': ['sign_wound'],
    'numbness': ['care_touch_test'],
    'wash': ['care_wash'],
    'dry': ['care_dry_toes'],
    'moisturise': ['care_moisturise'],
    'nail-care': ['care_nails'],
    'socks-shoes': ['care_shoes', 'care_socks'],
    'move': ['care_move'],
    'beach': ['life_beach', 'care_no_barefoot'],
    'hammam': ['life_hammam'],
    'ramadan': ['life_ramadan'],
    'summer': ['life_summer'],
    'food': ['food_plate'],
  };
  // A picture still to be made gives way to the next one that exists.
  final list = map[articleId] ?? const <String>[];
  final present = [for (final n in list) if (KImage.exists(n) != false) n];
  return present.isEmpty && list.isNotEmpty ? [list.last] : present;
}
