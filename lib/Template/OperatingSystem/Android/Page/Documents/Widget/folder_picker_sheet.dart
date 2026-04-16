import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../../Template/Utils/Constant/texts.dart';
import '../../../../../Commons/Styles/style.dart';
import '../Model/folder_model.dart';
import '../Repository/folder_repository.dart';

class FolderPickerSheet extends StatefulWidget {
  final List<FolderModel>? preloadedFolders;
  final void Function(String? folderId, String folderName) onPick;
  final String title;
  final String? excludeFolderId;
  final bool excludeRoot;

  const FolderPickerSheet({
    super.key,
    this.preloadedFolders,
    required this.onPick,
    this.title = 'Copy to',
    this.excludeFolderId,
    this.excludeRoot = false,
  });

  static Future<void> show({
    List<FolderModel>? folders,
    required void Function(String? folderId, String folderName) onPick,
    String title = 'Copy to',
    String? excludeFolderId,
    bool excludeRoot = false,
  }) {
    return Get.bottomSheet(
      FolderPickerSheet(
        preloadedFolders: folders,
        onPick: onPick,
        title: title,
        excludeFolderId: excludeFolderId,
        excludeRoot: excludeRoot,
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enterBottomSheetDuration: const Duration(milliseconds: 300),
    );
  }

  @override
  State<FolderPickerSheet> createState() => _FolderPickerSheetState();
}

class _FolderPickerSheetState extends State<FolderPickerSheet> {
  final _folderRepo = FolderRepository();
  bool _isLoading = false;

  final List<FolderModel> _navigationStack = [];
  List<FolderModel> _currentFolders = [];
  FolderModel? _highlightedFolder;

  @override
  void initState() {
    super.initState();
    if (widget.preloadedFolders != null) {
      _currentFolders = widget.preloadedFolders!;
    } else {
      _loadFolders(null);
    }
  }

  FolderModel? get _currentFolder =>
      _navigationStack.isEmpty ? null : _navigationStack.last;

  Future<void> _loadFolders(String? parentId) async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      List<FolderModel> result;
      if (parentId == null) {
        result = await _folderRepo.getFolders();
      } else {
        result = await _folderRepo.getSubFolders(parentId);
      }
      if (mounted) {
        setState(() => _currentFolders = result);
      }
    } catch (_) {
      // Ignore or show snack
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _pushFolder(FolderModel folder) async {
    if (_highlightedFolder?.folderId == folder.folderId) {
      setState(() => _highlightedFolder = null);
      return;
    }

    if (folder.itemCount == 0) {
      setState(() => _highlightedFolder = folder);
      return;
    }

    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final subs = await _folderRepo.getSubFolders(folder.folderId);
      if (subs.isEmpty) {
        setState(() {
          _highlightedFolder = folder;
        });
      } else {
        setState(() {
          _highlightedFolder = null;
          _navigationStack.add(folder);
          _currentFolders = subs;
        });
      }
    } catch (_) {
      // Ignore
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _popFolder() {
    if (_navigationStack.isNotEmpty) {
      _navigationStack.removeLast();
      _highlightedFolder = null;
      _loadFolders(_currentFolder?.folderId);
    }
  }

  String _buildPathPath(FolderModel target) {
    if (_navigationStack.isEmpty) return target.name;
    final pathSegments = _navigationStack.map((f) => f.name).toList();
    if (_navigationStack.last.folderId != target.folderId) {
      pathSegments.add(target.name);
    }
    return pathSegments.join(' / ');
  }

  void _onConfirmPick() {
    if (_highlightedFolder != null) {
      if (_highlightedFolder!.folderId == widget.excludeFolderId) return;
      Get.back();
      widget.onPick(
        _highlightedFolder!.folderId,
        _buildPathPath(_highlightedFolder!),
      );
      return;
    }

    final cur = _currentFolder;
    if (cur == null) {
      if (widget.excludeRoot) return;
      Get.back();
      widget.onPick(null, AppText.myDocuments);
    } else {
      if (cur.folderId == widget.excludeFolderId) return;
      Get.back();
      widget.onPick(cur.folderId, _buildPathPath(cur));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isRoot = _navigationStack.isEmpty;
    final titleText = isRoot ? widget.title : _currentFolder!.name;
    final canPickCurrent = _highlightedFolder != null
        ? _highlightedFolder!.folderId != widget.excludeFolderId
        : (isRoot ? false : _currentFolder!.folderId != widget.excludeFolderId);

    return Container(
      decoration: AppStyle.bottomSheetDecoration(context),
      padding: const EdgeInsets.only(top: 12),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: AppStyle.bottomSheetHandleOf(context),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  if (!isRoot)
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: cs.onSurface),
                      onPressed: _popFolder,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  if (!isRoot) const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      titleText,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (isRoot)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _PickerTile(
                  icon: Icons.home_outlined,
                  name: AppText.myDocuments,
                  subtitle: 'Root folder',
                  disabled: widget.excludeRoot,
                  onTap: widget.excludeRoot
                      ? () {}
                      : () {
                          Get.back();
                          widget.onPick(null, AppText.myDocuments);
                        },
                ),
              ),
            const Divider(height: 1),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.45,
                minHeight: 100,
              ),
              child: _buildBody(),
            ),
            if (!isRoot)
              Container(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerLowest,
                  boxShadow: [
                    BoxShadow(
                      color: cs.shadow.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: canPickCurrent ? _onConfirmPick : null,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                  ),
                  child: const Text('Select'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }

    final filtered = _currentFolders
        .where((f) => f.folderId != widget.excludeFolderId)
        .toList();

    if (filtered.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            'This folder is empty',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: filtered.length,
      itemBuilder: (_, i) {
        final folder = filtered[i];
        return _PickerTile(
          icon: Icons.folder_outlined,
          name: folder.name,
          subtitle: '${folder.itemCount} items',
          isSelected: _highlightedFolder?.folderId == folder.folderId,
          onTap: () => _pushFolder(folder),
        );
      },
    );
  }
}

class _PickerTile extends StatelessWidget {
  final IconData icon;
  final String name;
  final String subtitle;
  final VoidCallback onTap;
  final bool disabled;
  final bool isSelected;

  const _PickerTile({
    required this.icon,
    required this.name,
    required this.subtitle,
    required this.onTap,
    this.disabled = false,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      enabled: !disabled,
      selected: isSelected,
      tileColor: isSelected ? cs.primaryContainer.withValues(alpha: 0.3) : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: disabled
              ? cs.surfaceContainer
              : (isSelected
                    ? cs.primary.withValues(alpha: 0.1)
                    : cs.primaryContainer),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: disabled
              ? cs.onSurfaceVariant.withValues(alpha: 0.5)
              : cs.primary,
          size: 20,
        ),
      ),
      title: Text(
        name,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: disabled
              ? cs.onSurfaceVariant
              : (isSelected ? cs.primary : null),
        ),
      ),
      subtitle: Text(
        disabled ? 'Current location' : subtitle,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: disabled ? cs.onSurfaceVariant.withValues(alpha: 0.7) : null,
        ),
      ),
      trailing: disabled
          ? null
          : Icon(
              isSelected ? Icons.check_circle : Icons.chevron_right,
              color: isSelected ? cs.primary : cs.onSurfaceVariant,
              size: 20,
            ),
      onTap: onTap,
    );
  }
}
