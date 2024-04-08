import 'package:flutter/material.dart';
import 'package:reddit_clone/features/auth/screens/login_screen.dart';
import 'package:reddit_clone/features/community/screens/add_moderator_screen.dart';
import 'package:reddit_clone/features/community/screens/community_screen.dart';
import 'package:reddit_clone/features/community/screens/create_community_screen.dart';
import 'package:reddit_clone/features/community/screens/edit_community_screen.dart';
import 'package:reddit_clone/features/community/screens/mod_tools_screen.dart';
import 'package:reddit_clone/features/home/screens/home_screen.dart';
import 'package:reddit_clone/features/post/screens/comment_screen.dart';
import 'package:reddit_clone/features/post/screens/post_type_screen.dart';
import 'package:reddit_clone/features/user_profile/screens/edit_userprofile_screen.dart';
import 'package:reddit_clone/features/user_profile/screens/user_profile_screen.dart';
import 'package:routemaster/routemaster.dart';

final loggedOutRoute = RouteMap(routes: {
  '/': (_) => const MaterialPage(child: LoginScreen()),
});

final loggedInRoute = RouteMap(
  routes: {
    '/': (_) => const MaterialPage(child: HomeScreen()),
    '/create-community': (_) =>
        const MaterialPage(child: CreateCommunityScreen()),
    '/r/:communityName': (routeData) => MaterialPage(
          child: CommunityScreen(
            communityName: routeData.pathParameters['communityName']!,
          ),
        ),
    '/r/:communityName/mod-tools/': (routeData) => MaterialPage(
        child: ModToolScreen(
            communityName: routeData.pathParameters['communityName']!)),
    '/r/:communityName/mod-tools/edit-community': (routeData) => MaterialPage(
            child: EditCommunityScreen(
          communityName: routeData.pathParameters['communityName']!,
        )),
    '/r/:communityName/mod-tools/add-mods': (routeData) => MaterialPage(
            child: AddModeratorScreen(
          communityName: routeData.pathParameters['communityName']!,
        )),
    '/u/:uid': (routeData) => MaterialPage(
          child: UserProfileScreen(
            uid: routeData.pathParameters['uid']!,
          ),
        ),
    '/u/:uid/edit-user-profile': (routeData) => MaterialPage(
          child: EditUserProfileScreen(
            uid: routeData.pathParameters['uid']!,
          ),
        ),
    '/post-type-screen/:type': (routeData) => MaterialPage(
          child: PostTypeScreen(
            type: routeData.pathParameters['type']!,
          ),
        ),
    '/comment-screen/:postId': (routeData) => MaterialPage(
            child: CommentScreen(
          postId: routeData.pathParameters['postId']!,
        ))
  },
);
