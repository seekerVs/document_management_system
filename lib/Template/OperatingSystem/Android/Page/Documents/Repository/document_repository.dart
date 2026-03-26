import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../../Template/Utils/Firebase/firebase_method.dart';
import '../../../../../../Template/Utils/Firebase/firebase_utils.dart';
import '../../../../../Utils/Firebase/base_repository.dart';
import '../Model/document_model.dart';

class DocumentRepository extends BaseRepository {
  static final DocumentRepository _instance = DocumentRepository._();
  factory DocumentRepository() => _instance;
  DocumentRepository._();

  Future<List<DocumentModel>> getRootDocuments() async {
    final result = await handleRequest(() async {
      final snap = await FirebaseUtils.documentsRef
          .where('ownerUid', isEqualTo: currentUid)
          .where('folderId', isNull: true)
          .orderBy('updatedAt', descending: true)
          .get();
      return snap.docs.map((d) => DocumentModel.fromFirestore(d)).toList();
    });
    return result ?? [];
  }

  Future<List<DocumentModel>> getFolderDocuments(String folderId) async {
    final result = await handleRequest(() async {
      final snap = await FirebaseUtils.documentsRef
          .where('ownerUid', isEqualTo: currentUid)
          .where('folderId', isEqualTo: folderId)
          .orderBy('updatedAt', descending: true)
          .get();
      return snap.docs.map((d) => DocumentModel.fromFirestore(d)).toList();
    });
    return result ?? [];
  }

  Future<List<DocumentModel>> searchDocuments(String query) async {
    final result = await handleRequest(() async {
      final end = '$query\uf8ff';
      final snap = await FirebaseUtils.documentsRef
          .where('ownerUid', isEqualTo: currentUid)
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: end)
          .limit(20)
          .get();
      return snap.docs.map((d) => DocumentModel.fromFirestore(d)).toList();
    });
    return result ?? [];
  }

  Future<void> addDocument(DocumentModel doc) => handleRequest(() async {
    await FirebaseMethod.setDocument(
      ref: FirebaseUtils.documentDoc(doc.documentId),
      data: doc.toFirestore(),
    );
  });

  Future<void> renameDocument(String docId, String name) =>
      handleRequest(() async {
        await FirebaseMethod.updateDocument(
          ref: FirebaseUtils.documentDoc(docId),
          data: {'name': name, 'updatedAt': Timestamp.now()},
        );
      });

  Future<void> moveDocument(String docId, String? folderId) =>
      handleRequest(() async {
        await FirebaseMethod.updateDocument(
          ref: FirebaseUtils.documentDoc(docId),
          data: {'folderId': folderId, 'updatedAt': Timestamp.now()},
        );
      });

  Future<void> deleteDocument(String docId) => handleRequest(() async {
    await FirebaseMethod.deleteDocument(ref: FirebaseUtils.documentDoc(docId));
  });

  Future<int> getDocumentCount() async {
    final result = await handleRequest(() async {
      final snap = await FirebaseUtils.documentsRef
          .where('ownerUid', isEqualTo: currentUid)
          .count()
          .get();
      return snap.count ?? 0;
    });
    return result ?? 0;
  }
}
