import 'package:hive/hive.dart';
import 'package:stockall/classes/payment_entry/payment_entry.dart';
import 'package:stockall/classes/temp_expenses/expense_category.dart';
import 'package:stockall/classes/temp_expenses/sub_expense.dart';

part 'temp_expenses_class.g.dart';

class ExpenseType {
  static const String simpleExpense = 'simple_expense';
  static const String staffSalary = 'staff_salary';
  static const String stockPurchase = 'stock_purchase';
  static const String custom = 'custom';

  static const List<String> systemTypes = [
    simpleExpense,
    staffSalary,
    stockPurchase,
  ];

  static String labelFor(String? type, {String? customCategoryName}) {
    switch (type) {
      case staffSalary:
        return 'Staff Salary';
      case stockPurchase:
        return 'Stock Purchase';
      case custom:
        if (customCategoryName != null &&
            customCategoryName.trim().isNotEmpty) {
          return customCategoryName.trim();
        }
        return 'Custom Category';
      case simpleExpense:
      default:
        return 'Simple Expenses';
    }
  }

  /// Names a custom category cannot take: the system categories'
  /// labels, plus the old "Simple Expense" label.
  static const List<String> reservedNames = [
    'simple expense',
    'simple expenses',
    'staff salary',
    'stock purchase',
  ];

  /// True when [name] (trimmed, any case) is a reserved name.
  static bool isReservedName(String name) =>
      reservedNames.contains(name.trim().toLowerCase());
}

@HiveType(typeId: 2)
class TempExpensesClass extends HiveObject {
  @HiveField(0)
  int? id;

  @HiveField(1)
  DateTime? createdDate;

  @HiveField(2)
  int shopId;

  @HiveField(3)
  String name;

  @HiveField(4)
  String? creator;

  @HiveField(5)
  String? description;

  @HiveField(6)
  double amount;

  @HiveField(7)
  double? quantity;

  @HiveField(8)
  String? unit;

  @HiveField(9)
  String? userId;

  @HiveField(10)
  String? departmentName;

  @HiveField(11)
  String? departmentUuid;

  @HiveField(12)
  String? uuid;

  @HiveField(13)
  DateTime? updatedAt;

  @HiveField(14)
  String? userName;

  @HiveField(15, defaultValue: ExpenseType.simpleExpense)
  String expenseType;

  @HiveField(16)
  String? expenseCategoryUuid;

  @HiveField(17)
  String? expenseCategoryName;

  @HiveField(18)
  String? staffUuid;

  @HiveField(19)
  String? staffName;

  @HiveField(20)
  String? purchaseUuid;

  @HiveField(21)
  String? paymentChannel;

  @HiveField(22)
  List<PaymentEntry>? paymentEntries;

  /// Optional breakdown. When non-empty, [amount] and
  /// [paymentEntries] are derived from it; reports only ever read
  /// [amount], so the lines are never counted twice.
  @HiveField(23)
  List<SubExpense>? subExpenses;

  TempExpensesClass({
    required this.name,
    this.description,
    required this.amount,
    required this.creator,
    this.quantity,
    this.unit,
    required this.shopId,
    this.id,
    this.createdDate,
    required this.userId,
    required this.departmentName,
    required this.departmentUuid,
    this.uuid,
    this.updatedAt,
    this.userName,
    this.expenseType = ExpenseType.simpleExpense,
    this.expenseCategoryUuid,
    this.expenseCategoryName,
    this.staffUuid,
    this.staffName,
    this.purchaseUuid,
    this.paymentChannel,
    this.paymentEntries,
    this.subExpenses,
  });

  String get categoryLabel => ExpenseType.labelFor(
    expenseType,
    customCategoryName: expenseCategoryName,
  );

  /// [categoryLabel], but a custom category's name is looked up
  /// in [categories] by uuid, so a rename shows on every expense.
  /// Falls back to the saved name (category deleted or not loaded).
  String categoryLabelWith(List<ExpenseCategory> categories) {
    if (isCustomCategory && expenseCategoryUuid != null) {
      for (final category in categories) {
        if (category.uuid == expenseCategoryUuid) {
          return ExpenseType.labelFor(
            ExpenseType.custom,
            customCategoryName: category.name,
          );
        }
      }
    }
    return categoryLabel;
  }

  bool get isSimpleExpense => expenseType == ExpenseType.simpleExpense;
  bool get isStaffSalary => expenseType == ExpenseType.staffSalary;
  bool get isStockPurchase => expenseType == ExpenseType.stockPurchase;
  bool get isCustomCategory => expenseType == ExpenseType.custom;

  /// Only Simple and Custom expenses can be broken down.
  static bool allowsSubExpenses(String type) =>
      type == ExpenseType.simpleExpense || type == ExpenseType.custom;

  bool get hasSubExpenses =>
      subExpenses != null && subExpenses!.isNotEmpty;

  double get subExpensesTotal =>
      hasSubExpenses ? SubExpense.totalOf(subExpenses!) : 0;

  /// True when the lines no longer add up to [amount], e.g. after an
  /// older app version edited the amount.
  bool get subExpensesMismatch =>
      hasSubExpenses &&
      (subExpensesTotal - amount).abs() > PaymentBreakdown.tolerance;

  String get resolvedPaymentChannelLabel {
    if (paymentEntries != null && paymentEntries!.isNotEmpty) {
      return PaymentBreakdown(paymentEntries!).label;
    }
    if (paymentChannel != null && paymentChannel!.trim().isNotEmpty) {
      return paymentChannel!.trim();
    }
    return PaymentMethods.cash;
  }

  factory TempExpensesClass.fromJson(Map<String, dynamic> json) {
    final rawEntries = json['payment_entries'];
    List<PaymentEntry>? parsedEntries;
    if (rawEntries is List) {
      parsedEntries =
          rawEntries
              .whereType<Map>()
              .map(
                (e) => PaymentEntry.fromJson(
                  Map<String, dynamic>.from(e),
                ),
              )
              .toList();
    }
    final rawSubs = json['sub_expenses'];
    List<SubExpense>? parsedSubs;
    if (rawSubs is List) {
      parsedSubs =
          rawSubs
              .whereType<Map>()
              .map(
                (e) => SubExpense.fromJson(
                  Map<String, dynamic>.from(e),
                ),
              )
              .toList();
    }

    return TempExpensesClass(
      id: json['id'] as int?,
      createdDate:
          json['created_date'] != null
              ? DateTime.parse(json['created_date'].toString()).toLocal()
              : null,
      shopId: (json['shop_id'] as num).toInt(),
      name: (json['name'] ?? '') as String,
      description: json['description'] as String?,
      amount: (json['amount'] as num).toDouble(),
      quantity:
          json['quantity'] != null
              ? (json['quantity'] as num).toDouble()
              : null,
      unit: json['unit'] as String?,
      userId: json['user_id'] as String?,
      creator: json['creator'] as String?,
      departmentUuid: json['department_uuid'] as String?,
      departmentName: json['department_name'] as String?,
      uuid: json['uuid'] as String?,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'].toString()).toLocal()
              : null,
      userName: json['user_name'] as String?,
      expenseType:
          (json['expense_type'] as String?)?.trim().isNotEmpty == true
              ? (json['expense_type'] as String).trim()
              : ExpenseType.simpleExpense,
      expenseCategoryUuid: json['expense_category_uuid'] as String?,
      expenseCategoryName: json['expense_category_name'] as String?,
      staffUuid: json['staff_uuid'] as String?,
      staffName: json['staff_name'] as String?,
      purchaseUuid: json['purchase_uuid'] as String?,
      paymentChannel: json['payment_channel'] as String?,
      paymentEntries: parsedEntries,
      subExpenses: parsedSubs,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // 'id': id,
      'created_date': createdDate?.toUtc().toIso8601String(),
      'shop_id': shopId,
      'name': name,
      'description': description,
      'amount': amount,
      'quantity': quantity,
      'unit': unit,
      'user_id': userId,
      'creator': creator,
      'department_uuid': departmentUuid,
      'department_name': departmentName,
      'uuid': uuid,
      'updated_at': updatedAt?.toUtc().toIso8601String(),
      'user_name': userName,
      'expense_type': expenseType,
      'expense_category_uuid': expenseCategoryUuid,
      'expense_category_name': expenseCategoryName,
      'staff_uuid': staffUuid,
      'staff_name': staffName,
      'purchase_uuid': purchaseUuid,
      'payment_channel': paymentChannel,
      'payment_entries':
          paymentEntries?.map((e) => e.toJson()).toList(),
      // Left out while null so plain expenses keep syncing even if the
      // sub_expenses column is missing; cleared rows are sent as [].
      if (subExpenses != null)
        'sub_expenses': subExpenses!.map((e) => e.toJson()).toList(),
    };
  }
}
