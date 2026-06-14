import 'package:flutter/material.dart';

import 'application/collection_controller.dart';
import 'application/pool_controller.dart';
import 'application/settings_controller.dart';
import 'application/viewer_controller.dart';
import 'core/clock.dart';
import 'ui/theme/orbit_theme.dart';
import 'ui/viewer/viewer_screen.dart';

/// アプリのルート。テーマを当ててビューアを起動する。
class OrbitApp extends StatelessWidget {
  const OrbitApp({
    super.key,
    required this.viewer,
    required this.pool,
    required this.settings,
    required this.collection,
    this.clock = const SystemClock(),
  });

  final ViewerController viewer;
  final PoolController pool;
  final SettingsController settings;
  final CollectionController collection;
  final Clock clock;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ORBIT',
      debugShowCheckedModeBanner: false,
      theme: buildOrbitTheme(),
      home: ViewerScreen(
        controller: viewer,
        pool: pool,
        settings: settings,
        collection: collection,
        clock: clock,
      ),
    );
  }
}
