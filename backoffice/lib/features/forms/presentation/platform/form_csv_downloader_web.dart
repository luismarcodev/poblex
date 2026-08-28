import 'dart:convert';

import 'package:web/web.dart' as web;

bool downloadFormCsv({required String filename, required String csv}) {
  final anchor = web.HTMLAnchorElement()
    ..href = Uri.dataFromString(
      csv,
      mimeType: 'text/csv',
      encoding: utf8,
    ).toString()
    ..download = filename;
  anchor.click();
  return true;
}
