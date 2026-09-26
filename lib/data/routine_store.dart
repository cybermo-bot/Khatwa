import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The daily foot care routine: which steps the patient ticked today.
/// Only step ids and the date are stored; nothing medical.
class RoutineStore extends ChangeNotifier {
  RoutineStore._();
  static final RoutineStore instance = RoutineStore._();

  static const steps = ['check', 'wash', 'dry', 'cream', 'shoes'];

  final Set<String> _done = {};
  String _dayKey = '';
  String _owner = '';

  Set<String> get done => Set.unmodifiable(_done);

  String _keyFor(String owner, DateTime day) =>
      'khatwa_routine_${owner}_${day.year}${day.month.toString().padLeft(2, '0')}${day.day.toString().padLeft(2, '0')}';

  Future<void> load(String owner) async {
    final key = _keyFor(owner, DateTime.now());
    if (key == _dayKey && owner == _owner) return;
    final prefs = await SharedPreferences.getInstance();
    _owner = owner;
    _dayKey = key;
    _done
      ..clear()
      ..addAll(prefs.getStringList(key) ?? const []);
    notifyListeners();
  }

  Future<void> toggle(String step) async {
    if (_dayKey.isEmpty) return;
    if (!_done.remove(step)) _done.add(step);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_dayKey, _done.toList());
  }
}
