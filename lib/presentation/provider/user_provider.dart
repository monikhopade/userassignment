/*// import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:assignment/data/repositories/user_repository.dart';
import 'package:assignment/data/models/user_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/user_service.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  final dio = Dio();
  return UserRepository(UserService(dio));
});

final userListProvider = StateNotifierProvider<UserListNotifier, AsyncValue<List<UserModel>>>((ref) {
  return UserListNotifier(ref.read(userRepositoryProvider));
});

class UserListNotifier extends StateNotifier<AsyncValue<List<UserModel>>> {
  final UserRepository _repository;
  int _page = 1;
  bool _hasMore = true;

  UserListNotifier(this._repository) : super(const AsyncValue.loading()) {
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    if (!_hasMore) return;

    try {
      final response = await _repository.getUsers(5, _page);
      final newUsers = response.data;
      _hasMore = _page < response.total_pages;
      _page++;
      state = AsyncValue.data([...?state.value, ...newUsers]);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  void reset(){
    _page = 1;
    _hasMore = true;
    state = const AsyncValue.loading();
    // await fetchUsers();
  }
}


// Provider to manage the search query
final searchQueryProvider = StateProvider<String>((ref) => '');

// Provider to filter users based on the search query
final filteredUsersProvider = Provider<List<UserModel>>((ref) {
  final searchQuery = ref.watch(searchQueryProvider);
  final users = ref.watch(userListProvider).value ?? [];

  if (searchQuery.isEmpty) {
    return users; // Return all users if no search query
  }

  // Filter users based on the search query
  return users.where((user) {
    final fullName = '${user.first_name} ${user.last_name}'.toLowerCase();
    return fullName.contains(searchQuery.toLowerCase());
  }).toList();
});

// Provider to manage the loading state for pagination
final isLoadingMoreProvider = StateProvider<bool>((ref) => false);
*/



import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:assignment/data/models/user_model.dart';
import 'package:assignment/data/repositories/user_repository.dart';
import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../core/network/user_service.dart';
import 'dart:convert'; // For jsonEncode and jsonDecode

// Provider for UserRepository
final userRepositoryProvider = Provider<UserRepository>((ref) {
  final dio = Dio();
  return UserRepository(UserService(dio));
});

// Provider for UserList
final userListProvider = StateNotifierProvider<UserListNotifier, AsyncValue<List<UserModel>>>((ref) {
  return UserListNotifier(ref.read(userRepositoryProvider));
});

class UserListNotifier extends StateNotifier<AsyncValue<List<UserModel>>> {
  final UserRepository _repository;
  int _page = 1;
  bool _hasMore = true;

  UserListNotifier(this._repository) : super(const AsyncValue.loading()) {
    _loadCachedUsers();
  }

  Future<void> _loadCachedUsers() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final connectivity = await Connectivity().checkConnectivity();

    // Check if offline
    if (connectivity.contains(ConnectivityResult.none)) {
      final cachedUsers = sharedPreferences.getString('userList');
      if (cachedUsers != null) {
        final users = (jsonDecode(cachedUsers) as List)
            .map((user) => UserModel.fromJson(user))
            .toList();
        state = AsyncValue.data(users); // Return cached user list
        return;
      }
    }

    await fetchUsers();
  }

  Future<void> fetchUsers() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity.contains(ConnectivityResult.none)) {
      final cachedUsers = sharedPreferences.getString('userList');
      if (cachedUsers != null) {
        final users = (jsonDecode(cachedUsers) as List)
            .map((user) => UserModel.fromJson(user))
            .toList();
        state = AsyncValue.data(users); // Return cached user list
        return;
      }
    }

    if (!_hasMore) return;

    try {
      final response = await _repository.getUsers(5, _page);
      final newUsers = response.data;

    final sharedPreferences = await SharedPreferences.getInstance();
    if(_page==1){
      await sharedPreferences.remove('userList');
    }
      // Cache the user list
      final cachedUsers = sharedPreferences.getString('userList');
      final users = cachedUsers != null
          ? (jsonDecode(cachedUsers) as List).map((user) => UserModel.fromJson(user)).toList()
          : [];
          
      users.addAll(newUsers);
      sharedPreferences.setString('userList', jsonEncode(users));

      _hasMore = _page < response.total_pages;
      _page++;
      state = AsyncValue.data([...?state.value, ...newUsers]);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  void reset() {
    _page = 1;
    _hasMore = true;
    state = const AsyncValue.loading();
  }
}

// Provider to manage the search query
final searchQueryProvider = StateProvider<String>((ref) => '');

// Provider to filter users based on the search query
final filteredUsersProvider = Provider<List<UserModel>>((ref) {
  final searchQuery = ref.watch(searchQueryProvider);
  final users = ref.watch(userListProvider).value ?? [];

  if (searchQuery.isEmpty) {
    return users; // Return all users if no search query
  }

  // Filter users based on the search query
  return users.where((user) {
    final fullName = '${user.first_name} ${user.last_name}'.toLowerCase();
    return fullName.contains(searchQuery.toLowerCase());
  }).toList();
});

// Provider to manage the loading state for pagination
final isLoadingMoreProvider = StateProvider<bool>((ref) => false);

// Provider to check internet connectivity
final connectivityProvider = StreamProvider<List<ConnectivityResult>>((ref) {
  final connectivity = Connectivity();
  return connectivity.onConnectivityChanged;
});
