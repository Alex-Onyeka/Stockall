import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stockitt/classes/temp_employee_class.dart';
import 'package:stockitt/classes/temp_main_receipt.dart';
import 'package:stockitt/components/major/top_banner.dart';
import 'package:stockitt/constants/calculations.dart';
import 'package:stockitt/constants/constants_main.dart';
import 'package:stockitt/main.dart';
import 'package:stockitt/pages/employees/add_employee_page/add_employee_page.dart';
import 'package:stockitt/pages/products/compnents/receipt_tile_main.dart';
import 'package:stockitt/providers/theme_provider.dart';

class EmployeePageMobile extends StatelessWidget {
  final String employeeId;
  const EmployeePageMobile({
    super.key,
    required this.employeeId,
  });

  @override
  Widget build(BuildContext context) {
    var employee = returnEmployeeProvider(
      context,
    ).returnEmployee(employeeId);
    var theme = returnTheme(context);
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            SizedBox(
              height:
                  MediaQuery.of(context).size.height - 50,
              child: Stack(
                alignment: Alignment(0, 1),
                children: [
                  Align(
                    alignment: Alignment(0, -1),
                    child: TopBanner(
                      isMain: false,
                      subTitle:
                          'Full Details about employee',
                      title: 'Employee Details',
                      theme: theme,
                      bottomSpace: 100,
                      topSpace: 30,
                      iconData: Icons.person,
                    ),
                  ),
                  Positioned(
                    top: 110,
                    child: DetailsPageContainer(
                      theme: theme,
                      employee: employee,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DetailsPageContainer extends StatelessWidget {
  final ThemeProvider theme;
  final TempEmployeeClass employee;
  const DetailsPageContainer({
    super.key,
    required this.theme,
    required this.employee,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width - 40,
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(32, 0, 0, 0),
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Row(
                spacing: 10,
                children: [
                  Container(
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey.shade200,
                    ),
                    child: SvgPicture.asset(
                      customersIconSvg,
                    ),
                  ),
                  Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 160,
                        child: Text(
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize:
                                theme
                                    .mobileTexts
                                    .b1
                                    .fontSize,
                          ),
                          employee.employeeName,
                        ),
                      ),
                      SizedBox(
                        width: 160,
                        child: Text(
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize:
                                theme
                                    .mobileTexts
                                    .b3
                                    .fontSize,
                          ),
                          employee.email ?? '',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: Colors.grey.shade300,
                  ),
                ),
                child: Center(
                  child: Text(
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize:
                          theme.mobileTexts.b3.fontSize,
                      color:
                          theme.lightModeColor.secColor200,
                    ),
                    'Employee',
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 20,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                color: Colors.grey.shade200,
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TabBarTabButton(
                        index: 0,
                        text: 'Basic Information',
                        theme: theme,
                      ),
                    ),
                    Expanded(
                      child: TabBarTabButton(
                        index: 1,
                        text: 'Purchases',
                        theme: theme,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Visibility(
                  visible:
                      returnCompProvider(
                        context,
                      ).activeTab ==
                      0,
                  child: EmployeeDetailsContainer(
                    employee: employee,
                    theme: theme,
                  ),
                ),
                Visibility(
                  visible:
                      returnCompProvider(
                        context,
                      ).activeTab ==
                      1,
                  child: SizedBox(
                    height:
                        MediaQuery.of(context).size.height -
                        420,
                    // width:
                    //     MediaQuery.of(context).size.width -
                    //     20,
                    child: Builder(
                      builder: (context) {
                        List<TempMainReceipt> receipts =
                            returnReceiptProvider(context)
                                .returnOwnReceipts(context)
                                .where(
                                  (receipt) =>
                                      receipt.staffId ==
                                      employee.id,
                                )
                                .toList();
                        if (returnReceiptProvider(context)
                            .returnOwnReceipts(context)
                            .where(
                              (test) =>
                                  test.staffId ==
                                  employee.id,
                            )
                            .isEmpty) {
                          return Center(
                            child: Text('Empty'),
                          );
                        } else {
                          return ListView.builder(
                            itemCount: receipts.length,
                            itemBuilder: (context, index) {
                              TempMainReceipt receipt =
                                  receipts[index];

                              return ReceiptTileMain(
                                theme: theme,
                                mainReceipt: receipt,
                              );
                            },
                          );
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Row(
            spacing: 15,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomerActionButton(
                icon: Icons.delete_outline_rounded,
                color: theme.lightModeColor.errorColor200,
                iconSize: 18,
                text: 'Delete',
                action: () {},
                theme: theme,
              ),
              CustomerActionButton(
                svg: editIconSvg,
                color: Colors.grey,
                iconSize: 15,
                text: 'Edit',
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
                theme: theme,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class EmployeeDetailsContainer extends StatelessWidget {
  const EmployeeDetailsContainer({
    super.key,
    required this.employee,
    required this.theme,
  });

  final TempEmployeeClass employee;
  final ThemeProvider theme;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height - 420,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              spacing: 15,
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 9,
                  child: TabBarUserInfoSection(
                    mainText: employee.employeeName,
                    text: 'Name',
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: TabBarUserInfoSection(
                    mainText: formatDateTime(
                      employee.createdDate,
                    ),
                    text: 'Date Added',
                  ),
                ),
              ],
            ),
            SizedBox(height: 30),
            Row(
              spacing: 15,
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 9,
                  child: TabBarUserInfoSection(
                    mainText: employee.email ?? 'Not Set',
                    text: 'Email',
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: TabBarUserInfoSection(
                    mainText:
                        employee.phoneNumber ?? 'Not Set',
                    text: 'Phone Number',
                  ),
                ),
              ],
            ),
            SizedBox(height: 40),
            Row(
              spacing: 15,
              children: [
                Text(
                  style: TextStyle(
                    fontSize: theme.mobileTexts.b2.fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                  'OTHER DETAILS:',
                ),
              ],
            ),
            SizedBox(height: 5),
            Divider(),
            SizedBox(height: 10),
            Row(
              spacing: 15,
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 9,
                  child: TabBarUserInfoSection(
                    mainText: employee.address ?? 'Not Set',
                    text: 'Address',
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: TabBarUserInfoSection(
                    mainText: employee.role,

                    text: 'Role',
                  ),
                ),
              ],
            ),

            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class CustomerActionButton extends StatelessWidget {
  final String text;
  final Function()? action;
  final IconData? icon;
  final Color color;
  final double iconSize;
  final ThemeProvider theme;
  final String? svg;

  const CustomerActionButton({
    super.key,
    required this.text,
    this.action,
    this.icon,
    required this.color,
    required this.iconSize,
    required this.theme,
    this.svg,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: action,
        borderRadius: BorderRadius.circular(5),
        child: Container(
          height: 35,
          width: 100,
          padding: EdgeInsets.symmetric(
            vertical: 7,
            horizontal: 10,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: Colors.grey.shade400),
          ),
          child: Center(
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceAround,
              children: [
                Text(
                  style: TextStyle(
                    fontSize: theme.mobileTexts.b3.fontSize,
                  ),
                  text,
                ),
                Stack(
                  children: [
                    Visibility(
                      visible: icon != null,
                      child: Icon(
                        size: iconSize,
                        color: color,
                        icon ??
                            Icons.delete_outline_rounded,
                      ),
                    ),
                    Visibility(
                      visible: svg != null,
                      child: SvgPicture.asset(
                        svg ?? '',
                        height: iconSize,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TabBarUserInfoSection extends StatelessWidget {
  final String text;
  final String mainText;
  const TabBarUserInfoSection({
    super.key,
    required this.text,
    required this.mainText,
  });

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return SizedBox(
      child: Column(
        spacing: 8,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(text),
          Row(
            children: [
              Flexible(
                child: Text(
                  style: TextStyle(
                    fontSize: theme.mobileTexts.b2.fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                  mainText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class TabBarTabButton extends StatelessWidget {
  final String text;
  final int index;
  const TabBarTabButton({
    super.key,
    required this.theme,
    required this.index,
    required this.text,
  });

  final ThemeProvider theme;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color:
                  returnCompProvider(context).activeTab ==
                          index
                      ? theme.lightModeColor.secColor200
                      : Colors.grey.shade400,
              width: 3,
            ),
          ),
        ),
        child: InkWell(
          onTap: () {
            returnCompProvider(
              context,
              listen: false,
            ).swtichTab(index);
          },
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 10),

            child: Center(
              child: Text(
                style: TextStyle(
                  fontWeight:
                      returnCompProvider(
                                context,
                              ).activeTab ==
                              index
                          ? FontWeight.bold
                          : FontWeight.normal,
                ),
                text,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
