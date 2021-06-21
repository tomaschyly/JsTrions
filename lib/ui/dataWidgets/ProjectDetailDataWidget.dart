import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:js_trions/core/AppTheme.dart';
import 'package:js_trions/model/ProgrammingLanguage.dart';
import 'package:js_trions/model/Project.dart';
import 'package:js_trions/model/dataRequests/GetProgrammingLanguagesDataRequest.dart';
import 'package:js_trions/model/dataRequests/GetProjectDataRequest.dart';
import 'package:js_trions/model/providers/ProjectProvider.dart';
import 'package:js_trions/ui/widgets/ChipWidget.dart';
import 'package:path/path.dart';
import 'package:tch_appliable_core/tch_appliable_core.dart';
import 'package:tch_common_widgets/tch_common_widgets.dart';

class ProjectDetailDataWidget extends AbstractDataWidget {
  final int projectId;
  final ValueChanged<Project?>? onProjectChanged;

  /// ProjectDetailDataWidget initialization
  ProjectDetailDataWidget({
    Key? key,
    required this.projectId,
    this.onProjectChanged,
  }) : super(
          key: key,
          dataRequests: [
            GetProjectDataRequest(projectId: projectId),
            GetProgrammingLanguagesDataRequest(),
          ],
        );

  /// Create state for widget
  @override
  State<StatefulWidget> createState() => ProjectDetailDataWidgetState();
}

class ProjectDetailDataWidgetState extends AbstractDataWidgetState<ProjectDetailDataWidget> {
  Project? get project => _project;

  final _topKey = GlobalKey();
  int? _projectId;
  Project? _project;
  bool _projectDirNotFound = false;
  bool _projectDirMacOSRequestAccess = false;
  bool _translationAssetsDirNotFound = false;
  Map<String, Map<String, String>> _translationPairsByLanguage = Map();
  String _selectedLanguage = '';
  Map<String, String> _selectedLanguagePairs = Map();
  final _searchController = TextEditingController();
  Timer? _searchTimer;
  String _searchQuery = '';

  /// Manually dispose of resources
  @override
  void dispose() {
    _searchController.dispose();

    _searchTimer?.cancel();
    _searchTimer = null;

    super.dispose();
  }

  /// Widget parameters changed
  @override
  void didUpdateWidget(covariant ProjectDetailDataWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.projectId != widget.projectId) {
      _resetForProject();
    }
  }

  /// Run initializations of screen on first build only
  @override
  firstBuildOnly(BuildContext context) {
    super.firstBuildOnly(context);

    _searchController.addListener(_searchTranslations);
  }

  /// Create screen content from widgets
  @override
  Widget buildContent(BuildContext context) {
    final commonTheme = CommonTheme.of<AppTheme>(context)!;

    return ValueListenableBuilder(
      valueListenable: dataSource!.results,
      builder: (BuildContext context, List<DataRequest> dataRequests, Widget? child) {
        final projectDataRequest = dataRequests.first as GetProjectDataRequest;
        final programmingLanguagesDataRequest = dataRequests[1] as GetProgrammingLanguagesDataRequest;

        final theProject = projectDataRequest.result;
        final programmingLanguages = programmingLanguagesDataRequest.result;

        if (theProject == null || programmingLanguages == null) {
          return Container();
        }

        _initProject(theProject, programmingLanguages.programmingLanguages);

        Widget content;

        if (_projectDirNotFound) {
          content = Padding(
            padding: const EdgeInsets.symmetric(horizontal: kCommonHorizontalMargin),
            child: Text(
              tt('project_detail.directory_not_found').replaceAll(r'$directory', theProject.directory),
              style: fancyText(kTextDanger),
            ),
          );
        } else if (_projectDirMacOSRequestAccess) {
          content = Container(
            padding: const EdgeInsets.symmetric(horizontal: kCommonHorizontalMargin),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tt('project_detail.macos_request_access.description'),
                  style: fancyText(kTextDanger),
                ),
                CommonSpaceV(),
                ButtonWidget(
                  style: commonTheme.buttonsStyle.buttonStyle.copyWith(
                    variant: ButtonVariant.Filled,
                    widthWrapContent: true,
                  ),
                  text: tt('project_detail.macos_request_access'),
                  onTap: () => _confirmFilesAccess(theProject),
                ),
              ],
            ),
          );
        } else if (_translationAssetsDirNotFound) {
          content = Padding(
            padding: const EdgeInsets.symmetric(horizontal: kCommonHorizontalMargin),
            child: Text(
              tt('project_detail.translation_assets_directory_not_found').replaceAll(r'$directory', '${theProject.directory}${theProject.translationAssets}'),
              style: fancyText(kTextDanger),
            ),
          );
        } else {
          bool rowIsOdd = false;

          content = Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_translationPairsByLanguage.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: kCommonHorizontalMargin),
                  child: Wrap(
                    spacing: kCommonHorizontalMarginHalf,
                    runSpacing: kCommonVerticalMarginHalf,
                    children: _translationPairsByLanguage.keys
                        .map((language) => _LanguageChipWidget(
                              language: language,
                              selected: _selectedLanguage == language,
                              selectLanguage: _selectLanguage,
                            ))
                        .toList(),
                  ),
                ),
                CommonSpaceV(),
              ],
              if (_selectedLanguagePairs.isNotEmpty) ...[
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    CommonSpaceH(),
                    Expanded(
                      child: TextFormFieldWidget(
                        style: commonTheme.formStyle.textFormFieldStyle.copyWith(
                          fullWidthMobileOnly: false,
                        ),
                        controller: _searchController,
                        label: tt('project_detail.field.search'),
                      ),
                    ),
                    CommonSpaceH(),
                  ],
                ),
                CommonSpaceV(),
                Text(
                  tt('project_detail.translations.label'),
                  style: fancyText(kTextHeadline),
                ),
                CommonSpaceV(),
                Expanded(
                  child: Scrollbar(
                    child: SingleChildScrollView(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: kCommonHorizontalMargin),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 1,
                              height: 1,
                              key: _topKey,
                            ),
                            Table(
                              // defaultColumnWidth: IntrinsicColumnWidth(),
                              columnWidths: <int, TableColumnWidth>{
                                0: IntrinsicColumnWidth(),
                                1: FixedColumnWidth(kCommonHorizontalMargin),
                                2: FlexColumnWidth(),
                                3: FixedColumnWidth(kCommonHorizontalMargin + kButtonHeight),
                              },
                              children: _selectedLanguagePairs.keys.where((key) => key.toLowerCase().contains(_searchQuery)).map((key) {
                                rowIsOdd = !rowIsOdd;

                                return TableRow(
                                  decoration: BoxDecoration(
                                    color: rowIsOdd ? kColorPrimary : null,
                                    borderRadius: commonTheme.buttonsStyle.buttonStyle.borderRadius,
                                  ),
                                  children: [
                                    TableCell(
                                      child: Container(
                                        constraints: BoxConstraints(minHeight: kButtonHeight),
                                        alignment: Alignment.topLeft,
                                        padding: const EdgeInsets.all(kCommonPrimaryMarginHalf),
                                        child: Text(
                                          key,
                                          style: fancyText(kText),
                                        ),
                                      ),
                                    ),
                                    CommonSpaceH(),
                                    TableCell(
                                      child: Container(
                                        constraints: BoxConstraints(minHeight: kButtonHeight),
                                        alignment: Alignment.topLeft,
                                        padding: const EdgeInsets.all(kCommonPrimaryMarginHalf),
                                        child: Text(
                                          _selectedLanguagePairs[key]!,
                                          style: fancyText(kText),
                                        ),
                                      ),
                                    ),
                                    TableCell(
                                      verticalAlignment: TableCellVerticalAlignment.fill,
                                      child: Container(
                                        color: kColorPrimaryLight,
                                        alignment: Alignment.centerRight,
                                        child: IconButtonWidget(
                                          svgAssetPath: 'images/edit.svg',
                                          // onTap: () => _pickDirectory(context, true),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          );
        }

        return Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              theProject.name,
              style: fancyText(kTextHeadline),
            ),
            CommonSpaceV(),
            Expanded(
              child: content,
            ),
          ],
        );
      },
    );
  }

  /// New projectId provided, reset and load new Project
  void _resetForProject() {
    updateDataRequests([
      GetProjectDataRequest(projectId: widget.projectId),
      GetProgrammingLanguagesDataRequest(),
    ]);
  }

  /// Check if Projects exists, init translations from Project based on parameters
  Future<void> _initProject(Project project, List<ProgrammingLanguage> programmingLanguages) async {
    if ((project.id != _projectId) || (_project != null && _project!.updated != project.updated)) {
      _projectId = project.id;
      _project = project;

      WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
        widget.onProjectChanged?.call(_project);
      });

      final directory = Directory(project.directory);

      bool exists = await directory.exists();
      bool macOsFileAccess = true;

      if (!kIsWeb && Platform.isMacOS) {
        try {
          await for (var _ in directory.list()) {}

          macOsFileAccess = true;
        } catch (e, t) {
          debugPrint('TCH_e $e\n$t');

          macOsFileAccess = false;
        }
      }

      setStateNotDisposed(() {
        _projectDirNotFound = !exists;
        _projectDirMacOSRequestAccess = !macOsFileAccess;
        _translationAssetsDirNotFound = false;
        _translationPairsByLanguage = Map();
        _selectedLanguage = '';
      });

      if (exists && macOsFileAccess) {
        final translationsAssetsDirectory = Directory('${project.directory}${project.translationAssets}');

        exists = await translationsAssetsDirectory.exists();

        setStateNotDisposed(() {
          _translationAssetsDirNotFound = !exists;
        });

        if (exists) {
          final Map<String, Map<String, String>> translationPairsByLanguage = Map();

          for (String language in project.languages) {
            final file = File(join(translationsAssetsDirectory.path, '$language.json'));

            if (!(await file.exists())) {
              await file.writeAsString('{}');
            }

            final json = jsonDecode(await file.readAsString());

            translationPairsByLanguage[language] = Map<String, String>.from(json);
          }

          setStateNotDisposed(() {
            _translationPairsByLanguage = translationPairsByLanguage;

            WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
              _selectLanguage(_translationPairsByLanguage.keys.first);
            });
          });
        }
      }

      updateLastSeenOfProject(project);
    }
  }

  /// Confirm access to Project files by picking the directory
  Future<void> _confirmFilesAccess(Project project) async {
    try {
      final directoryPath = await getDirectoryPath(
        initialDirectory: project.directory,
        confirmButtonText: tt('project_detail.macos_request_access'),
      );

      if (directoryPath == project.directory) {
        setStateNotDisposed(() {
          _projectId = null;
        });
      }
    } catch (e, t) {
      debugPrint('TCH_e $e\n$t');
    }
  }

  /// Select Language & init it
  void _selectLanguage(String language) {
    setStateNotDisposed(() {
      _selectedLanguage = language;
      _selectedLanguagePairs = _translationPairsByLanguage[language] ?? Map();

      //TODO calcualte info?

      WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
        final theContext = _topKey.currentContext;

        if (theContext != null) {
          Scrollable.ensureVisible(
            theContext,
            alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtStart,
          );
        }
      });
    });
  }

  /// Filter visible translations by query
  void _searchTranslations() {
    _searchTimer?.cancel();

    _searchTimer = Timer(Duration(milliseconds: 300), () {
      setStateNotDisposed(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }
}

class _LanguageChipWidget extends StatelessWidget {
  final String language;
  final bool selected;
  final void Function(String language) selectLanguage;

  /// LanguageChipWidget initialization
  _LanguageChipWidget({
    required this.language,
    this.selected = false,
    required this.selectLanguage,
  });

  /// Create view layout from widgets
  @override
  Widget build(BuildContext context) {
    final commonTheme = CommonTheme.of<AppTheme>(context)!;

    return ChipWidget(
      text: language,
      suffixIcon: SvgPicture.asset(
        selected ? 'images/circle-full.svg' : 'images/circle-empty.svg',
        width: commonTheme.buttonsStyle.iconButtonStyle.iconWidth,
        height: commonTheme.buttonsStyle.iconButtonStyle.iconHeight,
        color: commonTheme.buttonsStyle.iconButtonStyle.color,
      ),
      onTap: selected ? null : () => selectLanguage(language),
    );
  }
}
