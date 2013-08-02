library harness_browser;

import 'dart:html';
import 'package:unittest/html_enhanced_config.dart';
import 'package:unittest/unittest.dart';

import 'package:nv/src/storage.dart';
import 'nv/test_storage.dart' as storage;

main() {
  groupSep = ' - ';
  useHtmlEnhancedConfiguration();

  group('storage', () {
    group('memory', () {
      storage.main();
    });

    group('localStorage', () {
      var store = new StringStorage(window.localStorage);
      storage.main(store);
    });

    group('sessionStorage', () {
      var store = new StringStorage(window.sessionStorage);
      storage.main(store);
    });
  });

}
