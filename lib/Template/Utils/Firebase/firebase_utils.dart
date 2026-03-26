import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseUtils {
  FirebaseUtils._();

  static FirebaseAuth get auth => FirebaseAuth.instance;
  static FirebaseFirestore get firestore => FirebaseFirestore.instance;

  static User? get currentUser => auth.currentUser;
  static String? get currentUid => auth.currentUser?.uid;
  static String? get currentEmail => auth.currentUser?.email;
  static bool get isLoggedIn => auth.currentUser != null;

  static CollectionReference get usersRef => firestore.collection('users');

  static CollectionReference get foldersRef => firestore.collection('folders');

  static CollectionReference get documentsRef =>
      firestore.collection('documents');

  static CollectionReference get signatureRequestsRef =>
      firestore.collection('signature_requests');

  static CollectionReference get activitiesRef =>
      firestore.collection('activities');

  static CollectionReference get notificationsRef =>
      firestore.collection('notifications');

  static CollectionReference get signingTokensRef =>
      firestore.collection('signing_tokens');

  static DocumentReference userDoc(String uid) => usersRef.doc(uid);
  static DocumentReference folderDoc(String id) => foldersRef.doc(id);
  static DocumentReference documentDoc(String id) => documentsRef.doc(id);
  static DocumentReference signatureRequestDoc(String id) =>
      signatureRequestsRef.doc(id);
  static DocumentReference notificationDoc(String id) =>
      notificationsRef.doc(id);
  static DocumentReference signingTokenDoc(String token) =>
      signingTokensRef.doc(token);
}
