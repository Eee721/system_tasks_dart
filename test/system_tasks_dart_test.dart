import 'package:system_tasks_dart/system_tasks_dart.dart';
import 'package:test/test.dart';

void main() {
  group('A group of tests', () {
    test('First Test', () async {
      var ps = await SystemTasks.tasks();
      expect(ps, isNotNull);
    });
  });
}
