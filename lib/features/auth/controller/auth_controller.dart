import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:reddit_clone/core/utils.dart';
import 'package:reddit_clone/features/auth/repository/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/models/user_model.dart';

final userProvider = StateProvider<UserModel?>((ref) => null);
final authControllerProvider = StateNotifierProvider<AuthController, bool>(
  (ref) => AuthController(
    authRepository: ref.watch(authRepositoryProvider),
    ref: ref,
  ),
);
final authStateChangeProvider = StreamProvider((ref) {
  final authProvider = ref.watch(authControllerProvider.notifier);
  return authProvider.authStateChange;
});

final userDataProvider = StreamProvider.family((ref, String uid) {
  final authProvider = ref.watch(authControllerProvider.notifier);
  return authProvider.getUserData(uid);
});

class AuthController extends StateNotifier<bool> {
  final AuthRepository _authRepository;
  final Ref _ref;

  AuthController({required AuthRepository authRepository, required Ref ref})
      : _authRepository = authRepository,
        _ref = ref,
        super(false);

  Stream<User?> get authStateChange => _authRepository.authStateChange;
  Stream<UserModel> getUserData(String uid) {
    return _authRepository.getUserData(uid);
  }

  void signInWithGoogle(BuildContext context) async {
    state = true;
    final user = await _authRepository.signInWithGoogle();
    state = false;
    user.fold(
      (l) => showSnackBar(context, l.message),
      (userModel) {
        _ref.read(userProvider.notifier).update((state) => userModel);
      },
    );
  }

  void logOut() {
    _authRepository.logOut();
  }
}
