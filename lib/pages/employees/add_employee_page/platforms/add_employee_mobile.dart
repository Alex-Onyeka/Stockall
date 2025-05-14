import 'package:flutter/material.dart';
import 'package:stockitt/classes/temp_employee_class.dart';
import 'package:stockitt/components/buttons/main_button_p.dart';
import 'package:stockitt/components/text_fields/general_textfield.dart';
import 'package:stockitt/components/text_fields/phone_number_text_field.dart';
import 'package:stockitt/main.dart';

class AddEmployeeMobile extends StatefulWidget {
  final TempEmployeeClass? employee;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController addressController;
  final TextEditingController countryController;
  final TextEditingController cityController;
  final TextEditingController stateController;

  const AddEmployeeMobile({
    super.key,
    required this.nameController,
    required this.phoneController,
    required this.addressController,
    required this.countryController,
    required this.cityController,
    required this.stateController,
    this.employee,
  });

  @override
  State<AddEmployeeMobile> createState() =>
      _AddEmployeeMobileState();
}

class _AddEmployeeMobileState
    extends State<AddEmployeeMobile> {
  //
  //
  //

  bool isExtra = false;

  //
  //
  @override
  void initState() {
    super.initState();
    if (widget.employee == null) {
      return;
    } else {
      setState(() {
        isExtra = true;
      });
      widget.nameController.text =
          widget.employee!.employeeName;
      widget.phoneController.text =
          widget.employee!.phoneNumber ?? '';
      if (widget.employee!.address != null) {
        widget.addressController.text =
            widget.employee!.address!;
      }
      if (widget.employee!.country != null) {
        widget.countryController.text =
            widget.employee!.country!;
      }

      if (widget.employee!.city != null) {
        widget.cityController.text = widget.employee!.city!;
      }
      if (widget.employee!.state != null) {
        widget.stateController.text =
            widget.employee!.state!;
      }
    }
  }

  //
  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            toolbarHeight: 60,
            leading: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Padding(
                padding: const EdgeInsets.only(
                  left: 20.0,
                  right: 10,
                ),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                ),
              ),
            ),
            centerTitle: true,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  style: TextStyle(
                    fontSize: theme.mobileTexts.h4.fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                  widget.employee != null
                      ? 'Edit Employee Info'
                      : 'Add New Employee',
                ),
              ],
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 25.0,
            ),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        GeneralTextField(
                          title: 'Name',
                          hint: 'Enter employees\' Name',
                          controller: widget.nameController,
                          lines: 1,
                          theme: theme,
                        ),
                        SizedBox(height: 15),
                        PhoneNumberTextField(
                          title: 'Phone Number',
                          hint:
                              'Enter employees\' Phone Numer',
                          controller:
                              widget.phoneController,
                          theme: theme,
                        ),
                        SizedBox(height: 20),
                        Row(
                          spacing: 5,
                          children: [
                            Icon(
                              size: 17,
                              color:
                                  theme
                                      .lightModeColor
                                      .secColor100,
                              Icons.warning_rounded,
                            ),
                            Text(
                              style: TextStyle(
                                fontSize: 12,
                              ),
                              'The fields below are optional.',
                            ),
                          ],
                        ),
                        SizedBox(height: 15),
                        InkWell(
                          onTap: () {
                            setState(() {
                              isExtra = !isExtra;
                            });
                          },
                          child: Row(
                            crossAxisAlignment:
                                CrossAxisAlignment.center,
                            mainAxisAlignment:
                                MainAxisAlignment
                                    .spaceBetween,
                            spacing: 5,
                            children: [
                              Text(
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                                isExtra
                                    ? 'Colapse'
                                    : 'Expand',
                              ),
                              Icon(
                                size: 35,
                                color: Colors.grey,
                                isExtra
                                    ? Icons
                                        .keyboard_arrow_up_rounded
                                    : Icons
                                        .keyboard_arrow_down_rounded,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),
                        Visibility(
                          visible: isExtra,
                          child: Column(
                            children: [
                              GeneralTextField(
                                title: 'Country',
                                hint:
                                    'Enter Country (Nigeria)',
                                controller:
                                    widget
                                        .countryController,
                                lines: 1,
                                theme: theme,
                              ),
                              SizedBox(height: 15),
                              GeneralTextField(
                                title: 'State',
                                hint: 'Enter State (Abuja)',
                                controller:
                                    widget.stateController,
                                lines: 1,
                                theme: theme,
                              ),
                              SizedBox(height: 15),
                              GeneralTextField(
                                title: 'City',
                                hint: 'Enter City (Wuse)',
                                controller:
                                    widget.cityController,
                                lines: 1,
                                theme: theme,
                              ),
                              SizedBox(height: 15),
                              GeneralTextField(
                                title: 'Address',
                                hint:
                                    'Enter Address (32 close, behind school gate.)',
                                controller:
                                    widget
                                        .addressController,
                                lines: 1,
                                theme: theme,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 15),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                MainButtonP(
                  themeProvider: theme,
                  action: () {
                    returnValidate(
                      context,
                      listen: false,
                    ).checkInputs(
                      conditionsThree: false,
                      conditionsFour: false,
                      conditionsSecond: false,
                      conditionsFirst:
                          widget
                              .nameController
                              .text
                              .isEmpty ||
                          widget
                              .phoneController
                              .text
                              .isEmpty,
                      context: context,
                      action: () {
                        // if (widget.employee == null) {
                        //   returnEmployeesPro(
                        //     context,
                        //     listen: false,
                        //   ).addemployee(
                        //     TempemployeesClass(
                        //       shopId:
                        //           currentShop(
                        //             context,
                        //           ).shopId,
                        //       country:
                        //           widget
                        //               .countryController
                        //               .text,
                        //       dateAdded: DateTime.now(),
                        //       id:
                        //           returnemployees(
                        //             context,
                        //             listen: false,
                        //           ).employees.length +
                        //           1,
                        //       name:
                        //           widget
                        //               .nameController
                        //               .text,
                        //       email:
                        //           widget
                        //               .emailController
                        //               .text,
                        //       phone:
                        //           widget
                        //               .phoneController
                        //               .text,
                        //       address:
                        //           widget
                        //               .addressController
                        //               .text,
                        //       city:
                        //           widget
                        //               .cityController
                        //               .text,
                        //       state:
                        //           widget
                        //               .stateController
                        //               .text,
                        //     ),
                        //   );
                        // } else {
                        //   returnemployees(
                        //     context,
                        //     listen: false,
                        //   ).updateemployee(
                        //     mainemployee: widget.employee!,
                        //     setteremployee:
                        //         TempemployeesClass(
                        //           shopId:
                        //               currentShop(
                        //                 context,
                        //               ).shopId,
                        //           id:
                        //               returnemployees(
                        //                 context,
                        //                 listen: false,
                        //               ).getId(),
                        //           name:
                        //               widget
                        //                   .nameController
                        //                   .text,
                        //           email:
                        //               widget
                        //                   .emailController
                        //                   .text,
                        //           phone:
                        //               widget
                        //                   .phoneController
                        //                   .text,
                        //           address:
                        //               widget
                        //                   .addressController
                        //                   .text,
                        //           city:
                        //               widget
                        //                   .cityController
                        //                   .text,
                        //           state:
                        //               widget
                        //                   .stateController
                        //                   .text,
                        //           dateAdded:
                        //               widget
                        //                   .employee!
                        //                   .dateAdded,
                        //         ),
                        //   );
                        // }
                        returnCompProvider(
                          context,
                          listen: false,
                        ).successAction(
                          () => Navigator.of(context).pop(),
                        );
                      },
                    );
                  },
                  text:
                      widget.employee != null
                          ? 'Update Details'
                          : 'Add Employee',
                ),
              ],
            ),
          ),
        ),
        Visibility(
          visible: returnCompProvider(context).isLoaderOn,
          child: returnCompProvider(
            context,
            listen: false,
          ).showSuccess(
            widget.employee != null
                ? 'employee Updated Successfully'
                : 'employee Added Successfully',
          ),
        ),
      ],
    );
  }
}
