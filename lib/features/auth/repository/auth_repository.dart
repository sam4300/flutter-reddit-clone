import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
}
