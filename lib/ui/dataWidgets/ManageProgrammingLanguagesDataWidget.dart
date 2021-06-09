import 'package:js_trions/core/AppTheme.dart';
import 'package:js_trions/model/ProgrammingLanguage.dart';
import 'package:js_trions/model/ProgrammingLanguages.dart';
import 'package:js_trions/model/dataRequests/GetProgrammingLanguagesDataRequest.dart';
import 'package:js_trions/model/dataTasks/DeleteProgrammingLanguageDataTask.dart';
import 'package:js_trions/model/dataTasks/SaveProgrammingLanguageDataTask.dart';
import 'package:js_trions/model/providers/ProgrammingLanguageProvider.dart';
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
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _extensionController = TextEditingController();
  final _nameFocus = FocusNode();
  final _extensionFocus = FocusNode();

  /// Manually dispose of resources
  @override
  void dispose() {
    _nameController.dispose();
    _extensionController.dispose();
    _nameFocus.dispose();
    _extensionFocus.dispose();

    super.dispose();
  }

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

        programmingLanguages.programmingLanguages.sort((a, b) => a.name.compareTo(b.name));

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: kCommonHorizontalMarginHalf,
              runSpacing: kCommonVerticalMarginHalf,
              children: programmingLanguages.programmingLanguages
                  .map((ProgrammingLanguage programmingLanguage) => _ChipWidget(programmingLanguage: programmingLanguage))
                  .toList(),
            ),
            CommonSpaceV(),
            Form(
              key: _formKey,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormFieldWidget(
                      controller: _nameController,
                      focusNode: _nameFocus,
                      nextFocus: _extensionFocus,
                      label: tt('programming_languages.manage.name'),
                      validations: [
                        FormFieldValidation(
                          validator: validateRequired,
                          errorText: tt('validation.required'),
                        ),
                      ],
                    ),
                  ),
                  CommonSpaceHHalf(),
                  Expanded(
                    child: TextFormFieldWidget(
                      controller: _extensionController,
                      focusNode: _extensionFocus,
                      label: tt('programming_languages.manage.extension'),
                      validations: [
                        FormFieldValidation(
                          validator: validateRequired,
                          errorText: tt('validation.required'),
                        ),
                      ],
                    ),
                  ),
                  CommonSpaceH(),
                  IconButtonWidget(
                    svgAssetPath: 'images/plus.svg',
                    onTap: () => saveProgrammingLanguage(
                      context,
                      formKey: _formKey,
                      nameController: _nameController,
                      extensionController: _extensionController,
                    ),
                  ),
                ],
              ),
            ),
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
      padding: const EdgeInsets.only(left: kCommonHorizontalMarginHalf),
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
          CommonSpaceHHalf(),
          IconButtonWidget(
            style: kIconButtonStyle.copyWith(
              variant: IconButtonVariant.IconOnly,
              color: kColorRed,
            ),
            svgAssetPath: 'images/times.svg',
            onTap: () => deleteProgrammingLanguage(
              context,
              programmingLanguage,
            ),
          ),
        ],
      ),
    );
  }
}
