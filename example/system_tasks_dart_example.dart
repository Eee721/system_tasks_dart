import 'package:system_tasks_dart/system_tasks_dart.dart';

void main() async{
  var b = await SystemTasks.isRunning("E:\\working\\projects\\muflauncher\\.build\\launcher\\launcher.exe");
  print(b);

  var task = await SystemTasks.getRunningTaskByPath("E:\\working\\projects\\muflauncher\\.build\\launcher\\launcher.exe");
  if (task != null){
    print(task);
  }

  // SystemTasks.tasks(byName: "launcher.exe").then((ps) {
  //   // var p = ps.firstWhere((p) => p.pname.toLowerCase() == 'code.exe');
  //   // if (p != null) {
  //   //   p.reStartLikes();
  //   // }
  //   ps.forEach((element) {
  //     print(element.p);
  //   });
  // });


}
