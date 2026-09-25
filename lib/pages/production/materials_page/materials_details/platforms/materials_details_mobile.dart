import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_production_folder/temp_material_class/material_class.dart';
import 'package:stockall/classes/temp_production_folder/temp_materials_item_history/materials_item_history.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/production/materials_page/add_material/add_material.dart';
import 'package:stockall/pages/production/materials_page/materials_details/platforms/components/manage_this_item_toggle_button_material_item.dart';
import 'package:stockall/pages/production/materials_page/materials_details/platforms/components/quantity_in_stock_widget_material_item.dart';
import 'package:stockall/pages/production/materials_page/materials_details/platforms/components/transfer_materials_quantity.dart';
import 'package:stockall/pages/production/materials_page/materials_details/platforms/components/update_cost_price_action_material_item.dart';
import 'package:stockall/pages/production/materials_page/materials_item_history_page/materials_item_history_page.dart';
import 'package:stockall/pages/products/product_details/platforms/components/bottom_info_section.dart';
import 'package:stockall/pages/products/product_details/platforms/components/edit_button.dart';
import 'package:stockall/pages/products/product_details/platforms/components/tab_container.dart';
import 'package:stockall/providers/theme_provider.dart';

class MaterialsDetailsMobile extends StatefulWidget {
  final ThemeProvider theme;
  final String materialUuid;
  const MaterialsDetailsMobile({
    super.key,
    required this.theme,
    required this.materialUuid,
  });

  @override
  State<MaterialsDetailsMobile> createState() =>
      _MaterialsDetailsMobileState();
}

class _MaterialsDetailsMobileState
    extends State<MaterialsDetailsMobile> {
  late Future<MaterialClass> materialFuture;

  bool isLoading = false;
  bool showSuccess = false;
  bool setDate = false;
  TextEditingController costController =
      TextEditingController();
  TextEditingController quantityController =
      TextEditingController();
  TextEditingController qttyPerUnitController =
      TextEditingController();

  @override
  void dispose() {
    super.dispose();
    costController.dispose();
    quantityController.dispose();
    qttyPerUnitController.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<MaterialClass>? materialList =
        returnMaterialsProvider(context: context)
            .materialListMain
            .where(
              (material) =>
                  material.uuid == widget.materialUuid,
            )
            .toList();
    if (materialList.isEmpty) {
      return Scaffold(
        body: returnCompProvider(
          context,
          listen: false,
        ).showLoader(message: 'Loading...'),
      );
    } else {
      MaterialClass material = materialList.first;
      return Stack(
        children: [
          Scaffold(
            appBar: appBar(
              context: context,
              title: 'Details',
              widget: Visibility(
                visible: !isStoreKeeper(),
                child: Padding(
                  padding: const EdgeInsets.only(
                    right: 15.0,
                  ),
                  child: InkWell(
                    mouseCursor: SystemMouseCursors.click,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return MaterialsItemHistoryPage(
                              materialsItemUuid:
                                  widget.materialUuid,
                              fromMaterialsItemDetails:
                                  true,
                            );
                          },
                        ),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.only(
                        right: 15,
                        left: 15,
                        top: 5,
                        bottom: 5,
                      ),
                      decoration: BoxDecoration(),
                      child: Row(
                        spacing: 3,
                        children: [
                          Text(
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  widget
                                      .theme
                                      .mobileTexts
                                      .b3
                                      .fontSize,
                            ),
                            'History',
                          ),
                          Icon(
                            size: 15,
                            Icons.receipt_long_rounded,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 15.0,
              ),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: 10),
                          Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.center,
                            children: [
                              Text(
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize:
                                      widget
                                          .theme
                                          .mobileTexts
                                          .h4
                                          .fontSize,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                                material.name,
                              ),
                              Text(
                                style: TextStyle(
                                  fontSize:
                                      widget
                                          .theme
                                          .mobileTexts
                                          .b3
                                          .fontSize,
                                  color:
                                      widget
                                          .theme
                                          .lightModeColor
                                          .secColor200,
                                  fontWeight:
                                      FontWeight.normal,
                                ),
                                'Date Created: ${formatDateTime(material.createdAt ?? DateTime.now())}',
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          Visibility(
                            visible: authorization(
                              authorized:
                                  Authorizations()
                                      .manageCostPrice,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    spacing: 10,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment
                                                .center,
                                        children: [
                                          Expanded(
                                            child: TabContainer(
                                              isMoney: true,
                                              text:
                                                  'Cost Price',
                                              price:
                                                  material
                                                      .costPrice,
                                              theme:
                                                  widget
                                                      .theme,
                                              backGround:
                                                  const Color.fromARGB(
                                                    11,
                                                    15,
                                                    4,
                                                    114,
                                                  ),
                                              border:
                                                  const Color.fromARGB(
                                                    32,
                                                    45,
                                                    3,
                                                    255,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Visibility(
                                        visible: authorization(
                                          authorized:
                                              Authorizations()
                                                  .updateMaterials,
                                        ),
                                        child: EditButton(
                                          theme:
                                              widget.theme,
                                          action: () {
                                            updateCostPriceActionMaterialItem(
                                              costController:
                                                  costController,
                                              context:
                                                  context,
                                              theme:
                                                  widget
                                                      .theme,
                                              material:
                                                  material,
                                            );
                                          },
                                          text:
                                              'Edit Price',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 15),
                          quantityInStockWidgetMaterialItem(
                            context: context,
                            material: material,
                            shopI: shopId(),
                          ),

                          SizedBox(height: 10),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(
                                  horizontal: 10.0,
                                ),
                            child: Column(
                              spacing: 0,
                              children: [
                                ManageThisItemToggleButtonMaterialItem(
                                  material: material,
                                  setStataAction: () {
                                    setState(() {});
                                  },
                                  theme: widget.theme,
                                ),
                                Visibility(
                                  visible:
                                      material.expiryDate !=
                                      null,
                                  child: BottomInfoSection(
                                    theme: widget.theme,
                                    mainText:
                                        material.expiryDate !=
                                                null
                                            ? getDayDifference(
                                                      material.expiryDate ??
                                                          DateTime.now(),
                                                    ) >=
                                                    1
                                                ? formatDateTime(
                                                  material.expiryDate ??
                                                      DateTime.now(),
                                                )
                                                : 'Item Expired'
                                            : 'Not Set',
                                    text: 'Expiry Date',
                                  ),
                                ),
                                Visibility(
                                  visible:
                                      material.sizeType !=
                                      null,
                                  child: BottomInfoSection(
                                    theme: widget.theme,
                                    mainText:
                                        material.sizeType ??
                                        'Not Set',
                                    text: 'Size Type',
                                  ),
                                ),
                                BottomInfoSection(
                                  theme: widget.theme,
                                  mainText:
                                      "(${material.categories?.length ?? 0}) Category(s)",
                                  text: 'Categories',
                                ),
                                BottomInfoSection(
                                  theme: widget.theme,
                                  mainText:
                                      (material.lowQtty ??
                                              10)
                                          .toString(),
                                  text:
                                      'Low Quantity Limit',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    spacing: 5,
                    children: [
                      Visibility(
                        visible: authorization(
                          authorized:
                              Authorizations()
                                  .transferMaterials,
                        ),
                        child: Expanded(
                          child: EditButton(
                            text: 'Transfer',
                            action: () {
                              transferMaterialsQuantity(
                                context,
                                material,
                              );
                            },
                            theme: returnTheme(context),
                            icon: Icons.rotate_left_rounded,
                            color: Colors.amber,
                          ),
                        ),
                      ),
                      Visibility(
                        visible: authorization(
                          authorized:
                              Authorizations()
                                  .deleteMaterials,
                        ),
                        child: Expanded(
                          child: EditButton(
                            text: 'Delete',
                            action: () {
                              final safeContext = context;
                              showDialog(
                                context: safeContext,
                                builder: (confirmDialog) {
                                  var provider =
                                      returnMaterialsProvider();
                                  return ConfirmationAlert(
                                    theme: returnTheme(
                                      context,
                                    ),
                                    message:
                                        'Are you sure you want to proceed with action?',
                                    title: 'Are you sure?',
                                    action: () async {
                                      Navigator.of(
                                        confirmDialog,
                                      ).pop();

                                      setState(() {
                                        isLoading = true;
                                      });
                                      MaterialsItemHistory
                                      materialsItemHistory = MaterialsItemHistory(
                                        shopId: shopId(),
                                        title:
                                            'Item Deleted',
                                        quantityChange: 0,
                                        newValue:
                                            (material.quantity ??
                                                    0)
                                                .toString(),
                                        desc:
                                            'Materials Item Deleted Now',
                                        isIncreased: false,
                                        oldValue:
                                            (material.quantity ??
                                                    0)
                                                .toString(),
                                      );
                                      await provider
                                          .deleteMaterialMain(
                                            isMultipleDelete:
                                                false,
                                            materialsItemHistory:
                                                materialsItemHistory,
                                            material:
                                                material,
                                          );
                                      setState(() {
                                        isLoading = false;
                                        showSuccess = true;
                                      });
                                      Future.delayed(
                                        Duration(
                                          seconds: 1,
                                        ),
                                        () {
                                          if (safeContext
                                              .mounted) {
                                            Navigator.of(
                                              safeContext,
                                            ).pop();
                                          }
                                        },
                                      );
                                    },
                                  );
                                },
                              );
                            },
                            theme: returnTheme(context),
                            icon:
                                Icons
                                    .delete_forever_outlined,
                            color: Colors.redAccent,
                          ),
                        ),
                      ),
                      Visibility(
                        visible: authorization(
                          authorized:
                              Authorizations()
                                  .updateMaterials,
                        ),
                        child: Expanded(
                          child: EditButton(
                            text: 'Edit',
                            action: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return AddMaterial(
                                      material: material,
                                    );
                                  },
                                ),
                              ).then((context) {
                                returnMaterialsProvider()
                                    .getSingleMaterialItemOnline(
                                      itemUuid:
                                          widget
                                              .materialUuid,
                                    );
                                setState(() {});
                              });
                            },
                            theme: returnTheme(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
          Visibility(
            visible: isLoading,
            child: returnCompProvider(
              context,
              listen: false,
            ).showLoader(message: 'Updating'),
          ),
        ],
      );
    }
  }
}
