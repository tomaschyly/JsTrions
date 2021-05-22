import 'package:flutter/material.dart';
import 'package:js_trions/utils/AppTheme.dart';

class Space extends StatelessWidget {
  /// Create view layout from widgets
  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppDimens.PrimaryHorizontalMargin,
      height: AppDimens.PrimaryVerticalMargin,
    );
  }
}

class SpaceH extends StatelessWidget {
  /// Create view layout from widgets
  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppDimens.PrimaryHorizontalMargin,
    );
  }
}

class SpaceHHalf extends StatelessWidget {
  /// Create view layout from widgets
  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppDimens.PrimaryHorizontalMarginHalf,
    );
  }
}

class SpaceV extends StatelessWidget {
  /// Create view layout from widgets
  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppDimens.PrimaryVerticalMargin,
    );
  }
}

class SpaceVHalf extends StatelessWidget {
  /// Create view layout from widgets
  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppDimens.PrimaryVerticalMarginHalf,
    );
  }
}

class SpaceVDouble extends StatelessWidget {
  /// Create view layout from widgets
  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppDimens.PrimaryVerticalMarginDouble,
    );
  }
}
