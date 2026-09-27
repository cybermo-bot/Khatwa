import 'package:flutter/material.dart';

import '../data/reminders.dart';
import '../features/common.dart';
import '../ui/app_theme.dart';

/// Which reminders the patient gets, and at what time.
class RemindersPage extends StatelessWidget {
  const RemindersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final r = Reminders.instance;
    return AnimatedBuilder(
      animation: r,
      builder: (context, _) {
        final s = r.settings;
        Future<void> pickTime(TimeOfDay current, ReminderSettings Function(TimeOfDay) apply) async {
          final t = await showTimePicker(context: context, initialTime: current);
          if (t != null) await r.save(apply(t));
        }

        Widget timed(IconData icon, String title, String subtitle, bool on, TimeOfDay at, ValueChanged<bool> onToggle,
            ReminderSettings Function(TimeOfDay) setTime) {
          return KCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Row(children: [
                Icon(icon, color: K.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(title, style: K.bodyStrong),
                    Text(subtitle, style: K.small.copyWith(color: K.inkSoft)),
                  ]),
                ),
                Switch(value: on, onChanged: onToggle),
              ]),
              if (on)
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: TextButton.icon(
                    onPressed: () => pickTime(at, setTime),
                    icon: const Icon(Icons.schedule_rounded, size: 20),
                    label: Text(at.format(context), style: K.h2.copyWith(color: K.primaryStrong)),
                  ),
                ),
            ]),
          );
        }

        Widget toggle(IconData icon, String title, String subtitle, bool on, ValueChanged<bool> onToggle) => KCard(
              child: Row(children: [
                Icon(icon, color: K.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(title, style: K.bodyStrong),
                    Text(subtitle, style: K.small.copyWith(color: K.inkSoft)),
                  ]),
                ),
                Switch(value: on, onChanged: onToggle),
              ]),
            );

        return KPage(
          title: tr('Rappels', aeb: 'التذكير', ar: 'التذكيرات', en: 'Reminders'),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            if (!Reminders.systemNotifications)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: KNote(
                  icon: Icons.info_outline_rounded,
                  text: tr('Sur le web, les rappels s’affichent dans l’application. Sur le téléphone, ce sont de vraies notifications.',
                      aeb: 'في الويب، التذكير يبان في التطبيقة. في التليفون، يجيك إشعار.',
                      ar: 'على الويب تظهر التذكيرات داخل التطبيق. على الهاتف تصلك إشعارات حقيقية.',
                      en: 'On the web, reminders show inside the app. On the phone, they are real notifications.'),
                ),
              ),
            timed(
              Icons.visibility_outlined,
              tr('Contrôle des pieds', aeb: 'فحص الساقين', ar: 'فحص القدمين', en: 'Foot check'),
              tr('Chaque jour, le soir de préférence', aeb: 'كل نهار، خير في الليل', ar: 'كل يوم، ويفضّل مساءً', en: 'Every day, ideally in the evening'),
              s.check,
              s.checkAt,
              (v) => r.save(s.copyWith(check: v)),
              (t) => s.copyWith(checkAt: t),
            ),
            const SizedBox(height: 10),
            timed(
              Icons.spa_outlined,
              tr('Soin du soir', aeb: 'عناية الليل', ar: 'عناية المساء', en: 'Evening care'),
              tr('Crème sur les talons, chaussettes propres', aeb: 'كريمة على الكعبة، كلسيطات نظاف', ar: 'كريم على الكعبين، جوارب نظيفة', en: 'Cream on the heels, clean socks'),
              s.care,
              s.careAt,
              (v) => r.save(s.copyWith(care: v)),
              (t) => s.copyWith(careAt: t),
            ),
            const SizedBox(height: 10),
            timed(
              Icons.bloodtype_outlined,
              tr('Glycémie', aeb: 'السكر', ar: 'سكر الدم', en: 'Blood sugar'),
              tr('Noter la glycémie du matin', aeb: 'تسجّل سكر الصباح', ar: 'تسجيل سكر الصباح', en: 'Log the morning reading'),
              s.glucose,
              s.glucoseAt,
              (v) => r.save(s.copyWith(glucose: v)),
              (t) => s.copyWith(glucoseAt: t),
            ),
            const SizedBox(height: 10),
            toggle(
              Icons.replay_rounded,
              tr('Revérifier un signe', aeb: 'تعاود تشوف علامة', ar: 'إعادة فحص علامة', en: 'Recheck a sign'),
              tr('Deux jours après un contrôle à surveiller, le lendemain après un contrôle urgent',
                  aeb: 'بعد يومين من فحص يلزمو متابعة، وغدوة بعد فحص مستعجل',
                  ar: 'بعد يومين من فحص يحتاج متابعة، وفي اليوم التالي بعد فحص عاجل',
                  en: 'Two days after a check to watch, the next day after an urgent one'),
              s.followUp,
              (v) => r.save(s.copyWith(followUp: v)),
            ),
            const SizedBox(height: 10),
            toggle(
              Icons.event_outlined,
              tr('Rendez-vous', aeb: 'المواعيد', ar: 'المواعيد', en: 'Appointments'),
              tr('La veille, quand le médecin a fixé la date', aeb: 'نهار قبل، كي يحدّد الطبيب الموعد', ar: 'في اليوم السابق، عندما يحدد الطبيب الموعد', en: 'The day before, when the doctor has set the date'),
              s.visit,
              (v) => r.save(s.copyWith(visit: v)),
            ),
            const SizedBox(height: 10),
            toggle(
              Icons.chat_bubble_outline_rounded,
              tr('Messages du médecin', aeb: 'مساجات الطبيب', ar: 'رسائل الطبيب', en: 'Messages from the doctor'),
              tr('Dès qu’il vous répond', aeb: 'كي يجاوبك', ar: 'فور ردّه عليك', en: 'As soon as they reply'),
              s.messages,
              (v) => r.save(s.copyWith(messages: v)),
            ),
            if (Reminders.systemNotifications) ...[
              const SizedBox(height: 18),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                onPressed: () async {
                  await r.requestPermission();
                  final ok = await r.test();
                  if (!context.mounted) return;
                  kToast(
                      context,
                      ok
                          ? tr('Rappel envoyé', aeb: 'التذكير تبعث', ar: 'تم إرسال التذكير', en: 'Reminder sent')
                          : tr('Autorisez les notifications dans les réglages du téléphone.',
                              aeb: 'اسمح بالإشعارات في إعدادات التليفون.',
                              ar: 'اسمح بالإشعارات في إعدادات الهاتف.',
                              en: 'Allow notifications in the phone settings.'),
                      error: !ok);
                },
                icon: const Icon(Icons.notifications_active_outlined),
                label: Text(tr('Essayer un rappel', aeb: 'جرّب تذكير', ar: 'تجربة تذكير', en: 'Try a reminder')),
              ),
            ],
          ]),
        );
      },
    );
  }
}
