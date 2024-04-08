import 'package:any_link_preview/any_link_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/common/error_text.dart';
import 'package:reddit_clone/core/common/loader.dart';
import 'package:reddit_clone/core/constants/constant.dart';
import 'package:reddit_clone/features/auth/controller/auth_controller.dart';
import 'package:reddit_clone/features/community/controller/community_controller.dart';
import 'package:reddit_clone/features/post/controller/post_controller.dart';
import 'package:reddit_clone/models/post_model.dart';
import 'package:reddit_clone/theme/palette.dart';
import 'package:routemaster/routemaster.dart';

class PostCard extends ConsumerWidget {
  final Post post;
  const PostCard({super.key, required this.post});

  void deletePost(WidgetRef ref, BuildContext context) {
    ref.read(postControllerProvider.notifier).deletePost(post, context);
    Routemaster.of(context).pop();
  }

  void upVote(WidgetRef ref) {
    ref.read(postControllerProvider.notifier).upVote(post);
  }

  void downVote(WidgetRef ref) {
    ref.read(postControllerProvider.notifier).downVote(post);
  }

  void navigateToCommunityScreen(BuildContext context, String communityName) {
    Routemaster.of(context).push('/r/$communityName');
  }

  void navigateToUserScreen(BuildContext context, String uid) {
    Routemaster.of(context).push('/u/$uid');
  }

  void awardPost(WidgetRef ref, String award, BuildContext context) {
    ref
        .read(postControllerProvider.notifier)
        .awardPost(post: post, award: award, context: context);
  }

  void navigateToCommentScreen(BuildContext context) {
    Routemaster.of(context).push('/comment-screen/${post.id}');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    final isText = post.type == "Text";
    final isImage = post.type == 'Image';
    final isLink = post.type == "Link";
    final currentTheme = ref.watch(themeNotifierProvider);
    final user = ref.watch(userProvider)!;
    final isGuest = !user.isAuthenticated;
    return Column(
      children: [
        Container(
          decoration:
              BoxDecoration(color: currentTheme.drawerTheme.backgroundColor),
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                              vertical: 4, horizontal: 16)
                          .copyWith(right: 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () => navigateToCommunityScreen(
                                        context, post.communityName),
                                    child: CircleAvatar(
                                      backgroundImage: NetworkImage(
                                          post.communityProfilePic),
                                      radius: 16,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'r/${post.communityName}',
                                          style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        GestureDetector(
                                          onTap: () => navigateToUserScreen(
                                              context, post.uid),
                                          child: Text(
                                            'u/${post.username}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              if (post.uid == user.uid)
                                IconButton(
                                  onPressed: () {
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: const Text(
                                                'Are you sure you want to delete this post'),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    deletePost(ref, context),
                                                child: const Text('Yes'),
                                              ),
                                              TextButton(
                                                onPressed: () =>
                                                    Routemaster.of(context)
                                                        .pop(),
                                                child: const Text('No'),
                                              )
                                            ],
                                          );
                                        });
                                  },
                                  icon: const Icon(Icons.delete),
                                  color: Colors.red,
                                )
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          SizedBox(
                            height: 20,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: post.awards.length,
                              itemBuilder: (BuildContext context, int index) {
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 2),
                                  child: Image.asset(
                                      Constants.awards[post.awards[index]]!),
                                );
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Text(
                              post.title,
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (isImage)
                            SizedBox(
                              height: size.height * 0.20,
                              width: double.infinity,
                              child: Image.network(
                                post.link!,
                                fit: BoxFit.cover,
                              ),
                            ),
                          if (isLink)
                            SizedBox(
                              height: size.height * 0.20,
                              width: double.infinity,
                              child: AnyLinkPreview(
                                displayDirection:
                                    UIDirection.uiDirectionHorizontal,
                                link: post.link!,
                              ),
                            ),
                          if (isText)
                            Container(
                              alignment: Alignment.bottomLeft,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10.0),
                              child: Text(
                                post.description!,
                              ),
                            ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  IconButton(
                                    onPressed:
                                        isGuest ? () {} : () => upVote(ref),
                                    iconSize: 25,
                                    color: post.upVotes.contains(user.uid)
                                        ? Colors.red
                                        : null,
                                    icon: const Icon(Constants.up),
                                  ),
                                  Text(
                                    '${post.upVotes.length - post.downVotes.length == 0 ? 'vote' : post.upVotes.length - post.downVotes.length}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed:
                                        isGuest ? () {} : () => downVote(ref),
                                    iconSize: 25,
                                    color: post.downVotes.contains(user.uid)
                                        ? Pallete.blueColor
                                        : null,
                                    icon: const Icon(Constants.down),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () =>
                                        navigateToCommentScreen(context),
                                    iconSize: 25,
                                    icon: const Icon(Icons.comment),
                                  ),
                                  Text(
                                    post.commentCount == 0
                                        ? 'comment'
                                        : post.commentCount.toString(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                              ref
                                  .watch(communityByNameProvider(
                                      post.communityName))
                                  .when(
                                    data: (data) {
                                      if (data.mods.contains(user.uid)) {
                                        return IconButton(
                                          onPressed: () =>
                                              deletePost(ref, context),
                                          icon: const Icon(
                                              Icons.admin_panel_settings),
                                        );
                                      }
                                      return const SizedBox();
                                    },
                                    error: (error, stackTrace) =>
                                        ErrorText(message: error.toString()),
                                    loading: () => const Loader(),
                                  ),
                              IconButton(
                                onPressed: isGuest
                                    ? () {}
                                    : () {
                                        showDialog(
                                            context: context,
                                            builder: (context) => Dialog(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            20),
                                                    child: GridView.builder(
                                                        shrinkWrap: true,
                                                        gridDelegate:
                                                            const SliverGridDelegateWithFixedCrossAxisCount(
                                                                crossAxisCount:
                                                                    4),
                                                        itemCount:
                                                            user.awards.length,
                                                        itemBuilder:
                                                            (context, index) {
                                                          final award = user
                                                              .awards[index];

                                                          return GestureDetector(
                                                            onTap: () =>
                                                                awardPost(
                                                                    ref,
                                                                    award,
                                                                    context),
                                                            child: Image.asset(
                                                                Constants
                                                                        .awards[
                                                                    award]!),
                                                          );
                                                        }),
                                                  ),
                                                ));
                                      },
                                icon: const Icon(Icons.card_giftcard),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15)
      ],
    );
  }
}
