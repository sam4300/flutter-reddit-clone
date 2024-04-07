import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/provders/storage_repository_provider.dart';
import 'package:reddit_clone/core/utils.dart';
import 'package:reddit_clone/features/auth/controller/auth_controller.dart';
import 'package:reddit_clone/features/post/repository/post_repository.dart';
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

final getUserPostsProvider = StreamProvider.family((ref, String uid) {
  return ref.read(postControllerProvider.notifier).getUserPosts(uid);
});
final getCommunityPostProvider =
    StreamProvider.family((ref, String communityName) {
  return ref
      .read(postControllerProvider.notifier)
      .getCommunityPost(communityName);
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
    final user = _ref.read(userProvider)!;

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
    final user = _ref.read(userProvider)!;
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
    final user = _ref.read(userProvider)!;

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
    state = false;

    res.fold((l) => showSnackBar(context, l.message), (r) {
      showSnackBar(context, 'Posted Successfully');
      Routemaster.of(context).pop();
    });
  }

  void deletePost(Post post, BuildContext context) async {
    final res = await _postRepository.deletePost(post);
    res.fold((l) => showSnackBar(context, l.message),
        (r) => showSnackBar(context, 'Successfully Deleted'));
  }

  void upVote(Post post) {
    final userId = _ref.read(userProvider)!.uid;
    _postRepository.upVote(post, userId);
  }

  void downVote(Post post) {
    final userId = _ref.read(userProvider)!.uid;
    _postRepository.downVote(post, userId);
  }

  Stream<List<Post>> getUserPosts(String uid) {
    return _postRepository.getUserPosts(uid);
  }

  Stream<List<Post>> getCommunityPost(String communityName) {
    return _postRepository.getCommunityPost(communityName);
  }
}
