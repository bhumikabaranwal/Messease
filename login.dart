import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:messease/screens/home.dart';
import 'package:messease/screens/forgotpassword.dart';
import 'package:messease/screens/signup.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LogIn extends StatefulWidget {
  const LogIn({super.key});

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  String email = "", password = "", role = "student";
  final _formkey = GlobalKey<FormState>();
  TextEditingController useremailcontroller = TextEditingController();
  TextEditingController userpasswordcontroller = TextEditingController();
  bool _isLoading = false;

  userLogin() async {
    if (!_formkey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
      email = useremailcontroller.text;
      password = userpasswordcontroller.text;
    });

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        if (userData['role'] != role) {
          await FirebaseAuth.instance.signOut();
          _showErrorSnackbar("Invalid role selected. Please select the correct role.");
          return;
        }
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Home()));
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = e.code == 'user-not-found' 
          ? "No user found with this email address" 
          : e.code == 'wrong-password' 
              ? "Incorrect password, please try again" 
              : "Login error: ${e.message}";

      _showErrorSnackbar(errorMessage);

      if (e.code == 'wrong-password') {
        userpasswordcontroller.clear();
        setState(() => password = "");
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Color(0xFFE63946),
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white),
            SizedBox(width: 10),
            Expanded(child: Text(message, style: TextStyle(color: Colors.white))),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.all(10),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A2980), // Dark blue
              Color(0xFF26D0CE), // Teal
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Form(
              key: _formkey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Image.asset(
                      'assets/image.png', // Update with your logo
                      height: 100,
                    ),
                  ),
                  SizedBox(height: 30),
                  Text(
                    "Welcome Back",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Sign in to continue",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 40),
                  
                  // Email Field
                  _buildInputField(
                    controller: useremailcontroller,
                    icon: Icons.email_outlined,
                    hintText: "Email",
                    validator: (value) => value?.isEmpty ?? true ? 'Please enter email' : null,
                  ),
                  SizedBox(height: 16),
                  
                  // Password Field
                  _buildInputField(
                    controller: userpasswordcontroller,
                    icon: Icons.lock_outline,
                    hintText: "Password",
                    obscureText: true,
                    validator: (value) => value?.isEmpty ?? true ? 'Please enter password' : null,
                  ),
                  SizedBox(height: 16),
                  
                  // Role Dropdown
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: DropdownButtonFormField<String>(
                      value: role,
                      dropdownColor: Color(0xFF1A2980),
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.person_outline, color: Colors.white),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 'student',
                          child: Text('Student', style: TextStyle(color: Colors.white)),
                        ),
                        DropdownMenuItem(
                          value: 'admin',
                          child: Text('Admin', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                      onChanged: (value) => setState(() => role = value!),
                    ),
                  ),
                  SizedBox(height: 8),
                  
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ForgotPassword())),
                      child: Text(
                        "Forgot Password?",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  
                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : userLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? CircularProgressIndicator(color: Color(0xFF1A2980))
                          : Text(
                              "LOG IN",
                              style: TextStyle(
                                color: Color(0xFF1A2980),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: 24),
                  
                  // Sign Up Prompt
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SignUp())),
                      child: RichText(
                        text: TextSpan(
                          text: "Don't have an account? ",
                          style: TextStyle(color: Colors.white70),
                          children: [
                            TextSpan(
                              text: "Sign Up",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required IconData icon,
    required String hintText,
    String? Function(String?)? validator,
    bool obscureText = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: TextFormField(
        controller: controller,
        validator: validator,
        obscureText: obscureText,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: Icon(icon, color: Colors.white),
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.white70),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}