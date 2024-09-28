import 'package:js_trions/core/AppPreferences.dart';
import 'package:js_trions/model/Info.dart';
import 'package:js_trions/ui/dialogs/InfoDialog.dart';
import 'package:tch_appliable_core/tch_appliable_core.dart';

bool _intro = true;

/// Determine and show info modal on app intro
Future<void> determineInfo(BuildContext context) async {
  if (!_intro) {
    return;
  }
  _intro = false;

  if (prefsInt(PREFS_WELCOME) != 1) {
    prefsSetInt(PREFS_WELCOME, 1);

    await Future.delayed(kThemeAnimationDuration, () => InfoDialog.show(context, info: Info.welcome()));
  }
}
