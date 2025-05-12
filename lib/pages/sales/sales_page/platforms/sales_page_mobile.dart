import 'package:flutter/material.dart';
import 'package:stockitt/classes/temp_main_receipt.dart';
import 'package:stockitt/components/list_tiles/main_receipt_tile.dart';
import 'package:stockitt/components/major/empty_widget_display.dart';
import 'package:stockitt/components/major/items_summary.dart';
import 'package:stockitt/components/major/top_banner.dart';
import 'package:stockitt/constants/constants_main.dart';
import 'package:stockitt/main.dart';
import 'package:stockitt/pages/dashboard/components/main_bottom_nav.dart';
import 'package:stockitt/pages/products/total_products/total_products_page.dart';
import 'package:stockitt/pages/sales/make_sales/page1/make_sales_page.dart';
// import 'package:table_calendar/table_calendar.dart';

class SalesPageMobile extends StatefulWidget {
  const SalesPageMobile({super.key});

  @override
  State<SalesPageMobile> createState() =>
      _SalesPageMobileState();
}

class _SalesPageMobileState extends State<SalesPageMobile> {
  bool listEmpty = false;
  bool setDate = false;
  bool isDateSet = false;

  // DateTime? selectedDay;
  // DateTime? focusedDay;

  @override
  Widget build(BuildContext context) {
    var mainReceipts = returnReceiptProvider(
      context,
      listen: true,
    ).returnOwnReceiptsByDayOrWeek(context);
    var theme = returnTheme(context);
    return Scaffold(
      bottomNavigationBar: MainBottomNav(),
      body: Stack(
        children: [
          Column(
            children: [
              Material(
                color: Colors.transparent,
                child: SizedBox(
                  height: 300,
                  child: Stack(
                    children: [
                      TopBanner(
                        subTitle:
                            'Data of All Sales Records',
                        title: 'Sales',
                        theme: theme,
                        bottomSpace: 100,
                        topSpace: 20,
                        iconSvg: salesIconSvg,
                      ),
                      Align(
                        alignment: Alignment(0, 1),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              listEmpty = !listEmpty;
                            });
                          },
                          child: ItemsSummary(
                            isFilter: true,
                            isMoney1: true,
                            mainTitle:
                                'Sales Record Summary',
                            subTitle: 'For Today',
                            firsRow: true,
                            color1: Colors.green,
                            title1: 'Sales Revenue',
                            value1: returnReceiptProvider(
                              context,
                            ).getTotalRevenueForSelectedDay(
                              context,
                            ),
                            color2: Colors.amber,
                            title2: 'Sales Number',
                            value2:
                                mainReceipts.length
                                    .toDouble(),
                            secondRow: false,
                            onSearch: false,
                            filterAction: () {
                              setState(() {
                                setDate = !setDate;
                              });
                              // if (isDateSet == false) {
                              //   returnReceiptProvider(
                              //     context,
                              //     listen: false,
                              //   ).setReceiptDay(
                              //     DateTime(2025, 5, 6),
                              //   );
                              //   setState(() {
                              //     isDateSet = true;
                              //   });
                              // } else {
                              //   returnReceiptProvider(
                              //     context,
                              //     listen: false,
                              //   ).clearReceiptDate();
                              //   setState(() {
                              //     isDateSet = false;
                              //   });
                              // }
                            },
                          ),
                        ),
                      ),
                      //
                    ],
                  ),
                ),
              ),
              Expanded(
                child: SizedBox(
                  child: Builder(
                    builder: (context) {
                      if (!listEmpty) {
                        return Center(
                          child: SingleChildScrollView(
                            child: EmptyWidgetDisplay(
                              buttonText: 'Make Sales',
                              subText:
                                  'Click on the button below to start adding Sales to your Record.',
                              title:
                                  'You have not Made Any Sales Yet',
                              svg: productIconSvg,
                              height: 35,
                              action: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return MakeSalesPage();
                                    },
                                  ),
                                );
                              },
                              theme: theme,
                            ),
                          ),
                        );
                      } else {
                        return Padding(
                          padding:
                              const EdgeInsets.fromLTRB(
                                10.0,
                                15,
                                10,
                                15,
                              ),
                          child: Column(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(
                                      horizontal: 20.0,
                                    ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment
                                          .spaceBetween,
                                  children: [
                                    Text(
                                      style: TextStyle(
                                        fontWeight:
                                            FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                      'Products',
                                    ),
                                    MaterialButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (
                                              context,
                                            ) {
                                              return TotalProductsPage(
                                                theme:
                                                    theme,
                                              );
                                            },
                                          ),
                                        );
                                      },
                                      child: Row(
                                        spacing: 5,
                                        children: [
                                          Text(
                                            style: TextStyle(
                                              color:
                                                  theme
                                                      .lightModeColor
                                                      .secColor100,
                                            ),
                                            'See All',
                                          ),
                                          Icon(
                                            size: 16,
                                            color:
                                                theme
                                                    .lightModeColor
                                                    .secColor100,
                                            Icons
                                                .arrow_forward_ios_rounded,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(
                                        horizontal: 10.0,
                                      ),
                                  child: Builder(
                                    builder: (context) {
                                      if (mainReceipts
                                          .isEmpty) {
                                        return Center(
                                          child: Text(
                                            'Is Empty',
                                          ),
                                        );
                                      } else {
                                        return ListView.builder(
                                          itemCount:
                                              mainReceipts
                                                  .length,
                                          itemBuilder: (
                                            context,
                                            index,
                                          ) {
                                            TempMainReceipt
                                            mainReceipt =
                                                mainReceipts[index];
                                            return MainReceiptTile(
                                              mainReceipt:
                                                  mainReceipt,
                                            );
                                          },
                                        );
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          // Overlayed search results container
          // if (setDate)
          //   Stack(
          //     children: [
          //       Positioned(
          //         top: 200,
          //         left: 0,
          //         right: 0,
          //         child: Container(
          //           padding: EdgeInsets.only(
          //             // top: 40,
          //             bottom: 40,
          //           ),
          //           color: const Color.fromARGB(
          //             40,
          //             0,
          //             0,
          //             0,
          //           ),
          //           child: TableCalendar(
          //             firstDay: DateTime.utc(2020, 1, 1),
          //             lastDay: DateTime.utc(2030, 12, 31),
          //             focusedDay: DateTime.now(),
          //             selectedDayPredicate:
          //                 (day) =>
          //                     isSameDay(selectedDay, day),
          //             onDaySelected: (
          //               selectedDay,
          //               focusedDay,
          //             ) {
          //               setState(() {
          //                 this.selectedDay = selectedDay;
          //                 this.focusedDay = focusedDay;
          //               });
          //             },
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
        ],
      ),
    );
  }
}
