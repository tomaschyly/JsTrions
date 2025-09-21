import 'package:js_trions/core/app_theme.dart';
import 'package:js_trions/ui/screens/settings_screen.dart';
import 'package:tch_appliable_core/tch_appliable_core.dart';
import 'package:tch_common_widgets/tch_common_widgets.dart';

class DashboardInfoWidget extends StatelessWidget {
  final String title;
  final String text;
  final bool isDanger;
  final String? actionSettingsText;

  /// DashboardInfoWidget initialization
  const DashboardInfoWidget({
    super.key,
    required this.title,
    required this.text,
    this.isDanger = false,
    this.actionSettingsText,
  });

  /// Build content from widgets
  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: fancyText(kTextHeadline),
        ),
        CommonSpaceV(),
        Text(
          text,
          style: fancyText(kText).copyWith(
            color: isDanger ? kColorDanger : null,
          ),
        ),
        if (actionSettingsText?.isNotEmpty == true) ...[
          CommonSpaceV(),
          ButtonWidget(
            style: appTheme.buttonsStyle.buttonStyle.copyWith(
              widthWrapContent: true,
            ),
            text: actionSettingsText!,
            onTap: () {
              pushNamedNewStack(context, SettingsScreen.ROUTE, arguments: <String, String>{'router-no-animation': '1'});
            },
          ),
        ],
      ],
    );
  }
}

class DashboardInfoPayload {
  final String title;
  final String text;
  final bool isDanger;
  final String? actionSettingsText;

  /// DashboardInfoPayload initialization
  DashboardInfoPayload({
    required this.title,
    required this.text,
    this.isDanger = false,
    this.actionSettingsText,
  });

  /// Convert to String
  @override
  String toString() {
    return 'DashboardInfoPayload(title: $title, text: $text, isDanger: $isDanger, actionSettingsText: $actionSettingsText)';
  }
}
