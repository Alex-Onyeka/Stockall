import 'dart:typed_data';

// Which way a roll document goes to the printer, as pure rules: the
// printer saved on this device, the ways each platform can reach a
// printer, and what to offer when a direct send fails.

enum PosPlatform { android, ios, windows, macos, linux, web }

// Bluetooth: Android/iOS. Network: raw TCP (port 9100) from any native
// platform. Windows spooler: a printer installed in Windows (USB, shared
// or network), sent RAW. CUPS: a macOS/Linux print queue, sent raw.
enum PosTransport { bluetooth, network, windowsSpooler, cups }

enum PosPaper { mm58, mm80 }

extension PosPaperDetails on PosPaper {
  // Printable width in dots at 203 dpi.
  int get dots => this == PosPaper.mm58 ? 384 : 576;

  // The app's printType: 1 = 58mm, 2 = 80mm.
  int get printerType => this == PosPaper.mm58 ? 1 : 2;

  String get label => this == PosPaper.mm58 ? '58mm' : '80mm';
}

// The shop's printType (1 = 58mm, 2 = 80mm). Unset prints at 58mm, as
// the roll PDFs do.
PosPaper paperFromPrinterType(int? printerType) =>
    printerType == 2 ? PosPaper.mm80 : PosPaper.mm58;

const int defaultNetworkPort = 9100;

// The printer saved on this device.
class PosPrinterConfig {
  final PosTransport transport;

  // Bluetooth address, installed printer or queue name, or network host.
  final String address;

  // Network only.
  final int? port;

  // Shown to the user.
  final String name;
  final PosPaper paper;

  // Cut the paper after printing (printers without a cutter ignore it).
  final bool cut;

  const PosPrinterConfig({
    required this.transport,
    required this.address,
    required this.name,
    required this.paper,
    this.port,
    this.cut = false,
  });

  PosPrinterConfig copyWith({PosPaper? paper, bool? cut}) => PosPrinterConfig(
    transport: transport,
    address: address,
    name: name,
    port: port,
    paper: paper ?? this.paper,
    cut: cut ?? this.cut,
  );

  Map<String, dynamic> toMap() => {
    'transport': transport.name,
    'address': address,
    'port': port,
    'name': name,
    'paper': paper.name,
    'cut': cut,
  };

  // Null for anything that isn't a complete saved printer.
  static PosPrinterConfig? fromMap(Object? map) {
    if (map is! Map) return null;
    final transport = _byName(PosTransport.values, map['transport']);
    final paper = _byName(PosPaper.values, map['paper']);
    final address = map['address'];
    if (transport == null || paper == null) return null;
    if (address is! String || address.trim().isEmpty) return null;
    final port = map['port'];
    if (transport == PosTransport.network &&
        (port is! int || port < 1 || port > 65535)) {
      return null;
    }
    final name = map['name'];
    return PosPrinterConfig(
      transport: transport,
      address: address.trim(),
      port: port is int ? port : null,
      name: name is String && name.trim().isNotEmpty ? name.trim() : address,
      paper: paper,
      cut: map['cut'] == true,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is PosPrinterConfig &&
      other.transport == transport &&
      other.address == address &&
      other.port == port &&
      other.name == name &&
      other.paper == paper &&
      other.cut == cut;

  @override
  int get hashCode => Object.hash(transport, address, port, name, paper, cut);

  @override
  String toString() => 'PosPrinterConfig(${toMap()})';
}

T? _byName<T extends Enum>(List<T> values, Object? name) {
  for (final value in values) {
    if (value.name == name) return value;
  }
  return null;
}

// Ways each platform can reach a printer, in the order the setup offers
// them. Web has none: the browser print dialog is the only way.
List<PosTransport> transportsFor(PosPlatform platform) {
  switch (platform) {
    case PosPlatform.android:
    case PosPlatform.ios:
      return const [PosTransport.bluetooth, PosTransport.network];
    case PosPlatform.windows:
      return const [PosTransport.windowsSpooler, PosTransport.network];
    case PosPlatform.macos:
    case PosPlatform.linux:
      return const [PosTransport.cups, PosTransport.network];
    case PosPlatform.web:
      return const [];
  }
}

// Wired and network printers usually have a cutter; Bluetooth handheld
// printers usually don't.
bool defaultCut(PosTransport transport) => transport != PosTransport.bluetooth;

sealed class PosRoute {
  const PosRoute();
}

// The system print dialog with the roll PDF.
class PosSystemPrintRoute extends PosRoute {
  const PosSystemPrintRoute();
}

// Ask which printer to use, save it, then print.
class PosSetupRoute extends PosRoute {
  const PosSetupRoute();
}

// Send straight to the saved printer.
class PosDirectRoute extends PosRoute {
  final PosPrinterConfig printer;

  const PosDirectRoute(this.printer);
}

PosRoute choosePosRoute(PosPlatform platform, PosPrinterConfig? saved) {
  if (platform == PosPlatform.web) return const PosSystemPrintRoute();
  if (saved == null || !transportsFor(platform).contains(saved.transport)) {
    return const PosSetupRoute();
  }
  return PosDirectRoute(saved);
}

enum PosFailureChoice { retry, changePrinter, systemPrint }

// Offered when a direct send fails. Web never sends directly.
List<PosFailureChoice> failureChoices(PosPlatform platform) =>
    platform == PosPlatform.web ? const [] : PosFailureChoice.values;

// The printer to start from when nothing is saved yet: on Windows, the
// receipt printer the items report already uses (ReceiptPrinterClass).
PosPrinterConfig? seedPosPrinter({
  required PosPlatform platform,
  String? windowsPrinterName,
  int? windowsPaperSize,
  int? shopPrintType,
}) {
  final name = windowsPrinterName?.trim() ?? '';
  if (platform != PosPlatform.windows || name.isEmpty || name == 'Not Set') {
    return null;
  }
  return PosPrinterConfig(
    transport: PosTransport.windowsSpooler,
    address: name,
    name: name,
    paper: paperFromPrinterType(
      windowsPaperSize == 1 || windowsPaperSize == 2
          ? windowsPaperSize
          : shopPrintType,
    ),
    cut: true,
  );
}

// After the printer setup closes: a new choice replaces the saved
// printer; cancelling (null) keeps it. Saved only when it changed.
({PosPrinterConfig? printer, bool save}) printerAfterSetup(
  PosPrinterConfig? saved,
  PosPrinterConfig? picked,
) {
  if (picked == null) return (printer: saved, save: false);
  return (printer: picked, save: picked != saved);
}

// Keeping the current printer with a new paper size or cut setting.
PosPrinterConfig keepPrinter(
  PosPrinterConfig current, {
  required PosPaper paper,
  required bool cut,
}) => current.copyWith(paper: paper, cut: cut);

// Paper size the setup starts on.
PosPaper initialPaper(PosPrinterConfig? saved, int? shopPrintType) =>
    saved?.paper ?? paperFromPrinterType(shopPrintType);

// Null when [host] and [port] can be used for a network printer.
String? networkPrinterError(String host, String port) {
  final h = host.trim();
  if (h.isEmpty) return 'Enter the printer\'s IP address.';
  final ipv4 = RegExp(r'^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$');
  final ip = ipv4.firstMatch(h);
  if (ip != null) {
    for (var i = 1; i <= 4; i++) {
      if (int.parse(ip.group(i)!) > 255) {
        return 'That IP address is not valid.';
      }
    }
  } else if (!RegExp(
    r'^[A-Za-z0-9]([A-Za-z0-9-]*[A-Za-z0-9])?(\.[A-Za-z0-9]([A-Za-z0-9-]*[A-Za-z0-9])?)*$',
  ).hasMatch(h)) {
    return 'That IP address is not valid.';
  }
  final p = int.tryParse(port.trim());
  if (p == null || p < 1 || p > 65535) {
    return 'The port must be a number from 1 to 65535.';
  }
  return null;
}

// Queue names from `lpstat -e` (one per line) or `lpstat -a`
// ("<queue> accepting requests since ...").
List<String> parseLpstatQueues(String output) {
  final queues = <String>[];
  for (final line in output.split('\n')) {
    final trimmed = line.trim();
    if (trimmed.isEmpty) continue;
    final queue = trimmed.split(RegExp(r'\s+')).first;
    if (!queues.contains(queue)) queues.add(queue);
  }
  return queues;
}

// ---------------------------------------------------------------------
// Printer settings: the roll options and the A4 printer, both saved on
// this device next to the roll printer.

// How roll documents are laid out and finished, whichever way they reach
// the printer. Kept apart from the roll printer so the width also applies
// where no printer can be chosen (web, the system print dialog).
class RollOptions {
  final PosPaper paper;

  // Cut the paper after printing (printers without a cutter ignore it).
  final bool cut;

  const RollOptions({required this.paper, this.cut = false});

  RollOptions copyWith({PosPaper? paper, bool? cut}) =>
      RollOptions(paper: paper ?? this.paper, cut: cut ?? this.cut);

  Map<String, dynamic> toMap() => {'paper': paper.name, 'cut': cut};

  // Null without a known paper size. Unknown keys are ignored, so options
  // added later don't break older saves.
  static RollOptions? fromMap(Object? map) {
    if (map is! Map) return null;
    final paper = _byName(PosPaper.values, map['paper']);
    if (paper == null) return null;
    return RollOptions(paper: paper, cut: map['cut'] == true);
  }

  @override
  bool operator ==(Object other) =>
      other is RollOptions && other.paper == paper && other.cut == cut;

  @override
  int get hashCode => Object.hash(paper, cut);

  @override
  String toString() => 'RollOptions(${toMap()})';
}

// The roll options in force: the ones saved, else the paper and cut kept
// with the roll printer (saves from before roll options existed), else
// the shop's print type with no cut.
RollOptions effectiveRollOptions({
  RollOptions? saved,
  PosPrinterConfig? printer,
  int? shopPrintType,
}) {
  if (saved != null) return saved;
  if (printer != null) {
    return RollOptions(paper: printer.paper, cut: printer.cut);
  }
  return RollOptions(paper: paperFromPrinterType(shopPrintType));
}

// The roll printer with the roll options applied, as it is sent to.
PosPrinterConfig printerWithOptions(
  PosPrinterConfig printer,
  RollOptions options,
) => printer.copyWith(paper: options.paper, cut: options.cut);

// The A4 printer saved on this device: a system printer as the printing
// package names it (its url is the queue name on desktop and the AirPrint
// URL on iOS).
class A4PrinterConfig {
  final String url;

  // Shown to the user.
  final String name;

  const A4PrinterConfig({required this.url, required this.name});

  Map<String, dynamic> toMap() => {'url': url, 'name': name};

  // Null for anything that isn't a complete saved printer.
  static A4PrinterConfig? fromMap(Object? map) {
    if (map is! Map) return null;
    final url = map['url'];
    if (url is! String || url.trim().isEmpty) return null;
    final name = map['name'];
    return A4PrinterConfig(
      url: url.trim(),
      name: name is String && name.trim().isNotEmpty ? name.trim() : url.trim(),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is A4PrinterConfig && other.url == url && other.name == name;

  @override
  int get hashCode => Object.hash(url, name);

  @override
  String toString() => 'A4PrinterConfig(${toMap()})';
}

// Desktop can list the system printers. iOS can't list them, only pick
// one in the AirPrint picker. Android and web can't do either.
bool canListA4Printers(PosPlatform platform) =>
    platform == PosPlatform.windows ||
    platform == PosPlatform.macos ||
    platform == PosPlatform.linux;

bool canPickA4Printer(PosPlatform platform) => platform == PosPlatform.ios;

// Printing to a chosen printer without the system dialog: desktop and
// iOS. Android and web always print through the system dialog.
bool canDirectPrintA4(PosPlatform platform) =>
    canListA4Printers(platform) || canPickA4Printer(platform);

sealed class A4Route {
  const A4Route();
}

// The system print dialog with the A4 PDF.
class A4SystemPrintRoute extends A4Route {
  const A4SystemPrintRoute();
}

// Ask which A4 printer to use, save it, then print.
class A4SetupRoute extends A4Route {
  const A4SetupRoute();
}

// Send straight to the saved A4 printer.
class A4DirectRoute extends A4Route {
  final A4PrinterConfig printer;

  const A4DirectRoute(this.printer);
}

A4Route chooseA4Route(PosPlatform platform, A4PrinterConfig? saved) {
  if (!canDirectPrintA4(platform)) return const A4SystemPrintRoute();
  if (saved == null) return const A4SetupRoute();
  return A4DirectRoute(saved);
}

// Feed to the cutter and cut, leaving a little paper attached (GS V 66 0),
// as EscPosBuilder.cut does. Printers without a cutter ignore it.
const List<int> escPosCutCommand = [0x1D, 0x56, 0x42, 0x00];

// [chunks] with the cut command after them when [cut] is on.
List<Uint8List> withCut(List<Uint8List> chunks, {required bool cut}) =>
    cut ? [...chunks, Uint8List.fromList(escPosCutCommand)] : chunks;
