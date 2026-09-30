import 'package:flutter/material.dart';
import 'package:stockall/main.dart';
import 'package:stockall/services/barcode_generation/barcode_import_helper.dart';

class PrinterListWidget extends StatefulWidget {
  const PrinterListWidget({super.key});

  @override
  State<PrinterListWidget> createState() =>
      _PrinterListWidgetState();
}

class _PrinterListWidgetState
    extends State<PrinterListWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      listPrinters();
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context, listen: false);
    return Scaffold(
      body: Container(
        // width: 300,
        // height: 600,
        padding: EdgeInsets.symmetric(
          vertical: 20,
          horizontal: 20,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: Colors.grey.shade200,
        ),
        child: Column(
          spacing: 10,
          children: [
            Row(
              spacing: 5,
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                Opacity(
                  opacity: 0,
                  child: IconButton(
                    mouseCursor: SystemMouseCursors.click,
                    onPressed: () {},
                    icon: Icon(size: 18, Icons.refresh),
                  ),
                ),
                Text(
                  style: TextStyle(
                    fontSize: theme.mobileTexts.b1.fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                  'Avalaible Printers',
                ),
                IconButton(
                  mouseCursor: SystemMouseCursors.click,
                  onPressed: () {
                    listPrinters();
                  },
                  icon: Icon(size: 18, Icons.refresh),
                ),
              ],
            ),
            Container(
              height: 2.5,
              width: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: theme.lightModeColor.secColor200,
              ),
            ),
            Visibility(
              visible:
                  returnShopProvider(
                    context: context,
                  ).printerCache !=
                  null,
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 15,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        5,
                      ),
                      color: Color.fromARGB(
                        200,
                        255,
                        255,
                        255,
                      ),
                    ),
                    child: Row(
                      children: [
                        SizedBox(width: 3),
                        Expanded(
                          child: Column(
                            spacing: 2,
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                style: TextStyle(
                                  fontSize:
                                      theme
                                          .mobileTexts
                                          .b3
                                          .fontSize,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                                returnShopProvider(
                                      context: context,
                                    ).printerCache?.name ??
                                    'Name',
                              ),
                              Text(
                                style: TextStyle(
                                  fontSize:
                                      theme
                                          .mobileTexts
                                          .b3
                                          .fontSize,

                                  fontWeight:
                                      FontWeight.normal,
                                ),
                                returnShopProvider(
                                          context: context,
                                        )
                                        .printerCache
                                        ?.driverName ??
                                    'Driver Name',
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          color:
                              theme
                                  .lightModeColor
                                  .secColor200,
                          size: 16,
                          Icons.check,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 15),
                  Divider(height: 10),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                children:
                    returnShopProvider(context: context)
                        .printers
                        .where(
                          (print) =>
                              print.name !=
                              returnShopProvider(
                                context: context,
                              ).printerCache?.name,
                        )
                        .map(
                          (printer) => Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 3,
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: Ink(
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.circular(
                                        5,
                                      ),
                                  color: Color.fromARGB(
                                    110,
                                    255,
                                    255,
                                    255,
                                  ),
                                ),
                                child: InkWell(
                                  mouseCursor:
                                      SystemMouseCursors
                                          .click,
                                  borderRadius:
                                      BorderRadius.circular(
                                        5,
                                      ),
                                  onTap: () async {
                                    await returnShopProvider()
                                        .selectPrinter(
                                          printer,
                                          context,
                                        );
                                    setState(() {});
                                  },
                                  child: Container(
                                    padding:
                                        EdgeInsets.symmetric(
                                          vertical: 12,
                                          horizontal: 15,
                                        ),

                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            spacing: 2,
                                            crossAxisAlignment:
                                                CrossAxisAlignment
                                                    .start,
                                            children: [
                                              Text(
                                                style: TextStyle(
                                                  fontSize:
                                                      theme
                                                          .mobileTexts
                                                          .b4
                                                          .fontSize,
                                                  fontWeight:
                                                      FontWeight
                                                          .bold,
                                                ),
                                                printer
                                                    .name,
                                              ),
                                              Text(
                                                style: TextStyle(
                                                  fontSize:
                                                      theme
                                                          .mobileTexts
                                                          .b4
                                                          .fontSize,
                                                  fontWeight:
                                                      FontWeight
                                                          .normal,
                                                ),
                                                printer
                                                    .driverName,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
