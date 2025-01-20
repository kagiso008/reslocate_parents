// ignore: file_names
import 'package:flutter/material.dart';
import 'package:reslocate/pages/EnterMarksPage.dart';
import 'package:reslocate/pages/almostDone.dart';
import 'package:reslocate/widgets/mytoast.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AcademicChallengesPage extends StatefulWidget {
  const AcademicChallengesPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AcademicChallengesPageState createState() => _AcademicChallengesPageState();
}

class _AcademicChallengesPageState extends State<AcademicChallengesPage> {
  final List<String> _challenges = [
    'Resources',
    'Workload',
    'Time',
    'Career Path',
    'Subjects',
    'Support',
  ];

  final List<String> _learningMethods = [
    'Online Resources',
    'Mentorship',
    'Group Study',
    'After School Classes',
    'Online Courses',
  ];

  final List<String> _selectedChallenges = [];
  final List<String> _selectedLearningMethods = [];

  bool get _canSelectMoreChallenges => _selectedChallenges.length < 3;
  bool get _canSelectMoreLearningMethods => _selectedLearningMethods.length < 3;

  // Toggle Academic Challenge Selection
  void _toggleChallenge(String challenge) {
    setState(() {
      if (_selectedChallenges.contains(challenge)) {
        _selectedChallenges.remove(challenge);
      } else if (_canSelectMoreChallenges) {
        _selectedChallenges.add(challenge);
      }
    });
  }

  // Toggle Preferred Learning Methods Selection
  void _toggleLearningMethod(String method) {
    setState(() {
      if (_selectedLearningMethods.contains(method)) {
        _selectedLearningMethods.remove(method);
      } else if (_canSelectMoreLearningMethods) {
        _selectedLearningMethods.add(method);
      }
    });
  }

  bool _isSelectedChallenge(String challenge) {
    return _selectedChallenges.contains(challenge);
  }

  bool _isSelectedLearningMethod(String method) {
    return _selectedLearningMethods.contains(method);
  }

  Future<void> _handleNext() async {
    String? chal1, chal2, chal3;
    String? method1, method2, method3;

    // Assign selected challenges or set to null if less than 3 selected
    chal1 = _selectedChallenges.isNotEmpty ? _selectedChallenges[0] : null;
    chal2 = _selectedChallenges.length > 1 ? _selectedChallenges[1] : null;
    chal3 = _selectedChallenges.length > 2 ? _selectedChallenges[2] : null;

    // Assign selected learning methods or set to null if less than 3 selected
    method1 = _selectedLearningMethods.isNotEmpty
        ? _selectedLearningMethods[0]
        : null;
    method2 = _selectedLearningMethods.length > 1
        ? _selectedLearningMethods[1]
        : null;
    method3 = _selectedLearningMethods.length > 2
        ? _selectedLearningMethods[2]
        : null;

    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      final userId = user.id;

      // Update the profiles table with the selected values, and null for unselected ones
      await Supabase.instance.client.from('profiles').upsert({
        'id': userId,
        'acad_chal1': chal1,
        'acad_chal2': chal2,
        'acad_chal3': chal3,
        'learning_method1': method1,
        'learning_method2': method2,
        'learning_method3': method3,
      });

      // ignore: use_build_context_synchronously
      MyToast.showToast(context, 'Selections saved successfully!');
      // ignore: use_build_context_synchronously
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const PersonalInfoPage()));
    } else {
      MyToast.showToast(context, 'Please log in');
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
                  color: Color(0xFF0D47A1)), // Custom back button
              onPressed: () {
                Navigator.push(
                  // ignore: use_build_context_synchronously
                  context,
                  MaterialPageRoute(
                      builder: (context) => const EnterMarksPage()),
                ); // Navigate back
              },
            ),
            SvgPicture.asset(
              'assets/images/reslocate_logo.svg', // Replace with the correct path to your logo
              height: 50,
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Academic Challenges',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D47A1),
                  ),
                ),
                Text(
                  'Let us help you!',
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
                colors: [Color(0xFF0D47A1), Color(0xFF00E4BA)], // Gradient line
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Text(
                'What challenges do you face?',
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
              const SizedBox(height: 20),

              // Academic Challenges Buttons Styled Like Radio Buttons
              Wrap(
                spacing: 8,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: _challenges.map((challenge) {
                  bool isSelected = _isSelectedChallenge(challenge);

                  return GestureDetector(
                    onTap: () => _toggleChallenge(challenge),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF0D47A1)
                              : Colors.black26,
                          width: isSelected ? 1 : 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        color:
                            isSelected ? const Color(0xFF0D47A1) : Colors.white,
                      ),
                      child: Text(
                        challenge,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : Colors.black, // Pure black when not selected
                          fontSize: 16,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 40),

              // Preferred Learning Methods Section
              Text(
                'How do you prefer to learn?',
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
              const SizedBox(height: 20),

              // Preferred Learning Methods Buttons Styled Like Radio Buttons
              Wrap(
                spacing: 8,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: _learningMethods.map((method) {
                  bool isSelected = _isSelectedLearningMethod(method);

                  return GestureDetector(
                    onTap: () => _toggleLearningMethod(method),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF0D47A1)
                              : Colors.black26,
                          width: isSelected ? 1 : 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        color:
                            isSelected ? const Color(0xFF0D47A1) : Colors.white,
                      ),
                      child: Text(
                        method,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : Colors.black, // Pure black when not selected
                          fontSize: 16,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 60),

              // Navigation Button: Next
              ElevatedButton(
                onPressed: (_selectedChallenges.isNotEmpty &&
                        _selectedLearningMethods.isNotEmpty)
                    ? _handleNext
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D47A1),
                  minimumSize: const Size(160, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text('Next'),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
