import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/common/loader.dart';
import 'package:reddit_clone/features/community/controller/community_controller.dart';
import 'package:reddit_clone/theme/palette.dart';

class CreateCommunityScreen extends ConsumerStatefulWidget {
  const CreateCommunityScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CreateCommunityScreenState();
}

class _CreateCommunityScreenState extends ConsumerState<CreateCommunityScreen> {
  final communityController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    communityController.dispose();
  }

  void createCommunity() {
    ref
        .watch(communityControllerProvider.notifier)
        .createCommunity(communityController.text.trim(), context);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(communityControllerProvider);

    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Create Community',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
        ),
        body: isLoading
            ? const Loader()
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Community name'),
                    const SizedBox(height: 10),
                    TextField(
                      controller: communityController,
                      decoration: const InputDecoration(
                        hintText: 'r/Community_name ',
                        border: InputBorder.none,
                        filled: true,
                        fillColor: Pallete.greyColor,
                        contentPadding: EdgeInsets.all(12),
                      ),
                      maxLength: 21,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: createCommunity,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        'Create Community',
                        style: TextStyle(color: Colors.white, fontSize: 17),
                      ),
                    ),
                  ],
                ),
              ));
  }
}
