import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_user_class.dart';
import 'package:stockall/components/buttons/floating_action_butto.dart';
import 'package:stockall/components/major/empty_widget_display.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/employees/add_employee_page/add_employee_page.dart';
import 'package:stockall/pages/employees/components/employee_tile_main.dart';
import 'package:stockall/pages/employees/employee_page/employee_page.dart';

class EmployeeListMobile extends StatefulWidget {
  const EmployeeListMobile({super.key});

  @override
  State<EmployeeListMobile> createState() =>
      _EmployeeListMobileState();
}

class _EmployeeListMobileState
    extends State<EmployeeListMobile> {
  @override
  void initState() {
    super.initState();

    returnData(
      context,
      listen: false,
    ).toggleFloatingAction(context);
    if (returnUserProvider(
      context,
      listen: false,
    ).usersMain.isEmpty) {
      getEmployees();
    }
  }

  Future<List<TempUserClass>> getEmployees() async {
    var tempEmp =
        await returnUserProvider(
          context,
          listen: false,
        ).fetchUsers();

    return tempEmp;
  }

  @override
  Widget build(BuildContext context) {
    var user = userGeneral(context);
    var theme = returnTheme(context);
    return Scaffold(
      floatingActionButton: Visibility(
        visible: authorization(
          authorized: Authorizations().addEmployee,
          context: context,
        ),
        child: FloatingActionButtonMain(
          theme: theme,
          action: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return AddEmployeePage();
                },
              ),
            ).then((_) {
              if (mounted) {
                setState(() {});
              }
            });
          },
          color:
              returnTheme(
                context,
              ).lightModeColor.prColor300,
          text: 'Add New Employee',
        ),
      ),
      appBar: AppBar(
        toolbarHeight: 60,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Padding(
            padding: const EdgeInsets.only(
              left: 10.0,
              right: 5,
            ),
            child: Icon(Icons.arrow_back_ios_new_rounded),
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
              user.userId! == user.authUserId
                  ? 'Your Employees'
                  : 'My Account',
            ),
          ],
        ),
      ),
      body: Builder(
        builder: (context) {
          List<TempUserClass> employees =
              returnUserProvider(context).usersMain
                  .where(
                    (emp) => emp.authUserId != emp.userId!,
                  )
                  .toList();

          return Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Builder(
              builder: (context) {
                if (employees.isEmpty) {
                  return EmptyWidgetDisplay(
                    title: 'Empty Employee List',
                    subText:
                        'Your Have not Created Any Employee Yet.',
                    buttonText: 'Create Employee',
                    svg: productIconSvg,
                    theme: theme,
                    height: 30,
                    action: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return AddEmployeePage();
                          },
                        ),
                      ).then((_) {
                        setState(() {});
                      });
                    },
                    altAction: () {
                      getEmployees();
                      setState(() {});
                    },
                    altActionText: 'Refresh List',
                    altIcon: Icons.refresh_rounded,
                  );
                } else {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15.0,
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: 10),
                        Expanded(
                          child: RefreshIndicator(
                            onRefresh: () {
                              return getEmployees();
                            },
                            backgroundColor: Colors.white,
                            color:
                                theme
                                    .lightModeColor
                                    .prColor300,
                            displacement: 10,
                            child: ListView.builder(
                              itemCount: employees.length,
                              itemBuilder: (
                                context,
                                index,
                              ) {
                                TempUserClass employee =
                                    employees[index];

                                return EmployeeTileMain(
                                  action: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return EmployeePage(
                                            employeeId:
                                                employee
                                                    .userId!,
                                          );
                                        },
                                      ),
                                    ).then((_) {
                                      setState(() {});
                                    });
                                  },
                                  employee: employee,
                                  theme: theme,
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          );
        },
      ),
    );
  }
}
