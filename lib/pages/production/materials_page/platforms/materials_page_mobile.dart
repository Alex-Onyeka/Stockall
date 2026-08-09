import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_production_folder/temp_material_class/material_class.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/components/buttons/floating_action_butto.dart';
import 'package:stockall/components/major/empty_widget_display.dart';
import 'package:stockall/components/major/empty_widget_display_only.dart';
import 'package:stockall/components/text_fields/text_field_barcode.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/scan_barcode.dart';
import 'package:stockall/constants/subscription/items_auth.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/production/materials_page/add_material/add_material.dart';
import 'package:stockall/pages/production/materials_page/components/materials_tile_main.dart';
import 'package:stockall/pages/production/materials_page/materials_details/materials_details_page.dart';
import 'package:stockall/pages/production/materials_page/materials_item_history_page/materials_item_history_page.dart';
import 'package:stockall/pages/production/materials_page/platforms/materials_page_desktop.dart';
import 'package:stockall/pages/products/compnents/product_filter_button.dart';
import 'package:stockall/pages/products/compnents/product_filter_button_category.dart';

class MaterialsPageMobile extends StatefulWidget {
  const MaterialsPageMobile({super.key});

  @override
  State<MaterialsPageMobile> createState() =>
      _MaterialsPageMobileState();
}

class _MaterialsPageMobileState
    extends State<MaterialsPageMobile> {
  int currentSelect = 0;
  void changeSelected(int number) {
    currentSelect = number;
  }

  void clearState() {
    setState(() {
      searchController.clear();
    });
  }

  bool isFocus = false;
  TextEditingController searchController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    returnData().toggleFloatingAction(context);
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   if (returnCategoriesProvider()
    //       .categories()
    //       .isNotEmpty) {
    //     setState(() {
    //       categoryUuid =
    //           returnCategoriesProvider()
    //               .categories()
    //               .first
    //               .uuid;
    //     });
    //   }
    // });
  }

  int filterIndex = 0;
  String? categoryUuid;
  bool isDeleteLoading = false;

  Future<void> getMaterialList() async {
    await returnMaterialsProvider().getMaterials();
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      returnMaterialsProvider().toggleIsSelectMaterial(
        false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    var materials =
        searchController.text.isNotEmpty
            ? returnMaterialsProvider(context: context)
                .materialList()
                .where(
                  (pr) =>
                      pr.name.toLowerCase().contains(
                        searchController.text.toLowerCase(),
                      ) ||
                      pr.barcode?.toLowerCase() ==
                          searchController.text
                              .toLowerCase(),
                )
                .toList()
            : returnMaterialsProvider(
              context: context,
            ).materialList();
    List<MaterialClass> filterMaterials() {
      switch (currentSelect) {
        case 1:
          return materials
              .where((p) => p.quantity != 0)
              .toList();
        case 2:
          return materials
              .where(
                (p) =>
                    p.quantity != null &&
                    p.quantity! <= p.lowQtty! &&
                    p.quantity != 0,
              )
              .toList();
        case 3:
          return materials
              .where((p) => p.quantity == 0)
              .toList();
        case 4:
          return materials
              .where((p) => p.quantity == null)
              .toList();
        case 5:
          return materials
              .where((p) => p.departmentUuid == null)
              .toList();
        case 0:
        default:
          return materials;
      }
    }

    List<MaterialClass> categoryFilterMaterials() {
      if (categoryUuid != null) {
        return materials
            .where(
              (pr) =>
                  pr.categories?.contains(categoryUuid) ==
                  true,
            )
            .toList();
      }
      return materials;
    }

    return Stack(
      children: [
        Scaffold(
          appBar: appBar(
            context: context,
            title: 'All Materials',
            widget: PopupMenuButton(
              offset: Offset(-20, 30),
              color: Colors.white,
              itemBuilder: (context) {
                return [
                  PopupMenuItem(
                    onTap: () {
                      setState(() {
                        filterIndex = 0;
                      });
                      returnMaterialsProvider()
                          .toggleIsSelectMaterial(false);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10.0,
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
                              fontWeight:
                                  filterIndex == 0
                                      ? FontWeight.bold
                                      : null,
                            ),
                            'Inventory Record',
                          ),
                          Visibility(
                            visible:
                                filterIndex == 0 &&
                                !returnMaterialsProvider()
                                    .isSelectMaterials,
                            child: Icon(
                              size: 17,
                              color: Colors.grey.shade700,
                              Icons.check,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  PopupMenuItem(
                    onTap: () {
                      setState(() {
                        filterIndex = 1;
                      });
                      returnMaterialsProvider()
                          .toggleIsSelectMaterial(false);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10.0,
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
                              fontWeight:
                                  filterIndex == 1
                                      ? FontWeight.bold
                                      : null,
                            ),
                            'Categories',
                          ),
                          Visibility(
                            visible: filterIndex == 1,
                            child: Icon(
                              size: 17,
                              color: Colors.grey.shade700,
                              Icons.check,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  PopupMenuItem(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return MaterialsItemHistoryPage(
                              fromMaterialsItemDetails:
                                  false,
                            );
                          },
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10.0,
                      ),
                      child: Text(
                        style: TextStyle(
                          fontSize:
                              theme.mobileTexts.b3.fontSize,
                        ),
                        'View History',
                      ),
                    ),
                  ),
                  PopupMenuItem(
                    onTap: () {
                      if (returnMaterialsProvider()
                          .isSelectMaterials) {
                        returnMaterialsProvider()
                            .toggleIsSelectMaterial(false);
                      } else {
                        returnMaterialsProvider()
                            .toggleIsSelectMaterial(true);
                      }
                      setState(() {
                        filterIndex = 0;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10.0,
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
                                  filterIndex == 2
                                      ? FontWeight.bold
                                      : null,
                            ),
                            returnMaterialsProvider()
                                    .isSelectMaterials
                                ? 'Cancel'
                                : 'Select Materials',
                          ),
                          Visibility(
                            visible:
                                returnMaterialsProvider()
                                    .isSelectMaterials,
                            child: Icon(
                              size: 17,
                              color: Colors.grey.shade700,
                              Icons.clear,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ];
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: Container(
                  padding: EdgeInsets.all(5),
                  child: Row(
                    spacing: 4,
                    children: [
                      Text(
                        style: TextStyle(
                          fontSize:
                              theme.mobileTexts.b3.fontSize,
                          fontWeight: FontWeight.bold,
                        ),
                        filterIndex == 0
                            ? 'Inventory'
                            : 'Categories',
                      ),
                      Icon(Icons.more_vert_rounded),
                    ],
                  ),
                ),
              ),
            ),
          ),
          floatingActionButton: Visibility(
            visible: authorization(
              authorized: Authorizations().addMaterials,
            ),
            child: FloatingActionButtonMain(
              action: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return AddMaterial();
                    },
                  ),
                ).then((_) {
                  setState(() {
                    // getMaterialList(context);
                  });
                });
              },
              color: theme.lightModeColor.secColor100,
              text: 'Add Materials',
              theme: theme,
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.endFloat,
          body: Stack(
            children: [
              Column(
                children: [
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30.0,
                    ),
                    child: TextFieldBarcode(
                      clearTextField: () {
                        setState(() {});
                      },
                      searchController: searchController,
                      onChanged: (value) {
                        setState(() {
                          if (materials
                              .where(
                                (pr) =>
                                    pr.barcode
                                        ?.toLowerCase() ==
                                    searchController.text
                                        .toLowerCase(),
                              )
                              .isNotEmpty) {
                            ItemsAuthAction()
                                .useOfBArcodeAction(
                                  context: context,
                                  action: () {
                                    setState(() {});
                                  },
                                  failAction: () {
                                    setState(() {
                                      searchController
                                          .clear();
                                    });
                                  },
                                );
                          } else {
                            setState(() {});
                          }
                        });
                      },

                      onPressedScan: () async {
                        ItemsAuthAction()
                            .useOfBArcodeAction(
                              context: context,
                              action: () async {
                                String? result =
                                    await scanCode(
                                      context,
                                      'Scan Failed',
                                    );
                                setState(() {
                                  if (result != null) {
                                    searchController.text =
                                        result;
                                  } else {
                                    return;
                                  }
                                });
                              },
                            );
                      },
                    ),
                  ),
                  Expanded(
                    child: SizedBox(
                      child: Builder(
                        builder: (context) {
                          if (materials.isEmpty) {
                            return Center(
                              child: SingleChildScrollView(
                                child: RefreshIndicator(
                                  onRefresh:
                                      getMaterialList,
                                  color:
                                      theme
                                          .lightModeColor
                                          .prColor300,
                                  backgroundColor:
                                      Colors.white,
                                  displacement: 10,
                                  child: EmptyWidgetDisplay(
                                    buttonText: 'Add Item',
                                    subText:
                                        'Click on the button below to start adding Materials to your store.',
                                    title:
                                        'You have not Item Under this Category',
                                    icon: Icons.clear,
                                    height: 35,
                                    action: () {
                                      if (authorization(
                                        authorized:
                                            Authorizations()
                                                .addMaterials,
                                      )) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (
                                              context,
                                            ) {
                                              return AddMaterial();
                                            },
                                          ),
                                        ).then((_) {
                                          if (context
                                              .mounted) {}
                                        });
                                      }
                                    },
                                    theme: theme,
                                    altAction: () async {
                                      await returnMaterialsProvider()
                                          .getMaterials();
                                    },
                                    altActionText:
                                        'Refresh',
                                    altIcon: Icons.refresh,
                                  ),
                                ),
                              ),
                            );
                          } else {
                            return Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(
                                    10.0,
                                    15,
                                    10,
                                    15,
                                  ),
                              child: Column(
                                children: [
                                  Padding(
                                    padding:
                                        const EdgeInsets.symmetric(
                                          horizontal: 10.0,
                                        ),
                                    child: SizedBox(
                                      width:
                                          double.infinity,
                                      // height: 40,
                                      child: Builder(
                                        builder: (context) {
                                          if (returnMaterialsProvider(
                                            context:
                                                context,
                                          ).isSelectMaterials) {
                                            return SizedBox(
                                              width:
                                                  double
                                                      .infinity,
                                              child: Center(
                                                child: SingleChildScrollView(
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.center,
                                                    children: [
                                                      MaterialSelectionActionButton(
                                                        title:
                                                            'Delete',
                                                        action: () {
                                                          if (returnMaterialsProvider().selectedMaterials.isNotEmpty) {
                                                            showDialog(
                                                              context:
                                                                  context,
                                                              builder: (
                                                                confirmContext,
                                                              ) {
                                                                return ConfirmationAlert(
                                                                  theme:
                                                                      theme,
                                                                  message:
                                                                      'You are about to delete all the selected materials. Please not that this action can not be reversed. Are you sure you want to proceed?',
                                                                  title:
                                                                      'Delete Selected Materials',
                                                                  action: () async {
                                                                    Navigator.of(
                                                                      confirmContext,
                                                                    ).pop();
                                                                    setState(
                                                                      () {
                                                                        isDeleteLoading =
                                                                            true;
                                                                      },
                                                                    );
                                                                    var res =
                                                                        await returnMaterialsProvider().deleteSelectedMaterials();
                                                                    if (res ==
                                                                        0) {
                                                                      setState(
                                                                        () {
                                                                          isDeleteLoading =
                                                                              false;
                                                                        },
                                                                      );
                                                                      showDialog(
                                                                        // ignore: use_build_context_synchronously
                                                                        context:
                                                                            context,
                                                                        builder: (
                                                                          context,
                                                                        ) {
                                                                          return InfoAlert(
                                                                            theme:
                                                                                theme,
                                                                            message:
                                                                                'An error occoured while deleting selected materials. Please try again.',
                                                                            title:
                                                                                'An Error Occured',
                                                                          );
                                                                        },
                                                                      );
                                                                    } else {
                                                                      setState(
                                                                        () {
                                                                          isDeleteLoading =
                                                                              false;
                                                                        },
                                                                      );
                                                                      // returnMaterialsProvider().toggleIsSelectMaterial(
                                                                      //   false,
                                                                      // );
                                                                    }
                                                                  },
                                                                );
                                                              },
                                                            );
                                                          }
                                                        },
                                                        icon:
                                                            Icons.delete_outline_rounded,
                                                        color:
                                                            Colors.red.shade600,
                                                      ),
                                                      MaterialSelectionActionButton(
                                                        title:
                                                            'Duplicate',
                                                        action: () {
                                                          duplicateMaterialsAction(
                                                            context:
                                                                context,
                                                            loadingAction: (
                                                              value,
                                                            ) {
                                                              setState(
                                                                () {
                                                                  isDeleteLoading =
                                                                      value;
                                                                },
                                                              );
                                                            },
                                                          );
                                                        },
                                                        icon:
                                                            Icons.control_point_duplicate_rounded,
                                                        color:
                                                            Colors.grey,
                                                      ),
                                                      MaterialSelectionActionButton(
                                                        title:
                                                            'Cancel',
                                                        action: () {
                                                          returnMaterialsProvider().toggleIsSelectMaterial(
                                                            false,
                                                          );
                                                          setState(
                                                            () {
                                                              filterIndex =
                                                                  0;
                                                            },
                                                          );
                                                        },
                                                        icon:
                                                            Icons.clear,
                                                        color:
                                                            Colors.grey,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          } else {
                                            if (filterIndex ==
                                                0) {
                                              return SingleChildScrollView(
                                                clipBehavior:
                                                    Clip.hardEdge,
                                                scrollDirection:
                                                    Axis.horizontal,
                                                child: Row(
                                                  spacing:
                                                      5,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .center,
                                                  children: [
                                                    ProductsFilterButton(
                                                      length:
                                                          filterMaterials().length,
                                                      action: () {
                                                        setState(() {
                                                          changeSelected(
                                                            0,
                                                          );
                                                        });
                                                      },
                                                      currentSelected:
                                                          currentSelect,
                                                      number:
                                                          0,
                                                      title:
                                                          'All Materials',
                                                      theme:
                                                          theme,
                                                    ),
                                                    ProductsFilterButton(
                                                      length:
                                                          filterMaterials().length,
                                                      action: () {
                                                        setState(() {
                                                          changeSelected(
                                                            1,
                                                          );
                                                        });
                                                      },
                                                      currentSelected:
                                                          currentSelect,
                                                      number:
                                                          1,
                                                      title:
                                                          'In Stock',
                                                      theme:
                                                          theme,
                                                    ),
                                                    ProductsFilterButton(
                                                      length:
                                                          filterMaterials().length,
                                                      action: () {
                                                        setState(() {
                                                          changeSelected(
                                                            2,
                                                          );
                                                        });
                                                      },
                                                      currentSelected:
                                                          currentSelect,
                                                      number:
                                                          2,
                                                      title:
                                                          'Low Stock',
                                                      theme:
                                                          theme,
                                                    ),
                                                    ProductsFilterButton(
                                                      length:
                                                          filterMaterials().length,
                                                      currentSelected:
                                                          currentSelect,
                                                      action: () {
                                                        setState(() {
                                                          changeSelected(
                                                            3,
                                                          );
                                                        });
                                                      },
                                                      number:
                                                          3,
                                                      title:
                                                          'Out of Stock',
                                                      theme:
                                                          theme,
                                                    ),
                                                    ProductsFilterButton(
                                                      length:
                                                          filterMaterials().length,
                                                      currentSelected:
                                                          currentSelect,
                                                      action: () {
                                                        setState(() {
                                                          changeSelected(
                                                            4,
                                                          );
                                                        });
                                                      },
                                                      number:
                                                          4,
                                                      title:
                                                          'UnManaged',
                                                      theme:
                                                          theme,
                                                    ),
                                                    Visibility(
                                                      visible:
                                                          returnShopProvider().userShop()?.manageDepartments ==
                                                          true,
                                                      child: ProductsFilterButton(
                                                        length:
                                                            filterMaterials().length,
                                                        currentSelected:
                                                            currentSelect,
                                                        action: () {
                                                          setState(
                                                            () {
                                                              changeSelected(
                                                                5,
                                                              );
                                                            },
                                                          );
                                                        },
                                                        number:
                                                            5,
                                                        title:
                                                            'No Department',
                                                        theme:
                                                            theme,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            } else {
                                              return Center(
                                                child: SingleChildScrollView(
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  child: Row(
                                                    spacing:
                                                        6,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.center,
                                                    children:
                                                        returnCategoriesProvider()
                                                            .categories()
                                                            .map(
                                                              (
                                                                cat,
                                                              ) => ProductFilterButtonCategory(
                                                                theme:
                                                                    theme,
                                                                action: () {
                                                                  setState(
                                                                    () {
                                                                      categoryUuid =
                                                                          cat.uuid;
                                                                    },
                                                                  );
                                                                },
                                                                currentSelected:
                                                                    categoryUuid ??
                                                                    '',
                                                                title:
                                                                    cat.name,
                                                                uuid:
                                                                    cat.uuid,
                                                              ),
                                                            )
                                                            .toList(),
                                                  ),
                                                ),
                                              );
                                            }
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Expanded(
                                    child: Builder(
                                      builder: (context) {
                                        if (filterIndex ==
                                            0) {
                                          if (filterMaterials()
                                              .isNotEmpty) {
                                            return RefreshIndicator(
                                              onRefresh:
                                                  getMaterialList,
                                              color:
                                                  theme
                                                      .lightModeColor
                                                      .prColor300,
                                              backgroundColor:
                                                  Colors
                                                      .white,
                                              displacement:
                                                  10,
                                              child: ListView.builder(
                                                itemCount:
                                                    filterMaterials()
                                                        .length,
                                                itemBuilder: (
                                                  context,
                                                  index,
                                                ) {
                                                  List<
                                                    MaterialClass
                                                  >
                                                  materials =
                                                      filterMaterials();

                                                  MaterialClass
                                                  material =
                                                      materials[index];

                                                  return MaterialsTileMain(
                                                    isSelectMaterial:
                                                        returnMaterialsProvider(
                                                          context:
                                                              context,
                                                        ).isSelectMaterials,
                                                    uuidList:
                                                        returnMaterialsProvider(
                                                              context:
                                                                  context,
                                                            ).selectedMaterials
                                                            .map(
                                                              (
                                                                pr,
                                                              ) =>
                                                                  pr.uuid!,
                                                            )
                                                            .toList(),
                                                    action: () {
                                                      if (returnMaterialsProvider()
                                                          .isSelectMaterials) {
                                                        returnMaterialsProvider().selectMaterial(
                                                          material,
                                                        );
                                                      } else {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (
                                                              context,
                                                            ) {
                                                              return MaterialsDetailsPage(
                                                                materialUuid:
                                                                    material.uuid!,
                                                              );
                                                            },
                                                          ),
                                                        ).then((
                                                          _,
                                                        ) {
                                                          if (context.mounted) {
                                                            setState(
                                                              () {},
                                                            );
                                                          }
                                                        });
                                                      }
                                                    },
                                                    longPress: () {
                                                      returnMaterialsProvider().toggleIsSelectMaterial(
                                                        true,
                                                      );
                                                      setState(() {
                                                        filterIndex =
                                                            0;
                                                      });
                                                      returnMaterialsProvider().selectMaterial(
                                                        material,
                                                      );
                                                    },
                                                    theme:
                                                        theme,
                                                    material:
                                                        material,
                                                  );
                                                },
                                              ),
                                            );
                                          } else {
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.only(
                                                    bottom:
                                                        30.0,
                                                  ),
                                              child: EmptyWidgetDisplayOnly(
                                                title:
                                                    'Empty List',
                                                subText:
                                                    'You Don\'t have any material under this category',

                                                icon:
                                                    Icons
                                                        .dangerous_outlined,
                                                theme:
                                                    theme,
                                                height: 40,
                                              ),
                                            );
                                          }
                                        } else {
                                          if (categoryFilterMaterials()
                                              .isNotEmpty) {
                                            return RefreshIndicator(
                                              onRefresh:
                                                  getMaterialList,
                                              color:
                                                  theme
                                                      .lightModeColor
                                                      .prColor300,
                                              backgroundColor:
                                                  Colors
                                                      .white,
                                              displacement:
                                                  10,
                                              child: ListView.builder(
                                                itemCount:
                                                    categoryFilterMaterials()
                                                        .length,
                                                itemBuilder: (
                                                  context,
                                                  index,
                                                ) {
                                                  List<
                                                    MaterialClass
                                                  >
                                                  materials =
                                                      categoryFilterMaterials();

                                                  MaterialClass
                                                  material =
                                                      materials[index];

                                                  return MaterialsTileMain(
                                                    isSelectMaterial:
                                                        returnMaterialsProvider(
                                                          context:
                                                              context,
                                                        ).isSelectMaterials,
                                                    uuidList:
                                                        returnMaterialsProvider(
                                                              context:
                                                                  context,
                                                            ).selectedMaterials
                                                            .map(
                                                              (
                                                                pr,
                                                              ) =>
                                                                  pr.uuid!,
                                                            )
                                                            .toList(),
                                                    action: () {
                                                      if (returnMaterialsProvider()
                                                          .isSelectMaterials) {
                                                        returnMaterialsProvider().selectMaterial(
                                                          material,
                                                        );
                                                      } else {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (
                                                              context,
                                                            ) {
                                                              return MaterialsDetailsPage(
                                                                materialUuid:
                                                                    material.uuid!,
                                                              );
                                                            },
                                                          ),
                                                        ).then((
                                                          _,
                                                        ) {
                                                          if (context.mounted) {
                                                            setState(
                                                              () {},
                                                            );
                                                          }
                                                        });
                                                      }
                                                    },
                                                    longPress: () {
                                                      returnMaterialsProvider().toggleIsSelectMaterial(
                                                        true,
                                                      );
                                                      setState(() {
                                                        filterIndex =
                                                            0;
                                                      });
                                                      returnMaterialsProvider().selectMaterial(
                                                        material,
                                                      );
                                                    },
                                                    theme:
                                                        theme,
                                                    material:
                                                        material,
                                                  );
                                                },
                                              ),
                                            );
                                          } else {
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.only(
                                                    bottom:
                                                        30.0,
                                                  ),
                                              child: EmptyWidgetDisplayOnly(
                                                title:
                                                    'Empty List',
                                                subText:
                                                    'You Don\'t have any material under this category',

                                                icon:
                                                    Icons
                                                        .dangerous_outlined,
                                                theme:
                                                    theme,
                                                height: 40,
                                              ),
                                            );
                                          }
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
                ],
              ),
            ],
          ),
        ),
        Visibility(
          visible: isDeleteLoading,
          child: returnCompProvider(
            context,
          ).showLoader(message: 'Loading'),
        ),
      ],
    );
  }
}
