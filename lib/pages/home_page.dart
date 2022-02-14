import 'package:daily_todo_app/data/local_storage.dart';
import 'package:daily_todo_app/main.dart';
import 'package:daily_todo_app/models/task_model.dart';
import 'package:daily_todo_app/widgets/task_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late List<Task> _allTasks;
  late LocalStorage _localStorage;

  @override
  void initState() {
    super.initState();

    _localStorage = locater<LocalStorage>();
    _allTasks = <Task>[];

    // initState() fonksiyonunda async kullanılamadığı için oluşturuldu.
    // _allTasks = _localStorage.getAllTasks() komutunu gerçekleştirir.
    _getAllTaskFromDb();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: GestureDetector(
            onTap: () {
              _showAddTaskBottomSheet(context);
            },
            child: const Text(
              "Bugün Neler Yapacaksın?",
              style: TextStyle(color: Colors.black),
            ),
          ),
          centerTitle: false,
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.search),
            ),
            IconButton(
              onPressed: () {
                _showAddTaskBottomSheet(context);
              },
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        body: _allTasks.isNotEmpty
            ? ListView.builder(
                itemCount: _allTasks.length,
                itemBuilder: (context, index) {
                  var currentTask = _allTasks[index];
                  return Dismissible(
                    background: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        SizedBox(
                          width: 8,
                        ),
                        Icon(
                          Icons.delete,
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Text("Bu Görev Siliniyor!")
                      ],
                    ),
                    // oluşturulan farklı ListTile'ların keyleri birbirinden farklı olmalı.
                    key: Key(currentTask.id),
                    onDismissed: (direction) {
                      _allTasks.removeAt(index);
                      _localStorage.deleteTask(task: currentTask);
                      setState(() {});
                    },
                    child: TaskItem(task: currentTask),
                  );
                },
              )
            : const Center(
                child: Text("Hadi Bir Görev Ekle..."),
              ));
  }

  void _showAddTaskBottomSheet(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            ///
            /// container içindeki child ListTile ile arasındaki boşluk keyboard açılması durumunda üzerinde kalacak şekilde ayarlanır.
            /// viewInsets.bottom
            ///
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),

            ///
            /// Cihazın boyutlarına göre en verildi.
            /// Yükseklik içerik kadar olacağı için verilmedi.
            ///
            width: MediaQuery.of(context).size.width,
            child: ListTile(
              title: TextField(
                style: const TextStyle(fontSize: 20),
                decoration: const InputDecoration(
                  hintText: "Görev Nedir?",
                  // TextField altında çıkan border çizgisini kaldırmak için kullanılır.
                  border: InputBorder.none,
                ),
                onSubmitted: (value) {
                  // TextField içerisine input girildikten sonra onaylandığında kapanmasını sağlar.
                  Navigator.of(context).pop();
                  DatePicker.showTimePicker(context, showSecondsColumn: false,
                      onConfirm: (time) async {
                    if (value.length > 3) {
                      var newTask = Task.create(name: value, createdAt: time);

                      _allTasks.insert(0, newTask);
                      await _localStorage.addTask(task: newTask);
                      setState(() {});
                    }
                  });
                },
              ),
            ),
          );
        });
  }

  void _getAllTaskFromDb() async {
    _allTasks = await _localStorage.getAllTask();

    setState(() {});
  }
}
