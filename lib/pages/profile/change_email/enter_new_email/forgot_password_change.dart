// import 'package:flutter/material.dart';
// import 'package:stockall/constants/constants_main.dart';

// class ForgotPasswordChange extends StatefulWidget {
//   const ForgotPasswordChange({super.key});

//   @override
//   State<ForgotPasswordChange> createState() =>
//       _ForgotPasswordChangeState();
// }

// class _ForgotPasswordChangeState
//     extends State<ForgotPasswordChange> {
//   TextEditingController emailController =
//       TextEditingController();
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap:
//           () =>
//               FocusManager.instance.primaryFocus?.unfocus(),
//       child: LayoutBuilder(
//         builder: (context, constraints) {
//           if (constraints.maxWidth < mobileScreen) {
//             return ForgotPasswordMobileChange(
//               emailController: emailController,
//             );
//           } else {
//             return ForgotPasswordDesktopChange(
//               emailController: emailController,
//             );
//             // return Scaffold();
//           }
//         },
//       ),
//     );
//   }
// }
