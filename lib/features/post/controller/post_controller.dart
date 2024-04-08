import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/enums/karma_enum.dart';
import 'package:reddit_clone/core/provders/storage_repository_provider.dart';
import 'package:reddit_clone/core/utils.dart';
import 'package:reddit_clone/features/auth/controller/auth_controller.dart';
import 'package:reddit_clone/features/post/repository/post_repository.dart';
import 'package:reddit_clone/features/user_profile/controller/user_profile_controller.dart';
import 'package:reddit_clone/models/comments_model.dart';
import 'package:reddit_clone/models/community_model.dart';
import 'package:reddit_clone/models/post_model.dart';
import 'package:routemaster/routemaster.dart';
import 'package:uuid/uuid.dart';

final postControllerProvider =
    StateNotifierProvider<PostController, bool>((ref) {
  return PostController(
    postRepository: ref.read(postRepositoryProvider),
    ref: ref,
    storageRepository: ref.read(storageRepositoryProvider),
  );
});

final allPostsProvider =
    StreamProvider.family((ref, List<Community> communities) {
  final controllerRef = ref.read(postControllerProvider.notifier);
  return controllerRef.posts(communities);
});

final getPostByIdProvider = StreamProvider.family((ref, String postId) {
  return ref.read(postControllerProvider.notifier).getPostById(postId);
});

final getUserPostsProvider = StreamProvider.family((ref, String uid) {
  return ref.read(postControllerProvider.notifier).getUserPosts(uid);
});
final getCommunityPostProvider =
    StreamProvider.family((ref, String communityName) {
  return ref
      .read(postControllerProvider.notifier)
      .getCommunityPost(communityName);
});

final getCommentsProvider = StreamProvider.family((ref, String postId) {
  return ref.read(postControllerProvider.notifier).getComments(postId);
});

final getGuestPostsProvider = StreamProvider((ref) {
  return ref.read(postControllerProvider.notifier).getGuestPosts();
});

class PostController extends StateNotifier<bool> {
  final PostRepository _postRepository;
  final Ref _ref;
  final StorageRepository _storageRepository;

  PostController(
      {required PostRepository postRepository,
      required Ref ref,
      required StorageRepository storageRepository})
      : _postRepository = postRepository,
        _ref = ref,
        _storageRepository = storageRepository,
        super(false);

  void shareTextPost({
    required BuildContext context,
    required String title,
    required String description,
    required Community selectedCommunity,
  }) async {
    state = true;
    final postId = const Uuid().v1();
    final user = _ref.watch(userProvider)!;

    Post post = Post(
      id: postId,
      title: title,
      communityName: selectedCommunity.name,
      communityProfilePic: selectedCommunity.avatar,
      upVotes: [],
      downVotes: [],
      commentCount: 0,
      username: user.name,
      uid: user.uid,
      type: 'Text',
      createdAt: DateTime.now(),
      awards: [],
      description: description,
    );

    final res = await _postRepository.addPosts(post);
    _ref
        .read(userProfileControllerProvider.notifier)
        .updateKarma(Karma.textPost);

    state = false;

    res.fold((l) => showSnackBar(context, l.message), (r) {
      showSnackBar(context, 'Posted Successfully');
      Routemaster.of(context).pop();
    });
  }

  void shareImagePost({
    required BuildContext context,
    required String title,
    required File file,
    required Community selectedCommunity,
  }) async {
    state = true;
    final postId = const Uuid().v1();
    final user = _ref.watch(userProvider)!;
    final storeFile = await _storageRepository.storeFile(
        path: 'posts/${selectedCommunity.name}', id: postId, file: file);

    storeFile.fold((l) => showSnackBar(context, l.message), (r) async {
      Post post = Post(
          id: postId,
          title: title,
          communityName: selectedCommunity.name,
          communityProfilePic: selectedCommunity.avatar,
          upVotes: [],
          downVotes: [],
          commentCount: 0,
          username: user.name,
          uid: user.uid,
          type: 'Image',
          createdAt: DateTime.now(),
          awards: [],
          link: r);

      final res = await _postRepository.addPosts(post);
      _ref
          .read(userProfileControllerProvider.notifier)
          .updateKarma(Karma.imagePost);

      state = false;

      res.fold(
        (l) => showSnackBar(context, l.message),
        (r) {
          showSnackBar(context, 'Posted Successfully');
          Routemaster.of(context).pop();
        },
      );
    });
  }

  Stream<List<Post>> posts(List<Community> communities) {
    return _postRepository.fetchUserPosts(communities);
  }

  void shareLinkPost({
    required BuildContext context,
    required String title,
    required String link,
    required Community selectedCommunity,
  }) async {
    state = true;
    final postId = const Uuid().v1();
    final user = _ref.watch(userProvider)!;

    Post post = Post(
      id: postId,
      title: title,
      communityName: selectedCommunity.name,
      communityProfilePic: selectedCommunity.avatar,
      upVotes: [],
      downVotes: [],
      commentCount: 0,
      username: user.name,
      uid: user.uid,
      type: 'Link',
      createdAt: DateTime.now(),
      awards: [],
      link: link,
    );

    final res = await _postRepository.addPosts(post);
    _ref
        .read(userProfileControllerProvider.notifier)
        .updateKarma(Karma.linkPost);

    state = false;

    res.fold((l) => showSnackBar(context, l.message), (r) {
      showSnackBar(context, 'Posted Successfully');
      Routemaster.of(context).pop();
    });
  }

  void deletePost(Post post, BuildContext context) async {
    final res = await _postRepository.deletePost(post);
    _ref
        .read(userProfileControllerProvider.notifier)
        .updateKarma(Karma.deletePost);

    res.fold((l) => showSnackBar(context, l.message),
        (r) => showSnackBar(context, 'Successfully Deleted'));
  }

  void upVote(Post post) {
    final userId = _ref.watch(userProvider)!.uid;
    _postRepository.upVote(post, userId);
  }

  void downVote(Post post) {
    final userId = _ref.watch(userProvider)!.uid;
    _postRepository.downVote(post, userId);
  }

  Stream<List<Post>> getUserPosts(String uid) {
    return _postRepository.getUserPosts(uid);
  }

  Stream<List<Post>> getCommunityPost(String communityName) {
    return _postRepository.getCommunityPost(communityName);
  }

  Stream<Post> getPostById(String postId) {
    return _postRepository.getPostById(postId);
  }

  void addComment(BuildContext context, String text, String postId) async {
    final user = _ref.watch(userProvider)!;
    final commentId = const Uuid().v1();
    Comment comment = Comment(
        id: commentId,
        createdAt: DateTime.now(),
        userName: user.name,
        profilePic: user.profilePic,
        postId: postId,
        text: text);
    final res = await _postRepository.addComment(comment);
    _ref
        .read(userProfileControllerProvider.notifier)
        .updateKarma(Karma.comment);

    res.fold((l) => showSnackBar(context, l.message), (r) => null);
  }

  Stream<List<Comment>> getComments(String postId) {
    return _postRepository.getComments(postId);
  }

  void awardPost(
      {required Post post,
      required String award,
      required BuildContext context}) async {
    final user = _ref.watch(userProvider)!;
    final res = await _postRepository.awardPost(post, award, user.uid);
    res.fold((l) => showSnackBar(context, 'l.message'), (r) {
      _ref
          .read(userProfileControllerProvider.notifier)
          .updateKarma(Karma.awardPost);
      _ref.read(userProvider.notifier).update((state) {
        state?.awards.remove(award);
        return state;
      });
      Routemaster.of(context).pop();
    });
  }

  Stream<List<Post>> getGuestPosts() {
    return _postRepository.getGuestPosts();
  }
}
