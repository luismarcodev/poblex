import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

import 'business_photo_picker_types.dart';

/// Selección múltiple, a diferencia del picker de adjuntos de noticias: el
/// gestor sube la galería de un comercio de una vez, no foto a foto.
Future<List<PickedBusinessPhoto>> pickBusinessPhotos() async {
  final input = web.HTMLInputElement()
    ..type = 'file'
    ..multiple = true
    ..accept = 'image/jpeg,image/png,image/webp';
  final selected = Completer<web.FileList?>();

  void completeSelection(web.Event _) {
    if (!selected.isCompleted) selected.complete(input.files);
  }

  void completeCancellation(web.Event _) {
    if (!selected.isCompleted) selected.complete(null);
  }

  input.addEventListener('change', completeSelection.toJS);
  input.addEventListener('cancel', completeCancellation.toJS);
  input.click();

  final files = await selected.future;
  if (files == null || files.length == 0) return const [];

  final picked = <PickedBusinessPhoto>[];
  for (var index = 0; index < files.length; index++) {
    final file = files.item(index);
    if (file == null) continue;
    final buffer = (await file.arrayBuffer().toDart).toDart;
    picked.add(
      PickedBusinessPhoto(name: file.name, bytes: Uint8List.view(buffer)),
    );
  }
  return picked;
}
