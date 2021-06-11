import 'package:js_trions/core/AppTheme.dart';
import 'package:js_trions/model/Project.dart';
import 'package:js_trions/model/providers/ProjectProvider.dart';
import 'package:js_trions/ui/dataWidgets/ProjectProgrammingLanguagesFieldDataWidget.dart';
import 'package:tch_appliable_core/tch_appliable_core.dart';
import 'package:tch_common_widgets/tch_common_widgets.dart';

class EditProjectDialog extends AbstractStatefulWidget {
  final Project? project;

  /// EditProjectDialog initialization
  EditProjectDialog({
    this.project,
  });

  /// Show the dialog as a popup
  static Future<void> show(
    BuildContext context, {
    Project? project,
  }) {
    return showDialog(
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
  final _programmingLanguagesKey = GlobalKey<ProjectProgrammingLanguagesFieldDataWidgetState>();
  final _nameFocus = FocusNode();
  final _directoryFocus = FocusNode();

  /// Manually dispose of resources
  @override
  void dispose() {
    _nameController.dispose();
    _directoryController.dispose();
    _nameFocus.dispose();
    _directoryFocus.dispose();

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
                          TextFormFieldWidget(
                            controller: _directoryController,
                            focusNode: _directoryFocus,
                            label: tt('edit_project.field.directory'),
                            validations: [
                              FormFieldValidation(
                                validator: validateRequired,
                                errorText: tt('validation.required'),
                              ),
                            ],
                          ),
                          CommonSpaceVHalf(),
                          Text('Wip: languages'), //TODO
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
}
