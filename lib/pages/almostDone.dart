// ignore: file_names
import 'package:flutter/material.dart';
import 'package:reslocate/pages/academicChallenges.dart';
import 'package:reslocate/pages/homepage.dart';
import 'package:reslocate/widgets/mytoast.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PersonalInfoPage extends StatefulWidget {
  const PersonalInfoPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _PersonalInfoPageState createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<PersonalInfoPage> {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  final List<String> _racialGroups = [
    'Black',
    'Coloured',
    'White',
    'Indian',
    'Asian',
    'Multiracial'
  ];

  final List<String> _genders = [
    'Male',
    'Female',
    'Other',
  ];

  final List<String> _hobbies = [
    'Reading',
    'Sports',
    'Gaming',
    'Music',
    'Traveling',
    'Arts',
    'Cooking',
    'Technology',
    'Content Creation',
    'Debate',
    'Wildlife',
    'Social Causes',
    'Events'
  ];

  String? _selectedRacialGroup;
  String? _selectedGender;
  final List<String> _selectedHobbies = [];

  bool get _canSelectMoreHobbies => _selectedHobbies.length < 3;

  void _toggleHobby(String hobby) {
    setState(() {
      if (_selectedHobbies.contains(hobby)) {
        _selectedHobbies.remove(hobby);
      } else if (_canSelectMoreHobbies) {
        _selectedHobbies.add(hobby);
      }
    });
  }

  void _selectRacialGroup(String racialGroup) {
    setState(() {
      _selectedRacialGroup = racialGroup;
    });
  }

  void _selectGender(String gender) {
    setState(() {
      _selectedGender = gender;
    });
  }

  bool _isSelectedHobby(String hobby) {
    return _selectedHobbies.contains(hobby);
  }

  Future<void> _submitSelections() async {
    if (_selectedRacialGroup != null &&
        _selectedGender != null &&
        _selectedHobbies.isNotEmpty) {
      // Check for at least 1 hobby
      final user = _supabaseClient.auth.currentUser;
      if (user != null) {
        final response = await _supabaseClient.from('profiles').update({
          'race': _selectedRacialGroup,
          'gender': _selectedGender,
          'hobby1': _selectedHobbies.isNotEmpty ? _selectedHobbies[0] : null,
          'hobby2': _selectedHobbies.length > 1 ? _selectedHobbies[1] : null,
          'hobby3': _selectedHobbies.length > 2 ? _selectedHobbies[2] : null,
        }).eq('id', user.id);

        // ignore: use_build_context_synchronously
        MyToast.showToast(context, 'Personal info saved successfully!');
        Navigator.push(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 100,
        automaticallyImplyLeading: false, // Disable default leading button
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back,
                  color: Color(0xFF0D47A1)), // Back button
              onPressed: () {
                Navigator.push(
                  // ignore: use_build_context_synchronously
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AcademicChallengesPage()),
                );
              },
            ),
            SvgPicture.asset(
              'assets/images/reslocate_logo.svg',
              height: 50,
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Almost Done!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D47A1),
                  ),
                ),
                Text(
                  'Let\'s complete your profile',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.5),
          child: Container(
            height: 1.5,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0D47A1), Color(0xFF00E4BA)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Text(
                  'What is your race?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.05,
                    color: const Color(0xFF0D47A1),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: _racialGroups.map((racialGroup) {
                    return GestureDetector(
                      onTap: () => _selectRacialGroup(racialGroup),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _selectedRacialGroup == racialGroup
                                ? const Color(0xFF0D47A1)
                                : Colors.black26,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          color: _selectedRacialGroup == racialGroup
                              ? const Color(0xFF0D47A1)
                              : Colors.white,
                        ),
                        child: Text(
                          racialGroup,
                          style: TextStyle(
                            color: _selectedRacialGroup == racialGroup
                                ? Colors.white
                                : Colors.black,
                            fontSize: 16,
                            fontWeight: _selectedRacialGroup == racialGroup
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 40),

                Text(
                  'What is your gender?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.05,
                    color: const Color(0xFF0D47A1),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: _genders.map((gender) {
                    return GestureDetector(
                      onTap: () => _selectGender(gender),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _selectedGender == gender
                                ? const Color(0xFF0D47A1)
                                : Colors.black26,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          color: _selectedGender == gender
                              ? const Color(0xFF0D47A1)
                              : Colors.white,
                        ),
                        child: Text(
                          gender,
                          style: TextStyle(
                            color: _selectedGender == gender
                                ? Colors.white
                                : Colors.black,
                            fontSize: 16,
                            fontWeight: _selectedGender == gender
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 40),

                Text(
                  'Select your hobbies?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.05,
                    color: const Color(0xFF0D47A1),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  '(Max: 3 selections)',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: _hobbies.map((hobby) {
                    return GestureDetector(
                      onTap: () => _toggleHobby(hobby),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _isSelectedHobby(hobby)
                                ? const Color(0xFF0D47A1)
                                : Colors.black26,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          color: _isSelectedHobby(hobby)
                              ? const Color(0xFF0D47A1)
                              : Colors.white,
                        ),
                        child: Text(
                          hobby,
                          style: TextStyle(
                            color: _isSelectedHobby(hobby)
                                ? Colors.white
                                : Colors.black, // Pure black when not selected
                            fontSize: 16,
                            fontWeight: _isSelectedHobby(hobby)
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 60),

                // Navigation Button: Next
                ElevatedButton(
                  onPressed: (_selectedRacialGroup != null &&
                          _selectedGender != null &&
                          _selectedHobbies
                              .isNotEmpty) // Allow submission with at least 1 hobby
                      ? _submitSelections
                      : null, // Disable button if form is incomplete
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 20),
                    backgroundColor: (_selectedRacialGroup != null &&
                            _selectedGender != null &&
                            _selectedHobbies
                                .isNotEmpty) // At least 1 hobby to enable button
                        ? const Color(0xFF0D47A1)
                        : Colors.grey, // Grey when disabled, blue when enabled
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Next',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
