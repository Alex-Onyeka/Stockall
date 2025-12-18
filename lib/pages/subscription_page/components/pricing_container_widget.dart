import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/subscription/plan_pricing_class.dart';
import 'package:stockall/main.dart';
import 'package:stockall/services/auth_service.dart';
import 'package:stockall/services/sub_payment_serice.dart/paystack_checkout_page.dart';
import 'package:stockall/services/sub_payment_serice.dart/sub_payment_service.dart';

class PricingContainerWidget extends StatefulWidget {
  final GlobalKey fullComparisonSection;
  final PlanPricingClass pricingClass;
  const PricingContainerWidget({
    super.key,
    required this.fullComparisonSection,
    required this.pricingClass,
  });

  @override
  State<PricingContainerWidget> createState() =>
      _PricingContainerWidgetState();
}

class _PricingContainerWidgetState
    extends State<PricingContainerWidget> {
  void scrollTo(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  String duration() {
    if (widget.pricingClass.duration == 1) {
      return '1 Month';
    } else if (widget.pricingClass.duration == 6) {
      return '6 Months';
    } else {
      return '1 Year';
    }
  }

  Future<void> startPayment(
    BuildContext context,
    String userId,
    String email,
    int plan,
    double amount,
    int duration,
  ) async {
    print('Payment Process Begins');
    final paymentService = PaymentService(
      'https://jlwizkdhjazpbllpvtgo.functions.supabase.co/initiate-subscription-payment',
    );

    final callbackUrl = Uri.parse(
      'https://stockallapp.com/#/payment-result',
    );

    if (plan != 0) {
      final authorizationUrl = await paymentService
          .initiatePayment(
            userId: userId,
            email: email,
            plan: plan,
            amount: amount,
            duration: duration,
            callbackUrl: callbackUrl,
          );

      if (authorizationUrl == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to start payment'),
          ),
        );
        return;
      }
      if (kIsWeb) {
        print('Platform is Web');
        launchUrlMain(authorizationUrl.authorizationUrl);
      } else {
        Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder:
                (_) => PaystackCheckoutPage(
                  authorizationUrl: authorizationUrl,
                  callbackUrl: callbackUrl,
                ),
          ),
        );
      }
    } else {
      await returnSubcsription(
        context,
        listen: false,
      ).subscribe(plan: 0, context: context);
      Navigator.of(context).pop();
    }
  }

  bool isLoading = false;

  void toggleLoading(bool value) {
    setState(() {
      isLoading = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Container(
      width:
          screenWidth(context) > 570
              ? 260
              : double.infinity,
      height: 520,
      padding: EdgeInsets.fromLTRB(15, 15, 15, 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            style: TextStyle(
              fontSize: theme.mobileTexts.h4.fontSize,
              fontWeight: FontWeight.bold,
            ),
            "${widget.pricingClass.planName} Plan",
          ),
          Text(
            style: TextStyle(
              fontSize: theme.mobileTexts.b4.fontSize,
              fontWeight: FontWeight.bold,
            ),
            widget.pricingClass.planDesc,
          ),
          SizedBox(height: 20),
          Divider(color: Colors.grey.shade200, height: 1),
          SizedBox(height: 10),
          Row(
            children: [
              Text(
                style: TextStyle(
                  fontSize: theme.mobileTexts.h1.fontSize,
                  fontWeight: FontWeight.bold,
                ),
                formatMoney(
                  widget.pricingClass.totalPrice(),
                  context,
                ),
              ),
              Text(
                style: TextStyle(
                  fontSize: theme.mobileTexts.b3.fontSize,
                  fontWeight: FontWeight.normal,
                ),
                '/',
              ),
              Text(
                style: TextStyle(
                  fontSize: theme.mobileTexts.b3.fontSize,
                  fontWeight: FontWeight.normal,
                ),
                duration(),
              ),
            ],
          ),
          Visibility(
            visible:
                returnSubPaymentProvider(
                  context,
                ).discount !=
                null,
            child: Row(
              children: [
                Text(
                  style: TextStyle(
                    fontSize: theme.mobileTexts.b3.fontSize,
                    fontWeight: FontWeight.normal,
                    decoration: TextDecoration.lineThrough,
                  ),
                  returnSubPaymentProvider(
                            context,
                          ).discount !=
                          null
                      ? formatMoney(
                        widget.pricingClass.originalPrice(),
                        context,
                      )
                      : '',
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Material(
            type: MaterialType.transparency,
            child: Ink(
              decoration: BoxDecoration(
                border:
                    widget.pricingClass.plan == 1 ||
                            widget.pricingClass.plan == 2
                        ? null
                        : Border.all(
                          color:
                              theme
                                  .lightModeColor
                                  .prColor250,
                        ),
                gradient:
                    widget.pricingClass.plan == 1 ||
                            widget.pricingClass.plan == 2
                        ? theme.lightModeColor.prGradient
                        : null,
                borderRadius: BorderRadius.circular(2),
              ),
              child: InkWell(
                onTap: () async {
                  bool isOnline =
                      await returnConnectivityProvider(
                        context,
                        listen: false,
                      ).isOnline();
                  if (isOnline) {
                    showDialog(
                      // ignore: use_build_context_synchronously
                      context: context,
                      builder: (confirmDialog) {
                        return ConfirmationAlert(
                          theme: theme,
                          message:
                              'You are about to Update your subscription Plan. Please note that Subscription Cancellations and Refunds are not available at the Moment, are you sure you want to Proceed?',
                          title:
                              'Update Subscription Plan?',
                          action: () async {
                            Navigator.of(
                              confirmDialog,
                            ).pop();
                            toggleLoading(true);
                            await startPayment(
                              context,
                              returnShopProvider(
                                context,
                                listen: false,
                              ).userShop()!.userId,
                              AuthService()
                                  .currentUserEmail!,
                              widget.pricingClass.plan,
                              widget.pricingClass
                                  .totalPrice(),
                              widget.pricingClass.duration,
                            );
                            if (context.mounted) {
                              toggleLoading(false);
                            }
                          },
                        );
                      },
                    );
                  } else {
                    showDialog(
                      // ignore: use_build_context_synchronously
                      context: context,
                      builder: (context) {
                        return InfoAlert(
                          theme: theme,
                          message:
                              'You cannot proceed with this action when you are not connected to the internet. Please turn on your data connection and try again.',
                          title: 'No Internet Connection',
                        );
                      },
                    );
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10.0,
                  ),
                  child: Center(
                    child: Builder(
                      builder: (context) {
                        if (!isLoading) {
                          return Text(
                            style: TextStyle(
                              color:
                                  widget.pricingClass.plan ==
                                              1 ||
                                          widget
                                                  .pricingClass
                                                  .plan ==
                                              2
                                      ? Colors.white
                                      : theme
                                          .lightModeColor
                                          .prColor250,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            'Choose Plan',
                          );
                        } else {
                          return SizedBox(
                            height: 15,
                            width: 15,
                            child: CircularProgressIndicator(
                              strokeWidth: 1.8,
                              color:
                                  widget.pricingClass.plan ==
                                              1 ||
                                          widget
                                                  .pricingClass
                                                  .plan ==
                                              2
                                      ? Colors.white
                                      : theme
                                          .lightModeColor
                                          .prColor250,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          Divider(color: Colors.grey.shade200, height: 1),
          SizedBox(height: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 10,
              children: [
                PricingFeatureRow(
                  title:
                      'Online Storage Limit: ${widget.pricingClass.dataStorageDuration > 1 ? 'Unlimited' : widget.pricingClass.dataStorageDuration}',
                  numberOfItems:
                      widget
                          .pricingClass
                          .dataStorageDuration,
                  toolTipMessage:
                      'The duration of Month(s) your business data is securely stored online before it is automatically deleted from the cloud. For free plan, data is deleted from the cloud after a duration of 1 month.',
                ),
                PricingFeatureRow(
                  title:
                      'Numbers of Store Branches: ${widget.pricingClass.numberOfBranches}',
                  numberOfItems:
                      widget.pricingClass.numberOfBranches,
                  toolTipMessage:
                      'The number of store locations you can create and manage independently within your account.',
                ),
                PricingFeatureRow(
                  title:
                      'Numbers of Staffs Per Branch: ${widget.pricingClass.numberOfStaffs}',
                  numberOfItems:
                      widget.pricingClass.numberOfStaffs,
                  toolTipMessage:
                      'The number of employees per store branch you can add to help manage your store operations.',
                ),
                PricingFeatureRow(
                  title:
                      'Numbers of Items Per Branch: ${widget.pricingClass.numberOfItems > 1000000 ? 'Infinity' : widget.pricingClass.numberOfItems}',
                  numberOfItems:
                      widget.pricingClass.numberOfItems,
                  toolTipMessage:
                      'The number of products or inventory items you can add and manage per store branch, each tracked separately by store account.',
                ),
                PricingFeatureRow(
                  title: 'Run Bussiness Offline',
                  boolean: widget.pricingClass.useOffline,
                  toolTipMessage:
                      'Allows you to run your business without an internet connection, with data syncing automatically when you\'re back online.',
                ),
                PricingFeatureRow(
                  title: 'Create and Manage Invoices',
                  boolean:
                      widget.pricingClass.invoiceManagement,
                  toolTipMessage:
                      'Ability to to create, send, and manage professional invoices for your customers directly from the app.',
                ),
                PricingFeatureRow(
                  title: 'Generate, Print and Edit Receipt',
                  boolean:
                      widget.pricingClass.receiptManagement,
                  toolTipMessage:
                      'The ability to generate, edit, and print receipts for sales, making it easy to share transaction details with customers.',
                ),
                PricingFeatureRow(
                  title:
                      'Generate, Print, and Scan Barcode',
                  boolean: widget.pricingClass.barcode,
                  toolTipMessage:
                      'The ability to generate and print barcodes for products, and scan barcodes to quickly add items during sales.',
                ),
                PricingFeatureRow(
                  title:
                      'Use In-App Professional Calculator',
                  boolean:
                      widget.pricingClass.useCalculator,
                  toolTipMessage:
                      'The ability to access and use a built-in calculator within the app for quick calculations while managing your store.',
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () {
              scrollTo(widget.fullComparisonSection);
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Center(
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    Text(
                      style: TextStyle(
                        // color: Colors.grey.shade600,
                        fontSize: 10,
                        fontWeight: FontWeight.normal,
                      ),
                      'See Full Comparison',
                    ),
                    Icon(
                      size: 18,
                      color:
                          theme.lightModeColor.prColor250,
                      Icons.keyboard_arrow_down_rounded,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PricingFeatureRow extends StatelessWidget {
  final String title;
  final String? toolTipMessage;
  final int? numberOfItems;
  final bool? boolean;
  const PricingFeatureRow({
    super.key,
    this.toolTipMessage,
    required this.title,
    this.boolean,
    this.numberOfItems,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: toolTipMessage ?? '',
      verticalOffset: 10,
      padding: EdgeInsets.symmetric(
        vertical: 12,
        horizontal: 12,
      ),
      constraints: BoxConstraints(maxWidth: 280),
      margin: EdgeInsets.only(top: 0),
      triggerMode: TooltipTriggerMode.tap,
      showDuration:
          screenWidth(context) < tabletScreenSmall
              ? Duration(seconds: 10)
              : Duration(seconds: 4),
      ignorePointer: false,
      enableTapToDismiss: true,
      enableFeedback: toolTipMessage != null,
      textStyle: TextStyle(
        color: Colors.black,
        fontSize: 12,
        fontWeight: FontWeight.normal,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(0),
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(60, 0, 0, 0),
            blurRadius: 20,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 5,
          children: [
            Builder(
              builder: (context) {
                if (numberOfItems != null) {
                  if (numberOfItems == 0) {
                    return Icon(
                      size: 14,
                      color: Colors.red,
                      Icons.clear,
                    );
                  } else {
                    return Icon(
                      size: 14,
                      color: Colors.green,
                      Icons.check,
                    );
                  }
                } else {
                  if (boolean!) {
                    return Icon(
                      size: 14,
                      color: Colors.green,
                      Icons.check,
                    );
                  } else {
                    return Icon(
                      size: 14,
                      color: Colors.red,
                      Icons.clear,
                    );
                  }
                }
              },
            ),
            Text(
              style: TextStyle(
                color: Colors.grey.shade900,
                fontSize: 10,
                fontWeight: FontWeight.normal,
              ),
              title,
            ),
            Visibility(
              visible: toolTipMessage != null,
              child: Row(
                children: [
                  SizedBox(width: 3),
                  Container(
                    padding: EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(
                        color: Colors.grey,
                        width: 0.6,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        size: 9,
                        color: Colors.black,
                        Icons.question_mark_rounded,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
