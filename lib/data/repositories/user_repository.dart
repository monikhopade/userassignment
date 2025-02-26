import 'package:assignment/core/network/user_service.dart';
import 'package:assignment/data/models/user_model.dart';
import 'package:dio/dio.dart';

class UserRepository {
  final UserService _userService;

  UserRepository(this._userService);

  Future<UserResponse> getUsers(int perPage, int page) async {
    try {
      return await _userService.getUsers(perPage, page);
    } on DioException catch (e) {
      throw Exception("Failed to fetch users: ${e.message}");
    }
  }
}