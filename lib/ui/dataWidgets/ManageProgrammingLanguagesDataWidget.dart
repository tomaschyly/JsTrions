import 'package:js_trions/core/AppTheme.dart';
import 'package:js_trions/model/ProgrammingLanguage.dart';
import 'package:js_trions/model/ProgrammingLanguages.dart';
import 'package:js_trions/model/dataRequests/GetProgrammingLanguagesDataRequest.dart';
import 'package:js_trions/model/providers/ProgrammingLanguageProvider.dart';
import 'package:js_trions/ui/widgets/ChipWidget.dart';
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

class _ManageProgrammingLanguagesDataWidgetState extends AbstractDataWidgetState<ManageProgrammingLanguagesDataWidget> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _extensionController = TextEditingController();
  final _keyController = TextEditingController();
  final _nameFocus = FocusNode();
  final _extensionFocus = FocusNode();
  final _keyFocus = FocusNode();

  /// Manually dispose of resources
  @override
  void dispose() {
    _nameController.dispose();
    _extensionController.dispose();
    _keyController.dispose();
    _nameFocus.dispose();
    _extensionFocus.dispose();
    _keyFocus.dispose();

    super.dispose();
  }

  /// Create screen content from widgets
  @override
  Widget buildContent(BuildContext context) {
    final commonTheme = CommonTheme.of<AppTheme>(context)!;

    return ValueListenableBuilder(
      valueListenable: dataSource!.results,
      builder: (BuildContext context, List<DataRequest> dataRequests, Widget? child) {
        final dataRequest = dataRequests.first as GetProgrammingLanguagesDataRequest;

        final ProgrammingLanguages? programmingLanguages = dataRequest.result;

        if (programmingLanguages == null) {
          return Container();
        }

        sortProgrammingLanguagesAlphabetycally(programmingLanguages.programmingLanguages);

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedSize(
              duration: kThemeAnimationDuration,
              vsync: this,
              alignment: Alignment.topCenter,
              child: Wrap(
                spacing: kCommonHorizontalMarginHalf,
                runSpacing: kCommonVerticalMarginHalf,
                children: programmingLanguages.programmingLanguages
                    .map((ProgrammingLanguage programmingLanguage) => _ChipWidget(programmingLanguage: programmingLanguage))
                    .toList(),
              ),
            ),
            CommonSpaceV(),
            Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
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
                          nextFocus: _keyFocus,
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
                          keyController: _keyController,
                        ),
                      ),
                    ],
                  ),
                  CommonSpaceV(),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextFormFieldWidget(
                          controller: _keyController,
                          focusNode: _keyFocus,
                          label: tt('programming_languages.manage.key'),
                          validations: [
                            FormFieldValidation(
                              validator: validateRequired,
                              errorText: tt('validation.required'),
                            ),
                          ],
                        ),
                      ),
                      CommonSpaceH(),
                      Container(
                        width: commonTheme.buttonsStyle.iconButtonStyle.width,
                      ),
                    ],
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
    final commonTheme = CommonTheme.of<AppTheme>(context)!;

    return ChipWidget(
      variant: ChipVariant.LeftPadded,
      text: programmingLanguage.name,
      suffixIcon: IconButtonWidget(
        style: commonTheme.buttonsStyle.iconButtonStyle.copyWith(
          variant: IconButtonVariant.IconOnly,
          color: kColorDanger,
        ),
        svgAssetPath: 'images/times.svg',
        onTap: () => deleteProgrammingLanguage(
          context,
          programmingLanguage,
        ),
      ),
    );
  }
}
