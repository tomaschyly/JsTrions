import 'package:tch_appliable_core/tch_appliable_core.dart';

/// Save Project, works for both existing and new, and update data
Future<void> saveProject(
  BuildContext context, {
  required GlobalKey<FormState> formKey,
  bool popOnSuccess = true,
}) async {
  FocusScope.of(context).unfocus();

  if (formKey.currentState!.validate()) {
    final now = DateTime.now().millisecondsSinceEpoch;

    //TODO

    if (popOnSuccess) {
      Navigator.of(context).pop();
    }
  }
}
