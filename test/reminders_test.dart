import 'package:diabetic_foot_app/data/reminders.dart';
import 'package:diabetic_foot_app/ui/app_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('settings survive a save and a restart', () {
    const s = ReminderSettings(check: false, checkAt: TimeOfDay(hour: 20, minute: 15), glucose: true);
    final back = ReminderSettings.fromJson(s.toJson());
    expect(back.check, false);
    expect(back.checkAt, const TimeOfDay(hour: 20, minute: 15));
    expect(back.glucose, true);
    expect(back.followUp, true, reason: 'defaults stay on');
    expect(ReminderSettings.fromJson(const {}).checkAt, const TimeOfDay(hour: 19, minute: 0));
  });

  test('a doctor message and a visit in the next days become nudges', () {
    appLanguage.value = 'Français';
    final r = Reminders.instance;
    final now = DateTime(2026, 9, 28, 10);
    expect(r.nudges('nobody', now: now), isEmpty);
    r.unreadMessage = {'id': 7, 'sender': 'doctor', 'body': 'Venez jeudi.'};
    r.nextVisit = DateTime(2026, 9, 29, 9);
    final list = r.nudges('nobody', now: now);
    expect(list.map((n) => n.kind), ['message', 'visit']);
    expect(list.last.title, 'Rendez-vous demain');
    // A visit far away is not a nudge yet.
    r.unreadMessage = null;
    r.nextVisit = DateTime(2026, 10, 20);
    expect(r.nudges('nobody', now: now), isEmpty);
    r.nextVisit = null;
  });
}
