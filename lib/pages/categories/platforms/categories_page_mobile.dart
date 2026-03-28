import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_categories/category_class.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/alert_dialogues/dialog_template.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/components/major/empty_widget_display_only.dart';
import 'package:stockall/components/text_fields/general_textfield.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/subscription/items_auth.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/categories/components/category_list_tile_widget.dart';

class CategoriesPageMobile extends StatefulWidget {
  const CategoriesPageMobile({super.key});

  @override
  State<CategoriesPageMobile> createState() =>
      _CategoriesPageMobileState();
}

class _CategoriesPageMobileState
    extends State<CategoriesPageMobile> {
  final nameController = TextEditingController();
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Scaffold(
      appBar: appBar(
        context: context,
        title: 'Categories',
        backAction: () {
          Navigator.of(context).pop();
        },
        widget: Padding(
          padding: const EdgeInsets.only(right: 10.0),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                ItemsAuthAction().applyVariationsAction(
                  context: context,
                  action: () {
                    showDialog(
                      context: context,
                      builder: (confirmDialog) {
                        return StatefulBuilder(
                          builder: (context, setState) {
                            return DialogTemplate(
                              theme: theme,
                              message:
                                  'Enter Category Name',
                              title: 'Create Category',
                              action: () async {
                                if (!isLoading) {
                                  if (nameController
                                      .text
                                      .isEmpty) {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return InfoAlert(
                                          theme: theme,
                                          message:
                                              'Category Name Cannot be empty. Please enter Category name and try again.',
                                          title:
                                              'Category Name Empty',
                                        );
                                      },
                                    );
                                  } else {
                                    showDialog(
                                      context: context,
                                      builder: (
                                        mainDialog,
                                      ) {
                                        return ConfirmationAlert(
                                          theme: theme,
                                          message:
                                              'Are you sure you want to proceed?',
                                          title:
                                              'Proceed with action?',
                                          action: () async {
                                            Navigator.of(
                                              mainDialog,
                                            ).pop();
                                            setState(() {
                                              isLoading =
                                                  true;
                                            });
                                            var res = await returnCategoriesProvider().addCategory(
                                              category: CategoryClass(
                                                name:
                                                    nameController
                                                        .text
                                                        .trim(),
                                                shopId:
                                                    shopId(),
                                                uuid:
                                                    uuidGen(),
                                                createdAt:
                                                    DateTime.now(),
                                                updatedAt:
                                                    DateTime.now(),
                                                departmentId:
                                                    returnDepartmentProvider()
                                                        .currentDepartment()
                                                        ?.uuid,
                                                departmentName:
                                                    returnDepartmentProvider()
                                                        .currentDepartment()
                                                        ?.name,
                                              ),
                                            );

                                            if (res == 0) {
                                              setState(() {
                                                isLoading =
                                                    false;
                                              });
                                              showDialog(
                                                // ignore: use_build_context_synchronously
                                                context:
                                                    context,
                                                builder: (
                                                  context,
                                                ) {
                                                  return InfoAlert(
                                                    theme:
                                                        theme,
                                                    message:
                                                        'An Error Occoured. Please and try again.',
                                                    title:
                                                        'Failed',
                                                  );
                                                },
                                              );
                                            } else {
                                              Navigator.of(
                                                confirmDialog,
                                              ).pop();
                                            }
                                          },
                                        );
                                      },
                                    );
                                  }
                                }
                              },
                              widget: Stack(
                                alignment:
                                    AlignmentGeometry.xy(
                                      0,
                                      0,
                                    ),
                                children: [
                                  ConstrainedBox(
                                    constraints:
                                        BoxConstraints(
                                          maxWidth: 500,
                                        ),
                                    child: Stack(
                                      alignment:
                                          AlignmentGeometry.xy(
                                            0,
                                            0,
                                          ),
                                      children: [
                                        Container(
                                          color:
                                              const Color.fromARGB(
                                                47,
                                                255,
                                                255,
                                                255,
                                              ),
                                          height: 120,
                                          width: 500,
                                          child: Center(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal:
                                                        30.0,
                                                  ),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .center,
                                                mainAxisSize:
                                                    MainAxisSize
                                                        .min,
                                                spacing: 10,
                                                children: [
                                                  GeneralTextField(
                                                    title:
                                                        'Category Name *',
                                                    hint:
                                                        'Enter Name',
                                                    controller:
                                                        nameController,
                                                    lines:
                                                        1,
                                                    theme:
                                                        theme,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        Visibility(
                                          visible:
                                              isLoading,
                                          child: Container(
                                            height: 120,
                                            width: 300,
                                            decoration:
                                                BoxDecoration(
                                                  color:
                                                      const Color.fromARGB(
                                                        61,
                                                        255,
                                                        255,
                                                        255,
                                                      ),
                                                ),
                                            child: Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ).then((_) {
                      setState(() {
                        isLoading = false;
                      });
                      nameController.clear();
                    });
                  },
                );
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  vertical: 6,
                  horizontal: 15,
                ),
                child: Row(
                  spacing: 5,
                  children: [
                    Text(
                      style:
                          theme
                              .mobileTexts
                              .b3
                              .textStyleBold,
                      "Add",
                    ),
                    Icon(
                      color: Colors.grey,
                      size: 20,
                      Icons.add,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 15.0,
          ),
          child: Column(
            children: [
              SizedBox(height: 20),
              Expanded(
                child: Builder(
                  builder: (context) {
                    if (returnCategoriesProvider()
                        .categories
                        .isEmpty) {
                      return Material(
                        color: Colors.transparent,
                        child: EmptyWidgetDisplayOnly(
                          title: 'No Categories Added',
                          subText:
                              'You have not added any Category.',
                          theme: theme,
                          height: 25,
                          altAction: () {
                            returnCategoriesProvider()
                                .getCategories(shopId());
                          },
                          altActionText: 'Refresh',
                          altIcon: Icons.refresh,
                          icon: Icons.clear,
                        ),
                      );
                    } else {
                      return RefreshIndicator(
                        onRefresh: () {
                          return returnCategoriesProvider()
                              .getCategories(shopId());
                        },
                        backgroundColor: Colors.white,
                        color:
                            theme
                                .lightModeColor
                                .secColor200,
                        displacement: 10,
                        strokeWidth: 2,
                        child: ListView(
                          // shrinkWrap: true,
                          children:
                              returnCategoriesProvider(
                                    context: context,
                                  ).categories
                                  .map(
                                    (category) =>
                                        CategoryListTileWidget(
                                          categoryUuid:
                                              category.uuid,
                                        ),
                                  )
                                  .toList(),
                        ),
                      );
                    }
                  },
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
