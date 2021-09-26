import 'package:js_trions/core/AppTheme.dart';
import 'package:js_trions/model/Info.dart';
import 'package:tch_appliable_core/tch_appliable_core.dart';
import 'package:tch_common_widgets/tch_common_widgets.dart';

class InfoDialog extends AbstractStatefulWidget {
  final Info info;

  /// InfoDialog initialization
  InfoDialog({
    required this.info,
  });

  /// Show the popup as dialog
  static Future<void> show(BuildContext context, {required Info info}) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Material(
          color: Colors.transparent,
          child: InfoDialog(
            info: info,
          ),
        );
      },
      barrierColor: kColorShadow,
    );
  }

  /// Create state for widget
  @override
  State<StatefulWidget> createState() => _InfoDialogState();
}

class _InfoDialogState extends AbstractStatefulWidgetState<InfoDialog> {
  /// Create view layout from widgets
  @override
  Widget buildContent(BuildContext context) {
    final commonTheme = CommonTheme.of<AppTheme>(context)!;

    String theHeadline = widget.info.translatedHeadline(Translator.instance!.currentLanguage);
    String? theText = widget.info.translatedText(Translator.instance!.currentLanguage);

    return DialogContainer(
      style: commonTheme.dialogsStyle.listDialogStyle.dialogContainerStyle,
      isScrollable: !widget.info.isWelcome,
      content: [
        Stack(
          children: [
            if (widget.info.isWelcome)
              Positioned(
                top: 0,
                right: 0,
                child: Image.asset(
                  'images/tomas-chylyV3-padded-black-circle.png',
                  width: 48,
                  height: 48,
                ),
              ),
            if (widget.info.type != InfoType.FullImageOnly)
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (theHeadline.isNotEmpty) ...[
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: Text(
                            theHeadline,
                            style: fancyText(kTextHeadline),
                          ),
                        ),
                      ],
                    ),
                    CommonSpaceV(),
                  ],
                  if (theText != null &&
                      theText.isNotEmpty &&
                      (widget.info.isWelcome || widget.info.type == InfoType.TextOnly || widget.info.type == InfoType.ImageText)) ...[
                    Text(
                      theText,
                      style: fancyText(kText),
                      textAlign: TextAlign.start,
                    ),
                    CommonSpaceV(),
                  ],
                ],
              ),
          ],
        ),
      ],
      dialogFooter: DialogFooter(
        style: commonTheme.dialogsStyle.listDialogStyle.dialogFooterStyle,
        noText: tt('info.popup.close'),
        yesText: null,
        noOnTap: () {
          Navigator.pop(context, null);
        },
      ),
    );
  }
}
