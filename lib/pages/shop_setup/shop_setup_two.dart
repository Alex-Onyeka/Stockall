import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stockitt/classes/temp_shop_class.dart';
import 'package:stockitt/components/alert_dialogues/info_alert.dart';
import 'package:stockitt/components/buttons/main_button_p.dart';
import 'package:stockitt/components/progress_bar.dart';
import 'package:stockitt/main.dart';
import 'package:stockitt/pages/home/home.dart';
import 'package:stockitt/pages/shop_setup/components/text_field.dart';
import 'package:stockitt/components/major/top_banner.dart';
import 'package:stockitt/providers/theme_provider.dart';
import 'package:stockitt/services/auth_service.dart';

class ShopSetupTwo extends StatefulWidget {
  const ShopSetupTwo({super.key});

  @override
  State<ShopSetupTwo> createState() => _ShopSetupTwoState();
}

class _ShopSetupTwoState extends State<ShopSetupTwo> {
  bool isLoading = false;

  bool success = false;

  void loading() {
    setState(() {
      isLoading = true;
    });
    Future.delayed(Duration(seconds: 3), () {
      setState(() {
        isLoading = false;
      });
      showSuccess();
    });
  }

  void showSuccess() {
    setState(() {
      success = true;
    });
    Future.delayed(Duration(seconds: 3), () {
      if (!context.mounted) return;
      Navigator.pushReplacement(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(
          builder: (context) {
            return Home();
          },
        ),
      );
      // setState(() {
      //   success = false;
      // });
    });
  }

  TextEditingController stateController =
      TextEditingController();
  TextEditingController cityController =
      TextEditingController();
  TextEditingController addressController =
      TextEditingController();

  void checkInputs() {
    if (stateController.text.isEmpty ||
        cityController.text.isEmpty ||
        addressController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          var theme = returnTheme(context);
          return InfoAlert(
            theme: theme,
            message: 'All Fields Must be filled',
            title: 'Empty Fields',
          );
        },
      );
    } else {
      returnShopProvider(context, listen: false).createShop(
        TempShopClass(
          createdAt: DateTime.now(),
          userId: AuthService().currentUser!.id,
          email:
              returnShopProvider(
                context,
                listen: false,
              ).email!,
          name:
              returnShopProvider(
                context,
                listen: false,
              ).name,
          state:
              stateController.text.trim().isEmpty
                  ? null
                  : stateController.text.trim(),
          shopAddress:
              addressController.text.trim().isEmpty
                  ? null
                  : addressController.text.trim(),
          city:
              cityController.text.trim().isEmpty
                  ? null
                  : cityController.text.trim(),
        ),
      );
      loading();
    }
  }

  @override
  Widget build(BuildContext context) {
    var theme = Provider.of<ThemeProvider>(context);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Stack(
        children: [
          Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  TopBanner(
                    bottomSpace: 50,
                    iconData: Icons.home_work_outlined,
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
                      percent: '50%',
                      title: 'Your Progress',
                    ),
                  ),
                  SizedBox(height: 20),
                  Column(
                    spacing: 10,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30.0,
                        ),
                        child: Column(
                          spacing: 15,
                          children: [
                            FormFieldShop(
                              isPhone: false,
                              isOptional: false,
                              theme: theme,
                              hintText: 'State',
                              title: 'Enter State',
                              isEmail: false,
                              controller: stateController,
                            ),
                            FormFieldShop(
                              isPhone: false,
                              isOptional: false,
                              theme: theme,
                              hintText: 'City',
                              title: 'Enter City',

                              isEmail: false,
                              controller: cityController,
                            ),
                            FormFieldShop(
                              isPhone: false,
                              isOptional: false,
                              theme: theme,
                              hintText: 'Address',
                              title: 'Enter Address',
                              isEmail: false,

                              controller: addressController,
                            ),
                            SizedBox(height: 5),
                            MainButtonP(
                              themeProvider: theme,
                              action: () {
                                checkInputs();
                                // loading();
                              },
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
          ),
          Visibility(
            visible: isLoading,
            child: returnCompProvider(
              context,
              listen: false,
            ).showLoader('Setting Up Your Shop'),
          ),
          Visibility(
            visible: success,
            child: returnCompProvider(
              context,
              listen: false,
            ).showSuccess('Shop Setup Complete'),
          ),
        ],
      ),
    );
  }
}
