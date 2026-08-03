import 'package:flutter/material.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/alert_dialogues/dialog_template.dart';
import 'package:stockall/components/pin_code_widget/my_pin_code_widget.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/subscription/subscription_func.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/sales/make_sales/page1/platforms/components/select_sub_staff_list_widget.dart';

class SubStaffSelectionWidget extends StatefulWidget {
  const SubStaffSelectionWidget({super.key});

  @override
  State<SubStaffSelectionWidget> createState() =>
      _SubStaffSelectionWidgetState();
}

class _SubStaffSelectionWidgetState
    extends State<SubStaffSelectionWidget> {
  bool isOpen = false;
  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Visibility(
      visible:
          returnShopProvider(
                context: context,
              ).userShop()?.bulkSale ==
              true &&
          subPlans
              .firstWhere(
                (pl) =>
                    pl.plan ==
                    returnSubcsription(
                      context,
                    ).subscription?.plan,
              )
              .salesAuth
              .bulkSale,
      child: Column(
        children: [
          SizedBox(height: 10),
          Material(
            color: Colors.transparent,
            child: Ink(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Column(
                children: [
                  InkWell(
                    mouseCursor: SystemMouseCursors.click,
                    onTap: () {
                      setState(() {
                        isOpen = !isOpen;
                      });
                    },
                    borderRadius: BorderRadius.circular(5),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        15,
                        6,
                        15,
                        6,
                      ),
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        spacing: 5,
                        children: [
                          Text(
                            style: TextStyle(
                              fontSize:
                                  theme
                                      .mobileTexts
                                      .b4
                                      .fontSize,
                              fontWeight: FontWeight.bold,
                              // color: Colors.white,
                            ),
                            returnSalesProviderContext(
                                      context,
                                    )
                                    .currentMainCart()
                                    .cartName() ??
                                'Default ${returnSalesProviderContext(context).mainCartQueue.indexOf(returnSalesProviderContext(context).currentMainCart()) + 1}',
                          ),
                          Row(
                            spacing: 3,
                            children: [
                              InkWell(
                                mouseCursor:
                                    SystemMouseCursors
                                        .click,
                                onTap: () {
                                  returnSalesProvider()
                                      .addNewMainCart(
                                        context,
                                      );
                                },
                                borderRadius:
                                    BorderRadius.circular(
                                      5,
                                    ),
                                child: Padding(
                                  padding:
                                      EdgeInsetsGeometry.symmetric(
                                        vertical: 8,
                                        horizontal: 10,
                                      ),
                                  child: Icon(
                                    size: 20,
                                    Icons.add,
                                  ),
                                ),
                              ),
                              Visibility(
                                visible:
                                    screenWidth(context) >
                                    mobileScreen,
                                child: Icon(
                                  (screenWidth(context) <
                                              mobileScreen
                                          ? returnSalesProviderContext(
                                            context,
                                          ).isSubStaffSelectionMobileOpen
                                          : isOpen)
                                      ? Icons
                                          .keyboard_arrow_up_outlined
                                      : Icons
                                          .keyboard_arrow_down_outlined,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Visibility(
                    visible:
                        screenWidth(context) < mobileScreen
                            ? returnSalesProviderContext(
                              context,
                            ).isSubStaffSelectionMobileOpen
                            : isOpen,
                    child: SizedBox(
                      height: 300,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          15,
                          0,
                          15,
                          10,
                        ),
                        child: Column(
                          children: [
                            Divider(),
                            Expanded(
                              child: ListView(
                                shrinkWrap: true,
                                children:
                                    returnSalesProviderContext(
                                          context,
                                        ).mainCartQueue
                                        .map(
                                          (cart) => InkWell(
                                            mouseCursor:
                                                SystemMouseCursors
                                                    .click,
                                            onTap: () {
                                              returnSalesProvider()
                                                  .selectMainCart(
                                                    cart.mainCartId!,
                                                  );
                                            },
                                            child: Padding(
                                              padding:
                                                  EdgeInsetsGeometry.fromLTRB(
                                                    8,
                                                    2,
                                                    2,
                                                    2,
                                                  ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.center,
                                                    spacing:
                                                        5,
                                                    children: [
                                                      Icon(
                                                        size:
                                                            14,
                                                        color:
                                                            Colors.grey.shade400,
                                                        Icons.book,
                                                      ),
                                                      Text(
                                                        style: TextStyle(
                                                          fontSize:
                                                              theme.mobileTexts.b4.fontSize,
                                                          fontWeight:
                                                              returnSalesProviderContext(
                                                                        context,
                                                                      ).currentMainCart().mainCartId ==
                                                                      cart.mainCartId
                                                                  ? FontWeight.bold
                                                                  : null,
                                                        ),
                                                        cart.cartName() ??
                                                            'Default  ${returnSalesProviderContext(context).mainCartQueue.indexOf(cart) + 1}',
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    height:
                                                        40,
                                                    child: Row(
                                                      spacing:
                                                          5,
                                                      children: [
                                                        Visibility(
                                                          visible:
                                                              returnSalesProviderContext(
                                                                    context,
                                                                  ).mainCartQueue.length >
                                                                  1 ||
                                                              cart.subStaff !=
                                                                  null,
                                                          child: IconButton(
                                                            mouseCursor:
                                                                SystemMouseCursors.click,
                                                            onPressed: () {
                                                              if (cart.subStaff ==
                                                                  null) {
                                                                if (returnSalesProvider().mainCartQueue.length >
                                                                    1) {
                                                                  showDialog(
                                                                    context:
                                                                        context,
                                                                    builder: (
                                                                      context,
                                                                    ) {
                                                                      return ConfirmationAlert(
                                                                        theme:
                                                                            theme,
                                                                        message:
                                                                            'You are about to Delete Entire Bulk Sale Terminal, This action can not be reversed are you sure you want to proceed?',
                                                                        title:
                                                                            'Are you sure?',
                                                                        action: () async {
                                                                          if (!returnSalesProvider().canDeleteMainCart(
                                                                            cartMain:
                                                                                cart,
                                                                          )) {
                                                                            var res = await pinCodeAction(
                                                                              isMain:
                                                                                  true,
                                                                              context:
                                                                                  context,
                                                                            );
                                                                            if (res) {
                                                                              returnSalesProvider().deleteMainCart(
                                                                                cart.mainCartId!,
                                                                              );
                                                                              Navigator.of(
                                                                                context,
                                                                              ).pop();
                                                                            }
                                                                          } else {
                                                                            returnSalesProvider().deleteMainCart(
                                                                              cart.mainCartId!,
                                                                            );
                                                                            Navigator.of(
                                                                              context,
                                                                            ).pop();
                                                                          }
                                                                        },
                                                                      );
                                                                    },
                                                                  );
                                                                }
                                                              } else {
                                                                showDialog(
                                                                  context:
                                                                      context,
                                                                  builder: (
                                                                    context,
                                                                  ) {
                                                                    return ConfirmationAlert(
                                                                      theme:
                                                                          theme,
                                                                      message:
                                                                          'You are about to Remove this Staff from this Bulk Sale Terminal, This action can not be reversed are you sure you want to proceed?',
                                                                      title:
                                                                          'Remove Staff',
                                                                      action: () async {
                                                                        if (!returnSalesProvider().canDeleteMainCart(
                                                                          cartMain:
                                                                              cart,
                                                                        )) {
                                                                          var res = await pinCodeAction(
                                                                            isMain:
                                                                                false,
                                                                            context:
                                                                                context,
                                                                          );
                                                                          if (res) {
                                                                            returnSalesProvider().removeStaffFromMainCart(
                                                                              cart.mainCartId!,
                                                                            );
                                                                            // await mainLocalLog(
                                                                            //   cart.subStaff?.staffName,
                                                                            // );
                                                                            Navigator.of(
                                                                              context,
                                                                            ).pop();
                                                                          }
                                                                        } else {
                                                                          returnSalesProvider().removeStaffFromMainCart(
                                                                            cart.mainCartId!,
                                                                          );
                                                                          // await mainLocalLog(
                                                                          //   cart.subStaff?.staffName,
                                                                          // );
                                                                          Navigator.of(
                                                                            context,
                                                                          ).pop();
                                                                        }
                                                                      },
                                                                    );
                                                                  },
                                                                );
                                                              }
                                                            },
                                                            icon: Icon(
                                                              size:
                                                                  18,
                                                              color:
                                                                  Colors.red,
                                                              Icons.clear,
                                                            ),
                                                          ),
                                                        ),
                                                        Visibility(
                                                          visible:
                                                              cart.subStaff ==
                                                              null,
                                                          child: InkWell(
                                                            mouseCursor:
                                                                SystemMouseCursors.click,
                                                            onTap: () {
                                                              showDialog(
                                                                context:
                                                                    context,
                                                                builder: (
                                                                  templateDialog,
                                                                ) {
                                                                  return DialogTemplate(
                                                                    theme:
                                                                        theme,
                                                                    message:
                                                                        'Select a Sub Staff to add to this.',
                                                                    topRightWidget:
                                                                        screenWidth(
                                                                                  context,
                                                                                ) >
                                                                                mobileScreen
                                                                            ? IconButton(
                                                                              mouseCursor:
                                                                                  SystemMouseCursors.click,
                                                                              onPressed: () {
                                                                                returnSubStaffProvider().getSubStaffs();
                                                                              },
                                                                              icon: Icon(
                                                                                size:
                                                                                    20,
                                                                                color:
                                                                                    Colors.grey,
                                                                                Icons.refresh_outlined,
                                                                              ),
                                                                            )
                                                                            : null,
                                                                    title:
                                                                        'Select Sub Staff',
                                                                    action: () async {
                                                                      if (!returnSalesProvider().canDeleteMainCart(
                                                                        cartMain:
                                                                            cart,
                                                                      )) {
                                                                        var res = await pinCodeAction(
                                                                          isMain:
                                                                              false,
                                                                          context:
                                                                              context,
                                                                        );
                                                                        if (res) {
                                                                          if (returnSalesProvider().selectedSubStaff !=
                                                                              null) {
                                                                            await returnSalesProvider().addSubStaffToMainCart(
                                                                              cart.mainCartId!,
                                                                            );
                                                                            Navigator.of(
                                                                              templateDialog,
                                                                            ).pop();
                                                                          }
                                                                        }
                                                                      } else {
                                                                        await returnSalesProvider().addSubStaffToMainCart(
                                                                          cart.mainCartId!,
                                                                        );
                                                                        Navigator.of(
                                                                          templateDialog,
                                                                        ).pop();
                                                                      }
                                                                    },
                                                                    widget: SelectSubStaffListWidget(
                                                                      staff:
                                                                          cart.subStaff,
                                                                    ),
                                                                  );
                                                                },
                                                              ).then(
                                                                (
                                                                  _,
                                                                ) {
                                                                  returnSalesProvider().selectSubStaff();
                                                                },
                                                              );
                                                            },
                                                            child: Padding(
                                                              padding: EdgeInsetsGeometry.all(
                                                                8,
                                                              ),
                                                              child: Icon(
                                                                size:
                                                                    18,
                                                                color:
                                                                    Colors.grey,
                                                                Icons.edit,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                              ),
                            ),
                            Divider(),
                          ],
                        ),
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
  }
}
