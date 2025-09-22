import 'package:messease/screens/home.dart';
import 'package:messease/screens/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  String email = "",
      password = "",
      name = "",
      role = "student",
      rollNumber = "";
  TextEditingController namecontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();
  TextEditingController mailcontroller = TextEditingController();
  TextEditingController rollNumberController = TextEditingController();
  final _formkey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> registration() async {
    if (!_formkey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      email = mailcontroller.text;
      name = namecontroller.text;
      password = passwordcontroller.text;
      rollNumber = rollNumberController.text;
    });

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      await userCredential.user?.updateDisplayName(name);

      Map<String, dynamic> userData = {
        'name': name,
        'email': email,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      };

      if (role == 'student') {
        userData['rollNumber'] = rollNumber;
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(userData);

      _showSuccessSnackbar(
          "Registered Successfully! Welcome to the Hostel Mess");

      if (mounted) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => Home()));
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = e.code == 'weak-password'
          ? "Password must be at least 6 characters"
          : e.code == "email-already-in-use"
              ? "Account already exists"
              : "Registration error: ${e.message}";

      _showErrorSnackbar(errorMessage);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Color(0xFF2ECC71),
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 10),
            Text(message, style: TextStyle(color: Colors.white)),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Color(0xFFE74C3C),
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white),
            SizedBox(width: 10),
            Text(message, style: TextStyle(color: Colors.white)),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
            padding: EdgeInsets.all(24),
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
                  SizedBox(height: 20),
                  Text(
                    "Create Account",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Join us to get started",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 32),

                  // Name Field
                  _buildTextField(
                    controller: namecontroller,
                    icon: Icons.person_outline,
                    label: "Full Name",
                    validator: (value) => value?.isEmpty ?? true
                        ? 'Please enter your name'
                        : null,
                  ),
                  SizedBox(height: 16),

                  // Email Field
                  _buildTextField(
                    controller: mailcontroller,
                    icon: Icons.email_outlined,
                    label: "Email Address",
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Please enter email' : null,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: 16),

                  // Password Field
                  _buildTextField(
                    controller: passwordcontroller,
                    icon: Icons.lock_outline,
                    label: "Password",
                    validator: (value) => value?.isEmpty ?? true
                        ? 'Please enter password'
                        : value!.length < 6
                            ? 'Password must be 6+ characters'
                            : null,
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.white70,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
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
                        prefixIcon:
                            Icon(Icons.person_outline, color: Colors.white),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                        labelText: "Select Role",
                        labelStyle: TextStyle(color: Colors.white70),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 'student',
                          child: Text('Student',
                              style: TextStyle(color: Colors.white)),
                        ),
                        DropdownMenuItem(
                          value: 'admin',
                          child: Text('Admin',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ],
                      onChanged: (value) => setState(() {
                        role = value!;
                        if (role != 'student') {
                          rollNumberController.clear();
                        }
                      }),
                      validator: (value) =>
                          value == null ? 'Please select role' : null,
                    ),
                  ),
                  if (role == 'student') ...[
                    SizedBox(height: 16),
                    _buildTextField(
                      controller: rollNumberController,
                      icon: Icons.numbers,
                      label: "Roll Number",
                      validator: (value) => value?.isEmpty ?? true
                          ? 'Please enter roll number'
                          : null,
                    ),
                  ],
                  SizedBox(height: 32),

                  // Sign Up Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : registration,
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
                              "SIGN UP",
                              style: TextStyle(
                                color: Color(0xFF1A2980),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: 24),

                  // Login Prompt
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LogIn()),
                      ),
                      child: RichText(
                        text: TextSpan(
                          text: "Already have an account? ",
                          style: TextStyle(color: Colors.white70),
                          children: [
                            TextSpan(
                              text: "Login",
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

  Widget _buildTextField({
    required TextEditingController controller,
    required IconData icon,
    required String label,
    String? Function(String?)? validator,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: Icon(icon, color: Colors.white),
          labelText: label,
          labelStyle: TextStyle(color: Colors.white70),
          suffixIcon: suffixIcon,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        validator: validator,
      ),
    );
  }
}
