import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/classes/temp_main_receipt/temp_main_receipt.dart';
import 'package:stockall/services/lan/lan_access_policy.dart';
import 'package:stockall/services/lan/rest/hive_rest_engine.dart';
import 'package:stockall/services/lan/rest/lan_table.dart';
import 'package:stockall/services/lan/rest/lan_table_registry.dart';
import 'package:stockall/services/lan/rest/postgrest_request.dart';

/// 100k receipts: a month's window, newest first, first page of 1001 (the
/// shape `loadReceipts` sends) with an exact count. The indexed and
/// full-scan answers must be identical; the timings are printed for a look,
/// not asserted. They are from a debug (JIT) test run, so they are upper
/// bounds for a release build.
void main() {
  const shop = 7;
  final start = DateTime.utc(2026, 1, 1);

  final rows = <TempMainReceipt>[
    for (var i = 0; i < 100000; i++)
      TempMainReceipt(
        uuid: 'r$i',
        // Spread over a year, in insertion order like a real box.
        createdAt: start.add(Duration(minutes: (i * 5.256).round())),
        shopId: shop,
        staffId: 'staff-${i % 7}',
        staffName: 'Staff',
        paymentMethod: 'Cash',
        bank: 0,
        cashAlt: 100,
        departmentName: null,
        isInvoice: false,
        departmentUuidNew: 'd${i % 3}',
        cartName: null,
        subStaffName: null,
        comment: null,
        customerAccount: null,
        salesTypeIndex: 0,
        balance: (i % 10).toDouble(),
      ),
    for (var i = 0; i < 5000; i++)
      TempMainReceipt(
        uuid: 'other$i',
        createdAt: start.add(Duration(hours: i)),
        shopId: 8,
        staffId: 'x',
        staffName: 'X',
        paymentMethod: 'Cash',
        bank: 0,
        cashAlt: 0,
        departmentName: null,
        isInvoice: false,
        departmentUuidNew: null,
        cartName: null,
        subStaffName: null,
        comment: null,
        customerAccount: null,
        salesTypeIndex: 0,
      ),
  ];

  const who = LanPrincipal(
    userId: 'staff-1',
    shopId: shop,
    role: 'Cashier',
    access: [],
    departmentUuids: [],
    isOwner: false,
  );

  final request = PgRequest(
    table: 'receipts',
    op: PgOp.select,
    filters: [
      const PgFilter('shop_id', PgFilterOp.eq, '$shop'),
      PgFilter(
        'created_at',
        PgFilterOp.gte,
        DateTime.utc(2026, 6, 1).toIso8601String(),
      ),
      PgFilter(
        'created_at',
        PgFilterOp.lt,
        DateTime.utc(2026, 7, 1).toIso8601String(),
      ),
    ],
    order: const [
      PgOrder('created_at', ascending: false, nullsFirst: false),
    ],
    offset: 0,
    limit: 1001,
    countExact: true,
  );

  HiveRestEngine engineFor(LanTable<TempMainReceipt> table) {
    return HiveRestEngine(
      tables: [table],
      shopId: () => shop,
      manageDepartments: () => false,
    );
  }

  Future<(Duration, List<Object?>, String?)> time(HiveRestEngine e) async {
    final watch = Stopwatch()..start();
    final r = await e.handle(request, who);
    watch.stop();
    final body = r.body as List;
    return (
      watch.elapsed,
      [for (final row in body) (row as Map)['uuid']],
      r.headers['content-range'],
    );
  }

  test('a month of 100k receipts: date index vs full scan', () async {
    final full = receiptsTable(() => rows);
    // Rows the engine looks at (each is checked for its store).
    var looked = 0;
    LanTable<TempMainReceipt> counted({required bool indexed}) =>
        LanTable<TempMainReceipt>(
          name: 'receipts',
          rows: () => rows,
          toJson: full.toJson,
          shopIdOf: (r) {
            looked++;
            return full.shopIdOf(r);
          },
          columns: full.columns,
          departmentOf: full.departmentOf,
          dateIndexes: indexed ? full.dateIndexes : const {},
        );
    expect(full.dateIndexes, contains('created_at'));
    final indexed = engineFor(counted(indexed: true));
    final scan = engineFor(counted(indexed: false));

    looked = 0;
    final (cold, coldIds, coldRange) = await time(indexed);
    final coldLooked = looked;
    looked = 0;
    final (warm, warmIds, warmRange) = await time(indexed);
    final warmLooked = looked;
    looked = 0;
    final (fullScan, scanIds, scanRange) = await time(scan);
    final scanLooked = looked;

    // ignore: avoid_print
    print(
      'LAN engine, 100k receipts, 1-month window, first page of 1001:\n'
      '  indexed, cold (builds index): ${cold.inMilliseconds} ms\n'
      '  indexed, warm:                ${warm.inMilliseconds} ms\n'
      '  full scan:                    ${fullScan.inMilliseconds} ms\n'
      '  content-range: $warmRange\n'
      '  rows looked at: cold $coldLooked, warm $warmLooked, scan $scanLooked',
    );

    // Same answer either way.
    expect(warmIds, scanIds);
    expect(coldIds, scanIds);
    expect(warmRange, scanRange);
    expect(coldRange, scanRange);
    expect(warmIds, hasLength(1001));
    final total = int.parse(warmRange!.split('/').last);
    expect(total, greaterThan(8000));
    expect(total, lessThan(9000));
    // The index looks only at the month's rows; the scan at every row.
    // (Timings are printed only: machine load must not fail the suite.)
    expect(scanLooked, greaterThanOrEqualTo(rows.length));
    expect(warmLooked, lessThan(total * 2));
    expect(coldLooked, lessThan(total * 2));
  });
}
