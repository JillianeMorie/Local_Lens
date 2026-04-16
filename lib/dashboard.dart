import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
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

      body: Container(
        color: Colors.grey[100],
        child: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: 5,
          itemBuilder: (context, index) {
            return _buildPostCard();
          },
        ),
      ),

      // ⭐ ONLY PINK CAMERA ICON (NO ACTION)
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.pinkAccent,
        child: const Icon(Icons.camera_alt, color: Colors.white),
        onPressed: () {}, // intentionally empty
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildPostCard() {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      clipBehavior: Clip.antiAlias,
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

          Image.network(
            'https://picsum.photos/400/200',
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
          ),

          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Check out this amazing hidden spot I found today! #LocalLens",
                  style: TextStyle(fontSize: 15, color: Colors.black87),
                ),
                SizedBox(height: 15),
                Row(
                  children: [
                    Icon(
                      Icons.favorite_border,
                      color: Colors.pinkAccent,
                      size: 20,
                    ),
                    SizedBox(width: 5),
                    Text(
                      "12 likes",
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    SizedBox(width: 25),
                    Icon(Icons.comment_outlined, color: Colors.grey, size: 20),
                    SizedBox(width: 5),
                    Text(
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
