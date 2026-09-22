import 'package:flutter/gestures.dart';
import 'package:js_trions/core/app_theme.dart';
import 'package:tch_appliable_core/tch_appliable_core.dart';
import 'package:tch_common_widgets/tch_common_widgets.dart';

/// Rich text composed of plain text and tappable links with animated hover
class LinkTextWidget extends AbstractStatefulWidget {
  final List<LinkTextPart> parts;

  /// LinkTextWidget initialization
  const LinkTextWidget({super.key, required this.parts});

  /// Create state for widget
  @override
  State<StatefulWidget> createState() => _LinkTextWidgetState();
}

class _LinkTextWidgetState extends AbstractStatefulWidgetState<LinkTextWidget> with TickerProviderStateMixin {
  List<AnimationController?> _hoverControllers = [];
  List<TapGestureRecognizer?> _recognizers = [];

  /// State initialization
  @override
  void initState() {
    super.initState();

    _createLinkResources();
  }

  /// Manually dispose of resources
  @override
  void dispose() {
    _disposeLinkResources();

    super.dispose();
  }

  /// Widget parameters changed
  @override
  void didUpdateWidget(covariant LinkTextWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    final linksChanged =
        oldWidget.parts.length != widget.parts.length ||
        oldWidget.parts.indexed.any((entry) => (entry.$2.onTap != null) != (widget.parts[entry.$1].onTap != null));

    if (linksChanged) {
      _disposeLinkResources();

      _createLinkResources();
    } else {
      // Callbacks may be new closures on every parent build, recognizers only need the latest one
      for (final (index, part) in widget.parts.indexed) {
        _recognizers[index]?.onTap = part.onTap;
      }
    }
  }

  /// Create view layout from widgets
  @override
  Widget buildContent(BuildContext context) {
    final commonTheme = CommonTheme.of<AppTheme>(context)!;

    final animationDuration = commonTheme.buttonsStyle.buttonStyle.animationDuration;
    final animationCurve = commonTheme.buttonsStyle.buttonStyle.animationCurve;

    final hoverControllers = _hoverControllers.nonNulls.toList();
    for (final controller in hoverControllers) {
      controller.duration = animationDuration;
    }

    return AnimatedBuilder(
      animation: Listenable.merge(hoverControllers),
      builder: (BuildContext context, Widget? child) {
        return Text.rich(
          TextSpan(
            children: [
              for (final (index, part) in widget.parts.indexed)
                if (part.onTap == null) TextSpan(text: part.text, style: fancyText(kTextOf(context))) else _buildLinkSpan(context, part, index, animationCurve),
            ],
          ),
        );
      },
    );
  }

  /// Build link span with underline color animated by its hover controller
  TextSpan _buildLinkSpan(BuildContext context, LinkTextPart part, int index, Curve animationCurve) {
    final controller = _hoverControllers[index]!;

    final hoverProgress = animationCurve.transform(controller.value);
    // Accent never carries text in either scheme, the label reads as normal text and the accent stays on the underline
    final decorationColor = Color.lerp(kColorAccentLine(context), kColorAccentLineHover(context), hoverProgress)!;

    return TextSpan(
      text: part.text,
      style: fancyText(kTextBoldOf(context).copyWith(decoration: TextDecoration.underline, decorationColor: decorationColor)),
      recognizer: _recognizers[index],
      onEnter: (event) => controller.forward(),
      onExit: (event) => controller.reverse(),
    );
  }

  /// Create hover controller and tap recognizer for each link part
  void _createLinkResources() {
    _hoverControllers = widget.parts.map((part) => part.onTap != null ? AnimationController(vsync: this, duration: kThemeAnimationDuration) : null).toList();
    _recognizers = widget.parts.map((part) => part.onTap != null ? (TapGestureRecognizer()..onTap = part.onTap) : null).toList();
  }

  /// Dispose hover controllers and tap recognizers of link parts
  void _disposeLinkResources() {
    for (final controller in _hoverControllers) {
      controller?.dispose();
    }

    for (final recognizer in _recognizers) {
      recognizer?.dispose();
    }
  }
}

class LinkTextPart {
  final String text;
  final VoidCallback? onTap;

  /// LinkTextPart initialization, part with onTap is rendered as link
  const LinkTextPart({required this.text, this.onTap});
}
