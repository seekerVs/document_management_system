import 'dart:io';
import '../../../../../Utils/Formatters/formatter.dart';

class SelectedDocument {
  final String name;
  final File file;
  final double sizeMB;

  SelectedDocument({
    required this.name,
    required this.file,
    required this.sizeMB,
  });

  String get sizeLabel => AppFormatter.fileSizeFromMB(sizeMB);

  SelectedDocument copyWith({
    String? name,
    File? file,
    double? sizeMB,
  }) {
    return SelectedDocument(
      name: name ?? this.name,
      file: file ?? this.file,
      sizeMB: sizeMB ?? this.sizeMB,
    );
  }
}
