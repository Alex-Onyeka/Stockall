import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stockall/components/major/top_banner.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
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
    returnSubPaymentProvider(
      context,
      listen: false,
    ).selectDuration(duration);
  }

  final GlobalKey fullComparisonSection = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      returnSubPaymentProvider(
        context,
        listen: false,
      ).selectDuration(6);
    });
  }

  @override
  Widget build(BuildContext context) {
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
              iconData: Icons.attach_money_rounded,
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
                        style: TextStyle(
                          fontSize:
                              theme.mobileTexts.h1.fontSize,
                          fontWeight: FontWeight.bold,
                        ),
                        'Pick a Suitable Plan',
                      ),
                      Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        spacing: 5,
                        children: [
                          Text(
                            style: TextStyle(
                              fontSize:
                                  theme
                                      .mobileTexts
                                      .b3
                                      .fontSize,
                              fontWeight: FontWeight.normal,
                            ),
                            'Current Plan:',
                          ),
                          Text(
                            style: TextStyle(
                              fontSize:
                                  theme
                                      .mobileTexts
                                      .b3
                                      .fontSize,
                              fontWeight: FontWeight.bold,
                            ),
                            returnSubcsription(
                                      context,
                                    ).subscription?.plan ==
                                    1
                                ? 'Basic Plan'
                                : returnSubcsription(
                                      context,
                                    ).subscription?.plan ==
                                    2
                                ? 'Standard Plan'
                                : returnSubcsription(
                                      context,
                                    ).subscription?.plan ==
                                    3
                                ? 'Premium Plan'
                                : 'Free Plan',
                          ),
                          Visibility(
                            visible:
                                returnSubcsription(
                                  context,
                                ).subscription?.plan !=
                                0,
                            child: SvgPicture.asset(
                              color:
                                  returnSubcsription(
                                                context,
                                              )
                                              .subscription
                                              ?.plan ==
                                          1
                                      ? Colors.grey
                                      : returnSubcsription(
                                                context,
                                              )
                                              .subscription
                                              ?.plan ==
                                          2
                                      ? Colors.blue
                                      : null,
                              checkIconSvg,
                              height: 16,
                              width: 16,
                              fit: BoxFit.contain,
                            ),
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
                          context,
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
                                context,
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
