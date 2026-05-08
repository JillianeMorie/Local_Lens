import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // 1. Add this import
import 'profile.dart';
import 'create_post.dart';
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    }
  }

  void _toggleLike(String postId, List<dynamic> currentLikes) async {
    final String? currentUserId = FirebaseAuth.instance.currentUser!.email;
    final DocumentReference postRef = FirebaseFirestore.instance.collection('posts').doc(postId);

    if (currentLikes.contains(currentUserId)) {
      // User already liked it, so "unlike" it
      await postRef.update({
        'likes': FieldValue.arrayRemove([currentUserId])
      });
    } else {
      // User hasn't liked it, so "like" it
      await postRef.update({
        'likes': FieldValue.arrayUnion([currentUserId])
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.person, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfilePage()),
            );
          },
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.pinkAccent, Colors.greenAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          'LocalLens Feed',
          style: TextStyle(
            fontFamily: 'Cursive',
            fontWeight: FontWeight.bold,
            fontSize: 28,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      // 2. Wrap the body in a StreamBuilder
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .orderBy('createdAt', descending: true) // Newest posts first
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Something went wrong"));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final posts = snapshot.data?.docs ?? [];

          if (posts.isEmpty) {
            return const Center(child: Text("No posts yet. Be the first!"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              // Extract data from document
              final data = posts[index].data() as Map<String, dynamic>;
              final String postId = posts[index].id;
              return _buildPostCard(data, postId);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.pinkAccent,
        child: const Icon(Icons.camera_alt, color: Colors.white),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreatePostPage()),
          );
        },
      ),
    );
  }

  // 3. Updated to accept data Map
  Widget _buildPostCard(Map<String, dynamic> data , String postId) {
  final String currentUserId = FirebaseAuth.instance.currentUser?.email ?? "";
  final List<dynamic> likes = data['likes'] ?? [];
  final bool isLiked = likes.contains(currentUserId);
    // Formatting the timestamp
    final Timestamp? timestamp = data['createdAt'] as Timestamp?;
    final String timeAgo = timestamp != null 
        ? "${DateTime.now().difference(timestamp.toDate()).inMinutes}m ago" 
        : "Just now";

    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      clipBehavior: Clip.antiAlias,
      elevation: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.greenAccent,
              child: Icon(Icons.person, color: Colors.white),
            ),
            title: Text(
              data['author'] ?? "Unknown Author",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text("$timeAgo • Near you"),
          ),

          // 4. Conditional Image logic
          if ((data['imageUrl'] is String) &&
              (data['imageUrl'] as String).startsWith('http'))
            Image.network(
              data['imageUrl'],
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 100,
                color: Colors.grey[300],
                child: const Icon(Icons.broken_image, color: Colors.grey),
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
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        color: isLiked ? Colors.pinkAccent : Colors.grey,
                      ),
                      onPressed: () => _toggleLike(postId, likes),
                    ),
                    SizedBox(width: 5),
                    Text("${likes.length} likes", style: TextStyle(fontWeight: FontWeight.w500)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
