import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/services/lan/lan_addresses.dart';

void main() {
  const interfaces = [
    LanInterface(
      name: 'en0',
      index: 4,
      addresses: ['192.168.1.20', 'fe80::aaaa%en0'],
    ),
    LanInterface(name: 'en1', index: 5, addresses: ['10.0.0.5']),
    LanInterface(
      name: 'utun3',
      index: 9,
      addresses: ['fe80::bbbb%utun3', '10.8.0.2'],
    ),
    LanInterface(name: 'en2', index: 6, addresses: ['100.64.0.1']),
  ];

  group('buildCandidates', () {
    test('keeps IPv4, keeps zones, expands zone-less fe80, drops junk', () {
      final out = buildCandidates(
        [
          '192.168.1.30',
          'fe80::1',
          'fe80::2%en0',
          'not-an-ip',
          '192.168.1.30',
          ' 169.254.10.2 ',
          '::1',
        ],
        interfaces,
        isWindows: false,
      );

      expect(out, [
        '192.168.1.30',
        'fe80::1%en0',
        'fe80::2%en0',
        '169.254.10.2',
        '::1',
      ]);
    });

    test('uses the numeric interface index as the zone on Windows', () {
      expect(buildCandidates(['fe80::1'], interfaces, isWindows: true), [
        'fe80::1%4',
      ]);
    });

    test('drops zones on tunnel and AirDrop interfaces', () {
      expect(
        buildCandidates(
          ['fe80::3%utun3', 'fe80::3%9', 'fe80::4%awdl0'],
          [
            ...interfaces,
            const LanInterface(name: 'awdl0', index: 11, addresses: []),
          ],
          isWindows: false,
        ),
        isEmpty,
      );
    });

    test('drops a zone on anything but IPv6 link-local', () {
      expect(
        buildCandidates(
          ['10.0.0.9%en0', 'fe80::1%', 'fe80::1%bad zone'],
          interfaces,
          isWindows: false,
        ),
        isEmpty,
      );
    });

    test('a zone-less fe80 with no usable link-local interface is dropped', () {
      expect(
        buildCandidates(
          ['fe80::1'],
          const [LanInterface(name: 'en1', index: 5, addresses: ['10.0.0.5'])],
          isWindows: false,
        ),
        isEmpty,
      );
    });
  });

  test('isSkippedInterfaceName', () {
    expect(isSkippedInterfaceName('utun0'), isTrue);
    expect(isSkippedInterfaceName('AWDL0'), isTrue);
    expect(isSkippedInterfaceName('llw0'), isTrue);
    expect(isSkippedInterfaceName('en0'), isFalse);
    expect(isSkippedInterfaceName('Ethernet 2'), isFalse);
  });

  test('isPrivateIPv4', () {
    expect(isPrivateIPv4('10.1.2.3'), isTrue);
    expect(isPrivateIPv4('172.16.0.1'), isTrue);
    expect(isPrivateIPv4('172.31.255.1'), isTrue);
    expect(isPrivateIPv4('172.32.0.1'), isFalse);
    expect(isPrivateIPv4('192.168.0.1'), isTrue);
    expect(isPrivateIPv4('169.254.1.1'), isFalse);
    expect(isPrivateIPv4('100.64.0.1'), isFalse);
    expect(isPrivateIPv4('fe80::1'), isFalse);
  });

  test('sweepTargets covers each private /24 except own and tunnels', () {
    final targets = sweepTargets(interfaces);

    expect(targets, hasLength(253 * 2));
    expect(targets, contains('192.168.1.1'));
    expect(targets, contains('192.168.1.254'));
    expect(targets, contains('10.0.0.1'));
    expect(targets, isNot(contains('192.168.1.20')));
    expect(targets, isNot(contains('10.0.0.5')));
    expect(targets.any((t) => t.startsWith('10.8.0.')), isFalse);
    expect(targets.any((t) => t.startsWith('100.64.0.')), isFalse);
  });

  test('ownAddresses skips tunnel interfaces', () {
    expect(ownAddresses(interfaces), [
      '192.168.1.20',
      'fe80::aaaa%en0',
      '10.0.0.5',
      '100.64.0.1',
    ]);
  });
}
