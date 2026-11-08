import 'package:hive/hive.dart';

part 'payment_entry.g.dart';

// Same strings as the legacy receipt `paymentMethod` labels, so single-method
// receipts keep the label older app versions expect.
class PaymentMethods {
  static const String cash = 'Cash';
  static const String bank = 'Bank';
  static const String account = 'Account';
  // Label only, used when more than one method is paid. Never an entry method.
  static const String split = 'Split';

  static const List<String> all = [cash, bank, account];

  static bool isBankMethod(String method) {
    return method != cash && method != account && method != split;
  }
}

@HiveType(typeId: 153)
class PaymentEntry {
  @HiveField(0)
  String method;

  @HiveField(1)
  double amount;

  PaymentEntry({required this.method, required this.amount});

  factory PaymentEntry.fromJson(Map<String, dynamic> json) {
    return PaymentEntry(
      method: json['method'] as String,
      amount: (json['amount'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'method': method, 'amount': amount};
  }
}

// Pure helpers over a list of payment entries. Has no cart or provider
// dependencies so invoices and orders can reuse it later.
class PaymentBreakdown {
  final List<PaymentEntry> entries;

  static const double tolerance = 0.01;

  PaymentBreakdown(this.entries);

  factory PaymentBreakdown.fromAmounts({
    required double cash,
    required double bank,
    required double account,
  }) {
    return PaymentBreakdown([
      PaymentEntry(method: PaymentMethods.cash, amount: cash),
      PaymentEntry(method: PaymentMethods.bank, amount: bank),
      PaymentEntry(
        method: PaymentMethods.account,
        amount: account,
      ),
    ]);
  }

  double amountFor(String method) {
    return entries
        .where((entry) => entry.method == method)
        .fold<double>(0, (p, entry) => p + entry.amount);
  }

  double get cash => amountFor(PaymentMethods.cash);

  // Sums all bank / electronic channels (either 'Bank' or any custom bank account)
  double get bank {
    return entries
        .where(
          (entry) =>
              entry.method != PaymentMethods.cash &&
              entry.method != PaymentMethods.account,
        )
        .fold<double>(0, (p, entry) => p + entry.amount);
  }

  double get account => amountFor(PaymentMethods.account);

  double get total =>
      entries.fold<double>(0, (p, entry) => p + entry.amount);

  // Methods with a positive amount, preserving custom bank names
  List<String> get methodsUsed {
    final Set<String> used = {};
    for (final method in PaymentMethods.all) {
      if (amountFor(method) > 0) used.add(method);
    }
    for (final entry in entries) {
      if (entry.amount > 0) used.add(entry.method);
    }
    return used.toList();
  }

  bool uses(String method) => amountFor(method) > 0;

  bool get isSplit => methodsUsed.length > 1;

  String get label {
    var used = methodsUsed;
    if (used.isEmpty) {
      return entries.isNotEmpty ? entries.first.method : PaymentMethods.cash;
    } else if (used.length == 1) {
      return used.first;
    } else {
      return PaymentMethods.split;
    }
  }

  // Entries with a positive amount, merged per method.
  List<PaymentEntry> get compact {
    var used = methodsUsed;
    if (used.isEmpty) {
      if (entries.isNotEmpty) {
        return [PaymentEntry(method: entries.first.method, amount: 0)];
      }
      return [PaymentEntry(method: PaymentMethods.cash, amount: 0)];
    }
    return used
        .map(
          (method) => PaymentEntry(
            method: method,
            amount: amountFor(method),
          ),
        )
        .toList();
  }

  // Returns null when valid, otherwise a user-facing error message.
  // Pass `accountBalance: null` when no customer is selected.
  String? validate({
    required double total,
    double? accountBalance,
  }) {
    if (entries.any((entry) => entry.amount < 0)) {
      return 'Payment amounts cannot be negative.';
    }
    if (entries.any((entry) => entry.method.trim().isEmpty)) {
      return 'Payment method cannot be empty.';
    }
    if (account > 0) {
      if (accountBalance == null) {
        return 'Select a customer before paying from a Customer Account.';
      }
      if (account - accountBalance > tolerance) {
        return 'The Customer Account portion cannot be more than the customer\'s balance.';
      }
    }
    if ((this.total - total).abs() > tolerance) {
      return 'Payments must add up to the total.';
    }
    return null;
  }
}
