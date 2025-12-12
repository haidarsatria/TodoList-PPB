import 'package:flutter_test/flutter_test.dart';
import 'helpers/test_helper.dart';
import 'helpers/database_test_helper.dart';

void main() {
  setUpAll(() {
    setupMockTailFallbacks();
    setupSqfliteForTest();
  });
}
