import 'package:js_trions/model/ProgrammingLanguage.dart';
import 'package:js_trions/model/ProgrammingLanguages.dart';
import 'package:js_trions/model/dataTasks/DeleteProgrammingLanguageDataTask.dart';
import 'package:js_trions/model/dataTasks/SaveProgrammingLanguageDataTask.dart';
import 'package:sembast/sembast.dart';
import 'package:tch_appliable_core/tch_appliable_core.dart';
import 'package:tch_common_widgets/tch_common_widgets.dart';

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

/// Save Programming Language, works for both existing and new, and update data
Future<void> saveProgrammingLanguage(
  BuildContext context, {
  required GlobalKey<FormState> formKey,
  int? id,
  required TextEditingController nameController,
  required TextEditingController extensionController,
  bool clearFields = true,
}) async {
  FocusScope.of(context).unfocus();

  if (formKey.currentState!.validate()) {
    final programmingLanguage = ProgrammingLanguage.fromJson(<String, dynamic>{
      ProgrammingLanguage.COL_ID: id,
      ProgrammingLanguage.COL_NAME: nameController.text,
      ProgrammingLanguage.COL_EXTENSION: extensionController.text,
    });

    await MainDataProvider.instance!.executeDataTask<SaveProgrammingLanguageDataTask>(
      SaveProgrammingLanguageDataTask(
        data: programmingLanguage,
      ),
    );

    if (clearFields) {
      nameController.text = '';
      extensionController.text = '';
    }
  }
}

/// Delete existing ProgramminLanguage and update data
Future<void> deleteProgrammingLanguage(BuildContext context, ProgrammingLanguage programmingLanguage) async {
  final confirmed = await ConfirmDialog.show(
    context,
    isDanger: true,
    title: tt('dialog.confirm.title'),
    noText: tt('dialog.no'),
    yesText: tt('dialog.yes'),
  );

  if (confirmed == true) {
    await MainDataProvider.instance!.executeDataTask<DeleteProgrammingLanguageDataTask>(
      DeleteProgrammingLanguageDataTask(
        data: programmingLanguage,
      ),
    );
  }
}
