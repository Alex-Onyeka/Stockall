import 'dart:convert';
import 'dart:typed_data';

import 'package:stockall/classes/temp_shop_logos/temp_shop_logos.dart';
import 'package:stockall/services/lan/lan_access_policy.dart';

/// A `/storage/v1/...` request, as the LAN server received it.
class LanStorageRequest {
  const LanStorageRequest({
    required this.method,
    required this.path,
    required this.headers,
    required this.body,
  });

  final String method;

  /// What follows `/storage/v1/` (`object/logos/logos/7-1.png`).
  final String path;

  /// Lower-case keys.
  final Map<String, String> headers;
  final Uint8List body;
}

class LanStorageResponse {
  const LanStorageResponse(this.status, this.body, {this.contentType});

  factory LanStorageResponse.json(int status, Object? json) {
    return LanStorageResponse(
      status,
      Uint8List.fromList(utf8.encode(jsonEncode(json))),
      contentType: 'application/json',
    );
  }

  /// In storage-api's error shape, which storage-dart turns into a
  /// `StorageException`.
  factory LanStorageResponse.error(int status, String error, String message) {
    return LanStorageResponse.json(status, {
      'statusCode': '$status',
      'error': error,
      'message': message,
    });
  }

  final int status;
  final Uint8List body;
  final String? contentType;
}

abstract class LanStorageHandler {
  Future<LanStorageResponse> handle(
    LanStorageRequest request,
    LanPrincipal principal,
  );
}

/// The shop logo over the LAN, mirroring the app's offline logo
/// flow so the server's own sync uploads it:
/// - an upload to the `logos` bucket is held in memory;
/// - the shop update that points `logo_url` at it then queues the logo in
///   the server's created-logo box (and its local logo box) with the size
///   from that update, and leaves `logo_url` as it was: the server's
///   `uploadShopLogoSync` sets it to the Supabase URL after uploading, and
///   then deletes the previous logo, as the app does offline;
/// - a `logo_url` naming the LAN server for any other path is rewritten to
///   the Supabase public URL for the same path;
/// - removing objects answers "nothing removed": the server's sync removes
///   the old logo itself;
/// - downloads serve a held upload or the stored logo.
class LanLogoStorage implements LanStorageHandler {
  LanLogoStorage({
    required this.publicUrlOf,
    required this.storedLogo,
    required this.queueLogo,
    this.maxBytes = 5 * 1024 * 1024,
  });

  /// The Supabase public URL of an object in the `logos` bucket.
  final String Function(String objectPath) publicUrlOf;

  /// The logo the server already holds for its shop, if any.
  final TempShopLogos? Function() storedLogo;

  /// Puts a logo in the server's created-logo and logo boxes.
  final Future<void> Function(TempShopLogos logo) queueLogo;

  final int maxBytes;

  final Map<String, ({Uint8List bytes, String? contentType})> _held = {};

  static const String _bucket = 'logos';
  static const String _publicMarker = '/object/public/$_bucket/';

  @override
  Future<LanStorageResponse> handle(
    LanStorageRequest request,
    LanPrincipal principal,
  ) async {
    final path = request.path;
    final method = request.method.toUpperCase();
    if (method == 'GET') {
      for (final prefix in [
        'object/public/$_bucket/',
        'object/authenticated/$_bucket/',
        'object/$_bucket/',
      ]) {
        if (path.startsWith(prefix)) return _download(path.substring(prefix.length));
      }
    }
    if ((method == 'POST' || method == 'PUT') &&
        path.startsWith('object/$_bucket/')) {
      return _upload(path.substring('object/$_bucket/'.length), request, principal);
    }
    if (method == 'DELETE' && path == 'object/$_bucket') {
      if (!LanAccessPolicy.canWrite(principal, 'shops', LanWriteOp.update)) {
        return LanStorageResponse.error(403, 'Unauthorized', 'Not allowed');
      }
      return LanStorageResponse.json(200, const <Object>[]);
    }
    return LanStorageResponse.error(
      404,
      'not_found',
      'Only the logos bucket is served by the store server',
    );
  }

  Future<LanStorageResponse> _upload(
    String objectPath,
    LanStorageRequest request,
    LanPrincipal principal,
  ) async {
    if (!LanAccessPolicy.canWrite(principal, 'shops', LanWriteOp.update)) {
      return LanStorageResponse.error(403, 'Unauthorized', 'Not allowed');
    }
    if (objectPath.isEmpty || objectPath.contains('..')) {
      return LanStorageResponse.error(400, 'InvalidKey', 'Bad object path');
    }
    if (request.body.length > maxBytes) {
      return LanStorageResponse.error(413, 'Payload too large', 'Logo too large');
    }
    final file = _filePart(request.headers['content-type'], request.body);
    if (file == null || file.bytes.isEmpty) {
      return LanStorageResponse.error(400, 'InvalidRequest', 'No file sent');
    }
    _held[objectPath] = file;
    return LanStorageResponse.json(200, {
      'Key': '$_bucket/$objectPath',
      'Id': objectPath,
    });
  }

  LanStorageResponse _download(String objectPath) {
    final held = _held[objectPath];
    if (held != null) {
      return LanStorageResponse(
        200,
        held.bytes,
        contentType: held.contentType ?? 'application/octet-stream',
      );
    }
    final stored = storedLogo();
    if (stored != null && stored.imageName == objectPath) {
      return LanStorageResponse(200, base64Decode(stored.logoPath));
    }
    return LanStorageResponse.error(404, 'not_found', 'Object not found');
  }

  /// For the shops table: takes `logo_url` out of a shop update that points
  /// at a held upload, queueing that logo instead; rewrites a `logo_url`
  /// that names the LAN server to the Supabase URL.
  Future<Map<String, dynamic>> preparePatch(Map<String, dynamic> patch) async {
    final url = patch['logo_url'];
    if (url is! String) return patch;
    final at = url.indexOf(_publicMarker);
    if (at < 0) return patch;
    final objectPath = Uri.decodeComponent(
      url.substring(at + _publicMarker.length).split('?').first,
    );
    final held = _held.remove(objectPath);
    if (held != null) {
      final current = storedLogo();
      await queueLogo(
        TempShopLogos(
          logoPath: base64Encode(held.bytes),
          imageName: objectPath,
          imageHeight: _int(patch['image_height']) ?? current?.imageHeight ?? 0,
          imageWidth: _int(patch['image_width']) ?? current?.imageWidth ?? 0,
        ),
      );
      return Map.of(patch)..remove('logo_url');
    }
    if (Uri.tryParse(url)?.host == 'stockall-lan') {
      return Map.of(patch)..['logo_url'] = publicUrlOf(objectPath);
    }
    return patch;
  }

  static int? _int(Object? v) => v is num ? v.toInt() : null;

  /// The file part of a `multipart/form-data` body (storage-dart sends the
  /// bytes as a part with a `filename`).
  static ({Uint8List bytes, String? contentType})? _filePart(
    String? contentType,
    Uint8List body,
  ) {
    final match = RegExp(r'boundary=("?)([^";]+)\1').firstMatch(contentType ?? '');
    if (match == null) {
      // A raw body (not multipart) is the file itself.
      return (bytes: body, contentType: contentType);
    }
    final delimiter = utf8.encode('--${match.group(2)}');
    var start = _indexOf(body, delimiter, 0);
    while (start >= 0) {
      final partStart = start + delimiter.length;
      // "--" after the delimiter ends the body.
      if (partStart + 1 < body.length &&
          body[partStart] == 0x2d &&
          body[partStart + 1] == 0x2d) {
        break;
      }
      final next = _indexOf(body, delimiter, partStart);
      if (next < 0) break;
      final part = Uint8List.sublistView(body, partStart, next);
      final split = _indexOf(part, const [13, 10, 13, 10], 0);
      if (split >= 0) {
        final head = utf8.decode(part.sublist(0, split), allowMalformed: true);
        if (head.toLowerCase().contains('filename=')) {
          var end = part.length;
          // Drop the CRLF before the next delimiter.
          if (end >= 2 && part[end - 2] == 13 && part[end - 1] == 10) end -= 2;
          final type = RegExp(
            r'content-type:\s*([^\r\n]+)',
            caseSensitive: false,
          ).firstMatch(head)?.group(1)?.trim();
          return (
            bytes: Uint8List.fromList(part.sublist(split + 4, end)),
            contentType: type,
          );
        }
      }
      start = next;
    }
    return null;
  }

  static int _indexOf(List<int> haystack, List<int> needle, int from) {
    outer:
    for (var i = from; i <= haystack.length - needle.length; i++) {
      for (var j = 0; j < needle.length; j++) {
        if (haystack[i + j] != needle[j]) continue outer;
      }
      return i;
    }
    return -1;
  }
}
