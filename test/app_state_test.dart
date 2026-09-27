import 'package:diabetic_foot_app/ui/app_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('the chosen language is restored after a restart', () async {
    SharedPreferences.setMockInitialValues({'khatwa_language': 'English'});
    await loadLanguage();
    expect(appLanguage.value, 'English');

    appLanguage.value = 'Français';
    await Future<void>.delayed(Duration.zero);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('khatwa_language'), 'Français');
  });

  test('an unknown stored language is ignored', () async {
    appLanguage.value = 'تونسي';
    SharedPreferences.setMockInitialValues({'khatwa_language': 'Klingon'});
    await loadLanguage();
    expect(appLanguage.value, 'تونسي');
  });
}
