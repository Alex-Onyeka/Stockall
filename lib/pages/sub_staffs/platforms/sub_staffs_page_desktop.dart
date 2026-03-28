import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_sub_staff/temp_sub_staff.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/alert_dialogues/dialog_template.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/components/major/desktop_center_container.dart';
import 'package:stockall/components/major/empty_widget_display_only.dart';
import 'package:stockall/components/text_fields/general_textfield.dart';
import 'package:stockall/components/text_fields/phone_number_text_field.dart';
import 'package:stockall/constants/subscription/sales_auth.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/sub_staffs/components/sub_staff_list_tile_widget.dart';

class SubStaffsPageDesktop extends StatefulWidget {
  const SubStaffsPageDesktop({super.key});

  @override
  State<SubStaffsPageDesktop> createState() =>
      _SubStaffsPageDesktopState();
}

class _SubStaffsPageDesktopState
    extends State<SubStaffsPageDesktop> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return DesktopCenterContainer(
      mainWidget: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          SizedBox(height: 5),
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 20,
                    ),
                    child: Icon(
                      color: Colors.grey,
                      size: 20,
                      Icons.arrow_back_ios_new_rounded,
                    ),
                  ),
                ),
              ),
              Opacity(
                opacity: 0,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      returnSubStaffProvider()
                          .getSubStaffs();
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 15,
                      ),
                      child: Row(
                        spacing: 5,
                        children: [
                          Icon(
                            color: Colors.grey,
                            size: 18,
                            Icons.refresh,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Column(
                spacing: 8,
                children: [
                  Text(
                    style: TextStyle(
                      color:
                          theme
                              .lightModeColor
                              .shadesColorBlack,
                      fontSize:
                          theme.mobileTexts.h3.fontSize,
                      fontWeight:
                          theme
                              .mobileTexts
                              .h3
                              .fontWeightBold,
                    ),
                    'Sub Staffs',
                  ),
                  Text(
                    style:
                        theme
                            .mobileTexts
                            .b1
                            .textStyleNormal,
                    "Manage Your Sub Staffs",
                  ),
                ],
              ),
              Row(
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        returnSubStaffProvider()
                            .getSubStaffs();
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 15,
                        ),
                        child: Row(
                          spacing: 5,
                          children: [
                            Icon(
                              color: Colors.grey,
                              size: 18,
                              Icons.refresh,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        SalesAuthAction().allowBulkSaleAction(
                          context: context,
                          action: () {
                            showDialog(
                              context: context,
                              builder: (confirmDialog) {
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
                                          'Create Sub Staff',
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
                                                    setState(() {
                                                      isLoading =
                                                          true;
                                                    });
                                                    var subStaff = TempSubStaff(
                                                      departmentName:
                                                          returnDepartmentProvider().currentDepartment()?.name,
                                                      departmentUuid:
                                                          returnDepartmentProvider().currentDepartment()?.uuid,
                                                      phone:
                                                          phoneController.text.trim(),
                                                      createdAt:
                                                          DateTime.now(),
                                                      shopId:
                                                          shopId(),
                                                      staffName:
                                                          nameController.text.trim(),
                                                    );
                                                    var res =
                                                        await returnSubStaffProvider().createSubStaff(
                                                          subStaff,
                                                        );

                                                    if (res ==
                                                        0) {
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
                                                  color:
                                                      const Color.fromARGB(
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
                ],
              ),
            ],
          ),
          SizedBox(height: 30),
          Expanded(
            child: Builder(
              builder: (context) {
                if (returnSubStaffProvider(
                  context: context,
                ).subStaffs.isEmpty) {
                  return Material(
                    color: Colors.transparent,
                    child: EmptyWidgetDisplayOnly(
                      title: 'No Staffs Added',
                      subText:
                          'You have not added any Sub Staff.',
                      theme: theme,
                      height: 25,
                      altAction: () {
                        returnSubStaffProvider()
                            .getSubStaffs();
                      },
                      altActionText: 'Refresh',
                      altIcon: Icons.refresh,
                      icon: Icons.clear,
                    ),
                  );
                } else {
                  return RefreshIndicator(
                    onRefresh: () {
                      return returnSubStaffProvider()
                          .getSubStaffs();
                    },
                    backgroundColor: Colors.white,
                    color: theme.lightModeColor.secColor200,
                    displacement: 10,
                    strokeWidth: 2,
                    child: ListView(
                      // shrinkWrap: true,
                      children:
                          returnSubStaffProvider(
                                context: context,
                              ).subStaffs
                              .map(
                                (staff) =>
                                    SubStaffListTileWidget(
                                      staff: staff,
                                    ),
                              )
                              .toList(),
                    ),
                  );
                }
              },
            ),
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}
