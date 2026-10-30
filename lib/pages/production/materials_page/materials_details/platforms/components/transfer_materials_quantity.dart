import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_departments_class/department_class.dart';
import 'package:stockall/classes/temp_production_folder/temp_material_class/material_class.dart';
import 'package:stockall/classes/temp_production_folder/temp_materials_item_history/material_item_history_event_class.dart';
import 'package:stockall/classes/temp_production_folder/temp_materials_item_history/materials_item_history.dart';
import 'package:stockall/classes/temp_shop/temp_shop_class.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/alert_dialogues/dialog_template.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/components/buttons/main_button_p.dart';
import 'package:stockall/components/buttons/main_button_transparent.dart';
import 'package:stockall/components/major/empty_widget_display_only.dart';
import 'package:stockall/components/text_fields/edit_cart_text_field.dart';
import 'package:stockall/components/text_fields/general_textfield_only.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/subscription/general_settings_auth.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/products/product_details/platforms/components/edit_button.dart';
import 'package:stockall/pages/products/product_details/platforms/components/unit_selection_widget.dart';

Future<Object?> transferMaterialsQuantity(
  BuildContext context,
  MaterialClass materialsItem,
) {
  return showGeneralDialog(
    context: context,
    pageBuilder: (context, animation, secondaryAnimation) {
      return TransferMaterialsQuantityWidget(materialsItem: materialsItem);
    },
  );
}

class TransferMaterialsQuantityWidget extends StatefulWidget {
  final MaterialClass materialsItem;
  const TransferMaterialsQuantityWidget({
    super.key,
    required this.materialsItem,
  });

  @override
  State<TransferMaterialsQuantityWidget> createState() =>
      _TransferMaterialsQuantityWidgetState();
}

class _TransferMaterialsQuantityWidgetState
    extends State<TransferMaterialsQuantityWidget> {
  bool isEditQuantityLoading = false;
  final quantityController = TextEditingController();
  String? unitUuid;

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    final isMobile = screenWidth(context) < mobileScreen;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: GestureDetector(
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: SingleChildScrollView(
              child: Container(
                decoration: const BoxDecoration(color: Colors.white),
                child: Padding(
                  padding: EdgeInsets.only(left: 20.0, top: isMobile ? 10 : 40, right: 20, bottom: isMobile ? 20 : 0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(isMobile ? 20 : 30),
                        margin: EdgeInsets.only(bottom: isMobile ? 20 : 100),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(39, 4, 1, 41),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    width: 500,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Opacity(
                              opacity: 0,
                              child: IconButton(
                                mouseCursor: SystemMouseCursors.click,
                                onPressed: () {},
                                icon: Icon(Icons.clear),
                              ),
                            ),
                            Text(
                              style: TextStyle(
                                fontSize: theme.mobileTexts.b2.fontSize,
                                fontWeight: FontWeight.bold,
                              ),
                              'Transfer ${widget.materialsItem.getProductUnit(unitUuid: unitUuid).name} Quantity',
                            ),
                            Builder(
                              builder: (context) {
                                if (isEditQuantityLoading == true) {
                                  return SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: theme.lightModeColor.secColor200,
                                      strokeWidth: 3,
                                    ),
                                  );
                                } else {
                                  return IconButton(
                                    mouseCursor: SystemMouseCursors.click,
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    icon: Icon(size: 20, Icons.clear),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Column(
                          spacing: 20,
                          children: [
                            Text(
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: theme.mobileTexts.b3.fontSize,
                              ),
                              widget.materialsItem.quantity == null
                                  ? 'Quantity Not Set'
                                  : 'Current Quantity in ${widget.materialsItem.getProductUnit(unitUuid: unitUuid).name}: ${formatLargeNumberDouble(widget.materialsItem.getProductUnit(unitUuid: unitUuid).getQuantityEquivDivided(index: 3, context: context))}',
                            ),
                            EditCartTextField(
                              onChanged: (value) {
                                if (value.isEmpty) {
                                  setState(() {
                                    quantityController.text = '0';
                                  });
                                } else {
                                  var eValue = double.parse(
                                    quantityController.text,
                                  );
                                  if (widget.materialsItem
                                          .getProductUnit(unitUuid: unitUuid)
                                          .getQuantityEquivMultiplied(
                                            index: 3,
                                            newQuantity: eValue,
                                          ) >
                                      (widget.materialsItem.quantity ?? 0)) {
                                    setState(() {
                                      quantityController.text = '0';
                                    });
                                  }
                                }
                              },
                              title:
                                  '${widget.materialsItem.getProductUnit(unitUuid: unitUuid).name} Quantity',
                              hint: 'Enter Quantity Amount',
                              controller: quantityController,
                              theme: theme,
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        UnitSelectionWidget(
                          storageProduct: null,
                          material: widget.materialsItem,
                          productionItem: null,
                          product: null,
                          setUnitUuid: (uuid) {
                            setState(() {
                              unitUuid = uuid;
                            });
                            if (widget.materialsItem
                                    .getProductUnit(unitUuid: unitUuid)
                                    .getQuantityEquivMultiplied(
                                      index: 3,
                                      newQuantity:
                                          double.tryParse(
                                            quantityController.text.replaceAll(
                                              ',',
                                              '',
                                            ),
                                          ) ??
                                          0,
                                    ) >
                                (widget.materialsItem.quantity ?? 0)) {
                              quantityController.text = '0';
                            }
                          },
                          theme: theme,
                          unitUuid: unitUuid,
                        ),

                        SizedBox(height: 15),
                        MainButtonP(
                          themeProvider: theme,
                          action: () {
                            var firstContext = context;
                            if (widget.materialsItem
                                        .getProductUnit(unitUuid: unitUuid)
                                        .getQuantityEquivMultiplied(
                                          index: 3,
                                          newQuantity:
                                              double.tryParse(
                                                quantityController.text
                                                    .replaceAll(',', ''),
                                              ) ??
                                              0,
                                        ) <=
                                    (widget.materialsItem.quantity ?? 0) &&
                                quantityController.text.isNotEmpty &&
                                quantityController.text != '0') {
                              if (returnShopProvider()
                                      .userShop()
                                      ?.manageDepartments ==
                                  true) {
                                if (returnShopProvider().userShops.length > 1) {
                                  transferMaterialsAction(
                                    unitUuid: unitUuid,
                                    mainMaterials: widget.materialsItem,
                                    enteredValue:
                                        (double.tryParse(
                                              quantityController.text,
                                            ) ??
                                            0),
                                    firstContext: firstContext,
                                    loadingAction: (value) {
                                      setState(() {
                                        isEditQuantityLoading = value;
                                      });
                                    },
                                  );
                                } else {
                                  selectItemInADepartmentsMaterial(
                                    unitUuid: unitUuid,
                                    thirdContext: null,
                                    secondContext: null,
                                    firstContext: firstContext,
                                    mainMaterials: widget.materialsItem,
                                    enteredValue:
                                        (double.tryParse(
                                              quantityController.text,
                                            ) ??
                                            0),
                                    loadingAction: (value) {
                                      setState(() {
                                        isEditQuantityLoading = value;
                                      });
                                    },
                                  );
                                }
                              } else {
                                bool isOnline =
                                    returnConnectivityProvider().isConnected;
                                if (!isOnline) {
                                  showDialog(
                                    context: context,
                                    builder: (errorContext) {
                                      return InfoAlert(
                                        theme: theme,
                                        message:
                                            'You Can Only Transfer Items Into Other Stores When you have Internet Connection. Please turn on your internet connection and try again.',
                                        title: 'No Internet Connection',
                                      );
                                    },
                                  );
                                } else {
                                  selectShopsMaterials(
                                    unitUuid: unitUuid,
                                    secondContext: null,
                                    firstContext: firstContext,
                                    enteredValue:
                                        (double.tryParse(
                                              quantityController.text,
                                            ) ??
                                            0),
                                    mainMaterials: widget.materialsItem,
                                    loadingAction: (value) {
                                      setState(() {
                                        isEditQuantityLoading = value;
                                      });
                                    },
                                  );
                                }
                              }
                            }
                          },
                          text: 'Proceed',
                        ),
                        SizedBox(height: 15),
                        Material(
                          color: Colors.transparent,
                          child: EditButton(
                            text: 'Cancel',
                            action: () {
                              Navigator.of(context).pop();
                            },
                            theme: theme,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        ),
      ),
      ),
    );
  }
}

void transferMaterialsAction({
  required BuildContext firstContext,
  required MaterialClass mainMaterials,
  required Function(bool value) loadingAction,
  required String? unitUuid,
  required double enteredValue,
}) {
  var theme = returnTheme(firstContext, listen: false);
  showDialog(
    context: firstContext,
    builder: (secondContext) {
      return DialogTemplate(
        theme: theme,
        message: 'Select the action you want to Perform',
        title: 'Select Action',
        action: () {},
        showBottomActionButtons: false,
        widget: Column(
          spacing: 5,
          children: [
            Visibility(
              visible:
                  returnShopProvider().userShop()?.manageDepartments == true,
              child: MainButtonTransparent(
                themeProvider: theme,
                constraints: BoxConstraints(),
                text: 'Transfer To Department (Materials)',
                action: () {
                  selectDepartmentMaterialss(
                    mainMaterials: mainMaterials,
                    firstContext: firstContext,
                    secondContext: secondContext,
                    unitUuid: unitUuid,
                    enteredValue: enteredValue,
                    loadingAction: (value) {
                      loadingAction(value);
                    },
                  );
                },
              ),
            ),
            Visibility(
              visible: returnShopProvider().userShops.length > 1,
              child: MainButtonTransparent(
                themeProvider: theme,
                constraints: BoxConstraints(),
                text: 'Transfer To Branch (Materials)',
                action: () {
                  bool isOnline = returnConnectivityProvider().isConnected;
                  if (!isOnline) {
                    showDialog(
                      context: firstContext,
                      builder: (errorContext) {
                        return InfoAlert(
                          theme: theme,
                          message:
                              'You Can Only Transfer Material Items Into Other Stores When you have Internet Connection. Please turn on your internet connection and try again.',
                          title: 'No Internet Connection',
                        );
                      },
                    );
                  } else {
                    selectShopsMaterials(
                      secondContext: secondContext,
                      firstContext: firstContext,
                      enteredValue: enteredValue,
                      unitUuid: unitUuid,
                      mainMaterials: mainMaterials,
                      loadingAction: (value) {
                        loadingAction(value);
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}

void selectDepartmentMaterialss({
  required BuildContext? secondContext,
  required BuildContext firstContext,
  required String? unitUuid,
  required MaterialClass mainMaterials,
  required Function(bool value) loadingAction,
  required double enteredValue,
}) {
  var theme = returnTheme(secondContext ?? firstContext, listen: false);
  GeneralSettingsAuthAction().manageDeparmtmentsAction(
    context: secondContext ?? firstContext,
    action: () {
      DepartmentClass? selectedDept;
      showDialog(
        context: secondContext ?? firstContext,
        builder: (thirdContext) {
          return StatefulBuilder(
            builder: (statefulContext, setState) {
              return DialogTemplate(
                theme: theme,
                message: 'Select a Department From the List Below',
                title: 'Select Department',
                action: () {
                  if (selectedDept != null) {
                    selectItemInADepartmentsMaterial(
                      secondContext: secondContext,
                      firstContext: firstContext,
                      unitUuid: unitUuid,
                      mainMaterials: mainMaterials,
                      thirdContext: thirdContext,
                      loadingAction: loadingAction,
                      department: selectedDept,
                      enteredValue: enteredValue,
                    );
                  }
                },
                widget: SizedBox(
                  height: screenWidth(statefulContext) < mobileScreen ? (screenHeight(statefulContext) * 0.45).clamp(180.0, 420.0) : (screenHeight(statefulContext) - 270),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5.0,
                        vertical: 10,
                      ),
                      child: Builder(
                        builder: (context) {
                          List<DepartmentClass> departments =
                              returnDepartmentProvider().departments
                                  .where(
                                    (dept) =>
                                        dept.uuid !=
                                        returnDepartmentProvider()
                                            .currentDepartment()
                                            ?.uuid,
                                  )
                                  .toList();
                          if (departments.isEmpty) {
                            return SizedBox(
                              height: 400,
                              child: EmptyWidgetDisplayOnly(
                                title: 'No Department Found',
                                subText:
                                    'You have not been added to any departments.',
                                theme: theme,
                                height: 30,
                                altAction: () async {
                                  await returnDepartmentProvider()
                                      .getDepartments();
                                  setState(() {});
                                },
                                altActionText: 'Refresh',
                                icon: Icons.clear,
                              ),
                            );
                          } else {
                            return Column(
                              spacing: 5,
                              children:
                                  departments
                                      .map(
                                        (dept) => Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            mouseCursor:
                                                SystemMouseCursors.click,
                                            onTap: () {
                                              setState(() {
                                                if (selectedDept?.uuid ==
                                                    dept.uuid) {
                                                  selectedDept = null;
                                                } else {
                                                  selectedDept = dept;
                                                }
                                              });
                                            },
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 9.0,
                                                    horizontal: 12,
                                                  ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
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
                                                    dept.name,
                                                  ),
                                                  Container(
                                                    padding: EdgeInsets.all(2),
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      border: Border.all(
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                    child: Container(
                                                      padding: EdgeInsets.all(
                                                        5,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color:
                                                            selectedDept?.uuid ==
                                                                    dept.uuid
                                                                ? theme
                                                                    .lightModeColor
                                                                    .prColor250
                                                                : Colors
                                                                    .transparent,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
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
                  ),
                ),
              );
            },
          );
        },
      );
    },
  );
}

void selectItemInADepartmentsMaterial({
  required BuildContext? thirdContext,
  required BuildContext? secondContext,
  required BuildContext firstContext,
  required String? unitUuid,
  required MaterialClass mainMaterials,
  required Function(bool value) loadingAction,
  DepartmentClass? department,
  required double enteredValue,
}) {
  var theme = returnTheme(
    thirdContext ?? secondContext ?? firstContext,
    listen: false,
  );
  GeneralSettingsAuthAction().manageDeparmtmentsAction(
    context: thirdContext ?? secondContext ?? firstContext,
    action: () {
      final searchController = TextEditingController();
      MaterialClass? selectedMaterial;
      showDialog(
        context: thirdContext ?? secondContext ?? firstContext,
        builder: (fourthContext) {
          return StatefulBuilder(
            builder: (statefulContext, setState) {
              return DialogTemplate(
                theme: theme,
                message: 'Select an Item From the List Below',
                title: 'Select Item',
                action: () {
                  if (selectedMaterial != null) {
                    showDialog(
                      context: fourthContext,
                      builder: (fifthContext) {
                        return ConfirmationAlert(
                          theme: theme,
                          message:
                              'You are about to perform an Material Item quantity Transfer. Please note that this action can not be reversed. Are you sure you want to proceed?',
                          title: 'Transfer Item Quantity',
                          action: () async {
                            loadingAction(true);
                            MaterialClass oldMaterial = selectedMaterial!;
                            MaterialClass newMaterial = oldMaterial.copyWith();
                            newMaterial.quantity =
                                (newMaterial.quantity ?? 0) +
                                mainMaterials
                                    .getProductUnit(unitUuid: unitUuid)
                                    .getQuantityEquivMultiplied(
                                      index: 3,
                                      newQuantity: enteredValue,
                                    );
                            MaterialsItemHistory
                            materialsItemHistory = MaterialsItemHistory(
                              event: MaterialItemHistoryEventClass.transferedIn,
                              isManaged: newMaterial.isManaged,
                              source:
                                  MaterialItemHistoryEventClass
                                      .departmentSource,
                              shopId: shopId(),
                              isIncreased: true,
                              departmentName: newMaterial.departmentName,
                              departmentUuid: newMaterial.departmentUuid,
                              desc:
                                  'Item Quantity Received From Transfer - From Material Item Name: ${mainMaterials.name}. Department Name: ${returnDepartmentProvider().currentDepartment()?.name ?? 'Department Not Set'}.',
                              title: 'Transfered In',
                              createdAt: DateTime.now(),
                              itemUuid: newMaterial.uuid,
                              itemName: newMaterial.name,
                              newValue: formatLargeNumberDouble(
                                newMaterial
                                    .getProductUnit()
                                    .getQuantityEquivDivided(
                                      index: 3,
                                      newQuantity: (newMaterial.quantity ?? 0),
                                    ),
                              ),
                              oldValue: formatLargeNumberDouble(
                                oldMaterial
                                    .getProductUnit()
                                    .getQuantityEquivDivided(
                                      index: 3,
                                      newQuantity: (oldMaterial.quantity ?? 0),
                                    ),
                              ),
                              quantityChange: enteredValue,
                              staffId: currentUser().userId,
                              staffName: currentUser().name,
                              unit:
                                  mainMaterials
                                      .getProductUnit(unitUuid: unitUuid)
                                      .name,
                              primaryUnit: newMaterial.getProductUnit().name,
                            );
                            var res = await returnMaterialsProvider()
                                .updateMaterial(
                                  isMultipleUpdate: false,
                                  material: newMaterial,
                                  isQuantityUpdate: true,
                                  includeQuantity: true,
                                  quantityChange: mainMaterials
                                      .getProductUnit(unitUuid: unitUuid)
                                      .getQuantityEquivMultiplied(
                                        index: 3,
                                        newQuantity: enteredValue,
                                      ),
                                  isIncrement: true,
                                  materialsItemHistory: materialsItemHistory,
                                );

                            MaterialClass newMaterial2 =
                                mainMaterials.copyWith();
                            newMaterial2.quantity =
                                ((newMaterial2.quantity ?? 0) -
                                    mainMaterials
                                        .getProductUnit(unitUuid: unitUuid)
                                        .getQuantityEquivMultiplied(
                                          index: 3,
                                          newQuantity: enteredValue,
                                        ));
                            MaterialsItemHistory
                            materialsItemHistory2 = MaterialsItemHistory(
                              event:
                                  MaterialItemHistoryEventClass.transferedOut,
                              isManaged: oldMaterial.isManaged,
                              source:
                                  MaterialItemHistoryEventClass
                                      .departmentSource,
                              shopId: shopId(),
                              isIncreased: false,
                              desc:
                                  'Material Item Quantity Transfered To - Item Name: ${oldMaterial.name}, Department Name: ${department?.name ?? 'Department Not Set'}.',
                              title: 'Transfered Out',
                              createdAt: DateTime.now(),
                              itemUuid: newMaterial2.uuid,
                              itemName: newMaterial2.name,
                              newValue: formatLargeNumberDouble(
                                mainMaterials
                                    .getProductUnit()
                                    .getQuantityEquivDivided(
                                      index: 3,
                                      newQuantity: (newMaterial2.quantity ?? 0),
                                    ),
                              ),
                              oldValue: formatLargeNumberDouble(
                                mainMaterials
                                    .getProductUnit()
                                    .getQuantityEquivDivided(
                                      index: 3,
                                      newQuantity:
                                          (mainMaterials.quantity ?? 0),
                                    ),
                              ),
                              quantityChange: -enteredValue,
                              staffId: currentUser().userId,
                              staffName: currentUser().name,
                              unit:
                                  mainMaterials
                                      .getProductUnit(unitUuid: unitUuid)
                                      .name,
                              primaryUnit: mainMaterials.getProductUnit().name,
                            );
                            var res2 = await returnMaterialsProvider()
                                .updateMaterial(
                                  isMultipleUpdate: false,
                                  material: newMaterial2,
                                  isQuantityUpdate: true,
                                  includeQuantity: true,
                                  quantityChange: newMaterial2
                                      .getProductUnit(unitUuid: unitUuid)
                                      .getQuantityEquivMultiplied(
                                        index: 3,
                                        newQuantity: enteredValue,
                                      ),
                                  isIncrement: false,
                                  materialsItemHistory: materialsItemHistory2,
                                );
                            if (res == null || res2 == null) {
                              loadingAction(false);
                              showDialog(
                                // ignore: use_build_context_synchronously
                                context: fifthContext,
                                builder: (errorContext) {
                                  return InfoAlert(
                                    theme: theme,
                                    message:
                                        'An error occoured while Transferring MaterialClass Quantity. Please try again.',
                                    title: 'An Error Occured',
                                  );
                                },
                              );
                            } else {
                              Navigator.of(
                                // ignore: use_build_context_synchronously
                                fifthContext,
                              ).pop();
                              // ignore: use_build_context_synchronously
                              Navigator.of(
                                // ignore: use_build_context_synchronously
                                fourthContext,
                              ).pop();
                              if (thirdContext != null) {
                                Navigator.of(
                                  // ignore: use_build_context_synchronously
                                  thirdContext,
                                ).pop();
                              }
                              if (secondContext != null) {
                                Navigator.of(
                                  // ignore: use_build_context_synchronously
                                  secondContext,
                                ).pop();
                              }
                              Navigator.of(
                                // ignore: use_build_context_synchronously
                                firstContext,
                              ).pop();
                              loadingAction(false);
                            }
                          },
                        );
                      },
                    );
                  }
                },
                widget: SizedBox(
                  height: screenWidth(statefulContext) < mobileScreen ? (screenHeight(statefulContext) * 0.45).clamp(180.0, 420.0) : (screenHeight(statefulContext) - 270),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: 400,
                                maxHeight: 40,
                              ),
                              child: GeneralTextfieldOnly(
                                onChanged: (p0) {
                                  setState(() {});
                                },
                                hint: 'Search Name',
                                controller: searchController,
                                lines: 1,
                                theme: theme,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 5),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5.0,
                              vertical: 10,
                            ),
                            child: Builder(
                              builder: (context) {
                                if (returnMaterialsProvider().materialListMain
                                    .where(
                                      (item) =>
                                          (department != null
                                              ? item.departmentUuid ==
                                                  department.uuid
                                              : true) &&
                                          item.name.toLowerCase().contains(
                                            searchController.text.toLowerCase(),
                                          ) &&
                                          item.uuid != mainMaterials.uuid,
                                    )
                                    .isEmpty) {
                                  return SizedBox(
                                    height: 400,
                                    child: EmptyWidgetDisplayOnly(
                                      title: 'No MaterialClass Found',
                                      subText:
                                          'You have not added to any item under this department.',
                                      theme: theme,
                                      height: 30,
                                      altAction: () async {
                                        await returnMaterialsProvider()
                                            .getMaterials();
                                        setState(() {});
                                      },
                                      altActionText: 'Refresh',
                                      icon: Icons.clear,
                                    ),
                                  );
                                } else {
                                  return Column(
                                    spacing: 5,
                                    children:
                                        returnMaterialsProvider()
                                            .materialListMain
                                            .where(
                                              (item) =>
                                                  (department != null
                                                      ? item.departmentUuid ==
                                                          department.uuid
                                                      : true) &&
                                                  item.name
                                                      .toLowerCase()
                                                      .contains(
                                                        searchController.text
                                                            .toLowerCase(),
                                                      ) &&
                                                  item.uuid !=
                                                      mainMaterials.uuid,
                                            )
                                            .map(
                                              (item) => Material(
                                                color: Colors.transparent,
                                                child: InkWell(
                                                  mouseCursor:
                                                      SystemMouseCursors.click,
                                                  onTap: () {
                                                    setState(() {
                                                      if (selectedMaterial
                                                              ?.uuid ==
                                                          item.uuid) {
                                                        selectedMaterial = null;
                                                      } else {
                                                        selectedMaterial = item;
                                                      }
                                                    });
                                                  },
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          vertical: 9.0,
                                                          horizontal: 10,
                                                        ),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
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
                                                          item.name,
                                                        ),
                                                        Row(
                                                          spacing: 15,
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
                                                              '${item.getProductUnit().getQuantityEquivDivided(index: 3)} ${item.getProductUnit().name}',
                                                            ),
                                                            Container(
                                                              padding:
                                                                  EdgeInsets.all(
                                                                    2,
                                                                  ),
                                                              decoration: BoxDecoration(
                                                                shape:
                                                                    BoxShape
                                                                        .circle,
                                                                border: Border.all(
                                                                  color:
                                                                      Colors
                                                                          .grey,
                                                                ),
                                                              ),
                                                              child: Container(
                                                                padding:
                                                                    EdgeInsets.all(
                                                                      5,
                                                                    ),
                                                                decoration: BoxDecoration(
                                                                  shape:
                                                                      BoxShape
                                                                          .circle,
                                                                  color:
                                                                      selectedMaterial?.uuid ==
                                                                              item.uuid
                                                                          ? theme
                                                                              .lightModeColor
                                                                              .prColor250
                                                                          : Colors
                                                                              .transparent,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
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
    },
  );
}

void selectShopsMaterials({
  required BuildContext? secondContext,
  required BuildContext firstContext,
  required MaterialClass mainMaterials,
  required String? unitUuid,
  required Function(bool value) loadingAction,
  required double enteredValue,
}) {
  var theme = returnTheme(secondContext ?? firstContext, listen: false);
  TempShopClass? selectedShop;
  showDialog(
    context: secondContext ?? firstContext,
    builder: (thirdContext) {
      return StatefulBuilder(
        builder: (statefulContext, setState) {
          return DialogTemplate(
            theme: theme,
            message: 'Select a Shop Branch From the List Below',
            title: 'Select Shop Branch',
            cancelAction: () {
              Navigator.of(secondContext ?? firstContext).pop();
            },
            action: () {
              if (selectedShop != null) {
                selectItemInAShopMaterial(
                  unitUuid: unitUuid,
                  firstContext: firstContext,
                  secondContext: secondContext,
                  thirdContext: thirdContext,
                  mainMaterials: mainMaterials,
                  loadingAction: loadingAction,
                  enteredValue: enteredValue,
                  shop: selectedShop!,
                );
              }
            },
            widget: SizedBox(
              height: screenWidth(statefulContext) < mobileScreen ? (screenHeight(statefulContext) * 0.45).clamp(180.0, 420.0) : (screenHeight(statefulContext) - 270),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5.0,
                    vertical: 10,
                  ),
                  child: Builder(
                    builder: (context) {
                      if (returnShopProvider().userShops
                          .where(
                            (shop) =>
                                shop.shopId !=
                                returnShopProvider().userShop()?.shopId,
                          )
                          .isEmpty) {
                        return SizedBox(
                          height: 400,
                          child: EmptyWidgetDisplayOnly(
                            title: 'No Shop Found',
                            subText: 'No Shop Branches Was Found.',
                            theme: theme,
                            height: 30,
                            altAction: () async {
                              await returnShopProvider().getUserShops();
                              setState(() {});
                            },
                            altActionText: 'Refresh',
                            icon: Icons.clear,
                          ),
                        );
                      } else {
                        return Column(
                          spacing: 5,
                          children:
                              returnShopProvider(context: context).userShops
                                  .where(
                                    (shop) =>
                                        shop.shopId !=
                                        returnShopProvider().userShop()?.shopId,
                                  )
                                  .map(
                                    (shop) => Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        mouseCursor: SystemMouseCursors.click,
                                        onTap: () {
                                          setState(() {
                                            if (selectedShop?.shopId ==
                                                shop.shopId) {
                                              selectedShop = null;
                                            } else {
                                              selectedShop = shop;
                                            }
                                          });
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 9.0,
                                            horizontal: 12,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                style: TextStyle(
                                                  fontSize:
                                                      theme
                                                          .mobileTexts
                                                          .b3
                                                          .fontSize,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                shop.name,
                                              ),
                                              Container(
                                                padding: EdgeInsets.all(2),
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                                child: Container(
                                                  padding: EdgeInsets.all(5),
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color:
                                                        selectedShop?.shopId ==
                                                                shop.shopId
                                                            ? theme
                                                                .lightModeColor
                                                                .prColor250
                                                            : Colors
                                                                .transparent,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
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
              ),
            ),
          );
        },
      );
    },
  );
}

void selectItemInAShopMaterial({
  required BuildContext thirdContext,
  required BuildContext? secondContext,
  required BuildContext firstContext,
  required String? unitUuid,
  required MaterialClass mainMaterials,
  required Function(bool value) loadingAction,
  required TempShopClass shop,
  required double enteredValue,
}) {
  var theme = returnTheme(thirdContext, listen: false);
  final searchController = TextEditingController();
  MaterialClass? selectedMaterial;
  late Future<List<MaterialClass>> productFuture;
  showDialog(
    context: thirdContext,
    builder: (fourthContext) {
      productFuture = returnMaterialsProvider().getMaterialsForOtherShops(
        shop.shopId!,
      );
      return StatefulBuilder(
        builder: (statefulContext, setState) {
          return DialogTemplate(
            theme: theme,
            message: 'Select an Item From the List Below',
            title: 'Select Item',
            action: () {
              if (selectedMaterial != null) {
                showDialog(
                  context: fourthContext,
                  builder: (fifthContext) {
                    return ConfirmationAlert(
                      theme: theme,
                      message:
                          'You are about to perform an materialsItem quantity Transfer. Please note that this action can not be reversed. Are you sure you want to proceed?',
                      title: 'Transfer materialsItem Quantity',
                      action: () async {
                        loadingAction(true);
                        MaterialClass oldProduct = selectedMaterial!;
                        MaterialClass newMaterial = oldProduct.copyWith();
                        newMaterial.quantity =
                            (newMaterial.quantity ?? 0) +
                            mainMaterials
                                .getProductUnit(unitUuid: unitUuid)
                                .getQuantityEquivMultiplied(
                                  index: 3,
                                  newQuantity: enteredValue,
                                );
                        MaterialsItemHistory
                        materialsItemHistory = MaterialsItemHistory(
                          event: MaterialItemHistoryEventClass.transferedIn,
                          isManaged: newMaterial.isManaged,
                          source:
                              MaterialItemHistoryEventClass.branchStoreSource,
                          desc:
                              'Item Quantity Received From Transfer - From Material Item Name: ${mainMaterials.name}. Shop Name: ${returnShopProvider().userShop()?.name}.',
                          shopId: shop.shopId!,
                          title: 'Transfered In',
                          isIncreased: true,
                          departmentName: newMaterial.departmentName,
                          departmentUuid: newMaterial.departmentUuid,
                          createdAt: DateTime.now(),
                          itemUuid: newMaterial.uuid,
                          itemName: newMaterial.name,
                          newValue: formatLargeNumberDouble(
                            newMaterial
                                .getProductUnit()
                                .getQuantityEquivDivided(
                                  index: 3,
                                  material: newMaterial,
                                  newQuantity: (newMaterial.quantity ?? 0),
                                ),
                          ),
                          oldValue: formatLargeNumberDouble(
                            oldProduct.getProductUnit().getQuantityEquivDivided(
                              index: 3,
                              material: oldProduct,
                              newQuantity: (oldProduct.quantity ?? 0),
                            ),
                          ),
                          quantityChange: enteredValue,
                          staffId: currentUser().userId,
                          staffName: currentUser().name,
                          unit:
                              mainMaterials
                                  .getProductUnit(unitUuid: unitUuid)
                                  .name,
                          primaryUnit: newMaterial.getProductUnit().name,
                        );
                        var res = await returnMaterialsProvider()
                            .updateMaterialForOtherShops(
                              material: newMaterial,
                              materialsItemHistory: materialsItemHistory,
                            );

                        MaterialClass newMaterial2 = mainMaterials.copyWith();
                        newMaterial2.quantity =
                            ((newMaterial2.quantity ?? 0) -
                                newMaterial2
                                    .getProductUnit(unitUuid: unitUuid)
                                    .getQuantityEquivMultiplied(
                                      index: 3,
                                      newQuantity: enteredValue,
                                    ));
                        MaterialsItemHistory
                        materialsItemHistory2 = MaterialsItemHistory(
                          event: MaterialItemHistoryEventClass.transferedOut,
                          isManaged: newMaterial2.isManaged,
                          source:
                              MaterialItemHistoryEventClass.branchStoreSource,
                          shopId: shopId(),
                          isIncreased: false,
                          desc:
                              'Material Item Quantity Transfered To - Item Name: ${oldProduct.name}, Shop Name: ${shop.name}.',
                          title: 'Transfered Out',
                          createdAt: DateTime.now(),
                          itemUuid: newMaterial2.uuid,
                          itemName: newMaterial2.name,
                          newValue: formatLargeNumberDouble(
                            newMaterial2
                                .getProductUnit()
                                .getQuantityEquivDivided(
                                  index: 3,
                                  newQuantity: (newMaterial2.quantity ?? 0),
                                ),
                          ),
                          oldValue: formatLargeNumberDouble(
                            mainMaterials
                                .getProductUnit()
                                .getQuantityEquivDivided(
                                  index: 3,
                                  newQuantity: (mainMaterials.quantity ?? 0),
                                ),
                          ),
                          quantityChange: -enteredValue,
                          staffId: currentUser().userId,
                          staffName: currentUser().name,
                          unit:
                              newMaterial2
                                  .getProductUnit(unitUuid: unitUuid)
                                  .name,
                          primaryUnit: mainMaterials.getProductUnit().name,
                        );
                        var res2 = await returnMaterialsProvider()
                            .updateMaterial(
                              isMultipleUpdate: false,
                              material: newMaterial2,
                              isQuantityUpdate: true,
                              includeQuantity: true,
                              quantityChange: newMaterial2
                                  .getProductUnit(unitUuid: unitUuid)
                                  .getQuantityEquivMultiplied(
                                    index: 3,
                                    newQuantity: enteredValue,
                                  ),
                              isIncrement: false,
                              materialsItemHistory: materialsItemHistory2,
                            );
                        if (res == null || res2 == null) {
                          loadingAction(false);
                          showDialog(
                            // ignore: use_build_context_synchronously
                            context: fifthContext,
                            builder: (errorContext) {
                              return InfoAlert(
                                theme: theme,
                                message:
                                    'An error occoured while Transferring Item Quantity. Please try again.',
                                title: 'An Error Occured',
                              );
                            },
                          );
                        } else {
                          Navigator.of(
                            // ignore: use_build_context_synchronously
                            fifthContext,
                          ).pop();
                          // ignore: use_build_context_synchronously
                          Navigator.of(
                            // ignore: use_build_context_synchronously
                            fourthContext,
                          ).pop();
                          Navigator.of(
                            // ignore: use_build_context_synchronously
                            thirdContext,
                          ).pop();
                          if (secondContext != null) {
                            Navigator.of(
                              // ignore: use_build_context_synchronously
                              secondContext,
                            ).pop();
                          }
                          Navigator.of(
                            // ignore: use_build_context_synchronously
                            firstContext,
                          ).pop();
                          loadingAction(false);
                        }
                      },
                    );
                  },
                );
              }
            },
            widget: SizedBox(
              height: screenWidth(statefulContext) < mobileScreen ? (screenHeight(statefulContext) * 0.45).clamp(180.0, 420.0) : (screenHeight(statefulContext) - 270),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: 400,
                            maxHeight: 40,
                          ),
                          child: GeneralTextfieldOnly(
                            onChanged: (p0) {
                              setState(() {});
                            },
                            hint: 'Search Name',
                            controller: searchController,
                            lines: 1,
                            theme: theme,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  Expanded(
                    child: FutureBuilder(
                      future: productFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: returnCompProvider(
                              context,
                            ).showLoader(message: 'Loading'),
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                            child: SizedBox(
                              height: 400,
                              child: EmptyWidgetDisplayOnly(
                                title: 'An Error Occoured',
                                subText:
                                    'An Error Occoured while trying to get items',
                                theme: theme,
                                height: 30,
                                icon: Icons.clear,
                              ),
                            ),
                          );
                        } else {
                          List<MaterialClass> products =
                              (snapshot.data ?? [])
                                  .where(
                                    (item) =>
                                        item.name.toLowerCase().contains(
                                          searchController.text.toLowerCase(),
                                        ) &&
                                        item.uuid != mainMaterials.uuid,
                                  )
                                  .toList();
                          return SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5.0,
                                vertical: 10,
                              ),
                              child: Builder(
                                builder: (context) {
                                  if (products.isEmpty) {
                                    return SizedBox(
                                      height: 400,
                                      child: EmptyWidgetDisplayOnly(
                                        title: 'No Item Found',
                                        subText:
                                            'You have not added to any Item under this Shop.',
                                        theme: theme,
                                        height: 30,
                                        icon: Icons.clear,
                                      ),
                                    );
                                  } else {
                                    return Column(
                                      spacing: 5,
                                      children:
                                          products
                                              .map(
                                                (item) => Material(
                                                  color: Colors.transparent,
                                                  child: InkWell(
                                                    mouseCursor:
                                                        SystemMouseCursors
                                                            .click,
                                                    onTap: () {
                                                      setState(() {
                                                        if (selectedMaterial
                                                                ?.uuid ==
                                                            item.uuid) {
                                                          selectedMaterial =
                                                              null;
                                                        } else {
                                                          selectedMaterial =
                                                              item;
                                                        }
                                                      });
                                                    },
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            vertical: 9.0,
                                                            horizontal: 10,
                                                          ),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
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
                                                            item.name,
                                                          ),
                                                          Row(
                                                            spacing: 15,
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
                                                                '${item.quantity ?? 0}',
                                                              ),
                                                              Container(
                                                                padding:
                                                                    EdgeInsets.all(
                                                                      2,
                                                                    ),
                                                                decoration: BoxDecoration(
                                                                  shape:
                                                                      BoxShape
                                                                          .circle,
                                                                  border: Border.all(
                                                                    color:
                                                                        Colors
                                                                            .grey,
                                                                  ),
                                                                ),
                                                                child: Container(
                                                                  padding:
                                                                      EdgeInsets.all(
                                                                        5,
                                                                      ),
                                                                  decoration: BoxDecoration(
                                                                    shape:
                                                                        BoxShape
                                                                            .circle,
                                                                    color:
                                                                        selectedMaterial?.uuid ==
                                                                                item.uuid
                                                                            ? theme.lightModeColor.prColor250
                                                                            : Colors.transparent,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
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
                        }
                      },
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
