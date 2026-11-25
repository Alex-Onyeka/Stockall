import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_suppliers/supplier_rules.dart';
import 'package:stockall/classes/temp_suppliers/suppliers_class.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/local_database/purchases/purchase_func.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/purchases/purchase_list/purchase_list.dart';
import 'package:stockall/pages/suppliers/supplier_page/components/supplier_details_section_widget.dart';
import 'package:stockall/pages/suppliers/supplier_page/components/supplier_purchases_section.dart';

class SupplierPageMobile extends StatefulWidget {
  final SuppliersClass supplier;
  const SupplierPageMobile({
    super.key,
    required this.supplier,
  });

  @override
  State<SupplierPageMobile> createState() =>
      _SupplierPageMobileState();
}

class _SupplierPageMobileState
    extends State<SupplierPageMobile> {
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

    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color.fromARGB(
          255,
          253,
          254,
          255,
        ),
        body: Column(
          spacing: 10,
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 15,
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
                children: [
                  Row(
                    spacing: 6,
                    children: [
                      Material(
                        type: MaterialType.transparency,
                        child: InkWell(
                          mouseCursor:
                              SystemMouseCursors.click,
                          onTap: () {
                            Navigator.pop(context);
                          },
                          borderRadius:
                              BorderRadius.circular(30),
                          child: Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.grey.shade200,
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              size: 16,
                              color: Colors.grey.shade700,
                              Icons
                                  .arrow_back_ios_new_outlined,
                            ),
                          ),
                        ),
                      ),
                      Text(
                        style: TextStyle(
                          fontSize:
                              theme.mobileTexts.b3.fontSize,
                        ),
                        'Supplier Details',
                      ),
                    ],
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(
                      right: 15.0,
                    ),
                    child: PopupMenuButton(
                      offset: Offset(-20, 30),
                      color: Colors.white,
                      itemBuilder: (context) {
                        return [
                          PopupMenuItem(
                            height: 45,
                            onTap: () {
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
                            child: Text(
                              style: TextStyle(
                                fontSize:
                                    theme
                                        .mobileTexts
                                        .b3
                                        .fontSize,
                                fontWeight: FontWeight.bold,
                              ),
                              'Purchases',
                            ),
                          ),
                          PopupMenuItem(
                            enabled: authorization(
                              authorized:
                                  Authorizations()
                                      .deleteSupplier,
                            ),
                            height: 45,
                            onTap: () {
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
                            child: Text(
                              style: TextStyle(
                                fontSize:
                                    theme
                                        .mobileTexts
                                        .b3
                                        .fontSize,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                              'Delete Supplier',
                            ),
                          ),
                        ];
                      },
                      child: Icon(Icons.more_vert_rounded),
                    ),
                  ),
                ],
              ),
            ),
            Builder(
              builder: (context) {
                if (isDeleting) {
                  return Expanded(
                    child: Center(
                      child: returnCompProvider(
                        context,
                      ).showLoader(
                        message: 'Deleting Supplier',
                      ),
                    ),
                  );
                }
                return Expanded(
                  child: ListView(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15.0,
                        ),
                        child: Column(
                          spacing: 5,
                          children: [
                            SizedBox(
                              height: 340,
                              child:
                                  SupplierDetailsSectionWidget(
                                    supplier: supplier,
                                  ),
                            ),
                            SupplierPurchasesSection(
                              supplierUuid:
                                  supplier.uuid ?? '',
                            ),
                            SizedBox(height: 30),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
