import 'dart:io';
import '../../../../../Utils/Formatters/formatter.dart';

// Local-only model — not persisted to Firestore until request is submitted
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
}
