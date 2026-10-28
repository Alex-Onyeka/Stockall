import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/classes/temp_customer_account_receipts/customer_ledger_rules.dart';

void main() {
  group('customerLedgerTitle', () {
    group('null title gets the default for its direction and ledger', () {
      test('account credit', () {
        expect(
          customerLedgerTitle(title: null, isAdd: true, isBalance: true),
          'Account Credited',
        );
      });
      test('account debit', () {
        expect(
          customerLedgerTitle(title: null, isAdd: false, isBalance: true),
          'Account Debited',
        );
      });
      test('reward credit', () {
        expect(
          customerLedgerTitle(title: null, isAdd: true, isBalance: false),
          'Reward Earned',
        );
      });
      test('reward debit', () {
        expect(
          customerLedgerTitle(title: null, isAdd: false, isBalance: false),
          'Reward Deducted',
        );
      });
      test('null isBalance is the account ledger', () {
        expect(
          customerLedgerTitle(title: null, isAdd: true, isBalance: null),
          'Account Credited',
        );
        expect(
          customerLedgerTitle(title: null, isAdd: false, isBalance: null),
          'Account Debited',
        );
      });
    });

    group('a passed title is always kept', () {
      for (final isBalance in [true, false, null]) {
        for (final isAdd in [true, false]) {
          test('isBalance: $isBalance, isAdd: $isAdd', () {
            expect(
              customerLedgerTitle(
                title: 'Own Title',
                isAdd: isAdd,
                isBalance: isBalance,
              ),
              'Own Title',
            );
          });
        }
      }

      test('Reward Redeemed stays Reward Redeemed', () {
        expect(
          customerLedgerTitle(
            title: 'Reward Redeemed',
            isAdd: false,
            isBalance: false,
          ),
          'Reward Redeemed',
        );
      });

      test('a credit with its own title is not given a debit default', () {
        expect(
          customerLedgerTitle(
            title: 'Opening Balance',
            isAdd: true,
            isBalance: true,
          ),
          'Opening Balance',
        );
        expect(
          customerLedgerTitle(
            title: 'Bonus Reward',
            isAdd: true,
            isBalance: false,
          ),
          'Bonus Reward',
        );
      });
    });
  });

  group('customerLedgerDeleteReversal', () {
    // The provider uses the same rule for the account balance and the
    // cash reward, so each case covers both ledgers.
    for (final ledger in ['account', 'reward']) {
      group(ledger, () {
        test('deleting an addition subtracts it', () {
          final r = customerLedgerDeleteReversal(
            balance: 1500,
            amount: 400,
            isAdd: true,
          );
          expect(r.newBalance, 1100);
          expect(r.isIncrement, isFalse);
        });

        test('deleting a deduction adds it back', () {
          final r = customerLedgerDeleteReversal(
            balance: 1100,
            amount: 400,
            isAdd: false,
          );
          expect(r.newBalance, 1500);
          expect(r.isIncrement, isTrue);
        });

        test('add then delete returns to the start', () {
          const start = 250.0;
          final afterAdd = start + 75;
          final r = customerLedgerDeleteReversal(
            balance: afterAdd,
            amount: 75,
            isAdd: true,
          );
          expect(r.newBalance, start);
        });

        test('zero amount leaves the balance unchanged', () {
          for (final isAdd in [true, false]) {
            expect(
              customerLedgerDeleteReversal(
                balance: 300,
                amount: 0,
                isAdd: isAdd,
              ).newBalance,
              300,
            );
          }
        });
      });
    }

    test('deleting a redemption that emptied the reward restores it', () {
      final r = customerLedgerDeleteReversal(
        balance: 0,
        amount: 500,
        isAdd: false,
      );
      expect(r.newBalance, 500);
      expect(r.isIncrement, isTrue);
    });

    test('deleting an account debit can bring a negative balance back', () {
      final r = customerLedgerDeleteReversal(
        balance: -200,
        amount: 300,
        isAdd: false,
      );
      expect(r.newBalance, 100);
      expect(r.isIncrement, isTrue);
    });
  });
}
