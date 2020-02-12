Get a list of system processes, and you can kill, start, restart a process

Inspired by [system-task](https://github.com/januwA/system-task)

## Install
```yarn
dependencies:
  system_tasks_dart:
```

## Usage

A simple usage example:

```dart
import 'package:system_tasks_dart/system_tasks_dart.dart';

void main() {
  SystemTasks.tasks().then((ps) {
    var p = ps.firstWhere((p) => p.pname.toLowerCase() == 'code.exe');
    if (p != null) {
      p.reStartLinks();
    }
  });
}
```


## test
```sh
pub run test ./test/system_tasks_dart_test.dart
```