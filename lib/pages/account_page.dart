import 'package:reslocate/main.dart' show ContextExtension, supabase;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Assuming your logo is an SVG
import 'package:reslocate/pages/careerAspirations.dart';
import 'package:reslocate/widgets/mytoast.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:reslocate/lists/schools.dart';
import 'package:intl/intl.dart'; // For formatting the date

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final TextEditingController _schoolController = TextEditingController();

  bool isValidSchool(String value) {
    return schools
        .any((school) => school.toLowerCase() == value.trim().toLowerCase());
  }

  @override
  void initState() {
    super.initState();
    loadSchools();
  }

  String? _selectedGrade;
  DateTime? _selectedDate;
  final DateFormat _dateFormat =
      DateFormat('yyyy-MM-dd'); // Format for displaying date

  final _formKey = GlobalKey<FormState>(); // Form key to handle validation

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _schoolController.dispose();
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

    // Ensure a date of birth is selected
    if (_selectedDate == null) {
      MyToast.showToast(context, 'Please select your date of birth');
      return;
    }

    // Ensure a grade is selected
    if (_selectedGrade == null) {
      MyToast.showToast(context, 'Please select your grade');
      return;
    }

    // Check if the school is valid
    final school = _schoolController.text.trim();
    if (!isValidSchool(school)) {
      MyToast.showToast(context, 'Please select a valid school from the list');
      return;
    }

    // Fetch quintile for the selected school
    try {
      final institutionResponse = await supabase
          .from('institutions')
          .select('quintile')
          .ilike('official_Institution_Name', school)
          .single();

      final String? quintile = institutionResponse['quintile'];
      final firstName = _firstNameController.text.trim();
      final lastName = _lastNameController.text.trim();
      final phoneNumber = _phoneController.text.trim();

      // Use the selected date
      final dob = _dateFormat.format(_selectedDate!);

      final user = supabase.auth.currentUser;
      final updates = {
        'id': user!.id,
        'first_name': firstName,
        'last_name': lastName,
        'phone_number': phoneNumber,
        'school': school,
        'grade': _selectedGrade,
        'date_of_birth': dob,
        'quintile': quintile, // Add the quintile from institutions table
        'updated_at': DateTime.now().toIso8601String(),
      };

      await supabase.from('profiles').upsert(updates);
      if (mounted) {
        MyToast.showToast(context, 'Profile updated successfully!');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const CareerAspirationsPage(),
          ),
        );
      }
    } on PostgrestException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unexpected error occurred'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> saveToDatabase(String value) async {
    try {} catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving to database: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

// Add this function to load schools from database
  Future<void> loadSchools() async {
    try {
      // Load schools from your database
      // schools = await YourDatabaseService.getSchools();
      setState(() {}); // Refresh UI after loading schools
    } catch (e) {}
  }

// Function to show the DatePicker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(), // Default to today's date
      firstDate: DateTime(1900), // You can customize this as needed
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            // Set the date picker theme to black and white
            dialogBackgroundColor: Colors.white, // Background white
            colorScheme: const ColorScheme.light(
              primary: Colors.black, // Header background color (including text)
              onPrimary: Colors.white, // Header text color
              onSurface:
                  Colors.black, // Text color for the date and day numbers
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor:
                    Colors.black, // Button text color (e.g., "CANCEL", "OK")
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Widget _buildCustomRadioButton(String value) {
    bool isSelected = _selectedGrade == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedGrade = value;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 8.0),
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? const Color(0xFF0D47A1) : Colors.black26,
              width: isSelected ? 1.5 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
            color: isSelected
                ? const Color(0xFF0D47A1).withOpacity(0.1)
                : Colors.white,
          ),
          child: Center(
            child: Text(
              value,
              style: TextStyle(
                color: isSelected
                    ? const Color(0xFF0D47A1)
                    : Colors
                        .black, // Change grade button text to black when unselected
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
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

                  // Date of Birth Section
                  GestureDetector(
                    onTap: () => _selectDate(context),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: screenHeight * 0.015, // Responsive padding
                        horizontal: screenWidth * 0.04,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black26, width: 1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today,
                              color: Color(0xFF0D47A1)),
                          const SizedBox(width: 16),
                          Text(
                            _selectedDate == null
                                ? 'Select your date of birth'
                                : _dateFormat.format(_selectedDate!),
                            style: TextStyle(
                              fontSize: screenWidth * 0.04, // Dynamic font size
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Phone Number
                  _buildTextField(_phoneController, 'Phone Number', Icons.phone,
                      validator: validatePhoneNumber),
                  const SizedBox(height: 20),

                  // School Autocomplete
                  Autocomplete<String>(
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text.isEmpty) {
                        return const Iterable<String>.empty();
                      }
                      return schools.where((String option) {
                        return option
                            .toLowerCase()
                            .contains(textEditingValue.text.toLowerCase());
                      });
                    },
                    displayStringForOption: (String option) => option,
                    fieldViewBuilder: (context, fieldTextEditingController,
                        fieldFocusNode, onFieldSubmitted) {
                      return TextFormField(
                        controller: fieldTextEditingController,
                        focusNode: fieldFocusNode,
                        decoration: InputDecoration(
                          labelText: 'School',
                          labelStyle: const TextStyle(color: Colors.black),
                          prefixIcon: Icon(Icons.school,
                              color: const Color(0xFF0D47A1)), // Blue icon
                          helperText:
                              'Please select from the suggested schools',
                          errorText:
                              fieldTextEditingController.text.isNotEmpty &&
                                      !isValidSchool(
                                          fieldTextEditingController.text)
                                  ? 'Please select a valid school from the list'
                                  : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: const BorderSide(
                                color: Color(0xFF0D47A1)), // Blue border
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: const BorderSide(
                                color: Color(
                                    0xFF0D47A1)), // Blue border when enabled
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: const BorderSide(
                                color: Color(0xFF0D47A1),
                                width: 2), // Blue and thicker when focused
                          ),
                        ),
                        onFieldSubmitted: (String value) {
                          if (isValidSchool(value)) {
                            _schoolController.text = value;
                            // Save to database or perform other actions
                            saveToDatabase(value);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Please select a valid school from the list'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                      );
                    },
                    onSelected: (String selection) {
                      _schoolController.text = selection;
                      // Save to database or perform other actions
                      saveToDatabase(selection);
                    },
                    optionsViewBuilder: (context, onSelected, options) {
                      return Align(
                        alignment: Alignment.topLeft,
                        child: Material(
                          elevation: 4.0,
                          borderRadius: BorderRadius.circular(12.0),
                          color: Colors.white,
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.9,
                            padding: const EdgeInsets.all(8.0),
                            child: SizedBox(
                              height: (options.length * 50.0 > 220.0)
                                  ? 220.0
                                  : options.length * 50.0,
                              child: ListView.builder(
                                padding: const EdgeInsets.all(8.0),
                                itemCount: options.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final String option =
                                      options.elementAt(index);
                                  return ListTile(
                                    title: Text(option),
                                    onTap: () {
                                      onSelected(option);
                                    },
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  // Grade Selector
                  const Text(
                    "Select Your Grade",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildCustomRadioButton('10'),
                      const SizedBox(width: 8),
                      _buildCustomRadioButton('11'),
                      const SizedBox(width: 8),
                      _buildCustomRadioButton('12'),
                    ],
                  ),
                  const SizedBox(height: 30),

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
