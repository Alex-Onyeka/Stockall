/// Fixtures shared by the LAN engine tests.
library;

import 'package:stockall/classes/temp_customers/temp_customers_class.dart';
import 'package:stockall/classes/temp_expenses/temp_expenses_class.dart';
import 'package:stockall/classes/temp_invoices/temp_invoices.dart';
import 'package:stockall/classes/temp_main_receipt/temp_main_receipt.dart';
import 'package:stockall/classes/temp_orders/orders.dart';
import 'package:stockall/classes/temp_product_class/prices_class/product_prices_class.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/classes/temp_product_class/units_class/product_units_class.dart';
import 'package:stockall/services/lan/lan_access_policy.dart';

final DateTime t0 = DateTime.utc(2026, 11, 1);

TempProductClass product(
  String uuid, {
  int shopId = 7,
  String name = 'Item',
  DateTime? updatedAt,
  String? department,
  List<String>? departments,
}) {
  return TempProductClass(
    uuid: uuid,
    name: name,
    unit: 'pcs',
    isRefundable: true,
    costPrice: 10,
    sellingPrice: 15,
    shopId: shopId,
    setCustomPrice: false,
    departmentName: null,
    departmentUuid: department,
    departmentUuids: departments,
    isManaged: true,
    quantity: 4,
    barcode: 'b-$uuid',
    categoryUuid: 'cat-1',
    groupUnit: null,
    qttyPerGroup: null,
    wholeSalePrice: null,
    storageUuid: null,
    categories: const [],
    useGroupUnit: false,
    unitsList: [
      ProductUnitsClass(
        uuid: 'u-$uuid',
        staffUuid: 's',
        createdAt: t0,
        staffName: 'S',
        conversion: 1,
        name: 'Unit(s)',
        isPrimary: true,
        productUuid: uuid,
      ),
    ],
    pricesList: [
      ProductPricesClass(
        uuid: 'p-$uuid',
        staffUuid: 's',
        createdAt: t0,
        staffName: 'S',
        priceValue: 15,
        name: 'Price',
        isPrimary: true,
        itemUuid: uuid,
      ),
    ],
    widthDimension: null,
    heightDimension: null,
    manageSalesWastage: false,
    updatedAt: updatedAt ?? t0,
  );
}

TempMainReceipt receipt(
  String uuid,
  DateTime createdAt, {
  int shopId = 7,
  String? department,
  double? balance,
}) {
  return TempMainReceipt(
    id: uuid.hashCode,
    uuid: uuid,
    barcode: 'bar-$uuid',
    createdAt: createdAt,
    shopId: shopId,
    staffId: 'staff-1',
    staffName: 'Ada',
    paymentMethod: 'Cash',
    bank: 0,
    cashAlt: 100,
    departmentName: null,
    isInvoice: false,
    invoiceUuid: 'inv-$uuid',
    customerUuid: 'cust-1',
    orderUuid: 'ord-$uuid',
    balance: balance,
    departmentUuidNew: department,
    cartName: null,
    subStaffName: null,
    comment: null,
    customerAccount: null,
    salesTypeIndex: 0,
  );
}

TempInvoice invoice(String uuid, DateTime createdAt) {
  return TempInvoice(
    id: 1,
    uuid: uuid,
    barcode: 'ib-$uuid',
    createdAt: createdAt,
    updatedAt: createdAt,
    shopId: 7,
    staffId: 'staff-1',
    staffName: 'Ada',
    paymentMethod: 'Cash',
    bank: 0,
    cashAlt: 0,
    departmentName: null,
    customerUuid: 'cust-1',
    departmentUuidNew: 'd1',
    cartName: null,
    subStaffName: null,
    comment: null,
  );
}

Orders order(String uuid, {double? balance}) {
  return Orders(
    uuid: uuid,
    createdAt: t0,
    updatedAt: t0,
    shopId: 7,
    staffId: 'staff-1',
    customerId: 'cust-1',
    customerName: 'Bola',
    departmentUuid: 'd1',
    orderItems: const [],
    barcode: 'ob-$uuid',
    vat: null,
    comment: null,
    originalCost: null,
    balance: balance,
    cartName: null,
    fixedDiscount: null,
    generalDiscount: null,
    subStaffName: null,
    subStaffUuid: null,
  );
}

TempCustomersClass customer(String uuid, {String? department = 'd1'}) {
  return TempCustomersClass(
    uuid: uuid,
    name: 'Bola',
    email: 'b@c.d',
    phone: '080',
    address: null,
    city: null,
    state: null,
    dateAdded: t0,
    updatedAt: t0,
    shopId: 7,
    departmentName: null,
    departmentUuid: department,
    balance: 12.5,
    cashReward: 0,
  );
}

TempExpensesClass expense(String uuid, {String? purchaseUuid = 'pur-1'}) {
  return TempExpensesClass(
    id: 3,
    uuid: uuid,
    name: 'Fuel',
    amount: 50,
    creator: 'Ada',
    shopId: 7,
    userId: 'staff-1',
    departmentName: null,
    departmentUuid: 'd1',
    createdDate: t0,
    updatedAt: t0,
    expenseType: 'general',
    expenseCategoryUuid: 'ec-1',
    staffUuid: 'staff-1',
    purchaseUuid: purchaseUuid,
  );
}

LanPrincipal principal({
  List<String> access = const [],
  List<String> departments = const [],
}) {
  return LanPrincipal(
    userId: 'staff-1',
    shopId: 7,
    role: 'Cashier',
    access: access,
    departmentUuids: departments,
    isOwner: false,
  );
}
