import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stockitt/classes/temp_employee_class.dart';
import 'package:stockitt/components/buttons/floating_action_butto.dart';
import 'package:stockitt/components/major/empty_widget_display.dart';
import 'package:stockitt/constants/constants_main.dart';
import 'package:stockitt/main.dart';
import 'package:stockitt/pages/employees/add_employee_page/add_employee_page.dart';
import 'package:stockitt/pages/employees/components/employee_tile_main.dart';
import 'package:stockitt/providers/employee_provider.dart';

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
  }

  @override
  Widget build(BuildContext context) {
    final employeeProvider = Provider.of<EmployeeProvider>(
      context,
    );
    var theme = returnTheme(context);
    return Scaffold(
      floatingActionButton: FloatingActionButtonMain(
        theme: theme,
        action: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return AddEmployeePage();
              },
            ),
          );
        },
        color:
            returnTheme(context).lightModeColor.prColor300,
        text: 'Add New Employee',
      ),
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
              'Your Employees',
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: Builder(
          builder: (context) {
            if (employeeProvider.employeeList.isEmpty) {
              return EmptyWidgetDisplay(
                title: 'Empty Employee List',
                subText:
                    'Your Have not Created Any Employee Yet.',
                buttonText: 'Create Employee',
                svg: productIconSvg,
                theme: theme,
                height: 35,
                action: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return AddEmployeePage();
                      },
                    ),
                  );
                },
              );
            } else {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30.0,
                ),
                child: Column(
                  children: [
                    SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        itemCount:
                            employeeProvider
                                .employeeList
                                .length,
                        itemBuilder: (context, index) {
                          List<TempEmployeeClass>
                          employees =
                              employeeProvider.employeeList;
                          TempEmployeeClass employee =
                              employees[index];

                          return EmployeeTileMain(
                            employee: employee,
                            theme: theme,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
