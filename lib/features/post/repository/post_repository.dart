import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:reddit_clone/core/constants/firebase_constants.dart';
import 'package:reddit_clone/core/provders/firebase_provider.dart';
import 'package:reddit_clone/core/type_def.dart';
import 'package:reddit_clone/models/community_model.dart';
import 'package:reddit_clone/models/failure_model.dart';
import 'package:reddit_clone/models/post_model.dart';

final postRepositoryProvider = Provider(
  (ref) => PostRepository(
    firestore: ref.read(firestoreProvider),
  ),
);

class PostRepository {
  final FirebaseFirestore _firestore;

  PostRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  CollectionReference get _posts =>
      _firestore.collection(FirebaseConstants.postsCollection);

  FutureVoid addPosts(Post post) async {
    try {
      return right(
        _posts.doc(post.id).set(
              post.toMap(),
            ),
      );
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(
        e.toString(),
      ));
    }
  }

  Stream<List<Post>> fetchUserPosts(List<Community> communities) {
    return _posts
        .where('communityName',
            whereIn: communities.map((e) => e.name).toList())
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((event) => event.docs
            .map(
              (e) => Post.fromMap(e.data() as Map<String, dynamic>),
            )
            .toList());
  }

  FutureVoid deletePost(Post post) async {
    try {
      return right(_posts.doc(post.id).delete());
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(
        Failure(
          e.toString(),
        ),
      );
    }
  }

  void upVote(Post post, String userId) async {
    if (post.downVotes.contains(userId)) {
      await _posts.doc(post.id).update({
        'downVotes': FieldValue.arrayRemove([userId]),
      });
    }
    if (post.upVotes.contains(userId)) {
      await _posts.doc(post.id).update({
        'upVotes': FieldValue.arrayRemove([userId]),
      });
    } else {
      await _posts.doc(post.id).update({
        'upVotes': FieldValue.arrayUnion([userId]),
      });
    }
  }

  void downVote(Post post, String userId) async {
    if (post.upVotes.contains(userId)) {
      await _posts.doc(post.id).update({
        'upVotes': FieldValue.arrayRemove([userId]),
      });
    }
    if (post.downVotes.contains(userId)) {
      await _posts.doc(post.id).update({
        'downVotes': FieldValue.arrayRemove([userId]),
      });
    } else {
      await _posts.doc(post.id).update({
        'downVotes': FieldValue.arrayUnion([userId]),
      });
    }
  }

  Stream<List<Post>> getUserPosts(String uid) {
    return _posts
        .where('uid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (event) => event.docs
              .map(
                (e) => Post.fromMap(e.data() as Map<String, dynamic>),
              )
              .toList(),
        );
  }

  Stream<List<Post>> getCommunityPost(String communityName) {
    return _posts
        .where('communityName', isEqualTo: communityName)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (event) => event.docs
              .map(
                (e) => Post.fromMap(e.data() as Map<String, dynamic>),
              )
              .toList(),
        );
  }
}
