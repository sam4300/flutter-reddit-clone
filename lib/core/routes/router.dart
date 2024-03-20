import 'package:flutter/material.dart';
import 'package:reddit_clone/features/auth/screens/login_screen.dart';
import 'package:reddit_clone/features/community/screens/add_moderator_screen.dart';
import 'package:reddit_clone/features/community/screens/community_screen.dart';
import 'package:reddit_clone/features/community/screens/create_community_screen.dart';
import 'package:reddit_clone/features/community/screens/edit_community_screen.dart';
import 'package:reddit_clone/features/community/screens/mod_tools_screen.dart';
import 'package:reddit_clone/features/home/screens/home_screen.dart';
import 'package:reddit_clone/features/user_profile/screens/edit_userProfile_screen.dart';
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
    '/r': (_) => const MaterialPage(
          child: CommunityScreen(),
        ),
    '/r/mod-tools': (_) => const MaterialPage(child: ModToolScreen()),
    '/r/mod-tools/edit-community': (_) =>
        const MaterialPage(child: EditCommunityScreen()),
    '/r/mod-tools/add-mods': (_) =>
        const MaterialPage(child: AddModeratorScreen()),
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
  },
);
