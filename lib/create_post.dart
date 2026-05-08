import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

const String _storageBucket = 'local-lens-82877.appspot.com';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  File? _image;
  final picker = ImagePicker();
  final TextEditingController _captionController = TextEditingController();
  bool _isLoading = false;

  Future<void> pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        _image = File(picked.path);
      });
    }
  }

  Future<void> uploadPost() async {
    if (_image == null && _captionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Add image and caption")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("You must be logged in to post.")),
        );
        return;
      }

      String? imageUrl;
      if (_image != null) {
        // Upload image only when a file is selected.
        final ref = FirebaseStorage.instanceFor(bucket: _storageBucket)
            .ref()
            .child('posts')
            .child(user.uid)
            .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

        await ref.putFile(_image!);
        imageUrl = await ref.getDownloadURL();
      }

      // Save post data to Firestore.
      await FirebaseFirestore.instance.collection('posts').add({
        'author': user.displayName ?? user.email ?? "Anonymous",
        'caption': _captionController.text.trim(),
        'imageUrl': imageUrl,
        'userId': user.uid,
        'likes': <String>[],
        'createdAt': Timestamp.now(),
      });

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      final message = e.toString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message.contains('StorageException')
                ? 'Image upload failed. Check Firebase Storage bucket and rules in Firebase Console.'
                : "Error: $e",
          ),
        ),
      );
    }

    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Post")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _image != null
                ? Image.file(_image!, height: 200)
                : const Text("No image selected"),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: pickImage,
              child: const Text("Pick Image"),
            ),

            TextField(
              controller: _captionController,
              decoration: const InputDecoration(hintText: "Write a caption..."),
            ),

            const SizedBox(height: 20),

            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: uploadPost,
                    child: const Text("Upload Post"),
                  ),
          ],
        ),
      ),
    );
  }
}
