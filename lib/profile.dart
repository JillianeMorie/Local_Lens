import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final user = FirebaseAuth.instance.currentUser;

  File? _image;
  File? _profileImage;
  String? _profileImageUrl;
  String? _profileUsername;
  String? _imageUrl;

  final picker = ImagePicker();
  final TextEditingController _captionController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    loadProfileImage();
    loadProfileUsername();
  }

  // ---------------- PROFILE IMAGE ----------------
  Future<void> pickProfileImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() => _profileImage = File(picked.path));
      await uploadProfileImage();
    }
  }

  Future<void> uploadProfileImage() async {
    if (_profileImage == null || user == null) return;

    final ref = FirebaseStorage.instance
        .ref()
        .child('profile_pictures')
        .child('${user!.uid}.jpg');

    await ref.putFile(_profileImage!);
    final url = await ref.getDownloadURL();

    setState(() => _profileImageUrl = url);

    await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
      'profileImage': url,
    }, SetOptions(merge: true));
  }

  Future<void> loadProfileImage() async {
    if (user == null) return;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();

    if (doc.exists && doc.data()!.containsKey('profileImage')) {
      setState(() {
        _profileImageUrl = doc['profileImage'];
      });
    }
  }
    Future<void> loadProfileUsername() async {
    if (user == null) return;
    try{
      final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: user?.email)
        .get();

      if (querySnapshot.docs.isNotEmpty) {
        // 3. Access the first document found
        var userDoc = querySnapshot.docs.first;
        Map<String, dynamic> userData = userDoc.data();
        setState(() {
        _profileUsername = userData['username'];
        });
      }else {
        print("No user found with the exact username: ${user?.email}");
      }
    }catch (e) {
    print("Error fetching user: $e");
    }
  }

  // ---------------- PICK POST IMAGE ----------------
  Future<void> pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() => _image = File(picked.path));
    }
  }

  // ---------------- UPLOAD POST ----------------
  Future<void> uploadPost() async {
    if (_image == null && _captionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Add image and caption")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      _imageUrl = null;
      if (_image != null) {
        final ref = FirebaseStorage.instance
            .ref()
            .child('posts')
            .child(user!.uid)
            .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

        await ref.putFile(_image!);
        _imageUrl = await ref.getDownloadURL();
      }
      await FirebaseFirestore.instance.collection('posts').add({
        'author': _profileUsername ?? user?.email ?? "Anonymous",
        'caption': _captionController.text.trim(),
        'imageUrl': _imageUrl,
        'userId': user?.uid,
        'likes': <String>[],
        'createdAt': Timestamp.now(),
      });

      setState(() {
        _image = null;
        _captionController.clear();
      });

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Post uploaded!")));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  String _formatTimestamp(Timestamp timestamp) {
    final now = DateTime.now();
    final postTime = timestamp.toDate();
    final diff = now.difference(postTime);

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} minutes ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return DateFormat('MMM d, yyyy').format(postTime);
  }

  // ---------------- MOCK POST CARD ----------------
  Widget _buildMockPostCard(int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      clipBehavior: Clip.antiAlias,
      elevation: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.greenAccent,
              backgroundImage: _profileImageUrl != null
                  ? NetworkImage(_profileImageUrl!)
                  : null,
              child: _profileImageUrl == null
                  ? const Icon(Icons.person, color: Colors.white)
                  : null,
            ),
            title: Text(
              user?.displayName ?? "You",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text("${index + 1} days ago"),
          ),
          Image.network(
            'https://picsum.photos/400/200?random=$index',
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              height: 200,
              color: Colors.grey[300],
              child: const Icon(Icons.broken_image, size: 50),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "This is my mock post #$index from my profile! #LocalLens",
                  style: const TextStyle(fontSize: 15, color: Colors.black87),
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    const Icon(
                      Icons.favorite_border,
                      color: Colors.pinkAccent,
                      size: 20,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      "${index + 5} likes",
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(width: 25),
                    const Icon(
                      Icons.comment_outlined,
                      color: Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      "${index + 1} comments",
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- REAL POST CARD ----------------
  Widget _buildPostCard(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final Timestamp timestamp = data['createdAt'] ?? Timestamp.now();

    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      clipBehavior: Clip.antiAlias,
      elevation: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.greenAccent,
              backgroundImage: _profileImageUrl != null
                  ? NetworkImage(_profileImageUrl!)
                  : null,
              child: _profileImageUrl == null
                  ? const Icon(Icons.person, color: Colors.white)
                  : null,
            ),
            title: Text(
              data['author'] ?? "You",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(_formatTimestamp(timestamp)),
          ),
          if ((data['imageUrl'] is String) &&
              (data['imageUrl'] as String).isNotEmpty)
            Image.network(
              data['imageUrl'],
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 200,
                color: Colors.grey[300],
                child: const Icon(Icons.broken_image, size: 50),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['caption'] ?? "",
                  style: const TextStyle(fontSize: 15, color: Colors.black87),
                ),
                const SizedBox(height: 15),
                const Row(
                  children: [
                    Icon(
                      Icons.favorite_border,
                      color: Colors.pinkAccent,
                      size: 20,
                    ),
                    SizedBox(width: 5),
                    Text(
                      "0 likes",
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    SizedBox(width: 25),
                    Icon(Icons.comment_outlined, color: Colors.grey, size: 20),
                    SizedBox(width: 5),
                    Text(
                      "0 comments",
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ---------------- HEADER ----------------
            Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 180,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.pinkAccent, Colors.greenAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),

                // BACK ARROW
                Positioned(
                  top: MediaQuery.of(context).padding.top + 8,
                  left: 8,
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),

                // PROFILE PICTURE (CLICKABLE)
                Positioned(
                  bottom: -55,
                  child: GestureDetector(
                    onTap: pickProfileImage,
                    child: CircleAvatar(
                      radius: 58,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 54,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: _profileImageUrl != null
                            ? NetworkImage(_profileImageUrl!)
                            : null,
                        child: _profileImageUrl == null
                            ? const Icon(
                                Icons.add_a_photo,
                                size: 40,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 70),

            // ---------------- USER INFO ----------------
            Text(
              _profileUsername ?? "",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            Text(user?.email ?? "", style: const TextStyle(color: Colors.grey)),

            const SizedBox(height: 25),

            // ---------------- CREATE POST CARD ----------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Create a Post",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // IMAGE PREVIEW
                    _image != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              _image!,
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Container(
                            height: 180,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.grey[200],
                            ),
                            child: const Center(
                              child: Text("No image selected"),
                            ),
                          ),

                    const SizedBox(height: 10),

                    // PICK IMAGE BUTTON
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.greenAccent,
                        foregroundColor: Colors.black,
                      ),
                      icon: const Icon(Icons.photo),
                      onPressed: pickImage,
                      label: const Text("Choose Image"),
                    ),

                    // CAPTION
                    TextField(
                      controller: _captionController,
                      decoration: const InputDecoration(
                        hintText: "Write a caption...",
                      ),
                    ),

                    const SizedBox(height: 15),

                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.pinkAccent,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 45),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: uploadPost,
                            child: const Text("Post"),
                          ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            // ---------------- USER POSTS SECTION ----------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "My Posts",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  // StreamBuilder for real posts
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('posts')
                        .where('userId', isEqualTo: user?.uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      // If no real posts, show 3 mock posts
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Column(
                          children: List.generate(
                            3,
                            (index) => _buildMockPostCard(index),
                          ),
                        );
                      }

                      // Show real posts sorted latest first without requiring composite index.
                      final docs = List<DocumentSnapshot>.from(snapshot.data!.docs)
                        ..sort((a, b) {
                          final aMap = a.data() as Map<String, dynamic>;
                          final bMap = b.data() as Map<String, dynamic>;
                          final aTime =
                              (aMap['createdAt'] as Timestamp?)?.toDate() ??
                                  DateTime.fromMillisecondsSinceEpoch(0);
                          final bTime =
                              (bMap['createdAt'] as Timestamp?)?.toDate() ??
                                  DateTime.fromMillisecondsSinceEpoch(0);
                          return bTime.compareTo(aTime);
                        });

                      return Column(
                        children: docs.map((doc) => _buildPostCard(doc)).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }
}
