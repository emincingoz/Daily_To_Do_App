import 'package:daily_todo_app/data/local_storage.dart';
import 'package:daily_todo_app/main.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/task_model.dart';

class TaskItem extends StatefulWidget {
  Task task;

  TaskItem({Key? key, required this.task}) : super(key: key);

  @override
  _TaskItemState createState() => _TaskItemState();
}

class _TaskItemState extends State<TaskItem> {
  //
  // TextField için
  TextEditingController _taskNameController = TextEditingController();
  late LocalStorage _localStorage;

  @override
  void initState() {
    super.initState();

    // Singleton instance
    _localStorage = locater<LocalStorage>();
  }

  @override
  Widget build(BuildContext context) {
    _taskNameController.text = widget.task.name;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.2),
            blurRadius: 10,
          ),
        ],
      ),
      child: ListTile(
        // stateful widget içerisinde bulunduğu için widget.task şeklinde erişilebilir.
        title: widget.task.isCompleted
            ? Text(
                widget.task.name,
                style: const TextStyle(
                    // Görev tamamlandığında görevin üstü çizilir.
                    decoration: TextDecoration.lineThrough,
                    color: Colors.grey),
              )
            : TextField(
                ///
                /// TextField açıldığında yazma alanına focuslanmak için kullanıldı.
                //autofocus: true,

                /// Klavye onay tuşunun input verme işlemini sonlandırması için kullanıldı.
                textInputAction: TextInputAction.done,

                /// maxLines default 1 olarak ayarlandığı için uzun inputların tamamı görüntülenemez. null yapılması gerekti.
                maxLines: null,
                minLines: 1,

                controller: _taskNameController,
                // TextField alanında alttaki border çizgisi kaldırıldı.
                decoration: const InputDecoration(border: InputBorder.none),
                onSubmitted: (newValue) {
                  widget.task.name = newValue;
                  _localStorage.updateTask(task: widget.task);
                },
              ),
        leading: GestureDetector(
          onTap: () {
            widget.task.isCompleted = !widget.task.isCompleted;
            _localStorage.updateTask(task: widget.task);
            setState(() {});
          },
          child: Container(
            child: const Icon(
              Icons.check,
              color: Colors.white,
            ),
            decoration: BoxDecoration(
                color: widget.task.isCompleted ? Colors.green : Colors.white,
                border: Border.all(color: Colors.grey, width: .8),
                shape: BoxShape.circle),
          ),
        ),
        trailing: Text(
          DateFormat('hh:mm a').format(widget.task.createdAt),
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ),
    );
  }
}
