import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_production_folder/temp_productions/production_record.dart';
import 'package:stockall/classes/temp_production_folder/temp_productions/production_record_materials.dart';
import 'package:stockall/classes/temp_production_folder/temp_productions/unsynced/created_productions/created_production_record.dart';
import 'package:stockall/classes/temp_production_folder/temp_productions/unsynced/deleted_productions/deleted_production_record.dart';
import 'package:stockall/classes/temp_production_folder/temp_productions/unsynced/updated/updated_production_record.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/local_database/productions/production_records_func.dart';
import 'package:stockall/local_database/productions/unsync_funcs/created/created_production_record_func.dart';
import 'package:stockall/local_database/productions/unsync_funcs/deleted/deleted_production_records_func.dart';
import 'package:stockall/local_database/productions/unsync_funcs/updated/updated_production_records_func.dart';
import 'package:stockall/main.dart';
import 'package:stockall/providers/connectivity_provider.dart';
import 'package:stockall/providers/error_log_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductionRecordsProvider extends ChangeNotifier {
  static final ProductionRecordsProvider _instance =
      ProductionRecordsProvider._internal();
  factory ProductionRecordsProvider() => _instance;
  ProductionRecordsProvider._internal();
  bool isLoading = false;
  void toggleIsLoading(bool value) {
    isLoading = value;
    mainLocalLog(
      'Production Records is ${value ? 'Loading on' : 'Loading Off'}',
    );
    notifyListeners();
  }
  //
  //
  //

  final SupabaseClient supabase = Supabase.instance.client;
  final ConnectivityProvider connectivity =
      ConnectivityProvider();
  // ignore: prefer_final_fields
  List<ProductionRecord> _productionRecords = [
    ProductionRecord(
      comment:
          'This is a comment for the first time in many days',
      customCost: null,
      totalCost: null,
      isGroup: true,
      qttyPerGroup: 10,
      unit: 'Beans',
      uuid: uuidGen(),
      createdAt: DateTime.now(),
      shopId: 379,
      materials: [
        ProductionRecordMaterials(
          customCost: null,
          unit: 'Yam',
          productionRecordId: uuidGen(),
          qttyPerGroup: 12,
          uuid: uuidGen(),
          quantity: 20,
          materialName: 'Red Oil',
          materialUuid: uuidGen(),
          isGroup: false,
          totalCost: 2000,
          createdAt: DateTime.now(),
          departmentName: null,
          departmentUuid: null,
          staffName: currentUser().name,
          staffUuid: currentUser().userId,
          productionRecordName: 'Beans and Rice',
        ),
      ],
      itemName: 'Beans And Rice',
      itemUuid: uuidGen(),
      quantity: 24,
      staffId: currentUser().userId!,
      staffName: currentUser().name,
    ),
  ];
  List<ProductionRecord> get productionRecords =>
      _productionRecords;

  final String tableName = 'production_records';

  void clearProductionRecords() {
    _productionRecords.clear();
    mainLocalLog('Production Records Cleared');
    notifyListeners();
  }

  // CREATE a new ProductionRecords
  Future<ProductionRecord?> createProductionRecord(
    ProductionRecord productionRecord,
  ) async {
    await mainLocalLog(
      'Inner Production Records Creation Started',
    );
    bool isOnline = await connectivity.isOnline();
    if (isOnline) {
      productionRecord.createdAt = DateTime.now();
      try {
        final res =
            await supabase
                .from(tableName)
                .upsert(
                  productionRecord.toJson(),
                  onConflict: 'uuid',
                )
                .select()
                .single();
        final newProductionRecords =
            ProductionRecord.fromJson(res);
        notifyListeners();
        // await getProductionRecords(shopId());
        return newProductionRecords;
      } catch (e) {
        await mainLocalLog(
          '❌❌ Create Production Records Error Online: ${e.toString()}',
        );
        return null;
      }
    } else {
      try {
        productionRecord.createdAt = DateTime.now();
        await ProductionRecordsFunc()
            .createProductionRecord(productionRecord);
        await CreatedProductionRecordsFunc()
            .createProductions(
              CreatedProductionRecord(
                createdProductionRecord: productionRecord,
              ),
            );
        notifyListeners();
        // await getProductionRecords(shopId());
        return productionRecord;
      } catch (e) {
        await mainLocalLog(
          '❌❌ Create Production Records Error Offline: ${e.toString()}',
        );
        return null;
      }
    }
  }

  // CREATE a new ProductionRecords
  Future<ProductionRecord?> updateProductionRecords(
    ProductionRecord productionRecord,
  ) async {
    await mainLocalLog(
      'Inner Production Records Update Started',
    );
    bool isOnline = await connectivity.isOnline();
    productionRecord.updatedAt = DateTime.now();
    if (isOnline) {
      try {
        final res =
            await supabase
                .from(tableName)
                .upsert(
                  productionRecord.toJson(),
                  onConflict: 'uuid',
                )
                .select()
                .single();
        final newProductionRecords =
            ProductionRecord.fromJson(res);
        notifyListeners();
        await getProductionRecords(shopId());
        return newProductionRecords;
      } catch (e) {
        await mainLocalLog(
          '❌❌ Update Production Records Error Online: ${e.toString()}',
        );
        return null;
      }
    } else {
      productionRecord.updatedAt = DateTime.now().add(
        Duration(days: 1),
      );
      try {
        var res = await ProductionRecordsFunc()
            .createProductionRecord(productionRecord);
        if (res == 1) {
          var containsCreated =
              CreatedProductionRecordsFunc()
                  .getProductions()
                  .where(
                    (createdProduct) =>
                        createdProduct
                            .createdProductionRecord
                            .uuid ==
                        productionRecord.uuid,
                  )
                  .toList();
          if (containsCreated.isEmpty) {
            await UpdatedProductionRecordsFunc()
                .createUpdatedProductionRecords(
                  UpdatedProductionRecord(
                    updatedProductionRecord:
                        productionRecord,
                  ),
                );
          } else {
            await CreatedProductionRecordsFunc()
                .createProductions(
                  CreatedProductionRecord(
                    createdProductionRecord:
                        productionRecord,
                  ),
                );
          }
        } else {
          notifyListeners();
          return null;
        }
        await getProductionRecords(shopId());
        syncData();
        return productionRecord;
      } catch (e) {
        await mainLocalLog(
          '❌❌ Create Production Records Error Offline: ${e.toString()}',
        );
        return null;
      }
    }
  }

  // READ all ProductionRecords for a shop
  Future<List<ProductionRecord>> getProductionRecords(
    int shopId,
  ) async {
    // bool isOnline = await connectivity.isOnline();
    // if (isOnline &&
    //     ProductionRecordsFunc().isSynced() &&
    //     authorization(
    //       authorized: Authorizations().viewProductions,
    //     ) &&
    //     GeneralSettingsAuthAction().manageProductions(
    //       context: null,
    //     )) {
    //   await ProductionRecordsFunc()
    //       .clearProductionRecords();
    //   try {
    //     final data = await supabase
    //         .from(tableName)
    //         .select()
    //         .eq('shop_id', shopId)
    //         .order('created_at', ascending: false);
    //     if (data.isNotEmpty) {
    //       await mainLocalLog(
    //         'Production Records Gotten ${data.length}',
    //       );
    //     }

    //     _productionRecords =
    //         (data as List)
    //             .map(
    //               (json) => ProductionRecord.fromJson(json),
    //             )
    //             .toList();
    //     await ProductionRecordsFunc()
    //         .insertAllProductionRecords(_productionRecords);
    //     await mainLocalLog('Loaded');
    //     notifyListeners();
    //   } catch (e) {
    //     await mainLocalLog(
    //       '❌ Error Getting Production Records: ${e.toString()}',
    //     );
    //     return [];
    //   }
    // } else {
    //   _productionRecords =
    //       ProductionRecordsFunc().getProductionRecords();
    //   await mainLocalLog(
    //     'Offline Production Records Gotten',
    //   );
    //   notifyListeners();
    // }
    // notifyListeners();
    return _productionRecords;
  }

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

  // DELETE a ProductionRecords
  Future<int> deleteProductionRecords(
    ProductionRecord productionRecord,
    bool? updateInventory,
    bool createUpdate,
  ) async {
    await mainLocalLog('Deleting Production Records');
    try {
      await mainLocalLog(
        'Deleting Production Records Offline',
      );
      await ProductionRecordsFunc().deleteProductionRecord(
        productionRecord.uuid!,
      );
      var containsCreated =
          CreatedProductionRecordsFunc()
              .getProductions()
              .where(
                (productRecord) =>
                    productRecord
                        .createdProductionRecord
                        .uuid ==
                    productionRecord.uuid,
              )
              .toList();
      var containsUpdate = UpdatedProductionRecordsFunc()
          .getProductionIds()
          .where(
            (productRecord) =>
                productRecord
                    .updatedProductionRecord
                    .uuid ==
                productionRecord.uuid!,
          );
      if (containsCreated.isNotEmpty) {
        await CreatedProductionRecordsFunc()
            .deleteProduction(productionRecord.uuid!);
      } else {
        await DeletedProductionRecordsFunc()
            .createDeletedProductionRecords(
              DeletedProductionRecord(
                productionRecordUuid:
                    productionRecord.uuid!,
              ),
            );
      }
      if (containsUpdate.isNotEmpty) {
        await UpdatedProductionRecordsFunc()
            .deleteUpdatedProductionRecords(
              productionRecord.uuid!,
            );
      }
      returnData().syncData();

      await mainLocalLog(
        '✅ Production Records succesfully Delete.',
      );
      notifyListeners();
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Error Deleting Production Records: ${e.toString()}',
      );
      return 0;
    }
  }

  //
  //
  //
  //

  Future<void> createProductionRecordSync() async {
    try {
      bool isOnline = await connectivity.isOnline();
      // Prepare batch payload
      if (CreatedProductionRecordsFunc()
              .getProductions()
              .isNotEmpty &&
          isOnline) {
        final tempProductionRecords =
            CreatedProductionRecordsFunc()
                .getProductions()
                .toList();
        var newProductionRecords = tempProductionRecords
            .map((rec) {
              rec.createdProductionRecord.createdAt =
                  rec.createdProductionRecord.createdAt
                      ?.toUtc();
              return rec;
            });
        final payload =
            newProductionRecords
                .map(
                  (p) => p.createdProductionRecord.toJson(),
                )
                .toList();

        // Insert all at once
        final data =
            await supabase
                .from(tableName)
                .insert(payload)
                .select();

        await mainLocalLog(
          '${data.length} items added succesfully ✅',
        );
        await CreatedProductionRecordsFunc()
            .clearProductions();
        await mainLocalLog(
          'Unsynced Production Records Cleared',
        );

        await mainLocalLog(
          'Mounted, refreshing Production Records ✅',
        );
        await getProductionRecords(
          returnShopProvider().userShop()!.shopId!,
        );
      }
    } catch (e) {
      await mainLocalLog(
        'Batch Production Records insert failed ❌: $e',
      );
      await createErrorLog(
        error:
            'Batch Production Records insert failed ❌: $e',
      );
    }
  }

  //
  //
  //
  //
  //

  //
  //
  //
  //
  //

  Future<void> deleteProductionRecordsSync() async {
    try {
      bool isOnline = await connectivity.isOnline();
      // Prepare batch payload
      if (DeletedProductionRecordsFunc()
              .getProductionIds()
              .isNotEmpty &&
          isOnline) {
        final tempProductionRecords =
            DeletedProductionRecordsFunc()
                .getProductionIds()
                .toList();

        for (var rec in tempProductionRecords) {
          await supabase
              .from(tableName)
              .delete()
              .eq('uuid', rec.productionRecordUuid);
          // await DeletedProductionRecordsFunc()
          //     .deletedDeletedProductionRecords(rec.productionRecordUuid);
        }

        await mainLocalLog(
          '${tempProductionRecords.length} Production Records Created succesfully ✅',
        );
        await DeletedProductionRecordsFunc()
            .clearDeletedProductionRecords();
        await mainLocalLog(
          'Unsynced Deleted Production Records Cleared',
        );

        await mainLocalLog(
          'Mounted, refreshing Production Records ✅',
        );
        await getProductionRecords(
          returnShopProvider().userShop()!.shopId!,
        );
      }
    } catch (e) {
      await mainLocalLog(
        'Batch Production Records Deleted failed ❌: $e',
      );
      await createErrorLog(
        error:
            'Batch Production Records Delete failed ❌: $e',
      );
    }
  }

  //
  //
  //
  //

  Future<void> updateProductionRecordsSync() async {
    try {
      bool isOnline = await connectivity.isOnline();
      await mainLocalLog(
        UpdatedProductionRecordsFunc()
            .getProductionIds()
            .length
            .toString(),
      );

      if (UpdatedProductionRecordsFunc()
              .getProductionIds()
              .isNotEmpty &&
          isOnline) {
        final updatedProductionRecords =
            UpdatedProductionRecordsFunc()
                .getProductionIds();

        for (final updated in updatedProductionRecords) {
          final localProductionRecords =
              updated.updatedProductionRecord;

          localProductionRecords.updatedAt ??=
              DateTime.now().toLocal();

          if (localProductionRecords.uuid == null) {
            await mainLocalLog(
              'Local Production Records Uuid is Null',
            );
          }
          final remoteData =
              await supabase
                  .from(tableName)
                  .select('uuid, updated_at')
                  .eq('uuid', localProductionRecords.uuid!)
                  .maybeSingle();

          if (remoteData == null) {
            await supabase
                .from(tableName)
                .insert(localProductionRecords.toJson());
            await mainLocalLog(
              'Inserted product with uuid ${localProductionRecords.uuid}',
            );
            await UpdatedProductionRecordsFunc()
                .deleteUpdatedProductionRecords(
                  localProductionRecords.uuid ?? '',
                );
          } else {
            final remoteUpdatedAtRaw =
                remoteData['updated_at'];
            final remoteUpdatedAt =
                remoteUpdatedAtRaw == null
                    ? null
                    : DateTime.parse(
                      remoteUpdatedAtRaw,
                    ).toUtc();

            localProductionRecords.updatedAt =
                (localProductionRecords.updatedAt ??
                        DateTime.now())
                    .toUtc(); // ✅ keep both UTC
            await mainLocalLog(
              "Local updatedAt: ${localProductionRecords.updatedAt}",
            );
            await mainLocalLog(
              "Remote updatedAt: $remoteUpdatedAt",
            );

            if (remoteUpdatedAt == null ||
                localProductionRecords.updatedAt!.isAfter(
                  remoteUpdatedAt,
                )) {
              await supabase
                  .from(tableName)
                  .update(localProductionRecords.toJson())
                  .eq('uuid', localProductionRecords.uuid!);
              await mainLocalLog(
                'Updated ProductionRecords with uuid ${localProductionRecords.uuid}',
              );
              await UpdatedProductionRecordsFunc()
                  .deleteUpdatedProductionRecords(
                    localProductionRecords.uuid ?? '',
                  );
            } else {
              await mainLocalLog(
                'Skipped Production Records ${localProductionRecords.uuid}, remote is newer ✅',
              );
            }
          }
        }

        await UpdatedProductionRecordsFunc()
            .clearUpdatedProductionRecordsRecord();
        await mainLocalLog(
          'Unsynced Production Records products cleared',
        );
        await mainLocalLog(
          'Mounted, refreshing Production Records ✅',
        );
        await getProductionRecords(
          returnShopProvider().userShop()!.shopId!,
        );
      }
    } catch (e) {
      await mainLocalLog(
        'Batch Production Records update failed ❌: $e',
      );
      await createErrorLog(
        error:
            'Batch Production Records Update failed ❌: $e',
      );
    }
  }
  //
  //

  //
  //
  //

  List<ProductionRecord> departmentProductionRecords() {
    if (returnShopProvider()
            .userShop()
            ?.manageDepartments ==
        true) {
      if (!authorization(
        authorized: Authorizations().viewAllDepartments,
      )) {
        return productionRecords.where((cat) {
          return cat.departmentId ==
              returnDepartmentProvider()
                  .currentDepartment()
                  ?.uuid;
        }).toList();
      } else {
        if (returnDepartmentProvider()
                .currentDepartment()
                ?.uuid ==
            null) {
          return productionRecords;
        } else {
          return productionRecords.where((cat) {
            return cat.departmentId ==
                returnDepartmentProvider()
                    .currentDepartment()
                    ?.uuid;
            // }
          }).toList();
        }
      }
    } else {
      return productionRecords;
    }
  }

  List<ProductionRecord>
  returnProductionRecordsByDayOrWeek() {
    if (returnShopProvider()
            .userShop()
            ?.manageDepartments ==
        true) {
      if (rangeStartDate != null) {
        return departmentProductionRecords().where((
          productionRecord,
        ) {
          final created =
              productionRecord.createdAt!.toLocal();
          return !created.isBefore(
                fourAm(rangeStartDate!),
              ) &&
              created.isBefore(
                fourAmNextDay(
                  rangeEndDate ??
                      resolveBusinessDate(DateTime.now()),
                ),
              );
        }).toList();
      } else {
        final currentDate =
            dateSet ?? resolveBusinessDate(DateTime.now());

        return departmentProductionRecords()
            .where(
              (productionRecord) =>
                  !productionRecord.createdAt!.isBefore(
                    fourAm(currentDate),
                  ) &&
                  productionRecord.createdAt!.isBefore(
                    fourAmNextDay(currentDate),
                  ),
            )
            .toList();
      }
    } else {
      if (rangeStartDate != null) {
        if (authorization(
          authorized:
              Authorizations().viewAllTransactionRecords,
        )) {
          return productionRecords.where((
            productionRecord,
          ) {
            final created =
                productionRecord.createdAt!.toLocal();
            return !created.isBefore(
                  fourAm(rangeStartDate!),
                ) &&
                created.isBefore(
                  fourAmNextDay(
                    rangeEndDate ??
                        resolveBusinessDate(DateTime.now()),
                  ),
                );
          }).toList();
        } else {
          return productionRecords.where((
            productionRecord,
          ) {
            final created =
                productionRecord.createdAt!.toLocal();
            return !created.isBefore(
                  fourAm(rangeStartDate!),
                ) &&
                created.isBefore(
                  fourAmNextDay(
                    rangeEndDate ??
                        resolveBusinessDate(DateTime.now()),
                  ),
                ) &&
                productionRecord.staffId ==
                    currentUser().userId;
          }).toList();
        }
      } else {
        final currentDate = dateSet ?? DateTime.now();

        if (authorization(
          authorized:
              Authorizations().viewAllTransactionRecords,
        )) {
          return productionRecords
              .where(
                (productionRecord) =>
                    !productionRecord.createdAt!.isBefore(
                      fourAm(currentDate),
                    ) &&
                    !productionRecord.createdAt!.isAfter(
                      fourAmNextDay(currentDate),
                    ),
              )
              .toList();
        } else {
          return productionRecords
              .where(
                (productionRecord) =>
                    !productionRecord.createdAt!.isBefore(
                      fourAm(currentDate),
                    ) &&
                    !productionRecord.createdAt!.isAfter(
                      fourAmNextDay(currentDate),
                    ) &&
                    productionRecord.staffId ==
                        currentUser().userId,
              )
              .toList();
        }
      }
    }
  }

  double getTotalProducedInProduction({
    required List<ProductionRecord>? records,
    List<String>? recordUuids,
  }) {
    if (recordUuids != null) {
      List<ProductionRecord> tempItems = [];
      for (var item
          in returnProductionRecordsByDayOrWeek()) {
        if (recordUuids.contains(item.uuid)) {
          tempItems.add(item);
        }
      }
      return (tempItems)
          .map((item) => (item.quantity ?? 0))
          .toList()
          .fold(0, (a, b) => a + b);
    } else {
      return (records ??
              returnProductionRecordsByDayOrWeek())
          .map((item) => (item.quantity ?? 0))
          .toList()
          .fold(0, (a, b) => a + b);
    }
  }

  List<ProductionRecordMaterials>
  returnAllProductionRecordMaterials({
    required List<ProductionRecord>? productionRecords,
    List<String>? recordUuids,
  }) {
    if (recordUuids != null) {
      List<ProductionRecord> tempItems = [];
      for (var item
          in returnProductionRecordsByDayOrWeek()) {
        if (recordUuids.contains(item.uuid)) {
          tempItems.add(item);
        }
      }
      return (tempItems)
          .expand((item) => item.materials)
          .toList();
    } else {
      return (productionRecords ??
              returnProductionRecordsByDayOrWeek())
          .expand((item) => item.materials)
          .toList();
    }
  }

  double getTotalMaterialsUsed({
    required List<ProductionRecord>? productionRecords,
    List<String>? recordUuids,
  }) {
    if (recordUuids != null) {
      List<ProductionRecord> tempItems = [];
      for (var item
          in returnProductionRecordsByDayOrWeek()) {
        if (recordUuids.contains(item.uuid)) {
          tempItems.add(item);
        }
      }
      return (tempItems)
          .map((item) => item.quantity)
          .fold(0.0, (a, b) => a + (b ?? 0));
    } else {
      return returnAllProductionRecordMaterials(
            productionRecords: productionRecords,
          )
          .map((item) => item.quantity)
          .fold(0.0, (a, b) => a + b);
    }
  }

  double getTotalCostForProduction({
    required List<ProductionRecord> productionRecords,
  }) {
    double temp = 0;
    for (var item in productionRecords.expand(
      (item) => item.materials,
    )) {
      temp += (item.getTotalCost());
    }
    return temp;
  }
}
