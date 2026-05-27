class GeneralReportSalesSummaryItem {
  final String itemName;
  final String itemUuid;
  final double quantity;
  final double totalCost;
  final double costPrice;
  final String staffName;
  final String staffUuid;
  final String departmentName;
  final String departmentUuid;

  GeneralReportSalesSummaryItem({
    required this.itemName,
    required this.itemUuid,
    required this.quantity,
    required this.totalCost,
    required this.costPrice,
    required this.staffName,
    required this.staffUuid,
    required this.departmentName,
    required this.departmentUuid,
  });

  double profit() {
    return totalCost - costPrice;
  }
}

class GeneralReportFinalSummary {
  final List<GeneralReportSalesSummaryItem> items;

  GeneralReportFinalSummary({required this.items});

  double getTotalCost() {
    double tempTotal = 0;
    for (var item in items) {
      tempTotal += item.totalCost;
    }
    return tempTotal;
  }

  double getTotalQuantity() {
    double tempTotal = 0;
    for (var item in items) {
      tempTotal += item.quantity;
    }
    return tempTotal;
  }
}

class GeneralReportSalesSummaryItemDepartment {
  final String itemName;
  final String itemUuid;
  final String departmentName;
  final String departmentUuid;
  final double quantity;
  final double totalCost;

  GeneralReportSalesSummaryItemDepartment({
    required this.itemName,
    required this.itemUuid,
    required this.departmentName,
    required this.departmentUuid,
    required this.quantity,
    required this.totalCost,
  });
}

class GeneralReportFinalSummaryDepartment {
  final List<GeneralReportSalesSummaryItemDepartment> items;

  GeneralReportFinalSummaryDepartment({
    required this.items,
  });

  double getTotalCost() {
    double tempTotal = 0;
    for (var item in items) {
      tempTotal += item.totalCost;
    }
    return tempTotal;
  }

  double getTotalQuantity() {
    double tempTotal = 0;
    for (var item in items) {
      tempTotal += item.quantity;
    }
    return tempTotal;
  }
}

class GeneralReportSalesSummaryItemStaff {
  final String itemName;
  final String itemUuid;
  final String staffName;
  final String staffUuid;
  final double quantity;
  final double totalCost;

  GeneralReportSalesSummaryItemStaff({
    required this.itemName,
    required this.itemUuid,
    required this.staffName,
    required this.staffUuid,
    required this.quantity,
    required this.totalCost,
  });
}

class GeneralReportFinalSummaryStaff {
  final List<GeneralReportSalesSummaryItemStaff> items;

  GeneralReportFinalSummaryStaff({required this.items});

  double getTotalCost() {
    double tempTotal = 0;
    for (var item in items) {
      tempTotal += item.totalCost;
    }
    return tempTotal;
  }

  double getTotalQuantity() {
    double tempTotal = 0;
    for (var item in items) {
      tempTotal += item.quantity;
    }
    return tempTotal;
  }
}
