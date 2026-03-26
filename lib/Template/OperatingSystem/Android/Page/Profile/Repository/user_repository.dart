import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../../Template/Utils/Firebase/firebase_method.dart';
import '../../../../../../Template/Utils/Firebase/firebase_utils.dart';
import '../../../../../Utils/Firebase/base_repository.dart';
import '../Model/user_model.dart';

class UserRepository extends BaseRepository {
  static final UserRepository _instance = UserRepository._();
  factory UserRepository() => _instance;
  UserRepository._();

  Future<UserModel?> getCurrentUser() => handleRequest(() async {
    final uid = currentUid;
    final doc = await FirebaseMethod.getDocument(
      ref: FirebaseUtils.userDoc(uid),
    );
    return doc != null ? UserModel.fromFirestore(doc) : null;
  });

  Stream<UserModel?> streamCurrentUser() {
    final uid = currentUidOrNull;
    if (uid == null) return Stream.value(null);
    return FirebaseMethod.streamDocument(
      ref: FirebaseUtils.userDoc(uid),
    ).map((doc) => UserModel.fromFirestore(doc));
  }

  Future<void> createProfile(UserModel user) => handleRequest(() async {
    await FirebaseMethod.setDocument(
      ref: FirebaseUtils.userDoc(user.uid),
      data: user.toFirestore(),
    );
  });

  Future<void> updateProfile(String uid, {String? name, String? photoUrl}) =>
      handleRequest(() async {
        await FirebaseMethod.updateDocument(
          ref: FirebaseUtils.userDoc(uid),
          data: {
            'name': ?name,
            'photoUrl': ?photoUrl,
            'updatedAt': Timestamp.now(),
          },
        );
      });

  Future<UserModel?> getByEmail(String email) => handleRequest(() async {
    final snapshot = await FirebaseUtils.usersRef
        .where('email', isEqualTo: email)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return null;
    return UserModel.fromFirestore(snapshot.docs.first);
  });
}
