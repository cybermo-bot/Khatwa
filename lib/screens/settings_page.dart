import 'package:flutter/material.dart';

import '../data/ai_gateway.dart';
import '../ui/app_state.dart';
import '../ui/app_theme.dart';
import '../ui/foot_art.dart';
import '../ui/foot_shapes.dart';
import '../ui/strings.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final key = TextEditingController();
  bool testing = false;
  bool obscure = true;

  /// The AI key is a team tool, not a patient setting. Seven taps on the
  /// Khatwa card reveal it, as Android does for its developer options.
  bool developer = false;
  int _aboutTaps = 0;

  String get lang => appLanguage.value;

  @override
  void initState() {
    super.initState();
    if (ApiConfig.source == 'device') key.text = ApiConfig.key;
  }

  @override
  void dispose() {
    key.dispose();
    super.dispose();
  }

  void _tapAbout() {
    if (developer) return;
    _aboutTaps++;
    if (_aboutTaps >= 7) {
      setState(() => developer = true);
      kToast(context, S.t(lang, 'settings.devOn'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return KPage(
      title: S.t(lang, 'settings.title'),
      actions: const [LanguageButton()],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 14),
          KSectionLabel(S.t(lang, 'settings.textSize')),
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 4, bottom: 12),
            child: Text(S.t(lang, 'settings.textSizeHint'), style: K.small),
          ),
          ValueListenableBuilder<double>(
            valueListenable: appTextScale,
            builder: (context, scale, _) => _ChoiceRow(
              children: [
                for (final (option, sample) in const [
                  (1.0, 17.0),
                  (1.15, 22.0),
                  (1.3, 27.0),
                ])
                  _ChoiceTile(
                    selected: scale == option,
                    label: S.t(lang, 'settings.textSize.$option'),
                    onTap: () => saveTextScale(option),
                    // The sample shows the step itself, so it ignores the
                    // current scale.
                    top: Text(
                      'Aa',
                      textScaler: TextScaler.noScaling,
                      style: TextStyle(
                        fontFamily: K.family,
                        fontSize: sample,
                        height: 1,
                        fontWeight: FontWeight.w600,
                        color: scale == option ? K.primaryStrong : K.ink,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          KSectionLabel(S.t(lang, 'settings.theme')),
          const SizedBox(height: 4),
          ValueListenableBuilder<ThemeMode>(
            valueListenable: appThemeMode,
            builder: (context, mode, _) => _ChoiceRow(
              children: [
                for (final (value, icon, name) in const [
                  (ThemeMode.system, Icons.brightness_auto_outlined, 'system'),
                  (ThemeMode.light, Icons.light_mode_outlined, 'light'),
                  (ThemeMode.dark, Icons.dark_mode_outlined, 'dark'),
                ])
                  _ChoiceTile(
                    selected: mode == value,
                    label: S.t(lang, 'settings.theme.$name'),
                    onTap: () => saveThemeMode(value),
                    top: Icon(
                      icon,
                      size: 26,
                      color: mode == value ? K.primaryStrong : K.inkSoft,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          KSectionLabel(S.t(lang, 'settings.skin')),
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 4, bottom: 12),
            child: Text(S.t(lang, 'settings.skinHint'), style: K.small),
          ),
          ValueListenableBuilder<String>(
            valueListenable: appSkinTone,
            builder: (context, current, _) => _ChoiceRow(
              children: [
                for (final tone in SkinTone.all)
                  _ChoiceTile(
                    selected: current == tone.name,
                    label: S.t(lang, 'settings.skin.${tone.name}'),
                    onTap: () => saveSkinTone(tone.name),
                    top: SizedBox(
                      height: 64,
                      width: 36,
                      child: CustomPaint(
                        painter: FootArtPainter(
                          side: FootSide.right,
                          view: FootView.top,
                          tone: tone,
                          ground: current == tone.name
                              ? K.primarySoft
                              : K.surface,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _tapAbout,
            child: Padding(
              padding: const EdgeInsetsDirectional.symmetric(horizontal: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Khatwa', style: K.h2),
                  const SizedBox(height: 6),
                  Text(S.t(lang, 'app.tagline'), style: K.small),
                  const SizedBox(height: 12),
                  Text(S.t(lang, 'settings.about'), style: K.small),
                ],
              ),
            ),
          ),
          if (developer) ...[
            const SizedBox(height: 28),
            KSectionLabel(S.t(lang, 'settings.dev')),
            _developerCard(),
          ],
        ],
      ),
    );
  }

  Widget _developerCard() {
    final configured = ApiConfig.hasKey;
    return KCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          KBanner(
            text: configured
                ? '${S.t(lang, 'settings.key')} · ${ApiConfig.source == 'build' ? '--dart-define' : 'device'}'
                : S.t(lang, 'settings.keyMissing'),
            icon: configured
                ? Icons.check_circle_outline_rounded
                : Icons.warning_amber_rounded,
            color: configured ? K.ok : K.warn,
            background: configured ? K.okSoft : K.warnSoft,
          ),
          const SizedBox(height: 16),
          KField(
            label: S.t(lang, 'settings.key'),
            controller: key,
            obscure: obscure,
            hint: 'AIza...',
            suffix: IconButton(
              icon: Icon(
                obscure
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                size: 20,
                color: K.muted,
              ),
              onPressed: () => setState(() => obscure = !obscure),
            ),
          ),
          Text(S.t(lang, 'settings.keyHint'), style: K.small),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () async {
              await ApiConfig.setKey(key.text);
              if (!mounted) return;
              setState(() {});
              kToast(context, S.t(lang, 'common.save'));
            },
            child: Text(S.t(lang, 'common.save')),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: testing
                ? null
                : () async {
                    setState(() => testing = true);
                    final ok = await AiGateway.testKey();
                    if (!mounted) return;
                    setState(() => testing = false);
                    kToast(
                      context,
                      ok ? S.t(lang, 'settings.ok') : S.t(lang, 'common.error'),
                      error: !ok,
                    );
                  },
            icon: testing
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.wifi_tethering_rounded, size: 18),
            label: Text(S.t(lang, 'settings.test')),
          ),
        ],
      ),
    );
  }
}

/// Three equal choices side by side, all as tall as the tallest.
class _ChoiceRow extends StatelessWidget {
  final List<Widget> children;

  const _ChoiceRow({required this.children});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            Expanded(child: children[i]),
            if (i < children.length - 1) const SizedBox(width: 10),
          ],
        ],
      ),
    );
  }
}

/// One settings choice: a picture of the option on top, its name below.
/// The name gets the full tile width, so it never breaks mid-word.
class _ChoiceTile extends StatelessWidget {
  final bool selected;
  final String label;
  final Widget top;
  final VoidCallback onTap;

  const _ChoiceTile({
    required this.selected,
    required this.label,
    required this.top,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      label: label,
      excludeSemantics: true,
      child: KPressable(
        onTap: onTap,
        child: AnimatedContainer(
          duration: KMotion.standard,
          constraints: const BoxConstraints(minHeight: 108),
          padding: const EdgeInsets.fromLTRB(6, 12, 6, 12),
          decoration: BoxDecoration(
            color: selected ? K.primarySoft : K.surface,
            borderRadius: BorderRadius.circular(K.r20),
            border: Border.all(
              color: selected ? K.primary : K.control,
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 64, child: Center(child: top)),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: K.label.copyWith(
                  color: selected ? K.primaryStrong : K.ink,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
