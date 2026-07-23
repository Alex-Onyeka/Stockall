import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:bluetooth_print_plus/bluetooth_print_plus.dart';
import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_invoices/temp_invoices.dart';
import 'package:stockall/classes/temp_main_receipt/temp_main_receipt.dart';
import 'package:stockall/classes/temp_product_slaes_record/temp_product_sale_record.dart';
import 'package:stockall/classes/temp_shop/temp_shop_class.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/generate_barcode.dart';
import 'package:stockall/main.dart';
import 'package:stockall/providers/pos_printer/device_service.dart';

class BluetoothDevicesPage extends StatefulWidget {
  const BluetoothDevicesPage({super.key});

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
        backgroundColor: Colors.grey.shade300,
        child: Icon(Icons.stop),
      );
    } else {
      return FloatingActionButton(
        onPressed: onScanPressed,
        backgroundColor: Colors.grey,
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
    print(BluetoothPrintPlus.isBlueOn);
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
      color: Colors.transparent,
      child: Builder(
        builder: (context) {
          if (BluetoothPrintPlus.isBlueOn) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    20,
                    20,
                    15,
                  ),
                  height:
                      MediaQuery.of(context).size.height -
                      200,
                  width: 300,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                  child: Stack(
                    children: [
                      Column(
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
                              Text(
                                style: TextStyle(
                                  fontSize:
                                      theme
                                          .mobileTexts
                                          .h4
                                          .fontSize,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                                'Available Devices',
                              ),
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  mouseCursor:
                                      SystemMouseCursors
                                          .click,
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
                                      15,
                                    ),
                                    decoration:
                                        BoxDecoration(
                                          shape:
                                              BoxShape
                                                  .circle,
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
                                        InkWell(
                                          mouseCursor:
                                              SystemMouseCursors
                                                  .click,
                                          onTap:
                                              onScanPressed,
                                          child: Text(
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
                                              (
                                                device,
                                              ) => Padding(
                                                padding:
                                                    const EdgeInsets.only(
                                                      top:
                                                          5.0,
                                                    ),
                                                child: Material(
                                                  color:
                                                      Colors
                                                          .transparent,
                                                  child: ListTile(
                                                    tileColor:
                                                        Colors.grey.shade100,
                                                    contentPadding: EdgeInsets.symmetric(
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
                                                        Builder(
                                                          builder: (
                                                            context,
                                                          ) {
                                                            if (device.type ==
                                                                3) {
                                                              return Icon(
                                                                size:
                                                                    17,
                                                                Icons.print_rounded,
                                                              );
                                                            } else {
                                                              return Icon(
                                                                size:
                                                                    17,
                                                                Icons.device_hub_outlined,
                                                              );
                                                            }
                                                          },
                                                        ),
                                                        Flexible(
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment.start,
                                                            spacing:
                                                                2,
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
                                                                device.name,
                                                              ),
                                                              Text(
                                                                style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight.bold,
                                                                  fontSize:
                                                                      theme.mobileTexts.b4.fontSize,
                                                                ),
                                                                device.address,
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
                                                      Navigator.pop(
                                                        context,
                                                      );
                                                    },
                                                  ),
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
                      Align(
                        alignment: AlignmentGeometry.xy(
                          1,
                          1,
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: Ink(
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(5),
                              color: Colors.grey.shade200,
                            ),
                            child: InkWell(
                              mouseCursor:
                                  SystemMouseCursors.click,
                              borderRadius:
                                  BorderRadius.circular(5),
                              onTap: () {
                                if (BluetoothPrintPlus
                                    .isScanningNow) {
                                  onStopPressed();
                                } else {
                                  onScanPressed();
                                }
                              },
                              child: Container(
                                height: 50,
                                width: 50,
                                padding: EdgeInsets.all(10),
                                child: Center(
                                  child: Builder(
                                    builder: (context) {
                                      if (BluetoothPrintPlus
                                          .isScanningNow) {
                                        return SizedBox(
                                          height: 18,
                                          width: 18,
                                          child: CircularProgressIndicator(
                                            color:
                                                Colors
                                                    .grey
                                                    .shade600,
                                            strokeWidth: 3,
                                          ),
                                        );
                                      } else {
                                        return Icon(
                                          size: 22,
                                          color:
                                              Colors
                                                  .grey
                                                  .shade800,
                                          Icons.refresh,
                                        );
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          } else {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    20,
                    20,
                    15,
                  ),
                  height:
                      MediaQuery.of(context).size.height -
                      200,
                  width: 300,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      spacing: 12,
                      children: [
                        Icon(
                          size: 35,
                          color: Colors.grey,
                          Icons.bluetooth_disabled,
                        ),
                        Text(
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize:
                                theme
                                    .mobileTexts
                                    .b2
                                    .fontSize,
                            fontWeight: FontWeight.bold,
                          ),
                          'Bluetooth Is Not Turned On',
                        ),
                        Material(
                          color: Colors.transparent,
                          child: Ink(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                            ),
                            child: InkWell(
                              mouseCursor:
                                  SystemMouseCursors.click,
                              borderRadius:
                                  BorderRadius.circular(4),
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                              child: Container(
                                width: 150,
                                padding:
                                    EdgeInsetsGeometry.all(
                                      10,
                                    ),
                                child: Center(
                                  child: Text(
                                    style: TextStyle(
                                      fontSize:
                                          theme
                                              .mobileTexts
                                              .b4
                                              .fontSize,
                                      fontWeight:
                                          FontWeight.bold,
                                      color:
                                          theme
                                              .lightModeColor
                                              .secColor200,
                                    ),
                                    'Cancel',
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
        },
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
        return BluetoothDevicesPage();
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
    await BluetoothPrintPlus.write(data);
  }

  if (safeContext.mounted) {
    returnReceiptProvider(
      safeContext,
      listen: false,
    ).toggleIsLoading(false);
  }
}

Uint8List generateStyledReceipt({
  required TempMainReceipt receipt,
  required List<TempProductSaleRecord> records,
  required TempShopClass shop,
  required BuildContext context,
}) {
  final builder = ReceiptBuilder();
  if (!DeviceService.isPos) {
    builder.addBlank();
  }

  builder.addTextMiddle('#Shop ID: ${shopRef()}');

  builder.addTitle(shop.name);

  if (shop.showEmail!) {
    builder.addTextMiddle(shop.email ?? 'Email Not Set');
  }

  if (shop.showPhone!) {
    builder.addTextMiddle(shop.phoneNumber!);
  }

  if (shop.showAddress!) {
    builder.addTextMiddle(
      shop.shopAddress ?? 'Address Not Set',
    );
  }

  if (shop.showFacebookTop!) {
    builder.addTextMiddle(
      shop.faceBookHandle ?? 'Facebook Not Set',
    );
  }

  if (shop.showInstaTop!) {
    builder.addTextMiddle(
      shop.instaHandle ?? 'Instagram Not Set',
    );
  }

  builder.addSeparator();

  if (shop.showFirst!) {
    builder.addTextMiddle("Staff: ${receipt.staffName}");
  }

  if (shop.showSecond! && receipt.customerName != null) {
    builder.addTextMiddle(
      "Customer: ${receipt.customerName ?? 'Customer Not Set'}",
    );
  }
  builder.addTextMiddle(
    'Date: ${formatDateTime(receipt.createdAt)} | ${formatTime(receipt.createdAt)}',
  );
  if (shop.showFirst!) {
    builder.addTextMiddle(
      "Ticket Id: ${receipt.barcode ?? returnOnlyDigits(receipt.uuid ?? '')}",
    );
  }

  builder.addSeparator();
  builder.addTextMiddle('Payment Receipt');
  builder.addSeparator();
  // builder.addBlank();
  // builder.addTextBold('Items:'.toUpperCase());
  builder.addRowStyled(
    'Items:'.toUpperCase(),
    'Qty',
    'Price',
    rightBold: true,
  );

  if (!DeviceService.isPos) {
    builder.addSmallSpace(10);
  }

  for (final item in records) {
    builder.addRowStyled(
      item.productName,
      formatLargeNumberDouble(item.quantity),
      formatMoneyMid(
        amount:
            (receipt.fixedDiscount == null &&
                        receipt.generalDiscount == null) &&
                    item.discount != null
                ? ((item.originalCost ?? 0) -
                    (item.discountedAmount ?? 0))
                : (item.originalCost ?? 0),
        context: context,
        isR: true,
      ).split('.').first,
      rightBold: false,
    );
    if (!DeviceService.isPos) {
      builder.addSmallSpace(5);
    }
  }
  // builder.addBlank();
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
  final discount = returnReceiptProvider(
    context,
    listen: false,
  ).getDiscountAmountForReceipt(receipt);

  builder.addLeftRight(
    'Subtotal:',
    formatMoneyMid(
      amount: subtotal,
      context: context,
      isR: true,
    ),
  );
  if (receipt.fixedDiscount != null ||
      receipt.generalDiscount != null) {
    builder.addLeftRight(
      receipt.generalDiscount != null
          ? "Discount: [${receipt.generalDiscount}%]"
          : 'Discount:',
      formatMoneyMid(
        amount: discount,
        context: context,
        isR: true,
      ),
    );
  }

  if (receipt.vat != null) {
    builder.addLeftRight(
      "VAT: [${receipt.vat ?? 0}%]",
      formatMoneyMid(
        amount: returnReceiptProvider(
          context,
          listen: false,
        ).getVATForReceipt(receipt),
        context: context,
        isR: true,
      ),
    );
  }

  if (receipt.balance != null) {
    builder.addLeftRight(
      "Balance:",
      formatMoneyMid(
        amount: (receipt.balance ?? 0),
        context: context,
        isR: true,
      ),
    );
  }

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

  final barcode =
      receipt.barcode ??
      returnOnlyDigits(receipt.uuid ?? '');

  builder.addBarcode(barcode);

  builder.addTextMiddle(
    'Created by $appName Solutions - ( www.stockallapp.com )',
  );
  builder.addBlank();
  builder.addBlank();
  if (DeviceService.isPos) {
    builder.addBlank();
  }

  return builder.build();
}

class ReceiptBuilder {
  final StringBuffer _buffer = StringBuffer();
  final int lineWidth;

  ReceiptBuilder({this.lineWidth = 32});

  void addTitle(String text) {
    // Center align
    _buffer.write(String.fromCharCodes([0x1B, 0x61, 0x01]));

    // Bold ON
    _buffer.write(String.fromCharCodes([0x1B, 0x45, 0x01]));

    // Double width (not height)
    _buffer.write(String.fromCharCodes([0x1D, 0x21, 0x30]));

    _buffer.writeln(text.toUpperCase());

    // Reset size
    _buffer.write(String.fromCharCodes([0x1D, 0x21, 0x00]));

    // Bold OFF
    _buffer.write(String.fromCharCodes([0x1B, 0x45, 0x00]));

    // _buffer.writeln(""); // spacing
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
    final leftMax = 15;
    final middleMax = 4;
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
  void addSmallSpace([int dots = 10]) {
    _buffer.write(String.fromCharCodes([0x1B, 0x4A, dots]));
  }

  void addBarcode(String data) {
    final clean = data.replaceAll(RegExp(r'\D'), '');

    final ean =
        clean.length >= 12
            ? clean.substring(0, 12)
            : clean.padLeft(12, '0');

    // Center align
    _buffer.write(String.fromCharCodes([0x1B, 0x61, 0x01]));

    // Shorter barcode height
    _buffer.write(String.fromCharCodes([0x1D, 0x68, 60]));

    // Wider bars (better scanning)
    _buffer.write(String.fromCharCodes([0x1D, 0x77, 3]));

    // HRI text BELOW barcode
    _buffer.write(String.fromCharCodes([0x1D, 0x48, 0x02]));

    // EAN13 mode
    _buffer.write(String.fromCharCodes([0x1D, 0x6B, 0x43]));

    // 12-digit requirement
    _buffer.writeCharCode(12);

    _buffer.write(ean);

    _buffer.writeln();

    // Reset alignment
    _buffer.write(String.fromCharCodes([0x1B, 0x61, 0x00]));
  }

  Uint8List build() =>
      Uint8List.fromList(utf8.encode(_buffer.toString()));
}

//
//
//
//
//
//
//
//
//
//
//
//
////////////////////////////////////////////////////////////////////////////////////
// INVOICE PRINTING

void scanBluetoothPrintersinvoice({
  required TempInvoice invoice,
  required List<TempProductSaleRecord> records,
  required TempShopClass shop,
  required BuildContext context,
}) async {
  print('Main Bluetooth Scanning Started');
  if (BluetoothPrintPlus.isConnected) {
    connectToPrinterInvoice(
      safeContext: context,
      // receipt: receipt,
      invoice: invoice,
      records: records,
      shop: shop,
    );
  } else {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return BluetoothDevicesPage();
      },
    );
  }
}

void connectToPrinterInvoice({
  required BuildContext safeContext,
  required TempInvoice invoice,
  required List<TempProductSaleRecord> records,
  required TempShopClass shop,
}) async {
  if (safeContext.mounted) {
    final data = generateStyledInvoice(
      invoice: invoice,
      records: records,
      shop: shop,
      context: safeContext,
    );
    await BluetoothPrintPlus.write(data);
  }
}

Uint8List generateStyledInvoice({
  // required TempMainReceipt receipt,
  required TempInvoice invoice,
  required List<TempProductSaleRecord> records,
  required TempShopClass shop,
  required BuildContext context,
}) {
  final builder = ReceiptBuilder();

  if (!DeviceService.isPos) {
    builder.addBlank();
  }

  builder.addTextMiddle('#Shop ID: ${shopRef()}');

  if (shop.showShopName!) {
    builder.addTitle(shop.name);
  }

  if (shop.showEmail!) {
    builder.addTextMiddle(shop.email ?? 'Email Not Set');
  }

  if (shop.showPhone!) {
    builder.addTextMiddle(shop.phoneNumber!);
  }

  if (shop.showAddress!) {
    builder.addTextMiddle(
      shop.shopAddress ?? 'Address Not Set',
    );
  }

  if (shop.showFacebookTop!) {
    builder.addTextMiddle(
      shop.faceBookHandle ?? 'Facebook Not Set',
    );
  }

  if (shop.showInstaTop!) {
    builder.addTextMiddle(
      shop.instaHandle ?? 'Instagram Not Set',
    );
  }

  builder.addSeparator();

  if (shop.showFirst!) {
    builder.addTextMiddle("Staff: ${invoice.staffName}");
  }

  if (shop.showSecond! && invoice.customerName != null) {
    builder.addTextMiddle(
      "Customer: ${invoice.customerName ?? 'Customer Not Set'}",
    );
  }
  builder.addTextMiddle(
    'Date: ${formatDateTime(invoice.createdAt)} | ${formatTime(invoice.createdAt)}',
  );
  if (shop.showFirst!) {
    builder.addTextMiddle(
      "Ticket Id: ${invoice.barcode ?? returnOnlyDigits(invoice.uuid ?? '')}",
    );
  }

  builder.addSeparator();

  if (returnInvoicesProvider().getBalance(
        invoice: invoice,
      ) !=
      0) {
    builder.addTextMiddle('Invoice Receipt');
  } else {
    builder.addTextMiddle('PAID INVOICE');
  }
  builder.addSeparator();
  builder.addBlank();
  builder.addTextBold('Items:'.toUpperCase());

  if (!DeviceService.isPos) {
    builder.addSmallSpace(10);
  }

  for (final item in records) {
    builder.addRowStyled(
      item.productName,
      formatLargeNumberDouble(item.quantity),
      formatMoneyMid(
        amount:
            (invoice.fixedDiscount == null &&
                        invoice.generalDiscount == null) &&
                    item.discount != null
                ? ((item.originalCost ?? 0) -
                    (item.discountedAmount ?? 0))
                : (item.originalCost ?? 0),
        context: context,
        isR: true,
      ).split('.').first,
      rightBold: false,
    );

    if (!DeviceService.isPos) {
      builder.addSmallSpace(5);
    }
  }
  builder.addBlank();
  builder.addSeparator();
  builder.addBlank();
  final subtotal = returnInvoicesProvider()
      .getOriginalCostInvoice(invoice);
  final total = returnInvoicesProvider()
      .getTotalMainRevenueInvoice(invoice: invoice);
  final discount = returnInvoicesProvider()
      .getDiscountAmountForInvoice(invoice);

  builder.addLeftRight(
    'Subtotal:',
    formatMoneyMid(
      amount: subtotal,
      context: context,
      isR: true,
    ),
  );
  if (invoice.fixedDiscount != null ||
      invoice.generalDiscount != null) {
    builder.addLeftRight(
      invoice.generalDiscount != null
          ? "Discount: [${invoice.generalDiscount}%]"
          : 'Discount:',
      formatMoneyMid(
        amount: discount,
        context: context,
        isR: true,
      ),
    );
  }

  if (invoice.vat != null) {
    builder.addLeftRight(
      "VAT: [${invoice.vat ?? 0}%]",
      formatMoneyMid(
        amount: returnInvoicesProvider().getVATInvoice(
          invoice: invoice,
        ),
        context: context,
        isR: true,
      ),
    );
  }
  builder.addLeftRight(
    "Paid:",
    formatMoneyMid(
      amount: (returnInvoicesProvider().getAmountPaid(
        invoice: invoice,
      )),
      context: context,
      isR: true,
    ),
  );

  builder.addLeftRight(
    "Balance:",
    formatMoneyMid(
      amount: (returnInvoicesProvider().getBalance(
        invoice: invoice,
      )),
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

  final barcode =
      invoice.barcode ??
      returnOnlyDigits(invoice.uuid ?? '');

  builder.addBarcode(barcode);

  builder.addTextMiddle(
    'Created by $appName Solutions - ( www.stockallapp.com )',
  );
  builder.addBlank();
  builder.addBlank();
  if (DeviceService.isPos) {
    builder.addBlank();
  }

  return builder.build();
}
