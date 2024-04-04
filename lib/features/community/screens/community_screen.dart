import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:reddit_clone/core/common/error_text.dart';
import 'package:reddit_clone/core/common/loader.dart';
import 'package:reddit_clone/features/auth/controller/auth_controller.dart';
import 'package:reddit_clone/features/community/controller/community_controller.dart';
import 'package:reddit_clone/models/community_model.dart';
import 'package:reddit_clone/theme/palette.dart';
import 'package:routemaster/routemaster.dart';

class CommunityScreen extends ConsumerWidget {
  final String communityName;
  const CommunityScreen({super.key, required this.communityName});

  void joinOrLeaveCommunity(
      WidgetRef ref, BuildContext context, Community community) {
    ref
        .read(communityControllerProvider.notifier)
        .joinOrLeaveCommunity(context, community);
  }

  void navigateToModToolScreen(BuildContext context) {
    Routemaster.of(context).push('/r/$communityName/mod-tools');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.read(userProvider)!;
    return Scaffold(
      body: ref.watch(communityByNameProvider(communityName)).when(
          data: (community) => NestedScrollView(
                headerSliverBuilder: ((context, innerBoxIsScrolled) {
                  return [
                    SliverAppBar(
                      expandedHeight: 150,
                      flexibleSpace: Stack(
                        children: [
                          Positioned.fill(
                            child: Image.network(
                              community.banner,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          Align(
                            alignment: Alignment.topLeft,
                            child: CircleAvatar(
                              radius: 35,
                              backgroundImage: NetworkImage(community.avatar),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'r/${community.name}',
                                style: const TextStyle(
                                    fontSize: 19, fontWeight: FontWeight.bold),
                              ),
                              community.mods.contains(user.uid)
                                  ? OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(
                                            color: Pallete.greyColor),
                                        padding: const EdgeInsets.all(10),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                      ),
                                      onPressed: () =>
                                          navigateToModToolScreen(context),
                                      child: const Text(
                                        'Mod Tools',
                                        style: TextStyle(color: Colors.blue),
                                      ),
                                    )
                                  : OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(
                                            color: Pallete.greyColor),
                                        padding: const EdgeInsets.all(10),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                      ),
                                      onPressed: () => joinOrLeaveCommunity(
                                          ref, context, community),
                                      child: Text(
                                        community.members.contains(user.uid)
                                            ? 'Joined'
                                            : 'Join',
                                        style:
                                            const TextStyle(color: Colors.blue),
                                      ),
                                    )
                            ],
                          ),
                          Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: community.members.length <= 1
                                  ? Text('${community.members.length} member')
                                  : Text(
                                      '${community.members.length} members')),
                        ]),
                      ),
                    ),
                  ];
                }),
                body: const Text('Posts'),
              ),
          error: (error, stackTrace) => ErrorText(message: error.toString()),
          loading: () => const Loader()),
    );
  }
}
