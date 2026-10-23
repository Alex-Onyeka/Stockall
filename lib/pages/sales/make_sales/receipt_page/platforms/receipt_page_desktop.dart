import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stockall/classes/checkout_response.dart';
import 'package:stockall/classes/payment_entry/payment_entry.dart';
import 'package:stockall/classes/temp_customers/temp_customers_class.dart';
import 'package:stockall/classes/temp_main_receipt/temp_main_receipt.dart';
import 'package:stockall/classes/temp_product_slaes_record/temp_product_sale_record.dart';
import 'package:stockall/classes/user_class/temp_user_class.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/generate_barcode.dart';
import 'package:stockall/constants/subscription/sales_auth.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/authentication/base_page/base_page.dart';
import 'package:stockall/pages/sales/make_sales/page1/make_sales_page.dart';
import 'package:stockall/services/auth_service.dart';
import 'package:stockall/services/printing/import_helper.dart'
    show scanBluetoothPrinters;

class ReceiptPageDesktop extends StatefulWidget {
  final bool isMain;
  final CheckoutResponse response;
  const ReceiptPageDesktop({
    super.key,
    required this.response,
    required this.isMain,
  });

  @override
  State<ReceiptPageDesktop> createState() =>
      _ReceiptPageDesktopState();
}

class _ReceiptPageDesktopState
    extends State<ReceiptPageDesktop> {
  bool isLoading = false;
  bool isDeleteLoading = false;
  bool isPrintLoading = false;
  bool isDownloadLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      returnReceiptProvider(
        context,
        listen: false,
      ).toggleIsLoading(false);
      await returnShopProvider().getLogoImage(context);
      returnShopProvider().switchLogoPicked(false);
      if (mounted) setState(() {});
    });
    if (widget.isMain) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final shop = returnShopProvider().userShop();
        if (shop?.shopId != null) {
          returnReceiptProvider(
            context,
            listen: false,
          ).loadReceiptsOffline(shop!.shopId!);
        }
      });
    }
  }

  void _navigateBack() {
    if (widget.isMain) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MakeSalesPage(),
        ),
      );
    } else if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => BasePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var shop = returnShopProvider().userShop();
    var theme = returnTheme(context);

    TempMainReceipt defaultReceipt = TempMainReceipt(
      tempItems: null,
      salesTypeIndex: 1,
      orderUuid: null,
      customerAccount: 0,
      comment: null,
      subStaffName: null,
      departmentName:
          returnDepartmentProvider()
              .currentDepartment()
              ?.name,
      departmentUuidNew:
          returnDepartmentProvider()
              .currentDepartment()
              ?.uuid,
      createdAt: DateTime.now(),
      uuid: '1',
      shopId: shopId(),
      staffId: AuthService().currentUser!,
      staffName: 'Staff Name',
      paymentMethod: 'Cash',
      bank: 0,
      cashAlt: 0,
      isInvoice: false,
      cartName: 'Cart 1',
    );

    TempMainReceipt mainReceipt =
        widget.response.receipt ?? defaultReceipt;

    List<TempProductSaleRecord> records =
        mainReceipt.getItemsNoVoid();
    List<TempProductSaleRecord> recordsVoid =
        mainReceipt.getItemsVoid();

    String? customer;
    TempCustomersClass? customersClass;

    var customers = returnCustomers(context)
        .customersMain()
        .where((c) => c.uuid == mainReceipt.customerUuid);
    if (customers.isNotEmpty) {
      customersClass = customers.first;
    } else {
      customer = mainReceipt.customerName;
    }

    TempUserClass? staff;
    try {
      staff = returnUserProvider(
        context,
      ).usersMain.firstWhere(
        (c) => c.userId == mainReceipt.staffId,
      );
    } catch (e) {
      staff = null;
    }

    final String cashierName =
        staff?.name ??
        mainReceipt.staffName ??
        'Staff Name';

    final String ticketId =
        mainReceipt.barcode ??
        returnOnlyDigits(mainReceipt.uuid ?? '');

    final double totalRevenue = returnReceiptProvider(
      context,
      listen: false,
    ).getTotalMainRevenueReceipt(mainReceipt);

    final double originalCost = returnReceiptProvider(
      context,
      listen: false,
    ).getOriginalCostReceipt(mainReceipt);

    final double discountAmount = returnReceiptProvider(
      context,
      listen: false,
    ).getDiscountAmountForReceipt(mainReceipt);

    final double vatAmount = returnReceiptProvider(
      context,
      listen: false,
    ).getVATForReceipt(mainReceipt);

    final double remainingBalance =
        mainReceipt.balance ?? 0;
    final double amountPaid =
        (totalRevenue - remainingBalance) > 0
            ? (totalRevenue - remainingBalance)
            : totalRevenue;

    final bool isPartial = remainingBalance > 0;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _navigateBack();
      },
      child: Scaffold(
        backgroundColor: const Color.fromARGB(
          255,
          253,
          254,
          255,
        ),
        body: Column(
          spacing: 15,
          children: [
            // Top App Bar
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 30,
                vertical: 20,
              ),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey.shade200,
                  ),
                ),
                color: Colors.white,
              ),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                spacing: 10,
                children: [
                  Row(
                    spacing: 10,
                    children: [
                      InkWell(
                        mouseCursor:
                            SystemMouseCursors.click,
                        onTap: _navigateBack,
                        borderRadius: BorderRadius.circular(
                          30,
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.grey.shade200,
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            size: 18,
                            color: Colors.grey.shade700,
                            Icons
                                .arrow_back_ios_new_outlined,
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        spacing: 5,
                        children: [
                          Row(
                            spacing: 2,
                            children: [
                              Text(
                                style: TextStyle(
                                  fontSize:
                                      theme
                                          .mobileTexts
                                          .b3
                                          .fontSize,
                                ),
                                'Receipt',
                              ),
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
                                '[ #$ticketId ]',
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
                              fontWeight: FontWeight.bold,
                            ),
                            customersClass?.name ??
                                customer ??
                                'Customer Name',
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    spacing: 5,
                    children: [
                      // Printer Type Picker
                      PopupMenuButton<int>(
                        offset: const Offset(-20, 30),
                        color: Colors.white,
                        onSelected: (int type) {
                          if (returnShopProvider()
                                  .userShop()
                                  ?.printType !=
                              type) {
                            returnShopProvider()
                                .updatePrintType(
                                  shopId: shopId(),
                                  type: type,
                                );
                            setState(() {});
                          }
                        },
                        itemBuilder: (context) {
                          final currentType =
                              returnShopProvider()
                                  .userShop()
                                  ?.printType;
                          return [
                            PopupMenuItem<int>(
                              value: 1,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment
                                        .spaceBetween,
                                children: [
                                  Text(
                                    'Printer Type -- 58mm',
                                    style: TextStyle(
                                      fontSize:
                                          theme
                                              .mobileTexts
                                              .b2
                                              .fontSize,
                                      fontWeight:
                                          currentType == 1
                                              ? FontWeight
                                                  .bold
                                              : null,
                                    ),
                                  ),
                                  if (currentType == 1)
                                    Icon(
                                      size: 17,
                                      color:
                                          Colors
                                              .grey
                                              .shade700,
                                      Icons.check,
                                    ),
                                ],
                              ),
                            ),
                            PopupMenuItem<int>(
                              value: 2,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment
                                        .spaceBetween,
                                children: [
                                  Text(
                                    'Printer Type -- 80mm',
                                    style: TextStyle(
                                      fontSize:
                                          theme
                                              .mobileTexts
                                              .b2
                                              .fontSize,
                                      fontWeight:
                                          currentType == 2
                                              ? FontWeight
                                                  .bold
                                              : null,
                                    ),
                                  ),
                                  if (currentType == 2)
                                    Icon(
                                      size: 17,
                                      color:
                                          Colors
                                              .grey
                                              .shade700,
                                      Icons.check,
                                    ),
                                ],
                              ),
                            ),
                          ];
                        },
                        child: ActionButtonSmall(
                          action: null,
                          text:
                              returnShopProvider()
                                          .userShop()
                                          ?.printType ==
                                      2
                                  ? '80mm'
                                  : '58mm',
                          icon: Icon(
                            Icons.arrow_drop_down,
                            size: 16,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                      // Print Button
                      ActionButtonSmall(
                        isLoading: isPrintLoading,
                        action: () {
                          SalesAuthAction().printReceiptAction(
                            context: context,
                            action: () async {
                              final safeContext = context;
                              if (returnShopProvider()
                                      .userShop()
                                      ?.printType ==
                                  null) {
                                showDialog(
                                  context: context,
                                  builder: (dialogCtx) {
                                    return AlertDialog(
                                      backgroundColor:
                                          Colors.white,
                                      title: const Text(
                                        'SELECT PRINTER TYPE',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight:
                                              FontWeight
                                                  .bold,
                                        ),
                                      ),
                                      content: Column(
                                        mainAxisSize:
                                            MainAxisSize
                                                .min,
                                        children: [
                                          Divider(
                                            color:
                                                Colors
                                                    .grey
                                                    .shade200,
                                            height: 0,
                                          ),
                                          ListTile(
                                            onTap: () async {
                                              Navigator.of(
                                                dialogCtx,
                                              ).pop();
                                              await returnShopProvider()
                                                  .updatePrintType(
                                                    shopId:
                                                        shopId(),
                                                    type: 1,
                                                  );
                                              setState(
                                                () {},
                                              );
                                            },
                                            title: const Text(
                                              'Select Paper Size -- 58mm',
                                              style: TextStyle(
                                                fontSize:
                                                    12,
                                                fontWeight:
                                                    FontWeight
                                                        .bold,
                                              ),
                                            ),
                                          ),
                                          Divider(
                                            color:
                                                Colors
                                                    .grey
                                                    .shade200,
                                            height: 5,
                                          ),
                                          ListTile(
                                            onTap: () async {
                                              Navigator.of(
                                                dialogCtx,
                                              ).pop();
                                              await returnShopProvider()
                                                  .updatePrintType(
                                                    shopId:
                                                        shopId(),
                                                    type: 2,
                                                  );
                                              setState(
                                                () {},
                                              );
                                            },
                                            title: const Text(
                                              'Select Paper Size -- 80mm',
                                              style: TextStyle(
                                                fontSize:
                                                    12,
                                                fontWeight:
                                                    FontWeight
                                                        .bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              } else {
                                showDialog(
                                  context: context,
                                  builder: (confirmDialog) {
                                    return ConfirmationAlert(
                                      theme: theme,
                                      message:
                                          'You are about to Print This Receipt. Are you sure you want to Proceed?',
                                      title:
                                          'Print Receipt',
                                      action: () async {
                                        setState(() {
                                          isPrintLoading =
                                              true;
                                        });
                                        Navigator.of(
                                          confirmDialog,
                                        ).pop();

                                        final currentShop =
                                            returnShopProvider()
                                                .userShop()!;

                                        if (kIsWeb) {
                                          downloadPdfWebRoll(
                                            staffName:
                                                cashierName,
                                            filename:
                                                'Stockall_Receipt_${DateTime.now().millisecondsSinceEpoch}.pdf',
                                            context:
                                                safeContext,
                                            receipt:
                                                mainReceipt,
                                            records:
                                                records,
                                            shop:
                                                currentShop,
                                            printType:
                                                currentShop
                                                    .printType ??
                                                1,
                                          );
                                        } else if (usesBluetoothPrint()) {
                                          scanBluetoothPrinters(
                                            receipt:
                                                mainReceipt,
                                            context:
                                                safeContext,
                                            records:
                                                records,
                                            shop:
                                                currentShop,
                                            staffName:
                                                cashierName,
                                          );
                                        } else {
                                          await generateAndPreviewPdfRoll(
                                            printerType:
                                                currentShop
                                                    .printType ??
                                                1,
                                            staffName:
                                                cashierName,
                                            context:
                                                safeContext,
                                            receipt:
                                                mainReceipt,
                                            records:
                                                records,
                                            shop:
                                                currentShop,
                                          );
                                        }

                                        setState(() {
                                          isPrintLoading =
                                              false;
                                        });
                                      },
                                    );
                                  },
                                );
                              }
                            },
                          );
                        },
                        text: 'Print',
                      ),
                      // Download Button
                      ActionButtonSmall(
                        isLoading: isDownloadLoading,
                        action: () {
                          SalesAuthAction().downloadReceiptAction(
                            context: context,
                            action: () async {
                              final safeContext = context;
                              showDialog(
                                context: context,
                                builder: (confirmDialog) {
                                  return ConfirmationAlert(
                                    theme: theme,
                                    message:
                                        'You are about to download This Receipt. Are you sure you want to Proceed?',
                                    title:
                                        'Download Receipt',
                                    action: () async {
                                      setState(() {
                                        isDownloadLoading =
                                            true;
                                      });
                                      Navigator.of(
                                        confirmDialog,
                                      ).pop();

                                      final currentShop =
                                          returnShopProvider()
                                              .userShop()!;

                                      if (kIsWeb) {
                                        downloadPdfWeb(
                                          staffName:
                                              cashierName,
                                          filename:
                                              'Stockall_Receipt_${DateTime.now().millisecondsSinceEpoch}.pdf',
                                          context:
                                              safeContext,
                                          receipt:
                                              mainReceipt,
                                          records: records,
                                          shop: currentShop,
                                        );
                                      } else {
                                        await generateAndPreviewPdf(
                                          staffName:
                                              cashierName,
                                          context:
                                              safeContext,
                                          receipt:
                                              mainReceipt,
                                          records: records,
                                          shop: currentShop,
                                        );
                                      }

                                      await Future.delayed(
                                        const Duration(
                                          seconds: 1,
                                        ),
                                      );
                                      if (safeContext
                                          .mounted) {
                                        actionResultDialog(
                                          context:
                                              safeContext,
                                          message:
                                              'Receipt Downloaded',
                                          isSuccess: true,
                                        );
                                      }

                                      setState(() {
                                        isDownloadLoading =
                                            false;
                                      });
                                    },
                                  );
                                },
                              );
                            },
                          );
                        },
                        text: 'Download',
                      ),
                      // Edit Button
                      Visibility(
                        visible:
                            authorization(
                              authorized:
                                  Authorizations()
                                      .updateSale,
                            ) &&
                            mainReceipt.isInvoice == false,
                        child: ActionButtonSmall(
                          action: () {
                            showDialog(
                              context: context,
                              builder: (confirmDialog) {
                                return ConfirmationAlert(
                                  theme: theme,
                                  message:
                                      'You are about to edit this Receipt. Are you sure you want to proceed?',
                                  title: 'Edit Receipt',
                                  action: () {
                                    Navigator.of(
                                      confirmDialog,
                                    ).pop();
                                    returnSalesProvider()
                                        .onEditReceipt(
                                          receipt:
                                              mainReceipt,
                                          context: context,
                                        );
                                  },
                                );
                              },
                            );
                          },
                          text: 'Edit',
                        ),
                      ),
                      // Delete Button
                      Visibility(
                        visible: authorization(
                          authorized:
                              Authorizations().deleteSale,
                        ),
                        child: ActionButtonSmall(
                          isLoading: isDeleteLoading,
                          action: () {
                            showDialog(
                              context: context,
                              builder: (confirmDialog) {
                                return ConfirmationAlert(
                                  theme: theme,
                                  message:
                                      'This action cannot be recovered. Are you sure you want to delete this sale receipt?',
                                  title: 'Delete Receipt?',
                                  action: () async {
                                    Navigator.of(
                                      confirmDialog,
                                    ).pop();
                                    setState(() {
                                      isDeleteLoading =
                                          true;
                                    });

                                    final receiptP =
                                        returnReceiptProvider(
                                          context,
                                          listen: false,
                                        );

                                    var deleteResult = 1;
                                    if (mainReceipt
                                            .getSalesTypeIndex() ==
                                        1) {
                                      await receiptP
                                          .deleteReceipt(
                                            mainReceipt,
                                            records
                                                .map(
                                                  (rec) =>
                                                      rec.productName,
                                                )
                                                .toList(),
                                          );
                                    } else if (mainReceipt
                                            .getSalesTypeIndex() ==
                                        2) {
                                      await receiptP
                                          .deleteReceiptWithoutUpdatingInventory(
                                            receipt:
                                                mainReceipt,
                                          );
                                    } else if (mainReceipt
                                            .getSalesTypeIndex() ==
                                        3) {
                                      deleteResult = await returnOrdersProvider()
                                          .deleteDeliveryReceipt(
                                            receipt:
                                                mainReceipt,
                                            records:
                                                records,
                                            orderUuid:
                                                mainReceipt
                                                    .orderUuid,
                                          );
                                    }

                                    if (deleteResult != 1) {
                                      setState(() {
                                        isDeleteLoading =
                                            false;
                                      });
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Receipt was not deleted because its order quantities could not be restored safely.',
                                            ),
                                          ),
                                        );
                                      }
                                      return;
                                    }

                                    await actionResultDialog(
                                      context: context,
                                      message:
                                          'Deleted Successfully',
                                      isSuccess: true,
                                    );

                                    setState(() {
                                      isDeleteLoading =
                                          false;
                                    });

                                    if (context.mounted) {
                                      _navigateBack();
                                    }
                                  },
                                );
                              },
                            );
                          },
                          text: 'Delete',
                          textColor: Colors.red.shade300,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Main Body Area
            Expanded(
              child: ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30.0,
                    ),
                    child: Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      spacing: 20,
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        // Left Column: Main Receipt Card
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(
                              30,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.grey.shade100,
                              ),
                              borderRadius:
                                  BorderRadius.circular(3),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color.fromARGB(
                                    10,
                                    0,
                                    0,
                                    0,
                                  ),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                              color: Colors.white,
                            ),
                            child: Column(
                              spacing: 5,
                              children: [
                                if (shop != null &&
                                    (shop.showShopName ??
                                        false)) ...[
                                  Align(
                                    alignment:
                                        Alignment
                                            .centerLeft,
                                    child: Text(
                                      shop.name,
                                      style: TextStyle(
                                        fontSize:
                                            theme
                                                .mobileTexts
                                                .h4
                                                .fontSize,
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                ],

                                if (shop != null &&
                                    (shop.showAddress ??
                                        false) &&
                                    shop.shopAddress !=
                                        null) ...[
                                  Align(
                                    alignment:
                                        Alignment
                                            .centerLeft,
                                    child: Text(
                                      shop.shopAddress!,
                                      style: TextStyle(
                                        fontSize:
                                            theme
                                                .mobileTexts
                                                .b4
                                                .fontSize,
                                        color:
                                            Colors
                                                .grey
                                                .shade600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                ],

                                // Metadata Row: Cashier, Waiter, Date, Cart
                                Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                  mainAxisAlignment:
                                      MainAxisAlignment
                                          .spaceBetween,
                                  spacing: 5,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment
                                                .start,
                                        spacing: 5,
                                        children: [
                                          Text(
                                            style: TextStyle(
                                              fontSize:
                                                  theme
                                                      .mobileTexts
                                                      .b3
                                                      .fontSize,
                                              fontWeight:
                                                  FontWeight
                                                      .bold,
                                            ),
                                            'Cashier:',
                                          ),
                                          Text(
                                            style: TextStyle(
                                              fontSize:
                                                  theme
                                                      .mobileTexts
                                                      .b3
                                                      .fontSize,
                                              fontWeight:
                                                  FontWeight
                                                      .normal,
                                            ),
                                            cashierName,
                                          ),
                                          if (mainReceipt
                                                  .subStaffName !=
                                              null) ...[
                                            const SizedBox(
                                              height: 2,
                                            ),
                                            Text(
                                              style: TextStyle(
                                                fontSize:
                                                    theme
                                                        .mobileTexts
                                                        .b3
                                                        .fontSize,
                                                fontWeight:
                                                    FontWeight
                                                        .bold,
                                              ),
                                              'Waiter:',
                                            ),
                                            Text(
                                              style: TextStyle(
                                                fontSize:
                                                    theme
                                                        .mobileTexts
                                                        .b3
                                                        .fontSize,
                                                fontWeight:
                                                    FontWeight
                                                        .normal,
                                              ),
                                              mainReceipt
                                                  .subStaffName!,
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment
                                                .start,
                                        spacing: 5,
                                        children: [
                                          Text(
                                            style: TextStyle(
                                              fontSize:
                                                  theme
                                                      .mobileTexts
                                                      .b3
                                                      .fontSize,
                                              fontWeight:
                                                  FontWeight
                                                      .bold,
                                            ),
                                            'Date:',
                                          ),
                                          Row(
                                            spacing: 5,
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  style: TextStyle(
                                                    fontSize:
                                                        theme.mobileTexts.b3.fontSize,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                  ),
                                                  "${formatDateTime(mainReceipt.createdAt)}  |  ${formatTime(mainReceipt.createdAt)}",
                                                ),
                                              ),
                                            ],
                                          ),
                                          if (mainReceipt
                                                  .cartName !=
                                              null) ...[
                                            const SizedBox(
                                              height: 2,
                                            ),
                                            Text(
                                              style: TextStyle(
                                                fontSize:
                                                    theme
                                                        .mobileTexts
                                                        .b3
                                                        .fontSize,
                                                fontWeight:
                                                    FontWeight
                                                        .bold,
                                              ),
                                              'Cart:',
                                            ),
                                            Text(
                                              style: TextStyle(
                                                fontSize:
                                                    theme
                                                        .mobileTexts
                                                        .b3
                                                        .fontSize,
                                                fontWeight:
                                                    FontWeight
                                                        .normal,
                                              ),
                                              mainReceipt
                                                  .cartName!,
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Divider(
                                  color:
                                      Colors.grey.shade200,
                                  height: 40,
                                ),

                                // Items Table Header
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment
                                          .spaceBetween,
                                  spacing: 10,
                                  children: [
                                    Expanded(
                                      flex: 10,
                                      child: Text(
                                        style: TextStyle(
                                          fontSize:
                                              theme
                                                  .mobileTexts
                                                  .b3
                                                  .fontSize,
                                          fontWeight:
                                              FontWeight
                                                  .bold,
                                        ),
                                        'Items',
                                      ),
                                    ),
                                    Expanded(
                                      flex: 5,
                                      child: Text(
                                        style: TextStyle(
                                          fontSize:
                                              theme
                                                  .mobileTexts
                                                  .b3
                                                  .fontSize,
                                          fontWeight:
                                              FontWeight
                                                  .bold,
                                        ),
                                        'Price',
                                      ),
                                    ),
                                  ],
                                ),
                                Divider(
                                  color:
                                      Colors.grey.shade400,
                                  height: 5,
                                ),

                                // Active Sale Items List
                                Column(
                                  children:
                                      records.map((record) {
                                        final double
                                        itemTotal =
                                            (mainReceipt.fixedDiscount ==
                                                            null &&
                                                        mainReceipt.generalDiscount ==
                                                            null) &&
                                                    record.discount !=
                                                        null
                                                ? ((record.originalCost ??
                                                        0) -
                                                    (record.discountedAmount ??
                                                        0))
                                                : (record
                                                        .originalCost ??
                                                    0);

                                        final double
                                        unitRate =
                                            (record.priceQuantity() >
                                                    0)
                                                ? (itemTotal /
                                                    record
                                                        .priceQuantity())
                                                : itemTotal;

                                        return Container(
                                          margin:
                                              const EdgeInsets.only(
                                                top: 5.0,
                                                bottom: 5,
                                              ),
                                          padding:
                                              EdgeInsets.symmetric(
                                                vertical:
                                                    10,
                                                horizontal:
                                                    10,
                                              ),
                                          decoration:
                                              BoxDecoration(
                                                color:
                                                    Colors
                                                        .grey
                                                        .shade100,
                                              ),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment
                                                    .start,
                                            mainAxisAlignment:
                                                MainAxisAlignment
                                                    .spaceBetween,
                                            spacing: 10,
                                            children: [
                                              Expanded(
                                                flex: 10,
                                                child: Column(
                                                  spacing:
                                                      2,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .start,
                                                  children: [
                                                    Text(
                                                      style: TextStyle(
                                                        fontSize:
                                                            theme.mobileTexts.b3.fontSize,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                      '${record.productName}${record.dimensionsLabel()}',
                                                    ),
                                                    Visibility(
                                                      visible:
                                                          record.wastageNote().isNotEmpty,
                                                      child: Text(
                                                        style: TextStyle(
                                                          fontSize:
                                                              theme.mobileTexts.b4.fontSize,
                                                          color:
                                                              Colors.grey.shade700,
                                                        ),
                                                        record.wastageNote(),
                                                      ),
                                                    ),
                                                    Row(
                                                      spacing:
                                                          3,
                                                      children: [
                                                        Text(
                                                          style: TextStyle(
                                                            fontSize:
                                                                theme.mobileTexts.b3.fontSize,
                                                            fontWeight:
                                                                FontWeight.normal,
                                                          ),
                                                          'Qtty: ',
                                                        ),
                                                        Text(
                                                          style: TextStyle(
                                                            fontSize:
                                                                theme.mobileTexts.b3.fontSize,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                          formatLargeNumberDouble(
                                                            record.displayQuantity(),
                                                          ),
                                                        ),
                                                        Text(
                                                          style: TextStyle(
                                                            fontSize:
                                                                theme.mobileTexts.b4.fontSize,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                          record.unit ==
                                                                      'Others' ||
                                                                  record.unit ==
                                                                      null
                                                              ? 'Unit(s)'
                                                              : '${record.unit}',
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Expanded(
                                                flex: 5,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .start,
                                                  children: [
                                                    Text(
                                                      style: TextStyle(
                                                        fontSize:
                                                            theme.mobileTexts.b3.fontSize,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                      formatMoneyBig(
                                                        amount:
                                                            itemTotal,
                                                        context:
                                                            context,
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.only(
                                                        left:
                                                            1.0,
                                                      ),
                                                      child: Text(
                                                        style: TextStyle(
                                                          fontSize:
                                                              theme.mobileTexts.b4.fontSize,
                                                          color:
                                                              Colors.grey.shade600,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                        "${formatMoneyMid(amount: unitRate, context: context)} per 1",
                                                      ),
                                                    ),
                                                    Visibility(
                                                      visible:
                                                          record.discount !=
                                                              null &&
                                                          !record.customPriceSet &&
                                                          (mainReceipt.fixedDiscount ==
                                                                  null &&
                                                              mainReceipt.generalDiscount ==
                                                                  null),
                                                      child: Text(
                                                        style: TextStyle(
                                                          decoration:
                                                              TextDecoration.lineThrough,
                                                          fontSize:
                                                              theme.mobileTexts.b4.fontSize,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          color:
                                                              Colors.grey.shade600,
                                                        ),
                                                        formatMoneyMid(
                                                          amount:
                                                              record.originalCost!,
                                                          context:
                                                              context,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                ),

                                // Voided/Deleted Items List (if present)
                                if (recordsVoid
                                    .isNotEmpty) ...[
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment
                                            .center,
                                    children: [
                                      Text(
                                        style: TextStyle(
                                          fontSize:
                                              theme
                                                  .mobileTexts
                                                  .b3
                                                  .fontSize,
                                          fontWeight:
                                              FontWeight
                                                  .bold,
                                          color:
                                              Colors
                                                  .red
                                                  .shade400,
                                        ),
                                        'Deleted Items',
                                      ),
                                    ],
                                  ),
                                  Divider(
                                    color:
                                        Colors.red.shade200,
                                    height: 10,
                                  ),
                                  Column(
                                    children:
                                        recordsVoid.map((
                                          productRecord,
                                        ) {
                                          final double
                                          voidItemTotal =
                                              (mainReceipt.fixedDiscount ==
                                                              null &&
                                                          mainReceipt.generalDiscount ==
                                                              null) &&
                                                      productRecord.discount !=
                                                          null
                                                  ? ((productRecord.originalCost ??
                                                          0) -
                                                      (productRecord.discountedAmount ??
                                                          0))
                                                  : (productRecord
                                                          .originalCost ??
                                                      0);

                                          return Container(
                                            margin:
                                                const EdgeInsets.symmetric(
                                                  vertical:
                                                      3,
                                                ),
                                            padding:
                                                const EdgeInsets.symmetric(
                                                  vertical:
                                                      4.0,
                                                ),
                                            child: Row(
                                              spacing: 10,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Icon(
                                                  color:
                                                      Colors
                                                          .red
                                                          .shade400,
                                                  Icons
                                                      .arrow_right,
                                                ),
                                                Expanded(
                                                  flex: 10,
                                                  child: Column(
                                                    spacing:
                                                        2,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        style: TextStyle(
                                                          fontSize:
                                                              theme.mobileTexts.b3.fontSize,
                                                          decoration:
                                                              TextDecoration.lineThrough,
                                                          color:
                                                              Colors.grey.shade700,
                                                        ),
                                                        '${productRecord.productName}${productRecord.dimensionsLabel()}',
                                                      ),
                                                      if (productRecord
                                                          .wastageNote()
                                                          .isNotEmpty)
                                                        Text(
                                                          style: TextStyle(
                                                            fontSize:
                                                                theme.mobileTexts.b4.fontSize,
                                                            color:
                                                                Colors.grey.shade600,
                                                          ),
                                                          productRecord.wastageNote(),
                                                        ),
                                                      Text(
                                                        style: TextStyle(
                                                          fontSize:
                                                              theme.mobileTexts.b4.fontSize,
                                                          color:
                                                              Colors.grey.shade600,
                                                        ),
                                                        'Qty: ${productRecord.quantityText()} ${productRecord.unit == 'Others' || productRecord.unit == null ? 'Unit(s)' : productRecord.unit}',
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 5,
                                                  child: Text(
                                                    style: TextStyle(
                                                      fontSize:
                                                          theme.mobileTexts.b3.fontSize,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          Colors.grey.shade600,
                                                      decoration:
                                                          TextDecoration.lineThrough,
                                                    ),
                                                    formatMoneyMid(
                                                      amount:
                                                          voidItemTotal,
                                                      context:
                                                          context,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                  ),
                                ],

                                const SizedBox(height: 15),
                                Divider(
                                  color:
                                      Colors.grey.shade400,
                                  height: 5,
                                ),
                                const SizedBox(height: 15),

                                // Totals Breakdown
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.end,
                                  children: [
                                    SizedBox(
                                      width: 250,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment
                                                .start,
                                        spacing: 3,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment
                                                    .end,
                                            spacing: 20,
                                            children: [
                                              Expanded(
                                                flex: 4,
                                                child: Text(
                                                  style: TextStyle(
                                                    fontSize:
                                                        theme.mobileTexts.b4.fontSize,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                  ),
                                                  'Subtotal:',
                                                ),
                                              ),
                                              Expanded(
                                                flex: 5,
                                                child: Text(
                                                  style: TextStyle(
                                                    fontSize:
                                                        theme.mobileTexts.b4.fontSize,
                                                    fontWeight:
                                                        FontWeight.bold,
                                                  ),
                                                  formatMoneyBig(
                                                    amount:
                                                        originalCost,
                                                    context:
                                                        context,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          if (mainReceipt
                                                      .vat !=
                                                  null &&
                                              mainReceipt
                                                      .vat !=
                                                  0)
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .end,
                                              spacing: 20,
                                              children: [
                                                Expanded(
                                                  flex: 4,
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                        style: TextStyle(
                                                          fontSize:
                                                              theme.mobileTexts.b4.fontSize,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                        ),
                                                        'VAT: ',
                                                      ),
                                                      Text(
                                                        style: TextStyle(
                                                          fontSize:
                                                              theme.mobileTexts.b4.fontSize,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                        ),
                                                        '[ ${mainReceipt.vat ?? 0}% ]',
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 5,
                                                  child: Text(
                                                    style: TextStyle(
                                                      fontSize:
                                                          theme.mobileTexts.b4.fontSize,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    formatMoneyBig(
                                                      amount:
                                                          vatAmount,
                                                      context:
                                                          context,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          if (mainReceipt
                                                      .fixedDiscount !=
                                                  null ||
                                              mainReceipt
                                                      .generalDiscount !=
                                                  null)
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .end,
                                              spacing: 20,
                                              children: [
                                                Expanded(
                                                  flex: 4,
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                        style: TextStyle(
                                                          fontSize:
                                                              theme.mobileTexts.b4.fontSize,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                        ),
                                                        'Discount: ',
                                                      ),
                                                      if (mainReceipt.generalDiscount !=
                                                          null)
                                                        Text(
                                                          style: TextStyle(
                                                            fontSize:
                                                                theme.mobileTexts.b4.fontSize,
                                                            fontWeight:
                                                                FontWeight.normal,
                                                          ),
                                                          '[ ${mainReceipt.generalDiscount}% ]',
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 5,
                                                  child: Text(
                                                    style: TextStyle(
                                                      fontSize:
                                                          theme.mobileTexts.b4.fontSize,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    formatMoneyBig(
                                                      amount:
                                                          discountAmount,
                                                      context:
                                                          context,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          if (mainReceipt
                                                      .balance !=
                                                  null &&
                                              mainReceipt
                                                      .balance !=
                                                  0)
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .end,
                                              spacing: 20,
                                              children: [
                                                Expanded(
                                                  flex: 4,
                                                  child: Text(
                                                    style: TextStyle(
                                                      fontSize:
                                                          theme.mobileTexts.b4.fontSize,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                    ),
                                                    'Balance:',
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 5,
                                                  child: Text(
                                                    style: TextStyle(
                                                      fontSize:
                                                          theme.mobileTexts.b4.fontSize,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    formatMoneyBig(
                                                      amount:
                                                          remainingBalance,
                                                      context:
                                                          context,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          Divider(
                                            color:
                                                Colors
                                                    .grey
                                                    .shade200,
                                            height: 5,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment
                                                    .end,
                                            spacing: 20,
                                            children: [
                                              Expanded(
                                                flex: 4,
                                                child: Text(
                                                  style: TextStyle(
                                                    fontSize:
                                                        theme.mobileTexts.b3.fontSize,
                                                    fontWeight:
                                                        FontWeight.bold,
                                                  ),
                                                  'Total:',
                                                ),
                                              ),
                                              Expanded(
                                                flex: 5,
                                                child: Text(
                                                  style: TextStyle(
                                                    fontSize:
                                                        theme.mobileTexts.b2.fontSize,
                                                    fontWeight:
                                                        FontWeight.bold,
                                                  ),
                                                  formatMoneyBig(
                                                    amount:
                                                        totalRevenue,
                                                    context:
                                                        context,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Right Column: Summary Box, Customer Details, Payment Breakdown
                        Container(
                          width: 300,
                          padding:
                              const EdgeInsets.symmetric(
                                vertical: 10,
                              ),
                          child: Column(
                            spacing: 15,
                            children: [
                              // Summary & Customer Card
                              Container(
                                width: double.infinity,
                                padding:
                                    const EdgeInsets.all(
                                      15,
                                    ),
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.circular(
                                        5,
                                      ),
                                  border: Border.all(
                                    color:
                                        const Color.fromARGB(
                                          118,
                                          134,
                                          155,
                                          173,
                                        ),
                                  ),
                                  color:
                                      const Color.fromARGB(
                                        31,
                                        173,
                                        182,
                                        209,
                                      ),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                  children: [
                                    // Shop Logo, Tel, and Email
                                    if (returnShopProvider(
                                              context:
                                                  context,
                                            ).selectedLogo !=
                                            null ||
                                        (shop != null &&
                                            ((shop.phoneNumber !=
                                                        null &&
                                                    (shop.showPhone ??
                                                        true)) ||
                                                (shop.email !=
                                                        null &&
                                                    (shop.showEmail ??
                                                        true))))) ...[
                                      if (returnShopProvider(
                                            context:
                                                context,
                                          ).selectedLogo !=
                                          null) ...[
                                        Align(
                                          alignment:
                                              Alignment
                                                  .centerLeft,
                                          child: Container(
                                            height:
                                                (returnShopProvider(
                                                              context:
                                                                  context,
                                                            ).imageWidth ??
                                                            0) >
                                                        (2 *
                                                            (returnShopProvider(
                                                                  context:
                                                                      context,
                                                                ).imageHeight ??
                                                                0))
                                                    ? 30
                                                    : 50,
                                            width: 250,
                                            alignment:
                                                Alignment
                                                    .centerLeft,
                                            child: Image.memory(
                                              returnShopProvider(
                                                context:
                                                    context,
                                              ).selectedLogo!,
                                              fit:
                                                  BoxFit
                                                      .contain,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 6,
                                        ),
                                      ],
                                      if (shop != null) ...[
                                        if (shop.phoneNumber !=
                                                null &&
                                            (shop.showPhone ??
                                                true))
                                          Align(
                                            alignment:
                                                Alignment
                                                    .centerLeft,
                                            child: Text(
                                              "Tel: ${shop.phoneNumber!}",
                                              style: TextStyle(
                                                fontSize:
                                                    theme
                                                        .mobileTexts
                                                        .b4
                                                        .fontSize,
                                                color:
                                                    Colors
                                                        .grey
                                                        .shade700,
                                              ),
                                            ),
                                          ),
                                        if (shop.email !=
                                                null &&
                                            (shop.showEmail ??
                                                true))
                                          Align(
                                            alignment:
                                                Alignment
                                                    .centerLeft,
                                            child: Text(
                                              "Email: ${shop.email!}",
                                              style: TextStyle(
                                                fontSize:
                                                    theme
                                                        .mobileTexts
                                                        .b4
                                                        .fontSize,
                                                color:
                                                    Colors
                                                        .grey
                                                        .shade700,
                                              ),
                                            ),
                                          ),
                                      ],
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Divider(
                                        color:
                                            Colors
                                                .grey
                                                .shade300,
                                        height: 1,
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                    ],
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment
                                              .spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment
                                                  .start,
                                          children: [
                                            Row(
                                              children: [
                                                SizedBox(
                                                  width: 55,
                                                  child: Text(
                                                    style: TextStyle(
                                                      fontSize:
                                                          theme.mobileTexts.b4.fontSize,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                    ),
                                                    'Amount:',
                                                  ),
                                                ),
                                                Text(
                                                  style: TextStyle(
                                                    fontSize:
                                                        theme.mobileTexts.b4.fontSize,
                                                    fontWeight:
                                                        FontWeight.bold,
                                                  ),
                                                  formatMoneyMid(
                                                    amount:
                                                        totalRevenue,
                                                    context:
                                                        context,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                SizedBox(
                                                  width: 55,
                                                  child: Text(
                                                    style: TextStyle(
                                                      fontSize:
                                                          theme.mobileTexts.b4.fontSize,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                    ),
                                                    'Paid:',
                                                  ),
                                                ),
                                                Text(
                                                  style: TextStyle(
                                                    fontSize:
                                                        theme.mobileTexts.b4.fontSize,
                                                    fontWeight:
                                                        FontWeight.bold,
                                                  ),
                                                  formatMoneyMid(
                                                    amount:
                                                        amountPaid,
                                                    context:
                                                        context,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                SizedBox(
                                                  width: 55,
                                                  child: Text(
                                                    style: TextStyle(
                                                      fontSize:
                                                          theme.mobileTexts.b4.fontSize,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                    ),
                                                    'Balance:',
                                                  ),
                                                ),
                                                Text(
                                                  style: TextStyle(
                                                    fontSize:
                                                        theme.mobileTexts.b4.fontSize,
                                                    fontWeight:
                                                        FontWeight.bold,
                                                  ),
                                                  formatMoneyMid(
                                                    amount:
                                                        remainingBalance,
                                                    context:
                                                        context,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Container(
                                          padding:
                                              const EdgeInsets.symmetric(
                                                vertical: 3,
                                                horizontal:
                                                    10,
                                              ),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(
                                                  3,
                                                ),
                                            border: Border.all(
                                              color:
                                                  isPartial
                                                      ? const Color.fromARGB(
                                                        255,
                                                        255,
                                                        223,
                                                        126,
                                                      )
                                                      : Colors
                                                          .green,
                                            ),
                                          ),
                                          child: Text(
                                            style: TextStyle(
                                              fontSize:
                                                  theme
                                                      .mobileTexts
                                                      .b4
                                                      .fontSize,
                                              fontWeight:
                                                  FontWeight
                                                      .bold,
                                              color:
                                                  isPartial
                                                      ? const Color.fromARGB(
                                                        255,
                                                        245,
                                                        185,
                                                        6,
                                                      )
                                                      : Colors
                                                          .green,
                                            ),
                                            isPartial
                                                ? 'Partial'
                                                : 'Paid',
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Divider(
                                      color:
                                          Colors
                                              .grey
                                              .shade300,
                                      height: 1,
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Column(
                                      spacing: 7,
                                      crossAxisAlignment:
                                          CrossAxisAlignment
                                              .start,
                                      children: [
                                        Row(
                                          spacing: 10,
                                          children: [
                                            Icon(
                                              size: 16,
                                              color:
                                                  Colors
                                                      .grey
                                                      .shade600,
                                              Icons.person,
                                            ),
                                            Expanded(
                                              child: Text(
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
                                                customersClass
                                                        ?.name ??
                                                    customer ??
                                                    'Customer Not Set',
                                                overflow:
                                                    TextOverflow
                                                        .ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          spacing: 10,
                                          children: [
                                            const Icon(
                                              size: 16,
                                              color:
                                                  Colors
                                                      .grey,
                                              Icons.phone,
                                            ),
                                            Expanded(
                                              child: Text(
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
                                                customersClass
                                                        ?.phone ??
                                                    'Phone Not Set',
                                                overflow:
                                                    TextOverflow
                                                        .ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (customersClass
                                                    ?.email !=
                                                null &&
                                            customersClass!
                                                .email
                                                .isNotEmpty)
                                          Row(
                                            spacing: 10,
                                            children: [
                                              const Icon(
                                                size: 16,
                                                color:
                                                    Colors
                                                        .grey,
                                                Icons
                                                    .email_outlined,
                                              ),
                                              Expanded(
                                                child: Text(
                                                  style: TextStyle(
                                                    fontSize:
                                                        theme.mobileTexts.b4.fontSize,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                  ),
                                                  customersClass
                                                      .email,
                                                  overflow:
                                                      TextOverflow
                                                          .ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        if (mainReceipt
                                                    .comment !=
                                                null &&
                                            mainReceipt
                                                .comment!
                                                .isNotEmpty) ...[
                                          Divider(
                                            color:
                                                Colors
                                                    .grey
                                                    .shade300,
                                            height: 10,
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                style: TextStyle(
                                                  fontSize:
                                                      theme
                                                          .mobileTexts
                                                          .b3
                                                          .fontSize,
                                                  fontWeight:
                                                      FontWeight
                                                          .bold,
                                                ),
                                                'Comment:',
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  style: TextStyle(
                                                    fontSize:
                                                        theme.mobileTexts.b4.fontSize,
                                                  ),
                                                  mainReceipt
                                                      .comment!,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Payment Details Card
                              Container(
                                width: double.infinity,
                                padding:
                                    const EdgeInsets.all(
                                      15,
                                    ),
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.circular(
                                        5,
                                      ),
                                  border: Border.all(
                                    color:
                                        Colors
                                            .grey
                                            .shade200,
                                  ),
                                  color: Colors.white,
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                  spacing: 8,
                                  children: [
                                    Text(
                                      'Payment Details',
                                      style: TextStyle(
                                        fontSize:
                                            theme
                                                .mobileTexts
                                                .b3
                                                .fontSize,
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),
                                    Divider(
                                      color:
                                          Colors
                                              .grey
                                              .shade200,
                                      height: 5,
                                    ),
                                    if (mainReceipt
                                        .showsPaymentMethod(
                                          PaymentMethods
                                              .cash,
                                        ))
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment
                                                .spaceBetween,
                                        children: [
                                          Text(
                                            'Cash:',
                                            style: TextStyle(
                                              fontSize:
                                                  theme
                                                      .mobileTexts
                                                      .b4
                                                      .fontSize,
                                              color:
                                                  Colors
                                                      .grey
                                                      .shade700,
                                            ),
                                          ),
                                          Text(
                                            formatMoneyMid(
                                              amount:
                                                  mainReceipt
                                                      .cashAlt,
                                              context:
                                                  context,
                                            ),
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
                                          ),
                                        ],
                                      ),
                                    if (mainReceipt
                                        .showsPaymentMethod(
                                          PaymentMethods
                                              .bank,
                                        ))
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment
                                                .spaceBetween,
                                        children: [
                                          Text(
                                            'Bank:',
                                            style: TextStyle(
                                              fontSize:
                                                  theme
                                                      .mobileTexts
                                                      .b4
                                                      .fontSize,
                                              color:
                                                  Colors
                                                      .grey
                                                      .shade700,
                                            ),
                                          ),
                                          Text(
                                            formatMoneyMid(
                                              amount:
                                                  mainReceipt
                                                      .bank,
                                              context:
                                                  context,
                                            ),
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
                                          ),
                                        ],
                                      ),
                                    if (mainReceipt
                                        .showsPaymentMethod(
                                          PaymentMethods
                                              .account,
                                        ))
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment
                                                .spaceBetween,
                                        children: [
                                          Text(
                                            'Account:',
                                            style: TextStyle(
                                              fontSize:
                                                  theme
                                                      .mobileTexts
                                                      .b4
                                                      .fontSize,
                                              color:
                                                  Colors
                                                      .grey
                                                      .shade700,
                                            ),
                                          ),
                                          Text(
                                            formatMoneyMid(
                                              amount:
                                                  mainReceipt
                                                      .customerAccount ??
                                                  0,
                                              context:
                                                  context,
                                            ),
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
                                          ),
                                        ],
                                      ),
                                    if (mainReceipt
                                            .departmentName !=
                                        null) ...[
                                      Divider(
                                        color:
                                            Colors
                                                .grey
                                                .shade200,
                                        height: 5,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment
                                                .spaceBetween,
                                        children: [
                                          Text(
                                            'Department:',
                                            style: TextStyle(
                                              fontSize:
                                                  theme
                                                      .mobileTexts
                                                      .b4
                                                      .fontSize,
                                              color:
                                                  Colors
                                                      .grey
                                                      .shade700,
                                            ),
                                          ),
                                          Text(
                                            mainReceipt
                                                .departmentName!,
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
                                          ),
                                        ],
                                      ),
                                    ],
                                    if (mainReceipt
                                            .cartName !=
                                        null)
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment
                                                .spaceBetween,
                                        children: [
                                          Text(
                                            'Cart Name:',
                                            style: TextStyle(
                                              fontSize:
                                                  theme
                                                      .mobileTexts
                                                      .b4
                                                      .fontSize,
                                              color:
                                                  Colors
                                                      .grey
                                                      .shade700,
                                            ),
                                          ),
                                          Text(
                                            mainReceipt
                                                .cartName!,
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
                                          ),
                                        ],
                                      ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment
                                              .spaceBetween,
                                      children: [
                                        Text(
                                          'Shop ID:',
                                          style: TextStyle(
                                            fontSize:
                                                theme
                                                    .mobileTexts
                                                    .b4
                                                    .fontSize,
                                            color:
                                                Colors
                                                    .grey
                                                    .shade700,
                                          ),
                                        ),
                                        Text(
                                          shopRef(),
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
                                        ),
                                      ],
                                    ),
                                    if (shop != null &&
                                        (shop.showInstaTop ??
                                            false) &&
                                        shop.instaHandle !=
                                            null)
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment
                                                .spaceBetween,
                                        children: [
                                          Text(
                                            'Instagram:',
                                            style: TextStyle(
                                              fontSize:
                                                  theme
                                                      .mobileTexts
                                                      .b4
                                                      .fontSize,
                                              color:
                                                  Colors
                                                      .grey
                                                      .shade700,
                                            ),
                                          ),
                                          Text(
                                            shop.instaHandle!,
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
                                          ),
                                        ],
                                      ),
                                    if (shop != null &&
                                        (shop.showFacebookTop ??
                                            false) &&
                                        shop.faceBookHandle !=
                                            null)
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment
                                                .spaceBetween,
                                        children: [
                                          Text(
                                            'Facebook:',
                                            style: TextStyle(
                                              fontSize:
                                                  theme
                                                      .mobileTexts
                                                      .b4
                                                      .fontSize,
                                              color:
                                                  Colors
                                                      .grey
                                                      .shade700,
                                            ),
                                          ),
                                          Text(
                                            shop.faceBookHandle!,
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
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class ActionButtonSmall extends StatelessWidget {
  final Color? textColor;
  final Function()? action;
  final String text;
  final bool? isLoading;
  final Widget? icon;
  const ActionButtonSmall({
    super.key,
    this.textColor,
    required this.action,
    required this.text,
    this.isLoading,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        mouseCursor: SystemMouseCursors.click,
        onTap: action,
        borderRadius: BorderRadius.circular(3),
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 5,
            horizontal: 15,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            border: Border.all(
              color: textColor ?? Colors.grey.shade200,
            ),
          ),
          child: Builder(
            builder: (context) {
              if (isLoading != null && isLoading == true) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10.0,
                  ),
                  child: SizedBox(
                    width: 15,
                    height: 15,
                    child: CircularProgressIndicator(
                      color:
                          theme.lightModeColor.secColor200,
                      strokeWidth: 2.5,
                    ),
                  ),
                );
              } else {
                return Row(
                  children: [
                    Text(
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b4.fontSize,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                      text,
                    ),
                    Visibility(
                      visible: icon != null,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 5.0,
                        ),
                        child: icon ?? Container(),
                      ),
                    ),
                  ],
                );
              }
            },
          ),
        ),
      ),
    );
  }
}

Future<dynamic> actionResultDialog({
  required BuildContext context,
  required String message,
  required bool isSuccess,
}) async {
  await showDialog(
    barrierDismissible: false,
    context: context,
    builder: (dialogContext) {
      Future.delayed(const Duration(seconds: 3), () {
        if (dialogContext.mounted) {
          if (Navigator.of(dialogContext).canPop()) {
            Navigator.of(dialogContext).pop();
          }
        }
      });

      return AlertDialog(
        backgroundColor: Colors.white,
        content: Container(
          height: 400,
          width: 400,
          color: Colors.white,
          child: Builder(
            builder: (context) {
              if (!isSuccess) {
                return returnCompProvider(
                  context,
                  listen: false,
                ).showError(message);
              } else {
                return returnCompProvider(
                  context,
                  listen: false,
                ).showSuccess(message);
              }
            },
          ),
        ),
      );
    },
  );
}
