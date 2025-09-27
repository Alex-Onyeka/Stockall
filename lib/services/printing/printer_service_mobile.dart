import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_thermal_printer/flutter_thermal_printer.dart';
import 'package:flutter_thermal_printer/utils/printer.dart';
import 'package:flutter_usb_thermal_plugin/model/usb_device_model.dart';
import 'package:flutter_usb_thermal_plugin/flutter_usb_thermal_plugin.dart';
import 'package:stockall/classes/temp_main_receipt/temp_main_receipt.dart';
import 'package:stockall/classes/temp_product_slaes_record/temp_product_sale_record.dart';
import 'package:stockall/classes/temp_shop/temp_shop_class.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/main.dart';

FlutterUsbThermalPlugin usbPrinter =
    FlutterUsbThermalPlugin();
UsbDevice? deviceVar;
void setPrinter(UsbDevice newDevice) {
  deviceVar = newDevice;
}

void deletePrinter() {
  print(
    'Printer ${deviceVar?.productName} deleted Successfully',
  );
  deviceVar = null;
}

Future<void> connectToUsbDevice({
  required TempMainReceipt receipt,
  required List<TempProductSaleRecord> records,
  required TempShopClass shop,
  required BuildContext context,
}) async {
  var safeContext = context;

  // Step 1: Get list of USB devices
  List<UsbDevice> devices =
      await usbPrinter.getUSBDeviceList();

  if (deviceVar != null) {
    await usbPrinter.connect(
      int.tryParse(deviceVar!.vendorId) ?? 0,
      int.tryParse(deviceVar!.productId) ?? 0,
    );
    if (safeContext.mounted) {
      connectToPrinter(
        isConnected: true,
        safeContext: safeContext,
        device: deviceVar,
        receipt: receipt,
        records: records,
        shop: shop,
      );
      returnReceiptProvider(
        safeContext,
        listen: false,
      ).toggleIsLoading(false);
    }
    print(
      'Usb Device: ${deviceVar!.manufacturer} ${deviceVar!.productName} already connected',
    );

    return;
  } else {
    if (safeContext.mounted) {
      showDialog(
        context: context,
        builder: (context) {
          var theme = returnTheme(context, listen: false);
          return GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Material(
              color: const Color.fromARGB(63, 0, 0, 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 30,
                      horizontal: 20,
                    ),
                    height:
                        MediaQuery.of(context).size.height -
                        200,
                    width: 300,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        10,
                      ),
                      color: Colors.white,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceBetween,
                          children: [
                            Opacity(
                              opacity: 0,
                              child: Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  size: 18,
                                  Icons.clear,
                                ),
                              ),
                            ),
                            Text(
                              style: TextStyle(
                                fontSize:
                                    theme
                                        .mobileTexts
                                        .h4
                                        .fontSize,
                                fontWeight: FontWeight.bold,
                              ),
                              'Available Devices',
                            ),
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius:
                                    BorderRadius.circular(
                                      30,
                                    ),
                                onTap: () {
                                  Navigator.of(
                                    context,
                                  ).pop();
                                },
                                child: Container(
                                  padding: EdgeInsets.all(
                                    10,
                                  ),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    size: 18,
                                    Icons.clear,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        Divider(
                          color: Colors.grey.shade400,
                          height: 30,
                        ),
                        Builder(
                          builder: (context) {
                            if (devices.isEmpty) {
                              return Expanded(
                                child: Center(
                                  child: Column(
                                    spacing: 10,
                                    mainAxisSize:
                                        MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment
                                            .center,
                                    children: [
                                      Icon(
                                        size: 25,
                                        Icons
                                            .print_disabled_rounded,
                                      ),
                                      Text(
                                        style: TextStyle(
                                          fontWeight:
                                              FontWeight
                                                  .bold,
                                          fontSize:
                                              theme
                                                  .mobileTexts
                                                  .h4
                                                  .fontSize,
                                        ),
                                        'No Printer Found',
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            } else {
                              return Expanded(
                                child: ListView(
                                  children:
                                      devices
                                          .map(
                                            (
                                              device,
                                            ) => Material(
                                              color:
                                                  Colors
                                                      .transparent,
                                              child: ListTile(
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                      vertical:
                                                          5,
                                                      horizontal:
                                                          10,
                                                    ),
                                                shape: Border(
                                                  top: BorderSide(
                                                    color:
                                                        Colors.grey.shade200,
                                                  ),
                                                ),
                                                title: Row(
                                                  spacing:
                                                      10,
                                                  children: [
                                                    Icon(
                                                      size:
                                                          17,
                                                      Icons
                                                          .usb_rounded,
                                                    ),
                                                    Flexible(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment.start,
                                                        spacing:
                                                            5,
                                                        children: [
                                                          Text(
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight.bold,
                                                              fontSize:
                                                                  returnTheme(
                                                                    context,
                                                                    listen:
                                                                        false,
                                                                  ).mobileTexts.b1.fontSize,
                                                            ),
                                                            device.productName,
                                                          ),
                                                          Text(
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight.bold,
                                                              fontSize:
                                                                  theme.mobileTexts.b4.fontSize,
                                                            ),
                                                            'Usb',
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                onTap: () async {
                                                  Navigator.pop(
                                                    context,
                                                  );
                                                  await usbPrinter.connect(
                                                    int.tryParse(
                                                          device.vendorId,
                                                        ) ??
                                                        0,
                                                    int.tryParse(
                                                          device.productId,
                                                        ) ??
                                                        0,
                                                  );
                                                  if (safeContext
                                                      .mounted) {
                                                    connectToPrinter(
                                                      safeContext:
                                                          safeContext,
                                                      device:
                                                          device,
                                                      receipt:
                                                          receipt,
                                                      records:
                                                          records,
                                                      shop:
                                                          shop,
                                                    );
                                                  }
                                                },
                                              ),
                                            ),
                                          )
                                          .toList(),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ).then((_) {
        if (safeContext.mounted) {
          returnReceiptProvider(
            safeContext,
            listen: false,
          ).toggleIsLoading(false);
        }
      });
    }
  }
}

void scanBluetoothPrinters({
  required TempMainReceipt receipt,
  required List<TempProductSaleRecord> records,
  required TempShopClass shop,
  required BuildContext context,
}) async {
  var safeContext = context;
  var isTurnedOn =
      await FlutterThermalPrinter.instance.isBleTurnedOn();
  if (!isTurnedOn) {
    await FlutterThermalPrinter.instance.turnOnBluetooth();
  }
  FlutterThermalPrinter.instance.getPrinters(
    connectionTypes: [
      ConnectionType.BLE,
      // ConnectionType.USB,
    ],
  );

  late StreamSubscription<List<Printer>> subscription;

  subscription = FlutterThermalPrinter.instance.devicesStream.listen((
    List<Printer> printers,
  ) async {
    FlutterThermalPrinter.instance.stopScan();
    subscription.cancel();
    var printer = printers.first;
    var isConnected = await FlutterThermalPrinter.instance
        .connect(printers.first);
    if (isConnected == true && context.mounted) {
      connectToPrinter(
        isConnected: true,
        printer: printer,
        safeContext: safeContext,
        receipt: receipt,
        records: records,
        shop: shop,
      );
      print('Bluetooth: ${printer.name} already connected');
      return;
    } else {
      showDialog(
        context: context,
        builder: (context) {
          var theme = returnTheme(context, listen: false);
          return GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Material(
              color: const Color.fromARGB(63, 0, 0, 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 30,
                      horizontal: 20,
                    ),
                    height:
                        MediaQuery.of(context).size.height -
                        200,
                    width: 300,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        10,
                      ),
                      color: Colors.white,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceBetween,
                          children: [
                            Opacity(
                              opacity: 0,
                              child: Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  size: 18,
                                  Icons.clear,
                                ),
                              ),
                            ),
                            Text(
                              style: TextStyle(
                                fontSize:
                                    theme
                                        .mobileTexts
                                        .h4
                                        .fontSize,
                                fontWeight: FontWeight.bold,
                              ),
                              'Available Devices',
                            ),
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius:
                                    BorderRadius.circular(
                                      30,
                                    ),
                                onTap: () {
                                  Navigator.of(
                                    context,
                                  ).pop();
                                },
                                child: Container(
                                  padding: EdgeInsets.all(
                                    10,
                                  ),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    size: 18,
                                    Icons.clear,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        Divider(
                          color: Colors.grey.shade400,
                          height: 30,
                        ),
                        Builder(
                          builder: (context) {
                            if (printers.isEmpty) {
                              return Expanded(
                                child: Center(
                                  child: Column(
                                    spacing: 10,
                                    mainAxisSize:
                                        MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment
                                            .center,
                                    children: [
                                      Icon(
                                        size: 25,
                                        Icons
                                            .print_disabled_rounded,
                                      ),
                                      Text(
                                        style: TextStyle(
                                          fontWeight:
                                              FontWeight
                                                  .bold,
                                          fontSize:
                                              theme
                                                  .mobileTexts
                                                  .h4
                                                  .fontSize,
                                        ),
                                        'No Printer Found',
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            } else {
                              return Expanded(
                                child: ListView(
                                  children:
                                      printers
                                          .map(
                                            (
                                              printer,
                                            ) => Material(
                                              color:
                                                  Colors
                                                      .transparent,
                                              child: ListTile(
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                      vertical:
                                                          5,
                                                      horizontal:
                                                          10,
                                                    ),
                                                shape: Border(
                                                  top: BorderSide(
                                                    color:
                                                        Colors.grey.shade200,
                                                  ),
                                                ),
                                                title: Row(
                                                  spacing:
                                                      10,
                                                  children: [
                                                    Icon(
                                                      size:
                                                          17,
                                                      printer.connectionType ==
                                                              ConnectionType.BLE
                                                          ? Icons.bluetooth
                                                          : printer.connectionType ==
                                                              ConnectionType.USB
                                                          ? Icons.usb_rounded
                                                          : Icons.print,
                                                    ),
                                                    Flexible(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment.start,
                                                        spacing:
                                                            5,
                                                        children: [
                                                          Text(
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight.bold,
                                                              fontSize:
                                                                  returnTheme(
                                                                    context,
                                                                    listen:
                                                                        false,
                                                                  ).mobileTexts.b1.fontSize,
                                                            ),
                                                            printer.name ??
                                                                'Unnamed',
                                                          ),
                                                          Text(
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight.bold,
                                                              fontSize:
                                                                  theme.mobileTexts.b4.fontSize,
                                                            ),
                                                            printer.connectionType ==
                                                                    ConnectionType.BLE
                                                                ? 'BlueTooth'
                                                                : printer.connectionType ==
                                                                    ConnectionType.USB
                                                                ? 'Usb'
                                                                : 'Printer Type',
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                trailing: Visibility(
                                                  visible:
                                                      printer.isConnected !=
                                                          null &&
                                                      printer
                                                          .isConnected!,
                                                  child: Icon(
                                                    color:
                                                        printer.isConnected !=
                                                                    null &&
                                                                printer.isConnected!
                                                            ? Colors.amber
                                                            : Colors.grey,
                                                    Icons
                                                        .check,
                                                  ),
                                                ),
                                                onTap: () {
                                                  Navigator.pop(
                                                    context,
                                                  );
                                                  connectToPrinter(
                                                    printer:
                                                        printer,
                                                    safeContext:
                                                        safeContext,
                                                    receipt:
                                                        receipt,
                                                    records:
                                                        records,
                                                    shop:
                                                        shop,
                                                  );
                                                },
                                              ),
                                            ),
                                          )
                                          .toList(),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ).then((_) {
        if (safeContext.mounted) {
          returnReceiptProvider(
            safeContext,
            listen: false,
          ).toggleIsLoading(false);
        }
      });
    }
  });
}

void connectToPrinter({
  Printer? printer,
  UsbDevice? device,
  required BuildContext safeContext,
  required TempMainReceipt receipt,
  required List<TempProductSaleRecord> records,
  required TempShopClass shop,
  bool? isConnected,
}) async {
  if (isConnected == null && printer != null) {
    final result = await FlutterThermalPrinter.instance
        .connect(printer);
    print(
      result
          ? '✅ Connected to ${printer.name}'
          : '❌ Failed to connect',
    );
  }

  if (safeContext.mounted) {
    final data = generateStyledReceipt(
      receipt: receipt,
      records: records,
      shop: shop,
      context: safeContext,
    );
    if (printer != null) {
      await sendReceiptInChunks(
        data: data,
        printer: printer,
      );
    } else {
      // setPrinter(device!);
      await sendReceiptInChunks(data: data, device: device);
    }
  }

  if (safeContext.mounted) {
    returnReceiptProvider(
      safeContext,
      listen: false,
    ).toggleIsLoading(false);
  }
}

Future<void> sendReceiptInChunks({
  required Uint8List data,
  Printer? printer,
  UsbDevice? device,
  int chunkSize = 240, // Safe under BLE MTU
}) async {
  int offset = 0;

  while (offset < data.length) {
    final end =
        (offset + chunkSize < data.length)
            ? offset + chunkSize
            : data.length;

    final chunk = data.sublist(offset, end);

    if (printer != null) {
      await FlutterThermalPrinter.instance.printData(
        printer,
        chunk,
        longData: true,
      );
    } else {
      // await usbPrinter.write(chunk);
    }

    offset = end;
    await Future.delayed(
      Duration(milliseconds: 50),
    ); // Optional pacing
  }

  print('✅ Finished sending receipt in chunks.');
}

Uint8List generateStyledReceipt({
  required TempMainReceipt receipt,
  required List<TempProductSaleRecord> records,
  required TempShopClass shop,
  required BuildContext context,
}) {
  final builder = ReceiptBuilder();
  builder.addBlank();
  builder.addTitle(shop.name);
  builder.addTextMiddle(shop.email);
  if (shop.phoneNumber != null) {
    builder.addTextMiddle(shop.phoneNumber!);
  }
  builder.addTextMiddle(
    'Date: ${formatDateTime(receipt.createdAt)} | ${formatTime(receipt.createdAt)}',
  );

  builder.addSeparator();
  builder.addTextMiddle(
    receipt.isInvoice
        ? 'Generated Invoice'
        : 'Payment Receipt',
  );
  builder.addSeparator();
  builder.addBlank();
  builder.addTextBold('Items:'.toUpperCase());

  for (final item in records) {
    builder.addRowStyled(
      item.productName,
      '( ${item.quantity.toStringAsFixed(0)} )',
      formatMoneyMid(
        amount: item.revenue,
        context: context,
        isR: true,
      ),
      rightBold: false,
    );
  }
  builder.addBlank();
  builder.addSeparator();
  builder.addBlank();
  final subtotal = returnReceiptProvider(
    context,
    listen: false,
  ).getSubTotalRevenueForReceipt(context, records);
  final total = returnReceiptProvider(
    context,
    listen: false,
  ).getTotalMainRevenueReceipt(records, context);
  final discount = total - subtotal;

  builder.addLeftRight(
    'Subtotal:',
    formatMoneyMid(
      amount: subtotal,
      context: context,
      isR: true,
    ),
  );
  builder.addLeftRight(
    'Discount:',
    formatMoneyMid(
      amount: discount,
      context: context,
      isR: true,
    ),
  );
  builder.addLeftRight(
    'TOTAL:',
    formatMoneyMid(
      amount: total,
      context: context,
      isR: true,
    ),
    bold: true,
  );

  builder.addBlank();
  builder.addTextMiddle('Thanks for shopping with us!');
  builder.addBlank();
  builder.addBlank();

  return builder.build();
}

class ReceiptBuilder {
  final StringBuffer _buffer = StringBuffer();
  final int lineWidth;

  ReceiptBuilder({this.lineWidth = 32});

  void addTitle(String text) {
    _buffer.write(
      String.fromCharCodes([0x1B, 0x21, 0x08]),
    ); // bold + big
    _buffer.write(String.fromCharCodes([0x1B, 0x61, 0x01]));
    _buffer.writeln(text.toUpperCase());
    _buffer.write(
      String.fromCharCodes([0x1B, 0x21, 0x00]),
    ); // reset
  }

  void addTextMiddle(String text) {
    _buffer.write(String.fromCharCodes([0x1B, 0x61, 0x01]));
    _buffer.writeln(text);
    _buffer.write(String.fromCharCodes([0x1B, 0x61, 0x00]));
  }

  void addTextBold(String text) {
    _buffer.write(String.fromCharCodes([0x1B, 0x45, 0x01]));
    _buffer.writeln(text);
    _buffer.write(String.fromCharCodes([0x1B, 0x45, 0x00]));
  }

  void addText(String text) {
    _buffer.writeln(text);
  }

  void addSeparator() {
    _buffer.writeln('-' * lineWidth);
  }

  void addRowStyled(
    String left,
    String middle,
    String right, {
    bool rightBold = false,
  }) {
    final spaceBetween =
        4; // padding around center quantity
    final leftMax = 12;
    final middleMax = 6;
    final rightMax =
        lineWidth - leftMax - middleMax - spaceBetween;

    final l =
        left.length > leftMax
            ? left.substring(0, leftMax)
            : left.padRight(leftMax);
    final m =
        middle.length > middleMax
            ? middle.substring(0, middleMax)
            : middle
                .padLeft((middleMax + spaceBetween ~/ 2))
                .padRight(middleMax + spaceBetween);
    final r =
        right.length > rightMax
            ? right.substring(0, rightMax)
            : right.padLeft(rightMax);

    if (rightBold)
      // ignore: curly_braces_in_flow_control_structures
      _buffer.write(
        String.fromCharCodes([0x1B, 0x21, 0x08]),
      );
    _buffer.writeln('$l$m$r');
    if (rightBold)
      // ignore: curly_braces_in_flow_control_structures
      _buffer.write(
        String.fromCharCodes([0x1B, 0x21, 0x00]),
      );
  }

  void addLeftRight(
    String label,
    String value, {
    bool bold = false,
  }) {
    if (bold)
      // ignore: curly_braces_in_flow_control_structures
      _buffer.write(
        String.fromCharCodes([0x1B, 0x21, 0x08]),
      ); // Bold

    final l = label.padRight(16);
    final r = value.padLeft(lineWidth - 16);
    _buffer.writeln('$l$r');

    if (bold)
      // ignore: curly_braces_in_flow_control_structures
      _buffer.write(
        String.fromCharCodes([0x1B, 0x21, 0x00]),
      );
  }

  void addBlank() => _buffer.writeln();

  Uint8List build() =>
      Uint8List.fromList(utf8.encode(_buffer.toString()));
}
