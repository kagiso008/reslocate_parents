import 'package:reslocate/main.dart' show ContextExtension, supabase;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:reslocate/pages/careerAspirations.dart';
import 'package:reslocate/pages/parent_pages/studentDetails.dart';
import 'package:reslocate/widgets/mytoast.dart';

class ParentAccount extends StatefulWidget {
  const ParentAccount({super.key});

  @override
  State<ParentAccount> createState() => _ParentAccountState();
}

class _ParentAccountState extends State<ParentAccount> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  final _formKey = GlobalKey<FormState>(); // Form key to handle validation

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // Function to validate the phone number
  String? validatePhoneNumber(String value) {
    // South African phone number validation
    RegExp regex = RegExp(r'^(?:\+27|0)[6-8][0-9]{8}$');
    if (!regex.hasMatch(value)) {
      return 'Please enter a valid South African phone number';
    }
    return null;
  }

  Future<void> _updateProfile() async {
    // Validate the form
    if (!_formKey.currentState!.validate()) {
      return; // Return early if the form is not valid
    }

    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final phoneNumber = _phoneController.text.trim();

    final user = supabase.auth.currentUser;
    final updates = {
      'id': user!.id,
      'first_name': firstName,
      'last_name': lastName,
      'phone_number': phoneNumber,
      'updated_at': DateTime.now().toIso8601String(),
    };

    await supabase.from('profiles').upsert(updates);
    if (mounted) {
      try {
        MyToast.showToast(context, 'Profile updated successfully!');

        // Get user role from database
        final user = supabase.auth.currentUser;
        if (user != null) {
          final response = await supabase
              .from('profiles')
              .select('role, is_parent')
              .eq('id', user.id)
              .single();

          // Navigate based on database role
          if (response['is_parent'] == true) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const Studentdetails(),
              ),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CareerAspirationsPage(),
              ),
            );
          }
        }
      } catch (e) {
        print('Error getting user role: $e');
        MyToast.showToast(context, 'Navigation error. Please try again.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.05, // 5% of screen width
          vertical: screenHeight * 0.02, // 2% of screen height
        ),
        color: Colors.white,
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        // Logo (responsive size)
                        SvgPicture.asset(
                          'assets/images/reslocate_logo.svg',
                          height: screenHeight * 0.07, // 7% of screen height
                        ),
                        const SizedBox(height: 10),

                        // Title
                        Text(
                          'Let’s get to know you better!',
                          style: TextStyle(
                            fontSize: screenWidth * 0.06, // Dynamic font size
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0D47A1),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),

                  // Input Fields
                  _buildTextField(
                      _firstNameController, 'First Name', Icons.person),
                  const SizedBox(height: 20),

                  _buildTextField(
                      _lastNameController, 'Last Name', Icons.person_outline),
                  const SizedBox(height: 20),

                  // Phone Number
                  _buildTextField(_phoneController, 'Phone Number', Icons.phone,
                      validator: validatePhoneNumber),
                  const SizedBox(height: 20),

                  // Next Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _updateProfile,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: const Color(0xFF0D47A1),
                      ),
                      child: const Text(
                        'Next',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
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

  // Updated _buildTextField to include required field validation
  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon,
      {FocusNode? focusNode, String? Function(String)? validator}) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType:
          label == 'Phone Number' ? TextInputType.phone : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
            const TextStyle(color: Colors.black), // Make the label text black
        prefixIcon: Icon(icon, color: const Color(0xFF0D47A1)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF0D47A1),
            width: 2,
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
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '$label is required';
        }
        if (validator != null) {
          return validator(value);
        }
        return null;
      }, // Apply validation if provided
    );
  }
}
