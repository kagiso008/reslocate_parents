import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:reslocate/pages/editMarks.dart';
import 'package:reslocate/pages/parent_pages/parent_profile.dart';
import 'package:reslocate/widgets/mytoast.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditParentProfile extends StatefulWidget {
  final Map<String, dynamic> profileData;

  const EditParentProfile({super.key, required this.profileData});

  @override
  _EditParentProfileState createState() => _EditParentProfileState();
}

class _EditParentProfileState extends State<EditParentProfile> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _dateOfBirthController = TextEditingController();
  final TextEditingController _gradeController = TextEditingController();

  String? _selectedGender;
  String? _selectedRace;
  String? _selectedSchool;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _firstNameController.text = widget.profileData['first_name'] ?? '';
    _lastNameController.text = widget.profileData['last_name'] ?? '';
    _phoneNumberController.text = widget.profileData['phone_number'] ?? '';
    _dateOfBirthController.text =
        widget.profileData['date_of_birth']?.toString() ?? '';
    _gradeController.text = widget.profileData['grade']?.toString() ?? '';

    _selectedGender = widget.profileData['gender'];
    _selectedRace = widget.profileData['race'];
    _selectedSchool = widget.profileData['school'];
  }

  Future<void> _updateProfile() async {
    final supabase = Supabase.instance.client;

    // First fetch quintile for the selected school
    try {
      final institutionResponse = await supabase
          .from('institutions')
          .select('quintile')
          .ilike('official_Institution_Name', _selectedSchool!)
          .single();

      final String? quintile = institutionResponse['quintile'];

      final updates = {
        'first_name': _firstNameController.text,
        'last_name': _lastNameController.text,
        'phone_number': _phoneNumberController.text,
        'date_of_birth': _dateOfBirthController.text,
        'school': _selectedSchool,
        'grade': int.tryParse(_gradeController.text) ?? 0,
        'gender': _selectedGender,
        'race': _selectedRace,
        'quintile': quintile, // Add quintile to updates
      };

      await supabase
          .from('profiles')
          .update(updates)
          .eq('id', widget.profileData['id']);

      if (mounted) {
        MyToast.showToast(context, "Profile updated successfully");
      }
    } catch (error) {
      if (mounted) {
        MyToast.showToast(
            context, 'Error updating profile: ${error.toString()}');
      }
    }
  }

  Widget _buildDropdownField(String labelText, String? selectedValue,
      List<String> items, ValueChanged<String?> onChanged) {
    return SizedBox(
      width: MediaQuery.of(context).size.width, // Full screen width
      child: ButtonTheme(
        alignedDropdown: true,
        child: DropdownButtonFormField<String>(
          value: selectedValue,
          onChanged: onChanged,
          decoration: InputDecoration(
            labelText: labelText,
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
                width: 1.5,
              ),
            ),
          ),
          isExpanded: false,
          menuMaxHeight: 300,
          items: items.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: ConstrainedBox(
                constraints:
                    const BoxConstraints(maxWidth: 210), // Control item width
                child: Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            );
          }).toList(),
          hint: Text('Select $labelText'),
          style: const TextStyle(fontSize: 16, color: Colors.black),
          dropdownColor: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 100,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0D47A1)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/images/reslocate_logo.svg',
              height: 50,
            ),
            const SizedBox(width: 10),
            const Text(
              'Edit Profile',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D47A1),
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.5),
          child: Container(
            height: 1.5,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0D47A1),
                  Color(0xFF00E4BA),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            const Center(
              child: Text(
                'Personal Information',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D47A1),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildInputField('First Name', _firstNameController,
                prefixIcon: Icons.person),
            const SizedBox(height: 16),
            _buildInputField('Last Name', _lastNameController,
                prefixIcon: Icons.person),
            const SizedBox(height: 16),
            _buildInputField('Phone Number', _phoneNumberController,
                keyboardType: TextInputType.phone, prefixIcon: Icons.phone),
            const SizedBox(height: 30),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _updateProfile();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ParentProfile(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D47A1),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: const Text(
                        'Save Changes',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EditMarksPage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D47A1),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: const Text(
                        'Edit Marks',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String labelText, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text, IconData? prefixIcon}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: const Color(0xFF0D47A1))
            : null,
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      ),
    );
  }

  Widget _buildGradeDropdown() {
    return ButtonTheme(
      alignedDropdown: true,
      child: DropdownButtonFormField<int>(
        value: int.tryParse(_gradeController.text),
        items: [10, 11, 12].map((int grade) {
          return DropdownMenuItem<int>(
            value: grade,
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(maxWidth: 210), // Control item width
              child: Text(
                grade.toString(),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          );
        }).toList(),
        onChanged: (int? newValue) {
          setState(() {
            _gradeController.text = newValue.toString();
          });
        },
        decoration: InputDecoration(
          labelText: 'Grade',
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
        ),
        isExpanded: true,
        hint: const Text('Select Grade'),
        style: const TextStyle(fontSize: 16, color: Colors.black),
        dropdownColor: Colors.white,
        menuMaxHeight: 300, // Optional: limits menu height
      ),
    );
  }
}
