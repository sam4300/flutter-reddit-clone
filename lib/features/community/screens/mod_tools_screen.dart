import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ModToolScreen extends ConsumerWidget {
  final String communityName;
  const ModToolScreen({super.key, required this.communityName});

  void navigateToEditCommunityScreen(BuildContext context) {
    Routemaster.of(context).push('/r/$communityName/mod-tools/edit-community');
  }

  void navigateToAdModScreen(BuildContext context) {
    Routemaster.of(context).push('/r/$communityName/mod-tools/add-mods');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mod Tools'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          ListTile(
            onTap: () => navigateToAdModScreen(context),
            leading: const Icon(Icons.add_moderator),
            title: const Text("Add Moderators"),
          ),
          ListTile(
            onTap: () => navigateToEditCommunityScreen(context),
            leading: const Icon(Icons.edit),
            title: const Text("Edit Community"),
          )
        ],
      ),
    );
  }
}
