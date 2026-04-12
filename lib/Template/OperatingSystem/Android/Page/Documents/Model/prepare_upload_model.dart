class PrepareUploadResult {
  final String fileName;
  final String extension;
  final String? folderId;

  PrepareUploadResult({
    required this.fileName,
    required this.extension,
    this.folderId,
  });
}
