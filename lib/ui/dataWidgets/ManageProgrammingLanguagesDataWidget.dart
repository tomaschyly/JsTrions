import 'package:js_trions/core/app_theme.dart';
import 'package:js_trions/model/ProgrammingLanguage.dart';
import 'package:js_trions/model/ProgrammingLanguages.dart';
import 'package:js_trions/model/dataRequests/GetProgrammingLanguagesDataRequest.dart';
import 'package:js_trions/service/ProgrammingLanguageService.dart';
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
  ProgrammingLanguage? _editInProgress;

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
              alignment: Alignment.topCenter,
              child: Wrap(
                spacing: kCommonHorizontalMarginHalf,
                runSpacing: kCommonVerticalMarginHalf,
                children: programmingLanguages.programmingLanguages
                    .map((ProgrammingLanguage programmingLanguage) => _ChipWidget(
                          programmingLanguage: programmingLanguage,
                          edit: _edit,
                        ))
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
                        svgAssetPath: _editInProgress != null ? 'images/save.svg' : 'images/plus.svg',
                        onTap: () => _save(context),
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

  /// Save existing or create new ProgrammingLanguage
  void _save(BuildContext context) {
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      saveProgrammingLanguage(
        context,
        formKey: _formKey,
        id: _editInProgress?.id,
        nameController: _nameController,
        extensionController: _extensionController,
        keyController: _keyController,
      );

      setStateNotDisposed(() {
        _editInProgress = null;
      });
    }
  }

  /// Start edit of existing ProgrammingLanguage
  void _edit(ProgrammingLanguage programmingLanguage) {
    _nameController.text = programmingLanguage.name;
    _extensionController.text = programmingLanguage.extension;
    _keyController.text = programmingLanguage.key;

    setStateNotDisposed(() {
      _editInProgress = programmingLanguage;
    });
  }
}

class _ChipWidget extends StatelessWidget {
  final ProgrammingLanguage programmingLanguage;
  final void Function(ProgrammingLanguage programmingLanguage) edit;

  /// ChipWidget initialization
  _ChipWidget({
    required this.programmingLanguage,
    required this.edit,
  });

  /// Create view layout from widgets
  @override
  Widget build(BuildContext context) {
    final commonTheme = CommonTheme.of<AppTheme>(context)!;

    return ChipWidget(
      variant: ChipVariant.LeftPadded,
      text: programmingLanguage.name,
      suffixIcon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButtonWidget(
            style: commonTheme.buttonsStyle.iconButtonStyle.copyWith(
              variant: IconButtonVariant.IconOnly,
              iconWidth: 16,
              iconHeight: 16,
            ),
            svgAssetPath: 'images/pen.svg',
            onTap: () => edit(programmingLanguage),
          ),
          IconButtonWidget(
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
        ],
      ),
    );
  }
}
