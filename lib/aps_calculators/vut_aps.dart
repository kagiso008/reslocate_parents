import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:reslocate/available_courses/getAvailableCourses.dart';
import 'package:reslocate/widgets/loadingAnimation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CalculateApsVUTPage extends StatefulWidget {
  const CalculateApsVUTPage({super.key});

  @override
  _CalculateApsVUTPageState createState() => _CalculateApsVUTPageState();
}

class _CalculateApsVUTPageState extends State<CalculateApsVUTPage> {
  final SupabaseClient _supabaseClient = Supabase.instance.client;
  bool isLoading = true;
  Map<String, int?> userMarks = {};
  Map<String, String?> userSubjects = {}; // Store detected subjects here
  int? aps;
  String selectedCategory = 'Human Sciences'; // Default selected category
  String? mathType; // Store detected math type here

  @override
  void initState() {
    super.initState();
    _fetchUserMarksAndSubjects();
  }

  Future<void> _fetchUserMarksAndSubjects() async {
    try {
      final response = await _supabaseClient
          .from('user_marks')
          .select(
              'math_mark, math_type, subject1, subject2, subject3, subject4, subject1_mark, subject2_mark, subject3_mark, subject4_mark, home_language_mark, first_additional_language_mark, second_additional_language_mark, life_orientation_mark,home_language,first_additional_language,second_additional_language')
          .eq('user_id', _supabaseClient.auth.currentUser!.id)
          .single();

      setState(() {
        userMarks = {
          'math_mark': response['math_mark'],
          'subject1_mark': response['subject1_mark'],
          'subject2_mark': response['subject2_mark'],
          'subject3_mark': response['subject3_mark'],
          'subject4_mark': response['subject4_mark'],
          'home_language_mark': response['home_language_mark'],
          'first_additional_language_mark':
              response['first_additional_language_mark'],
          'second_additional_language_mark':
              response['second_additional_language_mark'],
          'life_orientation_mark': response['life_orientation_mark'],
        };

        // Detect subjects
        userSubjects = {
          'subject1': response['subject1'],
          'subject2': response['subject2'],
          'subject3': response['subject3'],
          'subject4': response['subject4'],
          'home_language': response['home_language'],
          'first_additional_language': response['first_additional_language'],
          'second_additional_language': response['second_additional_language'],
        };

        mathType = response['math_type']; // Fetch the math type

        aps = _calculateApsVUT(userMarks, mathType, selectedCategory);
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching user marks: $error')),
      );
    }
  }

  int _calculateApsVUT(
      Map<String, int?> marks, String? mathType, String category) {
    int apsScore = 0;

    int getApsPoints(int mark) {
      if (mark >= 90) return 8;
      if (mark >= 80) return 7;
      if (mark >= 70) return 6;
      if (mark >= 60) return 5;
      if (mark >= 50) return 4;
      if (mark >= 40) return 3;
      if (mark >= 30) return 2;
      return 0;
    }

    final allMarks = [
      marks['math_mark'],
      marks['subject1_mark'],
      marks['subject2_mark'],
      marks['subject3_mark'],
      marks['subject4_mark'],
      marks['home_language_mark'],
      marks['first_additional_language_mark'],
      marks['second_additional_language_mark'],
    ];

    final validMarks = allMarks
        .where((mark) => mark != null)
        .map((mark) => getApsPoints(mark!))
        .toList();

    validMarks.sort((a, b) => b.compareTo(a));
    final bestSixMarks = validMarks.take(6).toList();
    apsScore = bestSixMarks.reduce((a, b) => a + b);

    final mathMark = marks['math_mark'];
    final homeLanguageMark = marks['home_language_mark'];
    final englishMark = _getEnglishMark();
    final physicalScienceMark =
        _getPhysicalSciencesMark(); // New logic for Physical Science

    // Category-specific logic
    switch (category) {
      case 'Human Sciences':
        // Bonus for Home Language
        if (homeLanguageMark != null) {
          if (homeLanguageMark >= 80) {
            apsScore += 2;
          } else if (homeLanguageMark > 70) {
            apsScore += 1;
          }
        }

        // Add bonus points if the math type is "Mathematics"
        if (mathType == 'Mathematics' && mathMark != null) {
          if (mathMark >= 80) {
            apsScore += 3;
          } else if (mathMark >= 70) {
            apsScore += 2;
          } else if (mathMark >= 60) {
            apsScore += 1;
          }
        }

        // Bonus for other subjects
        for (var mark in [
          marks['subject1_mark'],
          marks['subject2_mark'],
          marks['subject3_mark'],
          marks['first_additional_language_mark']
        ]) {
          if (mark != null) {
            if (mark >= 80) {
              apsScore += 2;
            } else if (mark > 70) {
              apsScore += 1;
            }
          }
        }

        break;

      case 'Management Sciences':
        // Bonus for Home Language
        if (homeLanguageMark != null) {
          if (homeLanguageMark >= 80) {
            apsScore += 2;
          } else if (homeLanguageMark > 70) {
            apsScore += 1;
          }
        }

        // Add bonus points if the math type is "Mathematics"
        if (mathType == 'Mathematics' && mathMark != null) {
          if (mathMark >= 80) {
            apsScore += 3;
          } else if (mathMark >= 70) {
            apsScore += 2;
          } else if (mathMark >= 60) {
            apsScore += 1;
          }
        }

        // Bonus for other subjects
        for (var mark in [
          marks['subject1_mark'],
          marks['subject2_mark'],
          marks['subject3_mark'],
          marks['first_additional_language_mark']
        ]) {
          if (mark != null) {
            if (mark >= 80) {
              apsScore += 2;
            } else if (mark > 70) {
              apsScore += 1;
            }
          }
        }

        break;

      case 'Applied and Computer Sciences':
        // Include Life Orientation without bonus
        final lifeOrientationMark = marks['life_orientation_mark'];
        if (lifeOrientationMark != null && lifeOrientationMark >= 40) {
          apsScore += 3;
        } else if (lifeOrientationMark != null && lifeOrientationMark >= 30) {
          apsScore += 2;
        }
        break;

      case 'Engineering and Technology':
        // Bonus for Physical Science and English
        if (physicalScienceMark != null) {
          if (physicalScienceMark >= 80) {
            apsScore += 2;
          } else if (physicalScienceMark > 70) {
            apsScore += 1;
          }
        }

        if (englishMark != null) {
          if (englishMark >= 80) {
            apsScore += 2;
          } else if (englishMark > 70) {
            apsScore += 1;
          }
        }

        // Add bonus points if the math type is "Mathematics"
        if (mathType == 'Mathematics' && mathMark != null) {
          if (mathMark >= 80) {
            apsScore += 3;
          } else if (mathMark > 70) {
            apsScore += 2;
          } else if (mathMark >= 60) {
            apsScore += 1;
          }
        }
        break;

      default:
        break;
    }

    return apsScore;
  }

  // Helper function to detect Physical Science subject
  int? _getPhysicalSciencesMark() {
    // Check if any of the subjects are "Physical Sciences"
    if (userSubjects['subject1'] == 'Physical Sciences') {
      return userMarks['subject1_mark'];
    } else if (userSubjects['subject2'] == 'Physical Sciences') {
      return userMarks['subject2_mark'];
    } else if (userSubjects['subject3'] == 'Physical Sciences') {
      return userMarks['subject3_mark'];
    } else if (userSubjects['subject4'] == 'Physical Sciences') {
      return userMarks['subject4_mark'];
    }
    return null; // If no subject is Physical Science
  }

  // Helper function to detect English subject
  int? _getEnglishMark() {
    // Check if any of the subjects are "English"
    if (userSubjects['home_language']?.contains('English') == true) {
      return userMarks['home_language_mark'];
    } else if (userSubjects['first_additional_language']?.contains('English') ==
        true) {
      return userMarks['first_additional_language_mark'];
    } else if (userSubjects['second_additional_language']
            ?.contains('English') ==
        true) {
      return userMarks['second_additional_language_mark'];
    }
    return null; // If no subject is English
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
                Navigator.pop(context);
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
                  'APS',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D47A1),
                  ),
                ),
                Text(
                  'Vaal University of Technology',
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 242, 243, 243),
              Color.fromARGB(255, 241, 241, 241),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: isLoading
              ? const BouncingImageLoader()
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      // APS Score Display Card
                      Card(
                        elevation: 2.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                        color: Colors.white,
                        shadowColor: Colors.black.withOpacity(0.5),
                        child: Padding(
                          padding: const EdgeInsets.all(30.0),
                          child: Column(
                            children: [
                              const Text(
                                'Your APS Score',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 30),
                              TweenAnimationBuilder(
                                tween: Tween<double>(
                                    begin: 0, end: (aps ?? 0).toDouble()),
                                duration: const Duration(seconds: 2),
                                builder: (context, value, child) {
                                  return Text(
                                    value.toStringAsFixed(1),
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'VAAL UNIVERSITY OF TECHNOLOGY',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Faculty Dropdown
                      SizedBox(
                        width: double.infinity,
                        child: DropdownButtonFormField<String>(
                          isExpanded: true,
                          value: selectedCategory,
                          hint: const Text('Select Category'),
                          items: <String>[
                            'Human Sciences',
                            'Management Sciences',
                            'Applied and Computer Sciences',
                            'Engineering and Technology'
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newCategory) {
                            setState(() {
                              selectedCategory = newCategory!;
                              aps = _calculateApsVUT(
                                  userMarks, mathType, selectedCategory);
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GetAvailableCouresPage(
                                aps: aps ?? 0,
                                universityName: 'Vaal University of Technology',
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D47A1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40.0,
                            vertical: 15.0,
                          ),
                        ),
                        child: const Text(
                          'Courses you qualify for',
                          style: TextStyle(fontSize: 18, color: Colors.white),
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
