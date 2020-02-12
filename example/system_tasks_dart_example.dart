import 'package:system_tasks_dart/system_tasks_dart.dart';

void main() {
  SystemTasks.tasks().then((ps) {
    var p = ps.firstWhere((p) => p.pname.toLowerCase() == 'code.exe');
    if (p != null) {
      p.reStartLinks();
    }
  });
}
