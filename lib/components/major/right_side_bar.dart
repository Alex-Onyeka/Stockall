import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stockall/classes/temp_main_receipt.dart';
import 'package:stockall/classes/temp_product_sale_record.dart';
import 'package:stockall/components/buttons/main_button_p.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/profile/profile_page.dart';
import 'package:stockall/pages/sales/make_sales/page1/make_sales_page.dart';
import 'package:stockall/pages/sales/make_sales/receipt_page/receipt_page.dart';
import 'package:stockall/pages/sales/total_sales/total_sales_page.dart';
import 'package:stockall/providers/theme_provider.dart';

class RightSideBar extends StatelessWidget {
  const RightSideBar({
    super.key,
    required this.theme,
    // required this.receiptsLocal,
  });

  final ThemeProvider theme;
  // final List<TempMainReceipt> receiptsLocal;

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: MediaQuery.of(context).size.width > 950,
      child: Material(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.2,
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(10),
              topLeft: Radius.circular(10),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color.fromARGB(39, 4, 1, 41),
                blurRadius: 10,
              ),
            ],
          ),
          child: Column(
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return ProfilePage();
                        },
                      ),
                    );
                  },
                  child: SizedBox(
                    child: Column(
                      children: [
                        SizedBox(height: 60),
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          clipBehavior: Clip.hardEdge,
                          child: Image.asset(
                            profileIconImage,
                            height: 70,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize:
                                theme
                                    .mobileTexts
                                    .b2
                                    .fontSize,
                          ),
                          userGeneral(context).name,
                        ),
                        Text(
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            color:
                                theme
                                    .lightModeColor
                                    .secColor200,
                            fontSize:
                                theme
                                    .mobileTexts
                                    .b3
                                    .fontSize,
                          ),
                          userGeneral(context).email,
                        ),
                        SizedBox(height: 5),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(
                              32,
                              255,
                              193,
                              7,
                            ),
                            borderRadius:
                                BorderRadius.circular(5),
                            border: Border.all(
                              color:
                                  theme
                                      .lightModeColor
                                      .secColor200,
                            ),
                          ),
                          child: Text(
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              // color:
                              //     theme
                              //         .lightModeColor
                              //         .secColor200,
                              fontSize:
                                  theme
                                      .mobileTexts
                                      .b4
                                      .fontSize,
                            ),
                            userGeneral(context).role,
                          ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(
                                0,
                                0,
                                20,
                                20,
                              ),
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.end,
                            children: [
                              Icon(
                                size: 15,
                                color: Colors.grey,
                                Icons
                                    .arrow_forward_ios_rounded,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Divider(
                color: Colors.grey.shade300,
                height: 50,
              ),
              Expanded(
                child: SizedBox(
                  child: Column(
                    spacing: 10,
                    children: [
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return TotalSalesPage();
                                },
                              ),
                            );
                          },
                          child: Padding(
                            padding:
                                const EdgeInsets.fromLTRB(
                                  0,
                                  10,
                                  0,
                                  10,
                                ),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment
                                      .spaceBetween,
                              children: [
                                Text(
                                  style: TextStyle(
                                    fontSize:
                                        theme
                                            .mobileTexts
                                            .b2
                                            .fontSize,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                  returnReceiptProvider(
                                        context,
                                      ).dateSet ??
                                      'Todays Sales',
                                ),
                                Icon(
                                  size: 15,
                                  color: Colors.grey,
                                  Icons
                                      .arrow_forward_ios_rounded,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // SizedBox(height: 10),
                      Builder(
                        builder: (context) {
                          if (returnReceiptProvider(context)
                              .returnOwnReceiptsByDayOrWeek(
                                context,
                                returnReceiptProvider(
                                  context,
                                ).receipts,
                              )
                              .isEmpty) {
                            return Expanded(
                              child: Material(
                                color: Colors.transparent,
                                child: Center(
                                  child: Column(
                                    spacing: 10,
                                    mainAxisAlignment:
                                        MainAxisAlignment
                                            .center,
                                    children: [
                                      SvgPicture.asset(
                                        height: 18,
                                        receiptIconSvg,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment
                                                .center,
                                        children: [
                                          Flexible(
                                            child: Text(
                                              style: TextStyle(
                                                fontSize:
                                                    theme
                                                        .mobileTexts
                                                        .b3
                                                        .fontSize,
                                              ),
                                              'No Sales Recorded for today',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          } else {
                            return Expanded(
                              child: ListView.builder(
                                itemCount:
                                    returnReceiptProvider(
                                          context,
                                        )
                                        .returnOwnReceiptsByDayOrWeek(
                                          context,
                                          returnReceiptProvider(
                                            context,
                                          ).receipts,
                                        )
                                        .length,
                                itemBuilder: (
                                  context,
                                  index,
                                ) {
                                  TempMainReceipt rec =
                                      returnReceiptProvider(
                                        context,
                                      ).returnOwnReceiptsByDayOrWeek(
                                        context,
                                        returnReceiptProvider(
                                          context,
                                        ).receipts,
                                      )[index];
                                  TempProductSaleRecord
                                  firstP = returnReceiptProvider(
                                        context,
                                      )
                                      .produtRecordSalesMain
                                      .firstWhere(
                                        (record) =>
                                            record
                                                .recepitId ==
                                            rec.id!,
                                      );
                                  return Padding(
                                    padding:
                                        const EdgeInsets.only(
                                          bottom: 2,
                                        ),
                                    child: Material(
                                      color:
                                          Colors
                                              .transparent,
                                      child: InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (
                                                context,
                                              ) {
                                                return ReceiptPage(
                                                  receiptId:
                                                      rec.id!,
                                                  isMain:
                                                      false,
                                                );
                                              },
                                            ),
                                          );
                                        },
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.symmetric(
                                                horizontal:
                                                    5,
                                                vertical:
                                                    11,
                                              ),
                                          child: Row(
                                            spacing: 10,
                                            mainAxisAlignment:
                                                MainAxisAlignment
                                                    .spaceBetween,
                                            children: [
                                              Row(
                                                spacing: 10,
                                                children: [
                                                  SvgPicture.asset(
                                                    salesIconSvg,
                                                    height:
                                                        13,
                                                  ),
                                                  Text(
                                                    style: TextStyle(
                                                      fontSize:
                                                          theme.mobileTexts.b4.fontSize,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    cutLongText(
                                                      firstP
                                                          .productName,
                                                      13,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                spacing: 5,
                                                children: [
                                                  Text(
                                                    style: TextStyle(
                                                      fontSize:
                                                          theme.mobileTexts.b4.fontSize,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    cutLongText(
                                                      formatMoneyMid(
                                                        amount:
                                                            rec.bank +
                                                            rec.cashAlt,
                                                        context:
                                                            context,
                                                      ),
                                                      10,
                                                    ),
                                                  ),
                                                  Icon(
                                                    size:
                                                        15,
                                                    color:
                                                        Colors.grey,
                                                    Icons
                                                        .arrow_forward_ios_rounded,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              MainButtonP(
                themeProvider: theme,
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
                text: 'Make New Sale',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
