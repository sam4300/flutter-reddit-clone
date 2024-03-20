import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/features/auth/controller/auth_controller.dart';
import 'package:reddit_clone/theme/palette.dart';
import 'package:routemaster/routemaster.dart';

class ProfileDrawer extends ConsumerWidget {
  const ProfileDrawer({super.key});

  void logOut(WidgetRef ref) {
    ref.read(authControllerProvider.notifier).logOut();
  }

  void navigateToUserProfileScreen(BuildContext context, String uid) {
    Routemaster.of(context).push('/u/$uid');
  }

  void toggleTheme(WidgetRef ref) {
    ref.read(themeNotifierProvider.notifier).toggleTheme();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.read(userProvider)!;
    return SafeArea(
      child: Drawer(
        child: Column(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: NetworkImage(user.profilePic),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              'u/${user.name}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(
              height: 10,
            ),
            const Divider(
              color: Pallete.greyColor,
            ),
            ListTile(
              onTap: () => navigateToUserProfileScreen(context, user.uid),
              leading: const Icon(Icons.person),
              title: const Text('My Profile'),
            ),
            ListTile(
              onTap: () => logOut(ref),
              leading: const Icon(
                Icons.logout,
                color: Colors.red,
              ),
              title: const Text('Log Out'),
            ),
            const SizedBox(
              height: 10,
            ),
            Switch.adaptive(
              value: ref.watch(themeNotifierProvider.notifier).mode ==
                  ThemeMode.dark,
              onChanged: (val) => toggleTheme(ref),
            )
          ],
        ),
      ),
    );
  }
}
