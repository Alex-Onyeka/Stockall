import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_categories/category_class.dart';
import 'package:stockall/classes/temp_categories/unsynced/created_category/created_category.dart';
import 'package:stockall/classes/temp_categories/unsynced/deleted_category/deleted_category.dart';
import 'package:stockall/classes/temp_categories/unsynced/updated/updated_category.dart';
import 'package:stockall/classes/temp_customer_account_receipts/customer_account_receipts.dart';
import 'package:stockall/classes/temp_customer_account_receipts/unsynced/created/created_customer_account_receipts.dart';
import 'package:stockall/classes/temp_customer_account_receipts/unsynced/deleted/deleted_customer_account_receipts.dart';
import 'package:stockall/classes/temp_customer_account_receipts/unsynced/updated/updated_customer_account_receipts.dart';
import 'package:stockall/classes/temp_departments_class/department_class.dart';
import 'package:stockall/classes/temp_departments_class/unsynced/created_departments/created_departments.dart';
import 'package:stockall/classes/temp_departments_class/unsynced/deleted_departments/deleted_departments.dart';
import 'package:stockall/classes/temp_departments_class/unsynced/updated/updated_departments.dart';
import 'package:stockall/classes/temp_drafts/drafts.dart';
import 'package:stockall/classes/temp_drafts/unsynced/created/created_drafts.dart';
import 'package:stockall/classes/temp_drafts/unsynced/deleted/deleted_drafts.dart';
import 'package:stockall/classes/temp_drafts/unsynced/updated/updated_drafts.dart';
import 'package:stockall/classes/temp_error_log/temp_error_log_class.dart';
import 'package:stockall/classes/temp_error_log/unsynced/created_error_log_class.dart';
import 'package:stockall/classes/temp_event_log/temp_event_log_class.dart';
import 'package:stockall/classes/temp_event_log/unsynced/created_events_log_class.dart';
import 'package:stockall/classes/temp_expenses/expense_category.dart';
import 'package:stockall/classes/temp_expenses/unsynced/created_expense_categories/created_expense_category.dart';
import 'package:stockall/classes/temp_expenses/unsynced/deleted_expense_categories/deleted_expense_category.dart';
import 'package:stockall/classes/temp_expenses/unsynced/updated_expense_categories/updated_expense_category.dart';
import 'package:stockall/classes/temp_inventory_updates/temp_inventory_update_class.dart';
import 'package:stockall/classes/temp_inventory_updates/unsynced/created_inventory_updates_class.dart';
import 'package:stockall/classes/temp_item_history/item_history.dart';
import 'package:stockall/classes/temp_item_history/unsynced/created_item_history.dart';
import 'package:stockall/classes/temp_product_class/units_class/product_units_class.dart';
import 'package:stockall/classes/temp_production_folder/temp_material_class/material_class.dart';
import 'package:stockall/classes/temp_production_folder/temp_material_class/unsynced/created_materials/created_material.dart';
import 'package:stockall/classes/temp_production_folder/temp_material_class/unsynced/deleted_materials/deleted_material.dart';
import 'package:stockall/classes/temp_production_folder/temp_material_class/unsynced/updated/updated_material.dart';
import 'package:stockall/classes/temp_production_folder/temp_materials_item_history/materials_item_history.dart';
import 'package:stockall/classes/temp_production_folder/temp_materials_item_history/unsynced/created_materials_item_history.dart';
import 'package:stockall/classes/temp_production_folder/temp_production_item_history/production_item_history.dart';
import 'package:stockall/classes/temp_production_folder/temp_production_item_history/unsynced/created_production_item_history.dart';
import 'package:stockall/classes/temp_production_folder/temp_production_items/production_item.dart';
import 'package:stockall/classes/temp_production_folder/temp_production_items/unsynced/created/created_production_item.dart';
import 'package:stockall/classes/temp_production_folder/temp_production_items/unsynced/deleted/deleted_production_item.dart';
import 'package:stockall/classes/temp_production_folder/temp_production_items/unsynced/updated/updated_production_item.dart';
import 'package:stockall/classes/temp_production_folder/temp_production_materials_usage/production_materials_usage.dart';
import 'package:stockall/classes/temp_production_folder/temp_production_materials_usage/unsynced/created/created_production_materials_usage.dart';
import 'package:stockall/classes/temp_production_folder/temp_production_materials_usage/unsynced/deleted/deleted_production_materials_usage.dart';
import 'package:stockall/classes/temp_production_folder/temp_production_materials_usage/unsynced/updated/updated_production_materials_usage.dart';
import 'package:stockall/classes/temp_production_folder/temp_productions/production_record.dart';
import 'package:stockall/classes/temp_production_folder/temp_productions/unsynced/created_productions/created_production_record.dart';
import 'package:stockall/classes/temp_production_folder/temp_productions/unsynced/deleted_productions/deleted_production_record.dart';
import 'package:stockall/classes/temp_production_folder/temp_productions/unsynced/updated/updated_production_record.dart';
import 'package:stockall/classes/temp_purchase/temp_purchase.dart';
import 'package:stockall/classes/temp_purchase/unsynced/created_purchases/created_purchases.dart';
import 'package:stockall/classes/temp_purchase/unsynced/deleted_purchase/deleted_purchases.dart';
import 'package:stockall/classes/temp_purchase/unsynced/updated/updated_purchases.dart';
import 'package:stockall/classes/temp_storage_item_history/storage_item_history.dart';
import 'package:stockall/classes/temp_storage_item_history/unsynced/created_storage_item_history.dart';
import 'package:stockall/classes/temp_storage_product/temp_storage_products.dart';
import 'package:stockall/classes/temp_storage_product/unsynced/created_storage_products/created_storage_products.dart';
import 'package:stockall/classes/temp_storage_product/unsynced/deleted_storage_products/deleted_storage_product.dart';
import 'package:stockall/classes/temp_storage_product/unsynced/updated/updated_storage_product.dart';
import 'package:stockall/classes/temp_sub_staff/temp_sub_staff.dart';
import 'package:stockall/classes/temp_sub_staff/unsynced/created_sub_staffs/created_sub_staff.dart';
import 'package:stockall/classes/temp_sub_staff/unsynced/deleted_sub_staff/deleted_sub_staff.dart';
import 'package:stockall/classes/temp_sub_staff/unsynced/updated/updated_sub_staff.dart';
import 'package:stockall/classes/temp_suppliers/suppliers_class.dart';
import 'package:stockall/classes/temp_suppliers/unsynced/created_suppliers/created_suppliers.dart';
import 'package:stockall/classes/temp_suppliers/unsynced/deleted_suppliers/deleted_supplier.dart';
import 'package:stockall/classes/temp_suppliers/unsynced/updated/updated_suppliers.dart';
import 'package:stockall/services/lan/rest/lan_queued_writes.dart';
import 'package:stockall/services/lan/rest/lan_table.dart';
import 'package:stockall/services/lan/rest/lan_table_writes.dart';

/// The other 20 tables the app syncs. Each factory takes the rows
/// (a Hive box's values, or a test's list); [moreLanTables] wires them to
/// the server's boxes and the app's queues. Column names are `toJson`
/// keys, checked by `lan_registry_parity_test`; departments follow each
/// provider's `matchesCurrentDepartment` call (field and
/// `includeUnassignedWhenDeptSelected`).
///
/// Not served, because no live app code uses them: `product_sales`,
/// `waybills`, `way_bills`.
List<LanTable<dynamic>> moreLanTables({LanStaff Function()? staff}) {
  Iterable<T> rows<T>(String box) => Hive.box<T>(box).values;
  Stream<Object?> Function() watch<T>(String box) =>
      () => Hive.box<T>(box).watch();
  final by = staff ?? () => (id: null, name: null);

  return [
    draftsTable(
      () => rows<Drafts>('mainDraftsBoxStockall'),
      changes: watch<Drafts>('mainDraftsBoxStockall'),
      writes: queuedWrites<Drafts, CreatedDrafts, UpdatedDrafts, DeletedDrafts>(
        fromJson: Drafts.fromJson,
        main: 'mainDraftsBoxStockall',
        uuidOf: (r) => r.uuid,
        created: 'createdDraftsBoxStockall',
        createdUuid: (e) => e.draft.uuid,
        toCreated: (r, json, pending) => CreatedDrafts(draft: r),
        updated: 'updatedDraftsBoxStockall',
        updatedUuid: (e) => e.draft.uuid,
        toUpdated: (r, patch, pending) => UpdatedDrafts(draft: r),
        deleted: 'deletedDraftsBoxStockall',
        deletedUuid: (e) => e.draftUuid,
        toDeleted: (r) => DeletedDrafts(draftUuid: r.uuid!),
      ),
    ),
    customerAccountReceiptsTable(
      () => rows<CustomerAccountReceipts>('customerAccountReceiptsBoxStockall'),
      changes: watch<CustomerAccountReceipts>(
        'customerAccountReceiptsBoxStockall',
      ),
      writes: queuedWrites<
        CustomerAccountReceipts,
        CreatedCustomerAccountReceipts,
        UpdatedCustomerAccountReceipts,
        DeletedCustomerAccountReceipts
      >(
        fromJson: CustomerAccountReceipts.fromJson,
        main: 'customerAccountReceiptsBoxStockall',
        uuidOf: (r) => r.uuid,
        created: 'createdCustomerAccountReceiptsBoxStockall',
        createdUuid: (e) => e.createdCustomerAccountReceipts.uuid,
        toCreated:
            (r, json, pending) => CreatedCustomerAccountReceipts(
              createdCustomerAccountReceipts: r,
            ),
        updated: 'updatedCustomerAccountReceiptsBoxStockall',
        updatedUuid: (e) => e.updatedCustomerAccountReceipts.uuid,
        toUpdated:
            (r, patch, pending) => UpdatedCustomerAccountReceipts(
              updatedCustomerAccountReceipts: r,
            ),
        deleted: 'deletedCustomerAccountReceiptsBoxStockall',
        deletedUuid: (e) => e.customerAccountReceiptUuid,
        toDeleted:
            (r) => DeletedCustomerAccountReceipts(
              customerAccountReceiptUuid: r.uuid!,
            ),
      ),
    ),
    categoriesTable(
      () => rows<CategoryClass>('categoryBoxStockall'),
      changes: watch<CategoryClass>('categoryBoxStockall'),
      writes: queuedWrites<
        CategoryClass,
        CreatedCategory,
        UpdatedCategory,
        DeletedCategory
      >(
        fromJson: CategoryClass.fromJson,
        main: 'categoryBoxStockall',
        uuidOf: (r) => r.uuid,
        created: 'createdCategoriesBoxStockall',
        createdUuid: (e) => e.category.uuid,
        toCreated: (r, json, pending) => CreatedCategory(category: r),
        updated: 'updatedCategoriesBoxStockall',
        updatedUuid: (e) => e.category.uuid,
        toUpdated: (r, patch, pending) => UpdatedCategory(category: r),
        deleted: 'deletedCategoriesBoxStockall',
        deletedUuid: (e) => e.categoryUuid,
        toDeleted:
            (r) => DeletedCategory(categoryUuid: r.uuid, shopId: r.shopId),
      ),
    ),
    departmentsTable(
      () => rows<DepartmentClass>('departmentBoxStockall'),
      changes: watch<DepartmentClass>('departmentBoxStockall'),
      writes: queuedWrites<
        DepartmentClass,
        CreatedDepartments,
        UpdatedDepartments,
        DeletedDepartments
      >(
        fromJson: DepartmentClass.fromJson,
        main: 'departmentBoxStockall',
        uuidOf: (r) => r.uuid,
        created: 'createdDepartmentsBoxStockall',
        createdUuid: (e) => e.department.uuid,
        toCreated: (r, json, pending) => CreatedDepartments(department: r),
        updated: 'updatedDepartmentsBoxStockall',
        updatedUuid: (e) => e.department.uuid,
        toUpdated: (r, patch, pending) => UpdatedDepartments(department: r),
        deleted: 'deletedDepartmentsBoxStockall',
        deletedUuid: (e) => e.departmentUuid,
        toDeleted:
            (r) => DeletedDepartments(departmentUuid: r.uuid, shopId: r.shopId),
      ),
    ),
    suppliersTable(
      () => rows<SuppliersClass>('suppliersBoxStockall'),
      changes: watch<SuppliersClass>('suppliersBoxStockall'),
      writes: queuedWrites<
        SuppliersClass,
        CreatedSuppliers,
        UpdatedSuppliers,
        DeletedSupplier
      >(
        fromJson: SuppliersClass.fromJson,
        main: 'suppliersBoxStockall',
        uuidOf: (r) => r.uuid,
        created: 'createdSuppliersBoxStockall',
        createdUuid: (e) => e.supplier.uuid,
        toCreated: (r, json, pending) => CreatedSuppliers(supplier: r),
        updated: 'updatedSuppliersBoxStockall',
        updatedUuid: (e) => e.suppliers.uuid,
        toUpdated: (r, patch, pending) => UpdatedSuppliers(suppliers: r),
        deleted: 'deletedSuppliersBoxStockall',
        deletedUuid: (e) => e.supplierUuid,
        toDeleted: (r) => DeletedSupplier(supplierUuid: r.uuid!),
      ),
    ),
    subStaffTable(
      () => rows<TempSubStaff>('subStaffBoxStockall'),
      changes: watch<TempSubStaff>('subStaffBoxStockall'),
      writes: queuedWrites<
        TempSubStaff,
        CreatedSubStaff,
        UpdatedSubStaff,
        DeletedSubStaff
      >(
        fromJson: TempSubStaff.fromJson,
        main: 'subStaffBoxStockall',
        uuidOf: (r) => r.uuid,
        created: 'createdSubStaffBoxStockall',
        createdUuid: (e) => e.subStaff.uuid,
        toCreated: (r, json, pending) => CreatedSubStaff(subStaff: r),
        updated: 'updatedSubStaffBoxStockall',
        updatedUuid: (e) => e.subStaff.uuid,
        toUpdated: (r, patch, pending) => UpdatedSubStaff(subStaff: r),
        deleted: 'deletedSubStaffBoxStockall',
        deletedUuid: (e) => e.subStaffUuid,
        toDeleted: (r) => DeletedSubStaff(subStaffUuid: r.uuid!),
      ),
    ),
    storageProductsTable(
      () => rows<TempStorageProducts>('StorageProductsStockall'),
      changes: watch<TempStorageProducts>('StorageProductsStockall'),
      ensureDefaults: unitDefaultsPinner<TempStorageProducts>(
        units: (r) => r.unitsList,
        setUnits: (r, u) => r.unitsList = u,
        uuidOf: (r) => r.uuid,
        dimensionOf:
            (r) =>
                r.quantityType == 2
                    ? (ProductUnitsClass.isAreaUnitName(r.unit)
                        ? ProductUnitsClass.areaUnit
                        : ProductUnitsClass.sheetUnit)
                    : null,
        persist:
            (r) => Hive.box<TempStorageProducts>(
              'StorageProductsStockall',
            ).put(r.uuid, r),
        staff: by,
      ),
      writes: queuedWrites<
        TempStorageProducts,
        CreatedStorageProducts,
        UpdatedStorageProduct,
        DeletedStorageProduct
      >(
        fromJson: TempStorageProducts.fromJson,
        main: 'StorageProductsStockall',
        uuidOf: (r) => r.uuid,
        created: 'createdStorageProductsBoxStockall',
        createdUuid: (e) => e.storageProduct.uuid,
        toCreated:
            (r, json, pending) => CreatedStorageProducts(storageProduct: r),
        updated: 'updatedStorageProductBoxStockall',
        updatedUuid: (e) => e.updatedStorageProduct.uuid,
        toUpdated:
            (r, patch, pending) =>
                UpdatedStorageProduct(updatedStorageProduct: r),
        deleted: 'deletedStorageProductBoxStockall',
        deletedUuid: (e) => e.storageProducteUuid,
        toDeleted: (r) => DeletedStorageProduct(storageProducteUuid: r.uuid!),
        // Not in toJson.
        carryOver: (old, fresh) => fresh.desc ??= old.desc,
        // A pull keeps the default unit pinned on read.
        pullAdopt: (stored, pulled) {
          if (pulled.unitsList?.isNotEmpty ?? false) return;
          pulled.unitsList = stored.unitsList;
        },
      ),
    ),
    storageItemHistoryTable(
      () => rows<StorageItemHistory>('storageItemHistoryBoxStockall'),
      changes: watch<StorageItemHistory>('storageItemHistoryBoxStockall'),
      writes: appendOnlyWrites<StorageItemHistory, CreatedStorageItemHistory>(
        fromJson: StorageItemHistory.fromJson,
        main: 'storageItemHistoryBoxStockall',
        uuidOf: (r) => r.uuid,
        created: 'createdStorageItemHistoriesBoxStockall',
        createdUuid: (e) => e.storageItemHistory.uuid,
        toCreated: (r) => CreatedStorageItemHistory(storageItemHistory: r),
      ),
    ),
    itemHistoryTable(
      () => rows<ItemHistory>('itemHistoryBoxStockall'),
      changes: watch<ItemHistory>('itemHistoryBoxStockall'),
      writes: appendOnlyWrites<ItemHistory, CreatedItemHistory>(
        fromJson: ItemHistory.fromJson,
        main: 'itemHistoryBoxStockall',
        uuidOf: (r) => r.uuid,
        created: 'createdItemHistoriesBoxStockall',
        createdUuid: (e) => e.itemHistory.uuid,
        toCreated: (r) => CreatedItemHistory(itemHistory: r),
      ),
    ),
    inventoryUpdatesTable(
      () => rows<TempInventoryUpdateClass>('inventoryUpdatesBoxStockall'),
      changes: watch<TempInventoryUpdateClass>('inventoryUpdatesBoxStockall'),
      writes: appendOnlyWrites<
        TempInventoryUpdateClass,
        CreatedInventoryUpdatesClass
      >(
        fromJson: TempInventoryUpdateClass.fromJson,
        main: 'inventoryUpdatesBoxStockall',
        uuidOf: (r) => r.uuid,
        created: 'createdInventoryUpdatesBoxStockall',
        createdUuid: (e) => e.inventoryUpdate.uuid,
        toCreated: (r) => CreatedInventoryUpdatesClass(inventoryUpdate: r),
      ),
    ),
    eventLogsTable(
      () => rows<TempEventLogClass>('eventsLogBoxStockall'),
      changes: watch<TempEventLogClass>('eventsLogBoxStockall'),
      writes: appendOnlyWrites<TempEventLogClass, CreatedEventsLogClass>(
        fromJson: TempEventLogClass.fromJson,
        main: 'eventsLogBoxStockall',
        uuidOf: (r) => r.uuid,
        created: 'createdEventsLogBoxStockall',
        createdUuid: (e) => e.eventLog.uuid,
        toCreated: (r) => CreatedEventsLogClass(eventLog: r),
      ),
    ),
    errorLogsTable(
      () => rows<TempErrorLogClass>('errorLogBoxStockall'),
      changes: watch<TempErrorLogClass>('errorLogBoxStockall'),
      writes: appendOnlyWrites<TempErrorLogClass, CreatedErrorLogClass>(
        fromJson: TempErrorLogClass.fromJson,
        main: 'errorLogBoxStockall',
        uuidOf: (r) => r.uuid,
        created: 'createdErrorLogBoxStockall',
        createdUuid: (e) => e.errorLog.uuid,
        toCreated: (r) => CreatedErrorLogClass(errorLog: r),
      ),
    ),
    purchasesTable(
      () => rows<TempPurchase>('purchasesBoxStockall'),
      changes: watch<TempPurchase>('purchasesBoxStockall'),
      writes: queuedWrites<
        TempPurchase,
        CreatedPurchases,
        UpdatedPurchases,
        DeletedPurchases
      >(
        fromJson: TempPurchase.fromJson,
        main: 'purchasesBoxStockall',
        uuidOf: (r) => r.uuid,
        created: 'createdPurchasesBoxStockall',
        createdUuid: (e) => e.purchase.uuid,
        toCreated: (r, json, pending) => CreatedPurchases(purchase: r),
        updated: 'updatedPurchasesBoxStockall',
        updatedUuid: (e) => e.purchase.uuid,
        toUpdated: (r, patch, pending) => UpdatedPurchases(purchase: r),
        deleted: 'deletedPurchasesBoxStockall',
        deletedUuid: (e) => e.purchaseUuid,
        toDeleted: (r) => DeletedPurchases(purchaseUuid: r.uuid!),
      ),
    ),
    materialsTable(
      () => rows<MaterialClass>('materialBoxStockall'),
      changes: watch<MaterialClass>('materialBoxStockall'),
      ensureDefaults: unitDefaultsPinner<MaterialClass>(
        units: (r) => r.unitsList,
        setUnits: (r, u) => r.unitsList = u,
        uuidOf: (r) => r.uuid,
        persist:
            (r) =>
                Hive.box<MaterialClass>('materialBoxStockall').put(r.uuid, r),
        staff: by,
      ),
      writes: queuedWrites<
        MaterialClass,
        CreatedMaterial,
        UpdatedMaterial,
        DeletedMaterial
      >(
        fromJson: MaterialClass.fromJson,
        main: 'materialBoxStockall',
        uuidOf: (r) => r.uuid,
        created: 'createdMaterialsBoxStockall',
        createdUuid: (e) => e.material.uuid,
        // As for products: the pending insert keeps a quantity it has
        // to send.
        toCreated:
            (r, json, pending) => CreatedMaterial(
              material: r,
              includeQuantity:
                  json.containsKey('quantity') ||
                  (pending?.includeQuantity ?? false),
            ),
        updated: 'updatedMaterialsBoxStockall',
        updatedUuid: (e) => e.material.uuid,
        toUpdated:
            (r, patch, pending) => UpdatedMaterial(
              material: r,
              includeQuantity:
                  patch.containsKey('quantity') ||
                  (pending?.includeQuantity ?? false),
            ),
        deleted: 'deletedMaterialsBoxStockall',
        deletedUuid: (e) => e.materialUuid,
        toDeleted: (r) => DeletedMaterial(materialUuid: r.uuid!),
        carryOver: (old, fresh) => fresh.createdAt ??= old.createdAt,
        // A pull keeps the default unit pinned on read.
        pullAdopt: (stored, pulled) {
          if (pulled.unitsList?.isNotEmpty ?? false) return;
          pulled.unitsList = stored.unitsList;
        },
      ),
    ),
    materialsUsageTable(
      () =>
          rows<ProductionMaterialsUsage>('productionMaterialsUsageBoxStockall'),
      changes: watch<ProductionMaterialsUsage>(
        'productionMaterialsUsageBoxStockall',
      ),
      writes: queuedWrites<
        ProductionMaterialsUsage,
        CreatedProductionMaterialsUsage,
        UpdatedProductionMaterialsUsage,
        DeletedProductionMaterialsUsage
      >(
        fromJson: ProductionMaterialsUsage.fromJson,
        main: 'productionMaterialsUsageBoxStockall',
        uuidOf: (r) => r.uuid,
        created: 'createdProductionMaterialsUsageBoxStockall',
        createdUuid: (e) => e.createdProductionMaterialsUsage.uuid,
        toCreated:
            (r, json, pending) => CreatedProductionMaterialsUsage(
              createdProductionMaterialsUsage: r,
            ),
        updated: 'updatedProductionMaterialsUsageBoxStockall',
        updatedUuid: (e) => e.updatedProductionMaterialsUsage.uuid,
        toUpdated:
            (r, patch, pending) => UpdatedProductionMaterialsUsage(
              updatedProductionMaterialsUsage: r,
            ),
        deleted: 'deletedProductionMaterialsUsageBoxStockall',
        deletedUuid: (e) => e.materialsUsageUuid,
        toDeleted:
            (r) => DeletedProductionMaterialsUsage(materialsUsageUuid: r.uuid),
      ),
    ),
    productionItemsTable(
      () => rows<ProductionItem>('productionItemsBoxStockall'),
      changes: watch<ProductionItem>('productionItemsBoxStockall'),
      ensureDefaults: unitDefaultsPinner<ProductionItem>(
        units: (r) => r.unitsList,
        setUnits: (r, u) => r.unitsList = u,
        uuidOf: (r) => r.uuid,
        persist:
            (r) => Hive.box<ProductionItem>(
              'productionItemsBoxStockall',
            ).put(r.uuid, r),
        staff: by,
      ),
      writes: queuedWrites<
        ProductionItem,
        CreatedProductionItem,
        UpdatedProductionItem,
        DeletedProductionItem
      >(
        fromJson: ProductionItem.fromJson,
        main: 'productionItemsBoxStockall',
        uuidOf: (r) => r.uuid,
        created: 'createdProductionItemsBoxStockall',
        createdUuid: (e) => e.productionItem.uuid,
        toCreated:
            (r, json, pending) => CreatedProductionItem(
              productionItem: r,
              includeQuantity:
                  json.containsKey('quantity') ||
                  (pending?.includeQuantity ?? false),
            ),
        updated: 'updatedProductionItemsBoxStockall',
        updatedUuid: (e) => e.productionItem.uuid,
        toUpdated:
            (r, patch, pending) => UpdatedProductionItem(
              productionItem: r,
              includeQuantity:
                  patch.containsKey('quantity') ||
                  (pending?.includeQuantity ?? false),
            ),
        deleted: 'deletedProductionItemsBoxStockall',
        deletedUuid: (e) => e.productionItemUuid,
        toDeleted: (r) => DeletedProductionItem(productionItemUuid: r.uuid!),
        carryOver: (old, fresh) => fresh.createdAt ??= old.createdAt,
        // A pull keeps the default unit pinned on read.
        pullAdopt: (stored, pulled) {
          if (pulled.unitsList?.isNotEmpty ?? false) return;
          pulled.unitsList = stored.unitsList;
        },
      ),
    ),
    productionItemHistoryTable(
      () => rows<ProductionItemHistory>('productionItemHistoryBoxStockall'),
      changes: watch<ProductionItemHistory>('productionItemHistoryBoxStockall'),
      writes:
          appendOnlyWrites<ProductionItemHistory, CreatedProductionItemHistory>(
            fromJson: ProductionItemHistory.fromJson,
            main: 'productionItemHistoryBoxStockall',
            uuidOf: (r) => r.uuid,
            created: 'createdProductionItemHistoriesBoxStockall',
            createdUuid: (e) => e.productionItemHistory.uuid,
            toCreated:
                (r) => CreatedProductionItemHistory(productionItemHistory: r),
          ),
    ),
    materialsItemHistoryTable(
      () => rows<MaterialsItemHistory>('materialsItemHistoryBoxStockall'),
      changes: watch<MaterialsItemHistory>('materialsItemHistoryBoxStockall'),
      writes:
          appendOnlyWrites<MaterialsItemHistory, CreatedMaterialsItemHistory>(
            fromJson: MaterialsItemHistory.fromJson,
            main: 'materialsItemHistoryBoxStockall',
            uuidOf: (r) => r.uuid,
            created: 'createdMaterialsItemHistoriesBoxStockall',
            createdUuid: (e) => e.createdMaterialsItemHistory.uuid,
            toCreated:
                (r) =>
                    CreatedMaterialsItemHistory(createdMaterialsItemHistory: r),
          ),
    ),
    productionRecordsTable(
      () => rows<ProductionRecord>('productionRecordsBoxStockall'),
      changes: watch<ProductionRecord>('productionRecordsBoxStockall'),
      writes: queuedWrites<
        ProductionRecord,
        CreatedProductionRecord,
        UpdatedProductionRecord,
        DeletedProductionRecord
      >(
        fromJson: ProductionRecord.fromJson,
        main: 'productionRecordsBoxStockall',
        uuidOf: (r) => r.uuid,
        created: 'createdProductionRecordsBoxStockall',
        createdUuid: (e) => e.createdProductionRecord.uuid,
        toCreated:
            (r, json, pending) =>
                CreatedProductionRecord(createdProductionRecord: r),
        updated: 'updatedProductionRecordsBoxStockall',
        updatedUuid: (e) => e.updatedProductionRecord.uuid,
        toUpdated:
            (r, patch, pending) =>
                UpdatedProductionRecord(updatedProductionRecord: r),
        deleted: 'deletedProductionRecordBoxStockall',
        deletedUuid: (e) => e.productionRecordUuid,
        toDeleted:
            (r) => DeletedProductionRecord(productionRecordUuid: r.uuid!),
      ),
    ),
    expenseCategoriesTable(
      () => rows<ExpenseCategory>('expenseCategoriesBoxStockall'),
      changes: watch<ExpenseCategory>('expenseCategoriesBoxStockall'),
      writes: queuedWrites<
        ExpenseCategory,
        CreatedExpenseCategory,
        UpdatedExpenseCategory,
        DeletedExpenseCategory
      >(
        fromJson: ExpenseCategory.fromJson,
        main: 'expenseCategoriesBoxStockall',
        uuidOf: (r) => r.uuid,
        created: 'createdExpenseCategoriesBoxStockall',
        createdUuid: (e) => e.category.uuid,
        toCreated: (r, json, pending) => CreatedExpenseCategory(category: r),
        updated: 'updatedExpenseCategoriesBoxStockall',
        updatedUuid: (e) => e.category.uuid,
        toUpdated: (r, patch, pending) => UpdatedExpenseCategory(category: r),
        deleted: 'deletedExpenseCategoriesBoxStockall',
        deletedUuid: (e) => e.categoryUuid,
        toDeleted:
            (r) =>
                DeletedExpenseCategory(categoryUuid: r.uuid, shopId: r.shopId),
      ),
    ),
  ];
}

const _text = LanColumnType.text;
const _number = LanColumnType.number;
const _time = LanColumnType.timestamp;

/// A table's rows, read on each query.
typedef LanRows<T> = Iterable<T> Function();

/// A table's change stream, which drops its indexes.
typedef LanChanges = Stream<Object?> Function()?;

LanTable<Drafts> draftsTable(
  LanRows<Drafts> rows, {
  LanChanges changes,
  LanWrites<Drafts>? writes,
}) => LanTable<Drafts>(
  name: 'drafts',
  rows: rows,
  changes: changes,
  writes: writes,
  toJson: (r) => r.toJson(),
  shopIdOf: (r) => r.shopId,
  departmentOf: (r) => r.departmentUuid,
  columns: {
    'shop_id': LanColumn(_number, (r) => r.shopId),
    'uuid': LanColumn(_text, (r) => r.uuid),
    'created_at': LanColumn(_time, (r) => r.createdAt),
    'updated_at': LanColumn(_time, (r) => r.updatedAt),
  },
);

LanTable<CustomerAccountReceipts> customerAccountReceiptsTable(
  LanRows<CustomerAccountReceipts> rows, {
  LanChanges changes,
  LanWrites<CustomerAccountReceipts>? writes,
}) => LanTable<CustomerAccountReceipts>(
  name: 'customer_account_receipts',
  rows: rows,
  changes: changes,
  writes: writes,
  toJson: (r) => r.toJson(),
  shopIdOf: (r) => r.shopId,
  columns: {
    'shop_id': LanColumn(_number, (r) => r.shopId),
    'uuid': LanColumn(_text, (r) => r.uuid),
    'created_at': LanColumn(_time, (r) => r.createdAt),
    'updated_at': LanColumn(_time, (r) => r.updatedAt),
    'customer_uuid': LanColumn(_text, (r) => r.customerUuid),
  },
);

LanTable<CategoryClass> categoriesTable(
  LanRows<CategoryClass> rows, {
  LanChanges changes,
  LanWrites<CategoryClass>? writes,
}) => LanTable<CategoryClass>(
  name: 'categories',
  rows: rows,
  changes: changes,
  writes: writes,
  toJson: (r) => r.toJson(),
  shopIdOf: (r) => r.shopId,
  departmentOf: (r) => r.departmentId,
  includeUnassigned: true,
  dateIndexes: const {'updated_at'},
  columns: {
    'shop_id': LanColumn(_number, (r) => r.shopId),
    'uuid': LanColumn(_text, (r) => r.uuid),
    'name': LanColumn(_text, (r) => r.name),
    'updated_at': LanColumn(_time, (r) => r.updatedAt),
    'department_id': LanColumn(_text, (r) => r.departmentId),
  },
);

LanTable<DepartmentClass> departmentsTable(
  LanRows<DepartmentClass> rows, {
  LanChanges changes,
  LanWrites<DepartmentClass>? writes,
}) => LanTable<DepartmentClass>(
  name: 'departments',
  rows: rows,
  changes: changes,
  writes: writes,
  toJson: (r) => r.toJson(),
  shopIdOf: (r) => r.shopId,
  dateIndexes: const {'updated_at'},
  columns: {
    'shop_id': LanColumn(_number, (r) => r.shopId),
    'uuid': LanColumn(_text, (r) => r.uuid),
    'name': LanColumn(_text, (r) => r.name),
    'updated_at': LanColumn(_time, (r) => r.updatedAt),
  },
);

LanTable<SuppliersClass> suppliersTable(
  LanRows<SuppliersClass> rows, {
  LanChanges changes,
  LanWrites<SuppliersClass>? writes,
}) => LanTable<SuppliersClass>(
  name: 'suppliers',
  rows: rows,
  changes: changes,
  writes: writes,
  toJson: (r) => r.toJson(),
  shopIdOf: (r) => r.shopId,
  departmentOf: (r) => r.departmentId,
  includeUnassigned: true,
  dateIndexes: const {'updated_at'},
  columns: {
    'shop_id': LanColumn(_number, (r) => r.shopId),
    'uuid': LanColumn(_text, (r) => r.uuid),
    'name': LanColumn(_text, (r) => r.name),
    'updated_at': LanColumn(_time, (r) => r.updatedAt),
  },
);

LanTable<TempSubStaff> subStaffTable(
  LanRows<TempSubStaff> rows, {
  LanChanges changes,
  LanWrites<TempSubStaff>? writes,
}) => LanTable<TempSubStaff>(
  name: 'sub_staff',
  rows: rows,
  changes: changes,
  writes: writes,
  toJson: (r) => r.toJson(),
  shopIdOf: (r) => r.shopId,
  departmentOf: (r) => r.departmentUuid,
  columns: {
    'shop_id': LanColumn(_number, (r) => r.shopId),
    'uuid': LanColumn(_text, (r) => r.uuid),
    'updated_at': LanColumn(_time, (r) => r.updatedAt),
  },
);

LanTable<TempStorageProducts> storageProductsTable(
  LanRows<TempStorageProducts> rows, {
  LanChanges changes,
  LanWrites<TempStorageProducts>? writes,
  void Function(TempStorageProducts row)? ensureDefaults,
}) => LanTable<TempStorageProducts>(
  name: 'storage_products',
  rows: rows,
  changes: changes,
  writes: writes,
  toJson: (r) {
    ensureDefaults?.call(r);
    return r.toJson();
  },
  shopIdOf: (r) => r.shopId,
  dateIndexes: const {'updated_at'},
  columns: {
    'shop_id': LanColumn(_number, (r) => r.shopId),
    'uuid': LanColumn(_text, (r) => r.uuid),
    'name': LanColumn(_text, (r) => r.name),
    'updated_at': LanColumn(_time, (r) => r.updatedAt),
  },
);

LanTable<StorageItemHistory> storageItemHistoryTable(
  LanRows<StorageItemHistory> rows, {
  LanChanges changes,
  LanWrites<StorageItemHistory>? writes,
}) => LanTable<StorageItemHistory>(
  name: 'storage_item_history',
  rows: rows,
  changes: changes,
  writes: writes,
  toJson: (r) => r.toJson(),
  shopIdOf: (r) => r.shopId,
  // The app checks the storage side and the sales side.
  departmentsOf:
      (r) => [
        if (r.storageDepartmentUuid != null) r.storageDepartmentUuid!,
        if (r.salesDepartmentUuid != null) r.salesDepartmentUuid!,
      ],
  columns: {
    'shop_id': LanColumn(_number, (r) => r.shopId),
    'uuid': LanColumn(_text, (r) => r.uuid),
    'created_at': LanColumn(_time, (r) => r.createdAt),
  },
);

LanTable<ItemHistory> itemHistoryTable(
  LanRows<ItemHistory> rows, {
  LanChanges changes,
  LanWrites<ItemHistory>? writes,
}) => LanTable<ItemHistory>(
  name: 'item_history',
  rows: rows,
  changes: changes,
  writes: writes,
  toJson: (r) => r.toJson(),
  shopIdOf: (r) => r.shopId,
  departmentOf: (r) => r.departmentUuid,
  columns: {
    'shop_id': LanColumn(_number, (r) => r.shopId),
    'uuid': LanColumn(_text, (r) => r.uuid),
    'created_at': LanColumn(_time, (r) => r.createdAt),
    'item_uuid': LanColumn(_text, (r) => r.itemUuid),
  },
);

LanTable<TempInventoryUpdateClass> inventoryUpdatesTable(
  LanRows<TempInventoryUpdateClass> rows, {
  LanChanges changes,
  LanWrites<TempInventoryUpdateClass>? writes,
}) => LanTable<TempInventoryUpdateClass>(
  name: 'inventory_updates',
  rows: rows,
  changes: changes,
  writes: writes,
  toJson: (r) => r.toJson(),
  shopIdOf: (r) => r.shopId,
  departmentOf: (r) => r.departmentUuid,
  columns: {
    'shop_id': LanColumn(_number, (r) => r.shopId),
    'uuid': LanColumn(_text, (r) => r.uuid),
    'created_at': LanColumn(_time, (r) => r.createdAt),
  },
);

LanTable<TempEventLogClass> eventLogsTable(
  LanRows<TempEventLogClass> rows, {
  LanChanges changes,
  LanWrites<TempEventLogClass>? writes,
}) => LanTable<TempEventLogClass>(
  name: 'event_logs',
  rows: rows,
  changes: changes,
  writes: writes,
  toJson: (r) => r.toJson(),
  shopIdOf: (r) => r.shopId,
  departmentOf: (r) => r.departmentUuid,
  columns: {
    'shop_id': LanColumn(_number, (r) => r.shopId),
    'uuid': LanColumn(_text, (r) => r.uuid),
    'created_at': LanColumn(_time, (r) => r.createdAt),
  },
);

LanTable<TempErrorLogClass> errorLogsTable(
  LanRows<TempErrorLogClass> rows, {
  LanChanges changes,
  LanWrites<TempErrorLogClass>? writes,
}) => LanTable<TempErrorLogClass>(
  name: 'error_logs',
  rows: rows,
  changes: changes,
  writes: writes,
  toJson: (r) => r.toJson(),
  shopIdOf: (r) => r.shopId,
  columns: {
    'shop_id': LanColumn(_number, (r) => r.shopId),
    'uuid': LanColumn(_text, (r) => r.uuid),
    'created_at': LanColumn(_time, (r) => r.createdAt),
  },
);

LanTable<TempPurchase> purchasesTable(
  LanRows<TempPurchase> rows, {
  LanChanges changes,
  LanWrites<TempPurchase>? writes,
}) => LanTable<TempPurchase>(
  name: 'purchases',
  rows: rows,
  changes: changes,
  writes: writes,
  toJson: (r) => r.toJson(),
  shopIdOf: (r) => r.shopId,
  departmentOf: (r) => r.departmentUuid,
  columns: {
    'shop_id': LanColumn(_number, (r) => r.shopId),
    'uuid': LanColumn(_text, (r) => r.uuid),
    'created_at': LanColumn(_time, (r) => r.createdAt),
    'updated_at': LanColumn(_time, (r) => r.updatedAt),
    'supplier_id': LanColumn(_text, (r) => r.supplierId),
  },
);

LanTable<MaterialClass> materialsTable(
  LanRows<MaterialClass> rows, {
  LanChanges changes,
  LanWrites<MaterialClass>? writes,
  void Function(MaterialClass row)? ensureDefaults,
}) => LanTable<MaterialClass>(
  name: 'production_materials',
  rows: rows,
  changes: changes,
  writes: writes,
  toJson: (r) {
    ensureDefaults?.call(r);
    return r.toJson(isIncludeQuantity: true);
  },
  shopIdOf: (r) => r.shopId,
  departmentOf: (r) => r.departmentUuid,
  includeUnassigned: true,
  dateIndexes: const {'updated_at'},
  columns: {
    'shop_id': LanColumn(_number, (r) => r.shopId),
    'uuid': LanColumn(_text, (r) => r.uuid),
    'name': LanColumn(_text, (r) => r.name),
    'updated_at': LanColumn(_time, (r) => r.updatedAt),
  },
);

LanTable<ProductionMaterialsUsage> materialsUsageTable(
  LanRows<ProductionMaterialsUsage> rows, {
  LanChanges changes,
  LanWrites<ProductionMaterialsUsage>? writes,
}) => LanTable<ProductionMaterialsUsage>(
  name: 'production_materials_usage',
  rows: rows,
  changes: changes,
  writes: writes,
  toJson: (r) => r.toJson(),
  shopIdOf: (r) => r.shopId,
  departmentOf: (r) => r.departmentUuid,
  columns: {
    'shop_id': LanColumn(_number, (r) => r.shopId),
    'uuid': LanColumn(_text, (r) => r.uuid),
    'created_at': LanColumn(_time, (r) => r.createdAt),
    'updated_at': LanColumn(_time, (r) => r.updatedAt),
  },
);

LanTable<ProductionItem> productionItemsTable(
  LanRows<ProductionItem> rows, {
  LanChanges changes,
  LanWrites<ProductionItem>? writes,
  void Function(ProductionItem row)? ensureDefaults,
}) => LanTable<ProductionItem>(
  name: 'production_items',
  rows: rows,
  changes: changes,
  writes: writes,
  toJson: (r) {
    ensureDefaults?.call(r);
    return r.toJson(isIncludeQuantity: true);
  },
  shopIdOf: (r) => r.shopId,
  departmentOf: (r) => r.departmentUuid,
  includeUnassigned: true,
  dateIndexes: const {'updated_at'},
  columns: {
    'shop_id': LanColumn(_number, (r) => r.shopId),
    'uuid': LanColumn(_text, (r) => r.uuid),
    'name': LanColumn(_text, (r) => r.name),
    'updated_at': LanColumn(_time, (r) => r.updatedAt),
  },
);

LanTable<ProductionItemHistory> productionItemHistoryTable(
  LanRows<ProductionItemHistory> rows, {
  LanChanges changes,
  LanWrites<ProductionItemHistory>? writes,
}) => LanTable<ProductionItemHistory>(
  name: 'production_item_history',
  rows: rows,
  changes: changes,
  writes: writes,
  toJson: (r) => r.toJson(),
  shopIdOf: (r) => r.shopId,
  departmentOf: (r) => r.departmentUuid,
  columns: {
    'shop_id': LanColumn(_number, (r) => r.shopId),
    'uuid': LanColumn(_text, (r) => r.uuid),
    'created_at': LanColumn(_time, (r) => r.createdAt),
  },
);

LanTable<MaterialsItemHistory> materialsItemHistoryTable(
  LanRows<MaterialsItemHistory> rows, {
  LanChanges changes,
  LanWrites<MaterialsItemHistory>? writes,
}) => LanTable<MaterialsItemHistory>(
  name: 'production_materials_item_history',
  rows: rows,
  changes: changes,
  writes: writes,
  toJson: (r) => r.toJson(),
  shopIdOf: (r) => r.shopId,
  departmentOf: (r) => r.departmentUuid,
  columns: {
    'shop_id': LanColumn(_number, (r) => r.shopId),
    'uuid': LanColumn(_text, (r) => r.uuid),
    'created_at': LanColumn(_time, (r) => r.createdAt),
  },
);

LanTable<ProductionRecord> productionRecordsTable(
  LanRows<ProductionRecord> rows, {
  LanChanges changes,
  LanWrites<ProductionRecord>? writes,
}) => LanTable<ProductionRecord>(
  name: 'production_records',
  rows: rows,
  changes: changes,
  writes: writes,
  toJson: (r) => r.toJson(),
  shopIdOf: (r) => r.shopId,
  departmentOf: (r) => r.departmentId,
  columns: {
    'shop_id': LanColumn(_number, (r) => r.shopId),
    'uuid': LanColumn(_text, (r) => r.uuid),
    'created_at': LanColumn(_time, (r) => r.createdAt),
    'updated_at': LanColumn(_time, (r) => r.updatedAt),
  },
);

LanTable<ExpenseCategory> expenseCategoriesTable(
  LanRows<ExpenseCategory> rows, {
  LanChanges changes,
  LanWrites<ExpenseCategory>? writes,
}) => LanTable<ExpenseCategory>(
  name: 'expense_categories',
  rows: rows,
  changes: changes,
  writes: writes,
  toJson: (r) => r.toJson(),
  shopIdOf: (r) => r.shopId,
  columns: {
    'shop_id': LanColumn(_number, (r) => r.shopId),
    'uuid': LanColumn(_text, (r) => r.uuid),
    'name': LanColumn(_text, (r) => r.name),
    'updated_at': LanColumn(_time, (r) => r.updatedAt),
  },
);
