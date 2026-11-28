import 'package:flutter/material.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/lan_settings/components/lan_section.dart';
import 'package:stockall/pages/lan_settings/components/lan_settings_model.dart';
import 'package:stockall/providers/local_server_provider.dart';
import 'package:stockall/services/lan/lan_transport.dart';

/// Devices and the stock their carts hold. On the store
/// server, for a user with `Manage Local Server`: every device signed in
/// on it, who is signed in there, whether it is connected now, and its
/// holds, which can be released (for a till that broke with a cart open).
/// On a device using the server: the stock this device's carts hold.
class DevicesSection extends StatefulWidget {
  const DevicesSection({super.key, required this.model});

  final LanSettingsModel model;

  @override
  State<DevicesSection> createState() => _DevicesSectionState();
}

class _DevicesSectionState extends State<DevicesSection> {
  String? _releasing;
  String? _note;

  LanSettingsModel get model => widget.model;

  Future<void> _releaseDevice(LanConnectedDevice device) async {
    final name = _name(device);
    final go = await lanConfirm(
      context,
      title: 'Release held stock',
      message:
          'The stock $name\'s carts hold goes back on sale on every device. '
          'Its carts stay open.',
      action: 'Release',
    );
    if (!go || !mounted) return;
    setState(() {
      _releasing = device.deviceId;
      _note = null;
    });
    String note;
    try {
      final released = await model.releaseDeviceHolds(device.deviceId);
      note = 'Released $released held ${released == 1 ? 'item' : 'items'} '
          'from $name.';
    } catch (e) {
      note = 'Releasing failed: $e';
    }
    if (!mounted) return;
    setState(() {
      _releasing = null;
      _note = note;
    });
  }

  Future<void> _releaseOwn() async {
    final go = await lanConfirm(
      context,
      title: 'Release this device\'s held stock',
      message:
          'The stock this device\'s carts hold goes back on sale on every '
          'device. The carts stay open.',
      action: 'Release',
    );
    if (!go || !mounted) return;
    setState(() {
      _releasing = '';
      _note = null;
    });
    String note;
    try {
      await model.releaseOwnHolds();
      note = 'Released this device\'s held stock.';
    } catch (e) {
      note = 'Releasing failed: $e';
    }
    if (!mounted) return;
    setState(() {
      _releasing = null;
      _note = note;
    });
  }

  String _name(LanConnectedDevice device) => device.isThisDevice
      ? 'this desktop'
      : 'device ${lanShortId(device.deviceId)}';

  @override
  Widget build(BuildContext context) {
    if (!model.available) return const SizedBox.shrink();
    if (model.isServing) {
      return model.mayManage ? _server(context) : const SizedBox.shrink();
    }
    final kind = model.status.kind;
    if (kind != LanStatusKind.connected &&
        kind != LanStatusKind.serverUnreachable) {
      return const SizedBox.shrink();
    }
    final held = model.ownHolds;
    return LanSection(
      title: 'Stock held by this device',
      icon: Icons.shopping_cart_outlined,
      children: [
        LanText(
          held == 0
              ? 'This device\'s carts hold no stock on the store server.'
              : '$held ${held == 1 ? 'item' : 'items'} in this device\'s '
                    'carts ${held == 1 ? 'is' : 'are'} set aside on the store '
                    'server, so other devices can\'t sell ${held == 1 ? 'it' : 'them'}.',
        ),
        if (held > 0)
          LanButton(
            label: 'Release',
            outlined: true,
            busy: _releasing == '',
            onPressed: _releaseOwn,
          ),
        if (_note != null) LanNote(_note!),
      ],
    );
  }

  Widget _server(BuildContext context) {
    final devices = model.devices;
    final theme = returnTheme(context);
    return LanSection(
      title: 'Devices',
      icon: Icons.devices_other_outlined,
      children: [
        if (devices.isEmpty)
          const LanText('No device has signed in on this server yet.'),
        for (final device in devices)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 6,
              children: [
                Row(
                  spacing: 8,
                  children: [
                    Icon(
                      device.isThisDevice
                          ? Icons.desktop_windows_outlined
                          : Icons.point_of_sale_outlined,
                      size: 18,
                    ),
                    Expanded(
                      child: Text(
                        device.isThisDevice
                            ? 'This desktop'
                            : 'Device ${lanShortId(device.deviceId)}',
                        style: TextStyle(
                          fontSize: theme.mobileTexts.b2.fontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: (device.connected || device.isThisDevice
                                ? Colors.green
                                : Colors.grey)
                            .withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        device.connected || device.isThisDevice
                            ? 'Connected'
                            : 'Not connected',
                        style: TextStyle(
                          fontSize: theme.mobileTexts.b4.fontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                if (device.userEmail != null || device.lastSeen != null)
                  LanText(
                    [
                      if (device.userEmail != null) device.userEmail!,
                      if (device.lastSeen != null && !device.connected)
                        'last seen ${lanWhen(device.lastSeen!)}',
                    ].join(' · '),
                  ),
                if (device.holds.isEmpty)
                  const LanText('No stock held.')
                else ...[
                  for (final hold in device.holds)
                    LanText(
                      '${model.productName(hold.productUuid)} × '
                      '${_quantity(hold.quantity)} '
                      '(cart ${lanShortId(hold.cartId)})',
                      color: Colors.black87,
                    ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: LanButton(
                      label: 'Release this device\'s holds',
                      outlined: true,
                      danger: true,
                      busy: _releasing == device.deviceId,
                      onPressed: _releasing == null
                          ? () => _releaseDevice(device)
                          : null,
                    ),
                  ),
                ],
              ],
            ),
          ),
        if (_note != null) LanNote(_note!),
      ],
    );
  }

  static String _quantity(double q) =>
      q == q.roundToDouble() ? q.toInt().toString() : q.toString();
}
