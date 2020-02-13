import 'dart:io' show Platform, ProcessResult;

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

class SystemTasks {
  static Future<List<Task>> tasks() async {
    try {
      var r = await run(_CMD, []);
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

class Task {
  final List<String> p;
  final String line;

  String get pname => isWindows ? p[0] : p[10];
  String get pid => p[1];

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
