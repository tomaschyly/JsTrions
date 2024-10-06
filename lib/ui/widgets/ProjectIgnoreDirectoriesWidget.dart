import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:js_trions/core/AppTheme.dart';
import 'package:js_trions/model/Project.dart';
import 'package:js_trions/ui/widgets/ChipWidget.dart';
import 'package:tch_appliable_core/tch_appliable_core.dart';
import 'package:tch_common_widgets/tch_common_widgets.dart';

class ProjectIgnoreDirectoriesWidget extends AbstractStatefulWidget {
  final Project? project;
  final String projectDirectory;

  /// ProjectIgnoreDirectoriesWidget initialization
  ProjectIgnoreDirectoriesWidget({
    required Key key,
    this.project,
    required this.projectDirectory,
  }) : super(key: key);

  /// Create state for widget
  @override
  State<StatefulWidget> createState() => ProjectIgnoreDirectoriesWidgetState();
}

class ProjectIgnoreDirectoriesWidgetState extends AbstractStatefulWidgetState<ProjectIgnoreDirectoriesWidget> {
  List<String> get value => List<String>.from(_directories);

  List<String> _directories = [];
  final _formKey = GlobalKey<FormState>();
  final _directoryController = TextEditingController();

  /// State initialization
  @override
  void initState() {
    super.initState();

    final theProject = widget.project;
    if (theProject != null) {
      _directories = theProject.directories;
    }

    if (_directories.isEmpty) {
      _directories = <String>[
        '${Platform.pathSeparator}.git',
        '${Platform.pathSeparator}.idea',
        '${Platform.pathSeparator}.vscode',
      ];
    }
  }

  /// Manually dispose of resources
  @override
  void dispose() {
    _directoryController.dispose();

    super.dispose();
  }

  /// Create screen content from widgets
  @override
  Widget buildContent(BuildContext context) {
    _directories.sort((a, b) => a.compareTo(b));

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
            children: _directories
                .map((String directory) => _ChipWidget(
                      directory: directory,
                      onTap: _removeDirectory,
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
                  controller: _directoryController,
                  label: tt('edit_project.field.new_ignore_directory'),
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
                svgAssetPath: 'images/folder.svg',
                onTap: () => _pickDirectory(context),
              ),
              CommonSpaceHHalf(),
              IconButtonWidget(
                svgAssetPath: 'images/plus.svg',
                onTap: _addDirectory,
              ),
            ],
          ),
        ),
        CommonSpaceVHalf(),
        Text(
          tt('edit_project.field.ignore_directories.hint'),
          style: fancyText(kText),
        ),
      ],
    );
  }

  /// Pick a Directory to ignore
  Future<void> _pickDirectory(BuildContext context) async {
    try {
      final directoryPath = await getDirectoryPath(
        initialDirectory: widget.projectDirectory.isNotEmpty ? widget.projectDirectory : null,
      );

      if (directoryPath != null) {
        setStateNotDisposed(() {
          _directoryController.text = directoryPath.replaceAll(widget.projectDirectory, '');
        });
      }
    } catch (e, t) {
      debugPrint('TCH_e $e\n$t');
    }
  }

  /// Add new Directory to the list
  void _addDirectory() {
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      setStateNotDisposed(() {
        if (!_directories.contains(_directoryController.text)) {
          _directories.add(_directoryController.text);

          _directoryController.text = '';
        }
      });
    }
  }

  /// Remove Directory from list
  void _removeDirectory(String directory) {
    setStateNotDisposed(() {
      _directories.remove(directory);
    });
  }
}

class _ChipWidget extends StatelessWidget {
  final String directory;
  final void Function(String directory) onTap;
  final bool canTap;

  /// ChipWidget initialization
  _ChipWidget({
    required this.directory,
    required this.onTap,
    this.canTap = false,
  });

  /// Create view layout from widgets
  @override
  Widget build(BuildContext context) {
    final commonTheme = CommonTheme.of<AppTheme>(context)!;

    return ChipWidget(
      variant: ChipVariant.LeftPadded,
      text: directory,
      suffixIcon: canTap
          ? IconButtonWidget(
              style: commonTheme.buttonsStyle.iconButtonStyle.copyWith(
                variant: IconButtonVariant.IconOnly,
                color: kColorDanger,
              ),
              svgAssetPath: 'images/times.svg',
              onTap: () => onTap(directory),
            )
          : Container(),
    );
  }
}
