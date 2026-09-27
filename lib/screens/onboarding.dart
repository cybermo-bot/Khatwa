import 'package:flutter/material.dart';

import '../ui/app_state.dart';
import '../ui/app_theme.dart';
import '../ui/strings.dart';
import 'auth_pages.dart' show LandingVisual;

/// First launch: what Khatwa does, the 3D foot, the voice assistant.
/// Three short cards, skippable, never shown again.
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _pages = PageController();
  int _index = 0;

  static const _count = 3;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _next() {
    if (_index == _count - 1) {
      finishOnboarding();
      return;
    }
    _pages.nextPage(duration: KMotion.standard, curve: KMotion.emphasized);
  }

  Widget _visual(int i, double height) {
    if (i == 1) return LandingVisual(height: height);
    final icon = i == 0 ? Icons.health_and_safety_outlined : Icons.mic_rounded;
    return ExcludeSemantics(
      child: Container(
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(K.r28),
          gradient: RadialGradient(radius: 0.9, colors: [K.primarySoft, K.ground]),
        ),
        child: Center(
          child: Container(
            width: height * 0.46,
            height: height * 0.46,
            decoration: BoxDecoration(color: i == 2 ? K.primary : K.surface, shape: BoxShape.circle, boxShadow: [
              BoxShadow(color: K.glow.withAlpha(60), blurRadius: 30, spreadRadius: -4),
            ]),
            child: Icon(icon, size: height * 0.22, color: i == 2 ? K.onPrimary : K.primary),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = appLanguage.value;
    return Scaffold(
      backgroundColor: K.ground,
      body: SafeArea(
        child: LayoutBuilder(builder: (context, box) {
          final visual = (box.maxHeight * 0.36).clamp(160.0, 320.0);
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 8, 0),
                    child: Row(children: [
                      const Flexible(child: LanguagePill()),
                      const Spacer(),
                      TextButton(onPressed: finishOnboarding, child: Text(S.t(lang, 'onb.skip'))),
                    ]),
                  ),
                  Expanded(
                    child: PageView.builder(
                      controller: _pages,
                      itemCount: _count,
                      onPageChanged: (i) => setState(() => _index = i),
                      itemBuilder: (context, i) => SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _visual(i, visual),
                            const SizedBox(height: 28),
                            Text(S.t(lang, 'onb.${i + 1}.title'), textAlign: TextAlign.center, style: K.h1),
                            const SizedBox(height: 12),
                            Text(S.t(lang, 'onb.${i + 1}.body'),
                                textAlign: TextAlign.center, style: K.body.copyWith(color: K.inkSoft)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Semantics(
                    label: '${_index + 1} / $_count',
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (var i = 0; i < _count; i++)
                          AnimatedContainer(
                            duration: KMotion.standard,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: i == _index ? 22 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: i == _index ? K.primary : K.control.withAlpha(110),
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 18, 24, 20),
                    child: FilledButton(
                      onPressed: _next,
                      child: Text(S.t(lang, _index == _count - 1 ? 'onb.start' : 'onb.next')),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
