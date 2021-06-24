import 'package:flutter_svg/flutter_svg.dart';
import 'package:js_trions/core/AppTheme.dart';
import 'package:js_trions/ui/dialogs/FeedbackDialog.dart';
import 'package:js_trions/ui/screenStates/AppResponsiveScreenState.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:tch_appliable_core/tch_appliable_core.dart';
import 'package:tch_common_widgets/tch_common_widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends AbstractResposiveScreen {
  static const String ROUTE = "/about";

  /// Create state for widget
  @override
  State<StatefulWidget> createState() => _AboutScreenState();
}

class _AboutScreenState extends AppResponsiveScreenState<AboutScreen> {
  @override
  AbstractScreenStateOptions options = AppScreenStateOptions.main(
    screenName: AboutScreen.ROUTE,
    title: tt('about.screen.title'),
  );

  @override
  Widget extraLargeDesktopScreen(BuildContext context) => _BodyDesktopWidget();

  @override
  Widget largeDesktopScreen(BuildContext context) => _BodyDesktopWidget();

  @override
  Widget largePhoneScreen(BuildContext context) => _BodyWidget();

  @override
  Widget smallDesktopScreen(BuildContext context) => _BodyDesktopWidget();

  @override
  Widget smallPhoneScreen(BuildContext context) => _BodyWidget();

  @override
  Widget tabletScreen(BuildContext context) => _BodyWidget();
}

abstract class _AbstractBodyWidget extends AbstractStatefulWidget {}

abstract class _AbstractBodyWidgetState<T extends _AbstractBodyWidget> extends AbstractStatefulWidgetState<T> {
  String _version = '';

  /// Run initializations of screen on first build only
  @override
  firstBuildOnly(BuildContext context) {
    super.firstBuildOnly(context);

    PackageInfo.fromPlatform().then((PackageInfo packageInfo) => setStateNotDisposed(() {
          _version = 'JsTrions: ${packageInfo.version}';
        }));
  }

  /// Create view layout from widgets
  @override
  Widget buildContent(BuildContext context) {
    return Scrollbar(
      child: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: kCommonHorizontalMargin),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CommonSpaceV(),
              Container(
                width: kPhoneStopBreakpoint,
                padding: const EdgeInsets.symmetric(horizontal: kCommonHorizontalMargin),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 295,
                        child: Image.asset('images/tomas-chylyV3-padded-black-circle.png'),
                      ),
                      CommonSpaceVHalf(),
                      Text(
                        _version,
                        style: fancyText(kText),
                        textAlign: TextAlign.center,
                      ),
                      CommonSpaceV(),
                    ],
                  ),
                ),
              ),
              Container(
                width: kPhoneStopBreakpoint,
                padding: const EdgeInsets.symmetric(horizontal: kCommonHorizontalMargin),
                child: _InfoWidget(
                  crossAxisAlignment: CrossAxisAlignment.center,
                ),
              ),
              Container(
                width: kPhoneStopBreakpoint,
                padding: const EdgeInsets.symmetric(horizontal: kCommonHorizontalMargin),
                child: _LinksWidget(
                  crossAxisAlignment: CrossAxisAlignment.center,
                ),
              ),
              Container(
                width: kPhoneStopBreakpoint,
                padding: const EdgeInsets.symmetric(horizontal: kCommonHorizontalMargin),
                child: _AttributionWidget(
                  crossAxisAlignment: CrossAxisAlignment.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BodyWidget extends _AbstractBodyWidget {
  /// Create state for widget
  @override
  State<StatefulWidget> createState() => _BodyWidgetState();
}

class _BodyWidgetState extends _AbstractBodyWidgetState<_BodyWidget> {}

class _BodyDesktopWidget extends _AbstractBodyWidget {
  /// Create state for widget
  @override
  State<StatefulWidget> createState() => _BodyDesktopWidgetState();
}

class _BodyDesktopWidgetState extends _AbstractBodyWidgetState<_BodyDesktopWidget> {
  /// Create view layout from widgets
  @override
  Widget buildContent(BuildContext context) {
    return Scrollbar(
      child: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommonSpaceV(),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: kPhoneStopBreakpoint,
                        padding: const EdgeInsets.symmetric(horizontal: kCommonHorizontalMargin),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 295,
                                child: Image.asset('images/tomas-chylyV3-padded-black-circle.png'),
                              ),
                              CommonSpaceVHalf(),
                              Text(
                                _version,
                                style: fancyText(kText),
                                textAlign: TextAlign.center,
                              ),
                              CommonSpaceV(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(),
                  ),
                ],
              ),
              CommonSpaceV(),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: kPhoneStopBreakpoint,
                        padding: const EdgeInsets.symmetric(horizontal: kCommonHorizontalMargin),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _InfoWidget(),
                            _AttributionWidget(),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: kPhoneStopBreakpoint,
                        padding: const EdgeInsets.symmetric(horizontal: kCommonHorizontalMargin),
                        child: _LinksWidget(),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoWidget extends StatelessWidget {
  final CrossAxisAlignment crossAxisAlignment;

  /// InfoWidget initialization
  _InfoWidget({
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  /// Create view layout from widgets
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kCommonHorizontalMargin),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: crossAxisAlignment,
        children: [
          Text(
            tt('about.screen.text'),
            style: fancyText(kText),
          ),
          CommonSpaceV(),
        ],
      ),
    );
  }
}

class _LinksWidget extends StatelessWidget {
  final CrossAxisAlignment crossAxisAlignment;

  /// LinksWidget initialization
  _LinksWidget({
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  /// Create view layout from widgets
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kCommonHorizontalMargin),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: crossAxisAlignment,
        children: [
          ButtonWidget(
            text: tt('about.screen.website'),
            onTap: () => launch('https://tomas-chyly.com/en/'),
          ),
          CommonSpaceV(),
          ButtonWidget(
            text: tt('about.screen.contact'),
            onTap: () => _sendFeedback(context),
          ),
          CommonSpaceV(),
          ButtonWidget(
            text: tt('about.screen.privacy'),
            onTap: () => launch('https://tomas-chyly.com/en/jstrions-privacy-policy/'),
          ),
          CommonSpaceV(),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButtonWidget(
                svgAssetPath: 'images/linkedin.svg',
                onTap: () => launch('https://www.linkedin.com/in/tomas-chyly/'),
              ),
              CommonSpaceHHalf(),
              IconButtonWidget(
                svgAssetPath: 'images/twitter.svg',
                onTap: () => launch('https://twitter.com/TomasChyly'),
              ),
              CommonSpaceHHalf(),
              IconButtonWidget(
                svgAssetPath: 'images/github.svg',
                onTap: () => launch('https://github.com/tomaschyly'),
              ),
            ],
          ),
          CommonSpaceVHalf(),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButtonWidget(
                iconWidget: SvgPicture.asset('images/dartlang.svg'),
                onTap: () => launch('https://pub.dev/publishers/tomas-chyly.com/packages'),
              ),
              CommonSpaceHHalf(),
              IconButtonWidget(
                svgAssetPath: 'images/npm.svg',
                onTap: () => launch('https://www.npmjs.com/~tomaschyly'),
              ),
              CommonSpaceHHalf(),
              IconButtonWidget(
                svgAssetPath: 'images/stack_overflow.svg',
                onTap: () => launch('https://stackoverflow.com/users/1979892/tom%C3%A1%C5%A1-chyl%C3%BD'),
              ),
            ],
          ),
          CommonSpaceV(),
        ],
      ),
    );
  }

  /// Send feedback to BE using modal dialog
  Future<void> _sendFeedback(BuildContext context) async {
    final sent = await FeedbackDialog.show(context);

    if (sent == true) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          tt('feedback.submit'),
          style: fancyText(kText),
          textAlign: TextAlign.center,
        ),
      ));
    }
  }
}

class _AttributionWidget extends StatelessWidget {
  final CrossAxisAlignment crossAxisAlignment;

  /// AttributionWidget initialization
  _AttributionWidget({
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  /// Create view layout from widgets
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
