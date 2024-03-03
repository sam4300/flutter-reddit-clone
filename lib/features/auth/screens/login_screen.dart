import 'package:flutter/material.dart';
import 'package:reddit_clone/core/common/sign_in_button.dart';
import 'package:reddit_clone/core/constants/constant.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          Constant.logoPath,
          height: 40,
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 5.0),
            child: TextButton(
              onPressed: () {},
              child: const Text('Skip'),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
            height: 15,
          ),
          const Text(
            'Dive into anything',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 20,
          ),
          Image.asset(
            Constant.loginEmotePath,
            height: 400,
            width: double.infinity,
          ),
          const SizedBox(
            height: 20,
          ),
          const SigninButton()
        ],
      ),
    );
  }
}
