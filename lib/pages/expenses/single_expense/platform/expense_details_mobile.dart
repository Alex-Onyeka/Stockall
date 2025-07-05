import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stockall/classes/temp_expenses_class.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/major/top_banner.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/expenses/add_expenses/add_expenses.dart';
import 'package:stockall/providers/theme_provider.dart';

class ExpenseDetailsMobile extends StatelessWidget {
  final int expenseId;
  const ExpenseDetailsMobile({
    super.key,
    required this.expenseId,
  });

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Expanded(
              child: Stack(
                alignment: Alignment(0, 1),
                children: [
                  Align(
                    alignment: Alignment(0, -1),
                    child: TopBanner(
                      isMain: false,
                      subTitle:
                          'Full Details about Expense',
                      title: 'Expense Details',
                      theme: theme,
                      bottomSpace: 100,
                      topSpace: 30,
                      iconSvg: expensesIconSvg,
                    ),
                  ),
                  DetailsPageContainer(
                    theme: theme,
                    expenseId: expenseId,
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

class DetailsPageContainer extends StatefulWidget {
  final ThemeProvider theme;
  final int expenseId;
  const DetailsPageContainer({
    super.key,
    required this.theme,
    required this.expenseId,
  });

  @override
  State<DetailsPageContainer> createState() =>
      _DetailsPageContainerState();
}

class _DetailsPageContainerState
    extends State<DetailsPageContainer> {
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // return FutureBuilder(
    //   future: expenseFuture,
    //   builder: (context, snapshot) {
    //     if (snapshot.connectionState ==
    //         ConnectionState.waiting) {
    //       return Shimmer.fromColors(
    //         baseColor: Colors.grey.shade300,
    //         highlightColor: Colors.white,
    //         child: Container(
    //           width: MediaQuery.of(context).size.width - 40,
    //           height:
    //               MediaQuery.of(context).size.height -
    //               (MediaQuery.of(context).size.height *
    //                   0.25),
    //           decoration: BoxDecoration(
    //             borderRadius: BorderRadius.circular(5),
    //             color: Colors.grey,
    //           ),
    //         ),
    //       );
    //     } else if (snapshot.hasError) {
    //       return EmptyWidgetDisplayOnly(
    //         title: 'An Error Occured',
    //         subText:
    //             'Your data could not Load. Check your internet and try again.',
    //         theme: widget.theme,
    //         height: 30,
    //         icon: Icons.clear,
    //       );
    //     } else {

    //     }
    //   },
    // );

    final matching = returnExpensesProvider(
      context,
    ).expenses.where((e) => e.id == widget.expenseId);

    if (matching.isEmpty) {
      return Scaffold(
        body: returnCompProvider(
          context,
          listen: false,
        ).showLoader('Loading'),
      );
    }

    // final expense = matching.first;

    var expense = matching.firstWhere(
      (exp) => exp.id! == widget.expenseId,
    );

    return Stack(
      children: [
        Container(
          margin: EdgeInsets.only(bottom: 30),
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
            mainAxisSize: MainAxisSize.min,
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
                          expensesIconSvg,
                          color: Colors.grey.shade600,
                          height: 20,
                        ),
                      ),
                      Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            style: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize:
                                  widget
                                      .theme
                                      .mobileTexts
                                      .b3
                                      .fontSize,
                            ),
                            'Expense Name',
                          ),
                          Text(
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  widget
                                      .theme
                                      .mobileTexts
                                      .b1
                                      .fontSize,
                            ),
                            expense.name,
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
                      borderRadius: BorderRadius.circular(
                        5,
                      ),
                      border: Border.all(
                        color: Colors.grey.shade300,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize:
                              widget
                                  .theme
                                  .mobileTexts
                                  .b3
                                  .fontSize,
                          color:
                              widget
                                  .theme
                                  .lightModeColor
                                  .secColor200,
                        ),
                        'Expense',
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Divider(color: Colors.grey.shade300),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15.0,
                ),
                child: ExpenseDetailsContainer(
                  expense: expense,
                  theme: widget.theme,
                ),
              ),
              Visibility(
                visible: true,
                child: Row(
                  spacing: 15,
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 15),
                    CustomerActionButton(
                      icon: Icons.delete_outline_rounded,
                      color:
                          widget
                              .theme
                              .lightModeColor
                              .errorColor200,
                      iconSize: 18,
                      text: 'Delete',
                      action: () {
                        var expP = returnExpensesProvider(
                          context,
                          listen: false,
                        );
                        final safeContext = context;

                        showDialog(
                          context: safeContext,
                          builder: (_) {
                            return ConfirmationAlert(
                              theme: widget.theme,
                              message:
                                  'You are about to delete your Expenses, are you sure you want to proceed?',
                              title: 'Are you sure?',
                              action: () async {
                                if (safeContext.mounted) {
                                  Navigator.of(
                                    safeContext,
                                  ).pop(); // Close the dialog first
                                }
                                setState(() {
                                  isLoading = true;
                                });

                                await expP.deleteExpense(
                                  expense.id!,
                                  safeContext,
                                );

                                if (safeContext.mounted) {
                                  Navigator.of(
                                    safeContext,
                                  ).pop(); // Pop the page
                                }
                                // setState(() {
                                //   isLoading = false;
                                // });
                              },
                            );
                          },
                        );
                      },
                      theme: widget.theme,
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
                              return AddExpenses(
                                expense: expense,
                              );
                            },
                          ),
                        ).then((_) {
                          setState(() {
                            // expenseFuture = getExpense();
                          });
                        });
                      },
                      theme: widget.theme,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
        Visibility(
          visible: isLoading,
          child: returnCompProvider(
            context,
            listen: false,
          ).showLoader('Loading'),
        ),
      ],
    );
  }
}

class ExpenseDetailsContainer extends StatelessWidget {
  const ExpenseDetailsContainer({
    super.key,
    required this.expense,
    required this.theme,
  });

  final TempExpensesClass expense;
  final ThemeProvider theme;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height:
          MediaQuery.of(context).size.height -
          (MediaQuery.of(context).size.height * 0.41),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 15,
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 9,
                  child: TabBarUserInfoSection(
                    mainText: expense.name,
                    text: 'Expense Name',
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: TabBarUserInfoSection(
                    mainText: formatMoneyMid(
                      expense.amount,
                      context,
                    ),
                    text:
                        'Amount (${currencySymbol(context)})',
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 15,
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 9,
                  child: TabBarUserInfoSection(
                    mainText: expense.unit ?? 'Not Set',
                    text: 'Unit',
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: TabBarUserInfoSection(
                    mainText:
                        expense.quantity != null
                            ? formatLargeNumberDouble(
                              expense.quantity!,
                            )
                            : 'Not Set',
                    text: 'Quantity',
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 15,
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 9,
                  child: TabBarUserInfoSection(
                    mainText: expense.creator,
                    text: 'Created By: ',
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: TabBarUserInfoSection(
                    mainText: formatDateWithDay(
                      expense.createdDate!,
                    ),
                    text: 'Created Date',
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
                  'DESCRIPTION:',
                ),
              ],
            ),
            SizedBox(height: 5),
            Divider(),
            SizedBox(height: 10),
            Row(
              children: [
                Flexible(
                  child: Text(
                    expense.description ?? 'Not Set',
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
        spacing: 5,
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
