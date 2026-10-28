/// Title saved on a ledger entry: a passed title is kept; a null title gets
/// the default for its direction and ledger.
String customerLedgerTitle({
  required String? title,
  required bool isAdd,
  required bool? isBalance,
}) {
  if (title != null) return title;
  if (isBalance ?? true) {
    return isAdd ? 'Account Credited' : 'Account Debited';
  }
  return isAdd ? 'Reward Earned' : 'Reward Deducted';
}

/// Balance after deleting a ledger entry, and the direction of the queued
/// CustomerAccountUpdate: deleting an addition subtracts, deleting a
/// deduction adds back.
({double newBalance, bool isIncrement}) customerLedgerDeleteReversal({
  required double balance,
  required double amount,
  required bool isAdd,
}) =>
    isAdd
        ? (newBalance: balance - amount, isIncrement: false)
        : (newBalance: balance + amount, isIncrement: true);
