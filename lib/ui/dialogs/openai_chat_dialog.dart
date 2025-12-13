import 'dart:convert';

import 'package:js_trions/core/app_preferences.dart';
import 'package:js_trions/core/app_theme.dart';
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
  final _formKey = GlobalKey<FormState>();
  final _textController = TextEditingController();
  final _textFocusNode = FocusNode();
  bool _fullScreen = false;

  /// State initialization
  @override
  void initState() {
    super.initState();

    _fullScreen = prefsInt(PREFS_OPENAI_CHAT_DIALOG_ENLARGED) == 1;
  }

  /// Manually dispose of resources
  @override
  void dispose() {
    _textController.dispose();
    _textFocusNode.dispose();

    super.dispose();
  }

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
          content: [
            Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DialogHeader(
                    style: commonTheme.dialogsStyle.listDialogStyle.dialogHeaderStyle,
                    title: tt('openai_chat.dialog.title'),
                    trailing: IconButtonWidget(
                      style: commonTheme.buttonsStyle.iconButtonStyle.copyWith(
                        variant: IconButtonVariant.IconOnly,
                        iconWidth: kButtonHeight,
                        iconHeight: kButtonHeight,
                      ),
                      svgAssetPath: _fullScreen ? 'images/icons8-shrink.svg' : 'images/icons8-enlarge.svg',
                      onTap: () => setStateNotDisposed(() {
                        _fullScreen = !_fullScreen;

                        prefsSetInt(PREFS_OPENAI_CHAT_DIALOG_ENLARGED, _fullScreen ? 1 : 0);
                      }),
                      tooltip: _fullScreen ? tt('openai_chat.dialog.shrink.tooltip') : tt('openai_chat.dialog.enlarge.tooltip'),
                    ),
                  ),
                  CommonSpaceVHalf(),
                ],
              ),
            ),
          ],
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
