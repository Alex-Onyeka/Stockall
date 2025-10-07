import 'package:flutter/material.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/components/buttons/main_button_p.dart';
import 'package:stockall/components/buttons/main_button_transparent.dart';
import 'package:stockall/components/major/desktop_center_container.dart';
import 'package:stockall/components/text_fields/general_textfield.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/main.dart';

class CreateCategoryDesktop extends StatefulWidget {
  const CreateCategoryDesktop({super.key});

  @override
  State<CreateCategoryDesktop> createState() =>
      _CreateCategoryDesktopState();
}

class _CreateCategoryDesktopState
    extends State<CreateCategoryDesktop> {
  TextEditingController controller =
      TextEditingController();
  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return GestureDetector(
      onTap:
          () =>
              FocusManager.instance.primaryFocus?.unfocus(),
      child: DesktopCenterContainer(
        mainWidget: Scaffold(
          appBar: appBar(
            context: context,
            title: 'Create New Category',
          ),
          body: Column(
            children: [
              // TopBanner(
              //   subTitle: 'Create new category',
              //   title: 'Category',
              //   theme: theme,
              //   bottomSpace: 40,
              //   topSpace: 30,
              //   isMain: true,
              //   iconData: Icons.book_outlined,
              // ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30.0,
                ),
                child: Column(
                  children: [
                    SizedBox(height: 30),
                    GeneralTextField(
                      title: 'Add Category',
                      hint: 'Enter Catery name',
                      controller: controller,
                      lines: 1,
                      theme: theme,
                    ),
                    SizedBox(height: 20),
                    MainButtonP(
                      themeProvider: theme,
                      text: 'Create New Category',
                      action: () {
                        final safeContext = context;
                        if (controller.text.isNotEmpty) {
                          showDialog(
                            context: safeContext,
                            builder: (context) {
                              return ConfirmationAlert(
                                theme: theme,
                                message:
                                    'Are you sure you want to save category?',
                                title: 'Proceed?',
                                action: () async {
                                  await returnShopProvider(
                                    context,
                                    listen: false,
                                  ).appendShopCategories(
                                    shopId:
                                        returnShopProvider(
                                          context,
                                          listen: false,
                                        ).userShop!.shopId!,
                                    newCategories: [
                                      controller.text
                                          .trim(),
                                    ],
                                  );
                                  returnData(
                                    context,
                                    listen: false,
                                  ).selectCategory(
                                    controller.text,
                                  );

                                  await Future.delayed(
                                    Duration(
                                      milliseconds: 200,
                                    ),
                                    () {
                                      if (context.mounted) {
                                        // First pop closes the dialog
                                        Navigator.of(
                                          context,
                                        ).pop();

                                        // Second pop navigates back to the previous screen
                                        Navigator.of(
                                          context,
                                        ).maybePop();
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Category Added Successfully',
                                            ),
                                          ),
                                        ); // or pushReplacement if needed
                                      }
                                    },
                                  );
                                },
                              );
                            },
                          );
                        } else {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return InfoAlert(
                                theme: theme,
                                message:
                                    'Category Field Cannot be empty.',
                                title: 'Empty Field',
                              );
                            },
                          );
                        }
                      },
                    ),
                    SizedBox(height: 10),
                    MainButtonTransparent(
                      themeProvider: theme,
                      constraints: BoxConstraints(),
                      text: 'Cancel',
                      action: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
