import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_departments_class/department_class.dart';
import 'package:stockall/classes/temp_item_history/item_history.dart';
import 'package:stockall/classes/temp_item_history/item_history_event_class.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/classes/temp_shop/temp_shop_class.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/alert_dialogues/dialog_template.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/components/buttons/main_button_transparent.dart';
import 'package:stockall/components/major/empty_widget_display_only.dart';
import 'package:stockall/components/text_fields/general_textfield_only.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/services/product_linking_helper.dart';

/// Entry point to launch the Bulk Transfer workflow from total_products page.
Future<void> launchBulkTransferWorkflow({
  required BuildContext context,
  required Function(bool value) loadingAction,
}) async {
  final theme = returnTheme(context, listen: false);
  final selectedProducts = returnData().selectedProducts;

  if (selectedProducts.isEmpty) {
    showDialog(
      context: context,
      builder:
          (_) => InfoAlert(
            theme: theme,
            title: 'No Products Selected',
            message:
                'Please select one or more products to perform a bulk transfer.',
          ),
    );
    return;
  }

  final canTransferDept =
      returnShopProvider().userShop()?.manageDepartments ==
      true;
  final canTransferBranch =
      returnShopProvider().userShops.length > 1;

  if (!canTransferDept && !canTransferBranch) {
    showDialog(
      context: context,
      builder:
          (_) => InfoAlert(
            theme: theme,
            title: 'Transfer Unavailable',
            message:
                'You need multiple branches or department management enabled to transfer stock.',
          ),
    );
    return;
  }

  // Step 1: Destination Context Selection (Branch vs Department)
  if (canTransferDept && canTransferBranch) {
    showDialog(
      context: context,
      builder: (step1Context) {
        return DialogTemplate(
          theme: theme,
          title: 'Bulk Stock Transfer',
          message:
              'Select whether you want to transfer ${selectedProducts.length} selected product(s) to another branch or another department.',
          action: () {},
          showBottomActionButtons: false,
          widget: SizedBox(
            width: 500,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 10,
              children: [
                MainButtonTransparent(
                  themeProvider: theme,
                  constraints: const BoxConstraints(),
                  text: 'Transfer To Store Branch',
                  action: () {
                    Navigator.of(step1Context).pop();
                    _startBranchBulkTransfer(
                      context: context,
                      loadingAction: loadingAction,
                    );
                  },
                ),
                MainButtonTransparent(
                  themeProvider: theme,
                  constraints: const BoxConstraints(),
                  text: 'Transfer To Department',
                  action: () {
                    Navigator.of(step1Context).pop();
                    _startDepartmentBulkTransfer(
                      context: context,
                      loadingAction: loadingAction,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  } else if (canTransferBranch) {
    _startBranchBulkTransfer(
      context: context,
      loadingAction: loadingAction,
    );
  } else {
    _startDepartmentBulkTransfer(
      context: context,
      loadingAction: loadingAction,
    );
  }
}

void _startBranchBulkTransfer({
  required BuildContext context,
  required Function(bool value) loadingAction,
}) {
  final theme = returnTheme(context, listen: false);

  final isOnline = returnConnectivityProvider().isConnected;
  if (!isOnline) {
    showDialog(
      context: context,
      builder:
          (_) => InfoAlert(
            theme: theme,
            title: 'No Internet Connection',
            message:
                'You can only transfer items into other store branches when you have an active internet connection. Please connect to the internet and try again.',
          ),
    );
    return;
  }

  // Pick Destination Shop Branch
  TempShopClass? selectedShop;
  showDialog(
    context: context,
    builder: (branchPickContext) {
      return StatefulBuilder(
        builder: (stateContext, setState) {
          final otherShops =
              returnShopProvider().userShops
                  .where((s) => s.shopId != shopId())
                  .toList();

          return DialogTemplate(
            theme: theme,
            title: 'Select Destination Branch',
            message:
                'Select the destination branch to transfer ${returnData().selectedProducts.length} product(s) to.',
            action: () {
              if (selectedShop != null) {
                Navigator.of(branchPickContext).pop();
                _openBulkTransferWizard(
                  context: context,
                  isBranchTransfer: true,
                  targetShop: selectedShop,
                  loadingAction: loadingAction,
                );
              }
            },
            actionButtonText: 'Next',
            widget: SizedBox(
              width: 500,
              height: (screenHeight(stateContext) * 0.45)
                  .clamp(200.0, 420.0),
              child:
                  otherShops.isEmpty
                      ? EmptyWidgetDisplayOnly(
                        title: 'No Other Branches',
                        subText:
                            'No other store branches found.',
                        theme: theme,
                        height: 30,
                        icon: Icons.clear,
                      )
                      : SingleChildScrollView(
                        child: Column(
                          spacing: 4,
                          children:
                              otherShops.map((shop) {
                                final isSelected =
                                    selectedShop?.shopId ==
                                    shop.shopId;
                                return ListTile(
                                  title: Text(
                                    shop.name,
                                    style: TextStyle(
                                      fontWeight:
                                          isSelected
                                              ? FontWeight
                                                  .bold
                                              : FontWeight
                                                  .normal,
                                      fontSize:
                                          theme
                                              .mobileTexts
                                              .b3
                                              .fontSize,
                                    ),
                                  ),
                                  trailing: Icon(
                                    isSelected
                                        ? Icons
                                            .radio_button_checked
                                        : Icons
                                            .radio_button_off,
                                    color:
                                        isSelected
                                            ? theme
                                                .lightModeColor
                                                .prColor250
                                            : Colors.grey,
                                  ),
                                  onTap: () {
                                    setState(() {
                                      selectedShop =
                                          isSelected
                                              ? null
                                              : shop;
                                    });
                                  },
                                );
                              }).toList(),
                        ),
                      ),
            ),
          );
        },
      );
    },
  );
}

void _startDepartmentBulkTransfer({
  required BuildContext context,
  required Function(bool value) loadingAction,
}) {
  final theme = returnTheme(context, listen: false);

  DepartmentClass? selectedDept;
  showDialog(
    context: context,
    builder: (deptPickContext) {
      return StatefulBuilder(
        builder: (stateContext, setState) {
          final currentDeptUuid =
              returnDepartmentProvider()
                  .currentDepartment()
                  ?.uuid;
          final availableDepts =
              returnDepartmentProvider().departments
                  .where((d) => d.uuid != currentDeptUuid)
                  .toList();

          return DialogTemplate(
            theme: theme,
            title: 'Select Destination Department',
            message:
                'Select the department to transfer ${returnData().selectedProducts.length} product(s) to.',
            action: () {
              if (selectedDept != null) {
                Navigator.of(deptPickContext).pop();
                _openBulkTransferWizard(
                  context: context,
                  isBranchTransfer: false,
                  targetDepartment: selectedDept,
                  loadingAction: loadingAction,
                );
              }
            },
            actionButtonText: 'Next',
            widget: SizedBox(
              width: 500,
              height: (screenHeight(stateContext) * 0.45)
                  .clamp(200.0, 420.0),
              child:
                  availableDepts.isEmpty
                      ? EmptyWidgetDisplayOnly(
                        title: 'No Other Departments',
                        subText:
                            'No other departments available.',
                        theme: theme,
                        height: 30,
                        icon: Icons.clear,
                      )
                      : SingleChildScrollView(
                        child: Column(
                          spacing: 4,
                          children:
                              availableDepts.map((dept) {
                                final isSelected =
                                    selectedDept?.uuid ==
                                    dept.uuid;
                                return ListTile(
                                  title: Text(
                                    dept.name,
                                    style: TextStyle(
                                      fontWeight:
                                          isSelected
                                              ? FontWeight
                                                  .bold
                                              : FontWeight
                                                  .normal,
                                      fontSize:
                                          theme
                                              .mobileTexts
                                              .b3
                                              .fontSize,
                                    ),
                                  ),
                                  trailing: Icon(
                                    isSelected
                                        ? Icons
                                            .radio_button_checked
                                        : Icons
                                            .radio_button_off,
                                    color:
                                        isSelected
                                            ? theme
                                                .lightModeColor
                                                .prColor250
                                            : Colors.grey,
                                  ),
                                  onTap: () {
                                    setState(() {
                                      selectedDept =
                                          isSelected
                                              ? null
                                              : dept;
                                    });
                                  },
                                );
                              }).toList(),
                        ),
                      ),
            ),
          );
        },
      );
    },
  );
}

void _openBulkTransferWizard({
  required BuildContext context,
  required bool isBranchTransfer,
  TempShopClass? targetShop,
  DepartmentClass? targetDepartment,
  required Function(bool value) loadingAction,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return BulkTransferWizardDialog(
        isBranchTransfer: isBranchTransfer,
        targetShop: targetShop,
        targetDepartment: targetDepartment,
        loadingAction: loadingAction,
      );
    },
  );
}

/// Transfer item state used during resolution and quantity specification
class _TransferLineItem {
  final TempProductClass sourceProduct;
  TempProductClass? destinationProduct;
  bool isAutoLinked;
  bool isNewlyLinked;
  bool isCreateInDestination;
  double transferQuantity = 0.0;
  String? unitUuid;
  final TextEditingController quantityController;
  String? error;

  _TransferLineItem({
    required this.sourceProduct,
    this.destinationProduct,
    this.isAutoLinked = false,
    this.isNewlyLinked = false,
    this.isCreateInDestination = false,
    this.unitUuid,
    TextEditingController? controller,
  }) : quantityController =
           controller ?? TextEditingController(text: '0');
}

class BulkTransferWizardDialog extends StatefulWidget {
  final bool isBranchTransfer;
  final TempShopClass? targetShop;
  final DepartmentClass? targetDepartment;
  final Function(bool value) loadingAction;

  const BulkTransferWizardDialog({
    super.key,
    required this.isBranchTransfer,
    this.targetShop,
    this.targetDepartment,
    required this.loadingAction,
  });

  @override
  State<BulkTransferWizardDialog> createState() =>
      _BulkTransferWizardDialogState();
}

class _BulkTransferWizardDialogState
    extends State<BulkTransferWizardDialog> {
  // Wizard steps: 0 = Resolve Products, 1 = Specify Quantities, 2 = Confirmation
  int _currentStep = 0;
  bool _isLoadingProducts = true;
  String? _loadError;

  List<TempProductClass> _destinationPool = [];
  final List<_TransferLineItem> _transferItems = [];

  @override
  void initState() {
    super.initState();
    _initResolution();
  }

  @override
  void dispose() {
    for (final item in _transferItems) {
      item.quantityController.dispose();
    }
    super.dispose();
  }

  Future<void> _initResolution() async {
    setState(() {
      _isLoadingProducts = true;
      _loadError = null;
    });

    try {
      if (widget.isBranchTransfer) {
        _destinationPool = await returnData()
            .getProductsForOtherShops(
              widget.targetShop!.shopId!,
            );
      } else {
        _destinationPool =
            returnData().productListMain
                .where(
                  (p) =>
                      p.departmentUuid ==
                      widget.targetDepartment?.uuid,
                )
                .toList();
      }

      final sources = returnData().selectedProducts;
      _transferItems.clear();

      for (final src in sources) {
        final resolved =
            widget.isBranchTransfer
                ? ProductLinkingHelper.resolveLinkedProduct(
                  sourceProduct: src,
                  destinationProducts: _destinationPool,
                )
                : ProductLinkingHelper.resolveLinkedProductDepartment(
                  sourceProduct: src,
                  destinationProducts: _destinationPool,
                );

        final item = _TransferLineItem(
          sourceProduct: src,
          destinationProduct: resolved,
          isAutoLinked: resolved != null,
          isNewlyLinked: false,
          isCreateInDestination: false,
          unitUuid: src.getPrimaryUnit().uuid,
        );
        _transferItems.add(item);
      }

      setState(() {
        _isLoadingProducts = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingProducts = false;
        _loadError =
            'Failed to load destination products: $e';
      });
    }
  }

  void _manuallySelectDestinationProduct(
    _TransferLineItem item,
  ) {
    final theme = returnTheme(context, listen: false);
    final searchCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (pickerContext) {
        return StatefulBuilder(
          builder: (stateContext, setPickerState) {
            final query =
                searchCtrl.text.toLowerCase().trim();
            final filtered =
                _destinationPool.where((p) {
                  if (p.uuid == item.sourceProduct.uuid) {
                    return false;
                  }
                  if (query.isEmpty) return true;
                  return p.name.toLowerCase().contains(
                        query,
                      ) ||
                      (p.barcode != null &&
                          p.barcode!.toLowerCase().contains(
                            query,
                          ));
                }).toList();

            return DialogTemplate(
              theme: theme,
              title: 'Select Destination Product',
              message:
                  'Choose the corresponding product for "${item.sourceProduct.name}" in ${widget.targetShop?.name ?? widget.targetDepartment?.name}.',
              action: () {},
              showBottomActionButtons: false,
              widget: SizedBox(
                width: 500,
                height: (screenHeight(context) * 0.55)
                    .clamp(280.0, 500.0),
                child: Column(
                  children: [
                    GeneralTextfieldOnly(
                      hint: 'Search name or barcode...',
                      controller: searchCtrl,
                      lines: 1,
                      theme: theme,
                      onChanged:
                          (_) => setPickerState(() {}),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      mouseCursor: SystemMouseCursors.click,
                      onTap: () {
                        setState(() {
                          item.isCreateInDestination = true;
                          item.destinationProduct = item
                              .sourceProduct
                              .copyWith(
                                uuid: uuidGen(),
                                name:
                                    item.sourceProduct.name,
                                shopId:
                                    widget.isBranchTransfer
                                        ? widget
                                            .targetShop!
                                            .shopId
                                        : shopId(),
                                departmentUuid:
                                    !widget.isBranchTransfer
                                        ? widget
                                            .targetDepartment
                                            ?.uuid
                                        : null,
                                departmentName:
                                    !widget.isBranchTransfer
                                        ? widget
                                            .targetDepartment
                                            ?.name
                                        : null,
                              );
                          item.isAutoLinked = false;
                          item.isNewlyLinked = true;
                          item.error = null;
                        });
                        Navigator.of(pickerContext).pop();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: theme
                              .lightModeColor
                              .prColor250
                              .withValues(alpha: 0.08),
                          borderRadius:
                              BorderRadius.circular(6),
                          border: Border.all(
                            color: theme
                                .lightModeColor
                                .prColor250
                                .withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons
                                  .add_circle_outline_rounded,
                              size: 16,
                              color:
                                  theme
                                      .lightModeColor
                                      .prColor250,
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                'Create "${item.sourceProduct.name}" in ${widget.targetShop?.name ?? widget.targetDepartment?.name}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight:
                                      FontWeight.bold,
                                  color:
                                      theme
                                          .lightModeColor
                                          .prColor250,
                                ),
                                overflow:
                                    TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child:
                          filtered.isEmpty
                              ? EmptyWidgetDisplayOnly(
                                title:
                                    'No Matching Products',
                                subText:
                                    'No matching products found in destination.',
                                theme: theme,
                                height: 25,
                                icon: Icons.search_off,
                              )
                              : SingleChildScrollView(
                                child: Column(
                                  spacing: 4,
                                  children:
                                      filtered.map((p) {
                                        final isChosen =
                                            item
                                                .destinationProduct
                                                ?.uuid ==
                                            p.uuid;
                                        return ListTile(
                                          dense: true,
                                          title: Text(
                                            p.name,
                                            style: TextStyle(
                                              fontWeight:
                                                  isChosen
                                                      ? FontWeight
                                                          .bold
                                                      : FontWeight
                                                          .normal,
                                              fontSize:
                                                  theme
                                                      .mobileTexts
                                                      .b3
                                                      .fontSize,
                                            ),
                                          ),
                                          subtitle: Text(
                                            'Available: ${formatLargeNumberDouble(p.getPrimaryUnitQuantity(index: 1))} ${p.getPrimaryUnit().name}',
                                            style:
                                                const TextStyle(
                                                  fontSize:
                                                      11,
                                                ),
                                          ),
                                          trailing:
                                              isChosen
                                                  ? Icon(
                                                    Icons
                                                        .check_circle,
                                                    color:
                                                        theme.lightModeColor.prColor250,
                                                  )
                                                  : const Icon(
                                                    Icons
                                                        .chevron_right,
                                                    color:
                                                        Colors.grey,
                                                  ),
                                          onTap: () {
                                            setState(() {
                                              item.destinationProduct =
                                                  p;
                                              item.isAutoLinked =
                                                  false;
                                              item.isNewlyLinked =
                                                  true;
                                              item.error =
                                                  null;
                                            });
                                            Navigator.of(
                                              pickerContext,
                                            ).pop();
                                          },
                                        );
                                      }).toList(),
                                ),
                              ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  bool _validateStep1() {
    bool hasUnresolved = false;
    for (final item in _transferItems) {
      if (item.destinationProduct == null) {
        hasUnresolved = true;
        item.error = 'Please select a destination product';
      } else {
        item.error = null;
      }
    }
    setState(() {});
    return !hasUnresolved;
  }

  bool _validateStep2() {
    bool hasError = false;
    for (final item in _transferItems) {
      final src = item.sourceProduct;
      final dest = item.destinationProduct;

      final text = item.quantityController.text
          .trim()
          .replaceAll(',', '');
      final val = double.tryParse(text);

      if (val == null || val <= 0) {
        item.error =
            'Enter a valid transfer quantity (> 0)';
        hasError = true;
        continue;
      }

      if (dest == null) {
        item.error = 'Destination product not selected';
        hasError = true;
        continue;
      }

      if (!item.isCreateInDestination &&
          dest.uuid != null &&
          dest.uuid == src.uuid &&
          (!widget.isBranchTransfer ||
              dest.shopId == src.shopId)) {
        item.error =
            'Source and destination cannot be the same product';
        hasError = true;
        continue;
      }

      final selectedUnit = src.getProductUnit(
        unitUuid: item.unitUuid,
      );
      // Check available quantity in base unit
      final primaryUnitEquiv = selectedUnit
          .getQuantityEquivMultiplied(
            index: 1,
            newQuantity: val,
            product: src,
          );

      final availableActual =
          src.getActualQuantity() ?? 0.0;
      if (primaryUnitEquiv > availableActual + 0.00001) {
        final availableInSelected = selectedUnit
            .getQuantityEquivDivided(
              index: 1,
              product: src,
              newQuantity: availableActual,
            );
        item.error =
            'Exceeds available stock (Max ${formatLargeNumberDouble(availableInSelected)} ${selectedUnit.name})';
        hasError = true;
        continue;
      }

      item.transferQuantity = val;
      item.error = null;
    }

    setState(() {});
    return !hasError;
  }

  Future<void> _executeBulkTransfer() async {
    Navigator.of(context).pop();
    Navigator.of(context).pop(); // Close wizard dialog
    widget.loadingAction(true);

    final successItems = <String>[];
    final failedItems = <String>[];

    final isBranch = widget.isBranchTransfer;
    final targetShop = widget.targetShop;
    final targetDept = widget.targetDepartment;

    for (final item in _transferItems) {
      final src = item.sourceProduct;
      final dest = item.destinationProduct;
      final enteredVal = item.transferQuantity;
      final unitUuid = item.unitUuid;

      if (dest == null || enteredVal <= 0) continue;

      try {
        final equivQty = src
            .getProductUnit(unitUuid: unitUuid)
            .getQuantityEquivMultiplied(
              index: 1,
              newQuantity: enteredVal,
              product: src,
            );

        TempProductClass? updatedDest;
        if (item.isCreateInDestination) {
          updatedDest =
              await ProductLinkingHelper.createDestinationProductFromTransfer(
                sourceProduct: src,
                enteredTransferQuantity: enteredVal,
                unitUuid: unitUuid,
                isBranchTransfer: isBranch,
                targetShop: targetShop,
                targetDepartment: targetDept,
              );
          if (updatedDest == null) {
            failedItems.add(
              '${src.name}: Failed to create product in destination',
            );
            continue;
          }
        } else {
          // 1. Destination addition
          final destArea = dest.dimensionArea();
          final currentDestActual =
              dest.getActualQuantity() ?? 0.0;
          final newDestActual =
              currentDestActual + equivQty;
          updatedDest = dest.copyWith(
            quantity:
                dest.quantityType == 2
                    ? newDestActual / destArea
                    : newDestActual,
          );

          final destHistory = ItemHistory(
            event: ItemHistoryEventClass.transferedIn,
            isManaged: dest.isManaged,
            source:
                isBranch
                    ? ItemHistoryEventClass
                        .branchStoreSource
                    : ItemHistoryEventClass
                        .departmentSource,
            destination:
                ItemHistoryEventClass.productDestination,
            shopId:
                isBranch ? targetShop!.shopId! : shopId(),
            isIncreased: true,
            title: 'Transfered In',
            desc:
                isBranch
                    ? 'Item Quantity Received From Transfer - From Item Name: ${src.name}. Shop Name: ${returnShopProvider().userShop()?.name ?? 'Main Branch'}.'
                    : 'Item Quantity Received From Transfer - From Item Name: ${src.name}. Department Name: ${returnDepartmentProvider().currentDepartment()?.name ?? 'Not Set'}.',
            createdAt: DateTime.now(),
            itemUuid: updatedDest.uuid,
            itemName: updatedDest.name,
            newValue: formatLargeNumberDouble(
              updatedDest
                  .getProductUnit()
                  .getQuantityEquivDivided(
                    index: 1,
                    newQuantity: newDestActual,
                    product: updatedDest,
                  ),
            ),
            oldValue: formatLargeNumberDouble(
              dest.getProductUnit().getQuantityEquivDivided(
                index: 1,
                newQuantity: currentDestActual,
                product: dest,
              ),
            ),
            quantityChange: enteredVal,
            staffId: currentUser().userId,
            staffName: currentUser().name,
            unit:
                src.getProductUnit(unitUuid: unitUuid).name,
            primaryUnit: updatedDest.getProductUnit().name,
            departmentName: updatedDest.departmentName,
            departmentUuid: updatedDest.departmentUuid,
          );

          dynamic resDest;
          if (isBranch) {
            resDest = await returnData()
                .updateProductForOtherShops(
                  product: updatedDest,
                  itemHistory: destHistory,
                );
          } else {
            resDest = await returnData().updateProduct(
              product: updatedDest,
              isQuantityUpdate: true,
              includeQuantity: true,
              quantityChange:
                  updatedDest.quantityType == 2
                      ? equivQty / destArea
                      : equivQty,
              isIncrement: true,
              itemHistory: destHistory,
              isMultipleUpdate: true,
            );
          }

          if (resDest == null) {
            failedItems.add(
              '${src.name}: Destination update failed',
            );
            continue;
          }
        }

        // 2. Source deduction
        final sourceArea = src.dimensionArea();
        final currentSourceActual =
            src.getActualQuantity() ?? 0.0;
        final newSourceActual =
            currentSourceActual - equivQty;
        final updatedSource = src.copyWith(
          quantity:
              src.quantityType == 2
                  ? newSourceActual / sourceArea
                  : newSourceActual,
        );

        final sourceHistory = ItemHistory(
          event: ItemHistoryEventClass.transferedOut,
          isManaged: src.isManaged,
          source: ItemHistoryEventClass.productSource,
          destination:
              isBranch
                  ? ItemHistoryEventClass
                      .branchStoreDestination
                  : ItemHistoryEventClass
                      .departmentDestination,
          shopId: shopId(),
          isIncreased: false,
          title: 'Transfered Out',
          desc:
              isBranch
                  ? 'Item Quantity Transfered To - Item Name: ${dest.name}, Shop Name: ${targetShop!.name}.'
                  : 'Item Quantity Transfered To - Item Name: ${dest.name}, Department Name: ${targetDept?.name ?? 'Not Set'}.',
          createdAt: DateTime.now(),
          itemUuid: updatedSource.uuid,
          itemName: updatedSource.name,
          newValue: formatLargeNumberDouble(
            updatedSource
                .getProductUnit()
                .getQuantityEquivDivided(
                  index: 1,
                  newQuantity: newSourceActual,
                  product: updatedSource,
                ),
          ),
          oldValue: formatLargeNumberDouble(
            src.getProductUnit().getQuantityEquivDivided(
              index: 1,
              newQuantity: currentSourceActual,
              product: src,
            ),
          ),
          quantityChange: -enteredVal,
          staffId: currentUser().userId,
          staffName: currentUser().name,
          unit:
              updatedSource
                  .getProductUnit(unitUuid: unitUuid)
                  .name,
          primaryUnit: src.getProductUnit().name,
        );

        final resSource = await returnData().updateProduct(
          product: updatedSource,
          isQuantityUpdate: true,
          includeQuantity: true,
          quantityChange:
              updatedSource.quantityType == 2
                  ? equivQty / sourceArea
                  : equivQty,
          isIncrement: false,
          itemHistory: sourceHistory,
          isMultipleUpdate: true,
        );

        if (resSource == null) {
          failedItems.add(
            '${src.name}: Source deduction failed',
          );
          continue;
        }

        // 3. Save relationship if newly linked manually (and not already linked by creation)
        if (item.isNewlyLinked &&
            !item.isCreateInDestination) {
          if (isBranch && dest.uuid != null) {
            await ProductLinkingHelper.linkProducts(
              sourceProduct: updatedSource,
              targetProduct: updatedDest,
            );
          } else if (!isBranch && dest.uuid != null) {
            await ProductLinkingHelper.linkProductsDepartment(
              sourceProduct: updatedSource,
              targetProduct: updatedDest,
            );
          }
        }

        successItems.add(src.name);
      } catch (e) {
        failedItems.add('${src.name}: $e');
      }
    }

    await returnData().getProductsOffline(shopId());
    returnData().toggleIsSelectProduct(false);
    returnData().syncData();

    widget.loadingAction(false);

    if (!mounted) return;

    // Show summary result alert
    final theme = returnTheme(context, listen: false);
    if (failedItems.isEmpty) {
      showDialog(
        context: context,
        builder:
            (_) => InfoAlert(
              theme: theme,
              title: 'Bulk Transfer Complete',
              message:
                  'Successfully transferred all ${successItems.length} product(s) to ${widget.targetShop?.name ?? widget.targetDepartment?.name}.',
            ),
      );
    } else {
      showDialog(
        context: context,
        builder:
            (_) => InfoAlert(
              theme: theme,
              title:
                  successItems.isNotEmpty
                      ? 'Partial Transfer Completed'
                      : 'Bulk Transfer Failed',
              message:
                  'Transferred ${successItems.length} product(s) successfully.\n\nFailed (${failedItems.length}):\n${failedItems.join('\n')}',
            ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = returnTheme(context, listen: false);
    final isMobile = screenWidth(context) < mobileScreen;
    final destTitle =
        widget.targetShop?.name ??
        widget.targetDepartment?.name ??
        'Destination';

    if (_isLoadingProducts) {
      return DialogTemplate(
        theme: theme,
        title: 'Resolving Products',
        message:
            'Identifying linked destination products...',
        action: () {},
        showBottomActionButtons: false,
        widget: const SizedBox(
          width: 500,
          height: 180,
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (_loadError != null) {
      return DialogTemplate(
        theme: theme,
        title: 'Error Loading Products',
        message: _loadError!,
        action: () => Navigator.of(context).pop(),
        actionButtonText: 'Close',
        widget: const SizedBox(width: 500),
      );
    }

    if (_currentStep == 0) {
      // Step 1: Destination Resolution Screen
      final unlinkedCount =
          _transferItems
              .where((i) => i.destinationProduct == null)
              .length;

      return DialogTemplate(
        theme: theme,
        title: 'Bulk Transfer',
        message:
            'Destination: $destTitle. Linked products are automatically identified. Manually match unlinked products.',
        action: () {
          if (_validateStep1()) {
            setState(() => _currentStep = 1);
          }
        },
        actionButtonText: 'Proceed',
        cancelAction: () => Navigator.of(context).pop(),
        widget: SizedBox(
          width: 500,
          height:
              isMobile
                  ? (screenHeight(context) * 0.6).clamp(
                    300.0,
                    520.0,
                  )
                  : 460,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color:
                      unlinkedCount == 0
                          ? Colors.green.shade50
                          : Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color:
                        unlinkedCount == 0
                            ? Colors.green.shade200
                            : Colors.orange.shade200,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      unlinkedCount == 0
                          ? Icons.check_circle_rounded
                          : Icons.info_outline_rounded,
                      color:
                          unlinkedCount == 0
                              ? Colors.green.shade700
                              : Colors.orange.shade800,
                      size: 17,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        unlinkedCount == 0
                            ? 'All ${_transferItems.length} products resolved!'
                            : '$unlinkedCount product(s) need manual destination matching.',
                        style: TextStyle(
                          fontSize:
                              theme.mobileTexts.b3.fontSize,
                          fontWeight: FontWeight.bold,
                          color:
                              unlinkedCount == 0
                                  ? Colors.green.shade800
                                  : Colors.orange.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    spacing: 12,
                    children:
                        _transferItems.map((item) {
                          final dest =
                              item.destinationProduct;

                          return Container(
                            padding: const EdgeInsets.all(
                              10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius:
                                  BorderRadius.circular(8),
                              border: Border.all(
                                color:
                                    item.error != null
                                        ? Colors
                                            .red
                                            .shade300
                                        : Colors
                                            .grey
                                            .shade200,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item
                                            .sourceProduct
                                            .name,
                                        style: TextStyle(
                                          fontWeight:
                                              FontWeight
                                                  .bold,
                                          fontSize:
                                              theme
                                                  .mobileTexts
                                                  .b3
                                                  .fontSize,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      'Available: ${item.sourceProduct.getActualQuantity() ?? 0} ${item.sourceProduct.getProductUnit().name}',
                                      style: TextStyle(
                                        color:
                                            Colors
                                                .grey
                                                .shade600,
                                        fontSize:
                                            theme
                                                .mobileTexts
                                                .b4
                                                .fontSize,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons
                                          .subdirectory_arrow_right_rounded,
                                      size: 16,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(
                                      width: 6,
                                    ),
                                    Expanded(
                                      child:
                                          dest != null
                                              ? Row(
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal:
                                                          6,
                                                      vertical:
                                                          2,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color:
                                                          item.isCreateInDestination
                                                              ? Colors.purple.shade100
                                                              : (item.isAutoLinked
                                                                  ? Colors.green.shade100
                                                                  : Colors.blue.shade100),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            4,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      item.isCreateInDestination
                                                          ? 'Will Create'
                                                          : (item.isAutoLinked
                                                              ? 'Auto-Linked'
                                                              : 'Selected'),
                                                      style: TextStyle(
                                                        fontSize:
                                                            theme.mobileTexts.b5.fontSize,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color:
                                                            item.isCreateInDestination
                                                                ? Colors.purple.shade800
                                                                : (item.isAutoLinked
                                                                    ? Colors.green.shade800
                                                                    : Colors.blue.shade800),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    width:
                                                        6,
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      item.isCreateInDestination
                                                          ? '${dest.name} (New Product)'
                                                          : dest.name,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize:
                                                            theme.mobileTexts.b4.fontSize,
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              )
                                              : Text(
                                                'No matching destination product',
                                                style: TextStyle(
                                                  color:
                                                      Colors
                                                          .red
                                                          .shade700,
                                                  fontSize:
                                                      theme
                                                          .mobileTexts
                                                          .b4
                                                          .fontSize,
                                                  fontStyle:
                                                      FontStyle
                                                          .italic,
                                                ),
                                              ),
                                    ),
                                    Row(
                                      mainAxisSize:
                                          MainAxisSize.min,
                                      children: [
                                        if (dest == null)
                                          TextButton(
                                            onPressed: () {
                                              setState(() {
                                                item.isCreateInDestination =
                                                    true;
                                                item.destinationProduct = item.sourceProduct.copyWith(
                                                  name:
                                                      item
                                                          .sourceProduct
                                                          .name,
                                                  shopId:
                                                      widget.isBranchTransfer
                                                          ? widget.targetShop!.shopId
                                                          : shopId(),
                                                  departmentUuid:
                                                      !widget.isBranchTransfer
                                                          ? widget.targetDepartment?.uuid
                                                          : null,
                                                  departmentName:
                                                      !widget.isBranchTransfer
                                                          ? widget.targetDepartment?.name
                                                          : null,
                                                );
                                                item.isAutoLinked =
                                                    false;
                                                item.isNewlyLinked =
                                                    true;
                                                item.error =
                                                    null;
                                              });
                                            },
                                            style: TextButton.styleFrom(
                                              visualDensity:
                                                  VisualDensity
                                                      .compact,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal:
                                                        6,
                                                    vertical:
                                                        4,
                                                  ),
                                            ),
                                            child: Text(
                                              '+ Create${screenWidth(context) > mobileScreen ? ' New' : ''}',
                                              style: TextStyle(
                                                fontSize:
                                                    theme
                                                        .mobileTexts
                                                        .b4
                                                        .fontSize,
                                                color:
                                                    Colors
                                                        .purple
                                                        .shade700,
                                                fontWeight:
                                                    FontWeight
                                                        .bold,
                                              ),
                                            ),
                                          ),
                                        TextButton(
                                          onPressed:
                                              () =>
                                                  _manuallySelectDestinationProduct(
                                                    item,
                                                  ),
                                          style: TextButton.styleFrom(
                                            visualDensity:
                                                VisualDensity
                                                    .compact,
                                            padding:
                                                const EdgeInsets.symmetric(
                                                  horizontal:
                                                      8,
                                                  vertical:
                                                      4,
                                                ),
                                          ),
                                          child: Text(
                                            dest != null
                                                ? 'Change'
                                                : 'Select${screenWidth(context) > mobileScreen ? ' Product' : ''}',
                                            style: TextStyle(
                                              fontSize:
                                                  theme
                                                      .mobileTexts
                                                      .b4
                                                      .fontSize,
                                              color:
                                                  theme
                                                      .lightModeColor
                                                      .prColor250,
                                              fontWeight:
                                                  FontWeight
                                                      .bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                if (item.error != null)
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(
                                          top: 4,
                                        ),
                                    child: Text(
                                      item.error!,
                                      style: TextStyle(
                                        color:
                                            Colors
                                                .red
                                                .shade700,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_currentStep == 1) {
      // Step 2: Quantity Specification Screen
      return DialogTemplate(
        theme: theme,
        title: 'Specify Quantities',
        message:
            'Enter the quantity to transfer for each product to $destTitle.',
        action: () {
          if (_validateStep2()) {
            setState(() => _currentStep = 2);
          }
        },
        actionButtonText: 'Review',
        cancelAction:
            () => setState(() => _currentStep = 0),
        cancelText: 'Back',
        widget: SizedBox(
          width: 500,
          height:
              isMobile
                  ? (screenHeight(context) * 0.6).clamp(
                    300.0,
                    520.0,
                  )
                  : 460,
          child: SingleChildScrollView(
            child: Column(
              spacing: 12,
              children:
                  _transferItems.map((item) {
                    final src = item.sourceProduct;
                    final dest = item.destinationProduct!;
                    final totalBaseActual =
                        src.getActualQuantity() ?? 0.0;
                    final primaryQty = src
                        .getPrimaryUnitQuantity(index: 1);
                    final primaryUnit =
                        src.getPrimaryUnit();
                    final selectedUnit = src.getProductUnit(
                      unitUuid: item.unitUuid,
                    );
                    final availableInSelectedUnit =
                        selectedUnit
                            .getQuantityEquivDivided(
                              index: 1,
                              product: src,
                            );

                    final units =
                        (src.unitsList ?? []).isNotEmpty
                            ? src.unitsList!
                            : [src.getProductUnit()];

                    return Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(
                          8,
                        ),
                        border: Border.all(
                          color:
                              item.error != null
                                  ? Colors.red.shade300
                                  : Colors.grey.shade200,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  src.name,
                                  style: TextStyle(
                                    fontWeight:
                                        FontWeight.bold,
                                    fontSize:
                                        theme
                                            .mobileTexts
                                            .b3
                                            .fontSize,
                                  ),
                                ),
                              ),
                              Text(
                                'Available: ${formatLargeNumberDouble(availableInSelectedUnit)} ${selectedUnit.name}${!selectedUnit.isPrimary ? ' (${formatLargeNumberDouble(primaryQty)} ${primaryUnit.name})' : ''}',
                                style: TextStyle(
                                  color:
                                      Colors.grey.shade700,
                                  fontSize:
                                      theme
                                          .mobileTexts
                                          .b4
                                          .fontSize,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Destination: ${dest.name} ($destTitle)',
                            style: TextStyle(
                              fontSize:
                                  theme
                                      .mobileTexts
                                      .b4
                                      .fontSize,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Container(
                                  height: 34,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                        BorderRadius.circular(
                                          6,
                                        ),
                                    border: Border.all(
                                      color:
                                          item.error != null
                                              ? Colors
                                                  .red
                                                  .shade400
                                              : Colors
                                                  .grey
                                                  .shade300,
                                      width: 1,
                                    ),
                                  ),
                                  child: TextField(
                                    controller:
                                        item.quantityController,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                    style: TextStyle(
                                      fontSize:
                                          theme
                                              .mobileTexts
                                              .b4
                                              .fontSize,
                                      fontWeight:
                                          FontWeight.w500,
                                      color: Colors.black87,
                                    ),
                                    decoration: InputDecoration(
                                      hintText:
                                          'Transfer Qty',
                                      hintStyle: TextStyle(
                                        fontSize:
                                            theme
                                                .mobileTexts
                                                .b4
                                                .fontSize,
                                        fontWeight:
                                            FontWeight
                                                .normal,
                                        color:
                                            Colors
                                                .grey
                                                .shade400,
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 8,
                                          ),
                                      border:
                                          InputBorder.none,
                                      isDense: true,
                                    ),
                                    onChanged: (text) {
                                      final clean = text
                                          .trim()
                                          .replaceAll(
                                            ',',
                                            '',
                                          );
                                      final val =
                                          double.tryParse(
                                            clean,
                                          );
                                      if (val != null &&
                                          val > 0) {
                                        final inBase =
                                            selectedUnit
                                                .getQuantityEquivMultiplied(
                                                  index: 1,
                                                  newQuantity:
                                                      val,
                                                  product:
                                                      src,
                                                );
                                        if (inBase >
                                            totalBaseActual +
                                                0.00001) {
                                          setState(() {
                                            item.error =
                                                'Exceeds available stock: Max is ${formatLargeNumberDouble(availableInSelectedUnit)} ${selectedUnit.name}';
                                          });
                                          return;
                                        }
                                      }
                                      if (item.error !=
                                          null) {
                                        setState(
                                          () =>
                                              item.error =
                                                  null,
                                        );
                                      }
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (units.length > 1)
                                Expanded(
                                  flex: 2,
                                  child: Container(
                                    padding:
                                        const EdgeInsets.symmetric(
                                          horizontal: 8,
                                        ),
                                    height: 34,
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.circular(
                                            6,
                                          ),
                                      color: Colors.white,
                                      border: Border.all(
                                        color:
                                            Colors
                                                .grey
                                                .shade300,
                                        width: 1,
                                      ),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<
                                        String
                                      >(
                                        value:
                                            item.unitUuid ??
                                            units
                                                .first
                                                .uuid,
                                        isExpanded: true,
                                        items:
                                            units.map((u) {
                                              return DropdownMenuItem<
                                                String
                                              >(
                                                value:
                                                    u.uuid,
                                                child: Text(
                                                  u.name,
                                                  style: TextStyle(
                                                    fontSize:
                                                        theme.mobileTexts.b4.fontSize,
                                                  ),
                                                  overflow:
                                                      TextOverflow
                                                          .ellipsis,
                                                ),
                                              );
                                            }).toList(),
                                        onChanged: (
                                          newUuid,
                                        ) {
                                          if (newUuid ==
                                                  null ||
                                              newUuid ==
                                                  item.unitUuid) {
                                            return;
                                          }
                                          final oldUnit = src
                                              .getProductUnit(
                                                unitUuid:
                                                    item.unitUuid,
                                              );
                                          final newUnit = src
                                              .getProductUnit(
                                                unitUuid:
                                                    newUuid,
                                              );

                                          final currentText = item
                                              .quantityController
                                              .text
                                              .trim()
                                              .replaceAll(
                                                ',',
                                                '',
                                              );
                                          final currentVal =
                                              double.tryParse(
                                                currentText,
                                              );

                                          final newMax = newUnit
                                              .getQuantityEquivDivided(
                                                index: 1,
                                                product:
                                                    src,
                                                newQuantity:
                                                    totalBaseActual,
                                              );

                                          if (currentVal !=
                                                  null &&
                                              currentVal >
                                                  0) {
                                            final inBase = oldUnit
                                                .getQuantityEquivMultiplied(
                                                  index: 1,
                                                  newQuantity:
                                                      currentVal,
                                                  product:
                                                      src,
                                                );
                                            final inNewUnit =
                                                newUnit.getQuantityEquivDivided(
                                                  index: 1,
                                                  product:
                                                      src,
                                                  newQuantity:
                                                      inBase,
                                                );
                                            final clamped =
                                                inNewUnit >
                                                        newMax
                                                    ? newMax
                                                    : inNewUnit;
                                            item
                                                    .quantityController
                                                    .text =
                                                formatLargeNumberDouble(
                                                  clamped,
                                                );
                                          }

                                          setState(() {
                                            item.unitUuid =
                                                newUuid;
                                            item.error =
                                                null;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                )
                              else
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                  child: Text(
                                    src
                                        .getProductUnit()
                                        .name,
                                    style: TextStyle(
                                      fontWeight:
                                          FontWeight.bold,
                                      fontSize:
                                          theme
                                              .mobileTexts
                                              .b5
                                              .fontSize,
                                    ),
                                  ),
                                ),
                              const SizedBox(width: 8),
                              SizedBox(
                                height: 34,
                                child: OutlinedButton(
                                  onPressed: () {
                                    setState(() {
                                      item
                                          .quantityController
                                          .text = formatLargeNumberDouble(
                                        availableInSelectedUnit,
                                      );
                                      item.error = null;
                                    });
                                  },

                                  style: OutlinedButton.styleFrom(
                                    visualDensity:
                                        VisualDensity
                                            .compact,
                                    padding:
                                        const EdgeInsets.symmetric(
                                          horizontal: 10,
                                        ),
                                    side: BorderSide(
                                      color:
                                          theme
                                              .lightModeColor
                                              .prColor250,
                                      width: 1.2,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(
                                            6,
                                          ),
                                    ),
                                  ),
                                  child: Text(
                                    'MAX',
                                    style: TextStyle(
                                      fontSize:
                                          theme
                                              .mobileTexts
                                              .b5
                                              .fontSize,
                                      fontWeight:
                                          FontWeight.bold,
                                      color:
                                          theme
                                              .lightModeColor
                                              .prColor250,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (item.error != null)
                            Padding(
                              padding:
                                  const EdgeInsets.only(
                                    top: 4,
                                  ),
                              child: Text(
                                item.error!,
                                style: TextStyle(
                                  color:
                                      Colors.red.shade700,
                                  fontSize:
                                      theme
                                          .mobileTexts
                                          .b4
                                          .fontSize,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  }).toList(),
            ),
          ),
        ),
      );
    }

    // Step 3: Review & Confirmation Screen
    return DialogTemplate(
      theme: theme,
      title: 'Confirm Bulk Transfer',
      message:
          'Review the stock transfer of ${_transferItems.length} products to $destTitle. This action will deduct stock from the source and add to the destination.',
      action: () {
        showDialog(
          context: context,
          builder: (confirmContext) {
            return ConfirmationAlert(
              theme: theme,
              message:
                  'You are about to Perform Item Transfer. Are you sure You want to Proceed?',
              title: 'Proceed with Transfer?',
              action: _executeBulkTransfer,
            );
          },
        );
      },
      actionButtonText: 'Confirm',
      cancelAction: () => setState(() => _currentStep = 1),
      cancelText: 'Back',
      widget: SizedBox(
        width: 500,
        height:
            isMobile
                ? (screenHeight(context) * 0.55).clamp(
                  280.0,
                  480.0,
                )
                : 420,
        child: SingleChildScrollView(
          child: Column(
            spacing: 12,
            children:
                _transferItems.map((item) {
                  final src = item.sourceProduct;
                  final dest = item.destinationProduct!;
                  final unitName =
                      src
                          .getProductUnit(
                            unitUuid: item.unitUuid,
                          )
                          .name;

                  return Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(
                        8,
                      ),
                      border: Border.all(
                        color: Colors.grey.shade300,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                src.name,
                                style: TextStyle(
                                  fontWeight:
                                      FontWeight.bold,
                                  fontSize:
                                      theme
                                          .mobileTexts
                                          .b3
                                          .fontSize,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'To: ${dest.name} ($destTitle)',
                                style: TextStyle(
                                  color:
                                      Colors.grey.shade600,
                                  fontSize:
                                      theme
                                          .mobileTexts
                                          .b4
                                          .fontSize,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding:
                              const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                          decoration: BoxDecoration(
                            color: theme
                                .lightModeColor
                                .prColor250
                                .withValues(alpha: 0.12),
                            borderRadius:
                                BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${formatLargeNumberDouble(item.transferQuantity)} $unitName',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color:
                                  theme
                                      .lightModeColor
                                      .prColor250,
                              fontSize:
                                  theme
                                      .mobileTexts
                                      .b4
                                      .fontSize,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
          ),
        ),
      ),
    );
  }
}
