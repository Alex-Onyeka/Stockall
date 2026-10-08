import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/classes/payment_entry/payment_entry.dart';

void main() {
  PaymentEntry entry(String method, double amount) =>
      PaymentEntry(method: method, amount: amount);

  group('label', () {
    test('single method uses that method name', () {
      expect(
        PaymentBreakdown([entry(PaymentMethods.cash, 100)]).label,
        'Cash',
      );
      expect(
        PaymentBreakdown([entry(PaymentMethods.bank, 100)]).label,
        'Bank',
      );
      expect(
        PaymentBreakdown([
          entry(PaymentMethods.account, 100),
        ]).label,
        'Account',
      );
    });

    test('two or more methods is Split', () {
      expect(
        PaymentBreakdown([
          entry(PaymentMethods.account, 60),
          entry(PaymentMethods.bank, 40),
        ]).label,
        'Split',
      );
      expect(
        PaymentBreakdown([
          entry(PaymentMethods.cash, 10),
          entry(PaymentMethods.bank, 10),
          entry(PaymentMethods.account, 10),
        ]).label,
        'Split',
      );
    });

    test('zero amounts are ignored', () {
      var breakdown = PaymentBreakdown([
        entry(PaymentMethods.cash, 0),
        entry(PaymentMethods.bank, 50),
      ]);
      expect(breakdown.label, 'Bank');
      expect(breakdown.isSplit, isFalse);
    });

    test('no payments falls back to Cash', () {
      expect(PaymentBreakdown([]).label, 'Cash');
    });
  });

  group('fromAmounts (legacy receipt shapes)', () {
    test('old cash receipt', () {
      var b = PaymentBreakdown.fromAmounts(
        cash: 1000,
        bank: 0,
        account: 0,
      );
      expect(b.methodsUsed, ['Cash']);
      expect(b.total, 1000);
    });

    test('old cash + bank split', () {
      var b = PaymentBreakdown.fromAmounts(
        cash: 400,
        bank: 600,
        account: 0,
      );
      expect(b.methodsUsed, ['Cash', 'Bank']);
      expect(b.label, 'Split');
    });

    test('old account-only receipt is Account, not Cash 0', () {
      var b = PaymentBreakdown.fromAmounts(
        cash: 0,
        bank: 0,
        account: 1000,
      );
      expect(b.methodsUsed, ['Account']);
      expect(b.compact.single.amount, 1000);
    });

    test('compact keeps fixed Cash, Bank, Account order', () {
      var b = PaymentBreakdown([
        entry(PaymentMethods.account, 5),
        entry(PaymentMethods.cash, 3),
      ]);
      expect(
        b.compact.map((e) => e.method).toList(),
        ['Cash', 'Account'],
      );
    });
  });

  group('validate', () {
    test('valid split returns null', () {
      expect(
        PaymentBreakdown([
          entry(PaymentMethods.account, 5000),
          entry(PaymentMethods.bank, 5000),
        ]).validate(total: 10000, accountBalance: 5000),
        isNull,
      );
    });

    test('parts not adding up to total', () {
      expect(
        PaymentBreakdown([
          entry(PaymentMethods.cash, 4000),
          entry(PaymentMethods.bank, 5000),
        ]).validate(total: 10000),
        'Payments must add up to the total.',
      );
    });

    test('rounding within one kobo/cent is accepted', () {
      expect(
        PaymentBreakdown([
          entry(PaymentMethods.cash, 3333.33),
          entry(PaymentMethods.bank, 6666.67),
        ]).validate(total: 10000.004),
        isNull,
      );
    });

    test('account portion above balance is rejected', () {
      expect(
        PaymentBreakdown([
          entry(PaymentMethods.account, 6000),
          entry(PaymentMethods.bank, 4000),
        ]).validate(total: 10000, accountBalance: 5000),
        contains('cannot be more than'),
      );
    });

    test('account without a customer is rejected', () {
      expect(
        PaymentBreakdown([
          entry(PaymentMethods.account, 10000),
        ]).validate(total: 10000),
        contains('Select a customer'),
      );
    });

    test('negative amounts are rejected', () {
      expect(
        PaymentBreakdown([
          entry(PaymentMethods.cash, 11000),
          entry(PaymentMethods.bank, -1000),
        ]).validate(total: 10000),
        contains('negative'),
      );
    });

    test('Split is not a valid entry method', () {
      expect(
        PaymentBreakdown([
          entry(PaymentMethods.split, 10000),
        ]).validate(total: 10000),
        'Unknown payment method.',
      );
    });
  });
}
