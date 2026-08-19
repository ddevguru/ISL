import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';
import 'home_screen.dart';

class AuthScreenImproved extends StatefulWidget {
  @override
  _AuthScreenImprovedState createState() => _AuthScreenImprovedState();
}

class _AuthScreenImprovedState extends State<AuthScreenImproved> {
  bool isLogin = true;
  bool isLoading = false;
  bool showPassword = false;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    usernameController.dispose();
    firstNameController.dispose();
    super.dispose();
  }

  Future<void> signup() async {
    if (usernameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty) {
      _showSnackBar('सभी फील्ड भरें', Colors.red);
      return;
    }

    if (passwordController.text.length < 8) {
      _showSnackBar('Password कम से कम 8 characters का होना चाहिए', Colors.red);
      return;
    }

    setState(() => isLoading = true);

    try {
      print('Signup करने की कोशिश: ${usernameController.text}');
      print('Backend URL: ${ApiConfig.signupEndpoint}');

      final response = await http
          .post(
            Uri.parse(ApiConfig.signupEndpoint),
            headers: ApiConfig.defaultHeaders,
            body: jsonEncode({
              'username': usernameController.text,
              'email': emailController.text,
              'password': passwordController.text,
              'first_name': firstNameController.text,
            }),
          )
          .timeout(Duration(seconds: 10));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        await _saveToken(data['access_token']);

        _showSnackBar('✅ Signup सफल!', Colors.green);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else {
        final error = jsonDecode(response.body);
        _showSnackBar('❌ ${error['error'] ?? 'Signup failed'}', Colors.red);
      }
    } catch (e) {
      print('Error: $e');
      _showSnackBar('❌ Error: $e', Colors.red);
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      _showSnackBar('Email और Password भरें', Colors.red);
      return;
    }

    setState(() => isLoading = true);

    try {
      print('Login करने की कोशिश: ${emailController.text}');
      print('Backend URL: ${ApiConfig.loginEndpoint}');

      final response = await http
          .post(
            Uri.parse(ApiConfig.loginEndpoint),
            headers: ApiConfig.defaultHeaders,
            body: jsonEncode({
              'username_or_email': emailController.text,
              'password': passwordController.text,
            }),
          )
          .timeout(Duration(seconds: 10));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _saveToken(data['access_token']);

        _showSnackBar('✅ Login सफल!', Colors.green);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else {
        final error = jsonDecode(response.body);
        _showSnackBar('❌ ${error['error'] ?? 'Login failed'}', Colors.red);
      }
    } catch (e) {
      print('Error: $e');
      _showSnackBar('❌ Connection Error: $e', Colors.red);
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _saveToken(String token) async {
    ApiConfig.authToken = token;
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 30),

                // 🎨 Header
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '🤟',
                        style: TextStyle(fontSize: 50),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Sign Language\nDetection',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30),

                // 📧 Email Field
                buildTextField(
                  controller: emailController,
                  label: isLogin ? 'Email या Username' : 'Email',
                  icon: Icons.email,
                  hint: isLogin ? 'user@example.com' : 'your@email.com',
                ),
                SizedBox(height: 15),

                // 👤 Username (Signup only)
                if (!isLogin)
                  Column(
                    children: [
                      buildTextField(
                        controller: usernameController,
                        label: 'Username',
                        icon: Icons.person,
                        hint: 'username',
                      ),
                      SizedBox(height: 15),
                    ],
                  ),

                // 📝 First Name (Signup only)
                if (!isLogin)
                  Column(
                    children: [
                      buildTextField(
                        controller: firstNameController,
                        label: 'First Name',
                        icon: Icons.person_outline,
                        hint: 'John',
                      ),
                      SizedBox(height: 15),
                    ],
                  ),

                // 🔐 Password Field
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: passwordController,
                    obscureText: !showPassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: '••••••••',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: Icon(Icons.lock, color: Colors.deepPurple),
                      suffixIcon: GestureDetector(
                        onTap: () {
                          setState(() => showPassword = !showPassword);
                        },
                        child: Icon(
                          showPassword ? Icons.visibility : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                  ),
                ),
                SizedBox(height: 25),

                // 🔘 Login/Signup Button
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : (isLogin ? login : signup),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      disabledBackgroundColor: Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isLoading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            isLogin ? 'Login' : 'Signup',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                SizedBox(height: 20),

                // 🔄 Toggle
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isLogin ? 'नया user? ' : 'पहले से account है? ',
                      style: TextStyle(fontSize: 14),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isLogin = !isLogin;
                          emailController.clear();
                          passwordController.clear();
                          usernameController.clear();
                          firstNameController.clear();
                          showPassword = false;
                        });
                      },
                      child: Text(
                        isLogin ? 'Signup करें' : 'Login करें',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.deepPurple,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),

                // ℹ️ Info Box
                SizedBox(height: 25),
                Container(
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '📌 Backend Connection Info:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[900],
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Backend: ${ApiConfig.baseUrl}',
                        style: TextStyle(fontSize: 12),
                      ),
                      Text(
                        'Make sure:\n• Backend is running\n• Phone on same WiFi\n• IP is correct (192.168.0.132)',
                        style: TextStyle(fontSize: 12),
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

  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          prefixIcon: Icon(icon, color: Colors.deepPurple),
          filled: true,
          fillColor: Colors.grey[100],
        ),
      ),
    );
  }
}
