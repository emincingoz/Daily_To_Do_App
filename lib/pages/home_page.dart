import 'package:daily_todo_app/data/local_storage.dart';
import 'package:daily_todo_app/helper/translation_helper.dart';
import 'package:daily_todo_app/main.dart';
import 'package:daily_todo_app/models/task_model.dart';
import 'package:daily_todo_app/widgets/custom_search_delegate.dart';
import 'package:daily_todo_app/widgets/task_list_item.dart';
import 'package:easy_localization/easy_localization.dart';
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

    // Singleton instance
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
              'title',
              style: TextStyle(color: Colors.black),
            ).tr(),
          ),
          centerTitle: false,
          actions: [
            IconButton(
              onPressed: () {
                _showSearchPage();
              },
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
                      children: [
                        const SizedBox(
                          width: 8,
                        ),
                        const Icon(
                          Icons.delete,
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        const Text('remove_task').tr()
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
            : Center(
                child: const Text('empty_task_list').tr(),
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
                decoration: InputDecoration(
                  hintText: 'add_task'.tr(),
                  // TextField altında çıkan border çizgisini kaldırmak için kullanılır.
                  border: InputBorder.none,
                ),
                onSubmitted: (value) {
                  _dateTimePickerSetup(value);
                },
              ),
            ),
          );
        });
  }

  void _dateTimePickerSetup(String value) {
    // TextField içerisine input girildikten sonra onaylandığında kapanmasını sağlar.
    Navigator.of(context).pop();
    DatePicker.showTimePicker(
      context,
      locale: TranslationHelper.getDeviceLanguage(context),
      showSecondsColumn: false,
      onConfirm: (time) async {
        if (value.length > 3) {
          var newTask = Task.create(name: value, createdAt: time);

          _allTasks.insert(0, newTask);
          await _localStorage.addTask(task: newTask);
          setState(() {});
        }
      },
    );
  }

  void _showSearchPage() async {
    await showSearch(
        context: context, delegate: CustomSearchDelegate(allTasks: _allTasks));
    _getAllTaskFromDb();
  }

  void _getAllTaskFromDb() async {
    _allTasks = await _localStorage.getAllTask();

    setState(() {});
  }
}
