import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/common/error_text.dart';
import 'package:reddit_clone/core/common/loader.dart';
import 'package:reddit_clone/core/utils.dart';
import 'package:reddit_clone/features/community/controller/community_controller.dart';
import 'package:reddit_clone/features/post/controller/post_controller.dart';
import 'package:reddit_clone/models/community_model.dart';
import 'package:reddit_clone/theme/palette.dart';

class PostTypeScreen extends ConsumerStatefulWidget {
  final String type;
  const PostTypeScreen({super.key, required this.type});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PostTypeScreenState();
}

class _PostTypeScreenState extends ConsumerState<PostTypeScreen> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final linkController = TextEditingController();
  File? bannerFile;
  Community? selectedCommunity;
  List<Community> communities = [];

  void selectBannerFile() async {
    final res = await pickImage();

    if (res != null) {
      setState(() {
        bannerFile = File(res.files.first.path!);
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    titleController.dispose();
    descriptionController.dispose();
    linkController.dispose();
  }

  void sharePost() {
    if (widget.type == 'Image' &&
        bannerFile != null &&
        titleController.text.isNotEmpty) {
      ref.read(postControllerProvider.notifier).shareImagePost(
          context: context,
          title: titleController.text.trim(),
          file: bannerFile!,
          selectedCommunity: selectedCommunity ?? communities[0]);
    } else if (widget.type == 'Text' && titleController.text.isNotEmpty) {
      ref.read(postControllerProvider.notifier).shareTextPost(
          context: context,
          title: titleController.text.trim(),
          description: descriptionController.text.trim(),
          selectedCommunity: selectedCommunity ?? communities[0]);
    } else if (widget.type == 'Link' &&
        linkController.text.isNotEmpty &&
        titleController.text.isNotEmpty) {
      ref.read(postControllerProvider.notifier).shareLinkPost(
          context: context,
          title: titleController.text.trim(),
          link: linkController.text.trim(),
          selectedCommunity: selectedCommunity ?? communities[0]);
    } else {
      showSnackBar(context, 'Please enter all the fields');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(postControllerProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Post ${widget.type}',
        ),
        actions: [
          IconButton(
            onPressed: sharePost,
            icon: const Icon(Icons.done),
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    maxLength: 25,
                    controller: titleController,
                    decoration: const InputDecoration(
                      filled: true,
                      hintText: 'Enter the title of your post',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(10),
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (widget.type == 'Image')
                    GestureDetector(
                      onTap: () => selectBannerFile(),
                      child: DottedBorder(
                        borderType: BorderType.RRect,
                        radius: const Radius.circular(10),
                        dashPattern: const [10, 4],
                        strokeCap: StrokeCap.round,
                        color: Pallete
                            .darkModeAppTheme.textTheme.bodyMedium!.color!,
                        child: Container(
                            height: 150,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: bannerFile != null
                                ? Image.file(
                                    bannerFile!,
                                    fit: BoxFit.cover,
                                  )
                                : const Center(
                                    child: Icon(
                                      Icons.camera_alt_outlined,
                                      size: 40,
                                    ),
                                  )),
                      ),
                    ),
                  if (widget.type == 'Text')
                    TextField(
                      controller: descriptionController,
                      maxLines: 8,
                      decoration: const InputDecoration(
                        filled: true,
                        border: InputBorder.none,
                        hintText: 'Enter Description Here',
                        contentPadding: EdgeInsets.all(10),
                      ),
                    ),
                  if (widget.type == 'Link')
                    TextField(
                      controller: linkController,
                      decoration: const InputDecoration(
                        filled: true,
                        border: InputBorder.none,
                        hintText: 'Enter Link Here',
                        contentPadding: EdgeInsets.all(10),
                      ),
                    ),
                  const SizedBox(height: 15),
                  const Text('Select community'),
                  const SizedBox(height: 10),
                  ref.watch(getUserCommunityProvider).when(
                      data: (data) {
                        communities = data;
                        return Align(
                          alignment: Alignment.center,
                          child: DropdownButton(
                            value: selectedCommunity ?? data[0],
                            items: data
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e.name),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedCommunity = value;
                              });
                            },
                          ),
                        );
                      },
                      error: (error, stackTrace) =>
                          ErrorText(message: error.toString()),
                      loading: () => const Loader())
                ],
              ),
            ),
    );
  }
}
