import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:bluetooth_print_plus/bluetooth_print_plus.dart';
import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_main_receipt/temp_main_receipt.dart';
import 'package:stockall/classes/temp_product_slaes_record/temp_product_sale_record.dart';
import 'package:stockall/classes/temp_shop/temp_shop_class.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/main.dart';

class BluetoothDevicesPage extends StatefulWidget {
  final TempMainReceipt receipt;
  final List<TempProductSaleRecord> records;
  final TempShopClass shop;
  const BluetoothDevicesPage({
    super.key,
    required this.receipt,
    required this.records,
    required this.shop,
  });

  @override
  State<BluetoothDevicesPage> createState() =>
      _BluetoothDevicesPageState();
}

class _BluetoothDevicesPageState
    extends State<BluetoothDevicesPage> {
  BluetoothDevice? _device;
  late StreamSubscription<bool> _isScanningSubscription;
  late StreamSubscription<BlueState> _blueStateSubscription;
  late StreamSubscription<ConnectState>
  _connectStateSubscription;
  late StreamSubscription<Uint8List>
  _receivedDataSubscription;
  late StreamSubscription<List<BluetoothDevice>>
  _scanResultsSubscription;
  List<BluetoothDevice> _scanResults = [];

  Widget buildBlueOffWidget() {
    return Center(
      child: Text(
        "Bluetooth is turned off\nPlease turn on Bluetooth...",
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 16,
          color: Colors.red,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget buildScanButton(BuildContext context) {
    if (BluetoothPrintPlus.isScanningNow) {
      return FloatingActionButton(
        onPressed: onStopPressed,
        backgroundColor: Colors.red,
        child: Icon(Icons.stop),
      );
    } else {
      return FloatingActionButton(
        onPressed: onScanPressed,
        backgroundColor: Colors.green,
        child: Text("SCAN"),
      );
    }
  }

  Future onScanPressed() async {
    try {
      await BluetoothPrintPlus.startScan(
        timeout: Duration(seconds: 10),
      );
    } catch (e) {
      print("onScanPressed error: $e");
    }
  }

  Future onStopPressed() async {
    try {
      BluetoothPrintPlus.stopScan();
    } catch (e) {
      print("onStopPressed error: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    initBluetoothPrintPlusListen();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_scanResults.isEmpty) {
        onScanPressed();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _isScanningSubscription.cancel();
    _blueStateSubscription.cancel();
    _connectStateSubscription.cancel();
    _receivedDataSubscription.cancel();
    _scanResultsSubscription.cancel();
    _scanResults.clear();
  }

  Future<void> initBluetoothPrintPlusListen() async {
    /// listen scanResults
    _scanResultsSubscription = BluetoothPrintPlus
        .scanResults
        .listen((event) {
          if (mounted) {
            setState(() {
              _scanResults = event;
            });
          }
        });

    /// listen isScanning
    _isScanningSubscription = BluetoothPrintPlus.isScanning
        .listen((event) {
          print('********** isScanning: $event **********');
          if (mounted) {
            setState(() {});
          }
        });

    /// listen blue state
    _blueStateSubscription = BluetoothPrintPlus.blueState
        .listen((event) {
          print(
            '********** blueState change: $event **********',
          );
          if (mounted) {
            setState(() {});
          }
        });

    /// listen connect state
    _connectStateSubscription = BluetoothPrintPlus
        .connectState
        .listen((event) {
          print(
            '********** connectState change: $event **********',
          );
          switch (event) {
            case ConnectState.connected:
              setState(() {
                if (_device == null) return;
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder:
                //         (context) => FunctionPage(_device!),
                //   ),
                // );
              });
              break;
            case ConnectState.disconnected:
              setState(() {
                _device = null;
              });
              break;
          }
        });

    /// listen received data
    _receivedDataSubscription = BluetoothPrintPlus
        .receivedData
        .listen((data) {
          print(
            '********** received data: $data **********',
          );

          /// do something...
        });
  }

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Material(
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
                MediaQuery.of(context).size.height - 200,
            width: 300,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Opacity(
                      opacity: 0,
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        child: Icon(size: 18, Icons.clear),
                      ),
                    ),
                    Text(
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.h4.fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                      'Available Devices',
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(
                          30,
                        ),
                        onTap: () {
                          Navigator.of(context).pop();
                        },
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
                    ),
                  ],
                ),

                Divider(
                  color: Colors.grey.shade400,
                  height: 30,
                ),
                Builder(
                  builder: (context) {
                    if (_scanResults.isEmpty) {
                      return Expanded(
                        child: Center(
                          child: Column(
                            spacing: 10,
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [
                              Icon(
                                size: 25,
                                Icons
                                    .print_disabled_rounded,
                              ),
                              InkWell(
                                onTap: onScanPressed,
                                child: Text(
                                  style: TextStyle(
                                    fontWeight:
                                        FontWeight.bold,
                                    fontSize:
                                        theme
                                            .mobileTexts
                                            .h4
                                            .fontSize,
                                  ),
                                  'No Printer Found',
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    } else {
                      return Expanded(
                        child: ListView(
                          children:
                              _scanResults
                                  .map(
                                    (device) => Material(
                                      color:
                                          Colors
                                              .transparent,
                                      child: ListTile(
                                        contentPadding:
                                            EdgeInsets.symmetric(
                                              vertical: 5,
                                              horizontal:
                                                  10,
                                            ),
                                        shape: Border(
                                          top: BorderSide(
                                            color:
                                                Colors
                                                    .grey
                                                    .shade200,
                                          ),
                                        ),
                                        title: Row(
                                          spacing: 10,
                                          children: [
                                            Icon(
                                              size: 17,
                                              Icons
                                                  .bluetooth,
                                            ),
                                            Flexible(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment
                                                        .start,
                                                spacing: 5,
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
                                                    device
                                                        .name,
                                                  ),
                                                  Text(
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize:
                                                          theme.mobileTexts.b4.fontSize,
                                                    ),
                                                    device
                                                        .address,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        onTap: () async {
                                          await BluetoothPrintPlus.connect(
                                            device,
                                          );
                                          connectToPrinter(
                                            safeContext:
                                                context,
                                            receipt:
                                                widget
                                                    .receipt,
                                            records:
                                                widget
                                                    .records,
                                            shop:
                                                widget.shop,
                                          );
                                          // Navigator.pop(
                                          //   context,
                                          // );
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
    );
  }
}

void scanBluetoothPrinters({
  required TempMainReceipt receipt,
  required List<TempProductSaleRecord> records,
  required TempShopClass shop,
  required BuildContext context,
}) async {
  print('Main Bluetooth Scanning Started');
  if (BluetoothPrintPlus.isConnected) {
    connectToPrinter(
      safeContext: context,
      receipt: receipt,
      records: records,
      shop: shop,
    );
  } else {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return BluetoothDevicesPage(
          receipt: receipt,
          records: records,
          shop: shop,
        );
      },
    ).then((_) {
      if (context.mounted) {
        returnReceiptProvider(
          context,
          listen: false,
        ).toggleIsLoading(false);
      }
    });
  }
}

void connectToPrinter({
  // UsbDevice? device,
  required BuildContext safeContext,
  required TempMainReceipt receipt,
  required List<TempProductSaleRecord> records,
  required TempShopClass shop,
}) async {
  if (safeContext.mounted) {
    final data = generateStyledReceipt(
      receipt: receipt,
      records: records,
      shop: shop,
      context: safeContext,
    );
    // final data = Uint8List.fromList(
    //   "Hello StockAll App!\n".codeUnits,
    // );
    await BluetoothPrintPlus.write(data);
    // await sendReceiptInChunks(data: data);
  }

  if (safeContext.mounted) {
    returnReceiptProvider(
      safeContext,
      listen: false,
    ).toggleIsLoading(false);
  }
}

// Future<void> sendReceiptInChunks({
//   required Uint8List data,
//   int chunkSize = 240,
// }) async {
//   int offset = 0;

//   while (offset < data.length) {
//     final end =
//         (offset + chunkSize < data.length)
//             ? offset + chunkSize
//             : data.length;

//     final chunk = data.sublist(offset, end);

//     await BluetoothPrintPlus.write(chunk);

//     offset = end;
//     await Future.delayed(Duration(milliseconds: 50));
//   }

//   print('✅ Finished sending receipt in chunks.');
// }

Uint8List generateStyledReceipt({
  required TempMainReceipt receipt,
  required List<TempProductSaleRecord> records,
  required TempShopClass shop,
  required BuildContext context,
}) {
  final builder = ReceiptBuilder();
  builder.addBlank();
  builder.addTitle(shop.name);
  builder.addTextMiddle(shop.email ?? 'Email Not Set');
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
        amount: item.originalCost ?? 0,
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
  ).getOriginalCostReceipt(receipt);
  final total = returnReceiptProvider(
    context,
    listen: false,
  ).getTotalMainRevenueReceipt(receipt);
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
    receipt.generalDiscount != null
        ? "Discount: (${receipt.generalDiscount}%)"
        : 'Discount:',
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
