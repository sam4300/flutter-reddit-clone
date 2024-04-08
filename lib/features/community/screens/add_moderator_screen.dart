import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/common/error_text.dart';
import 'package:reddit_clone/core/common/loader.dart';
import 'package:reddit_clone/features/auth/controller/auth_controller.dart';
import 'package:reddit_clone/features/community/controller/community_controller.dart';

class AddModeratorScreen extends ConsumerStatefulWidget {
  final String communityName;
  const AddModeratorScreen({super.key, required this.communityName});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AddModeratorScreenState();
}

class _AddModeratorScreenState extends ConsumerState<AddModeratorScreen> {
  Set<String> uids = {};
  int ctr = 0;
  bool isLoading = false;

  void addToSet(String id) {
    setState(() {
      uids.add(id);
    });
  }

  void removeFromSet(String id) {
    setState(() {
      uids.remove(id);
      ctr++;
    });
  }

  void modifyModerators(String communityName) {
    ref
        .read(communityControllerProvider.notifier)
        .addModerator(communityName, uids.toList(), context);
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(userProvider)!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('add mods'),
        actions: [
          IconButton(
            onPressed: () => modifyModerators(widget.communityName),
            icon: const Icon(Icons.done),
          )
        ],
      ),
      body: ref.watch(communityByNameProvider(widget.communityName)).when(
          data: (community) {
            isLoading = false;
            return isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: community.members.length,
                    itemBuilder: (BuildContext context, int index) {
                      final member = community.members[index];
                      return ref.watch(userDataProvider(member)).when(
                          data: (user) {
                        if (community.mods.contains(user.uid) && ctr == 0) {
                          uids.add(user.uid);
                        }
                        return CheckboxListTile(
                          value: uids.contains(user.uid),
                          onChanged: (val) {
                            if (val!) {
                              addToSet(user.uid);
                            } else {
                              removeFromSet(user.uid);
                            }
                          },
                          title: currentUser == user.uid
                              ? Text('${user.name}(You)')
                              : Text(user.name),
                        );
                      }, error: (error, stackTrace) {
                        isLoading = false;
                        return ErrorText(message: error.toString());
                      }, loading: () {
                        isLoading = true;
                        return null;
                      });
                    },
                  );
          },
          error: (error, stackTrace) => ErrorText(message: error.toString()),
          loading: () => const Loader()),
    );
  }
}
