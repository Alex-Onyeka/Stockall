import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:stockall/local_database/lan/local_server_func.dart';
import 'package:stockall/services/lan/device_identity.dart';

void main() {
  final uuidV4 = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
  );

  setUpAll(() {
    Hive.init(
      Directory.systemTemp.createTempSync('stockall_lan_identity').path,
    );
  });

  tearDownAll(() async {
    await Hive.close();
  });

  test('device_id is a v4 UUID and stable across reads', () async {
    await DeviceIdentity().init();
    final first = await DeviceIdentity().deviceId();
    final second = await DeviceIdentity().deviceId();

    expect(first, matches(uuidV4));
    expect(second, first);
  });

  test('device_id persists after the box is closed and reopened', () async {
    await DeviceIdentity().init();
    final before = await DeviceIdentity().deviceId();

    await DeviceIdentity().deviceIdentityBox.close();
    await DeviceIdentity().init();

    expect(await DeviceIdentity().deviceId(), before);
  });

  test('device_id survives clearing the local server records', () async {
    await DeviceIdentity().init();
    await LocalServerFunc().init();
    final before = await DeviceIdentity().deviceId();

    await LocalServerFunc().clearLocalServerRecords();

    expect(await DeviceIdentity().deviceId(), before);
  });
}
