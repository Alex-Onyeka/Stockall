import 'package:flutter/material.dart';
import 'package:stockall/constants/subscription/subscription_func.dart';
import 'package:stockall/main.dart';

class ReportAuth {
  final bool printGeneralReport;
  final bool viewSalesReport;
  final bool printSalesReport;
  final bool viewItemsGeneralReport;
  final bool viewItemsAnalysisReport;
  final bool printItemsReport;
  final bool viewCustomersReport;
  final bool printCustomersReport;
  final bool viewEmployeesReport;
  final bool printEmployeesReport;
  final bool viewExpensesReport;
  final bool printExpensesReport;

  ReportAuth({
    required this.printGeneralReport,
    required this.viewSalesReport,
    required this.printSalesReport,
    required this.viewItemsGeneralReport,
    required this.viewItemsAnalysisReport,
    required this.printItemsReport,
    required this.viewCustomersReport,
    required this.printCustomersReport,
    required this.viewEmployeesReport,
    required this.printEmployeesReport,
    required this.viewExpensesReport,
    required this.printExpensesReport,
  });
}

class ReportAuthAction {
  bool printGeneralReportAction({
    required BuildContext context,
    Function()? action,
  }) {
    var plan =
        returnSubcsription(
          context,
          listen: false,
        ).subscription?.plan;
    if (plan == null) {
      return false;
    }
    if (plan == 3) {
      action == null ? {} : action();
      return true;
    } else {
      if (subPlans
          .firstWhere((pl) => pl.plan == plan)
          .reportAuth
          .printGeneralReport) {
        action == null ? {} : action();
        return true;
      } else {
        if (action != null) {
          showUnauthorizedDialog(context);
        }
        return false;
      }
    }
  }

  bool viewSalesReportAction({
    required BuildContext context,
    Function()? action,
  }) {
    var plan =
        returnSubcsription(
          context,
          listen: false,
        ).subscription?.plan;
    if (plan == null) {
      return false;
    }
    if (plan == 3) {
      action == null ? {} : action();
      return true;
    } else {
      if (subPlans
          .firstWhere((pl) => pl.plan == plan)
          .reportAuth
          .viewSalesReport) {
        action == null ? {} : action();
        return true;
      } else {
        if (action != null) {
          showUnauthorizedDialog(context);
        }
        return false;
      }
    }
  }

  bool printSalesReportAction({
    required BuildContext context,
    Function()? action,
  }) {
    var plan =
        returnSubcsription(
          context,
          listen: false,
        ).subscription?.plan;
    if (plan == null) {
      return false;
    }
    if (plan == 3) {
      action == null ? {} : action();
      return true;
    } else {
      if (subPlans
          .firstWhere((pl) => pl.plan == plan)
          .reportAuth
          .printSalesReport) {
        action == null ? {} : action();
        return true;
      } else {
        if (action != null) {
          showUnauthorizedDialog(context);
        }
        return false;
      }
    }
  }

  bool viewItemsGeneralReportAction({
    required BuildContext context,
    Function()? action,
  }) {
    var plan =
        returnSubcsription(
          context,
          listen: false,
        ).subscription?.plan;
    if (plan == null) {
      return false;
    }
    if (plan == 3) {
      action == null ? {} : action();
      return true;
    } else {
      if (subPlans
          .firstWhere((pl) => pl.plan == plan)
          .reportAuth
          .viewItemsGeneralReport) {
        action == null ? {} : action();
        return true;
      } else {
        if (action != null) {
          showUnauthorizedDialog(context);
        }
        return false;
      }
    }
  }

  bool viewItemsAnalysisReportAction({
    required BuildContext context,
    Function()? action,
  }) {
    var plan =
        returnSubcsription(
          context,
          listen: false,
        ).subscription?.plan;
    if (plan == null) {
      return false;
    }
    if (plan == 3) {
      action == null ? {} : action();
      return true;
    } else {
      if (subPlans
          .firstWhere((pl) => pl.plan == plan)
          .reportAuth
          .viewItemsAnalysisReport) {
        action == null ? {} : action();
        return true;
      } else {
        if (action != null) {
          showUnauthorizedDialog(context);
        }
        return false;
      }
    }
  }

  bool printItemsReportAction({
    required BuildContext context,
    Function()? action,
  }) {
    var plan =
        returnSubcsription(
          context,
          listen: false,
        ).subscription?.plan;
    if (plan == null) {
      return false;
    }
    if (plan == 3) {
      action == null ? {} : action();
      return true;
    } else {
      if (subPlans
          .firstWhere((pl) => pl.plan == plan)
          .reportAuth
          .printItemsReport) {
        action == null ? {} : action();
        return true;
      } else {
        if (action != null) {
          showUnauthorizedDialog(context);
        }
        return false;
      }
    }
  }

  bool viewCustomerReportAction({
    required BuildContext context,
    Function()? action,
  }) {
    var plan =
        returnSubcsription(
          context,
          listen: false,
        ).subscription?.plan;
    if (plan == null) {
      return false;
    }
    if (plan == 3) {
      action == null ? {} : action();
      return true;
    } else {
      if (subPlans
          .firstWhere((pl) => pl.plan == plan)
          .reportAuth
          .viewCustomersReport) {
        action == null ? {} : action();
        return true;
      } else {
        if (action != null) {
          showUnauthorizedDialog(context);
        }
        return false;
      }
    }
  }

  bool printCustomerReportAction({
    required BuildContext context,
    Function()? action,
  }) {
    var plan =
        returnSubcsription(
          context,
          listen: false,
        ).subscription?.plan;
    if (plan == null) {
      return false;
    }
    if (plan == 3) {
      action == null ? {} : action();
      return true;
    } else {
      if (subPlans
          .firstWhere((pl) => pl.plan == plan)
          .reportAuth
          .printCustomersReport) {
        action == null ? {} : action();
        return true;
      } else {
        if (action != null) {
          showUnauthorizedDialog(context);
        }
        return false;
      }
    }
  }

  bool viewEmployeesReportAction({
    required BuildContext context,
    Function()? action,
  }) {
    var plan =
        returnSubcsription(
          context,
          listen: false,
        ).subscription?.plan;
    if (plan == null) {
      return false;
    }
    if (plan == 3) {
      action == null ? {} : action();
      return true;
    } else {
      if (subPlans
          .firstWhere((pl) => pl.plan == plan)
          .reportAuth
          .viewEmployeesReport) {
        action == null ? {} : action();
        return true;
      } else {
        if (action != null) {
          showUnauthorizedDialog(context);
        }
        return false;
      }
    }
  }

  bool printEmployeesReportAction({
    required BuildContext context,
    Function()? action,
  }) {
    var plan =
        returnSubcsription(
          context,
          listen: false,
        ).subscription?.plan;
    if (plan == null) {
      return false;
    }
    if (plan == 3) {
      action == null ? {} : action();
      return true;
    } else {
      if (subPlans
          .firstWhere((pl) => pl.plan == plan)
          .reportAuth
          .printEmployeesReport) {
        action == null ? {} : action();
        return true;
      } else {
        if (action != null) {
          showUnauthorizedDialog(context);
        }
        return false;
      }
    }
  }

  bool viewExpensesReportAction({
    required BuildContext context,
    Function()? action,
  }) {
    var plan =
        returnSubcsription(
          context,
          listen: false,
        ).subscription?.plan;
    if (plan == null) {
      return false;
    }
    if (plan == 3) {
      action == null ? {} : action();
      return true;
    } else {
      if (subPlans
          .firstWhere((pl) => pl.plan == plan)
          .reportAuth
          .viewExpensesReport) {
        action == null ? {} : action();
        return true;
      } else {
        if (action != null) {
          showUnauthorizedDialog(context);
        }
        return false;
      }
    }
  }

  bool printExpensesReportAction({
    required BuildContext context,
    Function()? action,
  }) {
    var plan =
        returnSubcsription(
          context,
          listen: false,
        ).subscription?.plan;
    if (plan == null) {
      return false;
    }
    if (plan == 3) {
      action == null ? {} : action();
      return true;
    } else {
      if (subPlans
          .firstWhere((pl) => pl.plan == plan)
          .reportAuth
          .printExpensesReport) {
        action == null ? {} : action();
        return true;
      } else {
        if (action != null) {
          showUnauthorizedDialog(context);
        }
        return false;
      }
    }
  }
}
