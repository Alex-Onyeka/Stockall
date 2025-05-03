import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stockitt/components/buttons/main_button_p.dart';
import 'package:stockitt/components/progress_bar.dart';
import 'package:stockitt/pages/shop_setup/components/text_field.dart';
import 'package:stockitt/components/major/top_banner.dart';
import 'package:stockitt/providers/theme_provider.dart';

class ShopSetupTwo extends StatefulWidget {
  const ShopSetupTwo({super.key});

  @override
  State<ShopSetupTwo> createState() => _ShopSetupTwoState();
}

class _ShopSetupTwoState extends State<ShopSetupTwo> {
  TextEditingController nameController =
      TextEditingController();
  TextEditingController emailController =
      TextEditingController();
  TextEditingController numberController =
      TextEditingController();
  @override
  Widget build(BuildContext context) {
    var theme = Provider.of<ThemeProvider>(context);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 600) {
            return Scaffold(
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    TopBanner(
                      bottomSpace: 50,
                      topSpace: 40,
                      theme: theme,
                      subTitle:
                          'Create a Shop to get Started.',
                      title: 'Shop Setup',
                    ),
                    SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30.0,
                      ),
                      child: ProgressBar(
                        position: 0.06,
                        calcValue: 0.35,
                        theme: theme,
                        constraints: constraints,
                        percent: '50%',
                        title: 'Your Progress',
                      ),
                    ),
                    SizedBox(height: 20),
                    Column(
                      spacing: 10,
                      children: [
                        // Row(
                        //   mainAxisAlignment:
                        //       MainAxisAlignment.center,
                        //   children: [
                        //     Container(
                        //       padding: EdgeInsets.all(30),
                        //       decoration: BoxDecoration(
                        //         shape: BoxShape.circle,
                        //         color: Colors.grey.shade100,
                        //       ),
                        //       child: Center(
                        //         child: Icon(
                        //           size: 50,
                        //           Icons.home_work_outlined,
                        //         ),
                        //       ),
                        //     ),
                        //   ],
                        // ),
                        // Padding(
                        //   padding:
                        //       const EdgeInsets.symmetric(
                        //         horizontal: 80.0,
                        //       ),
                        //   child: Text(
                        //     textAlign: TextAlign.center,
                        //     style: TextStyle(
                        //       color:
                        //           theme
                        //               .lightModeColor
                        //               .greyColor100,
                        //       fontSize:
                        //           theme
                        //               .mobileTexts
                        //               .b2
                        //               .fontSize,
                        //     ),
                        //     'Enter Shop Details Below to Complete Shop Set Up',
                        //   ),
                        // ),
                        // SizedBox(height: 20),
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(
                                horizontal: 30.0,
                              ),
                          child: Column(
                            spacing: 15,
                            children: [
                              FormFieldShop(
                                isOptional: false,
                                theme: theme,
                                hintText: 'State',
                                title: 'Enter State',
                                isEmail: false,
                                controller: nameController,
                              ),
                              FormFieldShop(
                                isOptional: false,
                                theme: theme,
                                hintText: 'City',
                                title: 'Enter City',

                                isEmail: false,
                                controller: emailController,
                              ),
                              FormFieldShop(
                                isOptional: false,
                                theme: theme,
                                hintText: 'Address',
                                title: 'Enter Address',
                                isEmail: false,

                                controller:
                                    numberController,
                              ),
                              SizedBox(height: 5),
                              MainButtonP(
                                themeProvider: theme,
                                action: () {},
                                text: 'Create Shop',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          } else {
            return Scaffold(
              body: Column(
                children: [
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      gradient:
                          theme.lightModeColor.prGradient,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
