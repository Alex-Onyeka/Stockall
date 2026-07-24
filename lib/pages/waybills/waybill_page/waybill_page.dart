// import 'package:flutter/material.dart';
// import 'package:stockall/constants/constants_main.dart';
// import 'package:stockall/main.dart';
// import 'package:stockall/pages/waybills/waybill_page/platforms/waybill_page_desktop.dart';
// import 'package:stockall/pages/waybills/waybill_page/platforms/waybill_page_mobile.dart';

// class WaybillPage extends StatefulWidget {
//   final String waybillUuid;
//   const WaybillPage({super.key, required this.waybillUuid});

//   @override
//   State<WaybillPage> createState() => _WaybillPageState();
// }

// class _WaybillPageState extends State<WaybillPage> {
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       returnWaybillProvider().loadWaybills(shopId());
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         if (constraints.maxWidth < mobileScreen) {
//           return WaybillPageMobile(
//             waybillUuid: widget.waybillUuid,
//           );
//         } else {
//           return WaybillPageDesktop(
//             waybillUuid: widget.waybillUuid,
//           );
//         }
//       },
//     );
//   }
// }
