import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_departments_class/department_class.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/classes/temp_shop/temp_shop_class.dart';
import 'package:stockall/components/alert_dialogues/dialog_template.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/components/major/empty_widget_display_only.dart';
import 'package:stockall/components/text_fields/general_textfield_only.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/providers/theme_provider.dart';

// ============================================================================
// MODEL FOR LINKED PRODUCT DISPLAY
// ============================================================================
class LinkedProductInfo {
  final TempProductClass product;
  final TempShopClass shop;

  LinkedProductInfo({
    required this.product,
    required this.shop,
  });
}

class LinkedDepartmentProductInfo {
  final TempProductClass product;
  final DepartmentClass department;

  LinkedDepartmentProductInfo({
    required this.product,
    required this.department,
  });
}

// ============================================================================
// 1. BRANCH PRODUCT LINK WIDGET
// ============================================================================
class BranchProductLinkWidget extends StatefulWidget {
  final TempProductClass? currentProduct;
  final ThemeProvider theme;
  final Function(
    List<LinkedProductInfo> stagedBranches,
    List<LinkedProductInfo> removedBranches,
    bool isUnlinked,
  )
  onBranchesChanged;

  const BranchProductLinkWidget({
    super.key,
    this.currentProduct,
    required this.theme,
    required this.onBranchesChanged,
  });

  @override
  State<BranchProductLinkWidget> createState() =>
      _BranchProductLinkWidgetState();
}

class _BranchProductLinkWidgetState
    extends State<BranchProductLinkWidget> {
  List<LinkedProductInfo> _stagedBranches = [];
  final List<LinkedProductInfo> _removedBranches = [];
  bool _isUnlinked = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _resolveExistingLinks();
  }

  Future<void> _resolveExistingLinks() async {
    final prod = widget.currentProduct;
    if (prod == null) return;

    final clusterId = prod.globalProductId;
    if (clusterId == null || clusterId.trim().isEmpty) {
      return;
    }

    final otherShops =
        returnShopProvider().userShops
            .where((s) => s.shopId != shopId())
            .toList();
    if (otherShops.isEmpty) return;

    if (!returnConnectivityProvider().isConnected) return;

    setState(() => _isLoading = true);
    final found = <LinkedProductInfo>[];

    for (final s in otherShops) {
      if (s.shopId == null) continue;
      try {
        final products = await returnData()
            .getProductsForOtherShops(s.shopId!);
        for (final p in products) {
          if (p.globalProductId != null &&
              p.globalProductId == clusterId &&
              p.uuid != prod.uuid) {
            found.add(
              LinkedProductInfo(product: p, shop: s),
            );
            break;
          }
        }
      } catch (_) {}
    }

    if (mounted) {
      setState(() {
        _stagedBranches = List.from(found);
        _isLoading = false;
      });
    }
  }

  void _openBranchPicker() {
    final otherShops =
        returnShopProvider().userShops
            .where((s) => s.shopId != shopId())
            .toList();

    if (otherShops.isEmpty) {
      showDialog(
        context: context,
        builder:
            (_) => InfoAlert(
              theme: widget.theme,
              title: 'No Other Branches',
              message:
                  'You have only one store branch configured.',
            ),
      );
      return;
    }

    if (!returnConnectivityProvider().isConnected) {
      showDialog(
        context: context,
        builder:
            (_) => InfoAlert(
              theme: widget.theme,
              title: 'No Internet Connection',
              message:
                  'An active internet connection is required to fetch products from other branches.',
            ),
      );
      return;
    }

    TempShopClass? chosenShop;
    showDialog(
      context: context,
      builder: (shopDialogCtx) {
        return StatefulBuilder(
          builder: (stateCtx, setShopState) {
            return DialogTemplate(
              theme: widget.theme,
              title: 'Select Destination Branch',
              message:
                  'Choose the store branch to link with this product family.',
              action: () {
                if (chosenShop != null) {
                  Navigator.of(shopDialogCtx).pop();
                  _openProductPickerForShop(chosenShop!);
                }
              },
              actionButtonText: 'Next',
              widget: SizedBox(
                width: 500,
                height: (screenHeight(context) * 0.45)
                    .clamp(200.0, 420.0),
                child: SingleChildScrollView(
                  child: Column(
                    children:
                        otherShops.map((s) {
                          final isSelected =
                              chosenShop?.shopId ==
                              s.shopId;
                          final isAlreadyConnected =
                              _stagedBranches.any(
                                (c) =>
                                    c.shop.shopId ==
                                    s.shopId,
                              );

                          return ListTile(
                            title: Text(
                              s.name,
                              style: TextStyle(
                                fontWeight:
                                    isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                fontSize:
                                    widget
                                        .theme
                                        .mobileTexts
                                        .b3
                                        .fontSize,
                              ),
                            ),
                            subtitle:
                                isAlreadyConnected
                                    ? Text(
                                      'Already connected to family',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color:
                                            Colors
                                                .green
                                                .shade700,
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    )
                                    : null,
                            trailing: Icon(
                              isSelected
                                  ? Icons
                                      .radio_button_checked
                                  : Icons.radio_button_off,
                              color:
                                  isSelected
                                      ? widget
                                          .theme
                                          .lightModeColor
                                          .prColor250
                                      : Colors.grey,
                            ),
                            mouseCursor:
                                SystemMouseCursors.click,
                            onTap: () {
                              setShopState(() {
                                chosenShop =
                                    isSelected ? null : s;
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

  void _openProductPickerForShop(TempShopClass shop) {
    final searchCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (productDialogCtx) {
        return FutureBuilder<List<TempProductClass>>(
          future: returnData().getProductsForOtherShops(
            shop.shopId!,
          ),
          builder: (ctx, snapshot) {
            if (snapshot.connectionState ==
                ConnectionState.waiting) {
              return DialogTemplate(
                theme: widget.theme,
                title: 'Loading Products',
                message:
                    'Fetching products from ${shop.name}...',
                action: () {},
                showBottomActionButtons: false,
                widget: const SizedBox(
                  width: 500,
                  height: 180,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              );
            }

            final products = snapshot.data ?? [];

            return StatefulBuilder(
              builder: (stateCtx, setListState) {
                final query =
                    searchCtrl.text.toLowerCase().trim();
                final filtered =
                    products.where((p) {
                      if (query.isEmpty) return true;
                      return p.name.toLowerCase().contains(
                            query,
                          ) ||
                          (p.barcode != null &&
                              p.barcode!
                                  .toLowerCase()
                                  .contains(query));
                    }).toList();

                return DialogTemplate(
                  theme: widget.theme,
                  title: 'Select Product in ${shop.name}',
                  message:
                      'Choose the matching counterpart product to join this product family.',
                  action: () {},
                  showBottomActionButtons: false,
                  widget: SizedBox(
                    width: 500,
                    height: (screenHeight(context) * 0.55)
                        .clamp(280.0, 500.0),
                    child: Column(
                      children: [
                        GeneralTextfieldOnly(
                          hint:
                              'Search product name or barcode...',
                          controller: searchCtrl,
                          lines: 1,
                          theme: widget.theme,
                          onChanged:
                              (_) => setListState(() {}),
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child:
                              filtered.isEmpty
                                  ? EmptyWidgetDisplayOnly(
                                    title:
                                        'No Products Found',
                                    subText:
                                        'No matching products in ${shop.name}.',
                                    theme: widget.theme,
                                    height: 25,
                                    icon: Icons.search_off,
                                  )
                                  : SingleChildScrollView(
                                    child: Column(
                                      children:
                                          filtered.map((p) {
                                            final isSelected =
                                                _stagedBranches.any(
                                                  (b) =>
                                                      b.product.uuid ==
                                                      p.uuid,
                                                );

                                            return ListTile(
                                              dense: true,
                                              title: Text(
                                                p.name,
                                                style: TextStyle(
                                                  fontWeight:
                                                      isSelected
                                                          ? FontWeight.bold
                                                          : FontWeight.normal,
                                                  fontSize:
                                                      widget
                                                          .theme
                                                          .mobileTexts
                                                          .b3
                                                          .fontSize,
                                                ),
                                              ),
                                              subtitle: Text(
                                                'Available: ${p.getActualQuantity() ?? 0} ${p.getProductUnit().name}',
                                                style: const TextStyle(
                                                  fontSize:
                                                      11,
                                                ),
                                              ),
                                              trailing:
                                                  isSelected
                                                      ? Icon(
                                                        Icons.check_circle,
                                                        color:
                                                            widget.theme.lightModeColor.prColor250,
                                                      )
                                                      : const Icon(
                                                        Icons.chevron_right,
                                                        color:
                                                            Colors.grey,
                                                      ),
                                              mouseCursor:
                                                  SystemMouseCursors
                                                      .click,
                                              onTap: () {
                                                Navigator.of(
                                                  productDialogCtx,
                                                ).pop();
                                                setState(() {
                                                  _stagedBranches
                                                      .removeWhere(
                                                        (b) =>
                                                            b.shop.shopId ==
                                                            shop.shopId,
                                                      );
                                                  _stagedBranches.add(
                                                    LinkedProductInfo(
                                                      product: p,
                                                      shop: shop,
                                                    ),
                                                  );
                                                  _removedBranches
                                                      .removeWhere(
                                                        (b) =>
                                                            b.shop.shopId ==
                                                            shop.shopId,
                                                      );
                                                  _isUnlinked = false;
                                                });
                                                widget.onBranchesChanged(
                                                  _stagedBranches,
                                                  _removedBranches,
                                                  false,
                                                );
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
      },
    );
  }

  void _removeBranch(LinkedProductInfo info) {
    setState(() {
      _stagedBranches.removeWhere(
        (b) => b.shop.shopId == info.shop.shopId,
      );
      _removedBranches.add(info);
      if (_stagedBranches.isEmpty) {
        _isUnlinked = true;
      }
    });
    widget.onBranchesChanged(_stagedBranches, _removedBranches, _isUnlinked);
  }

  void _unlink() {
    setState(() {
      _removedBranches.addAll(_stagedBranches);
      _stagedBranches.clear();
      _isUnlinked = true;
    });
    widget.onBranchesChanged([], _removedBranches, true);
  }

  @override
  Widget build(BuildContext context) {
    if (returnShopProvider().userShops.length <= 1) {
      return const SizedBox.shrink();
    }

    final effectiveBranches = _stagedBranches;
    final hasLinks = effectiveBranches.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color:
              hasLinks
                  ? widget.theme.lightModeColor.prColor250
                      .withValues(alpha: 0.3)
                  : Colors.grey.shade300,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.hub_rounded,
                size: 16,
                color:
                    hasLinks
                        ? widget
                            .theme
                            .lightModeColor
                            .prColor250
                        : Colors.grey.shade700,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Multi-Branch Product Family',
                  style: TextStyle(
                    fontSize:
                        widget
                            .theme
                            .mobileTexts
                            .b4
                            .fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (hasLinks)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: Colors.green.shade200,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.link_rounded,
                        size: 14,
                        color: Colors.green.shade700,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _stagedBranches.length > 1
                            ? 'Linked (${_stagedBranches.length} Branches)'
                            : 'Linked (1 Branch)',
                        style: TextStyle(
                          fontSize:
                              widget
                                  .theme
                                  .mobileTexts
                                  .b5
                                  .fontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Connect this item to its counterparts across all other branches for automatic 2-way stock transfers.',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 10),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                ),
              ),
            )
          else if (effectiveBranches.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final info in effectiveBranches)
                  Container(
                    margin: const EdgeInsets.only(
                      bottom: 6,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(
                        6,
                      ),
                      border: Border.all(
                        color: Colors.grey.shade200,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.storefront_rounded,
                          size: 14,
                          color:
                              widget
                                  .theme
                                  .lightModeColor
                                  .prColor250,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                info.shop.name,
                                style: TextStyle(
                                  fontWeight:
                                      FontWeight.bold,
                                  fontSize:
                                      widget
                                          .theme
                                          .mobileTexts
                                          .b4
                                          .fontSize,
                                ),
                              ),
                              Text(
                                '${info.product.name} (Stock: ${info.product.getActualQuantity() ?? 0} ${info.product.getProductUnit().name})',
                                style: TextStyle(
                                  fontSize:
                                      widget
                                          .theme
                                          .mobileTexts
                                          .b4
                                          .fontSize,
                                  color:
                                      const Color.fromARGB(
                                        255,
                                        78,
                                        78,
                                        78,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.close_rounded,
                            size: 16,
                          ),
                          color: Colors.red.shade400,
                          splashRadius: 18,
                          tooltip: 'Remove',
                          onPressed: () => _removeBranch(info),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: _openBranchPicker,
                      icon: const Icon(
                        Icons.add_rounded,
                        size: 16,
                      ),
                      label: Text(
                        'Link Another Branch',
                        style: TextStyle(
                          fontSize:
                              widget
                                  .theme
                                  .mobileTexts
                                  .b4
                                  .fontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        visualDensity:
                            VisualDensity.compact,
                        foregroundColor:
                            widget
                                .theme
                                .lightModeColor
                                .prColor250,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _unlink,
                      icon: Icon(
                        Icons.link_off_rounded,
                        size: 16,
                        color: Colors.red.shade600,
                      ),
                      label: Text(
                        'Disconnect All',
                        style: TextStyle(
                          fontSize:
                              widget
                                  .theme
                                  .mobileTexts
                                  .b4
                                  .fontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade600,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        visualDensity:
                            VisualDensity.compact,
                      ),
                    ),
                  ],
                ),
              ],
            )
          else
            OutlinedButton.icon(
              onPressed: _openBranchPicker,
              icon: const Icon(
                Icons.add_link_rounded,
                size: 16,
              ),
              label: Text(
                style: TextStyle(
                  fontSize:
                      widget.theme.mobileTexts.b4.fontSize,
                  fontWeight: FontWeight.bold,
                ),
                'Link to Branch Product',
              ),
              style: OutlinedButton.styleFrom(
                visualDensity: VisualDensity.compact,
                foregroundColor:
                    widget.theme.lightModeColor.prColor250,
              ),
            ),
        ],
      ),
    );
  }
}

// ============================================================================
// 2. DEPARTMENT PRODUCT LINK WIDGET
// ============================================================================
class DepartmentProductLinkWidget extends StatefulWidget {
  final TempProductClass? currentProduct;
  final ThemeProvider theme;
  final Function(
    List<LinkedDepartmentProductInfo> stagedDepartments,
    List<LinkedDepartmentProductInfo> removedDepartments,
    bool isUnlinked,
  )
  onDepartmentsChanged;

  const DepartmentProductLinkWidget({
    super.key,
    this.currentProduct,
    required this.theme,
    required this.onDepartmentsChanged,
  });

  @override
  State<DepartmentProductLinkWidget> createState() =>
      _DepartmentProductLinkWidgetState();
}

class _DepartmentProductLinkWidgetState
    extends State<DepartmentProductLinkWidget> {
  List<LinkedDepartmentProductInfo> _stagedDepts = [];
  final List<LinkedDepartmentProductInfo> _removedDepts = [];
  bool _isUnlinked = false;

  @override
  void initState() {
    super.initState();
    _resolveExistingLinks();
  }

  void _resolveExistingLinks() {
    final prod = widget.currentProduct;
    if (prod == null) return;

    final clusterId = prod.globalDepartmentProductId;
    if (clusterId == null || clusterId.trim().isEmpty) {
      return;
    }

    final allProducts = returnData().productListMain;
    final departments =
        returnDepartmentProvider().departments;

    final found = <LinkedDepartmentProductInfo>[];
    for (final dept in departments) {
      if (dept.uuid == prod.departmentUuid) continue;
      for (final p in allProducts) {
        if (p.departmentUuid == dept.uuid &&
            p.globalDepartmentProductId != null &&
            p.globalDepartmentProductId == clusterId &&
            p.uuid != prod.uuid) {
          found.add(
            LinkedDepartmentProductInfo(
              product: p,
              department: dept,
            ),
          );
          break;
        }
      }
    }

    _stagedDepts = List.from(found);
  }

  void _openDepartmentPicker() {
    final currentDeptUuid =
        returnData().departmentUuid ??
        widget.currentProduct?.departmentUuid ??
        returnDepartmentProvider()
            .currentDepartment()
            ?.uuid;

    final availableDepts =
        returnDepartmentProvider().departments
            .where((d) => d.uuid != currentDeptUuid)
            .toList();

    if (availableDepts.isEmpty) {
      showDialog(
        context: context,
        builder:
            (_) => InfoAlert(
              theme: widget.theme,
              title: 'No Other Departments',
              message:
                  'There are no other departments available to link with this item.',
            ),
      );
      return;
    }

    DepartmentClass? chosenDept;
    showDialog(
      context: context,
      builder: (deptDialogCtx) {
        return StatefulBuilder(
          builder: (stateCtx, setDeptState) {
            return DialogTemplate(
              theme: widget.theme,
              title: 'Select Destination Department',
              message:
                  'Choose the department to link with this product.',
              action: () {
                if (chosenDept != null) {
                  Navigator.of(deptDialogCtx).pop();
                  _openProductPickerForDept(chosenDept!);
                }
              },
              actionButtonText: 'Next',
              widget: SizedBox(
                width: 500,
                height: (screenHeight(context) * 0.45)
                    .clamp(200.0, 420.0),
                child: SingleChildScrollView(
                  child: Column(
                    children:
                        availableDepts.map((d) {
                          final isSelected =
                              chosenDept?.uuid == d.uuid;
                          final isAlreadyConnected =
                              _stagedDepts.any(
                                (c) =>
                                    c.department.uuid ==
                                    d.uuid,
                              );
                          return ListTile(
                            title: Text(
                              d.name,
                              style: TextStyle(
                                fontWeight:
                                    isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                fontSize:
                                    widget
                                        .theme
                                        .mobileTexts
                                        .b3
                                        .fontSize,
                              ),
                            ),
                            subtitle:
                                isAlreadyConnected
                                    ? Text(
                                      'Already in family (tap to change item)',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color:
                                            Colors
                                                .blue
                                                .shade700,
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    )
                                    : null,
                            trailing: Icon(
                              isSelected
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_off,
                              color:
                                  isSelected
                                      ? widget.theme.lightModeColor.prColor250
                                      : Colors.grey,
                            ),
                            mouseCursor:
                                SystemMouseCursors.click,
                            onTap: () {
                              setDeptState(() {
                                chosenDept =
                                    isSelected ? null : d;
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

  void _openProductPickerForDept(DepartmentClass dept) {
    final searchCtrl = TextEditingController();
    final allProducts = returnData().productListMain;
    final deptProducts =
        allProducts
            .where((p) => p.departmentUuid == dept.uuid)
            .toList();

    showDialog(
      context: context,
      builder: (prodDialogCtx) {
        return StatefulBuilder(
          builder: (stateCtx, setListState) {
            final query =
                searchCtrl.text.toLowerCase().trim();
            final filtered =
                deptProducts.where((p) {
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
              theme: widget.theme,
              title: 'Select Product in ${dept.name}',
              message:
                  'Choose the matching product in ${dept.name} to establish the department link.',
              action: () {},
              showBottomActionButtons: false,
              widget: SizedBox(
                width: 500,
                height: (screenHeight(context) * 0.55)
                    .clamp(280.0, 500.0),
                child: Column(
                  children: [
                    GeneralTextfieldOnly(
                      hint:
                          'Search product name or barcode...',
                      controller: searchCtrl,
                      lines: 1,
                      theme: widget.theme,
                      onChanged: (_) => setListState(() {}),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child:
                          filtered.isEmpty
                              ? EmptyWidgetDisplayOnly(
                                title: 'No Products Found',
                                subText:
                                    'No matching products found in ${dept.name}.',
                                theme: widget.theme,
                                height: 25,
                                icon: Icons.search_off,
                              )
                              : SingleChildScrollView(
                                child: Column(
                                  children:
                                      filtered.map((p) {
                                        final isSelected =
                                            _stagedDepts.any(
                                              (d) =>
                                                  d.product.uuid ==
                                                  p.uuid,
                                            );

                                        return ListTile(
                                          dense: true,
                                          title: Text(
                                            p.name,
                                            style: TextStyle(
                                              fontWeight:
                                                  isSelected
                                                      ? FontWeight
                                                          .bold
                                                      : FontWeight
                                                          .normal,
                                              fontSize:
                                                  widget
                                                      .theme
                                                      .mobileTexts
                                                      .b3
                                                      .fontSize,
                                            ),
                                          ),
                                          subtitle: Text(
                                            'Available: ${p.getActualQuantity() ?? 0} ${p.getProductUnit().name}',
                                            style:
                                                const TextStyle(
                                                  fontSize:
                                                      11,
                                                ),
                                          ),
                                          trailing:
                                              isSelected
                                                  ? Icon(
                                                    Icons
                                                        .check_circle,
                                                    color:
                                                        widget.theme.lightModeColor.prColor250,
                                                  )
                                                  : const Icon(
                                                    Icons
                                                        .chevron_right,
                                                    color:
                                                        Colors.grey,
                                                  ),
                                          mouseCursor:
                                              SystemMouseCursors
                                                  .click,
                                          onTap: () {
                                            Navigator.of(
                                              prodDialogCtx,
                                            ).pop();
                                            setState(() {
                                              _stagedDepts
                                                  .removeWhere(
                                                    (d) =>
                                                        d.department.uuid ==
                                                        dept.uuid,
                                                  );
                                              _stagedDepts.add(
                                                LinkedDepartmentProductInfo(
                                                  product:
                                                      p,
                                                  department:
                                                      dept,
                                                ),
                                              );
                                              _removedDepts
                                                  .removeWhere(
                                                    (d) =>
                                                        d.department.uuid ==
                                                        dept.uuid,
                                                  );
                                              _isUnlinked =
                                                  false;
                                            });
                                            widget
                                                .onDepartmentsChanged(
                                                  _stagedDepts,
                                                  _removedDepts,
                                                  false,
                                                );
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

  void _removeDept(LinkedDepartmentProductInfo info) {
    setState(() {
      _stagedDepts.removeWhere(
        (d) => d.department.uuid == info.department.uuid,
      );
      _removedDepts.add(info);
      if (_stagedDepts.isEmpty) {
        _isUnlinked = true;
      }
    });
    widget.onDepartmentsChanged(_stagedDepts, _removedDepts, _isUnlinked);
  }

  void _unlink() {
    setState(() {
      _removedDepts.addAll(_stagedDepts);
      _stagedDepts.clear();
      _isUnlinked = true;
    });
    widget.onDepartmentsChanged([], _removedDepts, true);
  }

  @override
  Widget build(BuildContext context) {
    final canManageDepts =
        returnShopProvider()
            .userShop()
            ?.manageDepartments ==
        true;
    if (!canManageDepts) {
      return const SizedBox.shrink();
    }

    final effectiveDepts = _stagedDepts;
    final hasLinks = effectiveDepts.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color:
              hasLinks
                  ? widget.theme.lightModeColor.prColor250
                      .withValues(alpha: 0.3)
                  : Colors.grey.shade300,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_tree_rounded,
                size: 16,
                color:
                    hasLinks
                        ? widget.theme.lightModeColor.prColor250
                        : Colors.grey.shade700,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Multi-Department Product Family',
                  style: TextStyle(
                    fontSize:
                        widget
                            .theme
                            .mobileTexts
                            .b4
                            .fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (hasLinks)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: Colors.blue.shade200,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.link_rounded,
                        size: 14,
                        color: Colors.blue.shade700,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _stagedDepts.length > 1
                            ? 'Linked (${_stagedDepts.length} Departments)'
                            : 'Linked (1 Department)',
                        style: TextStyle(
                          fontSize:
                              widget
                                  .theme
                                  .mobileTexts
                                  .b5
                                  .fontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Connect this item to its counterparts across departments in this store for unified tracking and seamless transfers.',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 10),
          if (effectiveDepts.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final info in effectiveDepts)
                  Container(
                    margin: const EdgeInsets.only(
                      bottom: 6,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(
                        6,
                      ),
                      border: Border.all(
                        color: Colors.grey.shade200,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.apartment_rounded,
                          size: 14,
                          color:
                              widget
                                  .theme
                                  .lightModeColor
                                  .prColor250,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                info.department.name,
                                style: TextStyle(
                                  fontWeight:
                                      FontWeight.bold,
                                  fontSize:
                                      widget
                                          .theme
                                          .mobileTexts
                                          .b4
                                          .fontSize,
                                ),
                              ),
                              Text(
                                '${info.product.name} (Stock: ${info.product.getActualQuantity() ?? 0} ${info.product.getProductUnit().name})',
                                style: TextStyle(
                                  fontSize:
                                      widget
                                          .theme
                                          .mobileTexts
                                          .b4
                                          .fontSize,
                                  color:
                                      const Color.fromARGB(
                                        255,
                                        78,
                                        78,
                                        78,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.close_rounded,
                            size: 16,
                          ),
                          color: Colors.red.shade400,
                          splashRadius: 18,
                          tooltip: 'Remove',
                          onPressed: () => _removeDept(info),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: _openDepartmentPicker,
                      icon: const Icon(
                        Icons.add_rounded,
                        size: 16,
                      ),
                      label: Text(
                        'Link Another Department',
                        style: TextStyle(
                          fontSize:
                              widget
                                  .theme
                                  .mobileTexts
                                  .b4
                                  .fontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        visualDensity:
                            VisualDensity.compact,
                        foregroundColor:
                            widget
                                .theme
                                .lightModeColor
                                .prColor250,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _unlink,
                      icon: Icon(
                        Icons.link_off_rounded,
                        size: 16,
                        color: Colors.red.shade600,
                      ),
                      label: Text(
                        'Disconnect All',
                        style: TextStyle(
                          fontSize:
                              widget
                                  .theme
                                  .mobileTexts
                                  .b4
                                  .fontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade600,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        visualDensity:
                            VisualDensity.compact,
                      ),
                    ),
                  ],
                ),
              ],
            )
          else
            OutlinedButton.icon(
              onPressed: _openDepartmentPicker,
              icon: const Icon(
                Icons.add_link_rounded,
                size: 16,
              ),
              label: Text(
                style: TextStyle(
                  fontSize:
                      widget.theme.mobileTexts.b4.fontSize,
                  fontWeight: FontWeight.bold,
                ),
                'Link to Department Product',
              ),
              style: OutlinedButton.styleFrom(
                visualDensity: VisualDensity.compact,
                foregroundColor:
                    widget.theme.lightModeColor.prColor250,
              ),
            ),
        ],
      ),
    );
  }
}
