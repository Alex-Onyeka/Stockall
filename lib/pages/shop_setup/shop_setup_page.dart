import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stockitt/components/buttons/main_button_p.dart';
import 'package:stockitt/components/progress_bar.dart';
import 'package:stockitt/components/major/top_banner.dart';
import 'package:stockitt/pages/shop_setup/shop_setup_two.dart';
import 'package:stockitt/providers/theme_provider.dart';
import 'package:stockitt/pages/shop_setup/components/text_field.dart';

class ShopSetupPage extends StatefulWidget {
  const ShopSetupPage({super.key});

  @override
  State<ShopSetupPage> createState() =>
      _ShopSetupPageState();
}

class _ShopSetupPageState extends State<ShopSetupPage> {
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
                      iconData:
                          Icons.add_home_work_outlined,
                    ),
                    SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30.0,
                      ),
                      child: ProgressBar(
                        position: -1,
                        calcValue: 0.03,
                        theme: theme,
                        constraints: constraints,
                        percent: '0%',
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
                                hintText: 'Name',
                                title: 'Shop Name',
                                isEmail: false,
                                controller: nameController,
                              ),
                              FormFieldShop(
                                isOptional: true,
                                theme: theme,
                                hintText: 'Shop Email',
                                title: 'Enter Email',
                                message:
                                    'Uses your Personal Email if you don\'t set',
                                isEmail: true,
                                controller: emailController,
                              ),
                              FormFieldShop(
                                isOptional: true,
                                theme: theme,
                                hintText:
                                    'Shop Phone Number',
                                title: 'Enter Phone',
                                isEmail: false,
                                message:
                                    'Uses your Personal Number if you don\'t set',
                                controller:
                                    numberController,
                              ),
                              SizedBox(height: 5),
                              MainButtonP(
                                themeProvider: theme,
                                action: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return ShopSetupTwo();
                                      },
                                    ),
                                  );
                                },
                                text: 'Save and Proceed',
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
