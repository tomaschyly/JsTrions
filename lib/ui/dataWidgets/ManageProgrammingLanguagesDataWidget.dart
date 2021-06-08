import 'package:js_trions/model/ProgrammingLanguages.dart';
import 'package:js_trions/model/dataRequests/GetProgrammingLanguagesDataRequest.dart';
import 'package:tch_appliable_core/tch_appliable_core.dart';

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

        return Container(); //TODO
      },
    );
  }
}
