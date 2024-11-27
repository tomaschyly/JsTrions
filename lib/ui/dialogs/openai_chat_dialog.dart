import 'dart:convert';

import 'package:tch_appliable_core/tch_appliable_core.dart';
import 'package:tch_common_widgets/tch_common_widgets.dart';

class OpenAIChatDialog extends AbstractStatefulWidget {
  final String? contextDescription;

  ///OpenAIChatDialog initialization
  OpenAIChatDialog({
    super.key,
    this.contextDescription,
  });

  /// Show the dialog as a popup
  static Future<OpenAIChatDialogResult?> show(
    BuildContext context, {
    String? contextDescription,
  }) {
    return showDialog<OpenAIChatDialogResult>(
      context: context,
      builder: (BuildContext context) {
        return Material(
          color: Colors.transparent,
          child: OpenAIChatDialog(
            contextDescription: contextDescription,
          ),
        );
      },
    );
  }

  /// Create state for widget
  @override
  State<StatefulWidget> createState() => _OpenAIChatDialogState();
}

class OpenAIChatDialogResult {
  final String translation;

  /// OpenAIChatDialogResult initialization
  OpenAIChatDialogResult({
    required this.translation,
  });

  /// Convert to JSON string
  String toJson() {
    return jsonEncode({
      'translation': translation,
    });
  }

  /// Convert to String
  @override
  String toString() => 'OpenAIChatDialogResult(translation: $translation)';
}

class _OpenAIChatDialogState extends AbstractStatefulWidgetState<OpenAIChatDialog> {
  bool _fullScreen = false;

  /// Build content from widgets
  @override
  Widget buildContent(BuildContext context) {
    final commonTheme = context.commonTheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        alignment: Alignment.center,
        child: DialogContainer(
          style: commonTheme.dialogsStyle.listDialogStyle.dialogContainerStyle.copyWith(
            dialogWidth: _fullScreen ? double.infinity : 992,
            stretchContent: _fullScreen,
          ),
          content: [],
          dialogFooter: DialogFooter(
            style: commonTheme.dialogsStyle.listDialogStyle.dialogFooterStyle,
            noText: tt('dialog.cancel'),
            yesText: tt('openai_chat.dialog.submit'),
            noOnTap: () {
              Navigator.of(context).pop();
            },
            yesOnTap: () {
              //TODO
            },
          ),
        ),
      ),
    );
  }
}
