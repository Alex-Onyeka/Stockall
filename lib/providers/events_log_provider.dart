import 'package:flutter/widgets.dart';
import 'package:stockall/classes/temp_customers/temp_customers_class.dart';
import 'package:stockall/classes/temp_departments_class/department_class.dart';
import 'package:stockall/classes/temp_event_log/temp_event_log_class.dart';
import 'package:stockall/classes/temp_expenses/temp_expenses_class.dart';
import 'package:stockall/classes/temp_invoices/temp_invoices.dart';
import 'package:stockall/classes/temp_main_receipt/temp_main_receipt.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/classes/temp_sub_staff/temp_sub_staff.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/local_database/events_log/events_log_func.dart';
import 'package:stockall/local_database/events_log/unsync_funcs/created_events_log_func.dart';
import 'package:stockall/main.dart';
import 'package:stockall/providers/connectivity_provider.dart';
import 'package:stockall/providers/error_log_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EventsLogProvider with ChangeNotifier {
  final SupabaseClient client = Supabase.instance.client;
  final String tableName = 'event_logs';
  static final EventsLogProvider _instance =
      EventsLogProvider._internal();
  factory EventsLogProvider() => _instance;
  EventsLogProvider._internal();

  List<TempEventLogClass> logs = [];

  DateTime? dateSet;

  void clearDate() {
    dateSet = null;
    rangeStartDate = null;
    rangeEndDate = null;
    notifyListeners();
  }

  void setDate(DateTime date) {
    if (dateSet == null) {
      dateSet = date;
      rangeStartDate = null;
      rangeEndDate = null;
      mainLocalLog('Date set: $date');
    } else {
      dateSet = null;
      mainLocalLog('Date Cleared');
    }
    notifyListeners();
  }

  DateTime? rangeStartDate;
  DateTime? rangeEndDate;

  void setRange(DateTime rangeStart, DateTime endOfrange) {
    rangeStartDate = rangeStart;
    rangeEndDate = endOfrange;
    mainLocalLog(
      'Date Range set: Start: $rangeStart End: $endOfrange ',
    );
    dateSet = null;
    notifyListeners();
  }

  List<TempEventLogClass> departmentEvents() {
    if (returnShopProvider()
            .userShop()
            ?.manageDepartments ==
        true) {
      if (!authorization(
        authorized: Authorizations().viewAllDepartments,
      )) {
        return logs.where((cat) {
          return cat.departmentUuid ==
              returnDepartmentProvider()
                  .currentDepartment()
                  ?.uuid;
          // }
        }).toList();
      } else {
        if (returnDepartmentProvider()
                .currentDepartment()
                ?.uuid ==
            null) {
          return logs;
        } else {
          return logs.where((cat) {
            return cat.departmentUuid ==
                returnDepartmentProvider()
                    .currentDepartment()
                    ?.uuid;
          }).toList();
        }
      }
    } else {
      return logs;
    }
  }

  List<TempEventLogClass> returnLogs() {
    departmentEvents().sort(
      (a, b) => b.createdAt!.compareTo(a.createdAt!),
    );
    if (dateSet == null &&
        rangeEndDate == null &&
        rangeStartDate == null) {
      departmentEvents().sort(
        (a, b) => b.createdAt!.compareTo(a.createdAt!),
      );
      return departmentEvents();
    } else if (dateSet != null) {
      return departmentEvents()
          .where(
            (log) =>
                !log.createdAt!.isBefore(
                  fourAm(dateSet!),
                ) &&
                log.createdAt!.isBefore(
                  fourAmNextDay(dateSet!),
                ),
          )
          .toList();
    } else {
      return departmentEvents()
          .where(
            (log) =>
                !log.createdAt!.isBefore(
                  fourAm(rangeStartDate!),
                ) &&
                log.createdAt!.isBefore(
                  fourAmNextDay(
                    rangeEndDate ??
                        resolveBusinessDate(DateTime.now()),
                  ),
                ),
          )
          .toList();
    }
  }

  Future<List<TempEventLogClass>> getEventLogs() async {
    bool isOnline = await ConnectivityProvider().isOnline();
    var shopId = returnShopProvider().userShop()!.shopId!;
    if (isOnline && EventsLogFunc().isSynced()) {
      try {
        var res = await client
            .from(tableName)
            .select()
            .eq('shop_id', shopId)
            .order('created_at', ascending: false);
        if (res.isEmpty) {
          await mainLocalLog('No Event Logs Returned');
          logs.clear();
          EventsLogFunc().clearEventsLog();
          notifyListeners();
          return [];
        }
        logs =
            res
                .map((m) => TempEventLogClass.fromJson(m))
                .toList();

        await EventsLogFunc().insertAllEventsLog(logs);
        await mainLocalLog(
          '✅✅ Events Gotten Successfully Online',
        );
        notifyListeners();

        return logs;
      } catch (e) {
        await mainLocalLog(
          '❌❌ Events Getting Online Failed: ${e.toString()}',
        );
        return [];
      }
    } else {
      logs = EventsLogFunc().getEventsLogs();

      await mainLocalLog(
        'Events Gotten Successfully Offline',
      );
      notifyListeners();
      return logs;
    }
  }

  Future<List<TempEventLogClass>>
  getEventLogsOffline() async {
    logs = EventsLogFunc().getEventsLogs();

    await mainLocalLog(
      'Events Gotten Successfully Offline',
    );
    notifyListeners();
    return logs;
  }

  Future<int> createLog(TempEventLogClass log) async {
    // if (ReportAuthAction().viewEventsLogAction()) {
    //   // bool isOnline =
    //   //     await ConnectivityProvider().isOnline();
    //   log.uuid = uuidGen();
    //   log.createdAt ??= DateTime.now();
    //   // if (isOnline) {
    //   //   try {
    //   //     Map<String, dynamic>? res =
    //   //         await client
    //   //             .from(tableName)
    //   //             .insert(log.toJson())
    //   //             .select()
    //   //             .maybeSingle();
    //   //     if (res == null) {
    //   //       await mainLocalLog('Event Logging Failed');
    //   //       return 0;
    //   //     }
    //   //     logs.add(TempEventLogClass.fromJson(res));
    //   //     await EventsLogFunc().createEventsLog(
    //   //       TempEventLogClass.fromJson(res),
    //   //     );
    //   //     notifyListeners();
    //   //     await getEventLogs();
    //   //     await mainLocalLog('✅✅ Event Logged Successfully Online');
    //   //     return 1;
    //   //   } catch (e) {
    //   //     await mainLocalLog(
    //   //       'Event Creating Online Failed: ${e.toString()}',
    //   //     );
    //   //     return 0;
    //   //   }
    //   // } else {
    //   try {
    //     await EventsLogFunc().createEventsLog(log);
    //     await CreatedEventsLogFunc().createEventLog(
    //       CreatedEventsLogClass(eventLog: log),
    //     );
    //     await getEventLogsOffline();
    //     // syncData();
    //     return 1;
    //   } catch (e) {
    //     await mainLocalLog(
    //       'Offline Event Creating Failed: ${e.toString()}',
    //     );
    //     return 0;
    //   }
    //   // }
    // } else {
    //   return 0;
    // }
    return 1;
  }

  TempEventLogClass customerAdapter(
    TempCustomersClass customer,
    int event,
  ) {
    return TempEventLogClass(
      shopId: shopId(),
      tableName: 'customers',
      title: customer.name,
      event:
          event == 1
              ? 'created'
              : event == 2
              ? 'updated'
              : 'deleted',
      message:
          event == 1
              ? 'Customer Created #${customer.uuid!.split('-').first.substring(0, 5).toUpperCase()}'
              : event == 2
              ? 'Customer Updated #${customer.uuid!.split('-').first.substring(0, 5).toUpperCase()}'
              : 'Customer Deleted #${customer.uuid!.split('-').first.substring(0, 5).toUpperCase()}',
      staffName:
          returnUserProviderSingle().currentUserMain!.name,
      departmentName:
          returnDepartmentProvider()
              .currentDepartment()
              ?.name,
      departmentUuid:
          returnDepartmentProvider()
              .currentDepartment()
              ?.uuid,
    );
  }

  TempEventLogClass expensesAdapter(
    TempExpensesClass expenses,
    int event,
  ) {
    return TempEventLogClass(
      shopId: shopId(),
      tableName: 'expenses',
      title: expenses.name,
      event:
          event == 1
              ? 'created'
              : event == 2
              ? 'updated'
              : 'deleted',
      message:
          event == 1
              ? 'Expenses Created #${expenses.uuid!.split('-').first.substring(0, 5).toUpperCase()}'
              : event == 2
              ? 'Expenses Updated #${expenses.uuid!.split('-').first.substring(0, 5).toUpperCase()}'
              : 'Expenses Deleted #${expenses.uuid!.split('-').first.substring(0, 5).toUpperCase()}',
      staffName:
          returnUserProviderSingle().currentUserMain!.name,
      departmentName:
          returnDepartmentProvider()
              .currentDepartment()
              ?.name,
      departmentUuid:
          returnDepartmentProvider()
              .currentDepartment()
              ?.uuid,
      amount: expenses.amount,
    );
  }

  TempEventLogClass subStaffAdapter(
    TempSubStaff subStaff,
    int event,
  ) {
    return TempEventLogClass(
      shopId: shopId(),
      tableName: 'sub_staff',
      title: subStaff.staffName!,
      event:
          event == 1
              ? 'created'
              : event == 2
              ? 'updated'
              : 'deleted',
      message:
          event == 1
              ? 'SubStaff Created #${subStaff.uuid!.split('-').first.substring(0, 5).toUpperCase()}'
              : event == 2
              ? 'SubStaff Updated #${subStaff.uuid!.split('-').first.substring(0, 5).toUpperCase()}'
              : 'SubStaff Deleted #${subStaff.uuid!.split('-').first.substring(0, 5).toUpperCase()}',
      staffName:
          returnUserProviderSingle().currentUserMain!.name,
      departmentName:
          returnDepartmentProvider()
              .currentDepartment()
              ?.name,
      departmentUuid:
          returnDepartmentProvider()
              .currentDepartment()
              ?.uuid,
      // amount: subStaff.amount,
    );
  }

  TempEventLogClass departmentAdapter(
    DepartmentClass department,
    int event,
  ) {
    return TempEventLogClass(
      shopId: shopId(),
      tableName: 'department',
      title: department.name,
      event:
          event == 1
              ? 'created'
              : event == 2
              ? 'updated'
              : 'deleted',
      message:
          event == 1
              ? 'Expenses Created #${department.uuid.split('-').first.substring(0, 5).toUpperCase()}'
              : event == 2
              ? 'Expenses Updated #${department.uuid.split('-').first.substring(0, 5).toUpperCase()}'
              : 'Expenses Deleted #${department.uuid.split('-').first.substring(0, 5).toUpperCase()}',
      staffName:
          returnUserProviderSingle().currentUserMain!.name,
      departmentName:
          returnDepartmentProvider()
              .currentDepartment()
              ?.name,
      departmentUuid:
          returnDepartmentProvider()
              .currentDepartment()
              ?.uuid,
      amount: null,
    );
  }

  TempEventLogClass productAdapter(
    TempProductClass product,
    int event,
  ) {
    return TempEventLogClass(
      shopId: shopId(),
      tableName: 'products',
      title: product.name,
      event:
          event == 1
              ? 'created'
              : event == 2
              ? 'updated'
              : 'deleted',
      message:
          event == 1
              ? 'Item Created #${product.uuid!.split('-').first.substring(0, 5).toUpperCase()}'
              : event == 2
              ? 'Item Updated #${product.uuid!.split('-').first.substring(0, 5).toUpperCase()}'
              : 'Item Deleted #${product.uuid!.split('-').first.substring(0, 5).toUpperCase()}',
      staffName:
          returnUserProviderSingle().currentUserMain!.name,
      departmentName:
          returnDepartmentProvider()
              .currentDepartment()
              ?.name,
      departmentUuid:
          returnDepartmentProvider()
              .currentDepartment()
              ?.uuid,
      amount: product.sellingPrice,
    );
  }

  TempEventLogClass receiptAdapter(
    TempMainReceipt receipt,
    List<String> productNames,
    int event,
  ) {
    return TempEventLogClass(
      shopId: shopId(),
      tableName: 'receipts',
      title:
          '${productNames.last} and (${productNames.length - 1}) others.',
      event:
          event == 1
              ? 'created'
              : event == 2
              ? 'updated'
              : 'deleted',
      message:
          event == 1
              ? 'New Sale Created #${receipt.uuid!.split('-').first.substring(0, 5).toUpperCase()}'
              : event == 2
              ? 'Sale Updated #${receipt.uuid!.split('-').first.substring(0, 5).toUpperCase()}'
              : 'Sale Deleted #${receipt.uuid!.split('-').first.substring(0, 5).toUpperCase()}',
      staffName:
          returnUserProviderSingle().currentUserMain!.name,
      departmentName:
          returnDepartmentProvider()
              .currentDepartment()
              ?.name,
      departmentUuid:
          returnDepartmentProvider()
              .currentDepartment()
              ?.uuid,
      amount:
          event == 3
              ? (-1 * (receipt.bank + receipt.cashAlt))
              : (receipt.bank + receipt.cashAlt),
    );
  }

  TempEventLogClass invoiceAdapter(
    TempInvoice invoice,
    List<String> productNames,
    int event,
  ) {
    return TempEventLogClass(
      shopId: shopId(),
      tableName: 'invoices',
      title:
          '${productNames.last} and (${productNames.length - 1}) others.',
      event:
          event == 1
              ? 'created'
              : event == 2
              ? 'updated'
              : 'deleted',
      message:
          event == 1
              ? 'New Invoice Created #${invoice.uuid!.split('-').first.substring(0, 5).toUpperCase()}'
              : event == 2
              ? 'Invoice Updated #${invoice.uuid!.split('-').first.substring(0, 5).toUpperCase()}'
              : 'Invoice Deleted #${invoice.uuid!.split('-').first.substring(0, 5).toUpperCase()}',
      staffName:
          returnUserProviderSingle().currentUserMain!.name,
      departmentName:
          returnDepartmentProvider()
              .currentDepartment()
              ?.name,
      departmentUuid:
          returnDepartmentProvider()
              .currentDepartment()
              ?.uuid,
      amount:
          event == 3
              ? (-1 * (invoice.bank + invoice.cashAlt))
              : (invoice.bank + invoice.cashAlt),
    );
  }

  Future<void> eventsLogSync() async {
    try {
      bool isOnline =
          await ConnectivityProvider().isOnline();
      // Prepare batch payload
      if (CreatedEventsLogFunc()
              .getCreatedEventsLogs()
              .isNotEmpty &&
          isOnline) {
        final tempEventLogs =
            CreatedEventsLogFunc()
                .getCreatedEventsLogs()
                .toList();
        // var newEvents = tempEventLogs.map((log) {
        //   log.eventLog.createdAt = log.eventLog.createdAt!;
        //   return log;
        // });
        // final payload =
        //     newEvents
        //         .map((p) => p.eventLog.toJson())
        //         .toList();

        // Insert all at once
        int count = 0;
        for (var item in tempEventLogs) {
          try {
            // Insert all at once
            await client
                .from(tableName)
                .insert(item.eventLog.toJson())
                .select();
            count++;
            await CreatedEventsLogFunc().deleteEventLog(
              item.eventLog.uuid!,
            );
          } on PostgrestException catch (e) {
            // if (e.code == '23505') {
            await CreatedEventsLogFunc().deleteEventLog(
              item.eventLog.uuid!,
            );
            await mainLocalLog(
              'Error Synchronizing Events Log ${item.eventLog.title}: $e',
            );
            // }
            // await createErrorLog(
            //   error:
            //       'Error Synchronizing Events Log ${item.eventLog.title}: $e',
            // );
          }
        }

        await mainLocalLog(
          '$count Event Log items added successfully ✅',
        );
        await CreatedEventsLogFunc().clearEvents();
        await mainLocalLog('Unsynced Event Logs Cleared');
        await mainLocalLog(
          'Mounted, refreshing Receipts ✅',
        );
        await getEventLogs();
      }
    } catch (e) {
      await mainLocalLog(
        'Batch Event Logs insert failed ❌: $e',
      );
      await createErrorLog(
        error: 'Batch Event Logs insert failed ❌: $e',
      );
    }
  }

  // List<TempEventLogClass> testLogs = [
  //   TempEventLogClass(
  //     uuid: uuidGen(),
  //     shopId: 12,
  //     tableName: 'products',
  //     title: 'Beans and Rice',
  //     event: 'updated',
  //     amount: 18000,
  //     createdAt: DateTime.now(),
  //     message: 'A new Item is Created',
  //     staffName: 'Alex Onyeka',
  //   ),
  //   TempEventLogClass(
  //     uuid: uuidGen(),
  //     shopId: 12,
  //     tableName: 'expenses',
  //     title: 'I Ate Beans and Rice',
  //     event: 'created',
  //     amount: 5000,
  //     createdAt: DateTime.now(),
  //     message: 'A New Expenses was Created',
  //     staffName: 'Alex Onyeka',
  //   ),
  //   TempEventLogClass(
  //     uuid: uuidGen(),
  //     shopId: 12,
  //     tableName: 'shops',
  //     title: '12 Itemss Sold',
  //     event: 'deleted',
  //     amount: 12000,
  //     createdAt: DateTime.now(),
  //     message: 'A New Sales was Made',
  //     staffName: 'Alex Onyeka',
  //   ),
  // ];
}
