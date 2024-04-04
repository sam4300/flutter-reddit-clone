import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/common/error_text.dart';
import 'package:reddit_clone/core/common/loader.dart';
import 'package:reddit_clone/core/common/post_card.dart';
import 'package:reddit_clone/features/community/controller/community_controller.dart';
import 'package:reddit_clone/features/post/controller/post_controller.dart';

class PostScreen extends ConsumerWidget {
  const PostScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
        body: ref.watch(getUserCommunityProvider).when(
            data: (communities) =>
                ref.watch(allPostsProvider(communities)).when(
                      data: (posts) {
                        return ListView.builder(
                          itemCount: posts.length,
                          itemBuilder: (BuildContext context, int index) {
                            final post = posts[index];
                            return PostCard(post: post);
                          },
                        );
                      },
                      error: (error, stackTrace) =>
                          ErrorText(message: error.toString()),
                      loading: () => const Loader(),
                    ),
            error: (error, stackTrace) => ErrorText(message: error.toString()),
            loading: () => const Loader()));
  }
}
