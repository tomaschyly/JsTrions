import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:js_trions/core/AppTheme.dart';
import 'package:js_trions/model/Project.dart';
import 'package:js_trions/model/providers/ProjectProvider.dart';
import 'package:js_trions/ui/dataWidgets/ProjectProgrammingLanguagesFieldDataWidget.dart';
import 'package:js_trions/ui/widgets/ProjectIgnoreDirectoriesWidget.dart';
import 'package:js_trions/ui/widgets/ProjectLanguagesFieldWidget.dart';
import 'package:js_trions/ui/widgets/ProjectTranslationsJsonFormatFieldWidget.dart';
import 'package:js_trions/ui/widgets/ToggleContainerWidget.dart';
import 'package:tch_appliable_core/tch_appliable_core.dart';
import 'package:tch_common_widgets/tch_common_widgets.dart';

class EditProjectDialog extends AbstractStatefulWidget {
  final Project? project;

  /// EditProjectDialog initialization
  EditProjectDialog({
    this.project,
  });

  /// Show the dialog as a popup
  static Future<int?> show(
    BuildContext context, {
    Project? project,
  }) {
    return showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return Material(
          color: Colors.transparent,
          child: EditProjectDialog(project: project),
        );
      },
    );
  }

  /// Create state for widget
  @override
  State<StatefulWidget> createState() => _EditProjectDialogState();
}

class _EditProjectDialogState extends AbstractStatefulWidgetState<EditProjectDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _directoryController = TextEditingController();
  final _translationAssetsController = TextEditingController();
  final _languagesKey = GlobalKey<ProjectLanguagesFieldWidgetState>();
  final _programmingLanguagesKey = GlobalKey<ProjectProgrammingLanguagesFieldDataWidgetState>();
  final _translationsJsonFormatKey = GlobalKey<ProjectTranslationsJsonFormatFieldWidgetState>();
  final _ignoreDirectoriesKey = GlobalKey<ProjectIgnoreDirectoriesWidgetState>();
  final _nameFocus = FocusNode();
  final _directoryFocus = FocusNode();
  final _translationAssetsFocus = FocusNode();
  String _directoryPath = '';

  /// State initialization
  @override
  void initState() {
    super.initState();

    _directoryController.addListener(_directoryUpdated);

    final theProject = widget.project;
    if (theProject != null) {
      _nameController.text = theProject.name;
      _directoryController.text = theProject.directory;
      _translationAssetsController.text = theProject.translationAssets;

      _directoryPath = theProject.directory;
    }
  }

  /// Manually dispose of resources
  @override
  void dispose() {
    _directoryController.removeListener(_directoryUpdated);

    _nameController.dispose();
    _directoryController.dispose();
    _translationAssetsController.dispose();
    _nameFocus.dispose();
    _directoryFocus.dispose();
    _translationAssetsFocus.dispose();

    super.dispose();
  }

  /// Create view layout from widgets
  @override
  Widget buildContent(BuildContext context) {
    final commonTheme = CommonTheme.of<AppTheme>(context)!;

    final theProject = widget.project;

    return DialogContainer(
      style: commonTheme.dialogsStyle.listDialogStyle.dialogContainerStyle,
      content: [
        Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DialogHeader(
                style: commonTheme.dialogsStyle.listDialogStyle.dialogHeaderStyle,
                title: theProject != null ? tt('edit_project.title.edit').replaceAll(r'$name', theProject.name) : tt('edit_project.title.add'),
              ),
              CommonSpaceVHalf(),
              TextFormFieldWidget(
                controller: _nameController,
                focusNode: _nameFocus,
                nextFocus: _directoryFocus,
                label: tt('edit_project.field.name'),
                validations: [
                  FormFieldValidation(
                    validator: validateRequired,
                    errorText: tt('validation.required'),
                  ),
                ],
              ),
              CommonSpaceVHalf(),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormFieldWidget(
                      controller: _directoryController,
                      focusNode: _directoryFocus,
                      nextFocus: _translationAssetsFocus,
                      label: tt('edit_project.field.directory'),
                      validations: [
                        FormFieldValidation(
                          validator: validateRequired,
                          errorText: tt('validation.required'),
                        ),
                        FormFieldValidation(
                          validator: (String? value) {
                            final directory = Directory(value!);

                            bool exists = false;
                            try {
                              exists = directory.existsSync();
                            } catch (e, t) {
                              debugPrint('TCH_e $e\n$t');
                            }

                            return exists;
                          },
                          errorText: tt('edit_project.field.directory.error'),
                        ),
                      ],
                    ),
                  ),
                  CommonSpaceHHalf(),
                  IconButtonWidget(
                    svgAssetPath: 'images/folder.svg',
                    onTap: () => _pickDirectory(context),
                  ),
                ],
              ),
              CommonSpaceVHalf(),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormFieldWidget(
                      controller: _translationAssetsController,
                      focusNode: _translationAssetsFocus,
                      label: tt('edit_project.field.translation_assets'),
                      validations: [
                        FormFieldValidation(
                          validator: validateRequired,
                          errorText: tt('validation.required'),
                        ),
                        FormFieldValidation(
                          validator: (String? value) {
                            final directory = Directory('${_directoryController.text}$value');

                            bool exists = false;
                            try {
                              exists = directory.existsSync();
                            } catch (e, t) {
                              debugPrint('TCH_e $e\n$t');
                            }

                            return exists;
                          },
                          errorText: tt('edit_project.field.translation_assets.error'),
                        ),
                      ],
                    ),
                  ),
                  CommonSpaceHHalf(),
                  IconButtonWidget(
                    svgAssetPath: 'images/folder.svg',
                    onTap: () => _pickDirectory(context, true),
                  ),
                ],
              ),
              CommonSpaceVHalf(),
              Text(
                tt('edit_project.field.translation_assets.hint'),
                style: fancyText(kText),
              ),
              CommonSpaceVHalf(),
              ProjectLanguagesFieldWidget(
                key: _languagesKey,
                project: widget.project,
              ),
              CommonSpaceVHalf(),
              ProjectProgrammingLanguagesFieldDataWidget(
                key: _programmingLanguagesKey,
                project: widget.project,
              ),
              CommonSpaceVHalf(),
              ToggleContainerWidget(
                title: tt('edit_project.advanced'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ProjectTranslationsJsonFormatFieldWidget(
                      key: _translationsJsonFormatKey,
                      project: widget.project,
                    ),
                    CommonSpaceVHalf(),
                    ProjectIgnoreDirectoriesWidget(
                      key: _ignoreDirectoriesKey,
                      project: widget.project,
                      projectDirectory: _directoryPath,
                    ),
                  ],
                ),
                borderLess: true,
              ),
              CommonSpaceVHalf(),
            ],
          ),
        ),
      ],
      dialogFooter: DialogFooter(
        style: commonTheme.dialogsStyle.listDialogStyle.dialogFooterStyle,
        noText: tt('dialog.cancel'),
        yesText: tt('edit_project.submit'),
        noOnTap: () {
          Navigator.of(context).pop();
        },
        yesOnTap: () => saveProject(
          context,
          formKey: _formKey,
          project: widget.project,
          nameController: _nameController,
          directoryController: _directoryController,
          translationAssetsController: _translationAssetsController,
          languagesKey: _languagesKey,
          programmingLanguagesKey: _programmingLanguagesKey,
          translationsJsonFormatKey: _translationsJsonFormatKey,
          ignoreDirectoriesKey: _ignoreDirectoriesKey,
        ),
      ),
    );
  }

  /// Use file picker to pick a directory for Project or translation assets
  Future<void> _pickDirectory(BuildContext context, [bool translationAssets = false]) async {
    try {
      final theDirectoryPath = _directoryController.text;

      final directoryPath = await getDirectoryPath(
        initialDirectory: translationAssets && theDirectoryPath.isNotEmpty ? theDirectoryPath : null,
      );

      if (directoryPath != null) {
        setStateNotDisposed(() {
          if (translationAssets) {
            _translationAssetsController.text = directoryPath.replaceAll(theDirectoryPath, '');
          } else {
            _directoryController.text = directoryPath;
          }
        });
      }
    } catch (e, t) {
      debugPrint('TCH_e $e\n$t');
    }
  }

  /// Directory updated, update value used by widgets
  void _directoryUpdated() {
    if (_directoryPath != _directoryController.text) {
      _directoryPath = _directoryController.text;

      setStateNotDisposed(() {});
    }
  }
}
