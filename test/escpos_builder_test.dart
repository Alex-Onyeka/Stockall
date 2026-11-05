import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/services/printing/escpos_builder.dart';

// Printable widths of 58mm and 80mm printers, as in pdf_escpos_raster.
const int _dots58 = 384;
const int _dots80 = 576;

bool _containsSequence(List<int> bytes, List<int> sequence) {
  for (var i = 0; i + sequence.length <= bytes.length; i++) {
    var match = true;
    for (var j = 0; j < sequence.length; j++) {
      if (bytes[i + j] != sequence[j]) {
        match = false;
        break;
      }
    }
    if (match) return true;
  }
  return false;
}

List<int> _allBytes(EscPosBuilder b) => [
  for (final chunk in b.build()) ...chunk,
];

void main() {
  group('charsPerLine', () {
    test('comes from the paper width and font', () {
      final narrow = EscPosBuilder(paperDots: _dots58);
      final wide = EscPosBuilder(paperDots: _dots80);

      expect(narrow.charsPerLine(), 32);
      expect(narrow.charsPerLine(small: true), 42);
      expect(narrow.charsPerLine(doubleWidth: true), 16);
      expect(wide.charsPerLine(), 48);
      expect(wide.charsPerLine(small: true), 64);
      expect(wide.charsPerLine(doubleWidth: true), 24);
    });
  });

  group('columns', () {
    test('splits the line by flex', () {
      expect(
        EscPosBuilder(paperDots: _dots58).columnWidths([6, 2, 4]),
        [16, 5, 11],
      );
      expect(
        EscPosBuilder(paperDots: _dots80).columnWidths([6, 2, 4]),
        [24, 8, 16],
      );
      expect(
        EscPosBuilder(paperDots: _dots58).columnWidths([9, 7]),
        [18, 14],
      );
    });

    test('pads columns and wraps long text inside its column', () {
      final b = EscPosBuilder(paperDots: _dots58);
      b.columns([
        EscCol('Indomie Chicken Flavour Super Pack', flex: 6),
        EscCol('[2]', flex: 2),
        EscCol('N1,500', flex: 4),
      ]);
      final lines = b.preview.trimRight().split('\n');

      expect(lines, [
        'Indomie Chicken [2]  N1,500',
        'Flavour Super',
        'Pack',
      ]);
      expect(lines.first.indexOf('[2]'), 16);
      expect(lines.first.indexOf('N1,500'), 21);
    });

    test('never prints past the line width', () {
      for (final dots in [_dots58, _dots80]) {
        final b = EscPosBuilder(paperDots: dots);
        b.columns([
          EscCol('Subtotal and a very long label', flex: 9),
          EscCol('N123,456,789.00', flex: 7, bold: true),
        ]);
        for (final line in b.preview.trimRight().split('\n')) {
          expect(
            line.length,
            lessThanOrEqualTo(b.charsPerLine()),
          );
        }
      }
    });
  });

  group('text', () {
    test('wraps double-width text at half the line', () {
      final b = EscPosBuilder(paperDots: _dots58);
      b.text(
        'Mama Nkechi Provisions',
        doubleWidth: true,
        doubleHeight: true,
      );

      expect(b.preview.trimRight().split('\n'), [
        'Mama Nkechi',
        'Provisions',
      ]);
      expect(
        _containsSequence(_allBytes(b), [0x1D, 0x21, 0x11]),
        isTrue,
      );
    });

    test('starts small text under the requested column', () {
      final b = EscPosBuilder(paperDots: _dots58);
      b.smallUnderColumn('was N2,000', [6, 2, 4], 2);

      // Column 2 starts 21 Font A chars in: 252 dots = 28 Font B chars.
      expect(b.preview, '${' ' * 28}was N2,000\n');
    });
  });

  group('escPosSafe', () {
    test('replaces currency signs', () {
      expect(escPosSafe('₦1,500'), 'N1,500');
      expect(escPosSafe('E£20'), 'EGP20');
      expect(escPosSafe('£5'), 'GBP5');
      expect(escPosSafe('€5 ₵5 ₹5 ₺5'), 'EUR5 GHS5 Rs5 TL5');
    });

    test('writes area and volume units without superscripts', () {
      expect(escPosSafe('6.6 M²'), '6.6 M2');
      expect(escPosSafe('2 m³'), '2 m3');
    });

    test('folds accents and replaces unknown characters', () {
      expect(escPosSafe('Café Crème'), 'Cafe Creme');
      expect(escPosSafe('Rice 漢😀'), 'Rice ??');
      expect(escPosSafe('a\rb\tc'), 'ab c');
    });

    test('keeps every printed byte in ASCII', () {
      final b = EscPosBuilder(paperDots: _dots80);
      b.text('Café ₦1,500 — “Total”', align: EscAlign.center);
      b.columns([EscCol('Jollof é', flex: 6), EscCol('₦500')]);

      expect(_allBytes(b).every((byte) => byte < 0x80), isTrue);
    });
  });

  group('cut', () {
    test('feeds to the cutter and cuts with GS V 66 0', () {
      final b = EscPosBuilder(paperDots: _dots80);
      b.text('Total');
      b.cut();

      final bytes = _allBytes(b);
      expect(bytes.sublist(bytes.length - 4), [0x1D, 0x56, 0x42, 0x00]);
      expect(b.preview, 'Total\n[cut]\n');
    });
  });

  group('ean13', () {
    test('sends the first 12 digits with GS k', () {
      final b = EscPosBuilder(paperDots: _dots58);
      b.ean13('1234567890128');

      expect(
        _containsSequence(_allBytes(b), [
          0x1D,
          0x6B,
          67,
          12,
          ...'123456789012'.codeUnits,
        ]),
        isTrue,
      );
    });

    test('prints anything else as text', () {
      final b = EscPosBuilder(paperDots: _dots58);
      b.ean13('TICKET-42');

      expect(b.preview, 'TICKET-42\n');
      expect(
        _containsSequence(_allBytes(b), [0x1D, 0x6B]),
        isFalse,
      );
    });
  });

  group('build', () {
    test('starts with ESC @ and splits into small writes', () {
      final b = EscPosBuilder(paperDots: _dots80);
      for (var i = 0; i < 100; i++) {
        b.columns([
          EscCol('Item $i', flex: 6),
          EscCol('[1]', flex: 2),
          EscCol('N1,000', flex: 4),
        ]);
      }
      final chunks = b.build();

      expect(chunks.first.sublist(0, 2), [0x1B, 0x40]);
      expect(chunks.length, greaterThan(1));
      for (final chunk in chunks) {
        expect(chunk.length, lessThanOrEqualTo(escPosChunkBytes));
      }
      expect(_allBytes(b).length, b.length);
    });
  });

  group('wrapText', () {
    test('splits words longer than the line', () {
      expect(wrapText('ABCDEFGHIJ', 4), ['ABCD', 'EFGH', 'IJ']);
    });

    test('starts a new line at newlines', () {
      expect(wrapText('Cash: N1\nBank: N2', 20), [
        'Cash: N1',
        'Bank: N2',
      ]);
    });
  });
}
