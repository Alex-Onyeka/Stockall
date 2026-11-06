import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/classes/temp_shop/temp_shop_class.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/alert_dialogues/dialog_template.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/components/major/empty_widget_display_only.dart';
import 'package:stockall/components/text_fields/general_textfield_only.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/providers/theme_provider.dart';
import 'package:stockall/services/product_linking_helper.dart';

class ProductBranchLinkWidget extends StatefulWidget {
  final TempProductClass product;
  final ThemeProvider theme;
  final VoidCallback onUpdated;

  const ProductBranchLinkWidget({
    super.key,
    required this.product,
    required this.theme,
    required this.onUpdated,
  });

  @override
  State<ProductBranchLinkWidget> createState() =>
      _ProductBranchLinkWidgetState();
}

class _ProductBranchLinkWidgetState extends State<ProductBranchLinkWidget> {
  bool _isLoading = true;
  LinkedProductInfo? _linkedInfo;

  @override
  void initState() {
    super.initState();
    _loadLinkedInfo();
  }

  @override
  void didUpdateWidget(covariant ProductBranchLinkWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.product.transferedProductId !=
            widget.product.transferedProductId ||
        oldWidget.product.uuid != widget.product.uuid) {
      _loadLinkedInfo();
    }
  }

  Future<void> _loadLinkedInfo() async {
    final otherShops = returnShopProvider()
        .userShops
        .where((s) => s.shopId != shopId())
        .toList();

    if (otherShops.isEmpty) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    final isOnline = returnConnectivityProvider().isConnected;
    if (!isOnline) {
      // Offline: if we have a transferedProductId, we know it's linked but can't fetch remote details
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      return;
    }

    try {
      final info = await ProductLinkingHelper.findLinkedProductDetails(
        sourceProduct: widget.product,
        otherShops: otherShops,
      );
      if (mounted) {
        setState(() {
          _linkedInfo = info;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _openBranchAndProductPicker() {
    final isOnline = returnConnectivityProvider().isConnected;
    if (!isOnline) {
      showDialog(
        context: context,
        builder: (_) => InfoAlert(
          theme: widget.theme,
          title: 'No Internet Connection',
          message:
              'You need an active internet connection to link products across store branches.',
        ),
      );
      return;
    }

    final otherShops = returnShopProvider()
        .userShops
        .where((s) => s.shopId != shopId())
        .toList();

    if (otherShops.isEmpty) {
      showDialog(
        context: context,
        builder: (_) => InfoAlert(
          theme: widget.theme,
          title: 'No Other Branches',
          message: 'No other store branches are available to link with.',
        ),
      );
      return;
    }

    TempShopClass? chosenShop;

    showDialog(
      context: context,
      builder: (shopDialogContext) {
        return StatefulBuilder(
          builder: (stateContext, setDialogState) {
            return DialogTemplate(
              theme: widget.theme,
              title: 'Select Destination Branch',
              message:
                  'Choose the store branch containing the product you want to link with "${widget.product.name}".',
              action: () {
                if (chosenShop != null) {
                  Navigator.of(shopDialogContext).pop();
                  _openTargetProductPicker(chosenShop!);
                }
              },
              actionButtonText: 'Next',
              widget: SizedBox(
                width: 500,
                height: (screenHeight(context) * 0.45).clamp(200.0, 420.0),
                child: SingleChildScrollView(
                  child: Column(
                    spacing: 4,
                    children: otherShops.map((s) {
                      final isSelected = chosenShop?.shopId == s.shopId;
                      return ListTile(
                        title: Text(
                          s.name,
                          style: TextStyle(
                            fontWeight:
                                isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: widget.theme.mobileTexts.b3.fontSize,
                          ),
                        ),
                        trailing: Icon(
                          isSelected
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                          color: isSelected
                              ? widget.theme.lightModeColor.prColor250
                              : Colors.grey,
                        ),
                        onTap: () {
                          setDialogState(() {
                            chosenShop = isSelected ? null : s;
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

  void _openTargetProductPicker(TempShopClass shop) async {
    final searchCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (productDialogContext) {
        return FutureBuilder<List<TempProductClass>>(
          future: returnData().getProductsForOtherShops(shop.shopId!),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return DialogTemplate(
                theme: widget.theme,
                title: 'Loading Products',
                message: 'Fetching products from ${shop.name}...',
                action: () {},
                showBottomActionButtons: false,
                widget: const SizedBox(
                  height: 160,
                  child: Center(child: CircularProgressIndicator()),
                ),
              );
            }

            final products = snapshot.data ?? [];

            return StatefulBuilder(
              builder: (stateContext, setListState) {
                final query = searchCtrl.text.toLowerCase().trim();
                final filtered = products.where((p) {
                  if (query.isEmpty) return true;
                  return p.name.toLowerCase().contains(query) ||
                      (p.barcode != null &&
                          p.barcode!.toLowerCase().contains(query));
                }).toList();

                return DialogTemplate(
                  theme: widget.theme,
                  title: 'Select Product to Link',
                  message:
                      'Select the product in ${shop.name} that corresponds to "${widget.product.name}".',
                  action: () {},
                  showBottomActionButtons: false,
                  widget: SizedBox(
                    width: 500,
                    height: (screenHeight(context) * 0.55).clamp(280.0, 500.0),
                    child: Column(
                      children: [
                        GeneralTextfieldOnly(
                          hint: 'Search product name or barcode...',
                          controller: searchCtrl,
                          lines: 1,
                          theme: widget.theme,
                          onChanged: (_) => setListState(() {}),
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child: filtered.isEmpty
                              ? EmptyWidgetDisplayOnly(
                                  title: 'No Products Found',
                                  subText: 'No matching products in ${shop.name}.',
                                  theme: widget.theme,
                                  height: 25,
                                  icon: Icons.search_off,
                                )
                              : SingleChildScrollView(
                                  child: Column(
                                    spacing: 4,
                                    children: filtered.map((p) {
                                      final isCurrentlyLinked =
                                          _linkedInfo?.product.uuid == p.uuid ||
                                          widget.product.transferedProductId ==
                                              p.uuid;

                                      return ListTile(
                                        dense: true,
                                        title: Text(
                                          p.name,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: widget
                                                .theme.mobileTexts.b3.fontSize,
                                          ),
                                        ),
                                        subtitle: Text(
                                          'Qty: ${p.getActualQuantity() ?? 0} ${p.getProductUnit().name}',
                                          style: const TextStyle(fontSize: 11),
                                        ),
                                        trailing: isCurrentlyLinked
                                            ? Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 3),
                                                decoration: BoxDecoration(
                                                  color: Colors.green.shade100,
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  'Linked',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.green.shade800,
                                                  ),
                                                ),
                                              )
                                            : const Icon(Icons.link_rounded,
                                                color: Colors.grey),
                                        onTap: () {
                                          Navigator.of(productDialogContext).pop();
                                          _confirmAndLink(p, shop);
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

  void _confirmAndLink(TempProductClass target, TempShopClass shop) {
    showDialog(
      context: context,
      builder: (confirmContext) {
        return ConfirmationAlert(
          theme: widget.theme,
          title: 'Link Products Across Branches',
          message:
              'Link "${widget.product.name}" with "${target.name}" in "${shop.name}"?\n\nThis will allow Stockall to automatically recognize this product pair during branch stock transfers.',
          action: () async {
            Navigator.of(confirmContext).pop();
            setState(() => _isLoading = true);

            final success = await ProductLinkingHelper.linkProducts(
              sourceProduct: widget.product,
              targetProduct: target,
            );

            if (success) {
              await _loadLinkedInfo();
              widget.onUpdated();
              if (mounted) {
                showDialog(
                  context: context,
                  builder: (_) => InfoAlert(
                    theme: widget.theme,
                    title: 'Products Linked',
                    message:
                        '"${widget.product.name}" is now linked to "${target.name}" in "${shop.name}".',
                  ),
                );
              }
            } else {
              setState(() => _isLoading = false);
              if (mounted) {
                showDialog(
                  context: context,
                  builder: (_) => InfoAlert(
                    theme: widget.theme,
                    title: 'Linking Failed',
                    message:
                        'An error occurred while linking the products. Please try again.',
                  ),
                );
              }
            }
          },
        );
      },
    );
  }

  void _confirmAndUnlink() {
    showDialog(
      context: context,
      builder: (confirmContext) {
        return ConfirmationAlert(
          theme: widget.theme,
          title: 'Unlink Product',
          message:
              'Are you sure you want to unlink this product? This will remove the branch connection without deleting either product or modifying stock quantities.',
          action: () async {
            Navigator.of(confirmContext).pop();
            setState(() => _isLoading = true);

            final otherShops = returnShopProvider().userShops;
            final success = await ProductLinkingHelper.unlinkProduct(
              sourceProduct: widget.product,
              otherShops: otherShops,
            );

            if (success) {
              setState(() {
                _linkedInfo = null;
                _isLoading = false;
              });
              widget.onUpdated();
              if (mounted) {
                showDialog(
                  context: context,
                  builder: (_) => InfoAlert(
                    theme: widget.theme,
                    title: 'Product Unlinked',
                    message:
                        'The product relationship has been successfully removed.',
                  ),
                );
              }
            } else {
              setState(() => _isLoading = false);
              if (mounted) {
                showDialog(
                  context: context,
                  builder: (_) => InfoAlert(
                    theme: widget.theme,
                    title: 'Unlink Failed',
                    message:
                        'An error occurred while unlinking. Please try again.',
                  ),
                );
              }
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (returnShopProvider().userShops.length <= 1) {
      return const SizedBox.shrink(); // Single shop setup, branch linking not applicable
    }

    final isLinked = _linkedInfo != null ||
        (widget.product.transferedProductId != null &&
            widget.product.transferedProductId!.isNotEmpty);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isLinked ? Colors.green.shade50 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isLinked ? Colors.green.shade200 : Colors.grey.shade300,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isLinked
                  ? Colors.green.shade100
                  : Colors.grey.shade200,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isLinked ? Icons.link_rounded : Icons.link_off_rounded,
              color: isLinked ? Colors.green.shade800 : Colors.grey.shade600,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isLinked ? 'Linked Branch Product' : 'Branch Link: Not Linked',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: widget.theme.mobileTexts.b3.fontSize,
                    color: isLinked
                        ? Colors.green.shade900
                        : Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 2),
                if (_isLoading)
                  const Text(
                    'Checking branch link status...',
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  )
                else if (isLinked && _linkedInfo != null)
                  Text(
                    '${_linkedInfo!.product.name} (${_linkedInfo!.shop.name})',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.green.shade800,
                    ),
                  )
                else if (isLinked)
                  Text(
                    'Linked to counterpart (ID: ${widget.product.transferedProductId})',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.green.shade800,
                    ),
                  )
                else
                  Text(
                    'Link to corresponding product in another branch for automatic transfers.',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (isLinked) ...[
            TextButton(
              onPressed: _openBranchAndProductPicker,
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              child: const Text('Change', style: TextStyle(fontSize: 12)),
            ),
            TextButton(
              onPressed: _confirmAndUnlink,
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                foregroundColor: Colors.red.shade700,
              ),
              child: const Text('Unlink', style: TextStyle(fontSize: 12)),
            ),
          ] else
            TextButton.icon(
              onPressed: _openBranchAndProductPicker,
              icon: const Icon(Icons.add_link_rounded, size: 16),
              label: const Text('Link', style: TextStyle(fontSize: 12)),
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                foregroundColor: widget.theme.lightModeColor.prColor250,
              ),
            ),
        ],
      ),
    );
  }
}
