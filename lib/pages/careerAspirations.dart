// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:reslocate/pages/EnterMarksPage.dart';
import 'package:reslocate/pages/account_page.dart';
import 'package:reslocate/widgets/mytoast.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CareerAspirationsPage extends StatefulWidget {
  const CareerAspirationsPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CareerAspirationsPageState createState() => _CareerAspirationsPageState();
}

class _CareerAspirationsPageState extends State<CareerAspirationsPage> {
  final List<String> _careerAspirations = [
    'Agriculture',
    'Arts',
    'Business',
    'Communication',
    'Education',
    'Law',
    'Engineering',
    'Finance',
    'Government',
    'Media',
    'Science',
    'Technology',
  ];

  final List<String> _selectedAspirations = [];
  bool get _canSelectMoreAspirations => _selectedAspirations.length < 3;

  void _toggleAspirations(String aspiration) {
    setState(() {
      if (_selectedAspirations.contains(aspiration)) {
        _selectedAspirations.remove(aspiration);
      } else if (_canSelectMoreAspirations) {
        _selectedAspirations.add(aspiration);
      }
    });
  }

  bool _isSelectedAspiration(String aspiration) {
    return _selectedAspirations.contains(aspiration);
  }

  Future<void> _handleNext() async {
    if (_selectedAspirations.isNotEmpty) {
      // Fills missing aspirations with empty strings
      String careerAsp1 =
          _selectedAspirations.isNotEmpty ? _selectedAspirations[0] : 'NULL';
      String careerAsp2 =
          _selectedAspirations.length > 1 ? _selectedAspirations[1] : 'NULL';
      String careerAsp3 =
          _selectedAspirations.length > 2 ? _selectedAspirations[2] : 'NULL';

      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final userId = user.id;

        final response =
            await Supabase.instance.client.from('profiles').upsert({
          'id': userId,
          'career_asp1': careerAsp1,
          'career_asp2': careerAsp2,
          'career_asp3': careerAsp3,
        });

        // ignore: use_build_context_synchronously
        MyToast.showToast(context, 'Career Aspirations saved successfully!');
        Navigator.push(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(builder: (context) => const EnterMarksPage()),
        );
      } else {
        MyToast.showToast(context, 'Please log in');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // White background for the entire page
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 100, // Adjust height for your content
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
                  MaterialPageRoute(builder: (context) => const AccountPage()),
                ); // Navigate back
              },
            ),
            SvgPicture.asset(
              'assets/images/reslocate_logo.svg', // Replace with the correct path to your logo
              height: 50, // Adjust logo size
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Career Aspirations',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D47A1),
                  ),
                ),
                Text(
                  'Share your goals and interests',
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
              const SizedBox(height: 40), // Space below gradient
              Text(
                'Which industries interest you the most?',
                textAlign: TextAlign.center, // Center-align the text
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width *
                      0.05, // Dynamic font size
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
              const SizedBox(height: 20), // Space between question and options

              // Career Aspirations Buttons Styled Like Radio Buttons
              Wrap(
                spacing: 8,
                runSpacing: 10,
                alignment: WrapAlignment.center, // Center the Wrap content
                children: _careerAspirations.map((aspiration) {
                  bool isSelected = _isSelectedAspiration(aspiration);

                  return GestureDetector(
                    onTap: () => _toggleAspirations(aspiration),
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
                        aspiration,
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

              const SizedBox(height: 60), // Space before the navigation button

              // Navigation Button: Next
              ElevatedButton(
                onPressed: _selectedAspirations.isNotEmpty &&
                        _selectedAspirations.length <= 3
                    ? _handleNext
                    : null,
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  backgroundColor: _selectedAspirations.isNotEmpty &&
                          _selectedAspirations.length <= 3
                      ? const Color(0xFF0D47A1)
                      : Colors.grey,
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
    );
  }
}
