import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/constants/functions.dart';

void main() {
  test('the permission string is "Manage Local Server"', () {
    expect(Authorizations().manageLocalServer, 'Manage Local Server');
  });

  test('the migration grants that exact string to Owner and General Manager',
      () {
    final migrations =
        Directory('supabase/migrations')
            .listSync()
            .whereType<File>()
            .where(
              (f) => f.path.endsWith('_manage_local_server_permission.sql'),
            )
            .toList();

    expect(migrations, hasLength(1));
    final sql = migrations.single.readAsStringSync();

    expect(
      sql,
      contains("perm  constant text   := '${Authorizations().manageLocalServer}'"),
    );
    expect(sql, contains("ARRAY['Owner', 'General Manager']"));
    expect(sql, contains('UPDATE public.permissions'));
    expect(sql, contains('UPDATE public.users'));
  });
}
