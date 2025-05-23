import 'package:flutter/material.dart';
import 'package:stockitt/classes/temp_user_class.dart';
import 'package:stockitt/providers/theme_provider.dart';

class EmployeeTileMain extends StatelessWidget {
  const EmployeeTileMain({
    super.key,
    required this.employee,
    required this.theme,
    required this.action,
  });

  final TempUserClass employee;
  final Function() action;
  final ThemeProvider theme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7.0),
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(5),
          onTap: action,
          child: SizedBox(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 15.0,
                vertical: 15,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        spacing: 15,
                        children: [
                          Container(
                            height: 40,
                            width: 40,
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey.shade100,
                            ),
                            child: Center(
                              child: Text(
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight:
                                      FontWeight.bold,
                                  height: 1,
                                  color: Colors.black,
                                ),
                                employee
                                    .name
                                    .characters
                                    .first
                                    .toUpperCase(),
                              ),
                            ),
                          ),
                          Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                style: TextStyle(
                                  fontSize:
                                      theme
                                          .mobileTexts
                                          .b2
                                          .fontSize,
                                  fontWeight:
                                      FontWeight.bold,
                                ),

                                employee.name,
                              ),
                              Text(
                                style: TextStyle(
                                  color:
                                      theme
                                          .lightModeColor
                                          .secColor200,
                                  fontWeight:
                                      FontWeight.normal,
                                  fontSize:
                                      theme
                                          .mobileTexts
                                          .b3
                                          .fontSize,
                                ),
                                employee.email,
                              ),
                            ],
                          ),
                        ],
                      ),
                      Icon(
                        size: 20,
                        color: Colors.grey,
                        Icons.arrow_forward_ios_rounded,
                      ),
                    ],
                  ),
                  Divider(
                    height: 25,
                    color: Colors.grey.shade200,
                  ),
                  Row(
                    spacing: 10,
                    children: [
                      Text(
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize:
                              theme.mobileTexts.b3.fontSize,
                        ),
                        'Role:',
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 2,
                          horizontal: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                        ),
                        child: Text(
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize:
                                theme
                                    .mobileTexts
                                    .b3
                                    .fontSize,
                          ),
                          employee.role,
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
    );
  }
}
