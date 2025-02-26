import 'package:flutter/material.dart';
import 'package:assignment/presentation/pages/user_list_screen.dart';
import 'package:assignment/data/models/user_model.dart';

import '../../presentation/pages/user_detail_screen.dart';

class AppRouter {
  static const String userList = '/';
  static const String userDetail = '/userDetail';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case userList:
        return MaterialPageRoute(builder: (_) => const UserListScreen());
      case userDetail:
        final user = settings.arguments as UserModel;
        return MaterialPageRoute(
          builder: (_) => UserDetailScreen(user: user),
        );
      default:
        throw Exception('Invalid route: ${settings.name}');
    }
  }
}