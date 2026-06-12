import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/post_model.dart';
import '../utils/app_theme.dart';

class PostCard extends StatelessWidget {
  final PostModel post;

  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(
          bottom: BorderSide(color: AppTheme.divider, width: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: profile pic + username + time
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                // Profile picture
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppTheme.divider,
                  backgroundImage: post.userProfilePicBase64.isNotEmpty
                      ? MemoryImage(base64Decode(post.userProfilePicBase64))
                      : null,
                  child: post.userProfilePicBase64.isEmpty
                      ? Text(
                          post.username.isNotEmpty
                              ? post.username[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            color: AppTheme.accent,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 10),
                // Username
                Expanded(
                  child: Text(post.username, style: AppTheme.username),
                ),
                // Time ago
                Text(
                  timeago.format(post.createdAt),
                  style: AppTheme.caption,
                ),
              ],
            ),
          ),

          // Post image
          AspectRatio(
            aspectRatio: 1,
            child: post.imageBase64.isNotEmpty
                ? Image.memory(
                    base64Decode(post.imageBase64),
                    fit: BoxFit.cover,
                  )
                : Container(
                    color: AppTheme.inputFill,
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  ),
          ),

          // Caption
          if (post.caption.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${post.username} ',
                      style: AppTheme.username,
                    ),
                    TextSpan(
                      text: post.caption,
                      style: AppTheme.bodyText,
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
