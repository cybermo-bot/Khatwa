import 'package:flutter/material.dart';

import '../../data/auth_store.dart';
import '../../data/case_store.dart';
import '../../data/risk_profile.dart';
import '../../features/diet/diet_page.dart';
import '../../ui/app_state.dart';
import '../../ui/app_theme.dart';
import '../../ui/strings.dart';
import '../ai_chatbot.dart';
import '../feature_pages.dart';
import '../glycemia.dart';
import '../medical_information.dart';
import '../risk_profile_page.dart';
import '../settings_page.dart';
import '../create_account.dart';
import '../wellbeing.dart';

class MeTab extends StatelessWidget {
  const MeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = appLanguage.value;
    final account = AuthStore.instance.current;
    final guest = account?.guest ?? false;
    final displayName = guest ? S.t(lang, 'auth.guestName') : (account?.name ?? '');
    final profile = RiskProfile.latest();
    void open(Widget page) =>
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));

    return KPage(
      title: S.t(lang, 'tab.me'),
      showBack: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 10),
          if (displayName.trim().isNotEmpty)
            Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: K.primarySoft,
                    shape: BoxShape.circle,
                    border:
                        Border.all(color: K.glow.withAlpha(140), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                          color: K.glow.withAlpha(K.isDark ? 70 : 30),
                          blurRadius: 24,
                          spreadRadius: -4),
                    ],
                  ),
                  child: Text(
                    _initials(displayName),
                    style: K.h1.copyWith(color: K.primaryStrong),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(displayName, style: K.h1),
                      const SizedBox(height: 4),
                      if (guest)
                        KTag(S.t(lang, 'auth.guestBadge'), icon: Icons.person_outline_rounded)
                      else
                        Text(
                          account!.email.isNotEmpty ? _maskedEmail(account.email) : _maskedPhone(account.phone),
                          textDirection: TextDirection.ltr,
                          style: K.small.copyWith(
                              fontFeatures: const [FontFeature.tabularFigures()]),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          if (guest) ...[
            const SizedBox(height: 18),
            KCard(
              color: K.primarySoft,
              onTap: () => open(const CreateAccountPage(role: 'patient')),
              child: Row(
                children: [
                  Icon(Icons.person_add_alt_1_rounded, color: K.primaryStrong),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(S.t(lang, 'auth.guestUpgrade'),
                            style: K.bodyStrong.copyWith(color: K.primaryStrong)),
                        const SizedBox(height: 2),
                        Text(S.t(lang, 'auth.guestUpgradeSub'),
                            style: K.small.copyWith(color: K.primaryStrong)),
                      ],
                    ),
                  ),
                  Icon(Directionality.of(context) == TextDirection.rtl
                      ? Icons.chevron_left_rounded
                      : Icons.chevron_right_rounded, color: K.primaryStrong),
                ],
              ),
            ),
          ],
          const SizedBox(height: 28),
          KSectionLabel(S.t(lang, 'me.health')),
          KGroup(children: [
            KGroupRow(
              icon: Icons.shield_outlined,
              title: profile == null
                  ? S.t(lang, 'risk.cta')
                  : S.t(lang, profile.labelKey),
              subtitle: profile == null
                  ? S.t(lang, 'risk.subtitle')
                  : S.t(lang, profile.frequencyKey),
              onTap: () => open(RiskProfilePage(language: lang)),
            ),
            KGroupRow(
              icon: Icons.folder_shared_outlined,
              title: S.t(lang, 'me.record'),
              onTap: () => open(MedicalInformationPage(language: lang)),
            ),
            KGroupRow(
              icon: Icons.water_drop_outlined,
              title: S.t(lang, 'tool.glycemia'),
              onTap: () => open(GlycemiaPage(language: lang)),
            ),
          ]),
          const SizedBox(height: 26),
          KSectionLabel(S.t(lang, 'me.team')),
          KGroup(children: [
            KGroupRow(
              icon: Icons.event_outlined,
              title: S.t(lang, 'tool.appointments'),
              onTap: () => open(AppointmentsPage(language: lang)),
            ),
            KGroupRow(
              icon: Icons.forum_outlined,
              title: S.t(lang, 'tool.chat'),
              onTap: () => open(AiChatbotPage(language: lang)),
            ),
          ]),
          const SizedBox(height: 26),
          KSectionLabel(S.t(lang, 'me.more')),
          KGroup(children: [
            KGroupRow(
              icon: Icons.directions_walk_rounded,
              title: S.t(lang, 'tool.activity'),
              onTap: () => open(ActivityPage(language: lang)),
            ),
            KGroupRow(
              icon: Icons.restaurant_outlined,
              title: S.t(lang, 'tool.food'),
              onTap: () => open(const DietPage()),
            ),
            KGroupRow(
              icon: Icons.favorite_outline_rounded,
              title: S.t(lang, 'tool.wellbeing'),
              onTap: () => open(WellbeingPage(language: lang)),
            ),
          ]),
          const SizedBox(height: 26),
          KSectionLabel(S.t(lang, 'me.app')),
          KGroup(children: [
            KGroupRow(
              icon: Icons.tune_rounded,
              title: S.t(lang, 'settings.title'),
              subtitle:
                  '${S.t(lang, 'settings.textSize')}, ${S.t(lang, 'settings.theme')}',
              onTap: () => open(const SettingsPage()),
            ),
          ]),
          const SizedBox(height: 26),
          KSectionLabel(S.t(lang, 'me.privacy')),
          KNote(
            text: AuthStore.instance.encryptionActive
                ? S.t(lang, 'security.encrypted')
                : S.t(lang, 'security.notEncrypted'),
            icon: AuthStore.instance.encryptionActive
                ? Icons.lock_outline_rounded
                : Icons.lock_open_rounded,
          ),
          if (!AuthStore.instance.staySignedIn)
            KNote(text: S.t(lang, 'security.idle'), icon: Icons.timer_outlined),
          KNote(
              text: S.t(lang, 'report.disclaimer'),
              icon: Icons.shield_outlined),
          const SizedBox(height: 22),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(foregroundColor: K.danger),
            onPressed: () async {
              if (guest) {
                final leave = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    content: Text(S.t(lang, 'auth.guestLeave'), style: K.body),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          child: Text(S.t(lang, 'common.cancel'))),
                      TextButton(
                          onPressed: () => Navigator.of(ctx).pop(true),
                          child: Text(S.t(lang, 'auth.logout'))),
                    ],
                  ),
                );
                if (leave != true) return;
              }
              CaseStore.instance.lock();
              await AuthStore.instance.signOut();
              if (context.mounted) {
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
            },
            icon: const Icon(Icons.logout_rounded),
            label: Text(S.t(lang, 'auth.logout')),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '';
    final first = parts.first.characters.first;
    final second = parts.length > 1 ? parts.last.characters.first : '';
    return (first + second).toUpperCase();
  }

  String _maskedEmail(String email) {
    final at = email.indexOf('@');
    if (at < 2) return email;
    return '${email.substring(0, 2)}${'•' * (at - 2)}${email.substring(at)}';
  }

  String _maskedPhone(String phone) {
    if (phone.length < 4) return phone;
    return '${'•' * (phone.length - 2)}${phone.substring(phone.length - 2)}';
  }
}
