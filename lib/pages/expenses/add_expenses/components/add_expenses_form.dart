import 'package:flutter/material.dart';
import 'package:stockall/classes/payment_entry/payment_entry.dart';
import 'package:stockall/classes/temp_expenses/sub_expense.dart';
import 'package:stockall/classes/temp_expenses/temp_expenses_class.dart';
import 'package:stockall/classes/user_class/temp_user_class.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/components/buttons/main_button_p.dart';
import 'package:stockall/components/major/desktop_center_container.dart';
import 'package:stockall/components/text_fields/edit_cart_text_field.dart';
import 'package:stockall/components/text_fields/general_textfield.dart';
import 'package:stockall/components/text_fields/main_dropdown.dart';
import 'package:stockall/components/text_fields/money_textfield.dart';
import 'package:stockall/constants/bottom_sheet_widgets.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/date_picker_function.dart';
import 'package:stockall/constants/subscription/expenses_auth.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/expenses/add_expenses/components/sub_expenses_section.dart';
import 'package:stockall/pages/expenses/categories/expense_categories_page.dart';
import 'package:stockall/pages/expenses/components/expense_category_selector.dart';
import 'package:stockall/pages/expenses/components/expense_payment_channel_selector.dart';
import 'package:stockall/pages/expenses/components/expense_staff_selector.dart';
import 'package:stockall/pages/purchases/create_purchase/create_purchase.dart';

class AddExpensesForm extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController descController;
  final TextEditingController amountController;
  final TextEditingController quantityController;
  final TempExpensesClass? expenses;
  final bool isDesktop;

  const AddExpensesForm({
    super.key,
    required this.nameController,
    required this.descController,
    required this.amountController,
    required this.quantityController,
    this.expenses,
    required this.isDesktop,
  });

  @override
  State<AddExpensesForm> createState() => _AddExpensesFormState();
}

class _AddExpensesFormState extends State<AddExpensesForm> {
  bool isOpenUnit = false;
  bool isLoading = false;
  bool showSuccess = false;

  ExpenseCategorySelection _selectedCategory = const ExpenseCategorySelection(
    expenseType: ExpenseType.simpleExpense,
  );
  TempUserClass? _selectedStaff;
  DateTime _paymentDate = DateTime.now();
  String _paymentChannel = PaymentMethods.cash;
  List<SubExpense> _subExpenses = [];

  @override
  void initState() {
    super.initState();
    final existing = widget.expenses;
    if (existing != null) {
      widget.nameController.text = existing.name;
      widget.descController.text = existing.description ?? '';
      widget.quantityController.text =
          existing.quantity != null ? existing.quantity!.toString() : '';
      widget.amountController.text = existing.amount.toString();
      returnData().selectedUnit = existing.unit;
      _selectedCategory = ExpenseCategorySelection(
        expenseType: existing.expenseType,
        categoryUuid: existing.expenseCategoryUuid,
        categoryName: existing.expenseCategoryName,
      );
      _paymentDate = existing.createdDate ?? DateTime.now();
      final channelLabel = existing.resolvedPaymentChannelLabel;
      // "Split" only labels several methods; never use it as one.
      _paymentChannel =
          channelLabel == PaymentMethods.split
              ? _mainChannel(existing.paymentEntries ?? [])
              : channelLabel;
      _subExpenses =
          existing.subExpenses?.map((sub) => sub.copy()).toList() ?? [];
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        returnData().clearUnit();
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final sid = returnShopProvider().userShop()?.shopId;
      if (sid != null) {
        await returnExpensesProvider(
          context,
          listen: false,
        ).getExpenseCategories(sid);
      }
      if (existing?.staffUuid != null && mounted) {
        final staffList = _resolveStaffList(context);
        final match = staffList.where((u) => u.userId == existing!.staffUuid);
        if (match.isNotEmpty) {
          setState(() {
            _selectedStaff = match.first;
          });
        }
      }
    });
  }

  List<TempUserClass> _resolveStaffList(BuildContext context) {
    final userProvider = returnUserProvider(context, listen: false);
    final users = <TempUserClass>[...userProvider.usersMain];
    final current = userProvider.currentUserMain;
    if (current != null &&
        current.userId != null &&
        !users.any((u) => u.userId == current.userId)) {
      users.insert(0, current);
    }
    return users;
  }

  Future<void> _pickPaymentDate() async {
    final theme = returnTheme(context, listen: false);
    final picked = await myDatePickerAction(theme, context);
    if (picked != null && mounted) {
      setState(() {
        _paymentDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _paymentDate.hour,
          _paymentDate.minute,
        );
      });
    }
  }

  bool get _usesSubExpenses =>
      _subExpenses.isNotEmpty &&
      TempExpensesClass.allowsSubExpenses(_selectedCategory.expenseType);

  Future<void> _addSubExpense() async {
    SubExpense? initial;
    if (_subExpenses.isEmpty) {
      // First row starts from what is already typed, so nothing is lost.
      initial = SubExpense(
        uuid: '',
        name: '',
        amount:
            double.tryParse(
              widget.amountController.text.replaceAll(',', ''),
            ) ??
            0,
        quantity: double.tryParse(
          widget.quantityController.text.replaceAll(',', ''),
        ),
        paymentChannel: _paymentChannel,
        unit: returnData().selectedUnit,
      );
    }
    final saved = await showSubExpenseEditor(
      context: context,
      isDesktop: widget.isDesktop,
      initial: initial,
    );
    if (saved == null || !mounted) return;
    setState(() {
      _subExpenses = [..._subExpenses, saved];
    });
  }

  Future<void> _editSubExpense(int index) async {
    final saved = await showSubExpenseEditor(
      context: context,
      isDesktop: widget.isDesktop,
      initial: _subExpenses[index],
    );
    if (saved == null || !mounted) return;
    setState(() {
      _subExpenses = [..._subExpenses]..[index] = saved;
    });
  }

  void _removeSubExpense(int index) {
    setState(() {
      final removed = _subExpenses[index];
      _subExpenses = [..._subExpenses]..removeAt(index);
      if (_subExpenses.isEmpty) {
        // Back to a single amount: keep the last total and channel.
        widget.amountController.text = removed.amount.toString();
        _paymentChannel = removed.paymentChannel;
      }
    });
  }

  /// The method that paid the most in [entries], or Cash when there
  /// are none.
  String _mainChannel(List<PaymentEntry> entries) {
    final compact = PaymentBreakdown(entries).compact;
    compact.sort((a, b) => b.amount.compareTo(a.amount));
    return compact.isEmpty ? PaymentMethods.cash : compact.first.method;
  }

  /// Keeps the sub-expenses' total as the amount and the channel that
  /// paid the most.
  void _collapseSubExpenses() {
    final entries = SubExpense.paymentEntriesOf(_subExpenses);
    widget.amountController.text =
        SubExpense.totalOf(_subExpenses).toString();
    _paymentChannel = _mainChannel(entries);
    _subExpenses = [];
  }

  void _onCategorySelected(ExpenseCategorySelection selection) {
    if (_subExpenses.isEmpty ||
        TempExpensesClass.allowsSubExpenses(selection.expenseType)) {
      setState(() {
        _selectedCategory = selection;
      });
      return;
    }
    showDialog(
      context: context,
      builder:
          (dialogCtx) => ConfirmationAlert(
            theme: returnTheme(context, listen: false),
            title: 'Remove Sub-expenses?',
            message:
                '${ExpenseType.labelFor(selection.expenseType)} expenses cannot have sub-expenses. Switching will remove ${_subExpenses.length} sub-expense(s) and keep their total as the amount.',
            action: () {
              Navigator.of(dialogCtx).pop();
              if (!mounted) return;
              setState(() {
                _collapseSubExpenses();
                _selectedCategory = selection;
              });
            },
          ),
    );
  }

  void _showError(String title, String message) {
    showDialog(
      context: context,
      builder:
          (_) => InfoAlert(
            theme: returnTheme(context, listen: false),
            title: title,
            message: message,
          ),
    );
  }

  void _submitExpense() {
    final isSalary = _selectedCategory.expenseType == ExpenseType.staffSalary;
    if (isSalary && _selectedStaff == null) {
      _showError(
        'Staff Required',
        'Please select the staff member receiving this salary.',
      );
      return;
    }

    final effectiveName =
        isSalary
            ? (widget.nameController.text.trim().isNotEmpty
                ? widget.nameController.text.trim()
                : 'Salary - ${_selectedStaff!.name}')
            : widget.nameController.text.trim();

    final useSubs = _usesSubExpenses;
    if (effectiveName.isEmpty ||
        (!useSubs && widget.amountController.text.trim().isEmpty)) {
      _showError(
        'Empty Fields',
        isSalary
            ? 'Please enter the salary amount.'
            : 'Expense name and Amount cannot be empty.',
      );
      return;
    }

    final parsedAmount =
        useSubs
            ? SubExpense.totalOf(_subExpenses)
            : double.tryParse(
                  widget.amountController.text.replaceAll(',', ''),
                ) ??
                0;
    if (parsedAmount <= 0) {
      _showError('Zero Expense', 'Expense Amount must be greater than zero.');
      return;
    }

    final safeContext = context;
    showDialog(
      context: safeContext,
      builder: (dialogCtx) {
        final sid = returnShopProvider().userShop()!.shopId!;
        final dataProvider = returnData();
        final expensesProvider = returnExpensesProvider(
          safeContext,
          listen: false,
        );
        return ConfirmationAlert(
          theme: returnTheme(safeContext, listen: false),
          message:
              widget.expenses != null
                  ? 'You are about to update Expense details, are you sure you want to proceed?'
                  : 'You are about to record a new Expense, are you sure you want to proceed?',
          title: 'Are you sure?',
          action: () async {
            if (dialogCtx.mounted) {
              Navigator.of(dialogCtx).pop();
            }
            setState(() {
              isLoading = true;
            });

            final staffFullName =
                _selectedStaff == null
                    ? null
                    : '${_selectedStaff!.name} ${_selectedStaff!.lastName ?? ''}'
                        .trim();
            final paymentEntries =
                useSubs
                    ? SubExpense.paymentEntriesOf(_subExpenses)
                    : [
                      PaymentEntry(
                        method: _paymentChannel,
                        amount: parsedAmount,
                      ),
                    ];
            final paymentChannel =
                useSubs
                    ? PaymentBreakdown(paymentEntries).label
                    : _paymentChannel;
            // Parent quantity and unit are hidden while sub-expenses
            // exist, so they are not kept.
            final hideQuantity = isSalary || useSubs;
            // An expense that had sub-expenses sends [] so the server
            // column is cleared too.
            final List<SubExpense>? subExpenses =
                useSubs
                    ? _subExpenses.map((sub) => sub.copy()).toList()
                    : (widget.expenses?.subExpenses != null ? [] : null);

            if (widget.expenses == null) {
              ExpensesAuthAction().numberOfDailyExpensesAction(
                context: safeContext,
                action: () async {
                  final currentUser =
                      returnUserProvider(
                        safeContext,
                        listen: false,
                      ).currentUserMain!;
                  await expensesProvider.addExpense(
                    TempExpensesClass(
                      departmentName:
                          returnDepartmentProvider().currentDepartment()?.name,
                      departmentUuid:
                          returnDepartmentProvider().currentDepartment()?.uuid,
                      creator: currentUser.name,
                      userId: currentUser.userId!,
                      name: effectiveName,
                      unit: hideQuantity ? null : returnData().selectedUnit,
                      quantity:
                          hideQuantity
                              ? null
                              : double.tryParse(
                                widget.quantityController.text.replaceAll(
                                  ',',
                                  '',
                                ),
                              ),
                      amount: parsedAmount,
                      shopId: sid,
                      description: widget.descController.text.trim(),
                      uuid: uuidGen(),
                      createdDate: isSalary ? _paymentDate : DateTime.now(),
                      expenseType: _selectedCategory.expenseType,
                      expenseCategoryUuid: _selectedCategory.categoryUuid,
                      expenseCategoryName: _selectedCategory.categoryName,
                      staffUuid: isSalary ? _selectedStaff?.userId : null,
                      staffName: isSalary ? staffFullName : null,
                      paymentChannel: paymentChannel,
                      paymentEntries: paymentEntries,
                      subExpenses: subExpenses,
                    ),
                  );
                  if (!mounted) return;
                  setState(() {
                    isLoading = false;
                    showSuccess = true;
                  });
                  if (safeContext.mounted) {
                    dataProvider.clearFields();
                  }
                  await Future.delayed(const Duration(seconds: 2));
                  if (safeContext.mounted) {
                    Navigator.of(safeContext).pop();
                  }
                  if (mounted) {
                    setState(() {
                      isLoading = false;
                      showSuccess = false;
                    });
                  }
                },
              );
            } else {
              await expensesProvider.updateExpense(
                TempExpensesClass(
                  departmentName: widget.expenses!.departmentName,
                  departmentUuid: widget.expenses!.departmentUuid,
                  creator:
                      widget.expenses?.userName ??
                      returnUserProvider(
                        safeContext,
                        listen: false,
                      ).currentUserMain!.name,
                  userId: widget.expenses!.userId,
                  name: effectiveName,
                  unit: hideQuantity ? null : returnData().selectedUnit,
                  quantity:
                      hideQuantity
                          ? null
                          : double.tryParse(
                            widget.quantityController.text.replaceAll(',', ''),
                          ),
                  amount: parsedAmount,
                  shopId: sid,
                  description: widget.descController.text.trim(),
                  id: widget.expenses!.id,
                  uuid: widget.expenses!.uuid!,
                  createdDate:
                      isSalary ? _paymentDate : widget.expenses!.createdDate,
                  expenseType: _selectedCategory.expenseType,
                  expenseCategoryUuid: _selectedCategory.categoryUuid,
                  expenseCategoryName: _selectedCategory.categoryName,
                  staffUuid: isSalary ? _selectedStaff?.userId : null,
                  staffName: isSalary ? staffFullName : null,
                  purchaseUuid: widget.expenses!.purchaseUuid,
                  paymentChannel: paymentChannel,
                  paymentEntries: paymentEntries,
                  subExpenses: subExpenses,
                ),
                safeContext,
              );
              if (!mounted) return;
              setState(() {
                isLoading = false;
                showSuccess = true;
              });
              if (safeContext.mounted) {
                dataProvider.clearFields();
              }
              await Future.delayed(const Duration(seconds: 2));
              if (safeContext.mounted) {
                Navigator.of(safeContext).pop();
              }
              if (mounted) {
                setState(() {
                  isLoading = false;
                  showSuccess = false;
                });
              }
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = returnTheme(context);
    final expProvider = returnExpensesProvider(context);
    final staffList = _resolveStaffList(context);
    final type = _selectedCategory.expenseType;
    final isStockPurchase = type == ExpenseType.stockPurchase;
    final isStaffSalary = type == ExpenseType.staffSalary;

    final scaffold = Scaffold(
      appBar: AppBar(
        toolbarHeight: 60,
        centerTitle: true,
        title: Text(
          widget.expenses != null ? 'Edit Expense' : 'Add New Expense',
          style: TextStyle(
            fontSize: theme.mobileTexts.h4.fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  const SizedBox(height: 20),
                  ExpenseCategorySelector(
                    theme: theme,
                    selected: _selectedCategory,
                    customCategories: expProvider.expenseCategories,
                    enabled: widget.expenses?.isStockPurchase != true,
                    onManageCategories: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ExpenseCategoriesPage(),
                        ),
                      ).then((_) {
                        if (!context.mounted) return;
                        returnExpensesProvider(
                          context,
                          listen: false,
                        ).getExpenseCategories(shopId());
                      });
                    },
                    onSelected: _onCategorySelected,
                  ),
                  const SizedBox(height: 15),
                  if (isStockPurchase) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 10,
                        children: [
                          Row(
                            spacing: 8,
                            children: [
                              Icon(
                                Icons.inventory_2_outlined,
                                color: theme.lightModeColor.prColor250,
                              ),
                              Expanded(
                                child: Text(
                                  'Stock Purchase Expense',
                                  style: TextStyle(
                                    fontSize: theme.mobileTexts.b2.fontSize,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'Stock purchases are recorded through the Purchase workflow so inventory quantities, supplier balances, and payment channels stay in sync. Completing a purchase automatically records the paid amount as a Stock Purchase expense.',
                            style: TextStyle(
                              fontSize: theme.mobileTexts.b3.fontSize,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          MainButtonP(
                            themeProvider: theme,
                            text: 'Create New Purchase',
                            action: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const CreatePurchase(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ] else if (isStaffSalary) ...[
                    ExpenseStaffSelector(
                      theme: theme,
                      staffList: staffList,
                      selectedStaff: _selectedStaff,
                      onSelected: (staff) {
                        setState(() {
                          _selectedStaff = staff;
                          if (widget.nameController.text.trim().isEmpty ||
                              widget.nameController.text.startsWith(
                                'Salary - ',
                              )) {
                            widget.nameController.text =
                                'Salary - ${staff.name}';
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 15),
                    MoneyTextfield(
                      title: 'Salary Amount (${currencySymbol(context: context)})',
                      hint: 'Enter Salary Amount',
                      controller: widget.amountController,
                      theme: theme,
                    ),
                    const SizedBox(height: 15),
                    MainDropdown(
                      valueSet: true,
                      isOpen: false,
                      title: 'Payment Date',
                      hint: formatDateWithDay(_paymentDate),
                      theme: theme,
                      onTap: _pickPaymentDate,
                    ),
                    const SizedBox(height: 10),
                    ExpensePaymentChannelSelector(
                      initialChannel: _paymentChannel,
                      onChannelChanged: (channel) {
                        _paymentChannel = channel;
                      },
                    ),
                    const SizedBox(height: 15),
                    GeneralTextField(
                      title: 'Description / Payment Notes (Optional)',
                      hint: 'Enter salary notes or month',
                      controller: widget.descController,
                      lines: 3,
                      theme: theme,
                    ),
                  ] else ...[
                    // Simple Expense or Custom Expense Category
                    GeneralTextField(
                      title: 'Expense Name',
                      hint: 'Enter Expense Name',
                      controller: widget.nameController,
                      lines: 1,
                      theme: theme,
                    ),
                    const SizedBox(height: 15),
                    GeneralTextField(
                      title: 'Description (Optional)',
                      hint: 'Enter Expense Description',
                      controller: widget.descController,
                      lines: 4,
                      theme: theme,
                    ),
                    const SizedBox(height: 15),
                    SubExpensesSection(
                      theme: theme,
                      subExpenses: _subExpenses,
                      onAdd: _addSubExpense,
                      onEdit: _editSubExpense,
                      onRemove: _removeSubExpense,
                    ),
                  ],
                  if (!isStockPurchase &&
                      !isStaffSalary &&
                      _subExpenses.isEmpty) ...[
                    const SizedBox(height: 15),
                    MoneyTextfield(
                      title: 'Amount (${currencySymbol(context: context)})',
                      hint: 'Enter Expense Amount',
                      controller: widget.amountController,
                      theme: theme,
                    ),
                    const SizedBox(height: 10),
                    ExpensePaymentChannelSelector(
                      initialChannel: _paymentChannel,
                      onChannelChanged: (channel) {
                        _paymentChannel = channel;
                      },
                    ),
                    const SizedBox(height: 15),
                    EditCartTextField(
                      title: 'Quantity (Optional)',
                      hint: 'Enter Expense Quantity',
                      controller: widget.quantityController,
                      theme: theme,
                    ),
                    const SizedBox(height: 15),
                    MainDropdown(
                      valueSet: returnData().unitValueSet,
                      onTap: () {
                        FocusManager.instance.primaryFocus?.unfocus();
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
                      hint: returnData().selectedUnit ?? 'Select Expense Unit',
                      theme: theme,
                    ),
                  ],
                  const SizedBox(height: 20),
                ],
              ),
            ),
            if (!isStockPurchase) ...[
              MainButtonP(
                themeProvider: theme,
                action: _submitExpense,
                text:
                    widget.expenses != null ? 'Update Expense' : 'Add Expense',
              ),
              const SizedBox(height: 20),
            ],
          ],
        ),
      ),
    );

    return Stack(
      children: [
        widget.isDesktop
            ? DesktopCenterContainer(mainWidget: scaffold)
            : scaffold,
        Visibility(
          visible: isLoading,
          child: returnCompProvider(
            context,
            listen: false,
          ).showLoader(message: 'Loading'),
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
