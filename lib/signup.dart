import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  // Controllers to capture text input
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  // Firebase Registration Logic
  Future<void> _register() async {
    // Basic validation
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Create the user in Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser?.uid).set({
        'email': _emailController.text.trim(),
        'password': _passwordController.text.trim(),
        'username': _usernameController.text.trim(),
        'uid': FirebaseAuth.instance.currentUser?.email,
      });

      // Note: If you want to store the "Username", you will need to save it to 
      // Firestore or Realtime Database, as Firebase Auth only has a single Display Name field.

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account Created Successfully! You can now log in.')),
        );
        Navigator.pop(context); // Navigate back to the Login Page
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        // Show Firebase error messages (e.g., weak password, email already in use)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Registration failed. Please try again.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    // Clean up controllers when the widget is removed
    _fullNameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.pinkAccent, Colors.greenAccent],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // --- THE ARCHED TITLE WITH FLOWERS ---
                Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      top: -45,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            Icons.local_florist,
                            color: Colors.white70,
                            size: 28,
                          ),
                          SizedBox(width: 12),
                          Padding(
                            padding: EdgeInsets.only(bottom: 18),
                            child: Icon(
                              Icons.filter_vintage,
                              color: Colors.white,
                              size: 38,
                            ),
                          ),
                          SizedBox(width: 12),
                          Icon(
                            Icons.local_florist,
                            color: Colors.white70,
                            size: 28,
                          ),
                        ],
                      ),
                    ),
                    const Text(
                      'LocalLens',
                      style: TextStyle(
                        fontFamily: 'Cursive',
                        fontSize: 55,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            blurRadius: 15,
                            color: Colors.black12,
                            offset: Offset(2, 4),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // --- USER DETAILS FORM ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 45),
                  child: Column(
                    children: [
                      _buildTextField("Full Name", _fullNameController),
                      _buildTextField("Email Address", _emailController, isEmail: true),
                      _buildTextField("Username", _usernameController),
                      _buildTextField("Password (min 6 chars)", _passwordController, isObscure: true),

                      const SizedBox(height: 30),

                      // Create Account Button
                      _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : _buildActionButton(
                              label: "Create Account",
                              textColor: Colors.green,
                              onPressed: _register,
                            ),

                      const SizedBox(height: 15),

                      // Login Button (to go back)
                      _buildActionButton(
                        label: "Login",
                        textColor: Colors.pinkAccent,
                        onPressed: () {
                          Navigator.pop(context); // Goes back to the main page
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper for consistent rectangular text inputs
  Widget _buildTextField(String hint, TextEditingController controller, {bool isObscure = false, bool isEmail = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: isObscure,
        keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
        ),
      ),
    );
  }

  // Helper for consistent buttons
  Widget _buildActionButton({
    required String label,
    required Color textColor,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: textColor,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 5,
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
