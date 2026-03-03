import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_sub_staff/temp_sub_staff.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/alert_dialogues/dialog_template.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/components/text_fields/general_textfield.dart';
import 'package:stockall/components/text_fields/phone_number_text_field.dart';
import 'package:stockall/constants/subscription/sales_auth.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/sales/total_sales/total_sales_page.dart';

class SubStaffListTileWidget extends StatefulWidget {
  final TempSubStaff staff;
  const SubStaffListTileWidget({
    super.key,
    required this.staff,
  });

  @override
  State<SubStaffListTileWidget> createState() =>
      _SubStaffListTileWidgetState();
}

class _SubStaffListTileWidgetState
    extends State<SubStaffListTileWidget> {
  bool isLoading = false;
  bool isDeleteLoading = false;
  TextEditingController nameController =
      TextEditingController();
  TextEditingController phoneController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(10, 0, 0, 0),
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
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return TotalSalesPage(
                        subStaffId: widget.staff.uuid,
                      );
                    },
                  ),
                );
              },
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
                            Icons.person,
                          ),
                          Flexible(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
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
                                  widget.staff.staffName ??
                                      'Staff Name',
                                ),
                                Visibility(
                                  visible:
                                      widget.staff.phone !=
                                          null &&
                                      widget
                                          .staff
                                          .phone!
                                          .isNotEmpty,
                                  child: Text(
                                    style: TextStyle(
                                      fontSize:
                                          theme
                                              .mobileTexts
                                              .b4
                                              .fontSize,
                                      fontWeight:
                                          FontWeight.normal,
                                      color: Colors.grey,
                                    ),
                                    widget.staff.phone ??
                                        'Staff Phone',
                                  ),
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
                                child:
                                    CircularProgressIndicator(
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
                                              'You are about to delete this Sub Staff, Are you sure you want to proceed?',
                                          title:
                                              'Delete Staff',
                                          action: () async {
                                            Navigator.of(
                                              mainDialog,
                                            ).pop();
                                            setState(() {
                                              isDeleteLoading =
                                                  true;
                                            });
                                            var res = await returnSubStaffProvider()
                                                .deleteSubStaff(
                                                  widget
                                                      .staff,
                                                );

                                            if (res == 0) {
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
                          type: MaterialType.transparency,
                          child: InkWell(
                            borderRadius:
                                BorderRadius.circular(10),
                            onTap: () {
                              SalesAuthAction().allowBulkSaleAction(
                                context: context,
                                action: () {
                                  nameController.text =
                                      widget
                                          .staff
                                          .staffName ??
                                      '';
                                  phoneController.text =
                                      widget.staff.phone ??
                                      '';
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
                                            theme: theme,
                                            message:
                                                'Enter Sub Staff Details',
                                            title:
                                                'Edit Sub Staff',
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
                                                            'Staff Name Cannot be empty. Please enter staff name and try again.',
                                                        title:
                                                            'Staff Name Empty',
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
                                                          var subStaff = TempSubStaff(
                                                            phone:
                                                                phoneController.text.trim(),
                                                            createdAt:
                                                                DateTime.now(),
                                                            shopId:
                                                                widget.staff.shopId,
                                                            staffName:
                                                                nameController.text.trim(),
                                                            uuid:
                                                                widget.staff.uuid,
                                                            departmentName:
                                                                widget.staff.departmentName,
                                                            departmentUuid:
                                                                widget.staff.departmentUuid,
                                                          );
                                                          var res = await returnSubStaffProvider().updateSubStaff(
                                                            subStaff,
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
                                                    alignment:
                                                        AlignmentGeometry.xy(
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
                                                            250,
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
                                                                      'Staff Name *',
                                                                  hint:
                                                                      'Enter Name',
                                                                  controller:
                                                                      nameController,
                                                                  lines:
                                                                      1,
                                                                  theme:
                                                                      theme,
                                                                ),
                                                                PhoneNumberTextField(
                                                                  controller:
                                                                      phoneController,
                                                                  theme:
                                                                      theme,
                                                                  title:
                                                                      'Phone Number (Optional)',
                                                                  hint:
                                                                      'Enter Phone',
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
                                                              200,
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
                                    nameController.clear();
                                    phoneController.clear();
                                  });
                                },
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(
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
    );
  }
}
