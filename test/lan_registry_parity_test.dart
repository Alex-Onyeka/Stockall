import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/classes/lan/lan_user_credential.dart';
import 'package:stockall/classes/temp_permission/temp_permission_class.dart';
import 'package:stockall/classes/temp_shop/temp_shop_class.dart';
import 'package:stockall/classes/user_class/temp_user_class.dart';
import 'package:stockall/services/lan/lan_constants.dart';
import 'package:stockall/services/lan/rest/lan_store_tables.dart';
import 'package:stockall/services/lan/rest/lan_table.dart';
import 'package:stockall/services/lan/rest/lan_table_registry.dart';

import 'helpers/lan_fixtures.dart';
import 'helpers/lan_samples.dart';

/// Every table the server registers must mean on the LAN what it means on
/// Supabase:
/// - each column reads what `toJson` sends under that key (or a filter
///   would select different rows);
/// - a table written on the server round-trips through `fromJson` (an
///   update merges into `toJson` and parses it back);
/// - every table the app queries is served, forwarded or known unused,
///   and every column the app filters, orders or selects on a served table
///   is registered (or the LAN would answer 42703 where Supabase answers).
void main() {
  final tables = {
    for (final t in lanTables(shopId: () => 7)) t.name: t,
  };

  // Rows to check each table with.
  final samples = {for (final s in lanSamples()) s.table: s.json};
  final credential = LanUserCredential(
    shopId: 7,
    userId: 'staff-1',
    email: 'ada@shop.test',
    salt: 's',
    hash: 'h',
    iterations: 1,
    role: 'Cashier',
    access: const ['Make Sale'],
    departmentUuids: const [],
    isOwner: false,
    profileJson: jsonEncode(
      TempUserClass(
        userId: 'staff-1',
        name: 'Ada',
        email: 'ada@shop.test',
        password: 'secret',
        role: 'Cashier',
        departmentUuids: const [],
        access: const ['Make Sale'],
        pin: '1234',
      ).toJson()..remove('password'),
    ),
    updatedAt: DateTime.utc(2026, 11, 1),
  );
  Object rowFor(LanTable<dynamic> table) {
    switch (table.name) {
      case 'products':
        return product('p1', department: 'd1');
      case 'receipts':
        return receipt('r1', t0, department: 'd1');
      case 'invoices':
        return invoice('i1', t0);
      case 'orders':
        return order('o1', balance: 2);
      case 'customers':
        return customer('c1');
      case 'expenses':
        return expense('e1');
      case 'shops':
        return TempShopClass.fromJson(shopSample);
      case 'users':
        return credential;
      case 'permissions':
        return PermissionModel.fromJson(permissionSample);
    }
    final json = samples[table.name];
    if (json == null) fail('no sample row for ${table.name}');
    return table.writes!.fromJson(json) as Object;
  }

  Object? normalized(Object? v) {
    if (v is DateTime) return v.toUtc().microsecondsSinceEpoch;
    if (v is String) {
      final t = DateTime.tryParse(v);
      if (t != null && v.contains('-') && v.contains(':')) {
        return t.toUtc().microsecondsSinceEpoch;
      }
    }
    if (v is num) return v.toDouble();
    if (v is List) return [for (final e in v) normalized(e)];
    return v;
  }

  test('all 29 tables are registered', () {
    expect(tables, hasLength(29));
    expect(
      tables.keys.toSet(),
      containsAll([...samples.keys, 'shops', 'users', 'permissions']),
    );
  });

  group('each column reads what toJson sends', () {
    for (final name in tables.keys) {
      test(name, () {
        tables[name]!.withRowType(<X>(LanTable<X> table) {
          final row = rowFor(table) as X;
          final json = _wire(table.toJson(row));
          for (final MapEntry(key: column, value: c) in table.columns.entries) {
            expect(json.containsKey(column), isTrue, reason: '$name.$column');
            expect(
              normalized(c.get(row)),
              normalized(json[column]),
              reason: '$name.$column',
            );
          }
          return null;
        });
      });
    }
  });

  group('tables written on the server round-trip through fromJson', () {
    for (final name in tables.keys) {
      if (tables[name]!.writes?.isLocal != true) continue;
      test(name, () {
        tables[name]!.withRowType(<X>(LanTable<X> table) {
          final json = _wire(table.toJson(rowFor(table) as X));
          final again = _wire(table.toJson(table.writes!.fromJson(json)));
          // Every value survives; a null may come back as the model's
          // default (e.g. false), which is not lost data.
          expect(again.keys.toSet(), json.keys.toSet());
          for (final key in json.keys) {
            if (json[key] == null) continue;
            expect(
              jsonEncode(again[key]),
              jsonEncode(json[key]),
              reason: '$name.$key',
            );
          }
          return null;
        });
      });
    }
  });

  test('shops, users and permissions parse on the client', () {
    final shop = TempShopClass.fromJson(
      lanShopJson(TempShopClass.fromJson(shopSample)),
    );
    expect(shop.shopId, 7);
    expect(shop.isAllowedBySubscription, isTrue);

    final userJson = lanUserJson(credential);
    final user = TempUserClass.fromJson(userJson);
    expect(user.userId, 'staff-1');
    expect(user.pin, '1234');
    expect(userJson['password'], '');

    final perm = PermissionModel.fromJson(
      lanPermissionJson(PermissionModel.fromJson(permissionSample)),
    );
    expect(perm.permitNumber, 2);
  });

  group('the app\'s queries', () {
    // Supabase-only clients that never go through the LAN.
    const notRouted = {
      'lib/services/auth_service.dart',
    };
    // Tables no live code reads or writes.
    const unused = {
      'product_sales',
      'waybills',
      'way_bills',
      'product_suggestions',
      'referrees',
    };
    final uses = _scanQueries(notRouted);

    test('every table is served, forwarded or known unused', () {
      final unknown = {
        for (final u in uses)
          if (!tables.containsKey(u.table) &&
              !LanConstants.onlineOnlyTables.contains(u.table) &&
              !unused.contains(u.table))
            '${u.table} (${u.where})',
      };
      expect(unknown, isEmpty);
      // The scan really saw the app's queries.
      expect(uses.map((u) => u.table).toSet(), containsAll(tables.keys));
    });

    test('every column used on a served table is registered', () {
      final missing = {
        for (final u in uses)
          if (tables[u.table] case final table?)
            for (final column in u.columns)
              if (!table.columns.containsKey(column))
                '${u.table}.$column (${u.where})',
      };
      expect(missing, isEmpty);
    });
  });
}

/// What a client receives: the JSON on the wire.
Map<String, dynamic> _wire(Map<String, dynamic> json) =>
    jsonDecode(jsonEncode(json)) as Map<String, dynamic>;

class _Use {
  _Use(this.table, this.columns, this.where);
  final String table;
  final Set<String> columns;
  final String where;
}

/// Every `.from(<table>)…;` chain in lib/ outside the LAN server itself,
/// with the columns its filters, orders and selects name.
List<_Use> _scanQueries(Set<String> skip) {
  final uses = <_Use>[];
  final files = Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .where((f) => !f.path.startsWith('lib/services/lan/'))
      .where((f) => !skip.contains(f.path));
  for (final file in files) {
    final source = file
        .readAsLinesSync()
        .map((l) => l.trimLeft().startsWith('//') ? '' : l)
        .join('\n');
    final tableName = RegExp(
      r"tableName\s*=\s*'(\w+)'",
    ).firstMatch(source)?.group(1);
    for (final m in RegExp(r"\.from\(\s*('(\w+)'|tableName)\s*\)").allMatches(
      source,
    )) {
      // storage.from('logos') is the storage API.
      final before = source.substring(0, m.start).trimRight();
      if (before.endsWith('storage')) continue;
      final table = m.group(2) ?? tableName;
      if (table == null) continue;
      final end = source.indexOf(';', m.end);
      final chain = source.substring(m.end, end < 0 ? source.length : end);
      final columns = <String>{
        for (final c in RegExp(
          r"\.(?:eq|neq|gt|gte|lt|lte|inFilter|contains|order)\(\s*'(\w+)'",
        ).allMatches(chain))
          c.group(1)!,
        for (final s in RegExp(r"\.select\(\s*'([^']*)'").allMatches(chain))
          for (final c in s.group(1)!.split(','))
            if (c.trim().isNotEmpty) c.trim(),
        for (final o in RegExp(r"\.or\(\s*'([^']*)'").allMatches(chain))
          for (final term in o.group(1)!.split(','))
            term.split('.').first.trim(),
      };
      final line = '\n'.allMatches(source.substring(0, m.start)).length + 1;
      uses.add(_Use(table, columns, '${file.path}:$line'));
    }
  }
  return uses;
}
