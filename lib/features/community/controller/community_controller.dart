import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:reddit_clone/core/constants/constant.dart';
import 'package:reddit_clone/core/provders/storage_repository_provider.dart';
import 'package:reddit_clone/core/utils.dart';
import 'package:reddit_clone/features/auth/controller/auth_controller.dart';
import 'package:reddit_clone/features/community/repository/community_repository.dart';
import 'package:reddit_clone/models/community_model.dart';
import 'package:reddit_clone/models/failure_model.dart';
import 'package:routemaster/routemaster.dart';

final communityControllerProvider =
    StateNotifierProvider<CommunityController, bool>((ref) {
  return CommunityController(
    communityRepository: ref.read(communityRepositoryProvider),
    ref: ref,
    storageRepository: ref.read(storageRepositoryProvider),
  );
});

final getUserCommunityProvider = StreamProvider((ref) {
  final comController = ref.read(communityControllerProvider.notifier);
  return comController.getUserCommunities();
});

final communityByNameProvider =
    StreamProvider.family((ref, String communityName) {
  final controller = ref.read(communityControllerProvider.notifier);
  return controller.getCommunityByName(communityName);
});

final searchCommunityProvider = StreamProvider.family((ref, String query) {
  final controller = ref.read(communityControllerProvider.notifier);

  return controller.searchCommunity(query);
});

class CommunityController extends StateNotifier<bool> {
  final CommunityRepository _communityRepository;
  final Ref _ref;
  final StorageRepository _storageRepository;

  CommunityController({
    required CommunityRepository communityRepository,
    required Ref ref,
    required StorageRepository storageRepository,
  })  : _communityRepository = communityRepository,
        _ref = ref,
        _storageRepository = storageRepository,
        super(false);

  void createCommunity(String name, BuildContext context) async {
    state = true;
    final uid = _ref.read(userProvider)!.uid;
    Community community = Community(
      id: name,
      name: name,
      banner: Constants.bannerDefault,
      avatar: Constants.avatarDefault,
      members: [uid],
      mods: [uid],
    );
    final res = await _communityRepository.createCommunity(community);
    state = false;
    res.fold((l) => showSnackBar(context, l.message), (r) {
      showSnackBar(context, 'Community Successfully Created');
      Routemaster.of(context).pop();
    });
  }

  void joinOrLeaveCommunity(BuildContext context, Community community) async {
    final user = _ref.read(userProvider)!;
    Either<Failure, void> res;
    if (community.members.contains(user.uid)) {
      res = await _communityRepository.leaveCommunity(community.name, user.uid);
    } else {
      res = await _communityRepository.joinCommunity(community.name, user.uid);
    }
    res.fold((l) => showSnackBar(context, l.message), (r) {
      if (community.members.contains(user.uid)) {
        showSnackBar(context, 'Successfully left group');
      } else {
        showSnackBar(context, 'Successfully joined group');
      }
    });
  }

  Stream<Community> getCommunityByName(String name) {
    return _communityRepository.getCommunityByName(name);
  }

  Stream<List<Community>> getUserCommunities() {
    final user = _ref.read(userProvider)!;
    return _communityRepository.getUserCommunities(user.uid);
  }

  Stream<Community> getCommunityByNameForPost(String name) {
    return _communityRepository.getCommunityByNameForPost(name);
  }

  Stream<List<Community>> searchCommunity(String query) {
    return _communityRepository.searchCommunity(query);
  }

  void editCommunity(
      {required Community community,
      required File? profileFile,
      required File? bannerFile,
      required BuildContext context}) async {
    state = true;
    if (profileFile != null) {
      final res = await _storageRepository.storeFile(
        path: 'communities/profile',
        id: community.name,
        file: profileFile,
      );
      res.fold(
        (l) => showSnackBar(context, l.message),
        (r) => community = community.copyWith(avatar: r),
      );
    }
    if (bannerFile != null) {
      final res = await _storageRepository.storeFile(
        path: 'communities/banner',
        id: community.name,
        file: bannerFile,
      );
      res.fold(
        (l) => showSnackBar(context, l.message),
        (r) => community = community.copyWith(banner: r),
      );
    }

    final res = await _communityRepository.editCommunity(community);

    state = false;

    res.fold((l) => showSnackBar(context, l.message),
        (r) => Routemaster.of(context).pop());
  }

  void addModerator(
      String communityName, List<String> uids, BuildContext context) async {
    final res = await _communityRepository.addModerator(communityName, uids);
    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) => Routemaster.of(context).pop(),
    );
  }
}
