import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'strings.dart';

/// App-wide language. Changing it rebuilds the whole app, including direction.
final ValueNotifier<String> appLanguage = ValueNotifier<String>(S.fallback);

/// Text size, for patients with reduced vision. Many people with diabetes have
/// retinopathy, so this is not a cosmetic setting.
final ValueNotifier<double> appTextScale = ValueNotifier<double>(1.0);

const String _kTextScaleKey = 'khatwa_text_scale';

Future<void> loadTextScale() async {
  final prefs = await SharedPreferences.getInstance();
  appTextScale.value = prefs.getDouble(_kTextScaleKey) ?? 1.0;
}

Future<void> saveTextScale(double value) async {
  appTextScale.value = value;
  final prefs = await SharedPreferences.getInstance();
  await prefs.setDouble(_kTextScaleKey, value);
}

/// Light, dark, or follow the phone. Light by default (design A); the
/// patient can choose dark or the phone's setting in Settings.
final ValueNotifier<ThemeMode> appThemeMode =
    ValueNotifier<ThemeMode>(ThemeMode.light);

const String _kThemeModeKey = 'khatwa_theme_mode';

Future<void> loadThemeMode() async {
  final prefs = await SharedPreferences.getInstance();
  final stored = prefs.getString(_kThemeModeKey);
  appThemeMode.value = ThemeMode.values.firstWhere(
    (mode) => mode.name == stored,
    orElse: () => ThemeMode.light,
  );
}

Future<void> saveThemeMode(ThemeMode mode) async {
  appThemeMode.value = mode;
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_kThemeModeKey, mode.name);
}

/// Skin tone of the foot drawings: 'fair', 'medium' or 'deep'. The patient
/// picks the one closest to their own feet, because redness and colour
/// change look different on different skin.
final ValueNotifier<String> appSkinTone = ValueNotifier<String>('medium');

const String _kSkinToneKey = 'khatwa_skin_tone';

Future<void> loadSkinTone() async {
  final prefs = await SharedPreferences.getInstance();
  appSkinTone.value = prefs.getString(_kSkinToneKey) ?? 'medium';
}

Future<void> saveSkinTone(String tone) async {
  appSkinTone.value = tone;
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_kSkinToneKey, tone);
}

/// Compact language switcher used in page headers.
class LanguageButton extends StatelessWidget {
  const LanguageButton({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: S.t(appLanguage.value, 'app.language'),
      icon: const Icon(Icons.language_rounded, size: 22),
      onSelected: (value) => appLanguage.value = value,
      itemBuilder: (context) => [
        for (final language in S.languages)
          PopupMenuItem<String>(
            value: language,
            child: Row(
              children: [
                if (language == appLanguage.value)
                  const Icon(Icons.check_rounded, size: 16)
                else
                  const SizedBox(width: 16),
                const SizedBox(width: 8),
                Text(language),
              ],
            ),
          ),
      ],
    );
  }
}

/// Language switch that names the current language, for the first screens:
/// someone who cannot read the current language still finds their own.
class LanguagePill extends StatelessWidget {
  const LanguagePill({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return PopupMenuButton<String>(
      tooltip: S.t(appLanguage.value, 'app.language'),
      onSelected: (value) => appLanguage.value = value,
      position: PopupMenuPosition.under,
      itemBuilder: (context) => [
        for (final language in S.languages)
          PopupMenuItem<String>(
            value: language,
            height: 48,
            child: Row(
              children: [
                if (language == appLanguage.value)
                  const Icon(Icons.check_rounded, size: 18)
                else
                  const SizedBox(width: 18),
                const SizedBox(width: 10),
                Text(language, style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
      ],
      child: Container(
        constraints: const BoxConstraints(minHeight: 44),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: scheme.outline, width: 1.2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.translate_rounded, size: 18, color: scheme.primary),
            const SizedBox(width: 8),
            Flexible(
              child: Text(appLanguage.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: scheme.onSurface)),
            ),
            const SizedBox(width: 2),
            Icon(Icons.expand_more_rounded, size: 18, color: scheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
