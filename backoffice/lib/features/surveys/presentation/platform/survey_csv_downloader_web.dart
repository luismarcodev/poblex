import 'dart:convert';

import 'package:web/web.dart' as web;

bool downloadSurveyCsv({required String filename, required String csv}) {
  final href = Uri.dataFromString(
    csv,
    mimeType: 'text/csv',
    encoding: utf8,
  ).toString();
  final anchor = web.HTMLAnchorElement()
    ..href = href
    ..download = filename;
  anchor.click();
  return true;
}
