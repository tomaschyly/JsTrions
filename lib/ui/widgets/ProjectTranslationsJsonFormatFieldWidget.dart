import 'package:flutter_svg/flutter_svg.dart';
import 'package:js_trions/core/AppTheme.dart';
import 'package:js_trions/model/Project.dart';
import 'package:js_trions/ui/widgets/ChipWidget.dart';
import 'package:tch_appliable_core/tch_appliable_core.dart';
import 'package:tch_common_widgets/tch_common_widgets.dart';

class ProjectTranslationsJsonFormatFieldWidget extends AbstractStatefulWidget {
  final Project? project;

  /// ProjectTranslationsJsonFormatFieldWidget initialization
  ProjectTranslationsJsonFormatFieldWidget({
    required Key key,
    this.project,
  }) : super(key: key);

  /// Create state for widget
  @override
  State<StatefulWidget> createState() => ProjectTranslationsJsonFormatFieldWidgetState();
}

class ProjectTranslationsJsonFormatFieldWidgetState extends AbstractStatefulWidgetState<ProjectTranslationsJsonFormatFieldWidget>
    with TickerProviderStateMixin {
  ProjectTranslationsJsonFormat get value => ProjectTranslationsJsonFormat(
        translationsJsonFormat: _translationsJsonFormat,
        formatObjectInside: _formatObjectInsideController.text,
      );

  TranslationsJsonFormat _translationsJsonFormat = TranslationsJsonFormat.Simple;
  final _formatObjectInsideController = TextEditingController();

  /// State initialization
  @override
  void initState() {
    super.initState();

    final theProject = widget.project;
    if (theProject != null) {
      _translationsJsonFormat = theProject.translationsJsonFormat ?? TranslationsJsonFormat.Simple;
      _formatObjectInsideController.text = theProject.formatObjectInside ?? '';
    }
  }

  /// Create screen content from widgets
  @override
  Widget buildContent(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: kCommonHorizontalMarginHalf,
          runSpacing: kCommonVerticalMarginHalf,
          children: [
            _ChipWidget(
              translationsJsonFormat: TranslationsJsonFormat.Simple,
              onTap: _selectFormat,
              selected: _translationsJsonFormat == TranslationsJsonFormat.Simple,
            ),
            _ChipWidget(
              translationsJsonFormat: TranslationsJsonFormat.ObjectInside,
              onTap: _selectFormat,
              selected: _translationsJsonFormat == TranslationsJsonFormat.ObjectInside,
            ),
          ],
        ),
        AnimatedSize(
          duration: kThemeAnimationDuration,
          vsync: this,
          alignment: Alignment.topCenter,
          child: _translationsJsonFormat == TranslationsJsonFormat.ObjectInside
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonSpaceVHalf(),
                    TextFormFieldWidget(
                      controller: _formatObjectInsideController,
                      label: tt('edit_project.field.format_object_inside'),
                      validations: [
                        FormFieldValidation(
                          validator: validateRequired,
                          errorText: tt('validation.required'),
                        ),
                      ],
                    ),
                  ],
                )
              : Container(),
        ),
        CommonSpaceVHalf(),
        Text(
          tt('edit_project.field.translations_json_format.hint'),
          style: fancyText(kText),
        ),
      ],
    );
  }

  /// Select TranslationsJsonFormat and update
  void _selectFormat(TranslationsJsonFormat translationsJsonFormat) {
    FocusScope.of(context).unfocus();

    setStateNotDisposed(() {
      _translationsJsonFormat = translationsJsonFormat;
    });
  }
}

class _ChipWidget extends StatelessWidget {
  final TranslationsJsonFormat translationsJsonFormat;
  final void Function(TranslationsJsonFormat translationsJsonFormat) onTap;
  final bool selected;

  /// ChipWidget initialization
  _ChipWidget({
    required this.translationsJsonFormat,
    required this.onTap,
    this.selected = false,
  });

  /// Create view layout from widgets
  @override
  Widget build(BuildContext context) {
    final commonTheme = CommonTheme.of<AppTheme>(context)!;

    String text = '';

    switch (translationsJsonFormat) {
      case TranslationsJsonFormat.Simple:
        text = tt('edit_project.field.translations_json_format.simple');
        break;
      case TranslationsJsonFormat.ObjectInside:
        text = tt('edit_project.field.translations_json_format.object_inside');
        break;
    }

    return ChipWidget(
      text: text,
      suffixIcon: SvgPicture.asset(
        selected ? 'images/circle-full.svg' : 'images/circle-empty.svg',
        width: commonTheme.buttonsStyle.iconButtonStyle.iconWidth,
        height: commonTheme.buttonsStyle.iconButtonStyle.iconHeight,
        color: commonTheme.buttonsStyle.iconButtonStyle.color,
      ),
      onTap: selected ? null : () => onTap(translationsJsonFormat),
    );
  }
}

class ProjectTranslationsJsonFormat {
  final TranslationsJsonFormat translationsJsonFormat;
  final String? formatObjectInside;

  /// ProjectTranslationsJsonFormat initialization
  ProjectTranslationsJsonFormat({
    required this.translationsJsonFormat,
    required this.formatObjectInside,
  });
}
