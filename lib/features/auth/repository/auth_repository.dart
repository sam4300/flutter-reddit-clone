import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:reddit_clone/core/constants/constant.dart';
import 'package:reddit_clone/core/constants/firebase_constants.dart';
import 'package:reddit_clone/core/provders/firebase_provider.dart';
import 'package:reddit_clone/core/type_def.dart';
import 'package:reddit_clone/models/failure_model.dart';
import 'package:reddit_clone/models/user_model.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(
    firestore: ref.read(firestoreProvider),
    googleSignin: ref.read(googleSignInProvider),
    firebaseAuth: ref.read(authProvider),
  ),
);

class AuthRepository {
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignin;
  final FirebaseAuth _firebaseAuth;

  AuthRepository(
      {required FirebaseFirestore firestore,
      required GoogleSignIn googleSignin,
      required FirebaseAuth firebaseAuth})
      : _firestore = firestore,
        _googleSignin = googleSignin,
        _firebaseAuth = firebaseAuth;

  CollectionReference get _users =>
      _firestore.collection(FirebaseConstants.usersCollection);

  Stream<User?> get authStateChange => _firebaseAuth.authStateChanges();

  FutureEither<UserModel> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignin.signIn();
      final googleAuth = await googleUser?.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);

      final user = userCredential.user!;
      UserModel userModel;

      if (userCredential.additionalUserInfo!.isNewUser) {
        userModel = UserModel(
          name: user.displayName ?? 'No Name',
          profilePic: user.photoURL ?? Constant.avatarDefault,
          banner: Constant.bannerDefault,
          uid: user.uid,
          karma: 0,
          awards: [],
          isAuthenticated: user.emailVerified,
        );
        await _users.doc(user.uid).set(userModel.toMap());
      } else {
        userModel = await getUserData(user.uid).first;
      }
      return right(userModel);
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(
        Failure(
          e.toString(),
        ),
      );
    }
  }

  Stream<UserModel> getUserData(String uid) {
    return _users.doc(uid).snapshots().map(
          (event) => UserModel.fromMap(event.data() as Map<String, dynamic>),
        );
  }

  void logOut() async {
    await _googleSignin.signOut();
    await _firebaseAuth.signOut();
  }
}
