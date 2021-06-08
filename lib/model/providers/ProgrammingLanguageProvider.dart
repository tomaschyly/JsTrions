import 'package:js_trions/model/ProgrammingLanguage.dart';
import 'package:js_trions/model/ProgrammingLanguages.dart';
import 'package:sembast/sembast.dart';

/// On first app start fill store with programming languages
Future<void> updateDB(Database db, int oldVersion, int newVersion) async {
  final theStore = intMapStoreFactory.store(ProgrammingLanguage.STORE);

  if (oldVersion == 0) {
    final programmingLanguages = ProgrammingLanguages.fromJson(<String, dynamic>{
      'list': [
        {
          ProgrammingLanguage.COL_NAME: 'Dart',
          ProgrammingLanguage.COL_EXTENSION: 'dart',
        },
        {
          ProgrammingLanguage.COL_NAME: 'Kotlin',
          ProgrammingLanguage.COL_EXTENSION: 'kt',
        },
        {
          ProgrammingLanguage.COL_NAME: 'Swift',
          ProgrammingLanguage.COL_EXTENSION: 'swift',
        },
        {
          ProgrammingLanguage.COL_NAME: 'C#',
          ProgrammingLanguage.COL_EXTENSION: 'cs',
        },
      ],
    });

    for (ProgrammingLanguage programmingLanguage in programmingLanguages.programmingLanguages) {
      await theStore.add(db, programmingLanguage.toJson());
    }
  }
}
