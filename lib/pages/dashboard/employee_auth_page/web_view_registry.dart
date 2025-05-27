// lib/web_view_registry.dart
// This will be imported only on web

// ignore: avoid_web_libraries_in_flutter
import 'dart:ui' as ui;

import 'package:flutter/material.dart' as html;

void registerWebViewFactory(
  String viewId,
  html.Element Function(int viewId) factory,
) {
  // ignore: undefined_prefixed_name
  ui.platformViewRegistry.registerViewFactory(
    viewId,
    factory,
  );
}
