import 'package:flutter/material.dart';
import 'package:reddit_clone/core/constants/constant.dart';
import 'package:reddit_clone/theme/palette.dart';

class SigninButton extends StatelessWidget {
  const SigninButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: Image.asset(
        Constant.googleLogoPath,
        height: 40,
      ),
      onPressed: () {},
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
