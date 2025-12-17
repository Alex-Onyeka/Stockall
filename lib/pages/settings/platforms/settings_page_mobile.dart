import 'package:flutter/material.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/alert_dialogues/dialog_template.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/components/buttons/main_button_p.dart';
import 'package:stockall/components/buttons/main_button_transparent.dart';
import 'package:stockall/components/discount_setter.dart/discount_setter_widget.dart';
import 'package:stockall/components/major/drawer_widget/platforms/my_drawer_widget_desktop.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/generate_barcode.dart';
import 'package:stockall/constants/subscription/general_settings_auth.dart';
import 'package:stockall/constants/subscription/items_auth.dart';
import 'package:stockall/constants/subscription/sales_auth.dart';
import 'package:stockall/constants/subscription/subscription_func.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/authentication/components/email_text_field.dart';
import 'package:stockall/pages/profile/profile_page.dart';
import 'package:stockall/pages/settings/settings_page.dart';
import 'package:stockall/pages/shop_setup/edit_receipt_page/edit_receipt.dart';
import 'package:stockall/pages/shop_setup/shop_page/shop_page.dart';
import 'package:stockall/pages/subscription_page/subscription_page.dart';

class SettingsPageMobile extends StatefulWidget {
  const SettingsPageMobile({super.key});

  @override
  State<SettingsPageMobile> createState() =>
      _SettingsPageMobileState();
}

class _SettingsPageMobileState
    extends State<SettingsPageMobile> {
  final passwordController = TextEditingController();
  final productSearch = TextEditingController();
  final discountPercentController = TextEditingController();
  bool isLoading = false;
  bool isChangePlanLoading = false;
  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Stack(
      children: [
        Scaffold(
          appBar: appBar(
            context: context,
            title: 'General Settings',
            backAction: () {
              Navigator.of(context).pop();
            },
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 25.0,
              ),
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      // spacing: 10,
                      children: [
                        NavListTileDesktopAlt(
                          title: 'Account',
                          action: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return ProfilePage();
                                },
                              ),
                            );
                          },
                          height: 18,
                          icon: Icons.person,
                        ),
                        Visibility(
                          visible: authorization(
                            authorized:
                                Authorizations().manageShop,
                            context: context,
                          ),
                          child: NavListTileDesktopAlt(
                            height: 18,
                            action: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return ShopPage();
                                  },
                                ),
                              );
                            },
                            title: 'Manage Shop',
                            icon: Icons.home_filled,
                          ),
                        ),
                        Visibility(
                          visible: authorization(
                            authorized:
                                Authorizations().manageShop,
                            context: context,
                          ),
                          child: NavListTileDesktopAlt(
                            height: 18,
                            action: () {
                              setStoreAsHeadquarters(
                                context,
                              );
                            },
                            title:
                                'Set Business Head Quarter',
                            icon:
                                Icons
                                    .settings_suggest_outlined,
                          ),
                        ),
                        Visibility(
                          visible: authorization(
                            authorized:
                                Authorizations()
                                    .generalDiscount,
                            context: context,
                          ),
                          child: SubWrapper(
                            isVisible:
                                !SalesAuthAction()
                                    .applyDiscountAction(
                                      context: context,
                                    ),
                            mainWidget: NavListTileDesktopAlt(
                              height: 18,
                              action: () {
                                SalesAuthAction().applyDiscountAction(
                                  context: context,
                                  action: () {
                                    showDialog(
                                      context: context,
                                      builder: (
                                        confirmDialog,
                                      ) {
                                        bool
                                        isDiscountLoading =
                                            false;
                                        return StatefulBuilder(
                                          builder: (
                                            context,
                                            setState,
                                          ) {
                                            return DialogTemplate(
                                              showTopSection:
                                                  returnShopProvider(context).userShop()!.fixedDiscount ==
                                                              null &&
                                                          returnShopProvider(context).userShop()!.percentDiscount ==
                                                              null
                                                      ? null
                                                      : false,
                                              showBottomActionButtons:
                                                  returnShopProvider(context).userShop()!.fixedDiscount ==
                                                              null &&
                                                          returnShopProvider(context).userShop()!.percentDiscount ==
                                                              null
                                                      ? null
                                                      : false,
                                              theme: theme,
                                              message:
                                                  'Set General Discount',
                                              title:
                                                  'Set General Discount',
                                              action: () async {
                                                var fixedDiscount =
                                                    returnShopProvider(
                                                      context,
                                                      listen:
                                                          false,
                                                    ).generalFixedDiscount;
                                                var percentDiscount =
                                                    returnShopProvider(
                                                      context,
                                                      listen:
                                                          false,
                                                    ).generalPercentDiscount;
                                                if (!isDiscountLoading) {
                                                  if (fixedDiscount ==
                                                          null &&
                                                      percentDiscount ==
                                                          null &&
                                                      discountPercentController
                                                          .text
                                                          .isEmpty) {
                                                    showDialog(
                                                      context:
                                                          context,
                                                      builder: (
                                                        context,
                                                      ) {
                                                        return InfoAlert(
                                                          theme:
                                                              theme,
                                                          message:
                                                              'You have to select or enter a number in the text field before setting discount.',
                                                          title:
                                                              'Empty Discount',
                                                        );
                                                      },
                                                    );
                                                  } else {
                                                    showDialog(
                                                      context:
                                                          context,
                                                      builder: (
                                                        mainDialog,
                                                      ) {
                                                        return ConfirmationAlert(
                                                          theme:
                                                              theme,
                                                          message:
                                                              'Are you sure you want to proceed to set general discount?',
                                                          title:
                                                              'Proceed with action?',
                                                          action: () async {
                                                            Navigator.of(
                                                              mainDialog,
                                                            ).pop();
                                                            if (returnShopProvider(
                                                                  context,
                                                                  listen:
                                                                      false,
                                                                ).discountIndex ==
                                                                0) {
                                                              setState(
                                                                () {
                                                                  isDiscountLoading =
                                                                      true;
                                                                },
                                                              );
                                                              await returnShopProvider(
                                                                context,
                                                                listen:
                                                                    false,
                                                              ).setPercentDiscount(
                                                                discount:
                                                                    returnShopProvider(
                                                                      context,
                                                                      listen:
                                                                          false,
                                                                    ).generalPercentDiscount ??
                                                                    double.parse(
                                                                      discountPercentController.text,
                                                                    ),
                                                              );
                                                              setState(
                                                                () {
                                                                  isDiscountLoading =
                                                                      false;
                                                                },
                                                              );
                                                            } else {
                                                              setState(
                                                                () {
                                                                  isDiscountLoading =
                                                                      true;
                                                                },
                                                              );
                                                              await returnShopProvider(
                                                                context,
                                                                listen:
                                                                    false,
                                                              ).setFixedDiscount(
                                                                discount:
                                                                    returnShopProvider(
                                                                      context,
                                                                      listen:
                                                                          false,
                                                                    ).generalFixedDiscount ??
                                                                    double.parse(
                                                                      discountPercentController.text,
                                                                    ),
                                                              );
                                                              setState(
                                                                () {
                                                                  isDiscountLoading =
                                                                      false;
                                                                },
                                                              );
                                                            }
                                                          },
                                                        );
                                                      },
                                                    );
                                                  }
                                                }
                                              },
                                              widget: Stack(
                                                alignment:
                                                    AlignmentGeometry.xy(
                                                      0,
                                                      0,
                                                    ),
                                                children: [
                                                  Visibility(
                                                    visible:
                                                        returnShopProvider(
                                                              context,
                                                            ).userShop()?.fixedDiscount ==
                                                            null &&
                                                        returnShopProvider(
                                                              context,
                                                            ).userShop()?.percentDiscount ==
                                                            null,
                                                    child: Stack(
                                                      children: [
                                                        DiscountSetterBody(
                                                          isGeneral:
                                                              true,
                                                          discountPercentController:
                                                              discountPercentController,
                                                        ),
                                                        Visibility(
                                                          visible:
                                                              isDiscountLoading,
                                                          child: ConstrainedBox(
                                                            constraints: BoxConstraints(
                                                              maxWidth:
                                                                  500,
                                                            ),
                                                            child: Container(
                                                              color: const Color.fromARGB(
                                                                47,
                                                                255,
                                                                255,
                                                                255,
                                                              ),
                                                              height:
                                                                  180,
                                                              width:
                                                                  500,
                                                              child: Center(
                                                                child:
                                                                    CircularProgressIndicator(),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Visibility(
                                                    visible:
                                                        returnShopProvider(
                                                              context,
                                                            ).userShop()?.fixedDiscount !=
                                                            null ||
                                                        returnShopProvider(
                                                              context,
                                                            ).userShop()?.percentDiscount !=
                                                            null,
                                                    child: ConstrainedBox(
                                                      constraints: BoxConstraints(
                                                        maxWidth:
                                                            500,
                                                      ),
                                                      child: Stack(
                                                        alignment: AlignmentGeometry.xy(
                                                          0,
                                                          0,
                                                        ),
                                                        children: [
                                                          Container(
                                                            color: const Color.fromARGB(
                                                              47,
                                                              255,
                                                              255,
                                                              255,
                                                            ),
                                                            height:
                                                                250,
                                                            width:
                                                                500,
                                                            child: Center(
                                                              child: Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment.center,
                                                                mainAxisSize:
                                                                    MainAxisSize.min,
                                                                spacing:
                                                                    10,
                                                                children: [
                                                                  Text(
                                                                    style: TextStyle(
                                                                      fontSize:
                                                                          theme.mobileTexts.b1.fontSize,
                                                                      fontWeight:
                                                                          FontWeight.bold,
                                                                    ),
                                                                    'Current Discount Applied',
                                                                  ),
                                                                  Container(
                                                                    height:
                                                                        3,
                                                                    width:
                                                                        200,
                                                                    decoration: BoxDecoration(
                                                                      borderRadius: BorderRadius.circular(
                                                                        10,
                                                                      ),
                                                                      color:
                                                                          theme.lightModeColor.secColor200,
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    height:
                                                                        10,
                                                                  ),
                                                                  Row(
                                                                    spacing:
                                                                        5,
                                                                    mainAxisSize:
                                                                        MainAxisSize.min,
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment.center,
                                                                    children: [
                                                                      Icon(
                                                                        size:
                                                                            20,
                                                                        color:
                                                                            theme.lightModeColor.secColor200,
                                                                        Icons.discount,
                                                                      ),
                                                                      Flexible(
                                                                        child: Text(
                                                                          style: TextStyle(
                                                                            fontSize:
                                                                                theme.mobileTexts.h1.fontSize,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                          ),
                                                                          "${returnShopProvider(context, listen: false).userShop()!.fixedDiscount == null ? '%' : ''}${returnShopProvider(context, listen: false).userShop()!.percentDiscount ?? formatMoneyMid(amount: returnShopProvider(context, listen: false).userShop()!.fixedDiscount ?? 0, context: context)} ",
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  SizedBox(
                                                                    height:
                                                                        10,
                                                                  ),
                                                                  SizedBox(
                                                                    width:
                                                                        300,
                                                                    child: MainButtonP(
                                                                      themeProvider:
                                                                          theme,
                                                                      action: () async {
                                                                        showDialog(
                                                                          context:
                                                                              context,
                                                                          builder: (
                                                                            clearDiscountDialog,
                                                                          ) {
                                                                            return ConfirmationAlert(
                                                                              theme:
                                                                                  theme,
                                                                              message:
                                                                                  'Are you sure you want to clear your current applied discount?',
                                                                              title:
                                                                                  'Clear Discount?',
                                                                              action: () async {
                                                                                setState(
                                                                                  () {
                                                                                    isDiscountLoading =
                                                                                        true;
                                                                                  },
                                                                                );
                                                                                Navigator.of(
                                                                                  clearDiscountDialog,
                                                                                ).pop();
                                                                                await returnShopProvider(
                                                                                  context,
                                                                                  listen:
                                                                                      false,
                                                                                ).setPercentDiscount(
                                                                                  discount:
                                                                                      null,
                                                                                );
                                                                                setState(
                                                                                  () {
                                                                                    isDiscountLoading =
                                                                                        false;
                                                                                  },
                                                                                );
                                                                              },
                                                                            );
                                                                          },
                                                                        );
                                                                      },
                                                                      text:
                                                                          'Clear Discount',
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    width:
                                                                        300,
                                                                    child: MainButtonTransparent(
                                                                      themeProvider:
                                                                          theme,
                                                                      constraints:
                                                                          BoxConstraints(),
                                                                      text:
                                                                          'Cancel',
                                                                      action: () {
                                                                        Navigator.of(
                                                                          confirmDialog,
                                                                        ).pop();
                                                                      },
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                          Visibility(
                                                            visible:
                                                                isDiscountLoading,
                                                            child: Container(
                                                              height:
                                                                  200,
                                                              width:
                                                                  300,
                                                              decoration: BoxDecoration(
                                                                color: const Color.fromARGB(
                                                                  61,
                                                                  255,
                                                                  255,
                                                                  255,
                                                                ),
                                                              ),
                                                              child: Center(
                                                                child:
                                                                    CircularProgressIndicator(),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    ).then((_) {
                                      returnShopProvider(
                                        context,
                                        listen: false,
                                      ).clearDiscountsCache();
                                      discountPercentController
                                          .clear();
                                    });
                                  },
                                );
                              },
                              title: 'Manage Discount',
                              icon: Icons.discount,
                            ),
                          ),
                        ),
                        Visibility(
                          visible: authorization(
                            authorized:
                                Authorizations()
                                    .editReceiptTemplate,
                            context: context,
                          ),

                          child: SubWrapper(
                            isVisible:
                                !GeneralSettingsAuthAction()
                                    .customizeReceiptTemplateAction(
                                      context: context,
                                    ),
                            mainWidget: NavListTileDesktopAlt(
                              height: 18,
                              action: () {
                                GeneralSettingsAuthAction()
                                    .customizeReceiptTemplateAction(
                                      context: context,
                                      action: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (
                                              context,
                                            ) {
                                              return EditReceipt();
                                            },
                                          ),
                                        );
                                      },
                                    );
                              },
                              title:
                                  'Edit Receipt Template',
                              icon: Icons.receipt,
                            ),
                          ),
                        ),
                        Visibility(
                          visible: authorization(
                            authorized:
                                Authorizations()
                                    .generateBarcode,
                            context: context,
                          ),
                          child: SubWrapper(
                            isVisible:
                                !ItemsAuthAction()
                                    .generateBarcodeAction(
                                      context: context,
                                    ),
                            mainWidget: NavListTileDesktopAlt(
                              height: 18,
                              action: () {
                                ItemsAuthAction()
                                    .generateBarcodeAction(
                                      context: context,
                                      action: () {
                                        settingsGenerateProductBarcode(
                                          context,
                                          productSearch,
                                        );
                                      },
                                    );
                              },
                              title:
                                  'Generate Product Barcode',
                              icon: Icons.qr_code_rounded,
                            ),
                          ),
                        ),
                        // NavListTileDesktopAlt(
                        //   height: 18,
                        //   action: () {
                        //     returnSubcsription(
                        //       context,
                        //       listen: false,
                        //     ).select(
                        //       returnSubcsription(
                        //             context,
                        //             listen: false,
                        //           ).subscription?.plan ??
                        //           0,
                        //     );
                        //     showDialog(
                        //       context: context,
                        //       builder: (confirmDialog) {
                        //         return StatefulBuilder(
                        //           builder:
                        //               (
                        //                 context,
                        //                 setState,
                        //               ) => DialogTemplate(
                        //                 theme: theme,
                        //                 message:
                        //                     'Select Another Subcription Plan',
                        //                 title:
                        //                     'Select Plan',
                        //                 action: () async {
                        //                   if (!isChangePlanLoading) {
                        //                     setState(() {
                        //                       isChangePlanLoading =
                        //                           true;
                        //                     });
                        //                     await returnSubcsription(
                        //                       context,
                        //                       listen: false,
                        //                     ).subscribe(
                        //                       plan:
                        //                           returnSubcsription(
                        //                             context,
                        //                             listen:
                        //                                 false,
                        //                           ).selected!,
                        //                       context:
                        //                           context,
                        //                     );
                        //                     returnData(
                        //                       // ignore: use_build_context_synchronously
                        //                       context,
                        //                       listen: false,
                        //                     ).setAllowedRange(
                        //                       // ignore: use_build_context_synchronously
                        //                       context:
                        //                           context,
                        //                       plan:
                        //                           returnSubcsription(
                        //                             // ignore: use_build_context_synchronously
                        //                             context,
                        //                             listen:
                        //                                 false,
                        //                           ).subscription?.plan,
                        //                     );
                        //                     if (confirmDialog
                        //                         .mounted) {
                        //                       Navigator.of(
                        //                         confirmDialog,
                        //                       ).pop();
                        //                     }
                        //                   }
                        //                 },
                        //                 widget: Column(
                        //                   spacing: 5,
                        //                   mainAxisSize:
                        //                       MainAxisSize
                        //                           .min,
                        //                   children:
                        //                       returnSubcsription(
                        //                         context,
                        //                       ).subs.map((
                        //                         sub,
                        //                       ) {
                        //                         return Material(
                        //                           type:
                        //                               MaterialType
                        //                                   .transparency,
                        //                           child: InkWell(
                        //                             onTap: () {
                        //                               returnSubcsription(
                        //                                 context,
                        //                                 listen:
                        //                                     false,
                        //                               ).select(
                        //                                 sub.plan,
                        //                               );
                        //                             },
                        //                             child: Container(
                        //                               decoration: BoxDecoration(
                        //                                 border: Border(
                        //                                   bottom: BorderSide(
                        //                                     color:
                        //                                         Colors.grey.shade100,
                        //                                   ),
                        //                                 ),
                        //                               ),
                        //                               child: Padding(
                        //                                 padding: const EdgeInsets.symmetric(
                        //                                   horizontal:
                        //                                       20.0,
                        //                                   vertical:
                        //                                       10,
                        //                                 ),
                        //                                 child: Column(
                        //                                   mainAxisSize:
                        //                                       MainAxisSize.min,
                        //                                   children: [
                        //                                     Row(
                        //                                       mainAxisAlignment:
                        //                                           MainAxisAlignment.spaceBetween,
                        //                                       children: [
                        //                                         Text(
                        //                                           style: TextStyle(
                        //                                             fontSize:
                        //                                                 theme.mobileTexts.b2.fontSize,
                        //                                           ),
                        //                                           sub.planName,
                        //                                         ),
                        //                                         Stack(
                        //                                           children: [
                        //                                             Visibility(
                        //                                               visible:
                        //                                                   !isChangePlanLoading,
                        //                                               child: Container(
                        //                                                 padding: EdgeInsets.all(
                        //                                                   2,
                        //                                                 ),
                        //                                                 decoration: BoxDecoration(
                        //                                                   shape:
                        //                                                       BoxShape.circle,
                        //                                                   border: Border.all(
                        //                                                     color:
                        //                                                         Colors.grey.shade300,
                        //                                                   ),
                        //                                                 ),
                        //                                                 child: Container(
                        //                                                   padding: EdgeInsets.all(
                        //                                                     6,
                        //                                                   ),
                        //                                                   decoration: BoxDecoration(
                        //                                                     shape:
                        //                                                         BoxShape.circle,
                        //                                                     color:
                        //                                                         returnSubcsription(
                        //                                                                   context,
                        //                                                                 ).selected ==
                        //                                                                 sub.plan
                        //                                                             ? theme.lightModeColor.prColor250
                        //                                                             : Colors.transparent,
                        //                                                   ),
                        //                                                 ),
                        //                                               ),
                        //                                             ),
                        //                                             Visibility(
                        //                                               visible:
                        //                                                   isChangePlanLoading,
                        //                                               child: SizedBox(
                        //                                                 height:
                        //                                                     17,
                        //                                                 width:
                        //                                                     17,
                        //                                                 child: CircularProgressIndicator(
                        //                                                   strokeWidth:
                        //                                                       2,
                        //                                                   color:
                        //                                                       theme.lightModeColor.secColor200,
                        //                                                 ),
                        //                                               ),
                        //                                             ),
                        //                                           ],
                        //                                         ),
                        //                                       ],
                        //                                     ),
                        //                                   ],
                        //                                 ),
                        //                               ),
                        //                             ),
                        //                           ),
                        //                         );
                        //                       }).toList(),
                        //                 ),
                        //               ),
                        //         );
                        //       },
                        //     ).then((_) {
                        //       setState(() {
                        //         isChangePlanLoading = false;
                        //       });
                        //     });
                        //   },
                        //   title: 'Change Subscription Plan',
                        //   icon:
                        //       Icons
                        //           .earbuds_battery_outlined,
                        // ),
                        Visibility(
                          visible: authorization(
                            authorized:
                                Authorizations().manageShop,
                            context: context,
                          ),
                          child: NavListTileDesktopAlt(
                            height: 18,
                            action: () async {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return SubscriptionPage();
                                  },
                                ),
                              ).then((_) {
                                if (context.mounted) {
                                  print(
                                    'Context is mounted',
                                  );
                                  setState(() {});
                                } else {
                                  print(
                                    'Context is not mounted',
                                  );
                                }
                              });
                            },
                            title: 'Manage Subscription',
                            icon:
                                Icons
                                    .workspace_premium_outlined,
                          ),
                        ),
                        Visibility(
                          visible: authorization(
                            authorized:
                                Authorizations()
                                    .contactStockall,
                            context: context,
                          ),
                          child: NavListTileDesktopAlt(
                            height: 18,
                            action: () async {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return ConfirmationAlert(
                                    theme: theme,
                                    message:
                                        'You are about to download and install our official Native application, for better experience.',
                                    title:
                                        screenWidth(
                                                  context,
                                                ) >
                                                tabletScreenSmall
                                            ? 'Proceed to Download Desktop App'
                                            : 'Proceed to Download Mobile App',
                                    action: () async {
                                      Navigator.of(
                                        context,
                                      ).pop();
                                      await downloadApkFromApp(
                                        context: context,
                                      );
                                    },
                                  );
                                },
                              );
                            },
                            title:
                                screenWidth(context) >
                                        tabletScreenSmall
                                    ? 'Download Desktop App'
                                    : 'Download Mobile App',
                            icon: Icons.download_outlined,
                          ),
                        ),
                        Visibility(
                          visible: authorization(
                            authorized:
                                Authorizations()
                                    .contactStockall,
                            context: context,
                          ),
                          child: NavListTileDesktopAlt(
                            height: 18,
                            action: () async {
                              phoneCall();
                            },
                            title:
                                'Contact Us (+234 704 850 7587)',
                            icon: Icons.phone,
                          ),
                        ),
                        Visibility(
                          visible: authorization(
                            authorized:
                                Authorizations()
                                    .contactStockall,
                            context: context,
                          ),
                          child: NavListTileDesktopAlt(
                            height: 14,
                            action: () async {
                              openWhatsApp();
                            },
                            title: 'Chat With Us',
                            svg: whatsappIconSvg,
                          ),
                        ),
                        NavListTileDesktopAlt(
                          height: 20,
                          action: () async {
                            await launchUrlMain(
                              "https://stockallsolution.com/help-center",
                            );
                          },
                          title: 'Visit Help Center',
                          icon: Icons.people_alt_outlined,
                        ),
                        NavListTileDesktopAlt(
                          height: 18,
                          action: () async {
                            await launchUrlMain(
                              "https://stockallsolution.com/privacy-policy",
                            );
                          },
                          title: 'Privacy P. & Terms/C.',
                          icon: Icons.menu_book_rounded,
                        ),
                        NavListTileDesktopAlt(
                          height: 18,
                          action: () async {
                            await launchUrlMain(
                              "https://stockallsolution.com",
                            );
                          },
                          title: 'Go to Wesbite.',
                          icon: Icons.language_rounded,
                        ),
                        Visibility(
                          visible: authorization(
                            authorized:
                                Authorizations().deleteShop,
                            context: context,
                          ),
                          child: NavListTileDesktopAlt(
                            height: 18,
                            action: () {
                              var safeContext = context;
                              var shopP =
                                  returnShopProvider(
                                    context,
                                    listen: false,
                                  );
                              var userP =
                                  returnUserProvider(
                                    context,
                                    listen: false,
                                  );
                              showDialog(
                                context: context,
                                builder: (confirmDialog) {
                                  return ConfirmationAlert(
                                    theme: theme,
                                    message:
                                        'You are about to delete an entire Store, with all its data. You will loose all the data of this store after this process. This Action can not be reversed. Are you sure you want to proceed?',
                                    title: 'Delete Shop?',
                                    action: () async {
                                      Navigator.of(
                                        confirmDialog,
                                      ).pop();
                                      showDialog(
                                        context:
                                            safeContext,
                                        builder: (
                                          newDialog,
                                        ) {
                                          return DialogTemplate(
                                            theme: theme,
                                            message:
                                                'You have to enter your password to verify that you are the owner this shop, in other to delete',
                                            title:
                                                'Enter Password',
                                            action: () async {
                                              var password =
                                                  userP
                                                      .currentUserMain!
                                                      .password;
                                              if (passwordController
                                                  .text
                                                  .isEmpty) {
                                                showDialog(
                                                  // ignore: use_build_context_synchronously
                                                  context:
                                                      context,
                                                  builder: (
                                                    context,
                                                  ) {
                                                    return InfoAlert(
                                                      theme: returnTheme(
                                                        context,
                                                        listen:
                                                            false,
                                                      ),
                                                      message:
                                                          'Password field cannot be empty. You must enter you password in the password field to proceed.',
                                                      title:
                                                          'Password Empty',
                                                    );
                                                  },
                                                );
                                                return;
                                              }
                                              if (password !=
                                                  passwordController
                                                      .text) {
                                                showDialog(
                                                  // ignore: use_build_context_synchronously
                                                  context:
                                                      context,
                                                  builder: (
                                                    context,
                                                  ) {
                                                    return InfoAlert(
                                                      theme: returnTheme(
                                                        context,
                                                        listen:
                                                            false,
                                                      ),
                                                      message:
                                                          'The Password you entered is Incorrect. Please check the password and try again.',
                                                      title:
                                                          'Password Incorrect.',
                                                    );
                                                  },
                                                );
                                                return;
                                              }
                                              Navigator.of(
                                                newDialog,
                                              ).pop();
                                              setState(() {
                                                isLoading =
                                                    true;
                                              });
                                              var res = await shopP
                                                  .deleteShop(
                                                    context:
                                                        context,
                                                  );
                                              if (res ==
                                                  0) {
                                                setState(() {
                                                  isLoading =
                                                      false;
                                                });
                                              }
                                            },
                                            widget: SizedBox(
                                              width:
                                                  double
                                                      .infinity,
                                              child: EmailTextField(
                                                controller:
                                                    passwordController,
                                                theme:
                                                    theme,
                                                isEmail:
                                                    false,
                                                hint:
                                                    'Enter Password',
                                                title:
                                                    'Password',
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  );
                                },
                              );
                            },
                            title: 'Delete Shop',
                            color: Colors.red,
                            icon:
                                Icons
                                    .delete_outline_rounded,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 15),
                  Container(
                    color: Colors.transparent,
                    height: 20,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10.0,
                      ),
                      child: Row(
                        spacing: 10,
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          Row(
                            spacing: 10,
                            mainAxisAlignment:
                                MainAxisAlignment.start,
                            children: [
                              // SizedBox(
                              //   width: 20,
                              //   child: Center(),
                              // ),
                              Text(
                                style: TextStyle(
                                  color:
                                      Colors.grey.shade900,
                                  fontSize:
                                      theme
                                          .mobileTexts
                                          .b3
                                          .fontSize,
                                  fontStyle:
                                      FontStyle.italic,
                                ),
                                'Current App Build: ',
                              ),
                            ],
                          ),
                          Text(
                            style: TextStyle(
                              fontSize:
                                  theme
                                      .mobileTexts
                                      .b2
                                      .fontSize,
                              fontStyle: FontStyle.italic,
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.bold,
                            ),
                            currentUpdate.toString(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  // SizedBox(
                  //   height: screenHeight(context) * 0.2,
                  // ),
                ],
              ),
            ),
          ),
        ),
        Visibility(
          visible: isLoading,
          child: returnCompProvider(
            context,
            listen: false,
          ).showLoader(message: 'Deleting Store'),
        ),
      ],
    );
  }
}
