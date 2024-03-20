import 'package:flutter/material.dart';
import 'package:reddit_clone/features/community/controller/community_controller.dart';
import 'package:routemaster/routemaster.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ModToolScreen extends ConsumerWidget {
  const ModToolScreen({super.key});

  void navigateToEditCommunityScreen(BuildContext context, String name) {
    Routemaster.of(context).push('/r/mod-tools/edit-community');
  }

  void navigateToAdModScreen(BuildContext context, String name) {
    Routemaster.of(context).push('/r/mod-tools/add-mods');
  }


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = ref.watch(communityNameProvider)!;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mod Tools'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          ListTile(
            onTap: () => navigateToAdModScreen(context, name),
            leading: const Icon(Icons.add_moderator),
            title: const Text("Add Moderators"),
          ),
          ListTile(
            onTap: () => navigateToEditCommunityScreen(context, name),
            leading: const Icon(Icons.edit),
            title: const Text("Edit Community"),
          )
        ],
      ),
    );
  }
}
