import 'dart:io' show Platform, ProcessResult;

import 'package:path/path.dart';
import 'package:process_run/process_run.dart';

class Awesome {
  bool get isAwesome => true;
}

bool isWindows = Platform.isWindows;
String _CMD = isWindows ? "tasklist" : "ps aux";

bool _trim(String line) {
  return line.trim() != '';
}

Task _mapLine(String line) {
  return Task(line.trim().split(RegExp(r"\s+")), line);
}

Task _mapLineWindows(String line) {
  return Task(line.trim().split(','), line);
}


class SystemTasks {

  static Future<bool> isRunning(String exePath) async {
    var name = basename(exePath);
    var res = await pathTotasks(byName: name);
    // print(res);
    return res.containsKey(normalize(exePath));
  }

  static Future<Map<String,Task>> pathTotasks({String byName = null}) async {
    var res = await tasks(byName: byName);
    Map<String,Task> mapRes = {};
    res.forEach((element) {
      if (element.exePath.isEmpty) return;
      // print(normalize(element.exePath));
      mapRes[ normalize(element.exePath)] = element;
    });
    return mapRes;
  }

  static Future<List<Task>> tasks({String byName = null}) async {
    if (isWindows){
      try {
        var prms = [
          "process" ,
          if (byName != null)"where" ,
          if (byName != null)'name="$byName"' ,
          "get",
          'ProcessID,name,ExecutablePath' ,
          "/format:csv"
        ];
        // if (byName != null){
        //   prms.add('where "name=\'$byName\'"');
        // }
        var r = await runExecutableArguments("wmic", prms);
        // print(r.stdout);
        if (r.stdout != null) {
          String stdout = r.stdout.toString();
          // print(stdout);
          List tasks = stdout.split("\n").where(_trim).map(_mapLineWindows).toList();
          tasks = tasks.where((e) => (isWindows ? tasks.indexOf(e) > 1 : tasks.indexOf(e) > 0)).toList();
          return tasks;
        } else {
          return List<Task>();
        }
      } catch (e) {
        throw e;
      }
    }
    else{
      try {
        var r = await runExecutableArguments(_CMD, []);
        if (r.stdout != null) {
          String stdout = r.stdout.toString();
          List tasks = stdout.split("\n").where(_trim).map(_mapLine).toList();
          tasks = tasks
              .where((e) =>
          (isWindows ? tasks.indexOf(e) > 1 : tasks.indexOf(e) > 0))
              .toList();
          return tasks;
        } else {
          return List<Task>();
        }
      } catch (e) {
        throw e;
      }
    }

  }
}

class Task {
  final List<String> p;
  final String line;

  String get pname => isWindows ? p[2] : p[10];
  String get pid => p[3];
  String get exePath => p[1];

  const Task(this.p, this.line);

  /**
   * 杀死此进程
   */
  Future<ProcessResult> kill() {
    String command =
        isWindows ? "taskkill /PID ${pid} /TF" : "kill -s 9 ${pid}";
    return run(command, []);
  }

  /**
   * 杀死和此进程一样name的所有进程
   */
  Future<ProcessResult> killLikes() {
    String command =
        isWindows ? "TASKKILL /F /IM ${pname} /T" : "pkill -9 ${pname}";
    return run(command, []);
  }

  /**
   * 运行一个当前进程
   */
  Future<ProcessResult> start() {
    return run(pname.replaceAll(RegExp(r"\.exe$"), ""), []);
  }

  /**
   * 重启进程
   */
  Future<void> reStart() async {
    try {
      await kill();
      await start();
    } catch (error) {
      throw error;
    }
  }

  /**
   * 重启所有相关的进程
   */
  Future<void> reStartLikes() async {
    try {
      await killLikes();
      await start();
    } catch (error) {
      throw error;
    }
  }

  String toString() {
    return line;
  }
}
