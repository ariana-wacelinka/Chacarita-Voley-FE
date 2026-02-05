import 'dart:typed_data';

class SelectedFile {
  final String name;
  final String? path;
  final Uint8List? bytes;

  const SelectedFile({required this.name, this.path, this.bytes});
}
