import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stockitt/components/alert_dialogues/info_alert.dart';
import 'package:stockitt/components/buttons/main_button_p.dart';
import 'package:stockitt/components/progress_bar.dart';
import 'package:stockitt/components/major/top_banner.dart';
import 'package:stockitt/main.dart';
import 'package:stockitt/pages/shop_setup/shop_setup_two.dart';
import 'package:stockitt/providers/theme_provider.dart';
import 'package:stockitt/pages/shop_setup/components/text_field.dart';
import 'package:stockitt/services/auth_service.dart';

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
  void checkInput() {
    if (nameController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          var theme = returnTheme(context);
          return InfoAlert(
            theme: theme,
            message: 'Shop Name Must be set',
            title: 'Empty Fields',
          );
        },
      );
    } else {
      returnShopProvider(context, listen: false).name =
          nameController.text.trim();
      returnShopProvider(context, listen: false).email =
          emailController.text.isEmpty
              ? AuthService().currentUser!.email!
              : emailController.text;
      // returnShopProvider(context, listen: false).email =
      //     emailController.text.isEmpty
      //         ? AuthService().currentUser!.email!
      //         : emailController.text;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return ShopSetupTwo();
          },
        ),
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    emailController.dispose();
    numberController.dispose();
  }

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
                        percent: '0%',
                        title: 'Your Progress',
                      ),
                    ),
                    SizedBox(height: 20),
                    Column(
                      spacing: 10,
                      children: [
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(
                                horizontal: 30.0,
                              ),
                          child: Column(
                            spacing: 20,
                            children: [
                              FormFieldShop(
                                isPhone: false,
                                isOptional: false,
                                theme: theme,
                                hintText:
                                    'Enter your shop Name',
                                title: 'Shop Name',
                                isEmail: false,
                                controller: nameController,
                              ),
                              FormFieldShop(
                                isPhone: false,
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
                                isPhone: true,
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
                                  checkInput();
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
