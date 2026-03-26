import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../../../Template/Utils/Firebase/firebase_method.dart';
import '../../../../../../Template/Utils/Firebase/firebase_utils.dart';
import '../../../../../Utils/Exceptions/exceptions.dart';
import '../../../../../Utils/Firebase/base_repository.dart';
import '../../Profile/Model/user_model.dart';
import '../../Profile/Repository/user_repository.dart';

class AuthRepository extends BaseRepository {
  // Sign in with email + password
  Future<UserModel?> signInWithEmail({
    required String email,
    required String password,
  }) => handleRequest(() async {
    final credential = await FirebaseUtils.auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final doc = await FirebaseMethod.getDocument(
      ref: FirebaseUtils.userDoc(credential.user!.uid),
    );
    if (doc == null) throw const UserNotFoundException();
    return UserModel.fromFirestore(doc);
  });

  // Sign in with Google — v7 API
  Future<UserModel?> signInWithGoogle() => handleRequest(() async {
    // v7: authenticate() throws GoogleSignInException on cancel/error
    late final GoogleSignInAccount googleUser;
    try {
      googleUser = await GoogleSignIn.instance.authenticate();
    } on GoogleSignInException catch (e) {
      // User cancelled — return null silently
      if (e.code == GoogleSignInExceptionCode.canceled) return null;
      throw AppException('Google sign-in failed: ${e.description}');
    }

    // v7: authentication is synchronous
    final googleAuth = googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );

    final userCredential = await FirebaseUtils.auth.signInWithCredential(
      credential,
    );
    final user = userCredential.user!;

    final doc = await FirebaseMethod.getDocument(
      ref: FirebaseUtils.userDoc(user.uid),
    );

    if (doc != null) return UserModel.fromFirestore(doc);

    // First Google sign-in — create profile
    final now = DateTime.now();
    final newUser = UserModel(
      uid: user.uid,
      name: user.displayName ?? googleUser.displayName ?? '',
      email: user.email ?? googleUser.email,
      photoUrl: user.photoURL,
      createdAt: now,
      updatedAt: now,
    );
    await UserRepository().createProfile(newUser);
    return newUser;
  });

  // Sign up with email + password
  Future<UserModel?> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) => handleRequest(() async {
    final credential = await FirebaseUtils.auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final now = DateTime.now();
    final newUser = UserModel(
      uid: credential.user!.uid,
      name: name.trim(),
      email: email.trim(),
      createdAt: now,
      updatedAt: now,
    );
    await UserRepository().createProfile(newUser);
    return newUser;
  });

  // Sign out
  Future<void> signOut() => handleRequest(() async {
    await GoogleSignIn.instance.signOut();
    await FirebaseUtils.auth.signOut();
  });

  Stream<User?> get authStateChanges => FirebaseUtils.auth.authStateChanges();
}
