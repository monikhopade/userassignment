import 'package:flutter/material.dart';

import '../../data/models/user_model.dart';

class UserDetailScreen extends StatefulWidget {
  final UserModel user;

  const UserDetailScreen({super.key, required this.user});

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _photoAnimation;
  late Animation<Offset> _emailAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Define slide animations
    _photoAnimation = Tween<Offset>(
      begin: const Offset(0, -1), // Slide in from top
      end: Offset.zero, // Final position
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _emailAnimation = Tween<Offset>(
      begin: const Offset(0, 1), // Slide in from bottom
      end: Offset.zero, // Final position
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    // Start the animation
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.user.first_name} ${widget.user.last_name}"),
      ),
      body: Column(
        children: [
          // Photo with rounded corners and slide animation
          SlideTransition(
            position: _photoAnimation,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.8, // 80% of screen height
              padding: const EdgeInsets.all(16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20), // Rounded corners
                child: Image.network(
                  widget.user.avatar,
                  fit: BoxFit.cover, // Ensure the image covers the container
                ),
              ),
            ),
          ),

          // Email with slide animation
          SlideTransition(
            position: _emailAnimation,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                widget.user.email,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}