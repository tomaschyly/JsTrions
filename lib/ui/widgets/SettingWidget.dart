import 'package:js_trions/core/AppTheme.dart';
import 'package:tch_appliable_core/tch_appliable_core.dart';
import 'package:tch_common_widgets/tch_common_widgets.dart';

class SettingWidget extends StatelessWidget {
  final String label;
  final Widget content;
  final String description;

  /// SettingWidget initialization
  SettingWidget({
    required this.label,
    required this.content,
    required this.description,
  });

  /// Create view layout from widgets
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: fancyText(kTextBold)),
        CommonSpaceVHalf(),
        content,
        CommonSpaceVHalf(),
        Text(description, style: fancyText(kText)),
        CommonSpaceVDouble(),
      ],
    );
  }
}
