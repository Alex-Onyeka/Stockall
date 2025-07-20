import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_thermal_printer/flutter_thermal_printer.dart';
import 'package:flutter_thermal_printer/utils/printer.dart';
import 'package:stockall/classes/temp_main_receipt.dart';
import 'package:stockall/classes/temp_product_sale_record.dart';
import 'package:stockall/classes/temp_shop_class.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/main.dart';

void scanBluetoothPrinters({
  required TempMainReceipt receipt,
  required List<TempProductSaleRecord> records,
  required TempShopClass shop,
  required BuildContext context,
}) {
  var safeContext = context;
  FlutterThermalPrinter.instance.getPrinters(
    connectionTypes: [
      ConnectionType.BLE,
      ConnectionType.USB,
    ],
  );

  late StreamSubscription<List<Printer>> subscription;

  subscription = FlutterThermalPrinter
      .instance
      .devicesStream
      .listen((List<Printer> printers) async {
        FlutterThermalPrinter.instance.stopScan();
        subscription.cancel();
        var printer = printers.first;
        var isConnected = await FlutterThermalPrinter
            .instance
            .connect(printers.first);
        if (isConnected == true && context.mounted) {
          // showDialog(
          //   context: context,
          //   builder: (context) {
          //     return InfoAlert(
          //       theme: returnTheme(context, listen: false),
          //       message:
          //           'Bluetooth: ${printer.name} already connected',
          //       title: 'Printer Already Connected',
          //     );
          //   },
          // );
          connectToPrinter(
            isConnected: true,
            printer: printer,
            safeContext: safeContext,
            receipt: receipt,
            records: records,
            shop: shop,
          );
          print(
            'Bluetooth: ${printer.name} already connected',
          );
          return;
        } else {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                backgroundColor: Colors.white,
                title: Text('Select Printer'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children:
                      printers
                          .map(
                            (printer) => ListTile(
                              title: Row(
                                children: [
                                  Icon(Icons.print),
                                  Text(
                                    style: TextStyle(
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                    printer.name ??
                                        'Unnamed',
                                  ),
                                ],
                              ),
                              subtitle: Text(
                                style: TextStyle(
                                  fontWeight:
                                      FontWeight.bold,
                                  fontSize: 10,
                                ),
                                printer.address ??
                                    'No Address',
                              ),
                              onTap: () {
                                Navigator.pop(context);
                                connectToPrinter(
                                  printer: printer,
                                  safeContext: safeContext,
                                  receipt: receipt,
                                  records: records,
                                  shop: shop,
                                );
                              },
                            ),
                          )
                          .toList(),
                ),
              );
            },
          );
        }
      });
}

void connectToPrinter({
  required Printer printer,
  required BuildContext safeContext,
  required TempMainReceipt receipt,
  required List<TempProductSaleRecord> records,
  required TempShopClass shop,
  bool? isConnected,
}) async {
  if (isConnected == null) {
    final result = await FlutterThermalPrinter.instance
        .connect(printer);
    print(
      result
          ? '✅ Connected to ${printer.name}'
          : '❌ Failed to connect',
    );
  }

  final data = generateStyledReceipt(
    receipt: receipt,
    records: records,
    shop: shop,
    context: safeContext,
  );

  await sendReceiptInChunks(data: data, printer: printer);
}

Future<void> sendReceiptInChunks({
  required Uint8List data,
  required Printer printer,
  int chunkSize = 240, // Safe under BLE MTU
}) async {
  int offset = 0;

  while (offset < data.length) {
    final end =
        (offset + chunkSize < data.length)
            ? offset + chunkSize
            : data.length;

    final chunk = data.sublist(offset, end);

    await FlutterThermalPrinter.instance.printData(
      printer,
      chunk,
      longData: true,
    );

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

  builder.addTitle(shop.name);
  builder.addText(shop.email);
  if (shop.phoneNumber != null) {
    builder.addText(shop.phoneNumber!);
  }
  builder.addBlank();
  builder.addText(
    receipt.isInvoice
        ? 'Generated Invoice'
        : 'Payment Receipt',
  );
  builder.addSeparator();

  builder.addText('Staff: ${receipt.staffName}');
  builder.addText(
    'Customer: ${receipt.customerName ?? 'Not Set'}',
  );

  if (!receipt.isInvoice) {
    builder.addText(
      'Payment Method: ${receipt.paymentMethod}',
    );
    builder.addText(
      'Cash: ${formatMoneyMid(amount: receipt.cashAlt, context: context, isR: true)}',
    );
    builder.addText(
      'Bank: ${formatMoneyMid(amount: receipt.bank, context: context, isR: true)}',
    );
  }

  builder.addText(
    'Date: ${formatDateTime(receipt.createdAt)}',
  );
  builder.addText('Time: ${formatTime(receipt.createdAt)}');
  builder.addSeparator();
  builder.addText('Items:');

  for (final item in records) {
    builder.addRow(
      item.productName,
      item.quantity.toStringAsFixed(0),
      formatMoneyMid(
        amount: item.revenue,
        context: context,
        isR: true,
      ),
    );
  }

  builder.addSeparator();

  final subtotal = returnReceiptProvider(
    context,
    listen: false,
  ).getSubTotalRevenueForReceipt(context, records);
  final total = returnReceiptProvider(
    context,
    listen: false,
  ).getTotalMainRevenueReceipt(records, context);
  final discount = total - subtotal;

  builder.addText(
    'Subtotal: ${formatMoneyMid(amount: subtotal, context: context, isR: true)}',
  );
  builder.addText(
    'Discount: ${formatMoneyMid(amount: discount, context: context, isR: true)}',
  );
  builder.addText(
    'Total:    ${formatMoneyMid(amount: total, context: context, isR: true)}',
  );
  builder.addBlank();
  builder.addText('Thanks for shopping with us!');

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
    _buffer.writeln(text.toUpperCase());
    _buffer.write(
      String.fromCharCodes([0x1B, 0x21, 0x00]),
    ); // reset
    _buffer.writeln();
  }

  void addText(String text) {
    _buffer.writeln(text);
  }

  void addSeparator() {
    _buffer.writeln('-' * lineWidth);
  }

  void addRow(String left, String middle, String right) {
    final l = left.padRight(12);
    final m = middle.padRight(6);
    final r = right.padLeft(
      lineWidth - l.length - m.length,
    );
    _buffer.writeln('$l$m$r');
  }

  void addBlank() => _buffer.writeln();

  Uint8List build() =>
      Uint8List.fromList(utf8.encode(_buffer.toString()));
}
