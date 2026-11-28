/// Typed access to the LAN tables' boxes by name (Hive only returns an open box
/// under its exact value type). Generated from lan_more_tables.dart.
library;

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

final Map<String, Box<dynamic> Function()> lanBoxes = {
  'mainDraftsBoxStockall': () => Hive.box<Drafts>('mainDraftsBoxStockall'),
  'createdDraftsBoxStockall':
      () => Hive.box<CreatedDrafts>('createdDraftsBoxStockall'),
  'updatedDraftsBoxStockall':
      () => Hive.box<UpdatedDrafts>('updatedDraftsBoxStockall'),
  'deletedDraftsBoxStockall':
      () => Hive.box<DeletedDrafts>('deletedDraftsBoxStockall'),
  'customerAccountReceiptsBoxStockall':
      () => Hive.box<CustomerAccountReceipts>(
        'customerAccountReceiptsBoxStockall',
      ),
  'createdCustomerAccountReceiptsBoxStockall':
      () => Hive.box<CreatedCustomerAccountReceipts>(
        'createdCustomerAccountReceiptsBoxStockall',
      ),
  'updatedCustomerAccountReceiptsBoxStockall':
      () => Hive.box<UpdatedCustomerAccountReceipts>(
        'updatedCustomerAccountReceiptsBoxStockall',
      ),
  'deletedCustomerAccountReceiptsBoxStockall':
      () => Hive.box<DeletedCustomerAccountReceipts>(
        'deletedCustomerAccountReceiptsBoxStockall',
      ),
  'categoryBoxStockall': () => Hive.box<CategoryClass>('categoryBoxStockall'),
  'createdCategoriesBoxStockall':
      () => Hive.box<CreatedCategory>('createdCategoriesBoxStockall'),
  'updatedCategoriesBoxStockall':
      () => Hive.box<UpdatedCategory>('updatedCategoriesBoxStockall'),
  'deletedCategoriesBoxStockall':
      () => Hive.box<DeletedCategory>('deletedCategoriesBoxStockall'),
  'departmentBoxStockall':
      () => Hive.box<DepartmentClass>('departmentBoxStockall'),
  'createdDepartmentsBoxStockall':
      () => Hive.box<CreatedDepartments>('createdDepartmentsBoxStockall'),
  'updatedDepartmentsBoxStockall':
      () => Hive.box<UpdatedDepartments>('updatedDepartmentsBoxStockall'),
  'deletedDepartmentsBoxStockall':
      () => Hive.box<DeletedDepartments>('deletedDepartmentsBoxStockall'),
  'suppliersBoxStockall':
      () => Hive.box<SuppliersClass>('suppliersBoxStockall'),
  'createdSuppliersBoxStockall':
      () => Hive.box<CreatedSuppliers>('createdSuppliersBoxStockall'),
  'updatedSuppliersBoxStockall':
      () => Hive.box<UpdatedSuppliers>('updatedSuppliersBoxStockall'),
  'deletedSuppliersBoxStockall':
      () => Hive.box<DeletedSupplier>('deletedSuppliersBoxStockall'),
  'subStaffBoxStockall': () => Hive.box<TempSubStaff>('subStaffBoxStockall'),
  'createdSubStaffBoxStockall':
      () => Hive.box<CreatedSubStaff>('createdSubStaffBoxStockall'),
  'updatedSubStaffBoxStockall':
      () => Hive.box<UpdatedSubStaff>('updatedSubStaffBoxStockall'),
  'deletedSubStaffBoxStockall':
      () => Hive.box<DeletedSubStaff>('deletedSubStaffBoxStockall'),
  'StorageProductsStockall':
      () => Hive.box<TempStorageProducts>('StorageProductsStockall'),
  'createdStorageProductsBoxStockall':
      () =>
          Hive.box<CreatedStorageProducts>('createdStorageProductsBoxStockall'),
  'updatedStorageProductBoxStockall':
      () => Hive.box<UpdatedStorageProduct>('updatedStorageProductBoxStockall'),
  'deletedStorageProductBoxStockall':
      () => Hive.box<DeletedStorageProduct>('deletedStorageProductBoxStockall'),
  'storageItemHistoryBoxStockall':
      () => Hive.box<StorageItemHistory>('storageItemHistoryBoxStockall'),
  'createdStorageItemHistoriesBoxStockall':
      () => Hive.box<CreatedStorageItemHistory>(
        'createdStorageItemHistoriesBoxStockall',
      ),
  'itemHistoryBoxStockall':
      () => Hive.box<ItemHistory>('itemHistoryBoxStockall'),
  'createdItemHistoriesBoxStockall':
      () => Hive.box<CreatedItemHistory>('createdItemHistoriesBoxStockall'),
  'inventoryUpdatesBoxStockall':
      () => Hive.box<TempInventoryUpdateClass>('inventoryUpdatesBoxStockall'),
  'createdInventoryUpdatesBoxStockall':
      () => Hive.box<CreatedInventoryUpdatesClass>(
        'createdInventoryUpdatesBoxStockall',
      ),
  'eventsLogBoxStockall':
      () => Hive.box<TempEventLogClass>('eventsLogBoxStockall'),
  'createdEventsLogBoxStockall':
      () => Hive.box<CreatedEventsLogClass>('createdEventsLogBoxStockall'),
  'errorLogBoxStockall':
      () => Hive.box<TempErrorLogClass>('errorLogBoxStockall'),
  'createdErrorLogBoxStockall':
      () => Hive.box<CreatedErrorLogClass>('createdErrorLogBoxStockall'),
  'purchasesBoxStockall': () => Hive.box<TempPurchase>('purchasesBoxStockall'),
  'createdPurchasesBoxStockall':
      () => Hive.box<CreatedPurchases>('createdPurchasesBoxStockall'),
  'updatedPurchasesBoxStockall':
      () => Hive.box<UpdatedPurchases>('updatedPurchasesBoxStockall'),
  'deletedPurchasesBoxStockall':
      () => Hive.box<DeletedPurchases>('deletedPurchasesBoxStockall'),
  'materialBoxStockall': () => Hive.box<MaterialClass>('materialBoxStockall'),
  'createdMaterialsBoxStockall':
      () => Hive.box<CreatedMaterial>('createdMaterialsBoxStockall'),
  'updatedMaterialsBoxStockall':
      () => Hive.box<UpdatedMaterial>('updatedMaterialsBoxStockall'),
  'deletedMaterialsBoxStockall':
      () => Hive.box<DeletedMaterial>('deletedMaterialsBoxStockall'),
  'productionMaterialsUsageBoxStockall':
      () => Hive.box<ProductionMaterialsUsage>(
        'productionMaterialsUsageBoxStockall',
      ),
  'createdProductionMaterialsUsageBoxStockall':
      () => Hive.box<CreatedProductionMaterialsUsage>(
        'createdProductionMaterialsUsageBoxStockall',
      ),
  'updatedProductionMaterialsUsageBoxStockall':
      () => Hive.box<UpdatedProductionMaterialsUsage>(
        'updatedProductionMaterialsUsageBoxStockall',
      ),
  'deletedProductionMaterialsUsageBoxStockall':
      () => Hive.box<DeletedProductionMaterialsUsage>(
        'deletedProductionMaterialsUsageBoxStockall',
      ),
  'productionItemsBoxStockall':
      () => Hive.box<ProductionItem>('productionItemsBoxStockall'),
  'createdProductionItemsBoxStockall':
      () =>
          Hive.box<CreatedProductionItem>('createdProductionItemsBoxStockall'),
  'updatedProductionItemsBoxStockall':
      () =>
          Hive.box<UpdatedProductionItem>('updatedProductionItemsBoxStockall'),
  'deletedProductionItemsBoxStockall':
      () =>
          Hive.box<DeletedProductionItem>('deletedProductionItemsBoxStockall'),
  'productionItemHistoryBoxStockall':
      () => Hive.box<ProductionItemHistory>('productionItemHistoryBoxStockall'),
  'createdProductionItemHistoriesBoxStockall':
      () => Hive.box<CreatedProductionItemHistory>(
        'createdProductionItemHistoriesBoxStockall',
      ),
  'materialsItemHistoryBoxStockall':
      () => Hive.box<MaterialsItemHistory>('materialsItemHistoryBoxStockall'),
  'createdMaterialsItemHistoriesBoxStockall':
      () => Hive.box<CreatedMaterialsItemHistory>(
        'createdMaterialsItemHistoriesBoxStockall',
      ),
  'productionRecordsBoxStockall':
      () => Hive.box<ProductionRecord>('productionRecordsBoxStockall'),
  'createdProductionRecordsBoxStockall':
      () => Hive.box<CreatedProductionRecord>(
        'createdProductionRecordsBoxStockall',
      ),
  'updatedProductionRecordsBoxStockall':
      () => Hive.box<UpdatedProductionRecord>(
        'updatedProductionRecordsBoxStockall',
      ),
  'deletedProductionRecordBoxStockall':
      () => Hive.box<DeletedProductionRecord>(
        'deletedProductionRecordBoxStockall',
      ),
  'expenseCategoriesBoxStockall':
      () => Hive.box<ExpenseCategory>('expenseCategoriesBoxStockall'),
  'createdExpenseCategoriesBoxStockall':
      () => Hive.box<CreatedExpenseCategory>(
        'createdExpenseCategoriesBoxStockall',
      ),
  'updatedExpenseCategoriesBoxStockall':
      () => Hive.box<UpdatedExpenseCategory>(
        'updatedExpenseCategoriesBoxStockall',
      ),
  'deletedExpenseCategoriesBoxStockall':
      () => Hive.box<DeletedExpenseCategory>(
        'deletedExpenseCategoriesBoxStockall',
      ),
};
