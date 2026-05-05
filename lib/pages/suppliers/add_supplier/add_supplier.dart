import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_suppliers/suppliers_class.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/pages/products/add_product_one/add_product.dart';
import 'package:stockall/pages/suppliers/add_supplier/platforms/add_supplier_desktop.dart';
import 'package:stockall/pages/suppliers/add_supplier/platforms/add_supplier_mobile.dart';

class AddSupplier extends StatefulWidget {
  final SuppliersClass? supplier;
  const AddSupplier({super.key, this.supplier});

  @override
  State<AddSupplier> createState() => _AddSupplierState();
}

class _AddSupplierState extends State<AddSupplier> {
  TextEditingController nameController =
      TextEditingController();
  TextEditingController phoneController =
      TextEditingController();
  TextEditingController emailController =
      TextEditingController();
  TextEditingController addressController =
      TextEditingController();

  @override
  void dispose() {
    super.dispose();
    addressController.dispose();
    emailController.dispose();
    nameController.dispose();
    phoneController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:
          () =>
              FocusManager.instance.primaryFocus?.unfocus(),
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          checkPop(
            context: context,
            didPop: didPop,
            conditionX:
                nameController.text.isNotEmpty ||
                emailController.text.isNotEmpty ||
                phoneController.text.isNotEmpty ||
                addressController.text.isNotEmpty,
          );
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < mobileScreen) {
              return AddSupplierMobile(
                emailController: emailController,
                nameController: nameController,
                phoneController: phoneController,
                addressController: addressController,
                supplier: widget.supplier,
              );
            } else {
              return AddSupplierDesktop(
                emailController: emailController,
                nameController: nameController,
                phoneController: phoneController,
                addressController: addressController,
                supplier: widget.supplier,
              );
            }
          },
        ),
      ),
    );
  }
}
