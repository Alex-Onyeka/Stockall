import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_expenses/expense_category.dart';
import 'package:stockall/classes/temp_expenses/unsynced/created_expense_categories/created_expense_category.dart';
import 'package:stockall/local_database/expenses/expense_categories_func.dart';
import 'package:stockall/local_database/main_database.dart';
import 'package:stockall/services/lan/lan_routing.dart';
import 'package:stockall/services/lan/rest/lan_table_registry.dart';

/// The files whose code writes the app's queues for the LAN server.
const List<String> _writerFiles = [
  'lib/services/lan/rest/lan_more_tables.dart',
  'lib/services/lan/rest/lan_table_writes.dart',
  'lib/services/lan/rest/lan_store_tables.dart',
  'lib/services/lan/rest/lan_delta_registry.dart',
  'lib/services/lan/rest/lan_table_registry.dart',
  'lib/services/lan/lan_transport_io.dart',
];

/// A queue Func's class name: `Created…Func`, `Updated…Func`,
/// `Deleted…Func`, the quantity and account update queues.
final RegExp _queueFunc = RegExp(
  r'\b((?:Created|Updated|Deleted)[A-Za-z]*Func|[A-Za-z]*QuantityUpdateFunc|'
  r'CustomerAccountUpdateFunc)\(\)',
);

/// Each Func class in `lib/local_database` and the queue box name it opens.
Map<String, String> _boxOfFunc() {
  final out = <String, String>{};
  for (final f in Directory('lib/local_database').listSync(recursive: true)) {
    if (f is! File || !f.path.endsWith('.dart')) continue;
    final src = f.readAsStringSync();
    final cls = RegExp(r'class (\w+Func)\b').firstMatch(src)?.group(1);
    final box = RegExp(r"'(\w+BoxStockall)'").firstMatch(src)?.group(1);
    if (cls != null && box != null) out[cls] = box;
  }
  return out;
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final dir = Directory.systemTemp.createTempSync('stockall_lan_queues');
    // initHive() keeps the boxes in the app-support directory.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (call) async => dir.path,
        );
    await MainDatabase().initHive();
  });

  tearDownAll(() async {
    await Hive.close();
  });

  test('every queue the LAN server\'s writes add to is in lanQueues(): a '
      'queue box named in the registry, or a queue Func its writers use', () {
    final covered = lanQueues().keys.toSet();
    final boxOf = _boxOfFunc();
    final used = <String>{};
    for (final path in _writerFiles) {
      final src = File(path).readAsStringSync();
      for (final m in RegExp(
        r"(?:created|updated|deleted):\s*'(\w+)'",
      ).allMatches(src)) {
        used.add(m.group(1)!);
      }
      for (final m in _queueFunc.allMatches(src)) {
        final box = boxOf[m.group(1)!];
        expect(box, isNotNull, reason: 'no box found for ${m.group(1)}');
        used.add(box!);
      }
    }
    expect(used.difference(covered), isEmpty);
    // The two isSynced() never looked at.
    expect(
      covered,
      containsAll(['createdExpenseCategoriesBoxStockall', 'createdErrorLogBoxStockall']),
    );
    // Every one of them is opened by initHive.
    for (final name in covered) {
      expect(Hive.isBoxOpen(name), isTrue, reason: name);
    }
  });

  test('a queued expense category keeps the server from saying its queues '
      'reached Supabase; empty queues let it', () async {
    expect(serverQueuesEmpty(syncing: () => false), isTrue);

    await Hive.box<CreatedExpenseCategory>(
      ExpenseCategoriesFunc.createdBoxName,
    ).put(
      'ec-1',
      CreatedExpenseCategory(
        category: ExpenseCategory(uuid: 'ec-1', shopId: 7, name: 'Rent'),
      ),
    );
    expect(serverQueuesEmpty(syncing: () => false), isFalse);

    await Hive.box<CreatedExpenseCategory>(
      ExpenseCategoriesFunc.createdBoxName,
    ).clear();
    expect(serverQueuesEmpty(syncing: () => false), isTrue);
    // Never while a sync runs.
    expect(serverQueuesEmpty(syncing: () => true), isFalse);
  });

  test('a queue box that isn\'t open counts as not empty', () {
    expect(
      serverQueuesEmpty(
        syncing: () => false,
        queues: {'neverOpenedBoxStockall': () => true},
      ),
      isFalse,
    );
  });
}
