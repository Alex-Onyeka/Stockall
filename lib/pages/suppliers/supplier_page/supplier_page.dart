import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/suppliers/supplier_page/platform/supplier_page_desktop.dart';
import 'package:stockall/pages/suppliers/supplier_page/platform/supplier_page_mobile.dart';

class SupplierPage extends StatefulWidget {
  final String uuid;
  const SupplierPage({super.key, required this.uuid});

  @override
  State<SupplierPage> createState() => _SupplierPageState();
}

class _SupplierPageState extends State<SupplierPage> {
  /// Fetching suppliers because [SupplierPage.uuid] was not in the
  /// loaded list when the page opened.
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await returnPurchaseProvider().loadPurchases(shopId());
      if (returnSuppliersProvider().getSupplierByIdMain(
            widget.uuid,
          ) ==
          null) {
        if (mounted) setState(() => _loading = true);
        try {
          await returnSuppliersProvider().fetchSuppliers(
            shopId(),
          );
        } catch (e) {
          await mainLocalLog('Supplier page fetch failed: $e');
        }
        if (mounted) setState(() => _loading = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final supplier = returnSuppliersProvider(
      context: context,
    ).getSupplierByIdMain(widget.uuid);
    if (supplier == null) {
      return _SupplierMissing(loading: _loading);
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < mobileScreen) {
          return SupplierPageMobile(supplier: supplier);
        } else {
          return SupplierPageDesktop(supplier: supplier);
        }
      },
    );
  }
}

/// Shown instead of supplier details while the list loads, or when
/// the supplier is not in it (e.g. just deleted).
class _SupplierMissing extends StatelessWidget {
  final bool loading;
  const _SupplierMissing({required this.loading});

  @override
  Widget build(BuildContext context) {
    final theme = returnTheme(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          mouseCursor: SystemMouseCursors.click,
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.arrow_back_ios_new_rounded),
        ),
      ),
      body: Center(
        child:
            loading
                ? CircularProgressIndicator()
                : Column(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 8,
                  children: [
                    Icon(
                      Icons.person_off_outlined,
                      size: 40,
                      color: Colors.grey,
                    ),
                    Text(
                      'Supplier not found',
                      style: TextStyle(
                        fontSize: theme.mobileTexts.b1.fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'It may have been deleted.',
                      style: TextStyle(
                        fontSize: theme.mobileTexts.b3.fontSize,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Back'),
                    ),
                  ],
                ),
      ),
    );
  }
}
