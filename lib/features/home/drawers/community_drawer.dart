import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/common/error_text.dart';
import 'package:reddit_clone/core/common/loader.dart';
import 'package:reddit_clone/core/common/sign_in_button.dart';
import 'package:reddit_clone/features/auth/controller/auth_controller.dart';
import 'package:reddit_clone/features/community/controller/community_controller.dart';
import 'package:routemaster/routemaster.dart';

class CommunityDrawer extends ConsumerWidget {
  const CommunityDrawer({super.key});

  void navigateToCreateCommunity(BuildContext context) {
    Routemaster.of(context).push('/create-community');
  }

  void navigateToCommunityScreen(BuildContext context, String communityName) {
    Routemaster.of(context).push('/r/$communityName');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider)!;
    final isGuest = !user.isAuthenticated;
    return SafeArea(
      child: Drawer(
        width: 250,
        child: Column(
          children: [
            isGuest
                ? const SigninButton()
                : ListTile(
                    onTap: () => navigateToCreateCommunity(context),
                    leading: const Icon(
                      Icons.add,
                    ),
                    title: const Text(
                      'Create a Community',
                    ),
                  ),
            if (!isGuest)
              ref.watch(getUserCommunityProvider).when(
                    data: (communities) => Expanded(
                      child: ListView.builder(
                          itemCount: communities.length,
                          itemBuilder: (context, index) {
                            final community = communities[index];

                            return ListTile(
                              onTap: () {
                                navigateToCommunityScreen(
                                    context, community.name);
                              },
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(community.avatar),
                              ),
                              title: Text('r/${community.name}'),
                            );
                          }),
                    ),
                    error: (error, stacktrace) =>
                        ErrorText(message: error.toString()),
                    loading: () => const Loader(),
                  ),
          ],
        ),
      ),
    );
  }
}
