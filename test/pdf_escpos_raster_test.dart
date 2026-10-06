import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:stockall/services/printing/pdf_escpos_raster.dart';

img.Image _whiteImage(int width, int height) {
  final image = img.Image(
    width: width,
    height: height,
    numChannels: 4,
  );
  img.fill(image, color: img.ColorRgba8(255, 255, 255, 255));
  return image;
}

void main() {
  group('escPosRasterBands', () {
    test('starts with ESC @ and ends with a paper feed', () {
      final bands = escPosRasterBands(_whiteImage(dots58mm, 10));

      expect(bands.first, [0x1B, 0x40]);
      expect(bands.last, [0x1B, 0x64, 2]);
    });

    test('adds one feed line on POS devices', () {
      final bands = escPosRasterBands(
        _whiteImage(dots58mm, 10),
        extraFeed: true,
      );

      expect(bands.last, [0x1B, 0x64, 3]);
    });

    test('splits the image into GS v 0 bands of at most 128 rows', () {
      final bands = escPosRasterBands(_whiteImage(dots58mm, 300));
      final imageBands = bands.sublist(1, bands.length - 1);

      expect(imageBands.length, 3);

      final rows = [128, 128, 44];
      for (var i = 0; i < imageBands.length; i++) {
        final band = imageBands[i];
        // GS v 0, m = 0, xL xH = 48 bytes per row, yL yH = rows.
        expect(band.sublist(0, 8), [
          0x1D,
          0x76,
          0x30,
          0x00,
          48,
          0,
          rows[i] & 0xFF,
          rows[i] >> 8,
        ]);
        expect(band.length, 8 + 48 * rows[i]);
      }
    });

    test('80mm width gives 72 bytes per row', () {
      final bands = escPosRasterBands(_whiteImage(dots80mm, 1));

      expect(bands[1].sublist(4, 6), [72, 0]);
    });

    test('packs black pixels MSB first and leaves white blank', () {
      final image = _whiteImage(16, 1);
      final black = img.ColorRgba8(0, 0, 0, 255);
      image.setPixel(0, 0, black);
      image.setPixel(9, 0, black);

      final data = escPosRasterBands(image)[1].sublist(8);

      expect(data, [0x80, 0x40]);
    });

    test('transparent pixels print blank', () {
      final image = img.Image(width: 8, height: 1, numChannels: 4);
      image.setPixel(0, 0, img.ColorRgba8(0, 0, 0, 0));

      final data = escPosRasterBands(image)[1].sublist(8);

      expect(data, [0x00]);
    });
  });
}
