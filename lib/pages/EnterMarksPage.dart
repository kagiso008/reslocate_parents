// ignore: file_names
import 'package:flutter/material.dart';
import 'package:reslocate/pages/academicChallenges.dart';
import 'package:reslocate/pages/careerAspirations.dart';
import 'package:reslocate/widgets/mytoast.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:reslocate/lists/subjects.dart'; // Import the file containing your lists
import 'package:flutter_svg/flutter_svg.dart';

class EnterMarksPage extends StatefulWidget {
  const EnterMarksPage({super.key});

  @override
  State<EnterMarksPage> createState() => _EnterMarksPageState();
}

class _EnterMarksPageState extends State<EnterMarksPage> {
  String _selectedMath = mathematics[0];
  String _selectedHomeLanguage = homeLanguages[0];
  String _selectedFirstAdditionalLanguage = firstAdditionalLanguages[0];
  String _selectedSecondAdditionalLanguage = "None";
  String _selectedSubject1 = "None";
  String _selectedSubject2 = "None";
  String _selectedSubject3 = "None";
  String _selectedSubject4 = "None";

  int _mathMark = 0;
  int _homeLanguageMark = 0;
  int _firstAdditionalLanguageMark = 0;
  int _secondAdditionalLanguageMark = 0;
  int _subject1Mark = 0;
  int _subject2Mark = 0;
  int _subject3Mark = 0;
  int _subject4Mark = 0;
  int _lifeOrientationMark = 0;

  List<String> get _availableElectives {
    List<String> selectedElectives = [
      _selectedSubject1,
      _selectedSubject2,
      _selectedSubject3,
      _selectedSubject4,
    ];
    return electives
        .where((elec) => !selectedElectives.contains(elec))
        .toList();
  }

  List<DropdownMenuItem<int>> _getMarkDropdownItems() {
    List<DropdownMenuItem<int>> items = [];
    for (int i = 0; i <= 100; i++) {
      items.add(DropdownMenuItem(value: i, child: Text(i.toString())));
    }
    return items;
  }

  double _calculateAverage() {
    // Store all the subject marks in a list
    List<int> allMarks = [
      _mathMark,
      _homeLanguageMark,
      _firstAdditionalLanguageMark,
      _secondAdditionalLanguageMark,
      _subject1Mark,
      _subject2Mark,
      _subject3Mark,
      _subject4Mark,
      _lifeOrientationMark
    ];

    // Sort the marks in descending order
    allMarks.sort((a, b) => b.compareTo(a));

    // Take the top 7 marks
    int topSevenTotal = allMarks.take(7).reduce((a, b) => a + b);

    // Calculate the average
    return topSevenTotal / 7;
  }

  String _getLevelFromMark(int mark) {
    if (mark >= 0 && mark <= 29) {
      return '1';
    } else if (mark >= 30 && mark <= 39) {
      return '2';
    } else if (mark >= 40 && mark <= 49) {
      return '3';
    } else if (mark >= 50 && mark <= 59) {
      return '4';
    } else if (mark >= 60 && mark <= 69) {
      return '5';
    } else if (mark >= 70 && mark <= 79) {
      return '6';
    } else {
      return '7';
    }
  }

  Future<void> _saveMarks() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      MyToast.showToast(context, 'User is not logged in');
      return;
    }

    final averageMark = _calculateAverage().toInt();

    final totalAPS = int.parse(_getLevelFromMark(_mathMark)) +
        int.parse(_getLevelFromMark(_homeLanguageMark)) +
        int.parse(_getLevelFromMark(_firstAdditionalLanguageMark)) +
        int.parse(_getLevelFromMark(_secondAdditionalLanguageMark)) +
        int.parse(_getLevelFromMark(_subject1Mark)) +
        int.parse(_getLevelFromMark(_subject2Mark)) +
        int.parse(_getLevelFromMark(_subject3Mark)) +
        int.parse(_getLevelFromMark(_subject4Mark)) +
        int.parse(_getLevelFromMark(_lifeOrientationMark));

    final response = await Supabase.instance.client.from('user_marks').upsert({
      'user_id': user.id,
      'math_mark': _mathMark,
      'math_level': _getLevelFromMark(_mathMark),
      'math_type': _selectedMath,
      'home_language_mark': _homeLanguageMark,
      'home_language_level': _getLevelFromMark(_homeLanguageMark),
      'first_additional_language_mark': _firstAdditionalLanguageMark,
      'first_additional_language_level':
          _getLevelFromMark(_firstAdditionalLanguageMark),
      'second_additional_language_mark': _secondAdditionalLanguageMark,
      'second_additional_language_level':
          _getLevelFromMark(_secondAdditionalLanguageMark),
      'subject1': _selectedSubject1,
      'subject1_mark': _subject1Mark,
      'subject1_level': _getLevelFromMark(_subject1Mark),
      'subject2': _selectedSubject2,
      'subject2_mark': _subject2Mark,
      'subject2_level': _getLevelFromMark(_subject2Mark),
      'subject3': _selectedSubject3,
      'subject3_mark': _subject3Mark,
      'subject3_level': _getLevelFromMark(_subject3Mark),
      'subject4': _selectedSubject4,
      'subject4_mark': _subject4Mark,
      'subject4_level': _getLevelFromMark(_subject4Mark),
      'life_orientation_mark': _lifeOrientationMark,
      'life_orientation_level': _getLevelFromMark(_lifeOrientationMark),
      'average': averageMark,
      'aps_mark': totalAPS,
      'home_language': _selectedHomeLanguage,
      'first_additional_language': _selectedFirstAdditionalLanguage,
      'second_additional_language': _selectedSecondAdditionalLanguage,
    });

    if (response == null) {
      //print('Error: Response is null');
      return;
    }

    if (response.error != null) {
      MyToast.showToast(
          // ignore: use_build_context_synchronously
          context,
          'Error saving marks: ${response.error!.message}');
    } else {
      // ignore: use_build_context_synchronously
      MyToast.showToast(context, "Marks saved successfully");
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
        automaticallyImplyLeading: false,
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF0D47A1)),
              onPressed: () {
                Navigator.push(
                  // ignore: use_build_context_synchronously
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CareerAspirationsPage()),
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
                  'Grades',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D47A1),
                  ),
                ),
                Text(
                  'Enter your marks',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            _buildDropdownWithMarkField(
              subjectLabel: 'Mathematics',
              subjectValue: _selectedMath,
              subjectItems: mathematics,
              onSubjectChanged: (value) {
                setState(() {
                  _selectedMath = value!;
                });
              },
              markValue: _mathMark,
              onMarkChanged: (value) {
                setState(() {
                  _mathMark = value ?? 0;
                });
              },
              isMarkEnabled: _selectedMath != 'None',
            ),
            const Divider(),
            _buildDropdownWithMarkField(
              subjectLabel: 'Home Language',
              subjectValue: _selectedHomeLanguage,
              subjectItems: homeLanguages,
              onSubjectChanged: (value) {
                setState(() {
                  _selectedHomeLanguage = value!;
                });
              },
              markValue: _homeLanguageMark,
              onMarkChanged: (value) {
                setState(() {
                  _homeLanguageMark = value ?? 0;
                });
              },
              isMarkEnabled: _selectedHomeLanguage != 'None',
            ),
            const Divider(),
            _buildDropdownWithMarkField(
              subjectLabel: 'First Additional Language',
              subjectValue: _selectedFirstAdditionalLanguage,
              subjectItems: firstAdditionalLanguages,
              onSubjectChanged: (value) {
                setState(() {
                  _selectedFirstAdditionalLanguage = value!;
                });
              },
              markValue: _firstAdditionalLanguageMark,
              onMarkChanged: (value) {
                setState(() {
                  _firstAdditionalLanguageMark = value ?? 0;
                });
              },
              isMarkEnabled: _selectedFirstAdditionalLanguage != 'None',
            ),
            const Divider(),
            _buildDropdownWithMarkField(
              subjectLabel: 'Elective 1',
              subjectValue: _selectedSubject1,
              subjectItems: _availableElectives,
              onSubjectChanged: (value) {
                setState(() {
                  _selectedSubject1 = value!;
                });
              },
              markValue: _subject1Mark,
              onMarkChanged: (value) {
                setState(() {
                  _subject1Mark = value ?? 0;
                });
              },
              isMarkEnabled: _selectedSubject1 != 'None',
            ),
            const Divider(),
            _buildDropdownWithMarkField(
              subjectLabel: 'Elective 2',
              subjectValue: _selectedSubject2,
              subjectItems: _availableElectives,
              onSubjectChanged: (value) {
                setState(() {
                  _selectedSubject2 = value!;
                });
              },
              markValue: _subject2Mark,
              onMarkChanged: (value) {
                setState(() {
                  _subject2Mark = value ?? 0;
                });
              },
              isMarkEnabled: _selectedSubject2 != 'None',
            ),
            const Divider(),
            _buildDropdownWithMarkField(
              subjectLabel: 'Elective 3',
              subjectValue: _selectedSubject3,
              subjectItems: _availableElectives,
              onSubjectChanged: (value) {
                setState(() {
                  _selectedSubject3 = value!;
                });
              },
              markValue: _subject3Mark,
              onMarkChanged: (value) {
                setState(() {
                  _subject3Mark = value ?? 0;
                });
              },
              isMarkEnabled: _selectedSubject3 != 'None',
            ),
            const Divider(),
            _buildDropdownWithMarkField(
              subjectLabel: 'Life Orientation',
              subjectValue: 'Life Orientation',
              subjectItems: ['Life Orientation'], // Single item as label
              onSubjectChanged: (value) {
                // No change required
              },
              markValue: _lifeOrientationMark,
              onMarkChanged: (value) {
                setState(() {
                  _lifeOrientationMark = value ?? 0;
                });
              },
              isMarkEnabled: true, // Always enabled
            ),
            const Divider(),
            const Text("Extra Subjects"),
            const Divider(),
            _buildDropdownWithMarkField(
              subjectLabel: 'Elective 4',
              subjectValue: _selectedSubject4,
              subjectItems: _availableElectives,
              onSubjectChanged: (value) {
                setState(() {
                  _selectedSubject4 = value!;
                });
              },
              markValue: _subject4Mark,
              onMarkChanged: (value) {
                setState(() {
                  _subject4Mark = value ?? 0;
                });
              },
              isMarkEnabled: _selectedSubject4 != 'None',
            ),
            const Divider(),
            _buildDropdownWithMarkField(
              subjectLabel: 'Second Additional Language',
              subjectValue: _selectedSecondAdditionalLanguage,
              subjectItems: secondAdditionalLanguages,
              onSubjectChanged: (value) {
                setState(() {
                  _selectedSecondAdditionalLanguage = value!;
                });
              },
              markValue: _secondAdditionalLanguageMark,
              onMarkChanged: (value) {
                setState(() {
                  _secondAdditionalLanguageMark = value ?? 0;
                });
              },
              isMarkEnabled: _selectedSecondAdditionalLanguage != 'None',
            ),
            const SizedBox(height: 40),

            // Save Button with Validation
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  if (_validateMarks()) {
                    await _saveMarks();
                    // ignore: use_build_context_synchronously
                    MyToast.showToast(context, "Marks saved successfully");
                    Navigator.push(
                      // ignore: use_build_context_synchronously
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AcademicChallengesPage(),
                      ),
                    );
                  } else {
                    MyToast.showToast(
                        context, "Please enter marks for at least 7 subjects.");
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  backgroundColor: const Color(0xFF0D47A1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Save Marks',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _validateMarks() {
    int enteredMarksCount = 0;

    if (_mathMark > 0) enteredMarksCount++;
    if (_homeLanguageMark > 0) enteredMarksCount++;
    if (_firstAdditionalLanguageMark > 0) enteredMarksCount++;
    if (_secondAdditionalLanguageMark > 0) enteredMarksCount++;
    if (_subject1Mark > 0) enteredMarksCount++;
    if (_subject2Mark > 0) enteredMarksCount++;
    if (_subject3Mark > 0) enteredMarksCount++;
    if (_subject4Mark > 0) enteredMarksCount++;
    if (_lifeOrientationMark > 0) enteredMarksCount++;

    return enteredMarksCount >= 7;
  }

  Widget _buildDropdownWithMarkField({
    required String subjectLabel,
    required String subjectValue,
    required List<String> subjectItems,
    required ValueChanged<String?> onSubjectChanged,
    required int markValue,
    required ValueChanged<int?> onMarkChanged,
    required bool isMarkEnabled,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Expanded(
            child: PopupMenuButton<String>(
              onSelected: onSubjectChanged,
              color: Colors.white, // White background for the entire menu
              itemBuilder: (BuildContext context) {
                return subjectItems.map((String item) {
                  return PopupMenuItem<String>(
                    value: item,
                    child: Container(
                      width: 200,
                      color: Colors
                          .white, // Explicitly set the container background to white
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Text(
                          item,
                          style: const TextStyle(fontSize: 16.0),
                        ),
                      ),
                    ),
                  );
                }).toList();
              },
              child: ListTile(
                tileColor: Colors.white, // Set background of ListTile to white
                title: Text(subjectLabel),
                subtitle: Text(subjectValue),
                trailing: const Icon(Icons.arrow_drop_down),
              ),
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 80,
            child: DropdownButtonFormField<int>(
              value: isMarkEnabled ? markValue : null,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                isDense: true,
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Colors.blue.shade900), // Blue border when focused
                  borderRadius: BorderRadius.circular(12),
                ),
                fillColor: Colors.white, // Ensure white background when focused
                filled: true,
              ),
              dropdownColor:
                  Colors.white, // Set dropdown color when expanded to white
              items: _getMarkDropdownItems(),
              onChanged: isMarkEnabled ? onMarkChanged : null,
            ),
          ),
        ],
      ),
    );
  }
}
