import 'dart:io';
import 'dart:ui';

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

    windowManager.show();
  }
}
