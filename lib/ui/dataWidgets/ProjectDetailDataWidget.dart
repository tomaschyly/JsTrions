import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:js_trions/core/AppPreferences.dart';
import 'package:js_trions/core/AppTheme.dart';
import 'package:js_trions/model/ProgrammingLanguage.dart';
import 'package:js_trions/model/Project.dart';
import 'package:js_trions/model/dataRequests/GetProgrammingLanguagesDataRequest.dart';
import 'package:js_trions/model/dataRequests/GetProjectDataRequest.dart';
import 'package:js_trions/model/providers/ProjectProvider.dart';
import 'package:js_trions/ui/dialogs/EditProjectTranslationDialog.dart';
import 'package:js_trions/ui/widgets/ChipWidget.dart';
import 'package:js_trions/ui/widgets/ToggleContainerWidget.dart';
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

class ProjectDetailDataWidgetState extends AbstractDataWidgetState<ProjectDetailDataWidget> with TickerProviderStateMixin {
  Project? get project => _project;

  final _topKey = GlobalKey();
  ProjectAnalysisOnInit _analysisOnInit = ProjectAnalysisOnInit.Never;
  int? _projectId;
  Project? _project;
  bool _projectDirNotFound = false;
  bool _projectDirMacOSRequestAccess = false;
  bool _translationAssetsDirNotFound = false;
  Map<String, SplayTreeMap<String, String>> _translationPairsByLanguage = Map();
  Map<String, SplayTreeMap<String, String>> _codePairsByLanguage = Map();
  String _selectedLanguage = '';
  SplayTreeMap<String, String> _selectedLanguagePairs = SplayTreeMap();
  final _searchController = TextEditingController();
  Timer? _searchTimer;
  String _searchQuery = '';
  GlobalKey? _newTranslationKey;
  String? _newTranslation;
  SourceOfTranslations _sourceOfTranslations = SourceOfTranslations.All;
  bool _isAnalyzing = false;
  bool _displayOnlyCodeOnlyKeys = false;
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<bool> _showScrollTop = ValueNotifier(false);
  final List<_InfoWidget> _infoList = [];

  /// Manually dispose of resources
  @override
  void dispose() {
    _searchController.dispose();

    _searchTimer?.cancel();
    _searchTimer = null;

    _scrollController.dispose();

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

    _analysisOnInit = ProjectAnalysisOnInit.values[prefsInt(PREFS_PROJECTS_ANALYSIS)!];
    _sourceOfTranslations = SourceOfTranslations.values[prefsInt(PREFS_PROJECTS_SOURCE)!];

    _scrollController.addListener(_shouldShowScrollTop);
  }

  /// Create screen content from widgets
  @override
  Widget buildContent(BuildContext context) {
    final snapshot = AppDataState.of(context)!;
    final commonTheme = CommonTheme.of<AppTheme>(context)!;

    final isDesktop = [
      ResponsiveScreen.SmallDesktop,
      ResponsiveScreen.LargeDesktop,
      ResponsiveScreen.ExtraLargeDesktop,
    ].contains(snapshot.responsiveScreen);

    return Stack(
      children: [
        ValueListenableBuilder(
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
                  tt('project_detail.translation_assets_directory_not_found')
                      .replaceAll(r'$directory', '${theProject.directory}${theProject.translationAssets}'),
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
                    Expanded(
                      child: Scrollbar(
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 1,
                                height: 1,
                                key: _topKey,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: kCommonHorizontalMargin),
                                child: ToggleContainerWidget(
                                  title: tt('project_detail.actions.title'),
                                  content: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: kCommonHorizontalMarginHalf),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          tt('project_detail.actions.source.title'),
                                          style: fancyText(kTextBold),
                                        ),
                                        CommonSpaceVHalf(),
                                        Wrap(
                                          spacing: kCommonHorizontalMarginHalf,
                                          runSpacing: kCommonVerticalMarginHalf,
                                          children: [
                                            _SourceOfTranslationsChipWidget(
                                              source: SourceOfTranslations.All,
                                              selected: _sourceOfTranslations == SourceOfTranslations.All,
                                              selectSource: _selectSource,
                                            ),
                                            _SourceOfTranslationsChipWidget(
                                              source: SourceOfTranslations.Assets,
                                              selected: _sourceOfTranslations == SourceOfTranslations.Assets,
                                              selectSource: _selectSource,
                                            ),
                                            _SourceOfTranslationsChipWidget(
                                              source: SourceOfTranslations.Code,
                                              selected: _sourceOfTranslations == SourceOfTranslations.Code,
                                              selectSource: _selectSource,
                                            ),
                                          ],
                                        ),
                                        CommonSpaceV(),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              tt('project_detail.actions.code_only_keys'),
                                              style: fancyText(kTextBold),
                                            ),
                                            CommonSpaceH(),
                                            Switch(
                                              value: _displayOnlyCodeOnlyKeys,
                                              onChanged: (bool newValue) {
                                                setStateNotDisposed(() {
                                                  _displayOnlyCodeOnlyKeys = newValue;
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                        CommonSpaceVHalf(),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              CommonSpaceV(),
                              AnimatedSize(
                                duration: kThemeAnimationDuration,
                                vsync: this,
                                alignment: Alignment.topCenter,
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(horizontal: kCommonHorizontalMargin),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: _infoList,
                                  ),
                                ),
                              ),
                              Text(
                                tt('project_detail.translations.label'),
                                style: fancyText(kTextHeadline),
                              ),
                              CommonSpaceV(),
                              AnimatedSize(
                                duration: kThemeAnimationDuration,
                                vsync: this,
                                alignment: Alignment.topCenter,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        if (_sourceOfTranslations != SourceOfTranslations.Code)
                                          ButtonWidget(
                                            style: commonTheme.buttonsStyle.buttonStyle.copyWith(
                                              widthWrapContent: true,
                                            ),
                                            text: tt('project_detail.add_translation'),
                                            prefixIconSvgAssetPath: 'images/plus.svg',
                                            onTap: () => _processTranslationsForKey(context, theProject),
                                          ),
                                        if (_sourceOfTranslations == SourceOfTranslations.All) CommonSpaceH(),
                                        if (_sourceOfTranslations != SourceOfTranslations.Assets)
                                          ButtonWidget(
                                            style: commonTheme.buttonsStyle.buttonStyle.copyWith(
                                              widthWrapContent: true,
                                            ),
                                            text: tt('project_detail.analyze_code'),
                                            prefixIconSvgAssetPath: 'images/code.svg',
                                            onTap: () => _processProjectCode(theProject, programmingLanguages.programmingLanguages),
                                            isLoading: _isAnalyzing,
                                          ),
                                        CommonSpaceH(),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              CommonSpaceV(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: kCommonHorizontalMargin),
                                child: Table(
                                  // defaultColumnWidth: IntrinsicColumnWidth(),
                                  columnWidths: <int, TableColumnWidth>{
                                    0: IntrinsicColumnWidth(),
                                    1: FixedColumnWidth(kCommonHorizontalMargin),
                                    2: FlexColumnWidth(),
                                    3: FixedColumnWidth(kButtonHeight),
                                    4: FixedColumnWidth(kCommonHorizontalMargin + kButtonHeight),
                                  },
                                  children: [
                                    TableRow(
                                      decoration: BoxDecoration(
                                        color: kColorSecondaryDark,
                                        borderRadius: commonTheme.buttonsStyle.buttonStyle.borderRadius,
                                      ),
                                      children: [
                                        TableCell(
                                          child: Container(
                                            constraints: BoxConstraints(minHeight: kButtonHeight),
                                            alignment: Alignment.topLeft,
                                            padding: const EdgeInsets.all(kCommonPrimaryMarginHalf),
                                            child: Text(
                                              tt('project_detail.table.key'),
                                              style: fancyText(kTextBold),
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
                                              tt('project_detail.table.translation'),
                                              style: fancyText(kTextBold),
                                            ),
                                          ),
                                        ),
                                        TableCell(
                                          verticalAlignment: TableCellVerticalAlignment.fill,
                                          child: Container(),
                                        ),
                                        TableCell(
                                          verticalAlignment: TableCellVerticalAlignment.fill,
                                          child: Container(),
                                        ),
                                      ],
                                    ),
                                    ..._selectedLanguagePairs.keys
                                        .where((key) =>
                                            (key.toLowerCase().contains(_searchQuery) || _selectedLanguagePairs[key]!.toLowerCase().contains(_searchQuery)) &&
                                            (!_displayOnlyCodeOnlyKeys ||
                                                _sourceOfTranslations == SourceOfTranslations.Assets ||
                                                _translationPairsByLanguage[_selectedLanguage]?[key] == null))
                                        .map((key) {
                                      rowIsOdd = !rowIsOdd;

                                      final isCodeOnly = _translationPairsByLanguage[_selectedLanguage]?[key] == null;

                                      Color? rowColor = rowIsOdd ? kColorPrimary : null;
                                      if (isCodeOnly) {
                                        rowColor = rowIsOdd ? kColorWarning : kColorWarningDark;
                                      }

                                      return TableRow(
                                        decoration: BoxDecoration(
                                          color: rowColor,
                                          borderRadius: commonTheme.buttonsStyle.buttonStyle.borderRadius,
                                        ),
                                        children: [
                                          TableCell(
                                            child: Container(
                                              key: key == _newTranslation ? _newTranslationKey : null,
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
                                              alignment: Alignment.center,
                                              child: IconButtonWidget(
                                                style: commonTheme.buttonsStyle.iconButtonStyle.copyWith(
                                                  variant: IconButtonVariant.IconOnly,
                                                ),
                                                svgAssetPath: isCodeOnly ? 'images/plus.svg' : 'images/edit.svg',
                                                onTap: () => _processTranslationsForKey(context, theProject, key),
                                              ),
                                            ),
                                          ),
                                          TableCell(
                                            verticalAlignment: TableCellVerticalAlignment.fill,
                                            child: Container(
                                              alignment: Alignment.center,
                                              child: isCodeOnly
                                                  ? null
                                                  : IconButtonWidget(
                                                      style: commonTheme.buttonsStyle.iconButtonStyle.copyWith(
                                                        variant: IconButtonVariant.IconOnly,
                                                        iconColor: kColorDanger,
                                                      ),
                                                      svgAssetPath: 'images/trash.svg',
                                                      onTap: () => _deleteTranslationsForKey(context, theProject, key),
                                                    ),
                                            ),
                                          ),
                                        ],
                                      );
                                    }).toList(),
                                  ],
                                ),
                              ),
                              Container(
                                height: kButtonHeight + (!isDesktop ? (2 * kCommonVerticalMargin) : kCommonVerticalMargin),
                              ),
                            ],
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
        ),
        ValueListenableBuilder(
          valueListenable: _showScrollTop,
          builder: (BuildContext context, bool value, Widget? child) {
            return Positioned(
              right: 0,
              bottom: !isDesktop ? kCommonVerticalMargin : 0,
              child: AnimatedOpacity(
                opacity: value ? 1 : 0,
                duration: kThemeAnimationDuration,
                child: IgnorePointer(
                  ignoring: !value,
                  child: IconButtonWidget(
                    style: commonTheme.buttonsStyle.iconButtonStyle.copyWith(
                      variant: IconButtonVariant.Filled,
                      iconColor: kColorPrimaryLight,
                    ),
                    svgAssetPath: 'images/arrow-up.svg',
                    onTap: () {
                      final theContext = _topKey.currentContext;

                      if (theContext != null) {
                        Scrollable.ensureVisible(
                          theContext,
                          alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtStart,
                          duration: kThemeAnimationDuration,
                        );
                      }
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  /// New projectId provided, reset and load new Project
  void _resetForProject() {
    setStateNotDisposed(() {
      _selectedLanguage = '';
      _selectedLanguagePairs = SplayTreeMap();
      _codePairsByLanguage = Map();
      _infoList.clear();
    });

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
      });

      if (exists && macOsFileAccess) {
        final translationsAssetsDirectory = Directory('${project.directory}${project.translationAssets}');

        exists = await translationsAssetsDirectory.exists();

        setStateNotDisposed(() {
          _translationAssetsDirNotFound = !exists;
        });

        if (exists) {
          final Map<String, SplayTreeMap<String, String>> translationPairsByLanguage = Map();

          for (String language in project.languages) {
            final file = File(join(translationsAssetsDirectory.path, '$language.json'));

            if (!(await file.exists())) {
              await file.writeAsString('{}');
            }

            final json = jsonDecode(await file.readAsString());

            translationPairsByLanguage[language] = SplayTreeMap<String, String>.from(json);
          }

          setStateNotDisposed(() {
            _translationPairsByLanguage = translationPairsByLanguage;

            WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
              _selectLanguage(_translationPairsByLanguage.keys.first);

              if (_analysisOnInit == ProjectAnalysisOnInit.Always) {
                _processProjectCode(project, programmingLanguages);
              } else if (_analysisOnInit == ProjectAnalysisOnInit.CodeVisibleOnly &&
                  (_sourceOfTranslations == SourceOfTranslations.Code || _sourceOfTranslations == SourceOfTranslations.All)) {
                _processProjectCode(project, programmingLanguages);
              } else {
                _analyzeTranslations();
              }
            });
          });
        }
      }

      updateLastSeenOfProject(project);
    }
  }

  /// Analyze translations for equality, if some has missing translations notify
  void _analyzeTranslations() {
    final countByLanguage = Map<String, int>();
    final keysByLanguage = Map<String, List<String>>();

    for (String language in _translationPairsByLanguage.keys) {
      final pairsForLanguage = _translationPairsByLanguage[language]!;

      countByLanguage[language] = pairsForLanguage.keys.length;
      keysByLanguage[language] = pairsForLanguage.keys.toList()..sort();
    }

    final List<_InfoWidget> infoList = [];
    bool languagesNotEqualCount = false;

    String languageTopCount = '';
    String? languageLowerCount;
    int topCount = -1;
    int lowerCount = 0;

    for (String language in countByLanguage.keys) {
      final count = countByLanguage[language]!;

      if (topCount == -1) {
        languageTopCount = language;
        topCount = count;
      } else if (count > topCount) {
        languageTopCount = language;
        topCount = count;
      }
    }

    for (String language in countByLanguage.keys) {
      final count = countByLanguage[language]!;

      if (count < topCount) {
        languageLowerCount = language;
        lowerCount = count;
        languagesNotEqualCount = true;
        break;
      }
    }

    if (languagesNotEqualCount) {
      infoList.add(
        _InfoWidget(
          text: tt('project_detail.info.languages_not_equal_count')
              .replaceFirst(r'$topLanguage', languageTopCount)
              .replaceFirst(r'$topLanguageCount', topCount.toString())
              .replaceFirst(r'$lowerLanguage', languageLowerCount!)
              .replaceFirst(r'$lowerLanguageCount', lowerCount.toString()),
          clearInfo: _clearInfo,
        ),
      );
    }

    if (!languagesNotEqualCount) {
      bool languagesNotEqualKeys = false;

      for (String language in keysByLanguage.keys) {
        final keys = keysByLanguage[language]!;

        for (String otherLanguage in keysByLanguage.keys) {
          if (otherLanguage != language) {
            final otherKeys = keysByLanguage[otherLanguage]!;

            languagesNotEqualKeys = listEquals(keys, otherKeys);

            if (!languagesNotEqualKeys) {
              infoList.add(
                _InfoWidget(
                  text: tt('project_detail.info.languages_not_equal_keys').replaceFirst(r'$language', language).replaceFirst(r'$otherLanguage', otherLanguage),
                  clearInfo: _clearInfo,
                ),
              );
              break;
            }
          }
        }

        if (!languagesNotEqualKeys) {
          break;
        }
      }
    }

    if (_codePairsByLanguage.isNotEmpty) {
      final keysInAssets = keysByLanguage[languageTopCount]!;

      for (String key in _codePairsByLanguage[languageTopCount]!.keys) {
        if (!keysInAssets.contains(key)) {
          final showCodeOnly = prefsInt(PREFS_PROJECTS_CODE_ONLY) == 1;

          if (showCodeOnly) {
            setStateNotDisposed(() {
              _displayOnlyCodeOnlyKeys = true;
            });
          }

          infoList.add(
            _InfoWidget(
              text: tt('project_detail.info.code_key_not_translated'),
              clearInfo: _clearInfo,
            ),
          );
          break;
        }
      }
    }

    if (infoList.isEmpty) {
      infoList.add(
        _InfoWidget(
          text: tt('project_detail.info.success'),
          isSuccess: true,
          clearInfo: _clearInfo,
        ),
      );
    }

    setStateNotDisposed(() {
      _infoList.clear();

      _infoList.addAll(infoList);
    });
  }

  /// Clear chosen info from list
  void _clearInfo(_InfoWidget info) {
    setStateNotDisposed(() {
      _infoList.remove(info);
    });
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

      _selectedLanguagePairs = SplayTreeMap();

      switch (_sourceOfTranslations) {
        case SourceOfTranslations.Assets:
          _selectedLanguagePairs = _translationPairsByLanguage[language] ?? SplayTreeMap();
          break;
        case SourceOfTranslations.Code:
          _selectedLanguagePairs = _codePairsByLanguage[language] ?? SplayTreeMap();
          break;
        case SourceOfTranslations.All:
          _selectedLanguagePairs = _codePairsByLanguage[language] ?? SplayTreeMap();

          _selectedLanguagePairs.addAll(_translationPairsByLanguage[language] ?? SplayTreeMap());
          break;
      }

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

  /// Select SourceOfTranslations & update table
  void _selectSource(SourceOfTranslations source) {
    setStateNotDisposed(() {
      _sourceOfTranslations = source;

      WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
        _selectLanguage(_selectedLanguage);
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

  /// Add/Edit translations for key and save to Project assets
  Future<void> _processTranslationsForKey(BuildContext context, Project project, [String? key]) async {
    final isNew = key == null;
    final List<String> languages = [];
    final List<String> translations = [];

    for (String language in project.languages) {
      languages.add(language);

      final pairs = _translationPairsByLanguage[language]!;

      translations.add(pairs[key] ?? '');
    }

    final translation = await EditProjectTranslationDialog.show(
      context,
      project: project,
      translation: Translation(
        key: key,
        languages: languages,
        translations: translations,
      ),
    );

    if (translation != null) {
      for (int i = 0; i < translation.languages.length; i++) {
        final language = translation.languages[i];

        final pairs = _translationPairsByLanguage[language]!;

        pairs[translation.key!] = translation.translations[i];

        final codePairs = _codePairsByLanguage[language];
        if (codePairs != null) {
          codePairs[translation.key!] = translation.translations[i];
        }
      }

      setStateNotDisposed(() {
        if (isNew) {
          _newTranslationKey = GlobalKey();
          _newTranslation = translation.key;

          WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
            final theContext = _newTranslationKey?.currentContext;

            if (theContext != null) {
              Scrollable.ensureVisible(
                theContext,
                duration: kThemeAnimationDuration,
              );
            }
          });
        }
      });

      await _saveTranslationsToAssets(context, project);
    }
  }

  /// If users confirms, delete translations for key and save to Project assets
  Future<void> _deleteTranslationsForKey(BuildContext context, Project project, String key) async {
    final confirmed = await ConfirmDialog.show(
      context,
      isDanger: true,
      title: tt('dialog.confirm.title'),
      noText: tt('dialog.no'),
      yesText: tt('dialog.yes'),
    );

    if (confirmed == true) {
      for (String language in project.languages) {
        final pairs = _translationPairsByLanguage[language]!;

        pairs.remove(key);
      }

      setStateNotDisposed(() {});

      await _saveTranslationsToAssets(context, project);
    }
  }

  /// Save translations for all languages to Project translations assets directory
  Future<void> _saveTranslationsToAssets(BuildContext context, Project project) async {
    final translationsAssetsDirectory = Directory('${project.directory}${project.translationAssets}');

    final encoder = prefsInt(PREFS_PROJECTS_BEAUTIFY_JSON) == 1 ? JsonEncoder.withIndent('  ') : JsonEncoder();

    for (String language in project.languages) {
      final file = File(join(translationsAssetsDirectory.path, '$language.json'));

      final pairs = _translationPairsByLanguage[language]!;

      await file.writeAsString(encoder.convert(pairs));
    }
  }

  /// Go through whole Project code depending on Programming Languages and find keys usage, pair with existing translations
  Future<void> _processProjectCode(Project project, List<ProgrammingLanguage> programmingLanguages) async {
    final projectId = widget.projectId;
    final start = DateTime.now();

    setStateNotDisposed(() {
      _isAnalyzing = true;
    });

    Map<String, SplayTreeMap<String, String>> translationPairsByLanguage = Map<String, SplayTreeMap<String, String>>.from(_translationPairsByLanguage);
    Map<String, SplayTreeMap<String, String>> codePairsByLanguage = Map();

    final Map<String, ProgrammingLanguage> acceptedExtensions = Map();

    for (ProgrammingLanguage programmingLanguage in programmingLanguages) {
      if (project.programmingLanguages.contains(programmingLanguage.id)) {
        acceptedExtensions['.${programmingLanguage.extension}'] = programmingLanguage;
      }
    }

    final List<String> foundKeys = [];

    final directory = Directory(project.directory);

    await for (var file in directory.list(recursive: true, followLinks: false)) {
      if (file is File) {
        final fileExtension = extension(file.path);

        final programmingLanguageForExtension = acceptedExtensions[fileExtension];

        if (programmingLanguageForExtension != null) {
          final regExp =
              RegExp(project.translationKeys.firstWhere((translationKey) => translationKey.programmingLanguage == programmingLanguageForExtension.id).key);

          final fileContents = await file.readAsString();

          regExp.allMatches(fileContents).forEach((match) {
            for (int i = 0; i < match.groupCount; i++) {
              foundKeys.add(match.group(i)!);
            }
          });
        }
      }
    }

    for (String language in project.languages) {
      final pairs = translationPairsByLanguage[language]!;
      final codePairs = SplayTreeMap<String, String>();

      for (String key in foundKeys) {
        codePairs[key] = pairs[key] ?? '';
      }

      codePairsByLanguage[language] = codePairs;
    }

    if (projectId != widget.projectId) {
      return;
    }

    final diff = DateTime.now().difference(start);
    final minAnalysisAnimationDuration = 800;

    setStateNotDisposed(() {
      _codePairsByLanguage = codePairsByLanguage;
      if (diff.inMilliseconds >= minAnalysisAnimationDuration) {
        _isAnalyzing = false;
      }

      WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
        _selectLanguage(_selectedLanguage);

        _analyzeTranslations();
      });
    });

    if (diff.inMilliseconds < minAnalysisAnimationDuration) {
      Future.delayed(Duration(milliseconds: minAnalysisAnimationDuration - diff.inMilliseconds), () {
        setStateNotDisposed(() {
          _isAnalyzing = false;
        });
      });
    }
  }

  /// Toggle scrollTop visibility based on scrolled position.
  void _shouldShowScrollTop() {
    if (_scrollController.position.pixels > kCommonVerticalMargin && !_showScrollTop.value) {
      _showScrollTop.value = true;
    } else if (_scrollController.position.pixels <= kCommonVerticalMargin && _showScrollTop.value) {
      _showScrollTop.value = false;
    }
  }
}

enum ProjectAnalysisOnInit {
  Always,
  Never,
  CodeVisibleOnly,
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

enum SourceOfTranslations {
  Assets,
  Code,
  All,
}

class _SourceOfTranslationsChipWidget extends StatelessWidget {
  final SourceOfTranslations source;
  final bool selected;
  final void Function(SourceOfTranslations source) selectSource;

  /// SourceOfTranslationsChipWidget initialization
  _SourceOfTranslationsChipWidget({
    required this.source,
    this.selected = false,
    required this.selectSource,
  });

  /// Create view layout from widgets
  @override
  Widget build(BuildContext context) {
    final commonTheme = CommonTheme.of<AppTheme>(context)!;

    String text = '';

    switch (source) {
      case SourceOfTranslations.All:
        text = tt('project_detail.actions.source.all');
        break;
      case SourceOfTranslations.Assets:
        text = tt('project_detail.actions.source.assets');
        break;
      case SourceOfTranslations.Code:
        text = tt('project_detail.actions.source.code');
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
      onTap: selected ? null : () => selectSource(source),
    );
  }
}

class _InfoWidget extends StatelessWidget {
  final String text;
  final bool isSuccess;
  final bool isDanger;
  final void Function(_InfoWidget info) clearInfo;

  /// InfoWidget initialization
  _InfoWidget({
    required this.text,
    this.isSuccess = false,
    this.isDanger = false,
    required this.clearInfo,
  });

  /// Create view layout from widgets
  @override
  Widget build(BuildContext context) {
    final commonTheme = CommonTheme.of<AppTheme>(context)!;

    TextStyle textStyle = kTextWarning;

    if (isSuccess) {
      textStyle = kTextSuccess;
    }

    if (isDanger) {
      textStyle = kTextDanger;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                text,
                style: fancyText(textStyle),
              ),
            ),
            CommonSpaceHHalf(),
            IconButtonWidget(
              style: commonTheme.buttonsStyle.iconButtonStyle.copyWith(
                variant: IconButtonVariant.IconOnly,
                color: kColorDanger,
              ),
              svgAssetPath: 'images/times.svg',
              onTap: () => clearInfo(this),
            ),
          ],
        ),
        CommonSpaceV(),
      ],
    );
  }
}
