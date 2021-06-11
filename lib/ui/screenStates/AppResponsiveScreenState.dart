import 'package:flutter_svg/svg.dart';
import 'package:js_trions/ui/screens/AboutScreen.dart';
import 'package:js_trions/ui/screens/DashboardScreen.dart';
import 'package:js_trions/ui/screens/ProjectsScreen.dart';
import 'package:js_trions/ui/screens/SettingsScreen.dart';
import 'package:js_trions/core/AppTheme.dart';
import 'package:tch_appliable_core/tch_appliable_core.dart';
import 'package:tch_common_widgets/tch_common_widgets.dart';

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
          pushNamedNewStack(context, DashboardScreen.ROUTE, arguments: <String, String>{'router-no-animation': '1'});
        },
        isSelected: (BuildContext context) {
          final RoutingArguments? arguments = RoutingArguments.of(context);

          return arguments?.route == DashboardScreen.ROUTE;
        },
        title: Text(
          tt('drawer.dashboard'),
          style: fancyText(kText),
        ),
        icon: SvgPicture.asset('images/dashboard.svg', color: kColorTextPrimary),
      ),
      DrawerOption(
        onSelect: (BuildContext context) {
          pushNamedNewStack(context, ProjectsScreen.ROUTE, arguments: <String, String>{'router-no-animation': '1'});
        },
        isSelected: (BuildContext context) {
          final RoutingArguments? arguments = RoutingArguments.of(context);

          return arguments?.route == ProjectsScreen.ROUTE;
        },
        title: Text(
          tt('drawer.projects'),
          style: fancyText(kText),
        ),
        icon: SvgPicture.asset('images/project.svg', color: kColorTextPrimary),
      ),
      DrawerOption(
        onSelect: (BuildContext context) {
          pushNamedNewStack(context, SettingsScreen.ROUTE, arguments: <String, String>{'router-no-animation': '1'});
        },
        isSelected: (BuildContext context) {
          final RoutingArguments? arguments = RoutingArguments.of(context);

          return arguments?.route == SettingsScreen.ROUTE;
        },
        title: Text(
          tt('drawer.settings'),
          style: fancyText(kText),
        ),
        icon: SvgPicture.asset('images/cog.svg', color: kColorTextPrimary),
      ),
      DrawerOption(
        onSelect: (BuildContext context) {
          pushNamedNewStack(context, AboutScreen.ROUTE, arguments: <String, String>{'router-no-animation': '1'});
        },
        isSelected: (BuildContext context) {
          final RoutingArguments? arguments = RoutingArguments.of(context);

          return arguments?.route == AboutScreen.ROUTE;
        },
        title: Text(
          tt('drawer.about'),
          style: fancyText(kText),
        ),
        icon: SvgPicture.asset('images/info.svg', color: kColorTextPrimary),
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
  @protected
  PreferredSizeWidget? createAppBar(BuildContext context) {
    final appTheme = CommonTheme.of<AppTheme>(context)!;

    return AppBar(
      toolbarHeight: 44,
      title: Text(
        options.title,
        style: fancyText(kTextHeadline),
      ),
      centerTitle: false,
      leading: options.drawerOptions?.isNotEmpty == true
          ? (!options.drawerIsPermanentlyVisible
              ? Builder(
                  builder: (BuildContext context) {
                    return IconButtonWidget(
                      style: appTheme.appBarIconButtonStyle,
                      svgAssetPath: 'images/hamburger.svg',
                      onTap: () {
                        Scaffold.of(context).openDrawer();
                      },
                    );
                  },
                )
              : null)
          : (Navigator.of(context).canPop() == true
              ? Builder(
                  builder: (BuildContext context) {
                    return IconButtonWidget(
                      style: appTheme.appBarIconButtonStyle,
                      svgAssetPath: 'images/back.svg',
                      onTap: () {
                        Navigator.pop(context);
                      },
                    );
                  },
                )
              : null),
      actions: options.appBarOptions
          ?.map((AppBarOption option) => Builder(
                builder: (BuildContext context) {
                  final theIcon = option.icon;
                  final theComplexIcon = option.complexIcon;

                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: IconButtonWidget(
                      style: appTheme.appBarIconButtonStyle.copyWith(
                        iconWidth: option.complexIcon != null ? kMinInteractiveSize : kIconSize,
                        iconHeight: option.complexIcon != null ? kMinInteractiveSize : kIconSize,
                      ),
                      iconWidget: (theComplexIcon != null ? theComplexIcon : theIcon) ?? Container(),
                      onTap: () {
                        option.onTap(context);
                      },
                    ),
                  );
                },
              ))
          .toList(),
    );
  }

  /// Create default BottomNavigationBar
  @protected
  BottomNavigationBar? createBottomBar(BuildContext context) => null;

  /// Create default Drawer
  @protected
  Widget? createDrawer(BuildContext context) {
    final theDrawerOptions = options.drawerOptions;

    if (theDrawerOptions != null && theDrawerOptions.isNotEmpty) {
      final drawerList = Container(
        width: options.drawerIsPermanentlyVisible ? kDrawerWidth : null,
        color: kColorPrimary,
        child: ListView(padding: EdgeInsets.zero, children: [
          Container(height: MediaQuery.of(context).padding.top),
          ...theDrawerOptions
              .map(
                (DrawerOption option) => Material(
                  color: option.isSelected(context) ? kColorPrimaryLight : kColorPrimary,
                  child: InkWell(
                    child: Container(
                      height: kMinInteractiveSizeNotTouch + kCommonVerticalMarginHalf,
                      padding: option.icon != null
                          ? const EdgeInsets.only(right: kCommonHorizontalMargin)
                          : const EdgeInsets.symmetric(horizontal: kCommonHorizontalMargin),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          if (option.icon != null)
                            Container(
                              width: kMinInteractiveSizeNotTouch + kCommonHorizontalMarginHalf,
                              height: kMinInteractiveSizeNotTouch + kCommonVerticalMarginHalf,
                              child: Center(
                                child: Container(
                                  width: kIconSizeNotTouch,
                                  height: kIconSizeNotTouch,
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
