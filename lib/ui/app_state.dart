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

/// Light, dark, or follow the phone. Follows the phone by default.
final ValueNotifier<ThemeMode> appThemeMode = ValueNotifier<ThemeMode>(ThemeMode.system);

const String _kThemeModeKey = 'khatwa_theme_mode';

Future<void> loadThemeMode() async {
  final prefs = await SharedPreferences.getInstance();
  final stored = prefs.getString(_kThemeModeKey);
  appThemeMode.value = ThemeMode.values.firstWhere(
    (mode) => mode.name == stored,
    orElse: () => ThemeMode.system,
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
