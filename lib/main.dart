import 'package:daily_todo_app/data/local_storage.dart';
import 'package:daily_todo_app/widgets/task_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'models/task_model.dart';
import 'pages/home_page.dart';

// get_it paketi ile Singleton design patern eklendi.
final locater = GetIt.instance;

void setup() {
  locater.registerSingleton<LocalStorage>(HiveLocalStorage());
}

Future<void> setupHive() async {
  await Hive.initFlutter();

  Hive.registerAdapter(TaskAdapter());
  var taskBox = await Hive.openBox<Task>('tasks');

  taskBox.values.forEach((element) {
    if (element.createdAt.day != DateTime.now().day) {
      taskBox.delete(element.id);
    }
  });
}

Future<void> main() async {
  // runApp'den önce çalışması gereken uzun işlemler olduğu için kullanıldı.
  // uygulama ekrana gelmeden önce başlatılması ve ele alınması gereken işlemleri gerçekleştirir.
  WidgetsFlutterBinding.ensureInitialized();

  ///
  /// Saat ve şarj bilgilerinin olduğu status bar, normalde appBarın renginden hafif koyu renkli, bu koyuluğu kaldırmak için kullanılır.
  ///
  SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent));

  await setupHive();

  setup();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Material App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: const AppBarTheme(
            elevation: 0,
            backgroundColor: Colors.white,
            iconTheme: IconThemeData(color: Colors.black)),
      ),
      home: const HomePage(),
    );
  }
}
