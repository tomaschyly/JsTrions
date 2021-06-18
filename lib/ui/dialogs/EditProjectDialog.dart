import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:js_trions/core/AppTheme.dart';
import 'package:js_trions/model/Project.dart';
import 'package:js_trions/model/providers/ProjectProvider.dart';
import 'package:js_trions/ui/dataWidgets/ProjectProgrammingLanguagesFieldDataWidget.dart';
import 'package:js_trions/ui/widgets/ProjectLanguagesFieldWidget.dart';
import 'package:path/path.dart';
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
  final _nameFocus = FocusNode();
  final _directoryFocus = FocusNode();
  final _translationAssetsFocus = FocusNode();

  /// Manually dispose of resources
  @override
  void dispose() {
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

    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          child: ClipRRect(
            borderRadius: commonTheme.dialogsStyle.listDialogStyle.borderRadius,
            child: Container(
              width: kPhoneStopBreakpoint,
              margin: commonTheme.dialogsStyle.listDialogStyle.dialogMargin,
              decoration: BoxDecoration(
                color: commonTheme.dialogsStyle.listDialogStyle.backgroundColor,
                border: Border.all(
                  color: commonTheme.dialogsStyle.listDialogStyle.color,
                  width: 1,
                ),
                borderRadius: commonTheme.dialogsStyle.listDialogStyle.borderRadius,
              ),
              child: Scrollbar(
                child: SingleChildScrollView(
                  child: Container(
                    padding: commonTheme.dialogsStyle.listDialogStyle.dialogPadding,
                    child: Form(
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

                                        return directory.existsSync();
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

                                        return directory.existsSync();
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
                          ProjectLanguagesFieldWidget(
                            key: _languagesKey,
                            project: widget.project,
                          ),
                          CommonSpaceVHalf(),
                          ProjectProgrammingLanguagesFieldDataWidget(
                            key: _programmingLanguagesKey,
                            project: widget.project,
                          ),
                          DialogFooter(
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
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
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
}
