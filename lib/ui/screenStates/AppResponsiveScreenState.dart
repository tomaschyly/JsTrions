import 'package:js_trions/ui/AboutScreen.dart';
import 'package:js_trions/ui/DashboardScreen.dart';
import 'package:js_trions/ui/ProjectsScreen.dart';
import 'package:js_trions/ui/SettingsScreen.dart';
import 'package:js_trions/utils/AppTheme.dart';
import 'package:tch_appliable_core/tch_appliable_core.dart';

class AppScreenStateOptions extends AbstractScreenStateOptions {
  /// AppScreenStateOptions initialization for default app state
  AppScreenStateOptions.basic({
    required String screenName,
    required String title,
  }) : super.basic(
          screenName: screenName,
          title: title,
        ) {
    optionsBuildPreProcessor = optionsBuildPreProcess;
  }

  /// AppScreenStateOptions initialization for state with Drawer
  AppScreenStateOptions.main({
    required String screenName,
    required String title,
  }) : super.basic(
          screenName: screenName,
          title: title,
        ) {
    optionsBuildPreProcessor = optionsBuildPreProcess;

    drawerOptions = <DrawerOption>[
      DrawerOption(
        onSelect: (BuildContext context) {
          pushNamedNewStack(context, DashboardScreen.ROUTE, arguments: <String, String>{'router-fade-animation': '1'});
        },
        isSelected: (BuildContext context) {
          final RoutingArguments? arguments = RoutingArguments.of(context);

          return arguments?.route == DashboardScreen.ROUTE;
        },
        title: Text(
          tt('drawer.dashboard'),
          // style: AppStyles.Text, //TODO theme
        ),
        // icon: SvgPicture.asset('images/male.svg', color: Colors.black), //TODO icons
      ),
      DrawerOption(
        onSelect: (BuildContext context) {
          pushNamedNewStack(context, ProjectsScreen.ROUTE, arguments: <String, String>{'router-fade-animation': '1'});
        },
        isSelected: (BuildContext context) {
          final RoutingArguments? arguments = RoutingArguments.of(context);

          return arguments?.route == ProjectsScreen.ROUTE;
        },
        title: Text(
          tt('drawer.projects'),
          // style: AppStyles.Text, //TODO theme
        ),
        // icon: SvgPicture.asset('images/male.svg', color: Colors.black), //TODO icons
      ),
      DrawerOption(
        onSelect: (BuildContext context) {
          pushNamedNewStack(context, SettingsScreen.ROUTE, arguments: <String, String>{'router-fade-animation': '1'});
        },
        isSelected: (BuildContext context) {
          final RoutingArguments? arguments = RoutingArguments.of(context);

          return arguments?.route == SettingsScreen.ROUTE;
        },
        title: Text(
          tt('drawer.settings'),
          // style: AppStyles.Text, //TODO theme
        ),
        // icon: SvgPicture.asset('images/male.svg', color: Colors.black), //TODO icons
      ),
      DrawerOption(
        onSelect: (BuildContext context) {
          pushNamedNewStack(context, AboutScreen.ROUTE, arguments: <String, String>{'router-fade-animation': '1'});
        },
        isSelected: (BuildContext context) {
          final RoutingArguments? arguments = RoutingArguments.of(context);

          return arguments?.route == AboutScreen.ROUTE;
        },
        title: Text(
          tt('drawer.about'),
          // style: AppStyles.Text, //TODO theme
        ),
        // icon: SvgPicture.asset('images/male.svg', color: Colors.black), //TODO icons
      ),
    ];
  }

  /// Callback used to preProcess options at the start of each build
  /// May be used to change options based on some conditions
  void optionsBuildPreProcess(BuildContext context) {
    final AbstractAppDataStateSnapshot snapshot = AppDataState.of(context)!;

    final permanentlyVisibleDrawerScreens = [
      ResponsiveScreen.ExtraLargeDesktop,
      ResponsiveScreen.LargeDesktop,
      ResponsiveScreen.SmallDesktop,
    ];

    drawerIsPermanentlyVisible = permanentlyVisibleDrawerScreens.contains(snapshot.responsiveScreen);
  }
}

abstract class AppResponsiveScreenState<T extends AbstractResposiveScreen> extends AbstractResposiveScreenState<T> {
  /// Create default AppBar
  @override
  AppBar? createAppBar(BuildContext context) => null;

  /// Create default BottomNavigationBar
  @protected
  BottomNavigationBar? createBottomBar(BuildContext context) => null;

  /// Create default Drawer
  @protected
  Widget? createDrawer(BuildContext context) {
    final theDrawerOptions = options.drawerOptions;

    if (theDrawerOptions != null && theDrawerOptions.isNotEmpty) {
      final drawerList = Container(
        width: options.drawerIsPermanentlyVisible ? 304 : null,
        // color: AppColors.GoldDarker, //TODO theme
        child: ListView(padding: EdgeInsets.zero, children: [
          Container(height: MediaQuery.of(context).padding.top),
          ...theDrawerOptions
              .map(
                (DrawerOption option) => Material(
                  // color: option.isSelected(context) ? AppColors.SilverDarker : AppColors.GoldDarker, //TODO theme
                  child: InkWell(
                    child: Container(
                      height: 48,
                      padding: option.icon != null
                          ? const EdgeInsets.only(right: AppDimens.PrimaryHorizontalMargin)
                          : const EdgeInsets.symmetric(horizontal: AppDimens.PrimaryHorizontalMargin),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          if (option.icon != null)
                            Container(
                              width: 48,
                              height: 48,
                              child: Center(
                                child: Container(
                                  width: 24,
                                  height: 24,
                                  child: option.icon,
                                ),
                              ),
                            ),
                          option.title,
                        ],
                      ),
                    ),
                    onTap: !option.isSelected(context)
                        ? () {
                            if (!options.drawerIsPermanentlyVisible) {
                              Navigator.pop(context);
                            }

                            option.onSelect(context);
                          }
                        : null,
                  ),
                ),
              )
              .toList(),
        ]),
      );

      if (options.drawerIsPermanentlyVisible) {
        return drawerList;
      } else {
        return Drawer(
          child: drawerList,
        );
      }
    }

    return null;
  }
}
