// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:stockall/pages/authentication/sign_up/enter_otp/platforms/enter_otp_mobile.dart';
// import 'package:stockall/providers/theme_provider.dart';

// class EnterOtp extends StatelessWidget {
//   final String number;
//   const EnterOtp({super.key, required this.number});

//   @override
//   Widget build(BuildContext context) {
//     var themeProvider = Provider.of<ThemeProvider>(context);
//     return SafeArea(
//       child: GestureDetector(
//         onTap: () => FocusScope.of(context).unfocus(),
//         child: LayoutBuilder(
//           builder: (context, constraints) {
//             if (constraints.maxWidth < 600) {
//               return EnterOtpMobile(
//                 number: number,
//                 themeProvider: themeProvider,
//               );
//             } else {
//               return EnterOtpDesktop(
//                 number: number,
//                 themeProvider: themeProvider,
//               );
//             }
//           },
//         ),
//       ),
//     );
//   }
// }
