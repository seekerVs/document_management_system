import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../../../../../../Template/Utils/Firebase/firebase_method.dart';
import '../../../../../../Template/Utils/Firebase/firebase_utils.dart';
import '../../../../../Utils/Firebase/base_repository.dart';
import '../../../../../Utils/Constant/lists.dart';
import '../Model/folder_model.dart';

class FolderRepository extends BaseRepository {
  static final FolderRepository _instance = FolderRepository._();
  factory FolderRepository() => _instance;
  FolderRepository._();

  Future<List<FolderModel>> getFolders() async {
    final result = await handleRequest(() async {
      final snap = await FirebaseUtils.foldersRef
          .where('ownerUid', isEqualTo: currentUid)
          .where('parentId', isNull: true)
          .orderBy('updatedAt', descending: true)
          .get();
      return snap.docs.map((d) => FolderModel.fromFirestore(d)).toList();
    });
    return result ?? [];
  }

  Future<List<FolderModel>> getSubFolders(String parentId) async {
    final result = await handleRequest(() async {
      final snap = await FirebaseUtils.foldersRef
          .where('ownerUid', isEqualTo: currentUid)
          .where('parentId', isEqualTo: parentId)
          .orderBy('updatedAt', descending: true)
          .get();
      return snap.docs.map((d) => FolderModel.fromFirestore(d)).toList();
    });
    return result ?? [];
  }

  Future<void> createFolder(FolderModel folder) => handleRequest(() async {
    await FirebaseMethod.setDocument(
      ref: FirebaseUtils.folderDoc(folder.folderId),
      data: folder.toFirestore(),
    );
  });

  Future<void> initializeDefaultFolders(String uid) => handleRequest(() async {
        await FirebaseMethod.runBatch((batch) async {
          for (final name in AppLists.defaultFolders) {
            final folderId = const Uuid().v4();
            final folder = FolderModel(
              folderId: folderId,
              ownerUid: uid,
              name: name,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            );
            batch.set(
              FirebaseUtils.folderDoc(folderId),
              folder.toFirestore(),
            );
          }
        });
      });

  Future<void> renameFolder(String folderId, String name) =>
      handleRequest(() async {
        await FirebaseMethod.updateDocument(
          ref: FirebaseUtils.folderDoc(folderId),
          data: {'name': name, 'updatedAt': Timestamp.now()},
        );
      });

  Future<void> deleteFolder(String folderId) => handleRequest(() async {
        // 1. Get subfolders
        final subFoldersSnap = await FirebaseUtils.foldersRef
            .where('parentId', isEqualTo: folderId)
            .get();

        // 2. Delete each subfolder recursively
        for (final subDoc in subFoldersSnap.docs) {
          await deleteFolder(subDoc.id);
        }

        // 3. Delete the folder itself
        await FirebaseMethod.deleteDocument(
          ref: FirebaseUtils.folderDoc(folderId),
        );
      });

  Future<void> updateItemCount(String folderId, int delta) =>
      handleRequest(() async {
        await FirebaseUtils.folderDoc(folderId).update({
          'itemCount': FieldValue.increment(delta),
          'updatedAt': Timestamp.now(),
        });
      });

  Future<int> getFolderCount() async {
    final result = await handleRequest(() async {
      final snap = await FirebaseUtils.foldersRef
          .where('ownerUid', isEqualTo: currentUid)
          .count()
          .get();
      return snap.count ?? 0;
    });
    return result ?? 0;
  }
  Future<String> getOrCreateFolderByName(String name) async {
    final result = await handleRequest(() async {
      // 1. Try to find existing root folder
      final snap = await FirebaseUtils.foldersRef
          .where('ownerUid', isEqualTo: currentUid)
          .where('parentId', isNull: true)
          .where('name', isEqualTo: name)
          .limit(1)
          .get();

      if (snap.docs.isNotEmpty) {
        return snap.docs.first.id;
      }

      // 2. Not found, create it
      final folderId = const Uuid().v4();
      final folder = FolderModel(
        folderId: folderId,
        ownerUid: currentUid,
        name: name,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await FirebaseUtils.folderDoc(folderId).set(folder.toFirestore());
      return folderId;
    });
    return result ?? '';
  }
}
