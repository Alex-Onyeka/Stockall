import 'dart:math';
import 'dart:typed_data';

// Bytes per BluetoothPrintPlus.write. Lower it if a printer with a small
// buffer drops data; raise it if printing is slow on a good printer.
const int escPosChunkBytes = 512;

// Character cell widths in dots for the two ESC/POS fonts.
const int fontADots = 12;
const int fontBDots = 9;

enum EscAlign { left, center, right }

class EscCol {
  final String text;
  final int flex;
  final EscAlign align;
  final bool bold;

  const EscCol(
    this.text, {
    this.flex = 1,
    this.align = EscAlign.left,
    this.bold = false,
  });
}

// Builds ESC/POS text commands for a thermal roll. Characters per line
// come from the printable width in dots, and every string is reduced to
// ASCII so it prints the same on any code page.
class EscPosBuilder {
  final int paperDots;
  final BytesBuilder _bytes = BytesBuilder();
  final StringBuffer _preview = StringBuffer();

  EscPosBuilder({required this.paperDots}) {
    _cmd([0x1B, 0x40]);
  }

  // Plain-text copy of what is printed, for debug logs and tests.
  String get preview => _preview.toString();

  int get length => _bytes.length;

  int charsPerLine({
    bool small = false,
    bool doubleWidth = false,
  }) {
    final chars =
        paperDots ~/ (small ? fontBDots : fontADots);
    return doubleWidth ? chars ~/ 2 : chars;
  }

  // Font A character widths for columns sharing the line by flex. The
  // last column takes whatever is left after rounding down.
  List<int> columnWidths(List<int> flexes) {
    final cpl = charsPerLine();
    final total = flexes.fold<int>(0, (a, b) => a + b);
    final widths = [for (final f in flexes) cpl * f ~/ total];
    widths[widths.length - 1] +=
        cpl - widths.fold<int>(0, (a, b) => a + b);
    return widths;
  }

  void text(
    String value, {
    EscAlign align = EscAlign.left,
    bool bold = false,
    bool small = false,
    bool doubleWidth = false,
    bool doubleHeight = false,
    int indent = 0,
  }) {
    final width = charsPerLine(
      small: small,
      doubleWidth: doubleWidth,
    );
    final size =
        (doubleWidth ? 0x10 : 0) | (doubleHeight ? 0x01 : 0);
    _cmd([0x1B, 0x61, align.index]);
    if (bold) _cmd([0x1B, 0x45, 1]);
    if (small) _cmd([0x1B, 0x4D, 1]);
    if (size != 0) _cmd([0x1D, 0x21, size]);
    for (final line in wrapText(
      escPosSafe(value),
      width - indent,
    )) {
      _line(' ' * indent + line);
    }
    if (size != 0) _cmd([0x1D, 0x21, 0]);
    if (small) _cmd([0x1B, 0x4D, 0]);
    if (bold) _cmd([0x1B, 0x45, 0]);
    if (align != EscAlign.left) _cmd([0x1B, 0x61, 0]);
  }

  // Bold label and regular value on one centred line, or on two lines
  // when they don't fit together.
  void centeredLabel(String label, String value) {
    final safeLabel = escPosSafe(label);
    final safeValue = escPosSafe(value);
    if (safeLabel.length + 1 + safeValue.length >
        charsPerLine()) {
      text(label, align: EscAlign.center, bold: true);
      text(value, align: EscAlign.center);
      return;
    }
    _cmd([0x1B, 0x61, 1, 0x1B, 0x45, 1]);
    _ascii(safeLabel);
    _cmd([0x1B, 0x45, 0]);
    _ascii(' $safeValue');
    _cmd([0x0A, 0x1B, 0x61, 0]);
    _preview.writeln('$safeLabel $safeValue');
  }

  // One row of columns. Text wraps inside its own column, and every
  // column but the last keeps a space before the next one.
  void columns(
    List<EscCol> cols, {
    bool doubleHeight = false,
  }) {
    final widths = columnWidths([
      for (final c in cols) c.flex,
    ]);
    final last = cols.length - 1;
    final cells = [
      for (var i = 0; i < cols.length; i++)
        wrapText(
          escPosSafe(cols[i].text),
          i == last ? widths[i] : widths[i] - 1,
        ),
    ];
    final rows = cells.fold<int>(
      0,
      (m, c) => max(m, c.length),
    );

    _cmd([0x1B, 0x61, 0]);
    if (doubleHeight) _cmd([0x1D, 0x21, 0x01]);
    for (var r = 0; r < rows; r++) {
      final plain = StringBuffer();
      for (var i = 0; i < cols.length; i++) {
        final room = i == last ? widths[i] : widths[i] - 1;
        var cell = _align(
          r < cells[i].length ? cells[i][r] : '',
          room,
          cols[i].align,
        );
        if (i != last) cell = '$cell ';
        // Trailing spaces on a full line can make some printers
        // print an extra blank line.
        if (i == last) cell = cell.trimRight();
        if (cols[i].bold) _cmd([0x1B, 0x45, 1]);
        _ascii(cell);
        if (cols[i].bold) _cmd([0x1B, 0x45, 0]);
        plain.write(cell);
      }
      _cmd([0x0A]);
      _preview.writeln(plain.toString().trimRight());
    }
    if (doubleHeight) _cmd([0x1D, 0x21, 0]);
  }

  // Small (Font B) text that starts where column [index] starts.
  void smallUnderColumn(
    String value,
    List<int> flexes,
    int index,
  ) {
    final widths = columnWidths(flexes);
    final offsetDots =
        widths.take(index).fold<int>(0, (a, b) => a + b) *
        fontADots;
    text(
      value,
      small: true,
      indent: (offsetDots / fontBDots).ceil(),
    );
  }

  void divider() {
    _cmd([0x1B, 0x61, 0]);
    _line('-' * charsPerLine());
  }

  void feed(int lines) {
    _cmd([0x1B, 0x64, lines]);
    for (var i = 0; i < lines; i++) {
      _preview.writeln();
    }
  }

  /// Feeds paper by [dots] vertical dots (ESC J n: 0x1B, 0x4A, n).
  /// Standard font line height is ~24-30 dots, so 6-8 dots creates subtle
  /// sub-line spacing between rows without inserting a full blank line.
  void feedDots([int dots = 6]) {
    _cmd([0x1B, 0x4A, dots.clamp(0, 255)]);
  }

  // EAN-13 with the digits printed below, centred. The printer adds the
  // check digit. Anything that isn't 12 or 13 digits prints as text.
  void ean13(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 12 && digits.length != 13) {
      text(value, align: EscAlign.center);
      return;
    }
    final data = digits.substring(0, 12);
    _cmd([
      0x1B, 0x61, 1, //
      0x1D, 0x68, 80, // height in dots
      0x1D, 0x77, min(3, paperDots ~/ 113), // module width
      0x1D, 0x48, 2, // digits below
      0x1D, 0x6B, 67, 12, ...data.codeUnits,
      0x0A,
      0x1B, 0x61, 0,
    ]);
    _preview.writeln('[EAN-13 $data]');
  }

  // Pre-built GS v 0 raster bands, such as the shop logo.
  void raster(List<Uint8List> bands) {
    _cmd([0x1B, 0x61, 0]);
    for (final band in bands) {
      _bytes.add(band);
    }
    _preview.writeln('[logo]');
  }

  // Everything so far, split into writes of at most [chunkBytes].
  List<Uint8List> build({int chunkBytes = escPosChunkBytes}) {
    final all = _bytes.toBytes();
    return [
      for (var i = 0; i < all.length; i += chunkBytes)
        all.sublist(i, min(i + chunkBytes, all.length)),
    ];
  }

  void _cmd(List<int> bytes) => _bytes.add(bytes);

  // [value] must already be ASCII (see escPosSafe).
  void _ascii(String value) => _bytes.add(value.codeUnits);

  void _line(String value) {
    final trimmed = value.trimRight();
    _ascii(trimmed);
    _cmd([0x0A]);
    _preview.writeln(trimmed);
  }

  String _align(String value, int width, EscAlign align) {
    switch (align) {
      case EscAlign.left:
        return value.padRight(width);
      case EscAlign.right:
        return value.padLeft(width);
      case EscAlign.center:
        final left = (width - value.length) ~/ 2;
        return (' ' * left + value).padRight(width);
    }
  }
}

// Wraps on spaces to [width] characters. Words longer than a line are
// split. Newlines in [value] start a new line.
List<String> wrapText(String value, int width) {
  final room = max(1, width);
  final lines = <String>[];
  for (final paragraph in value.split('\n')) {
    var line = '';
    for (var word in paragraph.split(' ')) {
      if (word.isEmpty) continue;
      while (word.length > room) {
        if (line.isNotEmpty) {
          lines.add(line);
          line = '';
        }
        lines.add(word.substring(0, room));
        word = word.substring(room);
      }
      if (word.isEmpty) continue;
      if (line.isEmpty) {
        line = word;
      } else if (line.length + 1 + word.length <= room) {
        line = '$line $word';
      } else {
        lines.add(line);
        line = word;
      }
    }
    lines.add(line);
  }
  return lines;
}

// Multi-character keys come first so E£ is matched before £.
const Map<String, String> _escPosReplacements = {
  'E£': 'EGP',
  'د.إ': 'AED',
  '₦': 'N',
  '₹': 'Rs',
  '₺': 'TL',
  '£': 'GBP',
  '€': 'EUR',
  '₵': 'GHS',
  '¥': 'Y',
  'ß': 'ss',
  '‘': "'",
  '’': "'",
  '“': '"',
  '”': '"',
  '–': '-',
  '—': '-',
  '…': '...',
  '•': '*',
  '×': 'x',
  ' ': ' ',
  '\t': ' ',
};

const String _accented =
    'ÀÁÂÃÄÅàáâãäåÇçÈÉÊËèéêëÌÍÎÏìíîïÑñÒÓÔÕÖØòóôõöøÙÚÛÜùúûüÝýÿ';
const String _unaccented =
    'AAAAAAaaaaaaCcEEEEeeeeIIIIiiiiNnOOOOOOooooooUUUUuuuuYyy';

// Reduces [value] to printable ASCII. Currency signs become letters
// (₦ → N), accents are dropped, and anything else becomes '?'.
String escPosSafe(String value) {
  var result = value;
  _escPosReplacements.forEach((from, to) {
    result = result.replaceAll(from, to);
  });
  final out = StringBuffer();
  for (final rune in result.runes) {
    if (rune == 0x0A || (rune >= 0x20 && rune < 0x7F)) {
      out.writeCharCode(rune);
    } else if (rune < 0x20 || rune == 0x7F) {
      continue;
    } else {
      final i = _accented.indexOf(
        String.fromCharCode(rune),
      );
      out.write(i >= 0 ? _unaccented[i] : '?');
    }
  }
  return out.toString();
}
