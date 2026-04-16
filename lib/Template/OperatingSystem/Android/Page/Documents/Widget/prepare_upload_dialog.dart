import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as p;
import '../../../../../../Template/Utils/Constant/texts.dart';
import '../../../../../../Template/Utils/Validators/validators.dart';
import '../../../../../../Template/Utils/Popups/dialog.dart';
import '../../../../../Commons/Widgets/app_text_field.dart';
import '../Model/prepare_upload_model.dart';
import '../Repository/folder_repository.dart';
import 'folder_picker_sheet.dart';

class PrepareUploadDialog extends StatefulWidget {
  final File file;
  final String originalName;
  final double fileSizeMB;
  final String? initialFolderId;

  const PrepareUploadDialog({
    super.key,
    required this.file,
    required this.originalName,
    required this.fileSizeMB,
    this.initialFolderId,
  });

  static Future<PrepareUploadResult?> show({
    required File file,
    required String originalName,
    required double fileSizeMB,
    String? initialFolderId,
  }) {
    return Get.dialog<PrepareUploadResult>(
      PrepareUploadDialog(
        file: file,
        originalName: originalName,
        fileSizeMB: fileSizeMB,
        initialFolderId: initialFolderId,
      ),
      barrierDismissible: false,
    );
  }

  @override
  State<PrepareUploadDialog> createState() => _PrepareUploadDialogState();
}

class _PrepareUploadDialogState extends State<PrepareUploadDialog> {
  late final TextEditingController _nameController;
  late final String _extension;
  final RxString _selectedFolderId = ''.obs;
  final RxString _selectedFolderName = ''.obs;
  final RxBool _isResolvingInitialFolder = false.obs;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _extension = p.extension(widget.originalName);
    final nameWithoutExt = p.basenameWithoutExtension(widget.originalName);
    _nameController = TextEditingController(text: nameWithoutExt);
    _selectedFolderId.value = widget.initialFolderId ?? '';
    _selectedFolderName.value = AppText.myDocuments;

    if (widget.initialFolderId != null) {
      _resolveInitialFolderName();
    }
  }

  Future<void> _resolveInitialFolderName() async {
    _isResolvingInitialFolder.value = true;
    try {
      final folders = await FolderRepository().getFolders();
      final folder = folders.firstWhereOrNull(
        (f) => f.folderId == widget.initialFolderId,
      );
      if (folder != null) {
        _selectedFolderName.value = folder.name;
      }
    } finally {
      _isResolvingInitialFolder.value = false;
    }
  }

  void _onShowFullPicker() {
    FolderPickerSheet.show(
      title: 'Select Destination',
      onPick: (folderId, folderName) {
        _selectedFolderId.value = folderId ?? '';
        _selectedFolderName.value = folderName;
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _onUpload() {
    if (_formKey.currentState!.validate()) {
      final result = PrepareUploadResult(
        fileName: _nameController.text.trim(),
        extension: _extension,
        folderId: _selectedFolderId.value.isEmpty
            ? null
            : _selectedFolderId.value,
      );
      Get.back(result: result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppDialogBase(
      title: 'Prepare Upload',
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // File Preview Box
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cs.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: cs.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: cs.error,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        'PDF',
                        style: TextStyle(
                          color: cs.surfaceContainerLowest,
                          fontWeight: FontWeight.w800,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.originalName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: cs.onSurface,
                          ),
                        ),
                        Text(
                          '${widget.fileSizeMB.toStringAsFixed(2)} MB',
                          style: textTheme.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Rename Field
            AppTextField(
              controller: _nameController,
              label: 'Document Name',
              hint: 'Enter file name',
              autofocus: true,
              maxLength: 100,
              validator: Validators.documentName,
              suffixIcon: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Center(
                  widthFactor: 1,
                  child: Text(
                    _extension,
                    style: textTheme.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Folder Selection Anchor
            Text(
              'Save to',
              style: textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _onShowFullPicker,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: cs.outlineVariant),
                ),
                child: Row(
                  children: [
                    Icon(
                      _selectedFolderId.value.isEmpty
                          ? Icons.home_outlined
                          : Icons.folder_outlined,
                      size: 20,
                      color: cs.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Obx(() {
                        if (_isResolvingInitialFolder.value) {
                          return Text(
                            'Loading...',
                            style: textTheme.bodyMedium?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          );
                        }
                        return Text(
                          _selectedFolderName.value,
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: cs.onSurface,
                          ),
                        );
                      }),
                    ),
                    Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: cs.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        AppDialogAction(
          label: AppText.cancel,
          onPressed: () => Get.back(),
          isPrimary: false,
        ),
        AppDialogAction(label: 'Upload', onPressed: _onUpload),
      ],
    );
  }
}
