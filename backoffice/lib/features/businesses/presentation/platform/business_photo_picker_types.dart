import 'dart:typed_data';

class PickedBusinessPhoto {
  const PickedBusinessPhoto({required this.name, required this.bytes});

  final String name;
  final Uint8List bytes;
}
