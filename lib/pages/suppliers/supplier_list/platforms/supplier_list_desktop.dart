import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_suppliers/suppliers_class.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/buttons/floating_action_butto.dart';
import 'package:stockall/components/major/desktop_page_container.dart';
import 'package:stockall/components/major/drawer_widget/platforms/my_drawer_widget_desktop.dart';
import 'package:stockall/components/major/empty_widget_display.dart';
import 'package:stockall/components/major/drawer_widget/my_drawer_widget.dart';
import 'package:stockall/components/major/right_side_bar.dart';
import 'package:stockall/components/text_fields/general_textfield_only.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/suppliers/add_supplier/add_supplier.dart';
import 'package:stockall/pages/suppliers/components/supplier_main_tile.dart';
import 'package:stockall/pages/suppliers/supplier_page/supplier_page.dart';
import 'package:stockall/services/auth_service.dart';

class SupplierListDesktop extends StatefulWidget {
  final TextEditingController searchController;
  final bool? isPurchase;
  final String? supplierUuid;
  const SupplierListDesktop({
    super.key,
    required this.searchController,
    this.isPurchase,
    this.supplierUuid,
  });

  @override
  State<SupplierListDesktop> createState() =>
      _SupplierListDesktopState();
}

class _SupplierListDesktopState
    extends State<SupplierListDesktop> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      returnData().showFloatingActionButton();
    });
    if (returnSuppliersProvider().suppliers.isEmpty) {
      getSuppliersList(context);
    }
  }

  // String searchResult = '';

  TextEditingController searchController =
      TextEditingController();

  Future<void> getSuppliersList(
    BuildContext context,
  ) async {
    await returnSuppliersProvider().fetchSuppliers(
      shopId(),
    );
  }

  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>();

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Scaffold(
      key: _scaffoldKey,
      drawer: MyDrawerWidgetDesktopMain(
        action: () {
          var safeContext = context;
          showDialog(
            context: context,
            builder: (context) {
              return ConfirmationAlert(
                theme: theme,
                message: 'You are about to Logout',
                title: 'Are you Sure?',
                action: () async {
                  Navigator.of(context).pop();
                  setState(() {
                    isLoading = true;
                  });
                  if (safeContext.mounted) {
                    await AuthService().signOut(
                      context: safeContext,
                      allowLogout: false,
                    );
                  }
                },
              );
            },
          );
        },
        theme: theme,
        notifications:
            returnNotificationProvider(
                  context,
                ).notifications().isEmpty
                ? []
                : returnNotificationProvider(
                  context,
                ).notifications(),
        globalKey: _scaffoldKey,
      ),
      body: Stack(
        children: [
          Row(
            spacing: 15,
            children: [
              Visibility(
                visible: widget.isPurchase == null,
                child: MyDrawerWidget(
                  globalKey: _scaffoldKey,
                  action: () {
                    var safeContext = context;
                    showDialog(
                      context: context,
                      builder: (context) {
                        return ConfirmationAlert(
                          theme: theme,
                          message:
                              'You are about to Logout',
                          title: 'Are you Sure?',
                          action: () async {
                            Navigator.of(context).pop();
                            setState(() {
                              isLoading = true;
                            });
                            if (safeContext.mounted) {
                              var res = await AuthService()
                                  .signOut(
                                    context: safeContext,
                                    allowLogout: false,
                                  );
                              if (res == 0 &&
                                  safeContext.mounted) {
                                setState(() {
                                  isLoading = false;
                                });
                              }
                            }
                          },
                        );
                      },
                    );
                  },
                  theme: theme,
                  notifications:
                      returnNotificationProvider(
                            context,
                          ).notifications().isEmpty
                          ? []
                          : returnNotificationProvider(
                            context,
                          ).notifications(),
                ),
              ),
              Expanded(
                child: DesktopPageContainer(
                  widget: Scaffold(
                    floatingActionButton:
                        FloatingActionButtonMain(
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
                              returnTheme(
                                context,
                              ).lightModeColor.prColor300,
                          text: 'Add Supplier',
                        ),
                    appBar: AppBar(
                      toolbarHeight: 60,
                      leading: Opacity(
                        opacity:
                            widget.isPurchase == null
                                ? 0
                                : 1,
                        child: IconButton(
                          mouseCursor:
                              SystemMouseCursors.click,
                          onPressed: () {
                            widget.isPurchase == null
                                ? {}
                                : Navigator.of(
                                  context,
                                ).pop();
                          },
                          icon: Padding(
                            padding: const EdgeInsets.only(
                              left: 10.0,
                              right: 0,
                            ),
                            child: Icon(
                              Icons
                                  .arrow_back_ios_new_rounded,
                            ),
                          ),
                        ),
                      ),
                      centerTitle: true,
                      title: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            style: TextStyle(
                              fontSize:
                                  theme
                                      .mobileTexts
                                      .h4
                                      .fontSize,
                              fontWeight: FontWeight.bold,
                            ),
                            widget.isPurchase == null
                                ? 'Your Suppliers'
                                : 'Select Supplier',
                          ),
                        ],
                      ),
                      actions: [
                        Visibility(
                          visible:
                              screenWidth(context) >
                              mobileScreen,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              mouseCursor:
                                  SystemMouseCursors.click,
                              borderRadius:
                                  BorderRadius.circular(10),
                              onTap: () async {
                                getSuppliersList(context);
                              },
                              child: Padding(
                                padding:
                                    const EdgeInsets.all(
                                      10,
                                    ),
                                child: Row(
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
                                            FontWeight.bold,
                                      ),
                                      'Refresh',
                                    ),
                                    Icon(
                                      size: 18,
                                      Icons.refresh_rounded,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
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
                                await returnSuppliersProvider()
                                    .fetchSuppliers(
                                      shopId(),
                                    );
                              },
                              altActionText: 'Refresh',
                              altIcon: Icons.refresh,
                            );
                          } else {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(
                                    horizontal: 15.0,
                                  ),
                              child: Column(
                                children: [
                                  SizedBox(height: 10),
                                  GeneralTextfieldOnly(
                                    hint:
                                        'Search Supplier Name',
                                    controller:
                                        widget
                                            .searchController,
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
                                              (
                                                supplier,
                                              ) => supplier
                                                  .name
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
                                                      ) => supplier
                                                          .name
                                                          .toLowerCase()
                                                          .contains(
                                                            widget.searchController.text.toLowerCase(),
                                                          ),
                                                    )
                                                    .length,
                                            itemBuilder: (
                                              context,
                                              index,
                                            ) {
                                              SuppliersClass
                                              supplier =
                                                  suppliers
                                                      .where(
                                                        (
                                                          supplier,
                                                        ) => supplier.name.toLowerCase().contains(
                                                          widget.searchController.text.toLowerCase(),
                                                        ),
                                                      )
                                                      .toList()[index];

                                              return SupplierMainTile(
                                                action: () {
                                                  if (widget
                                                          .isPurchase !=
                                                      null) {
                                                    returnPurchaseActionProvider().selectSupplier(
                                                      supplier:
                                                          supplier,
                                                    );
                                                    Navigator.of(
                                                      context,
                                                    ).pop(
                                                      context,
                                                    );
                                                  } else {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (
                                                          context,
                                                        ) {
                                                          return SupplierPage(
                                                            uuid:
                                                                supplier.uuid!,
                                                          );
                                                        },
                                                      ),
                                                    );
                                                  }
                                                },
                                                theme:
                                                    theme,
                                                supplier:
                                                    supplier,
                                                isPurchase:
                                                    widget
                                                        .isPurchase,
                                              );
                                            },
                                          );
                                        } else {
                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment
                                                    .start,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    style: TextStyle(
                                                      fontSize:
                                                          theme.mobileTexts.b1.fontSize,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    'Returned 0 Suppliers',
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
                  ),
                ),
              ),
              Visibility(
                visible: widget.isPurchase == null,
                child: RightSideBar(theme: theme),
              ),
            ],
          ),
          Visibility(
            visible: isLoading,
            child: returnCompProvider(
              context,
            ).showLoader(message: 'Logging Out...'),
          ),
        ],
      ),
    );
  }
}
