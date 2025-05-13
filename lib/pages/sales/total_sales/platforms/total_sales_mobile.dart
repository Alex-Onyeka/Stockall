import 'package:flutter/material.dart';
import 'package:stockitt/components/calendar/calendar_widget.dart';
import 'package:stockitt/components/list_tiles/main_receipt_tile.dart';
import 'package:stockitt/components/major/empty_widget_display.dart';
import 'package:stockitt/constants/constants_main.dart';
import 'package:stockitt/main.dart';

class TotalSalesMobile extends StatefulWidget {
  const TotalSalesMobile({super.key});

  @override
  State<TotalSalesMobile> createState() =>
      _TotalSalesMobileState();
}

class _TotalSalesMobileState
    extends State<TotalSalesMobile> {
  bool listEmpty = false;
  @override
  Widget build(BuildContext context) {
    var receiptProvider = returnReceiptProvider(context);
    var receipts = receiptProvider
        .returnOwnReceiptsByDayOrWeek(context);
    var theme = returnTheme(context);
    return GestureDetector(
      onTap: () {
        returnReceiptProvider(
          context,
          listen: false,
        ).clearReceiptDate();
      },
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 60,
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Padding(
              padding: const EdgeInsets.only(
                left: 20.0,
                right: 10,
              ),
              child: Icon(Icons.arrow_back_ios_new_rounded),
            ),
          ),
          centerTitle: true,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    listEmpty = !listEmpty;
                  });
                },
                child: Text(
                  style: TextStyle(
                    fontSize: theme.mobileTexts.h4.fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                  returnReceiptProvider(context).dateSet ??
                      'Todays Sales Receipts',
                ),
              ),
            ],
          ),
        ),
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.end,
                    children: [
                      MaterialButton(
                        onPressed: () {
                          if (returnReceiptProvider(
                                context,
                                listen: false,
                              ).isDateSet ||
                              returnReceiptProvider(
                                context,
                                listen: false,
                              ).setDate) {
                            returnReceiptProvider(
                              context,
                              listen: false,
                            ).clearReceiptDate();
                          } else {
                            returnReceiptProvider(
                              context,
                              listen: false,
                            ).openDatePicker();
                          }
                        },
                        child: Row(
                          spacing: 3,
                          children: [
                            Text(
                              style: TextStyle(
                                fontSize:
                                    theme
                                        .mobileTexts
                                        .b2
                                        .fontSize,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade700,
                              ),
                              receiptProvider.isDateSet ||
                                      receiptProvider
                                          .setDate
                                  ? 'Clear Date'
                                  : 'Set Date',
                            ),
                            Icon(
                              size: 20,
                              color:
                                  theme
                                      .lightModeColor
                                      .secColor100,
                              receiptProvider.isDateSet ||
                                      receiptProvider
                                          .setDate
                                  ? Icons.clear
                                  : Icons
                                      .date_range_outlined,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        if (receipts.isEmpty) {
                          return EmptyWidgetDisplay(
                            title: 'title',
                            subText: 'subText',
                            buttonText: 'buttonText',
                            svg: productIconSvg,
                            theme: theme,
                            height: 40,
                          );
                        } else {
                          return ListView.builder(
                            itemCount: receipts.length,
                            itemBuilder: (context, index) {
                              var receipt = receipts[index];
                              return MainReceiptTile(
                                mainReceipt: receipt,
                              );
                            },
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            if (returnReceiptProvider(context).setDate)
              Positioned(
                top: 40,
                left: 0,
                right: 0,
                child: Material(
                  child: Ink(
                    color: Colors.white,
                    child: Container(
                      padding: EdgeInsets.only(
                        top: 40,
                        bottom: 40,
                      ),
                      color: Colors.white,
                      child: Center(
                        child: Padding(
                          padding:
                              const EdgeInsets.symmetric(
                                horizontal: 15.0,
                              ),
                          child: Container(
                            height: 430,
                            width: 380,
                            padding: EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(10),
                              color: Colors.white,
                              border: Border.all(
                                color: Colors.grey,
                              ),
                            ),
                            child: CalendarWidget(
                              onDaySelected: (
                                selectedDay,
                                focusedDay,
                              ) {
                                returnReceiptProvider(
                                  context,
                                  listen: false,
                                ).setReceiptDay(
                                  selectedDay,
                                );
                              },
                              actionWeek: (
                                startOfWeek,
                                endOfWeek,
                              ) {
                                returnReceiptProvider(
                                  context,
                                  listen: false,
                                ).setReceiptWeek(
                                  startOfWeek,
                                  endOfWeek,
                                );
                              },
                            ),
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
    );
  }
}
