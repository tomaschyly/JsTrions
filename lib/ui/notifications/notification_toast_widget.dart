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
    late Color background;
    Color? textColor;

    switch (message.type) {
      case ScreenMessageType.error:
        background = kColorDanger;
        textColor = kColorTextPrimary;
        break;
      case ScreenMessageType.success:
        background = kColorSuccess;
        textColor = kColorTextSecondary;
        break;
      case ScreenMessageType.info:
        background = kColorWarning;
        textColor = kColorTextPrimary;
        break;
      default:
        background = kColorRed;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          margin: const EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 8),
          alignment: Alignment.center,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                cancelFunc();
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(minHeight: 48),
                decoration: BoxDecoration(
                  color: background,
                  borderRadius: appTheme.buttonsStyle.buttonStyle.borderRadius,
                ),
                alignment: Alignment.center,
                child: Text(
                  message.message,
                  style: fancyText(kTextBold.copyWith(
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
