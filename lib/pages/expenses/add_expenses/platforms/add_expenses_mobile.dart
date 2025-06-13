import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_expenses_class.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/components/buttons/main_button_p.dart';
import 'package:stockall/components/text_fields/general_textfield.dart';
import 'package:stockall/components/text_fields/main_dropdown.dart';
import 'package:stockall/components/text_fields/number_textfield.dart';
import 'package:stockall/constants/bottom_sheet_widgets.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/main.dart';
import 'package:stockall/services/auth_service.dart';

class AddExpensesMobile extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController descController;
  final TextEditingController amountController;
  final TextEditingController quantityController;
  final TempExpensesClass? expenses;

  const AddExpensesMobile({
    super.key,
    required this.nameController,
    required this.descController,
    required this.amountController,
    required this.quantityController,
    this.expenses,
  });

  @override
  State<AddExpensesMobile> createState() =>
      _AddExpensesMobileState();
}

bool isOpenUnit = false;
bool isLoading = false;
bool showSuccess = false;

class _AddExpensesMobileState
    extends State<AddExpensesMobile> {
  void createExpense() {
    if (widget.nameController.text.isEmpty ||
        widget.amountController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return InfoAlert(
            theme: returnTheme(context),
            message:
                'Expense name and Amount cannot be empty.',
            title: 'Empty Fields',
          );
        },
      );
    } else if (widget.amountController.text == '0') {
      showDialog(
        context: context,
        builder: (context) {
          return InfoAlert(
            theme: returnTheme(context),
            message:
                'Expense Amount cannot be set to Zero.',
            title: 'Zero Expense',
          );
        },
      );
    } else {
      final safeContext = context; // screen-level context

      showDialog(
        context: safeContext,
        builder: (context) {
          var dataProvider = returnData(
            context,
            listen: false,
          );
          // final localProvider = returnLocalDatabase(
          //   context,
          //   listen: false,
          // );
          final expensesProvider = returnExpensesProvider(
            safeContext,
            listen: false,
          );
          return ConfirmationAlert(
            theme: returnTheme(safeContext),
            message:
                widget.expenses != null
                    ? 'You are about to update Expense details, are you sure you want to proceed?'
                    : 'You are about to record a new Expense, are you sure you want to proceed?',
            title: 'Are you sure?',
            action: () async {
              if (safeContext.mounted) {
                Navigator.of(
                  safeContext,
                ).pop(); // close dialog
              }

              setState(() {
                isLoading = true;
              });

              if (widget.expenses == null) {
                await expensesProvider.addExpense(
                  TempExpensesClass(
                    creator: 'Owner',
                    // localProvider.currentEmployee!.name,
                    userId: AuthService().currentUser!.id,
                    // localProvider
                    //     .currentEmployee!
                    //     .userId!,
                    name: widget.nameController.text.trim(),
                    unit:
                        returnData(
                          context,
                          listen: false,
                        ).selectedUnit,

                    quantity: double.tryParse(
                      widget.quantityController.text,
                    ),
                    amount: double.parse(
                      widget.amountController.text
                          .replaceAll(',', ''),
                    ),
                    shopId:
                        returnShopProvider(
                          context,
                          listen: false,
                        ).userShop!.shopId!,
                    description: widget.descController.text,
                  ),
                );
              } else {
                await expensesProvider.updateExpense(
                  TempExpensesClass(
                    creator: 'Alex Onyeka',
                    // localProvider.currentEmployee!.name,
                    userId: AuthService().currentUser!.id,
                    // localProvider
                    //     .currentEmployee!
                    //     .userId!,
                    name: widget.nameController.text.trim(),
                    unit:
                        returnData(
                          context,
                          listen: false,
                        ).selectedUnit,

                    quantity: double.tryParse(
                      widget.quantityController.text,
                    ),
                    amount: double.parse(
                      widget.amountController.text
                          .replaceAll(',', ''),
                    ),
                    shopId:
                        returnShopProvider(
                          context,
                          listen: false,
                        ).userShop!.shopId!,
                    description: widget.descController.text,
                    id: widget.expenses!.id!,
                  ),
                );
              }

              setState(() {
                isLoading = false;
                showSuccess = true;
              });

              // Clear data before popping
              if (safeContext.mounted) {
                dataProvider.clearFields();
              }

              await Future.delayed(
                Duration(seconds: 2),
                () {
                  // Pop current screen
                  if (safeContext.mounted) {
                    Navigator.of(
                      safeContext,
                    ).pop(); // pop current page
                  }
                },
              );
              setState(() {
                isLoading = false;
                showSuccess = false;
              });
            },
          );
        },
      );
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.expenses != null) {
      widget.nameController.text = widget.expenses!.name;
      widget.descController.text =
          widget.expenses!.description ?? '';
      widget.quantityController.text =
          widget.expenses!.quantity != null
              ? widget.expenses!.quantity!.toStringAsFixed(
                0,
              )
              : '';
      widget.amountController.text = widget.expenses!.amount
          .toStringAsFixed(0);
      returnData(context, listen: false).selectedUnit =
          widget.expenses!.unit;
    }
  }

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
                  widget.expenses != null
                      ? 'Edit Expense'
                      : 'Add New Expense',
                ),
              ],
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
            ),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      SizedBox(height: 20),
                      GeneralTextField(
                        title: 'Expense Name',
                        hint: 'Enter Expense Name',
                        controller: widget.nameController,
                        lines: 1,
                        theme: theme,
                      ),
                      SizedBox(height: 15),
                      GeneralTextField(
                        title: 'Description (Optional)',
                        hint: 'Enter Expense Description',
                        controller: widget.descController,
                        lines: 4,
                        theme: theme,
                      ),
                      SizedBox(height: 15),
                      NumberTextfield(
                        title: 'Amount ($nairaSymbol)',
                        hint: 'Enter Expense Amount',
                        controller: widget.amountController,
                        theme: theme,
                      ),
                      SizedBox(height: 15),
                      NumberTextfield(
                        title: 'Quantity (Optional)',
                        hint: 'Enter Expense Quantity',
                        controller:
                            widget.quantityController,
                        theme: theme,
                      ),
                      SizedBox(height: 15),
                      MainDropdown(
                        valueSet:
                            returnData(
                              context,
                            ).unitValueSet,
                        onTap: () {
                          FocusManager.instance.primaryFocus
                              ?.unfocus();
                          unitsBottomSheet(context, () {
                            setState(() {
                              isOpenUnit = !isOpenUnit;
                            });
                          });
                          setState(() {
                            isOpenUnit = !isOpenUnit;
                          });
                        },
                        isOpen: isOpenUnit,
                        title: 'Expense Unit (Optional)',
                        hint:
                            returnData(
                              context,
                            ).selectedUnit ??
                            'Select Expense Unit',
                        theme: theme,
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
                MainButtonP(
                  themeProvider: theme,
                  action: () {
                    createExpense();
                  },
                  text:
                      widget.expenses != null
                          ? 'Update Expense'
                          : 'Add Expense',
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
        Visibility(
          visible: isLoading,
          child: returnCompProvider(
            context,
            listen: false,
          ).showLoader('Loading'),
        ),
        Visibility(
          visible: showSuccess,
          child: returnCompProvider(
            context,
            listen: false,
          ).showSuccess('Successfull'),
        ),
      ],
    );
  }
}
