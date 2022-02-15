import 'package:daily_todo_app/data/local_storage.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'data/hive_local_storage.dart';
import 'models/task_model.dart';
import 'pages/home_page.dart';

// get_it paketi ile LocalStorage için Singleton design patern eklendi.
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

  await EasyLocalization.ensureInitialized();

  ///
  /// Saat ve şarj bilgilerinin olduğu status bar, normalde appBarın renginden hafif koyu renkli, bu koyuluğu kaldırmak için kullanılır.
  ///
  SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent));

  await setupHive();

  setup();

  runApp(
    EasyLocalization(
        supportedLocales: const [Locale('en', 'US'), Locale('tr', 'TR')],
        path:
            'assets/translations', // <-- change the path of the translation files
        fallbackLocale: const Locale('en', 'US'),
        child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'outer_header'.tr(),
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: const AppBarTheme(
            elevation: 0,
            backgroundColor: Colors.white,
            iconTheme: IconThemeData(color: Colors.black)),
      ),
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,

      /// uygulama cihazın kendi diliyle başlasın
      locale: context.deviceLocale,
      home: const HomePage(),
    );
  }
}
