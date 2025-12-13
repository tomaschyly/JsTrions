import 'package:js_trions/service/InfoService.dart';
import 'package:js_trions/service/google_translate_service.dart';
import 'package:js_trions/service/openai_service.dart';
import 'package:js_trions/ui/data_widgets/dashboard_projects_data_widget.dart';
import 'package:js_trions/ui/screenStates/AppResponsiveScreenState.dart';
import 'package:js_trions/ui/widgets/dashboard/dashboard_info_widget.dart';
import 'package:tch_appliable_core/tch_appliable_core.dart';
import 'package:tch_appliable_core/utils/widget.dart';
import 'package:tch_common_widgets/tch_common_widgets.dart';

class DashboardScreen extends AbstractResponsiveScreen {
  static const String ROUTE = "/dashboard";

  /// Create state for widget
  @override
  State<StatefulWidget> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends AppResponsiveScreenState<DashboardScreen> {
  @override
  AbstractScreenOptions options = AppScreenStateOptions.main(
    screenName: DashboardScreen.ROUTE,
    title: tt('dashboard.screen.title'),
  );

  @override
  Widget extraLargeDesktopScreen(BuildContext context) => _BodyDesktopWidget(
        info: _info,
      );

  @override
  Widget largeDesktopScreen(BuildContext context) => _BodyDesktopWidget(
        info: _info,
      );

  @override
  Widget largePhoneScreen(BuildContext context) => _BodyWidget(
        info: _info,
      );

  @override
  Widget smallDesktopScreen(BuildContext context) => _BodyDesktopWidget(
        info: _info,
      );

  @override
  Widget smallPhoneScreen(BuildContext context) => _BodyWidget(
        info: _info,
      );

  @override
  Widget tabletScreen(BuildContext context) => _BodyWidget(
        info: _info,
      );

  List<DashboardInfoPayload> _info = [];

  /// Run initializations of screen on first build only
  @protected
  firstBuildOnly(BuildContext context) {
    super.firstBuildOnly(context);

    determineInfo(context);

    getGoogleTranslateDashboardInfo(_info);

    getOpenAIDashboardInfo(_info);
  }
}

abstract class _AbstractBodyWidget extends AbstractStatefulWidget {
  final List<DashboardInfoPayload> info;

  /// AbstractBodyWidget initialization
  _AbstractBodyWidget({required this.info});
}

abstract class _AbstractBodyWidgetState<T extends _AbstractBodyWidget> extends AbstractStatefulWidgetState<T> {
  final ScrollController _scrollController = ScrollController();

  /// Manually dispose of resources
  @override
  void dispose() {
    _scrollController.dispose();

    super.dispose();
  }

  /// Create view layout from widgets
  @override
  Widget buildContent(BuildContext context) {
    return Scrollbar(
      controller: _scrollController,
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: kCommonHorizontalMargin),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommonSpaceV(),
              DashboardProjectsDataWidget(),
              ...widget.info.map((info) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CommonSpaceVDouble(),
                    DashboardInfoWidget(
                      title: info.title,
                      text: info.text,
                      isDanger: info.isDanger,
                      actionSettingsText: info.actionSettingsText,
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _BodyWidget extends _AbstractBodyWidget {
  /// BodyWidget initialization
  _BodyWidget({required super.info});

  /// Create state for widget
  @override
  State<StatefulWidget> createState() => _BodyWidgetState();
}

class _BodyWidgetState extends _AbstractBodyWidgetState<_BodyWidget> {}

class _BodyDesktopWidget extends _AbstractBodyWidget {
  /// BodyDesktopWidget initialization
  _BodyDesktopWidget({required super.info});

  /// Create state for widget
  @override
  State<StatefulWidget> createState() => _BodyDesktopWidgetState();
}

class _BodyDesktopWidgetState extends _AbstractBodyWidgetState<_BodyDesktopWidget> {
  final _containerKey = GlobalKey();
  double _tileWidth = 0;

  /// Create view layout from widgets
  @override
  Widget buildContent(BuildContext context) {
    addPostFrameCallback((timeStamp) {
      _calculateTileWidth();
    });

    return Scrollbar(
      controller: _scrollController,
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Container(
          key: _containerKey,
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommonSpaceV(),
              if (_tileWidth > 0)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: kCommonHorizontalMargin),
                  child: Wrap(
                    spacing: kCommonHorizontalMargin,
                    runSpacing: kCommonHorizontalMargin,
                    children: [
                      SizedBox(
                        width: _tileWidth,
                        child: DashboardProjectsDataWidget(),
                      ),
                      ...widget.info.map((info) {
                        return SizedBox(
                          width: _tileWidth,
                          child: DashboardInfoWidget(
                            title: info.title,
                            text: info.text,
                            isDanger: info.isDanger,
                            actionSettingsText: info.actionSettingsText,
                          ),
                        );
                      }),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Calculate tile width from container size, 2 tiles per row with 3x 16px spaces
  void _calculateTileWidth() {
    final tileWidth = (_containerKey.currentContext?.size?.width ?? 0) / 2.0 - 32.0;

    if (tileWidth != _tileWidth) {
      setStateNotDisposed(() {
        _tileWidth = tileWidth;
      });
    }
  }
}
