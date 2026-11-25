import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_suppliers/supplier_rules.dart';
import 'package:stockall/classes/temp_suppliers/suppliers_class.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/local_database/purchases/purchase_func.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/invoices/invoice_page/invoice_page_desktop.dart';
import 'package:stockall/pages/purchases/purchase_list/purchase_list.dart';
import 'package:stockall/pages/suppliers/supplier_page/components/supplier_details_section_widget.dart';
import 'package:stockall/pages/suppliers/supplier_page/components/supplier_purchases_section.dart';

class SupplierPageDesktop extends StatefulWidget {
  final SuppliersClass supplier;
  const SupplierPageDesktop({
    super.key,
    required this.supplier,
  });

  @override
  State<SupplierPageDesktop> createState() =>
      _SupplierPageDesktopState();
}

class _SupplierPageDesktopState
    extends State<SupplierPageDesktop> {
  bool isDeleting = false;

  int _purchaseCount(SuppliersClass supplier) {
    var purchases = returnPurchaseProvider().purchases;
    if (purchases.isEmpty) {
      try {
        purchases = PurchaseFunc().getPurchases();
      } catch (_) {}
    }
    return supplierPurchaseCount(
      purchases,
      supplier.uuid ?? '',
    );
  }

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    final supplier = widget.supplier;

    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(
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
                      mouseCursor: SystemMouseCursors.click,
                      onTap: () {
                        Navigator.pop(context);
                      },
                      borderRadius: BorderRadius.circular(
                        30,
                      ),
                      child: Container(
                        padding: EdgeInsets.all(15),
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
                          Icons.arrow_back_ios_new_outlined,
                        ),
                      ),
                    ),
                    Text(
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b2.fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                      'Supplier Details',
                    ),
                  ],
                ),
                Row(
                  spacing: 5,
                  children: [
                    ActionButtonSmall(
                      isLoading: isDeleting,
                      action: () {
                        if (!isDeleting &&
                            supplier.uuid != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return PurchaseList(
                                  supplierUuid:
                                      supplier.uuid,
                                );
                              },
                            ),
                          );
                        }
                      },
                      text: 'Purchases',
                      textColor: Colors.grey.shade500,
                      icon: Icon(
                        size: 14,
                        color: Colors.grey.shade500,
                        Icons.arrow_forward_ios_rounded,
                      ),
                    ),
                    Visibility(
                      visible: authorization(
                        authorized:
                            Authorizations().deleteSupplier,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(
                          right: 20.0,
                        ),
                        child: ActionButtonSmall(
                          isLoading: isDeleting,
                          action: () {
                            if (!isDeleting) {
                              final warning =
                                  supplierDeleteWarning(
                                    _purchaseCount(
                                      supplier,
                                    ),
                                  );
                              showDialog(
                                context: context,
                                builder: (confirmDialog) {
                                  return ConfirmationAlert(
                                    theme: theme,
                                    message:
                                        '${warning == null ? '' : '$warning '}You are about to delete this Supplier, are you sure you want to proceed?',
                                    title:
                                        'Delete Supplier?',
                                    action: () async {
                                      final navigator =
                                          Navigator.of(
                                            context,
                                          );
                                      Navigator.of(
                                        confirmDialog,
                                      ).pop();
                                      setState(() {
                                        isDeleting = true;
                                      });
                                      await returnSuppliersProvider()
                                          .deleteSupplierMain(
                                            supplier,
                                            context,
                                          );
                                      if (navigator
                                          .mounted) {
                                        navigator.pop();
                                      }
                                      if (mounted) {
                                        setState(() {
                                          isDeleting =
                                              false;
                                        });
                                      }
                                    },
                                  );
                                },
                              );
                            }
                          },
                          text: 'Delete',
                          textColor: Colors.red.shade300,
                          icon: Icon(
                            size: 16,
                            color: Colors.red.shade300,
                            Icons.delete,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Builder(
              builder: (context) {
                if (isDeleting) {
                  return Center(
                    child: returnCompProvider(
                      context,
                    ).showLoader(
                      message: 'Deleting Supplier',
                    ),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.fromLTRB(
                    50,
                    0,
                    50,
                    30,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: 300,
                          ),
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(
                                  horizontal: 10.0,
                                ),
                            child:
                                SupplierDetailsSectionWidget(
                                  supplier: supplier,
                                ),
                          ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(
                                horizontal: 10.0,
                              ),
                          child: SupplierPurchasesSection(
                            supplierUuid:
                                supplier.uuid ?? '',
                          ),
                        ),
                        SizedBox(height: 30),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
