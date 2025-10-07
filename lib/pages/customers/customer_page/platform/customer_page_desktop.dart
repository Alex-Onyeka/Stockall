import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stockall/classes/temp_customers/temp_customers_class.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/major/top_banner.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/customers/add_customer/add_customer.dart';
import 'package:stockall/pages/sales/total_sales/total_sales_page.dart';
import 'package:stockall/providers/theme_provider.dart';

class CustomerPageDesktop extends StatelessWidget {
  final String uuid;
  const CustomerPageDesktop({
    super.key,
    required this.uuid,
  });

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    var customer = returnCustomers(context).customersMain
        .firstWhere((cust) => cust.uuid! == uuid);
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
                          'Full Details about customer',
                      title: 'Customer Details',
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
                      customer: customer,
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
  final TempCustomersClass customer;
  const DetailsPageContainer({
    super.key,
    required this.theme,
    required this.customer,
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
                          customer.name,
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
                          customer.email,
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
                    'Customer',
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
                        text: 'Basic Info',
                        theme: theme,
                      ),
                    ),
                    Expanded(
                      child: TabBarTabButton(
                        index: 1,
                        text: 'Purchases',
                        theme: theme,
                        action: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return TotalSalesPage(
                                  customerUuid:
                                      customer.uuid!,
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                CustomerDetailsContainer(
                  customer: customer,
                  theme: theme,
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
                action: () {
                  final safeContext = context;
                  showDialog(
                    context: context,
                    builder: (context) {
                      return ConfirmationAlert(
                        theme: theme,
                        message:
                            'You are about to delete your customer, are you sure you want to proceed?',
                        title: 'Are you sure?',
                        action: () async {
                          if (safeContext.mounted) {
                            Navigator.of(safeContext).pop();
                          }
                          returnCustomers(
                            context,
                            listen: false,
                          ).deleteCustomerMain(
                            customer.uuid!,
                            context,
                          );
                          await Future.delayed(
                            Duration(microseconds: 500),
                            () {},
                          );
                          if (context.mounted) {
                            Navigator.of(context).pop();
                          }
                        },
                      );
                    },
                  );
                },
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
                        return AddCustomer(
                          customer: customer,
                        );
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

class CustomerDetailsContainer extends StatelessWidget {
  const CustomerDetailsContainer({
    super.key,
    required this.customer,
    required this.theme,
  });

  final TempCustomersClass customer;
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
                    mainText: customer.name,
                    text: 'Name',
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: TabBarUserInfoSection(
                    mainText: formatDateTime(
                      customer.dateAdded,
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
                    mainText: customer.email,
                    text: 'Email',
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: TabBarUserInfoSection(
                    mainText: customer.phone,
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
                    mainText:
                        (customer.country != null &&
                                customer.country!
                                    .trim()
                                    .isNotEmpty)
                            ? customer.country!
                            : 'Not Set',

                    text: 'Country',
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: TabBarUserInfoSection(
                    mainText:
                        (customer.state != null &&
                                customer.state!
                                    .trim()
                                    .isNotEmpty)
                            ? customer.state!
                            : 'Not Set',

                    text: 'State',
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
                    mainText:
                        (customer.address != null &&
                                customer.address!
                                    .trim()
                                    .isNotEmpty)
                            ? customer.address!
                            : 'Not Set',

                    text: 'Address',
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: TabBarUserInfoSection(
                    mainText:
                        (customer.city != null &&
                                customer.city!
                                    .trim()
                                    .isNotEmpty)
                            ? customer.city!
                            : 'Not Set',

                    text: 'City',
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
  final Function()? action;
  const TabBarTabButton({
    super.key,
    required this.theme,
    required this.index,
    required this.text,
    this.action,
  });

  final ThemeProvider theme;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color:
              returnCompProvider(context).activeTab == index
                  ? const Color.fromARGB(39, 255, 201, 7)
                  : Colors.transparent,
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
            action!();
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
