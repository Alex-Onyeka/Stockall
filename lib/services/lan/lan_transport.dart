// Picks the LAN transport for the platform: dart:io everywhere except web,
// where a stub reports LAN sync as unavailable (no sockets, no mDNS).
export 'lan_transport_types.dart';
export 'lan_transport_stub.dart'
    if (dart.library.io) 'lan_transport_io.dart';
