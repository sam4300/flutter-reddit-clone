import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/common/error_text.dart';
import 'package:reddit_clone/core/common/loader.dart';
import 'package:reddit_clone/core/constants/constant.dart';
import 'package:reddit_clone/features/auth/controller/auth_controller.dart';
import 'package:reddit_clone/features/community/controller/community_controller.dart';
import 'package:reddit_clone/theme/palette.dart';

class EditCommunityScreen extends ConsumerStatefulWidget {
  const EditCommunityScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EditCommunityScreenState();
}

class _EditCommunityScreenState extends ConsumerState<EditCommunityScreen> {
  void selectBannerImage() {
    
  }
  @override
  Widget build(BuildContext context) {
    return ref.watch(communityByNameProvider).when(
          data: (community) => Scaffold(
            appBar: AppBar(
              title: const Text('Edit Community'),
              actions: [
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Save',
                    style: TextStyle(color: Colors.blue),
                  ),
                )
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  SizedBox(
                    height: 200,
                    child: Stack(
                      children: [
                        DottedBorder(
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
                            child: Center(
                              child: community.banner.isEmpty ||
                                      community.banner == Constant.bannerDefault
                                  ? const Icon(
                                      Icons.camera_alt_outlined,
                                      size: 40,
                                    )
                                  : Image.network(community.banner),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 20,
                          bottom: 20,
                          child: CircleAvatar(
                            backgroundImage: NetworkImage(community.avatar),
                            radius: 32,
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          error: (error, stackTrace) => ErrorText(message: error.toString()),
          loading: () => const Loader(),
        );
  }
}
