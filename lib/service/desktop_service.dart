import 'dart:io';

import 'package:flutter/material.dart';
import 'package:js_trions/core/constants.dart';
import 'package:screen_retriever/screen_retriever.dart';
import 'package:window_manager/window_manager.dart';

const double kDesktopStopBreakpoint = 1200;
const double kWindowWidth = 1149;
const double kWindowHeight = 718;

/// Initialize desktop window on app init
Future<void> initDesktop() async {
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await windowManager.ensureInitialized();

    final isWindow = !(await windowManager.isMaximized()) && !(await windowManager.isFullScreen());

    if (isWindow) {
      final display = await screenRetriever.getPrimaryDisplay();

      final screenWidth = display.size.width;
      final screenHeight = display.size.height;

      if (screenWidth > kDesktopStopBreakpoint && screenWidth > kWindowWidth && screenHeight > kWindowHeight) {
        await windowManager.setSize(const Size(kWindowWidth, kWindowHeight));

        windowManager.center();
      } else {
        if (Platform.isWindows || Platform.isLinux) {
          windowManager.maximize();
        } else {
          windowManager.setFullScreen(true);
        }
      }
    }

    await windowManager.setTitle(kAppTitle);

    windowManager.show();

    _desktopReady = true;

    // Scheme may have resolved while the window did not exist yet, apply what was asked for meanwhile
    final theRequestedBrightness = _requestedDesktopBrightness;
    if (theRequestedBrightness != null) {
      await applyDesktopBrightness(theRequestedBrightness);
    }
  }
}

/// Has initDesktop finished, window_manager traps on a missing window until then
bool _desktopReady = false;

/// Last brightness asked for, applied by initDesktop when it arrives before the window exists
Brightness? _requestedDesktopBrightness;

/// Last brightness applied to the native window chrome, so repeat calls do not reach the platform channel
Brightness? _appliedDesktopBrightness;

/// Make the native window chrome follow the resolved app scheme
Future<void> applyDesktopBrightness(Brightness brightness) async {
  if (!(Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    return;
  }

  _requestedDesktopBrightness = brightness;

  if (!_desktopReady || _appliedDesktopBrightness == brightness) {
    return;
  }

  _appliedDesktopBrightness = brightness;

  await windowManager.setBrightness(brightness);
}
