import 'package:firebase_auth/firebase_auth.dart';
import '../../../../../Utils/Exceptions/exceptions.dart';
import '../../../../../Utils/Firebase/firebase_method.dart';
import '../../../../../Utils/Firebase/firebase_utils.dart';
import '../../../../../Utils/Helpers/base_repository.dart';
import '../../Welcome/Model/user_model.dart';

class AuthRepository extends BaseRepository {
  Future<UserModel?> signInWithEmail({
    required String email,
    required String password,
  }) => handleRequest(() async {
    final credential = await FirebaseUtils.auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final uid = credential.user!.uid;
    final doc = await FirebaseMethod.getDocument(
      ref: FirebaseUtils.userDoc(uid),
    );
    if (doc == null) throw const UserNotFoundException();
    return UserModel.fromFirestore(doc);
  });

  Future<UserModel?> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) => handleRequest(() async {
    final credential = await FirebaseUtils.auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final user = credential.user!;
    final now = DateTime.now();

    final newUser = UserModel(
      uid: user.uid,
      name: name.trim(),
      email: email.trim(),
      role: UserRole.owner,
      createdAt: now,
      updatedAt: now,
    );

    await FirebaseMethod.setDocument(
      ref: FirebaseUtils.userDoc(user.uid),
      data: newUser.toFirestore(),
    );

    return newUser;
  });

  Future<void> signOut() =>
      handleRequest(() async => FirebaseUtils.auth.signOut());

  Future<bool> sendPasswordReset({required String email}) =>
      handleRequest(() async {
        await FirebaseUtils.auth.sendPasswordResetEmail(email: email.trim());
        return true;
      }).then((v) => v ?? false);

  Stream<User?> get authStateChanges => FirebaseUtils.auth.authStateChanges();
}
