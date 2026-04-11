import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  // Logout Function
  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      // Navigate back to Login and remove all previous screens from the stack
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
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
            onPressed: () {
              // TODO: Navigation to Notifications Screen
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => _logout(context),
          ),
        ],
      ),

      body: Container(
        color: Colors.grey[100],
        child: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: 5, // Replace with StreamBuilder<QuerySnapshot> later
          itemBuilder: (context, index) {
            return _buildPostCard();
          },
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.pinkAccent,
        elevation: 4,
        child: const Icon(Icons.add_a_photo, color: Colors.white),
        onPressed: () {
          // TODO: Navigate to Create Post Screen
        },
      ),
    );
  }

  Widget _buildPostCard() {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      clipBehavior: Clip.antiAlias, // Ensures image corners are rounded
      elevation: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.greenAccent,
              child: Icon(Icons.person, color: Colors.white),
            ),
            title: Text(
              "Local Explorer",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text("2 minutes ago • Near you"),
          ),

          // Image Area
          Image.network(
            'https://picsum.photos/400/200', // Dynamic placeholder
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
                const Text(
                  "Check out this amazing hidden spot I found today! #LocalLens",
                  style: TextStyle(fontSize: 15, color: Colors.black87),
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
                    const Text(
                      "12 likes",
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(width: 25),
                    const Icon(
                      Icons.comment_outlined,
                      color: Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      "3 comments",
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
}
