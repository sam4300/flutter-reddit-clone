import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/constants/constant.dart';
import 'package:reddit_clone/features/auth/controller/auth_controller.dart';
import 'package:reddit_clone/theme/palette.dart';

class SigninButton extends ConsumerWidget {
  const SigninButton({super.key});

  
  void buttonPressed(WidgetRef ref) {
    ref.read(authControllerProvider).signInWithGoogle();
  }

  @override
  Widget build(BuildContext context,WidgetRef ref) {
    return ElevatedButton.icon(
      icon: Image.asset(
        Constant.googleLogoPath,
        height: 40,
      ),
      onPressed: () {
        buttonPressed(ref);
      },
      label: const Text(
        'Sign in with Google',
        style: TextStyle(color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
          backgroundColor: Pallete.greyColor,
          minimumSize: const Size(500, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          )),
    );
  }
}
