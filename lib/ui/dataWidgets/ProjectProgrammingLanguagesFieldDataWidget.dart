import 'package:flutter_svg/svg.dart';
import 'package:js_trions/core/AppTheme.dart';
import 'package:js_trions/model/ProgrammingLanguage.dart';
import 'package:js_trions/model/ProgrammingLanguages.dart';
import 'package:js_trions/model/Project.dart';
import 'package:js_trions/model/dataRequests/GetProgrammingLanguagesDataRequest.dart';
import 'package:js_trions/model/providers/ProgrammingLanguageProvider.dart';
import 'package:tch_appliable_core/tch_appliable_core.dart';
import 'package:tch_appliable_core/utils/List.dart';
import 'package:tch_common_widgets/tch_common_widgets.dart';

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
    with SingleTickerProviderStateMixin {
  List<int> _selectedProgrammingLanguages = [];
  List<TranslationKey> _translationKeys = [];
  Map<int, TextEditingController> _fieldsControllers = Map();

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

  /// Manually dipose of resources
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
    return ValueListenableBuilder(
      valueListenable: dataSource!.results,
      builder: (BuildContext context, List<DataRequest> dataRequests, Widget? child) {
        final dataRequest = dataRequests.first as GetProgrammingLanguagesDataRequest;

        final ProgrammingLanguages? programmingLanguages = dataRequest.result;

        if (programmingLanguages == null) {
          return Container();
        }

        //TODO handle state where no PLs, at least one needed

        sortProgrammingLanguagesAlphabetycally(programmingLanguages.programmingLanguages);

        return AnimatedSize(
          duration: kThemeAnimationDuration,
          vsync: this,
          alignment: Alignment.topCenter,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: kCommonHorizontalMarginHalf,
                runSpacing: kCommonVerticalMarginHalf,
                children: programmingLanguages.programmingLanguages
                    .map((ProgrammingLanguage programmingLanguage) => _ChipWidget(
                          programmingLanguage: programmingLanguage,
                          selected: _selectedProgrammingLanguages.contains(programmingLanguage.id),
                          toggle: _toggle,
                        ))
                    .toList(),
              ),
              CommonSpaceVHalf(),
              ..._translationKeys.where((translationKey) => _selectedProgrammingLanguages.contains(translationKey.programmingLanguage)).map((translationKey) {
                final programmingLanguage =
                    programmingLanguages.programmingLanguages.firstWhere((programmingLanguage) => programmingLanguage.id == translationKey.programmingLanguage);

                return _TranslationKeyField(
                  translationKey: translationKey,
                  programmingLanguage: programmingLanguage,
                  textEditingController: _fieldsControllers[programmingLanguage.id!]!,
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  /// Toggle selection of Programming Language
  void _toggle(ProgrammingLanguage programmingLanguage) {
    setStateNotDisposed(() {
      if (_selectedProgrammingLanguages.contains(programmingLanguage.id)) {
        _selectedProgrammingLanguages.remove(programmingLanguage.id);
      } else {
        _selectedProgrammingLanguages.add(programmingLanguage.id!);

        final translationKey = _translationKeys.firstWhereOrNull((translationKey) => translationKey.programmingLanguage == programmingLanguage.id);

        if (translationKey == null) {
          _translationKeys.add(TranslationKey.fromJson(<String, dynamic>{
            'programmingLanguage': programmingLanguage.id,
            'key': programmingLanguage.key,
          }));

          _fieldsControllers[programmingLanguage.id!]?.dispose();
          _fieldsControllers[programmingLanguage.id!] = TextEditingController();
          _fieldsControllers[programmingLanguage.id!]!.text = programmingLanguage.key;
        }
      }
    });
  }
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
    return ClipRRect(
      borderRadius: kButtonStyle.borderRadius,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          child: Container(
            height: kButtonHeight,
            padding: const EdgeInsets.symmetric(horizontal: kCommonHorizontalMarginHalf),
            decoration: BoxDecoration(
              border: Border.all(
                width: 1,
                color: kColorTextPrimary,
              ),
              borderRadius: kButtonStyle.borderRadius,
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
                SvgPicture.asset(
                  selected ? 'images/circle-full.svg' : 'images/circle-empty.svg',
                  width: kIconButtonStyle.iconWidth,
                  height: kIconButtonStyle.iconHeight,
                  color: kIconButtonStyle.color,
                ),
              ],
            ),
          ),
          onTap: () => toggle(programmingLanguage),
        ),
      ),
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
