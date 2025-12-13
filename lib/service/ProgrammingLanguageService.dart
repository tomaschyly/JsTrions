import 'package:js_trions/core/app_theme.dart';
import 'package:js_trions/model/ProgrammingLanguage.dart';
import 'package:js_trions/model/ProgrammingLanguages.dart';
import 'package:js_trions/model/dataTasks/DeleteProgrammingLanguageDataTask.dart';
import 'package:js_trions/model/dataTasks/SaveProgrammingLanguageDataTask.dart';
import 'package:js_trions/service/ProjectService.dart';
import 'package:js_trions/ui/screenStates/AppResponsiveScreenState.dart';
import 'package:sembast/sembast.dart';
import 'package:tch_appliable_core/tch_appliable_core.dart';
import 'package:tch_common_widgets/tch_common_widgets.dart';

/// On first app start fill store with programming languages
Future<void> updateDBForProgrammingLanguage(Database db, int oldVersion, int newVersion) async {
  final theStore = intMapStoreFactory.store(ProgrammingLanguage.STORE);

  if (oldVersion == 0) {
    final programmingLanguages = ProgrammingLanguages.fromJson(<String, dynamic>{
      'list': [
        {
          ProgrammingLanguage.COL_NAME: 'Dart',
          ProgrammingLanguage.COL_EXTENSION: 'dart',
          ProgrammingLanguage.COL_KEY: r'''(?<=tt\(\')(.*?)(?=\'\))|(?<=tt\(\")(.*?)(?=\"\))''',
        },
        {
          ProgrammingLanguage.COL_NAME: 'Kotlin',
          ProgrammingLanguage.COL_EXTENSION: 'kt',
          ProgrammingLanguage.COL_KEY: r'''(?<=tt\(\')(.*?)(?=\'\))|(?<=tt\(\")(.*?)(?=\"\))''',
        },
        {
          ProgrammingLanguage.COL_NAME: 'Swift',
          ProgrammingLanguage.COL_EXTENSION: 'swift',
          ProgrammingLanguage.COL_KEY: r'''(?<=tt\(\')(.*?)(?=\'\))|(?<=tt\(\")(.*?)(?=\"\))''',
        },
        {
          ProgrammingLanguage.COL_NAME: 'C#',
          ProgrammingLanguage.COL_EXTENSION: 'cs',
          ProgrammingLanguage.COL_KEY: r'''(?<=T.Tk \(\')(.*?)(?=\'\))|(?<=T.Tk \(\")(.*?)(?=\"\))''',
        },
        {
          ProgrammingLanguage.COL_NAME: 'Javascript JSX',
          ProgrammingLanguage.COL_EXTENSION: 'jsx',
          ProgrammingLanguage.COL_KEY: r'''(?<=t \(\')(.*?)(?=\', language\))''',
        },
        {
          ProgrammingLanguage.COL_NAME: 'Typescript JSX',
          ProgrammingLanguage.COL_EXTENSION: 'tsx',
          ProgrammingLanguage.COL_KEY: r'''(?<=tt \(\')(.*?)(?=\', language\))''',
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
  required TextEditingController keyController,
  bool clearFields = true,
}) async {
  FocusScope.of(context).unfocus();

  final appTheme = context.appTheme;
  final isNew = id == null;

  if (formKey.currentState!.validate()) {
    final programmingLanguage = ProgrammingLanguage.fromJson(<String, dynamic>{
      ProgrammingLanguage.COL_ID: id,
      ProgrammingLanguage.COL_NAME: nameController.text,
      ProgrammingLanguage.COL_EXTENSION: extensionController.text,
      ProgrammingLanguage.COL_KEY: keyController.text,
    });

    await MainDataProvider.instance!.executeDataTask<SaveProgrammingLanguageDataTask>(
      SaveProgrammingLanguageDataTask(
        data: programmingLanguage,
      ),
    );

    if (clearFields) {
      nameController.text = '';
      extensionController.text = '';
      keyController.text = '';
    }

    displayScreenMessage(
      ScreenMessage(
        message: isNew ? tt('programmingLanguage.new.success') : tt('programmingLanguage.edit.success'),
        type: ScreenMessageType.success,
      ),
      appTheme: appTheme,
    );
  }
}

/// Delete existing ProgrammingLanguage and update data
Future<void> deleteProgrammingLanguage(BuildContext context, ProgrammingLanguage programmingLanguage) async {
  final appTheme = context.appTheme;

  final anyProject = await anyProjectForProgrammingLanguage(programmingLanguage.id!);

  final confirmed = await ConfirmDialog.show(
    context,
    isDanger: true,
    title: tt('dialog.confirm.title'),
    text: anyProject != null ? tt('delete_programming_language.text').replaceAll(r'$projectName', anyProject.name) : null,
    noText: tt('dialog.no'),
    yesText: tt('dialog.yes'),
  );

  if (confirmed == true) {
    await MainDataProvider.instance!.executeDataTask<DeleteProgrammingLanguageDataTask>(
      DeleteProgrammingLanguageDataTask(
        data: programmingLanguage,
      ),
    );

    displayScreenMessage(
      ScreenMessage(
        message: tt('programmingLanguage.delete.success'),
        type: ScreenMessageType.success,
      ),
      appTheme: appTheme,
    );
  }
}

/// Sort list of ProgrammingLanguages alphabetically
void sortProgrammingLanguagesAlphabetically(List<ProgrammingLanguage> programmingLanguages) {
  programmingLanguages.sort((a, b) => a.name.compareTo(b.name));
}
