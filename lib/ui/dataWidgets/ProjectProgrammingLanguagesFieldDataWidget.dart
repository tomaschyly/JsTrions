import 'package:flutter/gestures.dart';
import 'package:flutter_svg/svg.dart';
import 'package:js_trions/core/app_theme.dart';
import 'package:js_trions/model/ProgrammingLanguage.dart';
import 'package:js_trions/model/ProgrammingLanguages.dart';
import 'package:js_trions/model/Project.dart';
import 'package:js_trions/model/dataRequests/GetProgrammingLanguagesDataRequest.dart';
import 'package:js_trions/service/ProgrammingLanguageService.dart';
import 'package:js_trions/ui/widgets/ChipWidget.dart';
import 'package:tch_appliable_core/tch_appliable_core.dart';
import 'package:tch_appliable_core/utils/list.dart';
import 'package:tch_common_widgets/tch_common_widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class ProjectProgrammingLanguagesFieldDataWidget extends AbstractDataWidget {
  final Project? project;

  /// ProjectProgrammingLanguagesFieldDataWidget initialization
  ProjectProgrammingLanguagesFieldDataWidget({
    required Key key,
    this.project,
  }) : super(
          key: key,
          dataRequests: [GetProgrammingLanguagesDataRequest()],
        );

  /// Create state for widget
  @override
  State<StatefulWidget> createState() => ProjectProgrammingLanguagesFieldDataWidgetState();
}

class ProjectProgrammingLanguagesFieldDataWidgetState extends AbstractDataWidgetState<ProjectProgrammingLanguagesFieldDataWidget>
    with TickerProviderStateMixin {
  ProjectProgrammingLanguagesFieldDataWidgetValue get value => ProjectProgrammingLanguagesFieldDataWidgetValue(
        programmingLanguages: _selectedProgrammingLanguages,
        translationKeys: _translationKeys,
      );

  int? _projectId;
  List<int> _selectedProgrammingLanguages = [];
  List<TranslationKey> _translationKeys = [];
  Map<int, TextEditingController> _fieldsControllers = Map();
  bool _isError = false;
  String _errorText = '';

  /// State initialization
  @override
  void initState() {
    super.initState();

    final theProject = widget.project;
    if (theProject != null) {
      _selectedProgrammingLanguages.addAll(theProject.programmingLanguages);
      _translationKeys.addAll(theProject.translationKeys);
    }
  }

  /// Manually dispose of resources
  @override
  void dispose() {
    _fieldsControllers.forEach((key, controller) {
      controller.dispose();
    });

    super.dispose();
  }

  /// Create screen content from widgets
  @override
  Widget buildContent(BuildContext context) {
    final commonTheme = CommonTheme.of(context)!;

    return ValueListenableBuilder(
      valueListenable: dataSource!.results,
      builder: (BuildContext context, List<DataRequest> dataRequests, Widget? child) {
        final dataRequest = dataRequests.first as GetProgrammingLanguagesDataRequest;

        final ProgrammingLanguages? programmingLanguages = dataRequest.result;

        if (programmingLanguages == null) {
          return Container();
        }

        if (programmingLanguages.programmingLanguages.isEmpty) {
          return Padding(
            padding: const EdgeInsets.only(left: 8, top: 8, right: 8),
            child: Text(
              tt('edit_project.field.programming_languages.empty_error'),
              style: fancyText(commonTheme.formStyle.textFormFieldStyle.inputDecoration.errorStyle!).copyWith(
                color: commonTheme.formStyle.textFormFieldStyle.errorColor,
              ),
            ),
          );
        }

        sortProgrammingLanguagesAlphabetycally(programmingLanguages.programmingLanguages);

        _initProject(programmingLanguages.programmingLanguages);

        final availableTranslationKeys = _translationKeys.where((translationKey) =>
            _selectedProgrammingLanguages.contains(translationKey.programmingLanguage) &&
            programmingLanguages.programmingLanguages.any((programmingLanguage) => programmingLanguage.id == translationKey.programmingLanguage));

        return AnimatedSize(
          duration: kThemeAnimationDuration,
          alignment: Alignment.topCenter,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FormField<List<int>>(
                builder: (FormFieldState<List<int>> field) {
                  return Wrap(
                    spacing: kCommonHorizontalMarginHalf,
                    runSpacing: kCommonVerticalMarginHalf,
                    children: programmingLanguages.programmingLanguages
                        .map((ProgrammingLanguage programmingLanguage) => _ChipWidget(
                              programmingLanguage: programmingLanguage,
                              selected: _selectedProgrammingLanguages.contains(programmingLanguage.id),
                              toggle: _toggle,
                            ))
                        .toList(),
                  );
                },
                validator: (List<int>? value) {
                  value = _selectedProgrammingLanguages;

                  final validated = value.isEmpty ? tt('edit_project.field.programming_languages.error') : null;

                  setStateNotDisposed(() {
                    _isError = validated != null;
                    _errorText = validated ?? _errorText;
                  });

                  return validated;
                },
              ),
              if (_isError)
                Padding(
                  padding: const EdgeInsets.only(left: 8, top: 8, right: 8),
                  child: Text(
                    _errorText,
                    style: fancyText(commonTheme.formStyle.textFormFieldStyle.inputDecoration.errorStyle!).copyWith(
                      color: commonTheme.formStyle.textFormFieldStyle.errorColor,
                    ),
                  ),
                ),
              CommonSpaceVHalf(),
              ...availableTranslationKeys.map((translationKey) {
                final programmingLanguage =
                    programmingLanguages.programmingLanguages.firstWhere((programmingLanguage) => programmingLanguage.id == translationKey.programmingLanguage);

                return _TranslationKeyField(
                  translationKey: translationKey,
                  programmingLanguage: programmingLanguage,
                  textEditingController: _fieldsControllers[programmingLanguage.id!]!,
                );
              }).toList(),
              if (availableTranslationKeys.isNotEmpty) ...[
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: tt('edit_project.field.programming_languages.hint'),
                        style: fancyText(kText),
                      ),
                      TextSpan(
                        text: 'https://regexr.com/',
                        style: fancyText(kTextBold.copyWith(
                          color: kColorSecondary,
                          decoration: TextDecoration.underline,
                          decorationColor: kColorSecondary,
                        )),
                        recognizer: TapGestureRecognizer()..onTap = () => launch('https://regexr.com/'),
                      ),
                    ],
                  ),
                ),
                CommonSpaceVHalf(),
              ],
            ],
          ),
        );
      },
    );
  }

  /// Initialize by existing Project
  void _initProject(List<ProgrammingLanguage> programmingLanguages) {
    final theProject = widget.project;
    if (theProject != null && theProject.id != _projectId) {
      _projectId = theProject.id;

      for (ProgrammingLanguage programmingLanguage in programmingLanguages) {
        if (_selectedProgrammingLanguages.contains(programmingLanguage.id)) {
          final translationKey = _translationKeys.firstWhere((translationKey) => translationKey.programmingLanguage == programmingLanguage.id);

          final controller = TextEditingController();
          controller.addListener(() => translationKey.key = controller.text);

          _fieldsControllers[programmingLanguage.id!] = controller;
          _fieldsControllers[programmingLanguage.id!]!.text = translationKey.key;
        }
      }
    }
  }

  /// Toggle selection of Programming Language
  void _toggle(ProgrammingLanguage programmingLanguage) {
    setStateNotDisposed(() {
      if (_selectedProgrammingLanguages.contains(programmingLanguage.id)) {
        _selectedProgrammingLanguages.remove(programmingLanguage.id);
      } else {
        _selectedProgrammingLanguages.add(programmingLanguage.id!);

        TranslationKey? translationKey = _translationKeys.firstWhereOrNull((translationKey) => translationKey.programmingLanguage == programmingLanguage.id);

        if (translationKey == null) {
          translationKey = TranslationKey.fromJson(<String, dynamic>{
            'programmingLanguage': programmingLanguage.id,
            'key': programmingLanguage.key,
          });
          _translationKeys.add(translationKey);
        }

        final controller = TextEditingController();
        controller.addListener(() => translationKey!.key = controller.text);

        _fieldsControllers[programmingLanguage.id!]?.dispose();
        _fieldsControllers[programmingLanguage.id!] = controller;
        _fieldsControllers[programmingLanguage.id!]!.text = translationKey.key;
      }
    });
  }
}

class ProjectProgrammingLanguagesFieldDataWidgetValue {
  final List<int> programmingLanguages;
  final List<TranslationKey> translationKeys;

  /// ProjectProgrammingLanguagesFieldDataWidgetValue initialization
  ProjectProgrammingLanguagesFieldDataWidgetValue({
    required this.programmingLanguages,
    required this.translationKeys,
  });
}

class _ChipWidget extends StatelessWidget {
  final ProgrammingLanguage programmingLanguage;
  final bool selected;
  final void Function(ProgrammingLanguage programmingLanguage) toggle;

  /// ChipWidget initialization
  _ChipWidget({
    required this.programmingLanguage,
    this.selected = false,
    required this.toggle,
  });

  /// Create view layout from widgets
  @override
  Widget build(BuildContext context) {
    final commonTheme = CommonTheme.of<AppTheme>(context)!;

    return ChipWidget(
      text: programmingLanguage.name,
      suffixIcon: SvgPicture.asset(
        selected ? 'images/circle-full.svg' : 'images/circle-empty.svg',
        width: commonTheme.buttonsStyle.iconButtonStyle.iconWidth,
        height: commonTheme.buttonsStyle.iconButtonStyle.iconHeight,
        color: commonTheme.buttonsStyle.iconButtonStyle.color,
      ),
      onTap: () => toggle(programmingLanguage),
    );
  }
}

class _TranslationKeyField extends StatelessWidget {
  final TranslationKey translationKey;
  final ProgrammingLanguage programmingLanguage;
  final TextEditingController textEditingController;

  /// TranslationKeyField initialization
  _TranslationKeyField({
    required this.translationKey,
    required this.programmingLanguage,
    required this.textEditingController,
  });

  /// Create view layout from widgets
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextFormFieldWidget(
          controller: textEditingController,
          label: programmingLanguage.name,
          validations: [
            FormFieldValidation(
              validator: validateRequired,
              errorText: tt('validation.required'),
            ),
          ],
        ),
        CommonSpaceVHalf(),
      ],
    );
  }
}
