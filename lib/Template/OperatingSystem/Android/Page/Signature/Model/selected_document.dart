import 'dart:io';
import '../../../../../Utils/Formatters/formatter.dart';

class SelectedDocument {
  final String name;
  final File file;
  final double sizeMB;
  final String? documentId; // Non-null if already in library
  final String? storagePath; // Path in storage if already in library
  final String? folderId; // Target folder for new uploads

  SelectedDocument({
    required this.name,
    required this.file,
    required this.sizeMB,
    this.documentId,
    this.storagePath,
    this.folderId,
  });

  String get sizeLabel => AppFormatter.fileSizeFromMB(sizeMB);

  SelectedDocument copyWith({
    String? name,
    File? file,
    double? sizeMB,
    String? documentId,
    String? storagePath,
    String? folderId,
  }) {
    return SelectedDocument(
      name: name ?? this.name,
      file: file ?? this.file,
      sizeMB: sizeMB ?? this.sizeMB,
      documentId: documentId ?? this.documentId,
      storagePath: storagePath ?? this.storagePath,
      folderId: folderId ?? this.folderId,
    );
  }
}
