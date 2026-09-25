import 'package:bot_toast/bot_toast.dart';
import 'package:flutter_svg/svg.dart';
import 'package:js_trions/core/app_theme.dart';
import 'package:js_trions/ui/notifications/notification_toast_widget.dart';
import 'package:js_trions/ui/screens/AboutScreen.dart';
import 'package:js_trions/ui/screens/ProjectsScreen.dart';
import 'package:js_trions/ui/screens/dashboard_screen.dart';
import 'package:js_trions/ui/screens/settings_screen.dart';
import 'package:tch_appliable_core/tch_appliable_core.dart';
import 'package:tch_common_widgets/tch_common_widgets.dart';

class AppScreenStateOptions extends AbstractScreenOptions {
  /// AppScreenStateOptions initialization for default app state
  AppScreenStateOptions.basic({required super.screenName, required super.title}) : super.basic() {
    optionsBuildPreProcessor = optionsBuildPreProcess;
  }

  /// AppScreenStateOptions initialization for state with Drawer
  AppScreenStateOptions.main({required super.screenName, required super.title}) : super.basic() {
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
        title: Builder(builder: (BuildContext context) => Text(tt('drawer.dashboard'), style: fancyText(kTextOf(context)))),
        icon: Builder(
          builder: (BuildContext context) =>
              SvgPicture.asset('images/dashboard.svg', colorFilter: ColorFilter.mode(kColorTextPrimary(context), BlendMode.srcIn)),
        ),
      ),
      DrawerOption(
        onSelect: (BuildContext context) {
          pushNamedNewStack(context, ProjectsScreen.ROUTE, arguments: <String, String>{'router-no-animation': '1'});
        },
        isSelected: (BuildContext context) {
          final RoutingArguments? arguments = RoutingArguments.of(context);

          return arguments?.route == ProjectsScreen.ROUTE;
        },
        title: Builder(builder: (BuildContext context) => Text(tt('drawer.projects'), style: fancyText(kTextOf(context)))),
        icon: Builder(
          builder: (BuildContext context) => SvgPicture.asset('images/project.svg', colorFilter: ColorFilter.mode(kColorTextPrimary(context), BlendMode.srcIn)),
        ),
      ),
      DrawerOption(
        onSelect: (BuildContext context) {
          pushNamedNewStack(context, SettingsScreen.ROUTE, arguments: <String, String>{'router-no-animation': '1'});
        },
        isSelected: (BuildContext context) {
          final RoutingArguments? arguments = RoutingArguments.of(context);

          return arguments?.route == SettingsScreen.ROUTE;
        },
        title: Builder(builder: (BuildContext context) => Text(tt('drawer.settings'), style: fancyText(kTextOf(context)))),
        icon: Builder(
          builder: (BuildContext context) => SvgPicture.asset('images/cog.svg', colorFilter: ColorFilter.mode(kColorTextPrimary(context), BlendMode.srcIn)),
        ),
      ),
      DrawerOption(
        onSelect: (BuildContext context) {
          pushNamedNewStack(context, AboutScreen.ROUTE, arguments: <String, String>{'router-no-animation': '1'});
        },
        isSelected: (BuildContext context) {
          final RoutingArguments? arguments = RoutingArguments.of(context);

          return arguments?.route == AboutScreen.ROUTE;
        },
        title: Builder(builder: (BuildContext context) => Text(tt('drawer.about'), style: fancyText(kTextOf(context)))),
        icon: Builder(
          builder: (BuildContext context) => SvgPicture.asset('images/info.svg', colorFilter: ColorFilter.mode(kColorTextPrimary(context), BlendMode.srcIn)),
        ),
      ),
    ];
  }

  /// Callback used to preProcess options at the start of each build
  /// May be used to change options based on some conditions
  void optionsBuildPreProcess(BuildContext context) {
    final AbstractAppDataStateSnapshot snapshot = AppDataState.of(context)!;

    final permanentlyVisibleDrawerScreens = [ResponsiveScreen.extraLargeDesktop, ResponsiveScreen.largeDesktop, ResponsiveScreen.smallDesktop];

    drawerIsPermanentlyVisible = permanentlyVisibleDrawerScreens.contains(snapshot.responsiveScreen);
  }
}

abstract class AppResponsiveScreenState<T extends AbstractResponsiveScreen> extends AbstractResponsiveScreenState<T> {
  /// Create default AppBar
  @override
  @protected
  PreferredSizeWidget? createAppBar(BuildContext context) {
    final appTheme = CommonTheme.of<AppTheme>(context)!;

    return AppBar(
      toolbarHeight: 44,
      title: Text(options.title, style: fancyText(kTextHeadlineOf(context))),
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
          ?.map(
            (AppBarOption option) => Builder(
              builder: (BuildContext context) {
                final theIcon = option.icon;
                final theComplexIcon = option.complexIcon;

                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child:
                      option.button ??
                      IconButtonWidget(
                        style: appTheme.appBarIconButtonStyle.copyWith(
                          iconWidth: option.complexIcon != null ? kMinInteractiveSize : kIconSize,
                          iconHeight: option.complexIcon != null ? kMinInteractiveSize : kIconSize,
                        ),
                        iconWidget: theComplexIcon ?? theIcon ?? Container(),
                        onTap: () {
                          option.onTap!(context);
                        },
                      ),
                );
              },
            ),
          )
          .toList(),
    );
  }

  /// Create default BottomNavigationBar
  @override
  @protected
  BottomNavigationBar? createBottomBar(BuildContext context) => null;

  /// Create default Drawer
  @override
  @protected
  Widget? createDrawer(BuildContext context) {
    final theDrawerOptions = options.drawerOptions;

    if (theDrawerOptions != null && theDrawerOptions.isNotEmpty) {
      final drawerList = Container(
        width: options.drawerIsPermanentlyVisible ? kDrawerWidthOverride : null,
        color: kColorBackground(context),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(height: MediaQuery.of(context).padding.top),
            ...theDrawerOptions.map(
              (DrawerOption option) => _DrawerOptionWidget(
                option: option,
                isSelected: option.isSelected(context),
                onSelect: () {
                  if (!options.drawerIsPermanentlyVisible) {
                    Navigator.pop(context);
                  }

                  option.onSelect(context);
                },
              ),
            ),
          ],
        ),
      );

      if (options.drawerIsPermanentlyVisible) {
        return drawerList;
      } else {
        return Drawer(child: drawerList);
      }
    }

    return null;
  }

  /// If available show message for this screen
  @override
  @protected
  void screenMessage(BuildContext context, ScreenMessage message) {
    final appTheme = context.appTheme;

    displayScreenMessage(message, appTheme: appTheme);
  }
}

class _DrawerOptionWidget extends AbstractStatefulWidget {
  final DrawerOption option;
  final bool isSelected;
  final VoidCallback onSelect;

  /// DrawerOptionWidget initialization
  const _DrawerOptionWidget({required this.option, required this.isSelected, required this.onSelect});

  /// Create state for widget
  @override
  State<StatefulWidget> createState() => _DrawerOptionWidgetState();
}

class _DrawerOptionWidgetState extends AbstractStatefulWidgetState<_DrawerOptionWidget> {
  bool _isHovered = false;

  /// Widget parameters changed
  @override
  void didUpdateWidget(covariant _DrawerOptionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // InkWell without onTap does not report hover exit, so stale hover would remain once option is deselected
    if (widget.isSelected) {
      _isHovered = false;
    }
  }

  /// Create view layout from widgets
  @override
  Widget buildContent(BuildContext context) {
    final commonTheme = CommonTheme.of<AppTheme>(context)!;

    final option = widget.option;

    Color color = widget.isSelected ? kColorSurface(context) : kColorBackground(context);
    if (!widget.isSelected && _isHovered) {
      color = kColorSurfaceHover(context);
    }

    // Background is below Material, so InkWell splash stays visible above hover color
    return AnimatedContainer(
      duration: commonTheme.buttonsStyle.buttonStyle.animationDuration,
      curve: commonTheme.buttonsStyle.buttonStyle.animationCurve,
      color: color,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          mouseCursor: !widget.isSelected ? SystemMouseCursors.click : MouseCursor.defer,
          // Hover is drawn by animated background, default InkWell hover overlay would double it
          hoverColor: Colors.transparent,
          onHover: _setHoverState,
          onTap: !widget.isSelected ? widget.onSelect : null,
          child: Container(
            height: kMinInteractiveSizeNotTouch + kCommonVerticalMarginHalf,
            padding: option.icon != null
                ? const EdgeInsets.only(right: kCommonHorizontalMargin)
                : const EdgeInsets.symmetric(horizontal: kCommonHorizontalMargin),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                if (option.icon != null)
                  SizedBox(
                    width: kMinInteractiveSizeNotTouch + kCommonHorizontalMarginHalf,
                    height: kMinInteractiveSizeNotTouch + kCommonVerticalMarginHalf,
                    child: Center(
                      child: SizedBox(width: kIconSizeNotTouch, height: kIconSizeNotTouch, child: option.icon),
                    ),
                  ),
                option.title!,
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Update hover state and rebuild only when value changes
  void _setHoverState(bool isHovered) {
    if (_isHovered == isHovered) {
      return;
    }

    setStateNotDisposed(() {
      _isHovered = isHovered;
    });
  }
}

/// Show message by options
void displayScreenMessage(ScreenMessage message, {required AppTheme appTheme}) {
  Future.delayed(kThemeAnimationDuration, () {
    BotToast.showCustomNotification(
      toastBuilder: (CancelFunc cancelFunc) {
        return NotificationToastWidget(appTheme: appTheme, message: message, cancelFunc: cancelFunc);
      },
      duration: message.duration,
      align: Alignment.topCenter,
      /*wrapAnimation: (controller, cancel, child) => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 1), // from bottom
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: controller,
          curve: Curves.easeOut,
        )),
        child: child,
      ),*/
    );
  });
}
