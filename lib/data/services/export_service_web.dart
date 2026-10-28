import 'dart:convert';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

Future<String> saveCsvFile(String csvContent, String fileName) async {
  final bytes = utf8.encode(csvContent);
  final jsArray = bytes.toJS;
  final blobParts = <JSAny>[jsArray].toJS;
  final blob = web.Blob(blobParts, web.BlobPropertyBag(type: 'text/csv'));

  final url = web.URL.createObjectURL(blob);
  final anchor = web.HTMLAnchorElement()
    ..href = url
    ..download = fileName;

  (web.document.body as web.HTMLBodyElement?)?.appendChild(anchor);
  anchor.click();
  anchor.remove();
  web.URL.revokeObjectURL(url);

  return '';
}
