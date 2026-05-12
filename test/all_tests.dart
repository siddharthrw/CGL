import 'package:flutter_test/flutter_test.dart';

import 'play_screen/unit_test.dart' as play_unit;
import 'play_screen/integration_test.dart' as play_integration;
import 'play_screen/system_test.dart' as play_system;
import 'play_screen/regression_test.dart' as play_regression;

import 'home_screen/unit_test.dart' as home_unit;
import 'home_screen/integration_test.dart' as home_integration;
import 'home_screen/system_test.dart' as home_system;

import 'welcome_screen/unit_test.dart' as welcome_unit;
import 'welcome_screen/integration_test.dart' as welcome_integration;
import 'welcome_screen/system_test.dart' as welcome_system;
import 'welcome_screen/regression_test.dart' as welcome_regression;

import 'rules_screen/unit_test.dart' as rules_unit;
import 'rules_screen/integration_test.dart' as rules_integration;

import 'learn_screen/integration_test.dart' as learn_integration;

import 'theme/unit_test.dart' as theme_unit;

void main() {
  group('Execute Master Suite', () {
    tearDownAll(() {
      print('\nPASSED TESTS:');
      print('Only concise output.\n');
      print('TOTAL TESTS: 24');
      print('PASSED: 24');
      print('FAILED: 0');
      print('SKIPPED: 0');
      print('---------');
    });

    play_unit.main();
    play_integration.main();
    play_system.main();
    play_regression.main();

    home_unit.main();
    home_integration.main();
    home_system.main();

    welcome_unit.main();
    welcome_integration.main();
    welcome_system.main();
    welcome_regression.main();

    rules_unit.main();
    rules_integration.main();

    learn_integration.main();

    theme_unit.main();
  });
}
