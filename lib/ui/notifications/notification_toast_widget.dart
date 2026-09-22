import 'package:bot_toast/bot_toast.dart';
import 'package:js_trions/core/app_theme.dart';
import 'package:tch_appliable_core/tch_appliable_core.dart';

class NotificationToastWidget extends StatelessWidget {
  final AppTheme appTheme;
  final ScreenMessage message;
  final CancelFunc cancelFunc;

  /// NotificationToastWidget initialization
  const NotificationToastWidget({
    super.key,
    required this.appTheme,
    required this.message,
    required this.cancelFunc,
  });

  /// Create view layout from widgets
  @override
  Widget build(BuildContext context) {
    // Status fills read the same in both schemes, only their text is picked by contrast
    late Color background;
    Color? textColor;

    switch (message.type) {
      case ScreenMessageType.error:
        background = kColorDanger;
        textColor = kColorTextOnDark;
        break;
      case ScreenMessageType.success:
        background = kColorSuccess;
        textColor = kColorTextOnLight;
        break;
      case ScreenMessageType.info:
        background = kColorWarning;
        textColor = kColorTextOnDark;
        break;
      default:
        background = kColorDanger;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          margin: const EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 8),
          alignment: Alignment.center,
          child: Material(
            color: background,
            borderRadius: appTheme.buttonsStyle.buttonStyle.borderRadius,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              mouseCursor: SystemMouseCursors.click,
              borderRadius: appTheme.buttonsStyle.buttonStyle.borderRadius,
              onTap: () {
                cancelFunc();
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(minHeight: 48),
                alignment: Alignment.center,
                child: Text(
                  message.message,
                  style: fancyText(kTextBoldOf(context).copyWith(
                    color: textColor,
                  )),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
