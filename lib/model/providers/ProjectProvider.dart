import 'package:js_trions/model/Project.dart';
import 'package:js_trions/model/dataTasks/SaveProjectDataTask.dart';
import 'package:js_trions/ui/dataWidgets/ProjectProgrammingLanguagesFieldDataWidget.dart';
import 'package:js_trions/ui/widgets/ProjectLanguagesFieldWidget.dart';
import 'package:tch_appliable_core/tch_appliable_core.dart';

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
  bool popOnSuccess = true,
}) async {
  FocusScope.of(context).unfocus();

  if (formKey.currentState!.validate()) {
    final now = DateTime.now().millisecondsSinceEpoch;

    final programmingLanguagesValue = programmingLanguagesKey.currentState!.value;

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
