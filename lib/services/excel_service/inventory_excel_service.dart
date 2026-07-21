// class StockallSheet {

//     void header(...)

//     void row(...)

//     void rows(...)

//     void section(...)

//     void blankRow()

// }

// class StockallExcel {

//     StockallExcel({
//         required this.fileName,
//     });

//     final String fileName;

//     StockallSheet sheet(String name){...}

//     Future<void> download(){...}

// }

// class InventoryExcelService {
//   Future<void> downloadInventoryRecordsReport() async {
//   final excel = StockallExcel(
//     fileName: 'Inventory Records Report',
//   );

//   final sheet = excel.sheet('Inventory Records');

//   if (shop.manageInventoryStorage) {
//     sheet.section('Storage Items Records');

//     sheet.header([
//       'Name',
//       'Quantity',
//     ]);

//     sheet.rows(...);
//   }

//   if (!shop.manageDepartments) {
//     sheet.section('Sales Items Records');

//     sheet.header([
//       'Name',
//       'Quantity',
//       'Amount',
//     ]);

//     sheet.rows(...);
//   } else {
//     for (final department in departments) {
//       sheet.section(department.name);

//       sheet.header([
//         'Name',
//         'Quantity',
//         'Amount',
//       ]);

//       sheet.rows(...);
//     }

//     sheet.section('No Department');

//     sheet.header([
//       'Name',
//       'Quantity',
//       'Amount',
//     ]);

//     sheet.rows(...);
//   }

//   await excel.download();
// }
// }
