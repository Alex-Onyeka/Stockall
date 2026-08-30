import 'package:stockall/main.dart';

class PlanPricingClass {
  final String planName;
  final String planDesc;
  final int plan;
  final int oldPlan;
  final double price;
  final int duration;
  final double? discount;
  final int numberOfItems;
  final bool barcode;
  final bool invoiceManagement;
  final bool receiptManagement;
  final bool useCalculator;
  final int numberOfStaffs;
  final bool useOffline;
  final int numberOfBranches;
  final int dataStorageDuration;
  final double dollarRate;
  final int currencyIndex;

  PlanPricingClass({
    required this.planName,
    required this.planDesc,
    required this.plan,
    required this.oldPlan,
    required this.price,
    required this.duration,
    this.discount,
    required this.numberOfItems,
    required this.barcode,
    required this.invoiceManagement,
    required this.receiptManagement,
    required this.useCalculator,
    required this.numberOfStaffs,
    required this.useOffline,
    required this.numberOfBranches,
    required this.dataStorageDuration,
    required this.dollarRate,
    required this.currencyIndex,
  });

  double mainPrice() {
    if (currencyIndex == 0) {
      return price;
    } else {
      return price / dollarRate;
    }
  }

  double discountPrice() {
    return discount != null
        ? (mainPrice() - (mainPrice() * discount!))
        : mainPrice();
  }

  double discountedPrice() {
    return discount != null
        ? ((mainPrice() * discount!) * duration)
        : 0;
  }

  double discountPriceMain() {
    return discount != null
        ? (price - (price * discount!))
        : price;
  }

  double originalPrice() {
    return mainPrice() * (duration == 0 ? 1 : duration);
  }

  double totalPriceMain() {
    return discountPriceMain() *
        (duration == 0 ? 1 : duration);
  }

  double totalPrice() {
    return discountPrice() * (duration == 0 ? 1 : duration);
  }

  double vatPrice() {
    return (totalPrice() *
            (returnUtilityConstantProvider()
                    .utilityConstants
                    ?.vat ??
                7.5)) /
        100;
  }

  double finalPrice() {
    return totalPrice() + vatPrice();
  }
}
