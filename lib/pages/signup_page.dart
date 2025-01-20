import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:reslocate/pages/verify_email.dart';
import 'package:reslocate/pages/login_page.dart';
import 'package:reslocate/widgets/mytoast.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

enum UserRole {
  learner,
  parent,
}

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  SignupPageState createState() => SignupPageState();
}

class SignupPageState extends State<SignupPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _supabase = Supabase.instance.client;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _acceptedPrivacyPolicy = false;
  UserRole _selectedRole = UserRole.learner;

  Future<void> _launchPrivacyPolicy() async {
    final Uri url = Uri.parse('https://reslocate.net/privacy.html');
    if (!await launchUrl(url)) {
      if (mounted) {
        MyToast.showToast(context, 'Could not open privacy policy');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/images/reslocate_logo_name.svg',
                  height: 50,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Create a new account',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D47A1),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Jump in and start your journey today!',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                // Email field
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon:
                        const Icon(Icons.email, color: Color(0xFF0D47A1)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF0D47A1),
                        width: 1.5,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.black26,
                        width: 1,
                      ),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                _buildRoleSelection(),
                const SizedBox(height: 16),
                // Password field
                TextField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon:
                        const Icon(Icons.lock, color: Color(0xFF0D47A1)),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: const Color(0xFF0D47A1),
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF0D47A1),
                        width: 1.5,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.black26,
                        width: 1,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Confirm Password field
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: !_isConfirmPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    prefixIcon:
                        const Icon(Icons.lock, color: Color(0xFF0D47A1)),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isConfirmPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: const Color(0xFF0D47A1),
                      ),
                      onPressed: () {
                        setState(() {
                          _isConfirmPasswordVisible =
                              !_isConfirmPasswordVisible;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF0D47A1),
                        width: 1.5,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.black26,
                        width: 1,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Privacy Policy Checkbox and Link
                Row(
                  children: [
                    Checkbox(
                      value: _acceptedPrivacyPolicy,
                      onChanged: (value) {
                        setState(() {
                          _acceptedPrivacyPolicy = value ?? false;
                        });
                      },
                      activeColor: const Color(0xFF0D47A1),
                    ),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(color: Colors.black),
                          children: [
                            const TextSpan(text: 'I agree to the '),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: const TextStyle(
                                color: Color(0xFF0D47A1),
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = _launchPrivacyPolicy,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _acceptedPrivacyPolicy ? _signUp : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor:
                        _acceptedPrivacyPolicy ? Colors.blue[900] : Colors.grey,
                  ),
                  child: const SizedBox(
                    width: double.infinity,
                    child: Center(
                      child: Text(
                        'Sign Up',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account?'),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginPage()),
                        );
                      },
                      child: const Text(
                        'Log In',
                        style: TextStyle(
                          color: Color(0xFF0D47A1),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleSelection() {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.black26),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 12.0, top: 8.0),
              child: Text(
                'I am a:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D47A1),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<UserRole>(
                    title: const Text('Learner'),
                    value: UserRole.learner,
                    groupValue: _selectedRole,
                    activeColor: const Color(0xFF0D47A1),
                    onChanged: (UserRole? value) {
                      setState(() {
                        _selectedRole = value!;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<UserRole>(
                    title: const Text('Parent'),
                    value: UserRole.parent,
                    groupValue: _selectedRole,
                    activeColor: const Color(0xFF0D47A1),
                    onChanged: (UserRole? value) {
                      setState(() {
                        _selectedRole = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  bool _isValidEmail(String email) {
    final emailRegExp = RegExp(r"^[a-zA-Z0-9._]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    return emailRegExp.hasMatch(email);
  }

  bool _isValidPassword(String password) {
    return password.length >= 6 && password.contains(RegExp(r'[A-Za-z]'));
  }

  Future<void> _signUp() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (!_isValidEmail(email)) {
      MyToast.showToast(context, 'Please enter a valid email');
      return;
    }

    if (!_isValidPassword(password)) {
      MyToast.showToast(context,
          'Password must be at least 6 characters long and contain a letter');
      return;
    }

    if (password != confirmPassword) {
      MyToast.showToast(context, 'Passwords do not match');
      return;
    }

    try {
      // Sign up with additional user metadata
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'role': _selectedRole.toString().split('.').last,
          'is_parent': _selectedRole == UserRole.parent,
        },
      );

      if (response.user != null && mounted) {
        // Create initial profile in the profiles table
        try {
          await _supabase.from('profiles').upsert({
            'id': response.user!.id,
            'role': _selectedRole.toString().split('.').last,
            'is_parent': _selectedRole == UserRole.parent,
            'updated_at': DateTime.now().toIso8601String(),
          });

          // Create career guidance response entry if user is a learner
          if (_selectedRole == UserRole.learner) {
            await _supabase.from('career_guidance_responses').insert({
              'user_id': response.user!.id,
              'updated_at': DateTime.now().toIso8601String(),
            });
          }

          MyToast.showToast(context, 'Account created successfully!');
          MyToast.showToast(context, 'Please verify your email');

          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage2()),
          );
        } catch (profileError) {
          // Handle profile creation error
          print('Error creating profile: $profileError');
          MyToast.showToast(context,
              'Account created but profile setup failed. Please contact support.');
        }
      }
    } on AuthException catch (e) {
      if (e.statusCode == '23505') {
        MyToast.showToast(context, 'Email is already registered');
      } else if (e.message.contains('invalid_email')) {
        MyToast.showToast(context, 'Invalid email address');
      } else if (e.message.contains('weak_password')) {
        MyToast.showToast(
            context, 'Weak password: Please use a stronger password');
      } else {
        MyToast.showToast(context, e.message); // Show specific error message
      }
    } catch (e) {
      print('Signup error: $e');
      MyToast.showToast(
          context, 'An unexpected error occurred. Please try again later.');
    }
  }
}
