import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/constants/constant.dart';
import 'package:reddit_clone/core/utils.dart';
import 'package:reddit_clone/features/auth/controller/auth_controller.dart';
import 'package:reddit_clone/features/community/repository/community_repository.dart';
import 'package:reddit_clone/models/community_model.dart';
import 'package:reddit_clone/models/user_model.dart';
import 'package:routemaster/routemaster.dart';

final communityControllerProvider =
    StateNotifierProvider<CommunityController, bool>((ref) {
  return CommunityController(
      communityRepository: ref.read(communityRepositoryProvider), ref: ref);
});
final communityListProvider = StreamProvider((ref) {
  final getCommunityControllerProvider =
      ref.watch(communityControllerProvider.notifier);
  return getCommunityControllerProvider.getCommunities();
});
final communityNameProvider = StateProvider<String?>((ref) => null);

final communityByNameProvider = StreamProvider((ref) {
  final name = ref.watch(communityNameProvider);
  final controller = ref.watch(communityControllerProvider.notifier);
  return controller.getCommunityByName(name!);
});

class CommunityController extends StateNotifier<bool> {
  final CommunityRepository _communityRepository;
  final Ref _ref;

  CommunityController(
      {required CommunityRepository communityRepository, required Ref ref})
      : _communityRepository = communityRepository,
        _ref = ref,
        super(false);
  void createCommunity(String name, BuildContext context) async {
    state = true;
    final uid = _ref.read(userProvider)!.uid;
    Community community = Community(
      id: name,
      name: name,
      banner: Constant.bannerDefault,
      avatar: Constant.avatarDefault,
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

  Stream<Community> getCommunityByName(String name) {
    return _communityRepository.getCommunityByName(name);
  }

  Stream<List<Community>> getCommunities() {
    final uid = _ref.read(userProvider)!.uid;
    return _communityRepository.getCommunities(uid);
  }
}