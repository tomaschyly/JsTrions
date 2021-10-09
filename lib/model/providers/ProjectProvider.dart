import 'package:js_trions/model/Project.dart';
import 'package:js_trions/model/ProjectQuery.dart';
import 'package:js_trions/model/dataTasks/DeleteProjectDataTask.dart';
import 'package:js_trions/model/dataTasks/GetProjectsDataTask.dart';
import 'package:js_trions/model/dataTasks/SaveProjectDataTask.dart';
import 'package:js_trions/ui/dataWidgets/ProjectProgrammingLanguagesFieldDataWidget.dart';
import 'package:js_trions/ui/widgets/ProjectIgnoreDirectoriesWidget.dart';
import 'package:js_trions/ui/widgets/ProjectLanguagesFieldWidget.dart';
import 'package:js_trions/ui/widgets/ProjectTranslationsJsonFormatFieldWidget.dart';
import 'package:tch_appliable_core/tch_appliable_core.dart';
import 'package:tch_common_widgets/tch_common_widgets.dart';

/// Save Project, works for both existing and new, and update data
Future<void> saveProject(
  BuildContext context, {
  required GlobalKey<FormState> formKey,
  Project? project,
  required TextEditingController nameController,
  required TextEditingController directoryController,
  required TextEditingController translationAssetsController,
  required GlobalKey<ProjectLanguagesFieldWidgetState> languagesKey,
  required GlobalKey<ProjectProgrammingLanguagesFieldDataWidgetState> programmingLanguagesKey,
  required GlobalKey<ProjectTranslationsJsonFormatFieldWidgetState> translationsJsonFormatKey,
  required GlobalKey<ProjectIgnoreDirectoriesWidgetState> ignoreDirectoriesKey,
  bool popOnSuccess = true,
}) async {
  FocusScope.of(context).unfocus();

  if (formKey.currentState!.validate()) {
    final now = DateTime.now().millisecondsSinceEpoch;

    final programmingLanguagesValue = programmingLanguagesKey.currentState!.value;
    ProjectTranslationsJsonFormat? translationsJsonFormatValue = translationsJsonFormatKey.currentState?.value;
    if (translationsJsonFormatValue == null && project != null) {
      translationsJsonFormatValue = ProjectTranslationsJsonFormat(
        translationsJsonFormat: project.translationsJsonFormat ?? TranslationsJsonFormat.Simple,
        formatObjectInside: project.formatObjectInside,
      );
    }

    List<String>? ignoreDirectories = ignoreDirectoriesKey.currentState?.value;
    if (ignoreDirectories == null && project != null) {
      ignoreDirectories = project.directories;
    }

    final data = Project.fromJson(<String, dynamic>{
      Project.COL_ID: project?.id,
      Project.COL_NAME: nameController.text,
      Project.COL_DIRECTORY: directoryController.text,
      Project.COL_TRANSLATION_ASSETS: translationAssetsController.text,
      Project.COL_LANGUAGES: languagesKey.currentState!.value,
      Project.COL_PROGRAMMING_LANGUAGES: programmingLanguagesValue.programmingLanguages,
      Project.COL_TRANSLATION_KEYS: programmingLanguagesValue.translationKeys.map((translationKey) => translationKey.toJson()).toList(),
      Project.COL_LAST_SEEN: project?.lastSeen,
      Project.COL_UPDATED: now,
      Project.COL_CREATED: project?.created ?? now,
      Project.COL_TRANSLATIONS_JSON_FORMAT: translationsJsonFormatValue?.translationsJsonFormat.index,
      Project.COL_FORMAT_OBJECT_INSIDE: translationsJsonFormatValue?.formatObjectInside,
      Project.COL_IGNORE_DIRECTORIES: ignoreDirectories,
    });

    final dataTask = await MainDataProvider.instance!.executeDataTask<SaveProjectDataTask>(
      SaveProjectDataTask(
        data: data,
      ),
    );

    if (popOnSuccess && dataTask.result != null) {
      Navigator.of(context).pop(dataTask.result?.id);
    }
  }
}

/// If confirmed delete Project from DB
Future<void> deleteProject(
  BuildContext context, {
  required Project project,
  bool popOnSuccess = true,
}) async {
  final snapshot = AppDataState.of(context)!;

  final confirmed = await ConfirmDialog.show(
    context,
    isDanger: true,
    title: tt('dialog.confirm.title'),
    text: tt('delete_project.text'),
    noText: tt('dialog.no'),
    yesText: tt('dialog.yes'),
  );

  if (confirmed == true) {
    final dataTask = await MainDataProvider.instance!.executeDataTask<DeleteProjectDataTask>(
      DeleteProjectDataTask(
        data: project,
      ),
    );

    if (popOnSuccess &&
        dataTask.result != null &&
        ![
          ResponsiveScreen.SmallDesktop,
          ResponsiveScreen.LargeDesktop,
          ResponsiveScreen.ExtraLargeDesktop,
        ].contains(snapshot.responsiveScreen)) {
      Navigator.of(context).pop(dataTask.result?.id);
    }
  }
}

/// Update Project lastSeen in DB
Future<void> updateLastSeenOfProject(Project project) async {
  final now = DateTime.now().millisecondsSinceEpoch;

  project.lastSeen = now;

  await MainDataProvider.instance!.executeDataTask<SaveProjectDataTask>(
    SaveProjectDataTask(
      data: project,
    ),
  );
}

/// Sort list of Projects alphabetycally
void sortProjectsAlphabetycally(List<Project>? projects) {
  projects?.sort((a, b) => a.name.compareTo(b.name));
}

/// Sort list of Projects by lastSeen with most recent first
void sortProjectsByLastSeen(List<Project>? projects) {
  projects?.sort((a, b) => b.lastSeen.compareTo(a.lastSeen));
}

/// Find any Project that has Programming Language assigned
Future<Project?> anyProjectForProgrammingLanguage(int programmingLanguage) async {
  final dataTask = await MainDataProvider.instance!.executeDataTask(
    GetProjectsDataTask(data: ProjectQuery.fromJson({})),
  );

  final projects = dataTask.result;

  if (projects != null) {
    final filtered = projects.projects.where((project) => project.programmingLanguages.contains(programmingLanguage)).toList();

    if (filtered.isNotEmpty) {
      return filtered.first;
    }
  }

  return null;
}
