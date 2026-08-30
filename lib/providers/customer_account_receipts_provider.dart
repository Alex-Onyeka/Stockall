import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_customer_account_receipts/customer_account_receipts.dart';
import 'package:stockall/classes/temp_customer_account_receipts/unsynced/customer_account_update/customer_account_update.dart';
import 'package:stockall/classes/temp_customer_account_receipts/unsynced/created/created_customer_account_receipts.dart';
import 'package:stockall/classes/temp_customer_account_receipts/unsynced/deleted/deleted_customer_account_receipts.dart';
import 'package:stockall/classes/temp_customers/temp_customers_class.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/subscription/general_settings_auth.dart';
import 'package:stockall/local_database/customer_account_receipts/customer_account_receipts_func.dart';
import 'package:stockall/local_database/customer_account_receipts/unsync_funcs/customer_account_updates/customer_account_update_func.dart';
import 'package:stockall/local_database/customer_account_receipts/unsync_funcs/created/created_customer_account_receipts_func.dart';
import 'package:stockall/local_database/customer_account_receipts/unsync_funcs/deleted/deleted_customer_account_receipts_func.dart';
import 'package:stockall/local_database/customer_account_receipts/unsync_funcs/updated/updated_customer_account_receipts_func.dart';
import 'package:stockall/main.dart';
import 'package:stockall/providers/connectivity_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CustomerAccountReceiptsProvider
    extends ChangeNotifier {
  static final CustomerAccountReceiptsProvider _instance =
      CustomerAccountReceiptsProvider._internal();
  factory CustomerAccountReceiptsProvider() => _instance;
  CustomerAccountReceiptsProvider._internal();
  bool isLoading = false;
  void toggleIsLoading(bool value) {
    isLoading = value;
    mainLocalLog(
      'Customer Account Receipts is ${value ? 'Loading on' : 'Loading Off'}',
    );
    notifyListeners();
  }
  //
  //
  //

  final SupabaseClient supabase = Supabase.instance.client;
  final ConnectivityProvider connectivity =
      ConnectivityProvider();

  List<CustomerAccountReceipts> _customerAccountReceipts =
      [];

  List<CustomerAccountReceipts>
  get customerAccountReceipts => _customerAccountReceipts;

  final String tableName = 'customer_account_receipts';

  void clearCustomerAccountReceipts() {
    _customerAccountReceipts.clear();
    mainLocalLog('Customer Account Receipts Cleared');
    notifyListeners();
  }

  CustomerAccountReceipts?
  getSingleCustomerAccountReceipts({
    required String recordUuid,
  }) {
    return customerAccountReceipts
            .where((item) => item.uuid == recordUuid)
            .isNotEmpty
        ? customerAccountReceipts
            .where((item) => item.uuid == recordUuid)
            .first
        : null;
  }

  List<CustomerAccountReceipts> getACustomerReceipts({
    required String customerUuid,
  }) {
    return returnCustomerAccountReceiptsByDayOrWeek()
        .where((item) => item.customerUuid == customerUuid)
        .toList();
  }

  // CREATE a new CustomerAccountReceipts
  Future<CustomerAccountReceipts?>
  createCustomerAccountReceipts({
    required CustomerAccountReceipts customerAccountReceipt,
  }) async {
    if ((returnShopProvider()
                    .userShop()
                    ?.manageCustomerReward ==
                true ||
            returnShopProvider()
                    .userShop()
                    ?.manageCustomerAccount ==
                true) &&
        GeneralSettingsAuthAction()
                .manageCustomersAccountAndPoints(
                  context: null,
                ) ==
            true) {
      try {
        await mainLocalLog(
          'Customer Account Receipt/Reward Creation Started',
        );
        if (customerAccountReceipt.isAdd &&
            customerAccountReceipt.title == null) {
          if (customerAccountReceipt.isBalance ?? true) {
            customerAccountReceipt.title =
                'Account Credited';
          } else {
            customerAccountReceipt.title = 'Reward Earned';
          }
        } else {
          if (customerAccountReceipt.isBalance ?? true) {
            customerAccountReceipt.title =
                'Account Debited';
          } else {
            customerAccountReceipt.title =
                'Reward Deducted';
          }
        }
        customerAccountReceipt.uuid = uuidGen();
        customerAccountReceipt.createdAt = DateTime.now();
        customerAccountReceipt.shopId = shopId();
        customerAccountReceipt.staffId =
            currentUser().userId;
        customerAccountReceipt.staffName =
            currentUser().name;

        await CustomerAccountReceiptsFunc()
            .createCustomerAccountReceipts(
              customerAccountReceipt,
            );
        await CreatedCustomerAccountReceiptsFunc()
            .createCustomerAccountReceipts(
              CreatedCustomerAccountReceipts(
                createdCustomerAccountReceipts:
                    customerAccountReceipt,
              ),
            );
        List<TempCustomersClass> customers =
            returnCustomersSingle().customers
                .where(
                  (item) =>
                      item.uuid ==
                      customerAccountReceipt.customerUuid,
                )
                .toList();
        if (customers.isNotEmpty) {
          var customerOld = customers.first;
          var customer = customerOld.copyWith();
          CustomerAccountUpdate accountUpdate =
              CustomerAccountUpdate(
                amount:
                    (customerAccountReceipt.amount ?? 0),
                customerUuid: customer.uuid!,
                isIncrement: true,
                isBalance: false,
                createdAt: DateTime.now(),
                uuid: uuidGen(),
              );
          if (customerAccountReceipt.isAdd) {
            if (customerAccountReceipt.isBalance ?? true) {
              customerAccountReceipt.oldBalance =
                  customerOld.balance;
              customer.balance =
                  (customer.balance ?? 0) +
                  (customerAccountReceipt.amount ?? 0);
              accountUpdate.isBalance = true;
              customerAccountReceipt.newBalance =
                  customer.balance;
            } else {
              customerAccountReceipt.oldBalance =
                  customerOld.cashReward;
              customer.cashReward =
                  (customer.cashReward ?? 0) +
                  (customerAccountReceipt.amount ?? 0);
              accountUpdate.isBalance = false;
              customerAccountReceipt.newBalance =
                  customer.cashReward;
            }
            accountUpdate.isIncrement = true;
          } else {
            if (customerAccountReceipt.isBalance ?? true) {
              customerAccountReceipt.oldBalance =
                  customerOld.balance;
              double amount =
                  customerAccountReceipt.amount ?? 0;

              double balance = customer.balance ?? 0;

              customer.balance = balance - amount;
              accountUpdate.isBalance = true;
              customerAccountReceipt.newBalance =
                  customer.balance;
            } else {
              customerAccountReceipt.oldBalance =
                  customerOld.cashReward;
              double amount =
                  customerAccountReceipt.amount ?? 0;

              double cashReward = customer.cashReward ?? 0;

              customer.cashReward = cashReward - amount;
              accountUpdate.isBalance = false;
              customerAccountReceipt.newBalance =
                  customer.cashReward;
            }
            accountUpdate.isIncrement = false;
          }
          await CustomerAccountUpdateFunc()
              .createCustomerAccountUpdate(accountUpdate);
          await returnCustomersSingle().updateCustomerMain(
            customer,
          );
        }
        await getCustomerAccountReceiptsOffline();
        return customerAccountReceipt;
      } catch (e) {
        await mainLocalLog(
          'Error Creating Customer Account Receipt : ${e.toString()}',
        );
        return null;
      }
    } else {
      return null;
    }
  }

  // READ all CustomerAccountReceipts for a shop
  Future<List<CustomerAccountReceipts>>
  getCustomerAccountReceipts(int shopId) async {
    bool isOnline = await connectivity.isOnline();
    if (isOnline &&
        CustomerAccountReceiptsFunc().isSynced() &&
        authorization(
          authorized: Authorizations().viewCustomersAccount,
        ) &&
        GeneralSettingsAuthAction()
            .manageCustomersAccountAndPoints(
              context: null,
            ) &&
        returnShopProvider()
                .userShop()
                ?.manageCustomerAccount ==
            true) {
      await CustomerAccountReceiptsFunc()
          .clearCustomerAccountReceipts();
      try {
        final data = await supabase
            .from(tableName)
            .select()
            .eq('shop_id', shopId)
            .order('created_at', ascending: false);
        if (data.isNotEmpty) {
          await mainLocalLog(
            'Customer Account Receipts Gotten ${data.length}',
          );
        }

        _customerAccountReceipts =
            (data as List)
                .map(
                  (json) =>
                      CustomerAccountReceipts.fromJson(
                        json,
                      ),
                )
                .toList();
        await CustomerAccountReceiptsFunc()
            .insertAllCustomerAccountReceipts(
              _customerAccountReceipts,
            );
        await mainLocalLog('Loaded');
        notifyListeners();
      } catch (e) {
        await mainLocalLog(
          '❌ Error Getting Customer Account Receipts: ${e.toString()}',
        );
        return [];
      }
    } else {
      _customerAccountReceipts =
          CustomerAccountReceiptsFunc()
              .getCustomerAccountReceipts();
      await mainLocalLog(
        'Offline Customer Account Receipts Gotten',
      );
      notifyListeners();
    }
    notifyListeners();
    return _customerAccountReceipts;
  }

  Future<List<CustomerAccountReceipts>>
  getCustomerAccountReceiptsOffline() async {
    _customerAccountReceipts =
        CustomerAccountReceiptsFunc()
            .getCustomerAccountReceipts();
    await mainLocalLog(
      'Offline Customer Account Receipts Gotten',
    );
    notifyListeners();
    return _customerAccountReceipts;
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

  // DELETE a CustomerAccountReceipts
  Future<int> deleteCustomerAccountReceipts({
    required List<CustomerAccountReceipts> customerReceipts,
    required bool? updateCustomerBalance,
  }) async {
    await mainLocalLog(
      'Deleting Customer Account Receipts',
    );
    try {
      await mainLocalLog(
        'Deleting Customer Account Receipts Offline',
      );
      for (var customerAccountReceipt in customerReceipts) {
        await CustomerAccountReceiptsFunc()
            .deleteCustomerAccountReceipts(
              customerAccountReceipt.uuid!,
            );
        var containsCreated =
            CreatedCustomerAccountReceiptsFunc()
                .getCustomerAccountReceipts()
                .where(
                  (productRecord) =>
                      productRecord
                          .createdCustomerAccountReceipts
                          .uuid ==
                      customerAccountReceipt.uuid,
                )
                .toList();
        var containsUpdate =
            UpdatedCustomerAccountReceiptsFunc()
                .getCustomerAccountReceiptsIds()
                .where(
                  (productRecord) =>
                      productRecord
                          .updatedCustomerAccountReceipts
                          .uuid ==
                      customerAccountReceipt.uuid!,
                );
        if (containsCreated.isNotEmpty) {
          await CreatedCustomerAccountReceiptsFunc()
              .deleteCustomerAccountReceipt(
                customerAccountReceipt.uuid!,
              );
        } else {
          await DeletedCustomerAccountReceiptsFunc()
              .createDeletedCustomerAccountReceipts(
                DeletedCustomerAccountReceipts(
                  customerAccountReceiptUuid:
                      customerAccountReceipt.uuid!,
                ),
              );
        }
        if (containsUpdate.isNotEmpty) {
          await UpdatedCustomerAccountReceiptsFunc()
              .deleteUpdatedCustomerAccountReceipts(
                customerAccountReceipt.uuid!,
              );
        }
        if (updateCustomerBalance == true) {
          if (customerAccountReceipt.customerUuid != null) {
            List<TempCustomersClass> customers =
                returnCustomersSingle().customers
                    .where(
                      (item) =>
                          item.uuid ==
                          customerAccountReceipt
                              .customerUuid,
                    )
                    .toList();
            if (customers.isNotEmpty) {
              var customerOld = customers.first;
              var customer = customerOld.copyWith();
              CustomerAccountUpdate customerAccountUpdate =
                  CustomerAccountUpdate(
                    amount: 0,
                    customerUuid: customer.uuid ?? '',
                    isIncrement: false,
                    isBalance: false,
                    createdAt: DateTime.now(),
                    uuid: uuidGen(),
                  );
              if (customerAccountReceipt.isBalance ??
                  true) {
                customerAccountReceipt.oldBalance =
                    customerOld.balance;
                double amount =
                    customerAccountReceipt.amount ?? 0;

                double balance = customer.balance ?? 0;

                if (customerAccountReceipt.isAdd) {
                  customer.balance = balance - amount;
                  customerAccountUpdate.isBalance = true;
                  customerAccountUpdate.isIncrement = false;
                } else {
                  customer.balance = balance + amount;
                  customerAccountUpdate.isBalance = true;
                  customerAccountUpdate.isIncrement = true;
                }
                customerAccountUpdate.amount = amount;
                customerAccountReceipt.newBalance =
                    customer.balance;
              } else {
                customerAccountReceipt.oldBalance =
                    customerOld.cashReward;
                double amount =
                    customerAccountReceipt.amount ?? 0;

                double cashReward =
                    customer.cashReward ?? 0;

                customer.cashReward = cashReward - amount;
                customerAccountUpdate.isBalance = false;
                customerAccountUpdate.isIncrement = false;
                customerAccountUpdate.amount = amount;
                customerAccountReceipt.newBalance =
                    customer.cashReward;
              }
              await CustomerAccountUpdateFunc()
                  .createCustomerAccountUpdate(
                    customerAccountUpdate,
                  );
              await returnCustomersSingle()
                  .updateCustomerMain(customer);
            }
          }
          // syncData();
        } else {
          // syncData();
        }

        await mainLocalLog(
          '✅ Customer Account Receipts succesfully Delete.',
        );
      }
      notifyListeners();
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Error Deleting Customer Account Receipts: ${e.toString()}',
      );
      return 0;
    }
  }

  //
  //
  //
  //

  Future<void> createCustomerAccountReceiptsSync() async {
    try {
      bool isOnline = await connectivity.isOnline();
      // Prepare batch payload
      if (CreatedCustomerAccountReceiptsFunc()
              .getCustomerAccountReceipts()
              .isNotEmpty &&
          isOnline) {
        // final tempAccountUpdates =
        //     CustomerAccountUpdateFunc()
        //         .getQuantitiesUpdate()
        //         .toList()
        //         .map((item) {
        //           return {
        //             "customerUuid": item.customerUuid,
        //             "amount": item.amount,
        //             "isIncrement": item.isIncrement,
        //             'isBalance': item.isBalance,
        //           };
        //         })
        //         .toList();

        // await supabase.rpc(
        //   'update_customer_account',
        //   params: {'updates': tempAccountUpdates},
        // );

        // await CustomerAccountUpdateFunc()
        //     .clearQuantitiesUpdate();
        final tempCustomerAccountReceipts =
            CreatedCustomerAccountReceiptsFunc()
                .getCustomerAccountReceipts()
                .toList();
        var newCustomerAccountReceipts =
            tempCustomerAccountReceipts.map((rec) {
              rec.createdCustomerAccountReceipts.createdAt =
                  rec
                      .createdCustomerAccountReceipts
                      .createdAt
                      ?.toUtc();
              return rec;
            });
        final payload =
            newCustomerAccountReceipts
                .map(
                  (p) =>
                      p.createdCustomerAccountReceipts
                          .toJson(),
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
        await CreatedCustomerAccountReceiptsFunc()
            .clearCustomerAccountReceipts();
        await mainLocalLog(
          'Unsynced Customer Account Receipts Cleared',
        );

        await mainLocalLog(
          'Mounted, refreshing Customer Account Receipts ✅',
        );
        await getCustomerAccountReceipts(
          returnShopProvider().userShop()!.shopId!,
        );
      }
    } catch (e) {
      await mainLocalLog(
        'Batch Customer Account Receipts insert failed ❌: $e',
      );
    }
  }

  Future<void> customerAccountUpdateSync() async {
    try {
      bool isOnline = await connectivity.isOnline();
      // Prepare batch payload
      if (CustomerAccountUpdateFunc()
              .getQuantitiesUpdate()
              .isNotEmpty &&
          isOnline) {
        final tempAccountUpdates =
            CustomerAccountUpdateFunc()
                .getQuantitiesUpdate()
                .toList()
                .map((item) {
                  return {
                    "customerUuid": item.customerUuid,
                    "amount": item.amount,
                    "isIncrement": item.isIncrement,
                    'isBalance': item.isBalance,
                  };
                })
                .toList();
        await mainLocalLog(
          '❌🔥❌❌🔥❌❌❌❌❌❌❌🔥Customer Updates Length: ${tempAccountUpdates.length}',
        );

        await supabase.rpc(
          'update_customer_account',
          params: {'updates': tempAccountUpdates},
        );

        await CustomerAccountUpdateFunc()
            .clearQuantitiesUpdate();

        await mainLocalLog(
          'Unsynced Customer Account Updates Cleared',
        );

        await mainLocalLog(
          '❌🔥❌❌🔥❌❌❌❌❌❌❌🔥Mounted, refreshing Customer Account Updates ✅',
        );
      }
    } catch (e) {
      await mainLocalLog(
        'Batch Customer Account Updates insert failed ❌: $e',
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

  Future<void> deleteCustomerAccountReceiptsSync() async {
    try {
      bool isOnline = await connectivity.isOnline();
      // Prepare batch payload
      if (DeletedCustomerAccountReceiptsFunc()
              .getCustomerAccountReceiptsIds()
              .isNotEmpty &&
          isOnline) {
        final tempCustomerAccountReceipts =
            DeletedCustomerAccountReceiptsFunc()
                .getCustomerAccountReceiptsIds()
                .toList();

        for (var rec in tempCustomerAccountReceipts) {
          await supabase
              .from(tableName)
              .delete()
              .eq('uuid', rec.customerAccountReceiptUuid);
        }

        await mainLocalLog(
          '${tempCustomerAccountReceipts.length} Customer Account Receipts Created succesfully ✅',
        );
        await DeletedCustomerAccountReceiptsFunc()
            .clearDeletedCustomerAccountReceipts();
        await mainLocalLog(
          'Unsynced Deleted Customer Account Receipts Cleared',
        );

        await mainLocalLog(
          'Mounted, refreshing Customer Account Receipts ✅',
        );
        await getCustomerAccountReceipts(
          returnShopProvider().userShop()!.shopId!,
        );
      }
    } catch (e) {
      await mainLocalLog(
        'Batch Customer Account Receipts Deleted failed ❌: $e',
      );
    }
  }

  //
  //
  //
  //

  Future<void> updateCustomerAccountReceiptsSync() async {
    try {
      bool isOnline = await connectivity.isOnline();
      await mainLocalLog(
        UpdatedCustomerAccountReceiptsFunc()
            .getCustomerAccountReceiptsIds()
            .length
            .toString(),
      );

      if (UpdatedCustomerAccountReceiptsFunc()
              .getCustomerAccountReceiptsIds()
              .isNotEmpty &&
          isOnline) {
        final updatedCustomerAccountReceipts =
            UpdatedCustomerAccountReceiptsFunc()
                .getCustomerAccountReceiptsIds();

        for (final updated
            in updatedCustomerAccountReceipts) {
          final localCustomerAccountReceipts =
              updated.updatedCustomerAccountReceipts;

          localCustomerAccountReceipts.updatedAt ??=
              DateTime.now().toLocal();

          if (localCustomerAccountReceipts.uuid == null) {
            await mainLocalLog(
              'Local Customer Account Receipts Uuid is Null',
            );
          }
          final remoteData =
              await supabase
                  .from(tableName)
                  .select('uuid, updated_at')
                  .eq(
                    'uuid',
                    localCustomerAccountReceipts.uuid!,
                  )
                  .maybeSingle();

          if (remoteData == null) {
            await supabase
                .from(tableName)
                .insert(
                  localCustomerAccountReceipts.toJson(),
                );
            await mainLocalLog(
              'Inserted product with uuid ${localCustomerAccountReceipts.uuid}',
            );
            await UpdatedCustomerAccountReceiptsFunc()
                .deleteUpdatedCustomerAccountReceipts(
                  localCustomerAccountReceipts.uuid ?? '',
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

            localCustomerAccountReceipts.updatedAt =
                (localCustomerAccountReceipts.updatedAt ??
                        DateTime.now())
                    .toUtc(); // ✅ keep both UTC
            await mainLocalLog(
              "Local updatedAt: ${localCustomerAccountReceipts.updatedAt}",
            );
            await mainLocalLog(
              "Remote updatedAt: $remoteUpdatedAt",
            );

            if (remoteUpdatedAt == null ||
                localCustomerAccountReceipts.updatedAt!
                    .isAfter(remoteUpdatedAt)) {
              await supabase
                  .from(tableName)
                  .update(
                    localCustomerAccountReceipts.toJson(),
                  )
                  .eq(
                    'uuid',
                    localCustomerAccountReceipts.uuid!,
                  );
              await mainLocalLog(
                'Updated CustomerAccountReceipts with uuid ${localCustomerAccountReceipts.uuid}',
              );
              await UpdatedCustomerAccountReceiptsFunc()
                  .deleteUpdatedCustomerAccountReceipts(
                    localCustomerAccountReceipts.uuid ?? '',
                  );
            } else {
              await mainLocalLog(
                'Skipped Customer Account Receipts ${localCustomerAccountReceipts.uuid}, remote is newer ✅',
              );
            }
          }
        }

        await UpdatedCustomerAccountReceiptsFunc()
            .clearUpdatedCustomerAccountReceiptsRecord();
        await mainLocalLog(
          'Unsynced Customer Account Receipts products cleared',
        );
        await mainLocalLog(
          'Mounted, refreshing Customer Account Receipts ✅',
        );
        await getCustomerAccountReceipts(
          returnShopProvider().userShop()!.shopId!,
        );
      }
    } catch (e) {
      await mainLocalLog(
        'Batch Customer Account Receipts update failed ❌: $e',
      );
    }
  }
  //
  //

  //
  //
  //

  List<CustomerAccountReceipts>
  returnCustomerAccountReceiptsByDayOrWeek() {
    if (returnShopProvider()
            .userShop()
            ?.manageDepartments ==
        true) {
      if (rangeStartDate != null) {
        return customerAccountReceipts.where((
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

        return customerAccountReceipts
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
          return customerAccountReceipts.where((
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
          return customerAccountReceipts.where((
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
          return customerAccountReceipts
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
          return customerAccountReceipts
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
}
