import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/common/error_text.dart';
import 'package:reddit_clone/core/common/loader.dart';
import 'package:reddit_clone/core/common/post_card.dart';
import 'package:reddit_clone/features/auth/controller/auth_controller.dart';
import 'package:reddit_clone/features/post/controller/post_controller.dart';

class CommentScreen extends ConsumerStatefulWidget {
  final String postId;
  const CommentScreen({super.key, required this.postId});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CommentScreenState();
}

class _CommentScreenState extends ConsumerState<CommentScreen> {
  final _commentController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _commentController.dispose();
  }

  void addComment() {
    ref
        .read(postControllerProvider.notifier)
        .addComment(context, _commentController.text.trim(), widget.postId);
    setState(() {
      _commentController.text = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider)!;
    final isGuest = user.isAuthenticated;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Comments'),
        ),
        body: ref.watch(getPostByIdProvider(widget.postId)).when(
              data: (post) {
                return Column(
                  children: [
                    PostCard(post: post),
                    if (isGuest)
                      TextField(
                        onSubmitted: (value) => addComment(),
                        controller: _commentController,
                        decoration: const InputDecoration(
                          hintText: 'Enter your comment',
                          filled: true,
                          fillColor: Color.fromARGB(255, 59, 58, 58),
                          border: InputBorder.none,
                        ),
                      ),
                    ref.watch(getCommentsProvider(post.id)).when(
                          data: (comments) => Expanded(
                            child: ListView.builder(
                              itemCount: comments.length,
                              itemBuilder: (BuildContext context, int index) {
                                final comment = comments[index];
                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundImage:
                                        NetworkImage(comment.profilePic),
                                  ),
                                  title: Text(
                                    comment.userName,
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(comment.text),
                                );
                              },
                            ),
                          ),
                          error: (error, stackTrace) =>
                              ErrorText(message: error.toString()),
                          loading: () => const Loader(),
                        ),
                  ],
                );
              },
              error: (error, stackTrace) =>
                  ErrorText(message: error.toString()),
              loading: () => const Loader(),
            ),
      ),
    );
  }
}
