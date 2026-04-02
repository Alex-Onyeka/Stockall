import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_storage_product/temp_storage_products.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/alert_dialogues/dialog_template.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/components/major/empty_widget_display_only.dart';
import 'package:stockall/components/text_fields/edit_cart_text_field.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/providers/theme_provider.dart';

void updateStorageQuantity({
  required TempStorageProducts product,
  required BuildContext context,
  required ThemeProvider theme,
  Function()? action,
}) {
  showDialog(
    context: context,
    builder: (firstContext) {
      return StatefulBuilder(
        builder:
            (context, setState) => DialogTemplate(
              theme: theme,
              message: 'Enter Details',
              title: 'Update Unit Quantity',
              topRightWidget:
                  returnStorageProductProvider(
                        context: context,
                      ).isLoading
                      ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color:
                              theme
                                  .lightModeColor
                                  .secColor200,
                        ),
                      )
                      : null,
              action: () {},
              showBottomActionButtons: false,
              widget: StorageQuantityUpdateWidget(
                product: product,
              ),
            ),
      );
    },
  );
}

class StorageQuantityUpdateWidget extends StatefulWidget {
  final TempStorageProducts product;
  const StorageQuantityUpdateWidget({
    super.key,
    required this.product,
  });

  @override
  State<StorageQuantityUpdateWidget> createState() =>
      _StorageQuantityUpdateWidgetState();
}

class _StorageQuantityUpdateWidgetState
    extends State<StorageQuantityUpdateWidget> {
  final quantityController = TextEditingController();
  int currentIndex = 0;
  String? departmentUuid;
  String? staffUuid;
  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Column(
      spacing: 10,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          spacing: 5,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ToggleButton(
              theme: theme,
              currentIndex: currentIndex,
              myIndex: 0,
              title: 'Stock-In',
              action: () {
                setState(() {
                  currentIndex = 0;
                  departmentUuid = null;
                  staffUuid = null;
                });
              },
            ),
            ToggleButton(
              theme: theme,
              currentIndex: currentIndex,
              myIndex: 1,
              title: 'Stock-Out',
              action: () {
                setState(() {
                  currentIndex = 1;
                  departmentUuid = null;
                  staffUuid = null;
                });
                if (((widget.product.quantity ?? 0) -
                        ((double.tryParse(
                              (quantityController.text
                                  .replaceAll(',', '')),
                            ) ??
                            0)) <
                    0)) {
                  setState(() {
                    quantityController.text = '0';
                  });
                }
              },
            ),
            ToggleButton(
              theme: theme,
              currentIndex: currentIndex,
              myIndex: 2,
              title: 'Update',
              action: () {
                setState(() {
                  currentIndex = 2;
                  departmentUuid = null;
                  staffUuid = null;
                });
              },
            ),
          ],
        ),
        SizedBox(height: 5),
        EditCartTextField(
          title: 'Quantity',
          hint: 'Enter Quantity',
          controller: quantityController,
          theme: theme,
          showTitle: false,
          onChanged: (value) {
            if (currentIndex == 1) {
              if (((widget.product.quantity ?? 0) -
                      (double.parse(
                        (quantityController.text.replaceAll(
                          ',',
                          '',
                        )),
                      )) <
                  0)) {
                setState(() {
                  quantityController.text = '0';
                });
              }
            }
          },
        ),
        Visibility(
          visible: currentIndex == 1,
          child: Column(
            children: [
              SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing:
                    returnShopProvider()
                                .userShop()
                                ?.manageDepartments ==
                            true
                        ? 10
                        : 0,
                children: [
                  Visibility(
                    visible:
                        returnShopProvider()
                            .userShop()
                            ?.manageDepartments ==
                        true,
                    child: SelectDepartmentButton(
                      theme: theme,
                      title:
                          returnDepartmentProvider()
                                  .departments
                                  .where(
                                    (dept) =>
                                        dept.uuid ==
                                        departmentUuid,
                                  )
                                  .isNotEmpty
                              ? cutLongText(
                                returnDepartmentProvider()
                                    .departments
                                    .where(
                                      (dept) =>
                                          dept.uuid ==
                                          departmentUuid,
                                    )
                                    .first
                                    .name,
                                10,
                              )
                              : 'Department',
                      action: () {
                        showDialog(
                          context: context,
                          builder: (deptContext) {
                            return DialogTemplate(
                              theme: theme,
                              message:
                                  'Choose from the List of Departments below',
                              title: 'Select Department',
                              action: () {},
                              showBottomActionButtons:
                                  false,
                              widget: SizedBox(
                                height:
                                    screenHeight(context) -
                                    250,
                                child: Builder(
                                  builder: (context) {
                                    if (returnDepartmentProvider()
                                        .departments
                                        .isEmpty) {
                                      return EmptyWidgetDisplayOnly(
                                        title:
                                            'No Departments',
                                        subText:
                                            'You have not created any departments',
                                        theme: theme,
                                        height: 30,
                                        icon: Icons.clear,
                                      );
                                    } else {
                                      return Column(
                                        spacing: 5,
                                        children:
                                            returnDepartmentProvider()
                                                .departments
                                                .map(
                                                  (
                                                    dept,
                                                  ) => InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        departmentUuid =
                                                            dept.uuid;
                                                      });
                                                      Navigator.of(
                                                        deptContext,
                                                      ).pop();
                                                    },
                                                    child: Padding(
                                                      padding: EdgeInsetsGeometry.symmetric(
                                                        vertical:
                                                            10,
                                                        horizontal:
                                                            10,
                                                      ),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment.spaceBetween,
                                                        spacing:
                                                            5,
                                                        children: [
                                                          Row(
                                                            spacing:
                                                                5,
                                                            children: [
                                                              Icon(
                                                                size:
                                                                    14,
                                                                color:
                                                                    theme.lightModeColor.prColor300,
                                                                Icons.width_normal_rounded,
                                                              ),
                                                              Text(
                                                                style: TextStyle(
                                                                  fontSize:
                                                                      theme.mobileTexts.b4.fontSize,
                                                                  fontWeight:
                                                                      FontWeight.bold,
                                                                ),
                                                                dept.name,
                                                              ),
                                                            ],
                                                          ),
                                                          Icon(
                                                            size:
                                                                16,
                                                            color:
                                                                Colors.grey,
                                                            departmentUuid ==
                                                                    dept.uuid
                                                                ? Icons.check
                                                                : Icons.add,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                )
                                                .toList(),
                                      );
                                    }
                                  },
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  SelectDepartmentButton(
                    theme: theme,
                    title:
                        returnUserProviderSingle().usersMain
                                .where(
                                  (user) =>
                                      user.userId ==
                                      staffUuid,
                                )
                                .isNotEmpty
                            ? cutLongText(
                              returnUserProviderSingle()
                                  .usersMain
                                  .where(
                                    (user) =>
                                        user.userId ==
                                        staffUuid,
                                  )
                                  .first
                                  .name,
                              10,
                            )
                            : 'Staff',
                    action: () {
                      showDialog(
                        context: context,
                        builder: (userContext) {
                          return DialogTemplate(
                            theme: theme,
                            message:
                                'Choose from the List of Staffs below',
                            title: 'Select Staff',
                            action: () {},
                            showBottomActionButtons: false,
                            widget: SizedBox(
                              height:
                                  screenHeight(context) -
                                  250,
                              child: Builder(
                                builder: (context) {
                                  if (returnUserProviderSingle()
                                      .usersMain
                                      .isEmpty) {
                                    return EmptyWidgetDisplayOnly(
                                      title: 'No Staffs',
                                      subText:
                                          'You have not created any Staffs',
                                      theme: theme,
                                      height: 30,
                                      icon: Icons.clear,
                                    );
                                  } else {
                                    return Column(
                                      spacing: 5,
                                      children:
                                          returnUserProviderSingle()
                                              .usersMain
                                              .map(
                                                (
                                                  user,
                                                ) => InkWell(
                                                  onTap: () {
                                                    setState(() {
                                                      staffUuid =
                                                          user.userId;
                                                    });
                                                    Navigator.of(
                                                      userContext,
                                                    ).pop();
                                                  },
                                                  child: Padding(
                                                    padding: EdgeInsetsGeometry.symmetric(
                                                      vertical:
                                                          10,
                                                      horizontal:
                                                          10,
                                                    ),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.spaceBetween,
                                                      spacing:
                                                          5,
                                                      children: [
                                                        Row(
                                                          spacing:
                                                              5,
                                                          children: [
                                                            Icon(
                                                              size:
                                                                  14,
                                                              color:
                                                                  theme.lightModeColor.prColor300,
                                                              Icons.width_normal_rounded,
                                                            ),
                                                            Text(
                                                              style: TextStyle(
                                                                fontSize:
                                                                    theme.mobileTexts.b4.fontSize,
                                                                fontWeight:
                                                                    FontWeight.bold,
                                                              ),
                                                              user.name,
                                                            ),
                                                          ],
                                                        ),
                                                        Icon(
                                                          size:
                                                              16,
                                                          color:
                                                              Colors.grey,
                                                          staffUuid ==
                                                                  user.userId
                                                              ? Icons.check
                                                              : Icons.add,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              )
                                              .toList(),
                                    );
                                  }
                                },
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        Row(
          spacing: 15,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Ink(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Colors.grey.shade200,
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),

                    child: Center(
                      child: Text(
                        style: TextStyle(
                          fontSize:
                              theme.mobileTexts.b3.fontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                        'Cancel',
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Ink(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: theme.lightModeColor.errorColor200,
                ),
                child: InkWell(
                  onTap: () {
                    if (quantityController
                        .text
                        .isNotEmpty) {
                      showDialog(
                        context: context,
                        builder: (actionContext) {
                          return ConfirmationAlert(
                            theme: theme,
                            message:
                                'You are about to update the quantity of This item in Storage. Are you sure you want to proceed?',
                            title: 'Update Stock',
                            action: () async {
                              TempStorageProducts
                              newProduct =
                                  TempStorageProducts(
                                    shopId: shopId(),
                                    name:
                                        widget.product.name,
                                    createdAt:
                                        widget
                                            .product
                                            .createdAt,
                                    desc:
                                        widget.product.desc,
                                    groupUnit:
                                        widget
                                            .product
                                            .groupUnit,
                                    quantity:
                                        widget
                                            .product
                                            .quantity,
                                    unit:
                                        widget.product.unit,
                                    updatedAt:
                                        DateTime.now(),
                                    uuid:
                                        widget.product.uuid,
                                  );
                              Navigator.of(
                                actionContext,
                              ).pop();
                              returnStorageProductProvider()
                                  .toggleIsLoading(true);
                              if (currentIndex == 0) {
                                newProduct.quantity =
                                    ((widget
                                                .product
                                                .quantity ??
                                            0) +
                                        ((double.tryParse(
                                              quantityController
                                                  .text
                                                  .replaceAll(
                                                    ',',
                                                    '',
                                                  ),
                                            ) ??
                                            0)));
                              } else if (currentIndex ==
                                  1) {
                                newProduct.quantity =
                                    ((widget
                                                .product
                                                .quantity ??
                                            0) -
                                        ((double.tryParse(
                                              quantityController
                                                  .text
                                                  .replaceAll(
                                                    ',',
                                                    '',
                                                  ),
                                            ) ??
                                            0)));
                              } else {
                                newProduct.quantity =
                                    (((double.tryParse(
                                          quantityController
                                              .text
                                              .replaceAll(
                                                ',',
                                                '',
                                              ),
                                        ) ??
                                        0)));
                              }
                              var res =
                                  await returnStorageProductProvider()
                                      .updateProduct(
                                        product: newProduct,
                                      );
                              if (currentIndex == 1) {
                                var prs = returnData()
                                    .productListMain
                                    .where((pr) {
                                      if (departmentUuid !=
                                          null) {
                                        return pr.storageUuid ==
                                                widget
                                                    .product
                                                    .uuid &&
                                            pr.departmentUuid ==
                                                departmentUuid;
                                      } else {
                                        return pr
                                                .storageUuid ==
                                            widget
                                                .product
                                                .uuid;
                                      }
                                    });
                                if (prs.isNotEmpty) {
                                  var newPr =
                                      prs.first.copyWith();
                                  newPr.quantity =
                                      ((newPr.quantity ??
                                              0) +
                                          ((double.tryParse(
                                                quantityController
                                                    .text
                                                    .replaceAll(
                                                      ',',
                                                      '',
                                                    ),
                                              ) ??
                                              0)));
                                  await returnData()
                                      .updateProduct(
                                        product: newPr,
                                      );
                                }
                              }
                              returnStorageProductProvider()
                                  .toggleIsLoading(false);
                              if (res == 0) {
                                showDialog(
                                  // ignore: use_build_context_synchronously
                                  context: context,
                                  builder: (errorContext) {
                                    return InfoAlert(
                                      theme: theme,
                                      message:
                                          'An Error occoured while updating Your Stock. Please Try Again.',
                                      title:
                                          'An Error Occoured.',
                                    );
                                  },
                                );
                              } else {
                                Navigator.of(context).pop();
                              }
                            },
                          );
                        },
                      );
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),

                    child: Center(
                      child: Text(
                        style: TextStyle(
                          fontSize:
                              theme.mobileTexts.b3.fontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        'Proceed',
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class SelectDepartmentButton extends StatelessWidget {
  const SelectDepartmentButton({
    super.key,
    required this.theme,
    required this.title,
    this.action,
  });

  final ThemeProvider theme;
  final String title;
  final Function()? action;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: action,
      child: Padding(
        padding: EdgeInsetsGeometry.symmetric(
          vertical: 10,
          horizontal: 20,
        ),
        child: Center(
          child: Row(
            spacing: 5,
            children: [
              Icon(size: 16, color: Colors.grey, Icons.add),
              Text(
                style: TextStyle(
                  fontSize: theme.mobileTexts.b3.fontSize,
                ),
                title,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ToggleButton extends StatelessWidget {
  const ToggleButton({
    super.key,
    required this.theme,
    required this.myIndex,
    required this.currentIndex,
    required this.title,
    this.action,
  });

  final ThemeProvider theme;
  final int currentIndex;
  final int myIndex;
  final String title;
  final Function()? action;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            color:
                currentIndex == myIndex
                    ? const Color.fromARGB(20, 255, 127, 7)
                    : null,
            border: Border(
              bottom: BorderSide(
                color:
                    currentIndex == myIndex
                        ? const Color.fromARGB(
                          255,
                          255,
                          139,
                          7,
                        )
                        : Colors.grey.shade500,
                width: currentIndex == myIndex ? 1 : 0,
              ),
            ),
          ),
          child: InkWell(
            onTap: action,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 10,
              ),
              child: Center(
                child: Text(
                  style: TextStyle(
                    fontSize: theme.mobileTexts.b4.fontSize,
                    fontWeight:
                        currentIndex == myIndex
                            ? FontWeight.bold
                            : null,
                  ),
                  title,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
