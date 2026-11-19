import 'package:hive/hive.dart';
import 'package:stockall/classes/payment_entry/payment_entry.dart';

part 'sub_expense.g.dart';

/// One line of an expense's breakdown (e.g. "Transportation" under
/// "NEPA Bill"). Stored as a list inside the parent expense, like
/// receipt items. [amount] is the line total; [quantity] is for
/// information only.
@HiveType(typeId: 159)
class SubExpense {
  @HiveField(0)
  String uuid;

  @HiveField(1)
  String name;

  @HiveField(2)
  String? description;

  @HiveField(3)
  double amount;

  @HiveField(4)
  double? quantity;

  /// 'Cash', 'Bank' or a bank name: the same strings as
  /// [PaymentEntry.method].
  @HiveField(5)
  String paymentChannel;

  SubExpense({
    required this.uuid,
    required this.name,
    this.description,
    required this.amount,
    this.quantity,
    this.paymentChannel = PaymentMethods.cash,
  });

  factory SubExpense.fromJson(Map<String, dynamic> json) {
    final channel = (json['payment_channel'] as String?)?.trim();
    return SubExpense(
      uuid: (json['uuid'] ?? '').toString(),
      name: (json['name'] ?? '') as String,
      description: json['description'] as String?,
      amount: (json['amount'] as num? ?? 0).toDouble(),
      quantity:
          json['quantity'] != null
              ? (json['quantity'] as num).toDouble()
              : null,
      paymentChannel:
          channel == null || channel.isEmpty ? PaymentMethods.cash : channel,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'name': name,
      'description': description,
      'amount': amount,
      'quantity': quantity,
      'payment_channel': paymentChannel,
    };
  }

  SubExpense copy() => SubExpense(
    uuid: uuid,
    name: name,
    description: description,
    amount: amount,
    quantity: quantity,
    paymentChannel: paymentChannel,
  );

  /// Sum of the lines' amounts.
  static double totalOf(List<SubExpense> subs) =>
      subs.fold<double>(0, (sum, sub) => sum + sub.amount);

  /// The lines' amounts merged per payment channel, for the parent's
  /// `paymentEntries`.
  static List<PaymentEntry> paymentEntriesOf(List<SubExpense> subs) {
    return PaymentBreakdown(
      subs
          .map(
            (sub) => PaymentEntry(
              method: sub.paymentChannel,
              amount: sub.amount,
            ),
          )
          .toList(),
    ).compact;
  }
}
