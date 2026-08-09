import 'package:flutter/widgets.dart';
import 'package:stockall/classes/temp_production_folder/temp_production_item_history/production_item_history.dart';
import 'package:stockall/classes/temp_production_folder/temp_production_item_history/unsynced/created_production_item_history.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/subscription/general_settings_auth.dart';
import 'package:stockall/constants/subscription/items_auth.dart';
import 'package:stockall/local_database/production_item_history/production_item_histories_func.dart';
import 'package:stockall/local_database/production_item_history/unsync_funcs/created_production_item_histories_func.dart';
import 'package:stockall/main.dart';
import 'package:stockall/providers/connectivity_provider.dart';
import 'package:stockall/providers/error_log_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductionItemHistoryProvider with ChangeNotifier {
  final SupabaseClient client = Supabase.instance.client;
  final String tableName = 'production_item_history';
  static final ProductionItemHistoryProvider _instance =
      ProductionItemHistoryProvider._internal();
  factory ProductionItemHistoryProvider() => _instance;
  ProductionItemHistoryProvider._internal();

  List<ProductionItemHistory> productionItemHistories = [];

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

  List<ProductionItemHistory>
  departmentProductionItemHistories() {
    if (returnShopProvider()
            .userShop()
            ?.manageDepartments ==
        true) {
      if (!authorization(
        authorized: Authorizations().viewAllDepartments,
      )) {
        return productionItemHistories.where((cat) {
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
          return productionItemHistories;
        } else {
          return productionItemHistories.where((cat) {
            return cat.departmentUuid ==
                returnDepartmentProvider()
                    .currentDepartment()
                    ?.uuid;
            // }
          }).toList();
        }
      }
    } else {
      return productionItemHistories;
    }
  }

  List<ProductionItemHistory>
  returnProductionItemHistories() {
    departmentProductionItemHistories().sort(
      (a, b) => b.createdAt!.compareTo(a.createdAt!),
    );
    if (dateSet == null &&
        rangeEndDate == null &&
        rangeStartDate == null) {
      return departmentProductionItemHistories()
          .where(
            (productionItemHistory) =>
                !productionItemHistory.createdAt!.isBefore(
                  fourAm(dateSet ?? DateTime.now()),
                ) &&
                !productionItemHistory.createdAt!.isAfter(
                  fourAmNextDay(dateSet ?? DateTime.now()),
                ),
          )
          .toList();
    } else if (dateSet != null) {
      return departmentProductionItemHistories()
          .where(
            (productionItemHistory) =>
                !productionItemHistory.createdAt!.isBefore(
                  fourAm(dateSet!),
                ) &&
                !productionItemHistory.createdAt!.isAfter(
                  fourAmNextDay(dateSet!),
                ),
          )
          .toList();
    } else {
      return departmentProductionItemHistories()
          .where(
            (update) =>
                ((!update.createdAt!.isBefore(
                      fourAm(rangeStartDate!),
                    )) &&
                    (!update.createdAt!.isAfter(
                      fourAmNextDay(rangeEndDate!),
                    ))),
          )
          .toList();
    }
  }

  List<ProductionItemHistory>
  returnTransferedTodayHistories() {
    return returnProductionItemHistories()
        .where((item) => item.title == 'Transfered Out')
        .toList();
  }

  double getTotalTransferedOut({
    required List<ProductionItemHistory>? itemHistories,
  }) {
    return (itemHistories ??
            returnTransferedTodayHistories())
        .map((item) => (item.quantityChange ?? 0).abs())
        .fold(0, (a, b) => a + b);
  }

  Future<List<ProductionItemHistory>>
  getProductionItemHistories() async {
    bool isOnline = await ConnectivityProvider().isOnline();
    var shop = returnShopProvider().userShop()!;
    var shopId = shop.shopId!;
    if (isOnline &&
        ProductionItemHistoriesFunc().isSynced() &&
        ItemsAuthAction().trackItemHistoryAction(
          context: null,
        ) &&
        shop.manageProductions == true &&
        GeneralSettingsAuthAction().manageProductions(
          context: null,
        ) &&
        authorization(
          authorized: Authorizations().viewProductions,
        )) {
      try {
        var res = await client
            .from(tableName)
            .select()
            .eq('shop_id', shopId)
            .order('created_at', ascending: false);
        if (res.isEmpty) {
          await mainLocalLog(
            'No Production Item Histories Returned',
          );
          productionItemHistories.clear();
          ProductionItemHistoriesFunc()
              .clearProductionItemHistories();
          notifyListeners();
          return [];
        }
        productionItemHistories =
            res
                .map(
                  (m) => ProductionItemHistory.fromJson(m),
                )
                .toList();
        await ProductionItemHistoriesFunc()
            .insertAllProductionItemHistories(
              productionItemHistories,
            );
        await mainLocalLog(
          '✅✅ Production Item Histories Gotten Successfully Online',
        );
        notifyListeners();

        return productionItemHistories;
      } catch (e) {
        await mainLocalLog(
          '❌❌ Production Item Histories Getting Online Failed: ${e.toString()}',
        );
        return [];
      }
    } else {
      productionItemHistories =
          ProductionItemHistoriesFunc()
              .getProductionItemHistories();
      await mainLocalLog(
        'Production Item Histories Gotten Successfully Offline',
      );
      notifyListeners();
      return productionItemHistories;
    }
  }

  Future<List<ProductionItemHistory>>
  getProductionItemHistoriesOffline() async {
    productionItemHistories =
        ProductionItemHistoriesFunc()
            .getProductionItemHistories();
    await mainLocalLog(
      'Production Item Histories Gotten Successfully Offline',
    );
    notifyListeners();
    return productionItemHistories;
  }

  Future<int> createProductionItemHistory(
    ProductionItemHistory productionItemHistory,
  ) async {
    if (ItemsAuthAction().trackItemHistoryAction(
      context: null,
    )) {
      productionItemHistory.uuid = uuidGen();
      productionItemHistory.createdAt ??= DateTime.now();
      productionItemHistory.staffId = currentUser().userId;
      productionItemHistory.staffName = currentUser().name;
      productionItemHistory.departmentName ??=
          returnDepartmentProvider()
              .currentDepartment()
              ?.name;
      productionItemHistory.departmentUuid ??=
          returnDepartmentProvider()
              .currentDepartment()
              ?.uuid;
      try {
        await ProductionItemHistoriesFunc()
            .createProductionItemHistories(
              productionItemHistory,
            );
        await CreatedProductionItemHistoriesFunc()
            .createProductionItemHistory(
              CreatedProductionItemHistory(
                productionItemHistory:
                    productionItemHistory,
              ),
            );
        await getProductionItemHistoriesOffline();
        syncData();
        return 1;
      } catch (e) {
        await mainLocalLog(
          'Offline Creating Failed: ${e.toString()}',
        );
        return 0;
      }
    } else {
      return 0;
    }
  }

  Future<void> productionItemHistoriesSync() async {
    try {
      bool isOnline =
          await ConnectivityProvider().isOnline();
      if (CreatedProductionItemHistoriesFunc()
              .getCreatedProductionItemHistoriess()
              .isNotEmpty &&
          isOnline) {
        final tempProductionItemHistories =
            CreatedProductionItemHistoriesFunc()
                .getCreatedProductionItemHistoriess()
                .toList();
        var newProductionItemHistories =
            tempProductionItemHistories.map((
              productionItemHistory,
            ) {
              productionItemHistory
                  .productionItemHistory
                  .createdAt = productionItemHistory
                      .productionItemHistory
                      .createdAt!;
              return productionItemHistory;
            });
        final payload =
            newProductionItemHistories
                .map(
                  (p) => p.productionItemHistory.toJson(),
                )
                .toList();

        // Insert all at once
        final data =
            await client
                .from(tableName)
                .insert(payload)
                .select();

        await mainLocalLog(
          '${data.length} Production Item Histories added successfully ✅',
        );
        await CreatedProductionItemHistoriesFunc()
            .clearProductionItemHistory();
        await mainLocalLog(
          'Unsynced Production Item Histories Cleared',
        );
        await mainLocalLog(
          'Mounted, refreshing Production Item Histories ✅',
        );
        await getProductionItemHistories();
      }
    } catch (e) {
      await mainLocalLog(
        'Batch Production Item Histories insert failed ❌: $e',
      );
      await createErrorLog(
        error:
            'Batch Production Item Histories insert failed ❌: $e',
      );
    }
  }
}
