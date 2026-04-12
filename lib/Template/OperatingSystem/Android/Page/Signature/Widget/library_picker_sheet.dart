import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../Commons/Styles/style.dart';
import '../../../../../Commons/Widgets/loading_shimmer.dart';
import '../../Documents/Model/document_model.dart';
import '../../Documents/Repository/document_repository.dart';

class LibraryPickerSheet extends StatefulWidget {
  final Function(DocumentModel) onPick;

  const LibraryPickerSheet({super.key, required this.onPick});

  static void show({required Function(DocumentModel) onPick}) {
    Get.bottomSheet(
      LibraryPickerSheet(onPick: onPick),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  State<LibraryPickerSheet> createState() => _LibraryPickerSheetState();
}

class _LibraryPickerSheetState extends State<LibraryPickerSheet> {
  final DocumentRepository _repo = DocumentRepository();
  final RxList<DocumentModel> _documents = <DocumentModel>[].obs;
  final RxBool _isLoading = true.obs;
  final RxString _searchQuery = ''.obs;

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    _isLoading.value = true;
    try {
      final docs = await _repo.getAllDocuments();
      // Only show PDFs for signature requests
      _documents.value = docs.where((d) => d.isPdf).toList();
    } finally {
      _isLoading.value = false;
    }
  }

  List<DocumentModel> get _filteredDocs {
    if (_searchQuery.value.isEmpty) return _documents;
    return _documents
        .where(
          (d) =>
              d.name.toLowerCase().contains(_searchQuery.value.toLowerCase()),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      height: Get.height * 0.85,
      decoration: AppStyle.bottomSheetDecoration(context),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: AppStyle.bottomSheetHandleOf(context),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Select from Library',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: TextField(
              onChanged: (v) => _searchQuery.value = v,
              decoration: const InputDecoration(
                hintText: 'Search documents...',
                prefixIcon: Icon(Icons.search, size: 20),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Obx(() {
              if (_isLoading.value) {
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: 5,
                  itemBuilder: (_, _) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: LoadingShimmer.box(context, height: 72, radius: 12),
                  ),
                );
              }

              if (_filteredDocs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _searchQuery.value.isEmpty
                            ? Icons.folder_open_outlined
                            : Icons.search_off_outlined,
                        size: 64,
                        color: cs.onSurfaceVariant.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _searchQuery.value.isEmpty
                            ? 'No documents found'
                            : 'No matching documents',
                        style: textTheme.titleMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                itemCount: _filteredDocs.length,
                itemBuilder: (context, index) {
                  final doc = _filteredDocs[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: AppStyle.cardOf(context),
                    child: ListTile(
                      onTap: () {
                        Get.back();
                        widget.onPick(doc);
                      },
                      leading: Container(
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
                              color: cs.surfaceContainer,
                              fontWeight: FontWeight.w800,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                      title: Text(
                        doc.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.titleSmall,
                      ),
                      subtitle: Text(
                        '${doc.fileSizeMB.toStringAsFixed(2)} MB',
                        style: textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      trailing: Icon(
                        Icons.chevron_right,
                        size: 20,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
