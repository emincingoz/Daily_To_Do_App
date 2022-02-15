import 'package:hive_flutter/hive_flutter.dart';

import '../models/task_model.dart';
import 'local_storage.dart';

class HiveLocalStorage extends LocalStorage {
  late Box<Task> _taskBox;

  HiveLocalStorage() {
    _taskBox = Hive.box('tasks');
  }

  @override
  Future<void> addTask({required Task task}) async {
    await _taskBox.put(task.id, task);
  }

  @override
  Future<bool> deleteTask({required Task task}) async {
    //_taskBox.delete(task.id);

    // Task sınıfını HiveObject sınıfından türettiğim için task.delete() fonksiyonu ile silebilirim
    await task.delete();
    return true;
  }

  @override
  Future<List<Task>> getAllTask() async {
    List<Task> _allTask = <Task>[];
    _allTask = _taskBox.values.toList();

    if (_allTask.isNotEmpty) {
      _allTask.sort((Task a, Task b) => b.createdAt.compareTo(a.createdAt));
    }
    return _allTask;
  }

  @override
  Future<Task?> getTask({required String id}) async {
    if (_taskBox.containsKey(id)) {
      return _taskBox.get(id);
    } else {
      return null;
    }
  }

  @override
  Future<Task> updateTask({required Task task}) async {
    //
    // Task sınıfı HiveObject sınıfından türetildiği için kullanılabilen fonksiyon.
    await task.save();
    return task;
  }
}
