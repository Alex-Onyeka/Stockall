import 'dart:async';

import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/pages/lan_settings/components/lan_settings_model.dart';
import 'package:stockall/pages/lan_settings/platforms/lan_settings_desktop.dart';
import 'package:stockall/pages/lan_settings/platforms/lan_settings_mobile.dart';

/// Settings › Store Network: where this device stands with the
/// store server, the server role, pairing, devices and their held stock,
/// and the store server alerts. One column on a phone, two on a desktop;
/// both lay out the same sections.
class LanSettingsPage extends StatefulWidget {
  const LanSettingsPage({super.key, this.model});

  /// Tests pass a fake; the app reads the LAN provider.
  final LanSettingsModel? model;

  @override
  State<LanSettingsPage> createState() => _LanSettingsPageState();
}

class _LanSettingsPageState extends State<LanSettingsPage> {
  late final LanSettingsModel _model = widget.model ?? LanSettingsModel();
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    _model.changes.addListener(_changed);
    // The force-clear countdown, and devices connecting and leaving.
    _tick = Timer.periodic(const Duration(seconds: 1), (_) => _changed());
  }

  @override
  void dispose() {
    _tick?.cancel();
    _model.changes.removeListener(_changed);
    super.dispose();
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < mobileScreen) {
          return LanSettingsMobile(model: _model);
        }
        return LanSettingsDesktop(model: _model);
      },
    );
  }
}
