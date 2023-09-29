import 'dart:async';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:js_trions/core/AppTheme.dart';
import 'package:js_trions/model/Project.dart';
import 'package:js_trions/model/ProjectQuery.dart';
import 'package:js_trions/model/dataRequests/GetProjectsDataRequest.dart';
import 'package:js_trions/model/dataTasks/GetProjectDataTask.dart';
import 'package:js_trions/model/providers/ProjectProvider.dart';
import 'package:js_trions/ui/dataWidgets/ProjectDetailDataWidget.dart';
import 'package:js_trions/ui/dialogs/EditProjectDialog.dart';
import 'package:js_trions/ui/screenStates/AppResponsiveScreenState.dart';
import 'package:js_trions/ui/screens/ProjectDetailScreen.dart';
import 'package:supercharged/supercharged.dart';
import 'package:tch_appliable_core/tch_appliable_core.dart';
import 'package:tch_appliable_core/utils/List.dart';
import 'package:tch_appliable_core/utils/widget.dart';
import 'package:tch_common_widgets/tch_common_widgets.dart';

class ProjectsScreen extends AbstractResponsiveScreen {
  static const String ROUTE = "/projects";

  /// Create state for widget
  @override
  State<StatefulWidget> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends AppResponsiveScreenState<ProjectsScreen> {
  @override
  AbstractScreenOptions options = AppScreenStateOptions.main(
    screenName: ProjectsScreen.ROUTE,
    title: tt('projects.screen.title'),
  )..appBarOptions = <AppBarOption>[
      AppBarOption(
        onTap: (BuildContext context) {
          EditProjectDialog.show(context);
        },
        icon: SvgPicture.asset('images/plus.svg', color: kColorTextPrimary),
      ),
    ];

  ResponsiveScreen? _lastResponsiveScreen;
  Project? _project;

  @override
  Widget extraLargeDesktopScreen(BuildContext context) => _BodyDesktopWidget(
        onDataWidgetProjectInit: _onDataWidgetProjectInit,
      );

  @override
  Widget largeDesktopScreen(BuildContext context) => _BodyDesktopWidget(
        onDataWidgetProjectInit: _onDataWidgetProjectInit,
      );

  @override
  Widget largePhoneScreen(BuildContext context) => _BodyWidget(
        onDataWidgetProjectInit: _onDataWidgetProjectInit,
      );

  @override
  Widget smallDesktopScreen(BuildContext context) => _BodyDesktopWidget(
        onDataWidgetProjectInit: _onDataWidgetProjectInit,
      );

  @override
  Widget smallPhoneScreen(BuildContext context) => _BodyWidget(
        onDataWidgetProjectInit: _onDataWidgetProjectInit,
      );

  @override
  Widget tabletScreen(BuildContext context) => _BodyWidget(
        onDataWidgetProjectInit: _onDataWidgetProjectInit,
      );

  /// Run initializations of screen on first build only
  @override
  firstBuildOnly(BuildContext context) {
    super.firstBuildOnly(context);

    addPostFrameCallback((timeStamp) {
      _onDataWidgetProjectInit(_project);
    });
  }

  /// Create view layout from widgets
  @override
  Widget buildContent(BuildContext context) {
    final snapshot = AppDataState.of(context)!;

    addPostFrameCallback((timeStamp) {
      if (_lastResponsiveScreen != snapshot.responsiveScreen) {
        _lastResponsiveScreen = snapshot.responsiveScreen;

        _onDataWidgetProjectInit(_project);
      }
    });

    return super.buildContent(context);
  }

  /// On Project is initialized in DataWidget
  void _onDataWidgetProjectInit(Project? project) {
    final snapshot = AppDataState.of(context)!;
    final commonTheme = CommonTheme.of<AppTheme>(context)!;

    _project = project;

    final isDesktop = [
      ResponsiveScreen.ExtraLargeDesktop,
      ResponsiveScreen.LargeDesktop,
      ResponsiveScreen.SmallDesktop,
    ].contains(snapshot.responsiveScreen);

    setStateNotDisposed(() {
      options.appBarOptions = <AppBarOption>[
        AppBarOption(
          onTap: (BuildContext context) {
            EditProjectDialog.show(context);
          },
          icon: SvgPicture.asset('images/plus.svg', color: kColorTextPrimary),
          button: isDesktop
              ? ButtonWidget(
                  style: commonTheme.buttonsStyle.buttonStyle.copyWith(
                    variant: ButtonVariant.TextOnly,
                    contentPadding: const EdgeInsets.symmetric(horizontal: kCommonHorizontalMarginHalf),
                    widthWrapContent: true,
                  ),
                  text: tt('project_detail.add_project'),
                  prefixIconSvgAssetPath: 'images/plus.svg',
                  onTap: () {
                    EditProjectDialog.show(context);
                  },
                )
              : null,
        ),
        if (project != null) ...[
          AppBarOption(
            onTap: (BuildContext context) {
              EditProjectDialog.show(context, project: _project);
            },
            icon: SvgPicture.asset('images/edit.svg', color: kColorTextPrimary),
            button: isDesktop
                ? ButtonWidget(
                    style: commonTheme.buttonsStyle.buttonStyle.copyWith(
                      variant: ButtonVariant.TextOnly,
                      contentPadding: const EdgeInsets.symmetric(horizontal: kCommonHorizontalMarginHalf),
                      widthWrapContent: true,
                    ),
                    text: tt('project_detail.edit_project'),
                    prefixIconSvgAssetPath: 'images/edit.svg',
                    onTap: () {
                      EditProjectDialog.show(context, project: _project);
                    },
                  )
                : null,
          ),
          AppBarOption(
            onTap: (BuildContext context) => deleteProject(context, project: project),
            icon: SvgPicture.asset('images/trash.svg', color: kColorDanger),
            button: isDesktop
                ? ButtonWidget(
                    style: commonTheme.buttonsStyle.buttonStyle.copyWith(
                      variant: ButtonVariant.TextOnly,
                      contentPadding: const EdgeInsets.symmetric(horizontal: kCommonHorizontalMarginHalf),
                      widthWrapContent: true,
                      iconColor: kColorDanger,
                    ),
                    text: tt('project_detail.delete_project'),
                    prefixIconSvgAssetPath: 'images/trash.svg',
                    onTap: () {
                      deleteProject(context, project: project);
                    },
                  )
                : null,
          ),
        ],
      ];
    });
  }
}

abstract class _AbstractBodyWidget extends AbstractStatefulWidget {
  final ValueChanged<Project?> onDataWidgetProjectInit;

  /// AbstractBodyWidget initialization
  _AbstractBodyWidget({
    required this.onDataWidgetProjectInit,
  });
}

abstract class _AbstractBodyWidgetState<T extends _AbstractBodyWidget> extends AbstractStatefulWidgetState<T> {
  final _searchController = TextEditingController();
  Timer? _searchTimer;
  String _searchQuery = '';
  Project? _selectedProject;

  /// Manually dispose of resources
  @override
  void dispose() {
    _searchController.dispose();

    _searchTimer?.cancel();
    _searchTimer = null;

    super.dispose();
  }

  /// Run initializations of screen on first build only
  @override
  firstBuildOnly(BuildContext context) {
    super.firstBuildOnly(context);

    _searchController.addListener(_searchProjects);

    _selectProjectFromArguments(context);
  }

  /// Create view layout from widgets
  @override
  Widget buildContent(BuildContext context) {
    final commonTheme = CommonTheme.of<AppTheme>(context)!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: kCommonHorizontalMargin),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                  label: tt('projects.screen.field.search'),
                ),
              ),
              CommonSpaceH(),
            ],
          ),
          CommonSpaceV(),
          Expanded(
            child: _ProjectsListWidget(
              searchQuery: _searchQuery,
              selectProject: _selectProject,
              selectedProject: _selectedProject,
            ),
          ),
        ],
      ),
    );
  }

  /// Check routing arguments if Project should be selected
  Future<void> _selectProjectFromArguments(BuildContext context) async {
    final RoutingArguments arguments = RoutingArguments.of(context)!;

    final int? projectId = arguments[Project.COL_ID]?.toInt();

    if (projectId != null) {
      final dataTask = await MainDataProvider.instance!.executeDataTask(
        GetProjectDataTask(
          data: ProjectQuery.fromJson(
            <String, dynamic>{
              Project.COL_ID: projectId,
            },
          ),
        ),
      );

      final theProject = dataTask.result;

      if (theProject != null) {
        _selectProject(theProject);
      }
    }
  }

  /// Filter projects by current name string in real time
  void _searchProjects() {
    _searchTimer?.cancel();

    _searchTimer = Timer(Duration(milliseconds: 300), () {
      setStateNotDisposed(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  /// Select Project, on desktop screens show details, on smaller screens navs to details screen
  void _selectProject(Project? project) {
    final snapshot = AppDataState.of(context)!;

    if ([
      ResponsiveScreen.SmallDesktop,
      ResponsiveScreen.LargeDesktop,
      ResponsiveScreen.ExtraLargeDesktop,
    ].contains(snapshot.responsiveScreen)) {
      setStateNotDisposed(() {
        _selectedProject = project;
      });
    } else if (project != null) {
      _selectedProject = project;

      pushNamed(context, ProjectDetailScreen.ROUTE, arguments: <String, String>{
        Project.COL_ID: project.id!.toString(),
      });
    }
  }
}

class _BodyWidget extends _AbstractBodyWidget {
  /// BodyWidget initialization
  _BodyWidget({
    required ValueChanged<Project?> onDataWidgetProjectInit,
  }) : super(
          onDataWidgetProjectInit: onDataWidgetProjectInit,
        );

  /// Create state for widget
  @override
  State<StatefulWidget> createState() => _BodyWidgetState();
}

class _BodyWidgetState extends _AbstractBodyWidgetState<_BodyWidget> {}

class _BodyDesktopWidget extends _AbstractBodyWidget {
  /// BodyDesktopWidget initialization
  _BodyDesktopWidget({
    required ValueChanged<Project?> onDataWidgetProjectInit,
  }) : super(
          onDataWidgetProjectInit: onDataWidgetProjectInit,
        );

  /// Create state for widget
  @override
  State<StatefulWidget> createState() => _BodyDesktopWidgetState();
}

class _BodyDesktopWidgetState extends _AbstractBodyWidgetState<_BodyDesktopWidget> {
  /// Create view layout from widgets
  @override
  Widget buildContent(BuildContext context) {
    final commonTheme = CommonTheme.of<AppTheme>(context)!;

    final theProject = _selectedProject;

    return Container(
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonSpaceV(),
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: kLeftPanelWidth,
                  padding: const EdgeInsets.symmetric(horizontal: kCommonHorizontalMargin),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                              label: tt('projects.screen.field.search'),
                            ),
                          ),
                          CommonSpaceH(),
                        ],
                      ),
                      CommonSpaceV(),
                      Expanded(
                        child: _ProjectsListWidget(
                          searchQuery: _searchQuery,
                          selectProject: _selectProject,
                          selectedProject: _selectedProject,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: double.infinity,
                  color: kColorSecondaryDark,
                ),
                if (theProject != null)
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: kCommonHorizontalMargin),
                      child: ProjectDetailDataWidget(
                        projectId: theProject.id!,
                        onProjectChanged: widget.onDataWidgetProjectInit,
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: Container(),
                  ),
              ],
            ),
          ),
          CommonSpaceV(),
        ],
      ),
    );
  }
}

class _ProjectsListWidget extends AbstractStatefulWidget {
  final String searchQuery;
  final void Function(Project? project) selectProject;
  final Project? selectedProject;

  /// ProjectsListWidget initialization
  _ProjectsListWidget({
    required this.searchQuery,
    required this.selectProject,
    this.selectedProject,
  });

  /// Create state for widget
  @override
  State<StatefulWidget> createState() => _ProjectsListWidgetState();
}

class _ProjectsListWidgetState extends AbstractStatefulWidgetState<_ProjectsListWidget> {
  final _listKey = GlobalKey<ListDataWidgetState>();

  /// Widget parameters changed
  @override
  void didUpdateWidget(covariant _ProjectsListWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.searchQuery != widget.searchQuery) {
      _listKey.currentState!.updateDataRequests([
        _dataRequest(),
      ]);
    }
  }

  /// Create view layout from widgets
  @override
  Widget buildContent(BuildContext context) {
    final snapshot = AppDataState.of(context)!;
    final commonTheme = CommonTheme.of<AppTheme>(context)!;

    final isDesktop = [
      ResponsiveScreen.SmallDesktop,
      ResponsiveScreen.LargeDesktop,
      ResponsiveScreen.ExtraLargeDesktop,
    ].contains(snapshot.responsiveScreen);

    return ListDataWidget<GetProjectsDataRequest, Project>(
      key: _listKey,
      dataRequest: _dataRequest(),
      processResult: (GetProjectsDataRequest dataRequest) {
        final theProjects = dataRequest.result?.projects;

        sortProjectsAlphabetycally(theProjects);

        WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
          if (widget.selectedProject != null) {
            if (theProjects == null) {
              widget.selectProject(null);
            } else {
              final selectedProject = theProjects.firstWhereOrNull((project) => project.id == widget.selectedProject?.id);

              if (selectedProject == null) {
                widget.selectProject(null);
              }
            }
          }
        });

        return theProjects;
      },
      buildItem: (BuildContext context, int position, Project item) {
        return ButtonWidget(
          style: commonTheme.listItemButtonStyle.copyWith(
            variant: isDesktop && item.id == widget.selectedProject?.id ? ButtonVariant.Filled : ButtonVariant.TextOnly,
          ),
          text: item.name,
          onTap: isDesktop && item.id == widget.selectedProject?.id
              ? null
              : () {
                  widget.selectProject(item);
                },
        );
      },
      buildLoadingItemWithGlobalKey: (BuildContext context, GlobalKey globalKey) {
        return LoadingItemWidget(
          containerKey: globalKey,
          text: Text(
            tt('list.item.loading'),
            style: fancyText(kText),
          ),
        );
      },
      emptyState: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(kCommonPrimaryMargin),
        alignment: Alignment.topCenter,
        child: Text(
          tt('list.empty'),
          style: fancyText(kText),
        ),
      ),
    );
  }

  /// Create the DataRequest for current parameters
  GetProjectsDataRequest _dataRequest() {
    return GetProjectsDataRequest(
      parameters: <String, dynamic>{
        if (widget.searchQuery.isNotEmpty) '${Project.COL_NAME} LIKE': widget.searchQuery,
      },
    );
  }
}
