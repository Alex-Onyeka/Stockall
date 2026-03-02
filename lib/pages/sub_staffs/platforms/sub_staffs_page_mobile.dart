import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_sub_staff/temp_sub_staff.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/alert_dialogues/dialog_template.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/components/major/empty_widget_display_only.dart';
import 'package:stockall/components/text_fields/general_textfield.dart';
import 'package:stockall/components/text_fields/phone_number_text_field.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/constants/subscription/sales_auth.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/sub_staffs/platforms/sub_staffs_page_desktop.dart';

class SubStaffsPageMobile extends StatefulWidget {
  const SubStaffsPageMobile({super.key});

  @override
  State<SubStaffsPageMobile> createState() =>
      _SubStaffsPageMobileState();
}

class _SubStaffsPageMobileState
    extends State<SubStaffsPageMobile> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Scaffold(
      appBar: appBar(
        context: context,
        title: 'Sub Staffs',
        backAction: () {
          Navigator.of(context).pop();
        },
        widget: Padding(
          padding: const EdgeInsets.only(right: 10.0),
          child: Material(
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
                          builder: (context, setState) {
                            return DialogTemplate(
                              theme: theme,
                              message:
                                  'Enter Sub Staff Details',
                              title: 'Create Sub Staff',
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
                                              'Staff Name Cannot be empty. Please enter staff name and try again.',
                                          title:
                                              'Staff Name Empty',
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
                                            var subStaff = TempSubStaff(
                                              phone:
                                                  phoneController
                                                      .text
                                                      .trim(),
                                              createdAt:
                                                  DateTime.now(),
                                              shopId:
                                                  shopId(),
                                              staffName:
                                                  nameController
                                                      .text
                                                      .trim(),
                                            );
                                            var res = await returnSubStaffProvider()
                                                .createSubStaff(
                                                  subStaff,
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
                                          height: 250,
                                          width: 500,
                                          child: Center(
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
                                                      'Staff Name *',
                                                  hint:
                                                      'Enter Name',
                                                  controller:
                                                      nameController,
                                                  lines: 1,
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
                                        Visibility(
                                          visible:
                                              isLoading,
                                          child: Container(
                                            height: 200,
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
                      return ListView(
                        shrinkWrap: true,
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
