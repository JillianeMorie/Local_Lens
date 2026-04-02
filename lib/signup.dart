import 'package:flutter/material.dart';

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

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
                      _buildTextField("Full Name"),
                      _buildTextField("Email Address"),
                      _buildTextField("Username"),
                      _buildTextField("Password", isObscure: true),

                      const SizedBox(height: 30),

                      // Create Account Button
                      _buildActionButton(
                        label: "Create Account",
                        textColor: Colors.green,
                        onPressed: () {
                          // Add your registration logic here
                        },
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
  Widget _buildTextField(String hint, {bool isObscure = false}) {
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
        obscureText: isObscure,
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
