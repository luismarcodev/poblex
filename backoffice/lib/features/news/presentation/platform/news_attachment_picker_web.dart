import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

import 'news_attachment_picker_types.dart';

Future<PickedNewsAttachment?> pickNewsAttachment() async {
  final input = web.HTMLInputElement()
    ..type = 'file'
    ..accept = 'application/pdf,image/jpeg,image/png,image/webp';
  final selected = Completer<web.File?>();

  void completeSelection(web.Event _) {
    if (!selected.isCompleted) selected.complete(input.files?.item(0));
  }

  void completeCancellation(web.Event _) {
    if (!selected.isCompleted) selected.complete(null);
  }

  input.addEventListener('change', completeSelection.toJS);
  input.addEventListener('cancel', completeCancellation.toJS);
  input.click();

  final file = await selected.future;
  if (file == null) return null;
  final buffer = (await file.arrayBuffer().toDart).toDart;
  return PickedNewsAttachment(name: file.name, bytes: Uint8List.view(buffer));
}
