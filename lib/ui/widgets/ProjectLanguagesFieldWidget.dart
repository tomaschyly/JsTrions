import 'package:js_trions/core/AppTheme.dart';
import 'package:js_trions/model/Project.dart';
import 'package:js_trions/ui/widgets/ChipWidget.dart';
import 'package:tch_appliable_core/tch_appliable_core.dart';
import 'package:tch_common_widgets/tch_common_widgets.dart';

class ProjectLanguagesFieldWidget extends AbstractStatefulWidget {
  final Project? project;

  /// ProjectLanguagesFieldWidget initiliazation
  ProjectLanguagesFieldWidget({
    required Key key,
    this.project,
  }) : super(key: key);

  /// Create state for widget
  @override
  State<StatefulWidget> createState() => ProjectLanguagesFieldWidgetState();
}

class ProjectLanguagesFieldWidgetState extends AbstractStatefulWidgetState<ProjectLanguagesFieldWidget> with SingleTickerProviderStateMixin {
  List<String> get value => List<String>.from(_languages);

  List<String> _languages = [];
  final _formKey = GlobalKey<FormState>();
  final _languageController = TextEditingController();

  /// State initialization
  @override
  void initState() {
    super.initState();

    final theProject = widget.project;
    if (theProject != null) {
      _languages.addAll(theProject.languages);
    }

    if (_languages.isEmpty) {
      _languages.add('en');
    }
  }

  /// Manually dispose of resources
  @override
  void dispose() {
    _languageController.dispose();

    super.dispose();
  }

  /// Create screen content from widgets
  @override
  Widget buildContent(BuildContext context) {
    _languages.sort((a, b) => a.compareTo(b));

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
            children: _languages
                .map((String language) => _ChipWidget(
                      language: language,
                      onTap: _removeLanguage,
                      canTap: _languages.length > 1,
                    ))
                .toList(),
          ),
        ),
        CommonSpaceVHalf(),
        Form(
          key: _formKey,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextFormFieldWidget(
                  controller: _languageController,
                  label: tt('edit_project.field.new_language'),
                  validations: [
                    FormFieldValidation(
                      validator: validateRequired,
                      errorText: tt('validation.required'),
                    ),
                  ],
                ),
              ),
              CommonSpaceHHalf(),
              IconButtonWidget(
                svgAssetPath: 'images/plus.svg',
                onTap: _addLanguage,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Add new Language to selected Languages
  void _addLanguage() {
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      setStateNotDisposed(() {
        if (!_languages.contains(_languageController.text)) {
          _languages.add(_languageController.text);

          _languageController.text = '';
        }
      });
    }
  }

  /// Remove Language from selected Languages
  void _removeLanguage(String language) {
    setStateNotDisposed(() {
      _languages.remove(language);
    });
  }
}

class _ChipWidget extends StatelessWidget {
  final String language;
  final void Function(String language) onTap;
  final bool canTap;

  /// ChipWidget initialization
  _ChipWidget({
    required this.language,
    required this.onTap,
    this.canTap = true,
  });

  /// Create view layout from widgets
  @override
  Widget build(BuildContext context) {
    final commonTheme = CommonTheme.of<AppTheme>(context)!;

    return ChipWidget(
      variant: ChipVariant.LeftPadded,
      text: language,
      suffixIcon: canTap
          ? IconButtonWidget(
              style: commonTheme.buttonsStyle.iconButtonStyle.copyWith(
                variant: IconButtonVariant.IconOnly,
                color: kColorDanger,
              ),
              svgAssetPath: 'images/times.svg',
              onTap: () => onTap(language),
            )
          : Container(),
    );
  }
}
