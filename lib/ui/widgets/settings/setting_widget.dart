import 'package:js_trions/core/app_theme.dart';
import 'package:tch_appliable_core/tch_appliable_core.dart';
import 'package:tch_common_widgets/tch_common_widgets.dart';

class SettingWidget extends StatelessWidget {
  final String? label;
  final Widget content;
  final String? description;
  final Widget? trailing;

  /// SettingWidget initialization
  SettingWidget({
    required this.label,
    required this.content,
    required this.description,
    this.trailing,
  });

  /// Create view layout from widgets
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, style: fancyText(kTextBold)),
          CommonSpaceVHalf(),
        ],
        content,
        if (description != null) ...[
          CommonSpaceVHalf(),
          Text(description!, style: fancyText(kText)),
        ],
        if (trailing != null) ...[
          CommonSpaceVHalf(),
          trailing!,
        ],
        CommonSpaceVDouble(),
      ],
    );
  }
}
