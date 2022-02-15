import 'package:daily_todo_app/data/local_storage.dart';
import 'package:daily_todo_app/main.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../models/task_model.dart';
import 'task_list_item.dart';

class CustomSearchDelegate extends SearchDelegate {
  List<Task> allTasks;

  CustomSearchDelegate({
    required this.allTasks,
  });

  ///
  /// Arama alanının sağında kalan alanlar için buton vb atanır.
  /// cancel/clear butonu atandı
  ///
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
          onPressed: () {
            /// Arama alanına yazılan yazılar query stringine atanır.
            /// SearchDelegate içerisinde...
            query.isEmpty ? null : query = '';
          },
          icon: const Icon(Icons.clear))
    ];
  }

  ///
  /// Arama alanının solunda kalan alan için buton vb atanır.
  /// Buton olarak geri tuşu atandı
  ///
  @override
  Widget? buildLeading(BuildContext context) {
    return GestureDetector(
      onTap: () {
        close(context, null);
      },
      child: const Icon(
        Icons.arrow_back_ios_new,
        color: Colors.black,
        size: 24,
      ),
    );
  }

  ///
  /// Kullanıcı girdiği inputu onayladığında arama sonuçlarını getirmesi
  ///
  @override
  Widget buildResults(BuildContext context) {
    ///
    /// Kullanıcının girdiği input, allTasks içinde varsa filteredList'e atanır.
    /// allTasks constructor ile HomePagede alındı.
    ///
    List<Task> filteredList = allTasks
        .where((element) =>
            element.name.toLowerCase().contains(query.toLowerCase()))
        .toList();

    ///
    /// filteredList içerisinde görev varsa ListView ile arama alanı altında göster.
    /// görev yoksa ekrana search_failed yazısı gönder.
    ///
    return filteredList.isNotEmpty
        ? ListView.builder(
            itemCount: filteredList.length,
            itemBuilder: (context, index) {
              var currentTask = filteredList[index];
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
                    const Text('remove_task').tr(),
                  ],
                ),
                // oluşturulan farklı ListTile'ların keyleri birbirinden farklı olmalı.
                key: Key(currentTask.id),
                onDismissed: (direction) async {
                  filteredList.removeAt(index);
                  //_localStorage.deleteTask(task: currentTask);
                  await locater<LocalStorage>().deleteTask(task: currentTask);
                  //setState(() {});
                },
                child: TaskItem(task: currentTask),
              );
            },
          )
        : Center(
            child: const Text('search_failed').tr(),
          );
  }

  ///
  /// Arama alanına input girilmesi sırasında getirilen öneriler.
  ///
  @override
  Widget buildSuggestions(BuildContext context) {
    return Container();
  }
}
