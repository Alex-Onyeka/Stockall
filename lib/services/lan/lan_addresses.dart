import 'dart:io';

import 'package:stockall/services/lan/lan_constants.dart';

/// A network interface reduced to strings. `InternetAddress` objects from
/// `NetworkInterface.list()` lose their IPv6 scope when reused, so only the
/// text form (`fe80::…%en0`) is kept and re-parsed when connecting.
class LanInterface {
  const LanInterface({
    required this.name,
    required this.index,
    required this.addresses,
  });

  final String name;
  final int index;
  final List<String> addresses;

  bool get skipped => isSkippedInterfaceName(name);
}

bool isSkippedInterfaceName(String name) {
  final lower = name.toLowerCase();
  return LanConstants.skippedInterfacePrefixes.any(lower.startsWith);
}

Future<List<LanInterface>> listLanInterfaces() async {
  final list = await NetworkInterface.list(
    includeLinkLocal: true,
    includeLoopback: false,
    type: InternetAddressType.any,
  );
  return [
    for (final i in list)
      LanInterface(
        name: i.name,
        index: i.index,
        addresses: i.addresses.map((a) => a.address).toList(),
      ),
  ];
}

/// Usable addresses of this device, for the pairing QR code.
List<String> ownAddresses(List<LanInterface> interfaces) {
  return [
    for (final i in interfaces)
      if (!i.skipped)
        for (final a in i.addresses) a,
  ];
}

final RegExp _zonePattern = RegExp(r'^[A-Za-z0-9._\-]+$');

/// Turns raw address strings (from mDNS, a QR code, a cache or a sweep)
/// into connectable candidates:
/// - anything that isn't an IP address is dropped;
/// - a `%zone` is kept as text, unless it names a skipped interface;
/// - a zone-less `fe80::` address is expanded to one candidate per usable
///   interface that has IPv6 link-local (numeric index on Windows);
/// - duplicates are removed, order is kept.
List<String> buildCandidates(
  Iterable<String> raw,
  List<LanInterface> interfaces, {
  required bool isWindows,
}) {
  final usable = interfaces.where((i) => !i.skipped).toList();
  final skippedZones = {
    for (final i in interfaces)
      if (i.skipped) ...[i.name, '${i.index}'],
  };
  final out = <String>{};
  for (final entry in raw) {
    final text = entry.trim();
    if (text.isEmpty) continue;
    final percent = text.indexOf('%');
    final host = percent < 0 ? text : text.substring(0, percent);
    final zone = percent < 0 ? null : text.substring(percent + 1);
    final parsed = InternetAddress.tryParse(host);
    if (parsed == null) continue;
    final isV6LinkLocal =
        parsed.type == InternetAddressType.IPv6 &&
        host.toLowerCase().startsWith('fe80');
    if (zone != null) {
      if (!isV6LinkLocal || zone.isEmpty || !_zonePattern.hasMatch(zone)) {
        continue;
      }
      if (skippedZones.contains(zone)) continue;
      out.add('$host%$zone');
    } else if (isV6LinkLocal) {
      for (final i in usable) {
        final hasLinkLocal = i.addresses.any(
          (a) => a.toLowerCase().startsWith('fe80'),
        );
        if (hasLinkLocal) {
          out.add('$host%${isWindows ? i.index : i.name}');
        }
      }
    } else {
      out.add(host);
    }
  }
  return out.toList();
}

bool isPrivateIPv4(String address) {
  final parts = address.split('.');
  if (parts.length != 4) return false;
  final a = int.tryParse(parts[0]);
  final b = int.tryParse(parts[1]);
  if (a == null || b == null) return false;
  return a == 10 || (a == 172 && b >= 16 && b <= 31) || (a == 192 && b == 168);
}

/// Hosts to sweep: the /24 of each private IPv4 address on a usable
/// interface, without this device's own addresses. 169.254/16 is too large
/// to sweep; direct cables rely on mDNS and IPv6 link-local instead.
List<String> sweepTargets(List<LanInterface> interfaces) {
  final own = <String>{};
  final prefixes = <String>{};
  for (final i in interfaces) {
    if (i.skipped) continue;
    for (final a in i.addresses) {
      if (!isPrivateIPv4(a)) continue;
      own.add(a);
      prefixes.add(a.substring(0, a.lastIndexOf('.')));
    }
  }
  return [
    for (final prefix in prefixes)
      for (var host = 1; host <= 254; host++)
        if (!own.contains('$prefix.$host')) '$prefix.$host',
  ];
}
