import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:reddit_clone/core/constants/firebase_constants.dart';
import 'package:reddit_clone/core/provders/firebase_provider.dart';
import 'package:reddit_clone/core/type_def.dart';
import 'package:reddit_clone/models/community_model.dart';
import 'package:reddit_clone/models/failure_model.dart';

final communityRepositoryProvider = Provider((ref) {
  return CommunityRepository(firestore: ref.read(firestoreProvider));
});

class CommunityRepository {
  final FirebaseFirestore _firestore;

  const CommunityRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  CollectionReference get _communities =>
      _firestore.collection(FirebaseConstants.communitiesCollection);

  FutureVoid createCommunity(Community community) async {
    try {
      final communityDoc = await _communities.doc(community.name).get();
      if (communityDoc.exists) {
        throw 'A Community with this name already exists';
      }
      return right(
        _communities.doc(community.name).set(
              community.toMap(),
            ),
      );
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<Community>> getUserCommunities(String uid) {
    return _communities
        .where('members', arrayContains: uid)
        .snapshots()
        .map((event) {
      List<Community> communities = [];
      for (var doc in event.docs) {
        communities.add(
          Community.fromMap(doc.data() as Map<String, dynamic>),
        );
      }
      return communities;
    });
  }

  FutureVoid joinCommunity(String communityName, String uid) async {
    try {
      return right(_communities.doc(communityName).update({
        'members': FieldValue.arrayUnion([uid]),
      }));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureVoid leaveCommunity(String communityName, String uid) async {
    try {
      return right(_communities.doc(communityName).update({
        'members': FieldValue.arrayRemove([uid]),
      }));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<Community> getCommunityByName(String name) {
    return _communities.doc(name).snapshots().map(
        (event) => Community.fromMap(event.data() as Map<String, dynamic>));
  }

  Stream<Community> getCommunityByNameForPost(String name) {
    return _communities.doc(name).snapshots().map(
        (event) => Community.fromMap(event.data() as Map<String, dynamic>));
  }

  Stream<List<Community>> searchCommunity(String query) {
    return _communities
        .where(
          'name',
          isGreaterThanOrEqualTo: query.isEmpty ? 0 : query,
          isLessThan: query.isEmpty
              ? null
              : query.substring(0, query.length - 1) +
                  String.fromCharCode(query.codeUnitAt(query.length - 1) + 1),
        )
        .snapshots()
        .map((event) {
      List<Community> communities = [];
      for (var community in event.docs) {
        communities
            .add(Community.fromMap(community.data() as Map<String, dynamic>));
      }
      return communities;
    });
  }

  FutureVoid editCommunity(Community community) async {
    try {
      return right(
        _communities.doc(community.name).update(
              community.toMap(),
            ),
      );
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

  FutureVoid addModerator(String communityName, List<String> uids) async {
    try {
      return right(
        _communities.doc(communityName).update(
          {'mods': uids},
        ),
      );
    } on FirebaseException catch (e) {
      throw e.toString();
    } catch (e) {
      return left(
        Failure(
          e.toString(),
        ),
      );
    }
  }
}
