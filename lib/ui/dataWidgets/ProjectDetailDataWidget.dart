import 'dart:convert';
import 'dart:io';

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

  /// ProjectDetailDataWidget initialization
  ProjectDetailDataWidget({
    required this.projectId,
  }) : super(
          dataRequests: [
            GetProjectDataRequest(projectId: projectId),
            GetProgrammingLanguagesDataRequest(),
          ],
        );

  /// Create state for widget
  @override
  State<StatefulWidget> createState() => _ProjectDetailDataWidgetState();
}

class _ProjectDetailDataWidgetState extends AbstractDataWidgetState<ProjectDetailDataWidget> {
  final _topKey = GlobalKey();
  int? _projectId;
  bool _projectDirNotFound = false;
  bool _translationAssetsDirNotFound = false;
  Map<String, Map<String, String>> _translationPairsByLanguage = Map();
  String _selectedLanguage = '';
  Map<String, String> _selectedLanguagePairs = Map();

  /// Widget parameters changed
  @override
  void didUpdateWidget(covariant ProjectDetailDataWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.projectId != widget.projectId) {
      _resetForProject();
    }
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
          content = Text(
            tt('project_detail.directory_not_found').replaceAll(r'$directory', theProject.directory),
            style: fancyText(kTextDanger),
          );
        } else if (_translationAssetsDirNotFound) {
          content = Text(
            tt('project_detail.translation_assets_directory_not_found').replaceAll(r'$directory', '${theProject.directory}${theProject.translationAssets}'),
            style: fancyText(kTextDanger),
          );
        } else {
          bool rowIsOdd = false;

          content = Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_translationPairsByLanguage.isNotEmpty) ...[
                Wrap(
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
                CommonSpaceV(),
              ],
              if (_selectedLanguagePairs.isNotEmpty) ...[
                Text(
                  tt('project_detail.translations.label'),
                  style: fancyText(kTextBold),
                ),
                CommonSpaceV(),
                Table(
                  defaultColumnWidth: IntrinsicColumnWidth(),
                  children: _selectedLanguagePairs.keys.map((key) {
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
                      ],
                    );
                  }).toList(),
                ),
              ],
            ],
          );
        }

        return Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 1,
              height: 1,
              key: _topKey,
            ),
            Text(
              theProject.name,
              style: fancyText(kTextHeadline),
            ),
            CommonSpaceV(),
            content,
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
    if (project.id != _projectId) {
      _projectId = project.id;

      final directory = Directory(project.directory);

      bool exists = await directory.exists();
      //TODO can be error on MacOS because of the app sandbox

      setStateNotDisposed(() {
        _projectDirNotFound = !exists;
        _translationAssetsDirNotFound = false;
        _translationPairsByLanguage = Map();
        _selectedLanguage = '';
      });

      if (exists) {
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

  /// Select Language & init it
  void _selectLanguage(String language) {
    setStateNotDisposed(() {
      _selectedLanguage = language;
      _selectedLanguagePairs = _translationPairsByLanguage[language] ?? Map();

      //TODO calcualte info?

      WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
        Scrollable.ensureVisible(
          _topKey.currentContext!,
          alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtStart,
        );
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
