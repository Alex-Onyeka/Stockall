import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_categories/category_class.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/alert_dialogues/dialog_template.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/components/text_fields/general_textfield.dart';
import 'package:stockall/constants/subscription/items_auth.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/products/total_products/total_products_page.dart';

class CategoryListTileWidget extends StatefulWidget {
  final String categoryUuid;
  const CategoryListTileWidget({
    super.key,
    required this.categoryUuid,
  });

  @override
  State<CategoryListTileWidget> createState() =>
      _CategoryListTileWidgetState();
}

class _CategoryListTileWidgetState
    extends State<CategoryListTileWidget> {
  bool isLoading = false;
  bool isDeleteLoading = false;
  TextEditingController nameController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    CategoryClass category =
        returnCategoriesProvider(context: context)
                .categories()
                .where(
                  (cat) => cat.uuid == widget.categoryUuid,
                )
                .isNotEmpty
            ? returnCategoriesProvider(context: context)
                .categories()
                .where(
                  (cat) => cat.uuid == widget.categoryUuid,
                )
                .first
            : CategoryClass(
              name: 'Category Name',
              shopId: shopId(),
              uuid: 'uuid',
              departmentId:
                  returnDepartmentProvider()
                      .currentDepartment()
                      ?.uuid,
              departmentName:
                  returnDepartmentProvider()
                      .currentDepartment()
                      ?.name,
            );
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
          // boxShadow: [
          //   BoxShadow(
          //     color: const Color.fromARGB(10, 0, 0, 0),
          //     blurRadius: 10,
          //     spreadRadius: 5,
          //   ),
          // ],
        ),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return TotalProductsPage(
                    categoryUuid: widget.categoryUuid,
                    theme: theme,
                  );
                },
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 5,
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                // color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(
                      10,
                      0,
                      0,
                      0,
                    ),
                    blurRadius: 10,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: Ink(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                  ),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 10,
                    ),

                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            spacing: 10,
                            children: [
                              Icon(
                                size: 18,
                                color:
                                    theme
                                        .lightModeColor
                                        .secColor200,
                                Icons.category_outlined,
                              ),
                              Flexible(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                  spacing: 2,
                                  children: [
                                    Text(
                                      style: TextStyle(
                                        fontSize:
                                            theme
                                                .mobileTexts
                                                .b3
                                                .fontSize,
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                      category.name,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          spacing: 2,
                          children: [
                            Builder(
                              builder: (context) {
                                if (isDeleteLoading) {
                                  return SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color:
                                          theme
                                              .lightModeColor
                                              .secColor200,
                                    ),
                                  );
                                } else {
                                  return Material(
                                    type:
                                        MaterialType
                                            .transparency,
                                    child: InkWell(
                                      borderRadius:
                                          BorderRadius.circular(
                                            10,
                                          ),
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (
                                            mainDialog,
                                          ) {
                                            return ConfirmationAlert(
                                              theme: theme,
                                              message:
                                                  'You are about to delete this Category, Are you sure you want to proceed?',
                                              title:
                                                  'Delete Category',
                                              action: () async {
                                                Navigator.of(
                                                  mainDialog,
                                                ).pop();
                                                setState(() {
                                                  isDeleteLoading =
                                                      true;
                                                });
                                                var res = await returnCategoriesProvider()
                                                    .deleteCategory(
                                                      category:
                                                          category,
                                                    );

                                                if (res ==
                                                    0) {
                                                  setState(() {
                                                    isDeleteLoading =
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
                                                  setState(() {
                                                    isDeleteLoading =
                                                        false;
                                                  });
                                                }
                                              },
                                            );
                                          },
                                        );
                                      },
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.all(
                                              12.0,
                                            ),
                                        child: Icon(
                                          size: 20,
                                          color:
                                              Colors
                                                  .red
                                                  .shade400,
                                          Icons
                                              .delete_outline_rounded,
                                        ),
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                            Material(
                              type:
                                  MaterialType.transparency,
                              child: InkWell(
                                borderRadius:
                                    BorderRadius.circular(
                                      10,
                                    ),
                                onTap: () {
                                  ItemsAuthAction().applyVariationsAction(
                                    context: context,
                                    action: () {
                                      nameController.text =
                                          category.name;
                                      print("Init");
                                      showDialog(
                                        context: context,
                                        builder: (
                                          confirmDialog,
                                        ) {
                                          return StatefulBuilder(
                                            builder: (
                                              context,
                                              setState,
                                            ) {
                                              return DialogTemplate(
                                                theme:
                                                    theme,
                                                message:
                                                    'Enter Category Name',
                                                title:
                                                    'Edit Category',
                                                action: () async {
                                                  if (!isLoading) {
                                                    if (nameController
                                                        .text
                                                        .isEmpty) {
                                                      showDialog(
                                                        context:
                                                            context,
                                                        builder: (
                                                          context,
                                                        ) {
                                                          return InfoAlert(
                                                            theme:
                                                                theme,
                                                            message:
                                                                'Category Name Cannot be empty. Please enter Category name and try again.',
                                                            title:
                                                                'Category Name Empty',
                                                          );
                                                        },
                                                      );
                                                    } else {
                                                      showDialog(
                                                        context:
                                                            context,
                                                        builder: (
                                                          mainDialog,
                                                        ) {
                                                          return ConfirmationAlert(
                                                            theme:
                                                                theme,
                                                            message:
                                                                'Are you sure you want to proceed?',
                                                            title:
                                                                'Proceed with action?',
                                                            action: () async {
                                                              Navigator.of(
                                                                mainDialog,
                                                              ).pop();
                                                              setState(
                                                                () {
                                                                  isLoading =
                                                                      true;
                                                                },
                                                              );
                                                              var categoryUpdate = CategoryClass(
                                                                createdAt:
                                                                    DateTime.now(),
                                                                shopId:
                                                                    category.shopId,
                                                                name:
                                                                    nameController.text.trim(),
                                                                uuid:
                                                                    category.uuid,
                                                                updatedAt:
                                                                    DateTime.now(),
                                                                departmentId:
                                                                    category.departmentId,
                                                                departmentName:
                                                                    category.departmentName,
                                                              );
                                                              var res = await returnCategoriesProvider().updateCategory(
                                                                categoryUpdate,
                                                              );

                                                              if (res ==
                                                                  0) {
                                                                setState(
                                                                  () {
                                                                    isLoading =
                                                                        false;
                                                                  },
                                                                );
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
                                                      constraints: BoxConstraints(
                                                        maxWidth:
                                                            500,
                                                      ),
                                                      child: Stack(
                                                        alignment: AlignmentGeometry.xy(
                                                          0,
                                                          0,
                                                        ),
                                                        children: [
                                                          Container(
                                                            color: const Color.fromARGB(
                                                              47,
                                                              255,
                                                              255,
                                                              255,
                                                            ),
                                                            height:
                                                                120,
                                                            width:
                                                                500,
                                                            child: Center(
                                                              child: Padding(
                                                                padding: const EdgeInsets.symmetric(
                                                                  horizontal:
                                                                      30.0,
                                                                ),
                                                                child: Column(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment.center,
                                                                  mainAxisSize:
                                                                      MainAxisSize.min,
                                                                  spacing:
                                                                      10,
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
                                                              height:
                                                                  120,
                                                              width:
                                                                  300,
                                                              decoration: BoxDecoration(
                                                                color: const Color.fromARGB(
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
                                        nameController
                                            .clear();
                                      });
                                    },
                                  );
                                },
                                child: Padding(
                                  padding:
                                      const EdgeInsets.all(
                                        12.0,
                                      ),
                                  child: Icon(
                                    size: 18,
                                    color: Colors.grey,
                                    Icons.edit,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
