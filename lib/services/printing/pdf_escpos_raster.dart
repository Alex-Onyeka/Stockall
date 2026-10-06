import 'dart:math';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:printing/printing.dart';
import 'package:stockall/providers/pos_printer/device_service.dart';

// Printable dot widths of 58mm and 80mm thermal printers at 203 dpi.
const int dots58mm = 384;
const int dots80mm = 576;

// Rows per GS v 0 command, so each Bluetooth write stays small.
const int rasterBandRows = 128;

// Turns a roll PDF (the same one desktop prints) into ESC/POS raster
// commands for a Bluetooth thermal printer. printerType 1 = 58mm.
Future<List<Uint8List>> pdfToEscPosRaster(
  Uint8List pdfBytes, {
  required int printerType,
}) async {
  final raster =
      await Printing.raster(
        pdfBytes,
        pages: [0],
        dpi: 203,
      ).first;

  final page = img.Image.fromBytes(
    width: raster.width,
    height: raster.height,
    bytes: raster.pixels.buffer,
    bytesOffset: raster.pixels.offsetInBytes,
    numChannels: 4,
    order: img.ChannelOrder.rgba,
  );

  final resized = img.copyResize(
    page,
    width: printerType == 1 ? dots58mm : dots80mm,
    interpolation: img.Interpolation.average,
  );

  return escPosRasterBands(
    resized,
    extraFeed: DeviceService.isPos,
  );
}

// ESC @, then the image as 1-bit GS v 0 bands, then a short paper feed.
List<Uint8List> escPosRasterBands(
  img.Image image, {
  bool extraFeed = false,
}) {
  final widthBytes = (image.width + 7) ~/ 8;
  final bands = <Uint8List>[
    Uint8List.fromList([0x1B, 0x40]),
  ];

  for (var top = 0; top < image.height; top += rasterBandRows) {
    final rows = min(rasterBandRows, image.height - top);
    final band = Uint8List(8 + widthBytes * rows);
    band.setAll(0, [
      0x1D,
      0x76,
      0x30,
      0x00,
      widthBytes & 0xFF,
      widthBytes >> 8,
      rows & 0xFF,
      rows >> 8,
    ]);
    for (var y = 0; y < rows; y++) {
      for (var x = 0; x < image.width; x++) {
        if (_isDark(image.getPixel(x, top + y))) {
          band[8 + y * widthBytes + (x >> 3)] |= 0x80 >> (x & 7);
        }
      }
    }
    bands.add(band);
  }

  bands.add(Uint8List.fromList([0x1B, 0x64, extraFeed ? 3 : 2]));
  return bands;
}

bool _isDark(img.Pixel pixel) {
  // Blend over white paper so transparent areas print blank.
  final alpha = pixel.aNormalized;
  final luminance =
      pixel.luminanceNormalized * alpha + (1 - alpha);
  return luminance < 0.5;
}
