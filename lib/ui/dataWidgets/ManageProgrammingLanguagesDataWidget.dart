import 'package:js_trions/core/AppTheme.dart';
import 'package:js_trions/model/ProgrammingLanguage.dart';
import 'package:js_trions/model/ProgrammingLanguages.dart';
import 'package:js_trions/model/dataRequests/GetProgrammingLanguagesDataRequest.dart';
import 'package:tch_appliable_core/tch_appliable_core.dart';
import 'package:tch_common_widgets/tch_common_widgets.dart';

class ManageProgrammingLanguagesDataWidget extends AbstractDataWidget {
  /// ManageProgrammingLanguagesDataWidget initialization
  ManageProgrammingLanguagesDataWidget()
      : super(
          dataRequests: [GetProgrammingLanguagesDataRequest()],
        );

  /// Create state for widget
  @override
  State<StatefulWidget> createState() => _ManageProgrammingLanguagesDataWidgetState();
}

class _ManageProgrammingLanguagesDataWidgetState extends AbstractDataWidgetState<ManageProgrammingLanguagesDataWidget> {
  /// Create screen content from widgets
  @override
  Widget buildContent(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: dataSource!.results,
      builder: (BuildContext context, List<DataRequest> dataRequests, Widget? child) {
        final dataRequest = dataRequests.first as GetProgrammingLanguagesDataRequest;

        final ProgrammingLanguages? programmingLanguages = dataRequest.result;

        if (programmingLanguages == null) {
          return Container();
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: kCommonHorizontalMarginHalf,
              runSpacing: kCommonVerticalMargin,
              children: programmingLanguages.programmingLanguages
                  .map((ProgrammingLanguage programmingLanguage) => _ChipWidget(programmingLanguage: programmingLanguage))
                  .toList(),
            ),
            CommonSpaceV(),
          ],
        );
      },
    );
  }
}

class _ChipWidget extends StatelessWidget {
  final ProgrammingLanguage programmingLanguage;

  /// ChipWidget initialization
  _ChipWidget({
    required this.programmingLanguage,
  });

  /// Create view layout from widgets
  @override
  Widget build(BuildContext context) {
    return Container(
      height: kButtonHeight,
      padding: const EdgeInsets.symmetric(horizontal: kCommonHorizontalMarginHalf),
      decoration: BoxDecoration(
        border: Border.all(
          width: 1,
          color: kColorTextPrimary,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            programmingLanguage.name,
            style: fancyText(kText),
          ),
        ],
      ),
    );
  }
}
