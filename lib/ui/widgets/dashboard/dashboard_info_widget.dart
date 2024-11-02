import 'package:js_trions/core/app_theme.dart';
import 'package:tch_appliable_core/tch_appliable_core.dart';
import 'package:tch_common_widgets/tch_common_widgets.dart';

class DashboardInfoWidget extends StatelessWidget {
  final String title;
  final String text;
  final bool isDanger;

  /// DashboardInfoWidget initialization
  const DashboardInfoWidget({
    super.key,
    required this.title,
    required this.text,
    this.isDanger = false,
  });

  /// Build content from widgets
  @override
  Widget build(BuildContext context) {
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
      ],
    );
  }
}

class DashboardInfoPayload {
  final String title;
  final String text;
  final bool isDanger;

  /// DashboardInfoPayload initialization
  DashboardInfoPayload({
    required this.title,
    required this.text,
    this.isDanger = false,
  });

  /// Convert to String
  @override
  String toString() {
    return 'DashboardInfoPayload(title: $title, text: $text, isDanger: $isDanger)';
  }
}
