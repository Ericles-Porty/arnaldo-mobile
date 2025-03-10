import 'dart:io';

import 'package:arnaldo/app_module.dart';
import 'package:arnaldo/app_widget.dart';
import 'package:arnaldo/core/database/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// Future<void> resetDatabase() async {
//   String path = join(await getDatabasesPath(), 'arnaldo.db');
//   await deleteDatabase(path);
// }

void main() async {
  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  WidgetsFlutterBinding.ensureInitialized();

  print('getDatabasesPath: ');
  print(await getDatabasesPath());
  await DatabaseHelper().warmUp();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  //await resetDatabase();

  setPrintResolver((text) => print(text));

  // debugPrintRebuildDirtyWidgets = true;
  runApp(
    ModularApp(
      module: AppModule(),
      child: const AppWidget(),
    ),
  );
}
