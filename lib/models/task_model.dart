import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
part 'task_model.g.dart';

// HiveObject sınıfı update ve delete işlemlerini kolaylarştırdığı için kullanıldı.
@HiveType(typeId: 1)
class Task extends HiveObject {
  @HiveField(1)
  final String id;

  @HiveField(2)
  String name;

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  bool isCompleted;

  Task({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.isCompleted,
  });

  factory Task.create({required String name, required DateTime createdAt}) {
    return Task(
        // uuid paketi, o anki zaman bilgisine göre unique veriler oluşturmak için kullanıldı.
        id: const Uuid().v1(),
        name: name,
        createdAt: createdAt,
        isCompleted: false);
  }
}
