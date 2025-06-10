import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:stockall/components/buttons/main_button_p.dart';
import 'package:stockall/components/buttons/main_button_transparent.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/home/home.dart';
import 'package:stockall/pages/shop_setup/banner_screen/copy_staff_id/copy_staff_id.dart';
import 'package:stockall/pages/shop_setup/shop_setup_page.dart';

class ShopBannerScreen extends StatelessWidget {
  const ShopBannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 60.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LottieBuilder.asset(shopSetup, height: 140),
              SizedBox(height: 15),
              Text(
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: theme.mobileTexts.b2.fontSize,
                  fontWeight: FontWeight.bold,
                  color: theme.lightModeColor.secColor200,
                ),
                'You account has been Created Successfully',
              ),
              SizedBox(height: 10),
              Text(
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: theme.mobileTexts.h3.fontSize,
                  fontWeight: FontWeight.bold,
                ),
                'Set Up Your Store To Start Selling',
              ),
              SizedBox(height: 30),
              MainButtonP(
                themeProvider: theme,
                action: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return ShopSetupPage();
                      },
                    ),
                  );
                },
                text: 'Create Shop',
              ),
              SizedBox(height: 20),
              Text(
                textAlign: TextAlign.center,
                style: TextStyle(),
                'Or, don\'t you have a Store?',
              ),
              SizedBox(height: 10),
              // Container(
              //   padding: EdgeInsets.symmetric(vertical: 15),
              //   child: Center(
              //     child: Text(
              //       style: TextStyle(),
              //       'Sign Up as an Employee',
              //     ),
              //   ),
              // ),
              MainButtonTransparent(
                themeProvider: theme,
                constraints: BoxConstraints(),
                text: 'Sign Up as a Staff',
                action: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return CopyStaffId();
                      },
                    ),
                  );
                },
              ),
              SizedBox(height: 30),
              InkWell(
                onTap: () {
                  returnNavProvider(
                    context,
                    listen: false,
                  ).navigate(0);
                  Navigator.popAndPushNamed(context, '/');
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(
                    vertical: 15,
                  ),
                  child: Center(
                    child: Row(
                      spacing: 5,
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        Text(
                          style: TextStyle(
                            fontSize:
                                theme
                                    .mobileTexts
                                    .b1
                                    .fontSize,
                            fontWeight: FontWeight.bold,
                            color:
                                theme
                                    .lightModeColor
                                    .secColor200,
                          ),
                          'Refresh Page to Verify',
                        ),
                        Icon(
                          size: 22,
                          color: Colors.grey,
                          Icons.refresh_sharp,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
