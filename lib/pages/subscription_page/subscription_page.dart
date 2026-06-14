import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stockall/classes/subplan_class.dart';
import 'package:stockall/components/major/top_banner.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/subscription/subscription_func.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/subscription_page/components/comparison_section_widget.dart';
import 'package:stockall/pages/subscription_page/components/faq_section.dart';
import 'package:stockall/pages/subscription_page/components/pricing_section_widget.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() =>
      _SubscriptionPageState();
}

class _SubscriptionPageState
    extends State<SubscriptionPage> {
  void selectDuration(int duration) {
    returnSubPaymentProvider().selectDuration(duration);
  }

  final GlobalKey fullComparisonSection = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      returnSubPaymentProvider().selectDuration(1);
      returnSubPaymentProvider().selectCurrency(0);
    });
  }

  @override
  Widget build(BuildContext context) {
    SubplanClass? plan =
        subPlans
            .where(
              (pl) =>
                  pl.plan ==
                  returnSubcsription(
                    context,
                  ).subscription?.plan,
            )
            .firstOrNull;

    var theme = returnTheme(context);
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            TopBanner(
              subTitle:
                  'Unlock Multiple Game Changing Features',
              title: 'PRICING',
              theme: theme,
              bottomSpace: 50,
              topSpace: 20,
              isMain: true,
            ),
            SizedBox(height: 30),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                  ),
                  child: Column(
                    children: [
                      Text(
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize:
                              theme.mobileTexts.h1.fontSize,
                          fontWeight: FontWeight.bold,
                        ),
                        'Pick a Suitable Plan',
                      ),
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        spacing: 6,
                        children: [
                          Row(
                            crossAxisAlignment:
                                CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            spacing: 3,
                            children: [
                              Text(
                                style: TextStyle(
                                  fontSize:
                                      theme
                                          .mobileTexts
                                          .b4
                                          .fontSize,
                                  fontWeight:
                                      FontWeight.normal,
                                ),
                                'Plan:',
                              ),
                              Text(
                                style: TextStyle(
                                  fontSize:
                                      theme
                                          .mobileTexts
                                          .b4
                                          .fontSize,
                                  fontWeight:
                                      FontWeight.bold,
                                ),

                                plan?.planName ??
                                    'Sub Plan',
                              ),
                              Visibility(
                                visible: plan?.plan != 0,
                                child: SvgPicture.asset(
                                  color:
                                      plan?.plan == 1
                                          ? Colors.grey
                                          : plan?.plan == 2
                                          ? Colors.blue
                                          : null,
                                  checkIconSvg,
                                  height: 14,
                                  width: 14,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            width: 1,
                            height: 15,
                            color: Colors.grey.shade300,
                          ),
                          Row(
                            crossAxisAlignment:
                                CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            spacing: 3,
                            children: [
                              Text(
                                style: TextStyle(
                                  fontSize:
                                      theme
                                          .mobileTexts
                                          .b4
                                          .fontSize,
                                  fontWeight:
                                      FontWeight.normal,
                                ),
                                'Exp Date:',
                              ),
                              Text(
                                style: TextStyle(
                                  fontSize:
                                      theme
                                          .mobileTexts
                                          .b4
                                          .fontSize,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                                returnSubcsription(context)
                                            .subscription
                                            ?.nextPayment !=
                                        null
                                    ? formatDateTime(
                                      returnSubcsription(
                                                context,
                                              )
                                              .subscription
                                              ?.nextPayment ??
                                          DateTime.now(),
                                    )
                                    : 'Not Set',
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Container(
                        constraints: BoxConstraints(
                          maxWidth: 600,
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: 7,
                          horizontal: 7,
                        ),
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(5),
                          color: Colors.grey.shade100,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            DurationSelectionButton(
                              action: () {
                                selectDuration(1);
                              },
                              myIndex: 1,
                              title: 'Monthly',
                            ),
                            DurationSelectionButton(
                              action: () {
                                selectDuration(6);
                              },
                              myIndex: 6,
                              title: 'Bi-Annually',
                            ),
                            DurationSelectionButton(
                              action: () {
                                selectDuration(12);
                              },
                              myIndex: 12,
                              title: 'Annually',
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 15),
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize:
                                    theme
                                        .mobileTexts
                                        .b3
                                        .fontSize,
                                fontWeight:
                                    FontWeight.normal,
                                color: Colors.redAccent,
                              ),
                              'Please for Non Nigerian Users, Proceed Contact the customer Care (+2347048507587) for Subscription Procedure.',
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 5),
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        spacing: 5,
                        children: [
                          // Material(
                          //   color: Colors.transparent,
                          //   child: InkWell(
                          //     onTap: () {
                          //       returnSubPaymentProvider()
                          //           .selectCurrency(0);
                          //     },
                          //     child: Container(
                          //       padding:
                          //           EdgeInsets.symmetric(
                          //             horizontal: 6,
                          //             vertical: 6,
                          //           ),
                          //       child: Row(
                          //         spacing: 6,
                          //         children: [
                          //           Container(
                          //             decoration: BoxDecoration(
                          //               border: Border.all(
                          //                 color:
                          //                     returnSubPaymentProvider(
                          //                               context:
                          //                                   context,
                          //                             ).currencyIndex ==
                          //                             0
                          //                         ? Colors
                          //                             .transparent
                          //                         : Colors
                          //                             .grey,
                          //               ),
                          //               color:
                          //                   returnSubPaymentProvider(
                          //                             context:
                          //                                 context,
                          //                           ).currencyIndex ==
                          //                           0
                          //                       ? theme
                          //                           .lightModeColor
                          //                           .prColor250
                          //                       : Colors
                          //                           .transparent,
                          //               shape:
                          //                   BoxShape.circle,
                          //             ),
                          //             child: Icon(
                          //               size: 14,
                          //               color: Colors.white,
                          //               Icons.check,
                          //             ),
                          //           ),
                          //           Text(
                          //             style: TextStyle(
                          //               fontSize:
                          //                   theme
                          //                       .mobileTexts
                          //                       .b4
                          //                       .fontSize,
                          //               fontWeight:
                          //                   FontWeight.bold,
                          //             ),
                          //             '(₦) NGN Naira',
                          //           ),
                          //         ],
                          //       ),
                          //     ),
                          //   ),
                          // ),
                          Material(
                            color: Colors.transparent,
                            child: Ink(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color:
                                      Colors.grey.shade300,
                                ),
                              ),
                              child: InkWell(
                                onTap: () {
                                  openWhatsApp();
                                },
                                child: Container(
                                  padding:
                                      EdgeInsets.symmetric(
                                        vertical: 6,
                                        horizontal: 15,
                                      ),
                                  child: Row(
                                    spacing: 5,
                                    children: [
                                      // Container(
                                      //   decoration: BoxDecoration(
                                      //     border: Border.all(
                                      //       color:
                                      //           returnSubPaymentProvider(
                                      //                     context:
                                      //                         context,
                                      //                   ).currencyIndex ==
                                      //                   1
                                      //               ? Colors
                                      //                   .transparent
                                      //               : Colors
                                      //                   .grey,
                                      //     ),
                                      //     color:
                                      //         returnSubPaymentProvider(
                                      //                   context:
                                      //                       context,
                                      //                 ).currencyIndex ==
                                      //                 1
                                      //             ? theme
                                      //                 .lightModeColor
                                      //                 .prColor250
                                      //             : Colors
                                      //                 .transparent,
                                      //     shape:
                                      //         BoxShape.circle,
                                      //   ),
                                      //   child: Icon(
                                      //     size: 14,
                                      //     color: Colors.white,
                                      //     Icons.check,
                                      //   ),
                                      // ),
                                      Icon(
                                        size: 14,
                                        Icons.call,
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
                                                  .bold,
                                        ),
                                        'Contact Customer Care',
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 30),
                      PricingSectionWidget(
                        fullComparisonSection:
                            fullComparisonSection,
                      ),
                      const SizedBox(height: 80),
                      Text(
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize:
                              theme.mobileTexts.h1.fontSize,
                          fontWeight: FontWeight.bold,
                        ),
                        'Full Plan Comparison Breakdown',
                      ),
                      const SizedBox(height: 30),
                      ComparisonSectionWidget(
                        fullComparisonSection:
                            fullComparisonSection,
                      ),
                      const SizedBox(height: 80),
                      Text(
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize:
                              screenWidth(context) <
                                      mobileScreen
                                  ? theme
                                      .mobileTexts
                                      .h3
                                      .fontSize
                                  : theme
                                      .mobileTexts
                                      .h1
                                      .fontSize,
                          fontWeight: FontWeight.bold,
                        ),
                        'Frequently Asked Questions',
                      ),
                      const SizedBox(height: 30),
                      FaqSection(),
                      const SizedBox(height: 100),
                    ],
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

class DurationSelectionButton extends StatelessWidget {
  final int myIndex;
  final String title;
  final Function()? action;
  const DurationSelectionButton({
    super.key,
    required this.title,
    required this.myIndex,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Expanded(
      child: Material(
        type: MaterialType.transparency,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            color:
                returnSubPaymentProvider(
                          context: context,
                        ).currentDuration ==
                        myIndex
                    ? theme.lightModeColor.secColor200
                    : null,
          ),
          child: InkWell(
            onTap: action,
            child: Container(
              padding: EdgeInsets.symmetric(
                vertical: 4,
                horizontal: 6,
              ),

              child: Text(
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: theme.mobileTexts.b4.fontSize,
                  fontWeight: FontWeight.bold,
                  color:
                      returnSubPaymentProvider(
                                context: context,
                              ).currentDuration ==
                              myIndex
                          ? Colors.white
                          : theme
                              .lightModeColor
                              .secColor100,
                ),
                title,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
