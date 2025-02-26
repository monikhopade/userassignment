import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:assignment/data/models/user_model.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../core/navigation/app_router.dart';
import '../provider/user_provider.dart';

class UserListScreen extends ConsumerStatefulWidget {
  const UserListScreen({super.key});

  @override
  ConsumerState<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends ConsumerState<UserListScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchChanged);
    _checkConnectivity();
  }

  void _onScroll() {
     final connectivity = ref.read(connectivityProvider);
    final isLoadingMore = ref.read(isLoadingMoreProvider);
    // Disable pagination when offline
    if (connectivity.value!.contains(ConnectivityResult.none)) {
      return;
    }
 
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent &&
        !(isLoadingMore)) {
      _loadMoreUsers();
    }
  }

  void _onSearchChanged() {
    // Update the search query using Riverpod
    ref.read(searchQueryProvider.notifier).state = _searchController.text;
  }

  Future<void> _loadMoreUsers() async {
 
    // Update loading state using Riverpod
    ref.read(isLoadingMoreProvider.notifier).state = true;
    await ref.read(userListProvider.notifier).fetchUsers();
    ref.read(isLoadingMoreProvider.notifier).state = false;
  }

  Future<void> _refreshUsers() async {
     final List<ConnectivityResult> connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult.contains(ConnectivityResult.none)) {
        if(mounted){
         ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("No Internet Connection."),
                duration: Duration(seconds: 2),
              ),
            );
        }
      }
      else{
    // Reset the list and fetch users from the beginning
        ref.read(userListProvider.notifier).reset();
       await ref.read(userListProvider.notifier).fetchUsers();
      }
    
    
  }

  void _clearSearch() {
    _searchController.clear(); // Clear the search text
    ref.read(searchQueryProvider.notifier).state = ''; // Reset the search query
  }

  Future<void> _checkConnectivity() async {
    final connectivity = Connectivity();
    connectivity.onConnectivityChanged.listen((result) {
      if (result.contains(ConnectivityResult.none)) {
        if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("No Internet Connection. Showing cached data."),
                duration: Duration(seconds: 2),
              ),
            );}
      } else {
       if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Internet connection restored. Reloading data..."),
                duration: Duration(seconds: 2),
              ),
            );
       }
        _refreshUsers(); // Reload data when internet is back
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userListState = ref.watch(userListProvider);
    final filteredUsers = ref.watch(filteredUsersProvider);
    final isLoadingMore = ref.watch(isLoadingMoreProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Users"),
      ),
      body: userListState.when(
            data: (users) {
              return RefreshIndicator(
                onRefresh: _refreshUsers,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: "Search by name...",
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: _clearSearch,
                                  )
                                : null,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onChanged: (query) {
                            // Update the search query using Riverpod
                            ref.read(searchQueryProvider.notifier).state = query;
                          },
                        ),
                      ),
                      Expanded(
                        child: ListWheelScrollView.useDelegate(
                          controller: _scrollController,
                          itemExtent: 200, // Height of each item
                          perspective: 0.001, // 3D perspective
                          diameterRatio: 3.0, // Adjust the curvature of the wheel
                          offAxisFraction: 0.0,
                          squeeze: 1.0,
                          childDelegate: ListWheelChildBuilderDelegate(
                            childCount: filteredUsers.length + (isLoadingMore ? 1 : 0),
                            builder: (context, index) {
                              if (index < filteredUsers.length) {
                                final user = filteredUsers[index];
                                return _buildUserTile(user);
                              } else {
                                return _buildLoader();
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(child: Text("Error: $error")),
          ),
        
    );
  }

  Widget _buildUserTile(UserModel user) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRouter.userDetail,
          arguments: user,
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color.fromARGB(255, 24, 113, 121),
              Color.fromARGB(255, 56, 165, 175),
            ],
            begin: FractionalOffset(0.0, 0.0),
            end: FractionalOffset(1.0, 0.0),
            stops: [0.0, 1.0],
            tileMode: TileMode.clamp,
          ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(user.avatar),
              radius: 70,
            ),
            Text(
              "${user.first_name} ${user.last_name}",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoader() {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}