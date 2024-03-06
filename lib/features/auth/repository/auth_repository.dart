import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:reddit_clone/core/provders/firebase_provider.dart';

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

  void signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignin.signIn();
      final googleAuth = await googleUser?.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      print(userCredential.user?.email);
    } catch (e) {}
  }
}
