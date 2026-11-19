import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/classes/payment_entry/payment_entry.dart';
import 'package:stockall/classes/temp_expenses/sub_expense.dart';
import 'package:stockall/classes/temp_expenses/temp_expenses_class.dart';

List<SubExpense> _nepaSubs() => [
  SubExpense(
    uuid: 's1',
    name: 'Bill payment',
    amount: 50000,
    paymentChannel: 'GTB',
  ),
  SubExpense(
    uuid: 's2',
    name: 'Transportation',
    description: 'Okada to the office',
    amount: 10000,
    quantity: 2,
    paymentChannel: PaymentMethods.cash,
  ),
  SubExpense(
    uuid: 's3',
    name: 'Feeding',
    amount: 5000,
    paymentChannel: PaymentMethods.cash,
  ),
];

TempExpensesClass _expense({List<SubExpense>? subs, double amount = 65000}) {
  return TempExpensesClass(
    uuid: 'exp-nepa',
    shopId: 7,
    name: 'NEPA Bill',
    amount: amount,
    creator: 'Owner',
    userId: 'owner-1',
    departmentName: null,
    departmentUuid: null,
    createdDate: DateTime(2026, 11, 19, 10),
    subExpenses: subs,
    paymentEntries: subs == null ? null : SubExpense.paymentEntriesOf(subs),
    paymentChannel:
        subs == null
            ? PaymentMethods.cash
            : PaymentBreakdown(SubExpense.paymentEntriesOf(subs)).label,
  );
}

void main() {
  group('SubExpense', () {
    test('JSON round trip keeps every field', () {
      final sub = _nepaSubs()[1];
      final decoded = SubExpense.fromJson(sub.toJson());
      expect(decoded.uuid, 's2');
      expect(decoded.name, 'Transportation');
      expect(decoded.description, 'Okada to the office');
      expect(decoded.amount, 10000);
      expect(decoded.quantity, 2);
      expect(decoded.paymentChannel, PaymentMethods.cash);
      expect(sub.toJson()['payment_channel'], PaymentMethods.cash);
    });

    test('missing or blank channel defaults to Cash', () {
      final decoded = SubExpense.fromJson({
        'uuid': 'x',
        'name': 'Feeding',
        'amount': 500,
        'payment_channel': '  ',
      });
      expect(decoded.paymentChannel, PaymentMethods.cash);
      expect(decoded.quantity, isNull);
    });

    test('total and payment entries merged per channel', () {
      final subs = _nepaSubs();
      expect(SubExpense.totalOf(subs), 65000);
      final entries = SubExpense.paymentEntriesOf(subs);
      final breakdown = PaymentBreakdown(entries);
      expect(entries.length, 2);
      expect(breakdown.amountFor(PaymentMethods.cash), 15000);
      expect(breakdown.amountFor('GTB'), 50000);
      expect(breakdown.total, 65000);
      expect(breakdown.label, PaymentMethods.split);
    });

    test('single channel gives that channel as the label', () {
      final subs = _nepaSubs()
        ..forEach((s) => s.paymentChannel = 'GTB');
      expect(
        PaymentBreakdown(SubExpense.paymentEntriesOf(subs)).label,
        'GTB',
      );
    });
  });

  group('TempExpensesClass with sub-expenses', () {
    test('old row without sub_expenses parses to null', () {
      final exp = TempExpensesClass.fromJson({
        'shop_id': 7,
        'name': 'Stationery',
        'amount': 2500,
        'uuid': 'exp-old',
      });
      expect(exp.subExpenses, isNull);
      expect(exp.hasSubExpenses, isFalse);
      expect(exp.subExpensesMismatch, isFalse);
    });

    test('toJson leaves the key out while null, sends [] when cleared', () {
      final plain = _expense();
      expect(plain.toJson().containsKey('sub_expenses'), isFalse);

      final cleared = _expense(subs: []);
      expect(cleared.toJson()['sub_expenses'], isEmpty);
      expect(cleared.hasSubExpenses, isFalse);
    });

    test('JSON round trip keeps the breakdown and derived parent', () {
      final exp = _expense(subs: _nepaSubs());
      final decoded = TempExpensesClass.fromJson(exp.toJson());
      expect(decoded.subExpenses!.map((s) => s.name), [
        'Bill payment',
        'Transportation',
        'Feeding',
      ]);
      expect(decoded.amount, 65000);
      expect(decoded.subExpensesTotal, 65000);
      expect(decoded.subExpensesMismatch, isFalse);
      expect(decoded.resolvedPaymentChannelLabel, PaymentMethods.split);
    });

    test('amount changed elsewhere is flagged as a mismatch', () {
      final exp = _expense(subs: _nepaSubs(), amount: 70000);
      expect(exp.subExpensesMismatch, isTrue);
    });

    test('only Simple and Custom allow sub-expenses', () {
      expect(
        TempExpensesClass.allowsSubExpenses(ExpenseType.simpleExpense),
        isTrue,
      );
      expect(TempExpensesClass.allowsSubExpenses(ExpenseType.custom), isTrue);
      expect(
        TempExpensesClass.allowsSubExpenses(ExpenseType.staffSalary),
        isFalse,
      );
      expect(
        TempExpensesClass.allowsSubExpenses(ExpenseType.stockPurchase),
        isFalse,
      );
    });
  });
}
