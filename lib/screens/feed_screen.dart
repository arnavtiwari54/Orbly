import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../services/post_service.dart';
import '../utils/app_theme.dart';
import '../widgets/post_card.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final PostService postService = PostService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Orbly'),
        leading: Padding(
          padding: const EdgeInsets.all(10),
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.accent, Colors.purple],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child:
                const Icon(Icons.photo_camera, color: Colors.white, size: 18),
          ),
        ),
      ),
      body: StreamBuilder<List<PostModel>>(
        stream: postService.getAllPosts(),
        builder: (context, snapshot) {
          // While waiting for data
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.accent),
            );
          }

          // If there's an error
          if (snapshot.hasError) {
            return Center(
              child: Text('Error loading posts', style: AppTheme.bodyText),
            );
          }

          // If no posts yet
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.photo_library_outlined,
                      size: 64, color: AppTheme.textSecondary),
                  const SizedBox(height: 16),
                  Text('No posts yet', style: AppTheme.headingMedium),
                  const SizedBox(height: 8),
                  Text('Be the first to share something!',
                      style: AppTheme.caption),
                ],
              ),
            );
          }

          // Show posts
          List<PostModel> posts = snapshot.data!;
          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              return PostCard(post: posts[index]);
            },
          );
        },
      ),
    );
  }
}
