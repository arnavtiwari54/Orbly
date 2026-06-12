import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../models/post_model.dart';
import '../services/auth_service.dart';
import '../services/post_service.dart';
import '../utils/app_theme.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final PostService _postService = PostService();
  UserModel? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    UserModel? user = await _authService.getUserData(uid);
    setState(() {
      _user = user;
      _isLoading = false;
    });
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: Text('Log Out', style: AppTheme.headingMedium),
        content:
            Text('Are you sure you want to log out?', style: AppTheme.bodyText),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _logout();
            },
            child:
                const Text('Log Out', style: TextStyle(color: AppTheme.accent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.accent),
        ),
      );
    }

    if (_user == null) {
      return Scaffold(
        body: Center(child: Text('User not found', style: AppTheme.bodyText)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_user!.username),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _showLogoutDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Profile Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Profile Picture
                CircleAvatar(
                  radius: 44,
                  backgroundColor: AppTheme.inputFill,
                  backgroundImage: _user!.profilePicBase64.isNotEmpty
                      ? MemoryImage(base64Decode(_user!.profilePicBase64))
                      : null,
                  child: _user!.profilePicBase64.isEmpty
                      ? Text(
                          _user!.username.isNotEmpty
                              ? _user!.username[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            fontSize: 36,
                            color: AppTheme.accent,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                const SizedBox(height: 12),
                Text(_user!.username, style: AppTheme.headingMedium),
                const SizedBox(height: 4),
                Text(_user!.email, style: AppTheme.caption),
                const SizedBox(height: 16),

                // Posts Count
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppTheme.inputFill,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${_user!.postsCount}',
                        style: AppTheme.headingMedium
                            .copyWith(color: AppTheme.accent),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _user!.postsCount == 1 ? 'Post' : 'Posts',
                        style: AppTheme.caption,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(color: AppTheme.divider, height: 1),

          // Posts Grid
          Expanded(
            child: StreamBuilder<List<PostModel>>(
              stream: _postService.getUserPosts(_user!.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppTheme.accent),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.grid_off,
                            size: 48, color: AppTheme.textSecondary),
                        const SizedBox(height: 12),
                        Text('No posts yet', style: AppTheme.bodyText),
                        const SizedBox(height: 8),
                        Text('Tap + to share your first photo',
                            style: AppTheme.caption),
                      ],
                    ),
                  );
                }

                List<PostModel> posts = snapshot.data!;
                return GridView.builder(
                  padding: const EdgeInsets.all(2),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 2,
                    mainAxisSpacing: 2,
                  ),
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    return posts[index].imageBase64.isNotEmpty
                        ? Image.memory(
                            base64Decode(posts[index].imageBase64),
                            fit: BoxFit.cover,
                          )
                        : Container(
                            color: AppTheme.inputFill,
                            child: const Icon(Icons.broken_image,
                                color: Colors.grey, size: 20),
                          );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
