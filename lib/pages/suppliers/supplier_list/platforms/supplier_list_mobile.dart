import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_suppliers/suppliers_class.dart';
import 'package:stockall/components/buttons/floating_action_butto.dart';
import 'package:stockall/components/major/empty_widget_display.dart';
import 'package:stockall/components/text_fields/general_textfield_only.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/suppliers/add_supplier/add_supplier.dart';
import 'package:stockall/pages/suppliers/components/supplier_main_tile.dart';
import 'package:stockall/pages/suppliers/supplier_page/supplier_page.dart';

class SupplierListMobile extends StatefulWidget {
  final TextEditingController searchController;
  final bool? isPurchase;
  const SupplierListMobile({
    super.key,
    required this.searchController,
    this.isPurchase,
  });

  @override
  State<SupplierListMobile> createState() =>
      _SupplierListMobileState();
}

class _SupplierListMobileState
    extends State<SupplierListMobile> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      returnData().showFloatingActionButton();
    });
    if (returnSuppliersProvider().suppliers.isEmpty) {
      getSuppliers(context);
    }
  }

  // String searchResult = '';

  TextEditingController searchController =
      TextEditingController();

  Future<void> getSuppliers(BuildContext context) async {
    await returnSuppliersProvider().fetchSuppliers(
      shopId(),
    );
  }

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Scaffold(
      floatingActionButton: FloatingActionButtonMain(
        theme: theme,
        action: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return AddSupplier();
              },
            ),
          ).then((_) {
            setState(() {});
          });
        },
        color:
            returnTheme(context).lightModeColor.prColor300,
        text: 'Add Supplier',
      ),
      appBar: AppBar(
        toolbarHeight: 60,
        leading: IconButton(
          mouseCursor: SystemMouseCursors.click,
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Padding(
            padding: const EdgeInsets.only(
              left: 10.0,
              right: 0,
            ),
            child: Icon(Icons.arrow_back_ios_new_rounded),
          ),
        ),
        centerTitle: true,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              style: TextStyle(
                fontSize: theme.mobileTexts.h4.fontSize,
                fontWeight: FontWeight.bold,
              ),
              widget.isPurchase == null
                  ? 'Your Suppliers'
                  : 'Select Supplier',
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(
          bottom: 30.0,
          left: 10,
        ),
        child: Builder(
          builder: (context) {
            var suppliers =
                returnSuppliersProvider(
                  context: context,
                ).suppliers;
            if (suppliers.isEmpty) {
              return EmptyWidgetDisplay(
                title: 'Empty Supplier List',
                subText:
                    'You Have not Created Any Supplier.',
                buttonText: 'Create Supplier',
                svg: custBookIconSvg,
                theme: theme,
                height: 30,
                action: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return AddSupplier();
                      },
                    ),
                  ).then((_) {
                    setState(() {});
                  });
                },
                altAction: () async {
                  await getSuppliers(context);
                },
                altActionText: 'Refresh',
                altIcon: Icons.refresh,
              );
            } else {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15.0,
                ),
                child: Column(
                  children: [
                    SizedBox(height: 10),
                    GeneralTextfieldOnly(
                      hint: 'Search Supplier Name',
                      controller: widget.searchController,
                      lines: 1,
                      theme: theme,
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                    SizedBox(height: 15),
                    Expanded(
                      child: Builder(
                        builder: (context) {
                          if (suppliers
                              .where(
                                (supplier) => supplier.name
                                    .toLowerCase()
                                    .contains(
                                      widget
                                          .searchController
                                          .text
                                          .toLowerCase(),
                                    ),
                              )
                              .isNotEmpty) {
                            return ListView.builder(
                              itemCount:
                                  suppliers
                                      .where(
                                        (
                                          supplier,
                                        ) => supplier.name
                                            .toLowerCase()
                                            .contains(
                                              widget
                                                  .searchController
                                                  .text
                                                  .toLowerCase(),
                                            ),
                                      )
                                      .length,
                              itemBuilder: (
                                context,
                                index,
                              ) {
                                SuppliersClass supplier =
                                    suppliers
                                        .where(
                                          (
                                            supplier,
                                          ) => supplier.name
                                              .toLowerCase()
                                              .contains(
                                                widget
                                                    .searchController
                                                    .text
                                                    .toLowerCase(),
                                              ),
                                        )
                                        .toList()[index];

                                return SupplierMainTile(
                                  action: () {
                                    if (widget.isPurchase !=
                                        null) {
                                      returnPurchaseActionProvider()
                                          .selectSupplier(
                                            supplier:
                                                supplier,
                                          );
                                      Navigator.of(
                                        context,
                                      ).pop(context);
                                    } else {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (
                                            context,
                                          ) {
                                            return SupplierPage(
                                              uuid:
                                                  supplier
                                                      .uuid!,
                                            );
                                          },
                                        ),
                                      );
                                    }
                                  },
                                  theme: theme,
                                  supplier: supplier,
                                  isPurchase:
                                      widget.isPurchase,
                                );
                              },
                            );
                          } else {
                            return Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      style: TextStyle(
                                        fontSize:
                                            theme
                                                .mobileTexts
                                                .b1
                                                .fontSize,
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                      'Returned 0 Supplier',
                                    ),
                                  ],
                                ),
                              ],
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
