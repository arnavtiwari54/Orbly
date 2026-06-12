import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/post_service.dart';
import '../utils/app_theme.dart';
import '../widgets/loading_button.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _captionController = TextEditingController();
  final PostService _postService = PostService();
  final AuthService _authService = AuthService();
  final ImagePicker _picker = ImagePicker();

  XFile? _selectedXFile; // For web
  File? _selectedFile; // For mobile
  String? _webImageBase64; // Preview on web
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
      maxWidth: 800,
    );

    if (picked != null) {
      if (kIsWeb) {
        // On web, read bytes for preview
        final bytes = await picked.readAsBytes();
        setState(() {
          _selectedXFile = picked;
          _webImageBase64 = base64Encode(bytes);
        });
      } else {
        setState(() {
          _selectedFile = File(picked.path);
          _selectedXFile = picked;
        });
      }
    }
  }

  Future<void> _uploadPost() async {
    if (_selectedXFile == null && _selectedFile == null) {
      _showSnackBar('Please select an image first');
      return;
    }

    setState(() => _isLoading = true);

    String uid = FirebaseAuth.instance.currentUser!.uid;
    UserModel? user = await _authService.getUserData(uid);

    if (user == null) {
      setState(() => _isLoading = false);
      _showSnackBar('Could not load user data');
      return;
    }

    String result = await _postService.createPost(
      imageXFile: _selectedXFile,
      imageFile: _selectedFile,
      caption: _captionController.text.trim(),
      currentUser: user,
    );

    setState(() => _isLoading = false);

    if (result == 'success') {
      setState(() {
        _selectedXFile = null;
        _selectedFile = null;
        _webImageBase64 = null;
        _captionController.clear();
      });
      _showSnackBar('Post shared! 🎉');
    } else {
      _showSnackBar('Failed: $result');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.accent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Build image preview for both web and mobile
  Widget _buildImagePreview() {
    if (kIsWeb && _webImageBase64 != null) {
      return Image.memory(
        base64Decode(_webImageBase64!),
        fit: BoxFit.cover,
      );
    } else if (!kIsWeb && _selectedFile != null) {
      return Image.file(_selectedFile!, fit: BoxFit.cover);
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.add_photo_alternate_outlined,
            size: 56, color: AppTheme.textSecondary),
        const SizedBox(height: 12),
        Text('Tap to select a photo', style: AppTheme.bodyText),
        const SizedBox(height: 6),
        Text('From your gallery', style: AppTheme.caption),
      ],
    );
  }

  bool get _hasImage =>
      (kIsWeb && _webImageBase64 != null) || (!kIsWeb && _selectedFile != null);

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Post')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Image Picker Area
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: double.infinity,
                height: 300,
                decoration: BoxDecoration(
                  color: AppTheme.inputFill,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _hasImage ? AppTheme.accent : AppTheme.divider,
                    width: 1.5,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: _buildImagePreview(),
                ),
              ),
            ),

            if (_hasImage) ...[
              const SizedBox(height: 10),
              TextButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.swap_horiz, color: AppTheme.accent),
                label: Text('Change photo',
                    style: AppTheme.caption.copyWith(color: AppTheme.accent)),
              ),
            ],

            const SizedBox(height: 20),

            // Caption
            TextField(
              controller: _captionController,
              maxLines: 3,
              maxLength: 200,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(
                hintText: 'Write a caption...',
                alignLabelWithHint: true,
                prefixIcon: Padding(
                  padding: EdgeInsets.only(bottom: 40),
                  child:
                      Icon(Icons.edit_outlined, color: AppTheme.textSecondary),
                ),
              ),
            ),

            const SizedBox(height: 24),

            LoadingButton(
              isLoading: _isLoading,
              text: 'Share Post',
              onPressed: _uploadPost,
            ),
          ],
        ),
      ),
    );
  }
}
