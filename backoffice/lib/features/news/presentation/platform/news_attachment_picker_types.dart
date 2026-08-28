import 'dart:typed_data';

class PickedNewsAttachment {
  const PickedNewsAttachment({required this.name, required this.bytes});

  final String name;
  final Uint8List bytes;
}
