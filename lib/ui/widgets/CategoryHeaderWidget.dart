import 'package:js_trions/core/app_theme.dart';
import 'package:tch_appliable_core/tch_appliable_core.dart';
import 'package:tch_common_widgets/tch_common_widgets.dart';

class CategoryHeaderWidget extends StatelessWidget {
  final String text;
  final bool doubleMargin;

  /// CategoryHeaderWidget initialization
  CategoryHeaderWidget({
    required this.text,
    this.doubleMargin = false,
  });

  /// Create view layout from widgets
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: doubleMargin ? const EdgeInsets.only(bottom: kCommonVerticalMarginDouble) : const EdgeInsets.only(bottom: kCommonVerticalMargin),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Text(
            text,
            style: fancyText(kTextHeadline),
          ),
          CommonSpaceH(),
          Expanded(
            child: Container(
              height: 1,
              color: kColorSecondaryDark,
            ),
          ),
        ],
      ),
    );
  }
}
