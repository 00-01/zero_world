/// Create Post Screen
/// Interface for creating new social posts

import 'package:flutter/material.dart';
import '../models/social.dart';
import '../services/social_service.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final SocialService _socialService = SocialService();
  final TextEditingController _contentController = TextEditingController();

  PostType _selectedType = PostType.text;
  PostVisibility _selectedVisibility = PostVisibility.public;
  String? _location;
  List<String> _selectedImages = [];
  List<String> _selectedVideos = [];
  bool _isPosting = false;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
        actions: [
          TextButton(
            onPressed: _isPosting ? null : _createPost,
            child: _isPosting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Post', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  child: const Icon(Icons.person),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Current User',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    DropdownButton<PostVisibility>(
                      value: _selectedVisibility,
                      isDense: true,
                      underline: const SizedBox(),
                      items: PostVisibility.values.map((visibility) {
                        return DropdownMenuItem(
                          value: visibility,
                          child: Row(
                            children: [
                              Icon(_getVisibilityIcon(visibility), size: 16),
                              const SizedBox(width: 4),
                              Text(
                                visibility.name,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedVisibility = value);
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Content Input
            TextField(
              controller: _contentController,
              maxLines: 10,
              decoration: const InputDecoration(
                hintText: 'What\'s on your mind?',
                border: InputBorder.none,
              ),
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),

            // Selected Images Preview
            if (_selectedImages.isNotEmpty) ...[
              const Text(
                'Selected Images',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedImages.length,
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey[300],
                          ),
                          child: const Icon(Icons.image, size: 50),
                        ),
                        Positioned(
                          top: 4,
                          right: 12,
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.black54,
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(24, 24),
                            ),
                            onPressed: () {
                              setState(() {
                                _selectedImages.removeAt(index);
                              });
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Location
            if (_location != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(_location!),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        setState(() => _location = null);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            const Divider(),

            // Post Type Selection
            const Text(
              'Post Type',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: PostType.values.map((type) {
                return ChoiceChip(
                  label: Text(type.name),
                  selected: _selectedType == type,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedType = type);
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            const Divider(),

            // Media Options
            const Text(
              'Add to Post',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMediaButton(
                    icon: Icons.photo,
                    label: 'Photo',
                    color: Colors.green,
                    onTap: _pickImages,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMediaButton(
                    icon: Icons.videocam,
                    label: 'Video',
                    color: Colors.red,
                    onTap: _pickVideos,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildMediaButton(
                    icon: Icons.location_on,
                    label: 'Location',
                    color: Colors.blue,
                    onTap: _addLocation,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMediaButton(
                    icon: Icons.tag,
                    label: 'Tag People',
                    color: Colors.purple,
                    onTap: _tagPeople,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildMediaButton(
                    icon: Icons.poll,
                    label: 'Poll',
                    color: Colors.orange,
                    onTap: _createPoll,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMediaButton(
                    icon: Icons.emoji_emotions,
                    label: 'Feeling',
                    color: Colors.yellow.shade700,
                    onTap: _addFeeling,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 8),
            Text(label),
          ],
        ),
      ),
    );
  }

  IconData _getVisibilityIcon(PostVisibility visibility) {
    switch (visibility) {
      case PostVisibility.public:
        return Icons.public;
      case PostVisibility.friends:
        return Icons.people;
      case PostVisibility.private:
        return Icons.lock;
    }
  }

  void _pickImages() {
    // TODO: Implement image picker
    setState(() {
      _selectedImages.add('placeholder_image.jpg');
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Image picker not implemented yet')),
    );
  }

  void _pickVideos() {
    // TODO: Implement video picker
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Video picker not implemented yet')),
    );
  }

  void _addLocation() {
    // TODO: Implement location picker
    setState(() {
      _location = 'New York, NY';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Location picker not implemented yet')),
    );
  }

  void _tagPeople() {
    // TODO: Implement people tagging
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('People tagging not implemented yet')),
    );
  }

  void _createPoll() {
    // TODO: Implement poll creation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Poll creation not implemented yet')),
    );
  }

  void _addFeeling() {
    // TODO: Implement feeling/activity
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Feeling/activity not implemented yet')),
    );
  }

  Future<void> _createPost() async {
    final content = _contentController.text.trim();

    if (content.isEmpty && _selectedImages.isEmpty && _selectedVideos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post cannot be empty')),
      );
      return;
    }

    setState(() => _isPosting = true);

    try {
      // In production: call _socialService.createPost()
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post created successfully!')),
        );
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create post: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPosting = false);
      }
    }
  }
}
