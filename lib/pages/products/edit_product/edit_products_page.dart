// import 'package:flutter/material.dart';
// import 'package:stockall/classes/temp_product_class.dart';
// import 'package:stockall/main.dart';
// import 'package:stockall/pages/products/edit_product/platforms/edit_product_mobile.dart';

// class EditProductsPage extends StatefulWidget {
//   final TempProductClass product;
//   const EditProductsPage({
//     super.key,
//     required this.product,
//   });

//   @override
//   State<EditProductsPage> createState() =>
//       _EditProductsPageState();
// }

// class _EditProductsPageState
//     extends State<EditProductsPage> {
//   TextEditingController categoryController =
//       TextEditingController();
//   TextEditingController costController =
//       TextEditingController();
//   TextEditingController sellingController =
//       TextEditingController();
//   TextEditingController nameController =
//       TextEditingController();
//   TextEditingController brandController =
//       TextEditingController();
//   TextEditingController sizeController =
//       TextEditingController();
//   TextEditingController quantityController =
//       TextEditingController();
//   String? barcode;
//   @override
//   void initState() {
//     super.initState();
//     nameController.text = widget.product.name;
//     brandController.text =
//         widget.product.brand != null
//             ? brandController.text = widget.product.brand!
//             : widget.product.brand!;
//     returnData().selectedCategory =
//         widget.product.category;
//     returnData().catValueSet = true;
//     costController.text =
//         widget.product.costPrice.toString();
//     sellingController.text =
//         widget.product.sellingPrice == null
//             ? ''
//             : widget.product.sellingPrice.toString();
//     // sellingController.text =
//     //     widget.product.sellingPrice.toString();
//     returnData().selectedUnit =
//         widget.product.unit;
//     returnData().unitValueSet = true;
//     returnData().selectedColor =
//         widget.product.color;
//     returnData().colorValueSet =
//         widget.product.color != null ? true : false;
//     sizeController.text =
//         widget.product.size != null
//             ? sizeController.text = widget.product.size!
//             : widget.product.size!;
//     quantityController.text =
//         widget.product.quantity == null
//             ? ''
//             : widget.product.quantity.toString();
//     returnData().selectedSize =
//         widget.product.sizeType;
//     returnData().sizeValueSet =
//         widget.product.sizeType != null ? true : false;

//     returnData().inStock =
//         (widget.product.quantity ?? 0) > 0 ? true : false;
//     returnData().isRefundable =
//         widget.product.isRefundable;
//     returnData().isManaged =
//         widget.product.isManaged;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap:
//           () =>
//               FocusManager.instance.primaryFocus?.unfocus(),
//       child: LayoutBuilder(
//         builder: (context, constraints) {
//           if (constraints.maxWidth < 550) {
//             return EditProductMobile(
//               product: widget.product,
//               brandController: brandController,
//               nameController: nameController,
//               quantityController: quantityController,
//               sizeController: sizeController,
//               categoryController: categoryController,
//               costController: costController,
//               sellingController: sellingController,
//             );
//           } else {
//             return Scaffold();
//           }
//         },
//       ),
//     );
//   }
// }
