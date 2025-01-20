import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:reslocate/pages/scholarshipsPage.dart';
import 'package:reslocate/widgets/university_cards.dart';

class ParentGetAvailableCourses extends StatefulWidget {
  final int aps; // Add this parameter to receive the APS score
  final String universityName;

  const ParentGetAvailableCourses({
    super.key,
    required this.aps,
    required this.universityName,
  }); // Update constructor

  @override
  _ParentGetAvailableCoursesState createState() =>
      _ParentGetAvailableCoursesState();
}

class _ParentGetAvailableCoursesState extends State<ParentGetAvailableCourses> {
  final SupabaseClient _supabaseClient = Supabase.instance.client;
  bool isLoading = true;
  Map<String, List<Map<String, dynamic>>> facultyCourses = {};
  int visibleFaculties = 3; // Number of faculties to show initially
  Map<String, int> visibleCoursesPerFaculty =
      {}; // Number of courses to show per faculty initially
  Map<String, dynamic>? universityCard;

  @override
  void initState() {
    super.initState();
    loadChildData();
    _fetchUniversityCard();
  }

  Future<void> _fetchUniversityCard() async {
    try {
      final response = await _supabaseClient
          .from('Institutions Information')
          .select('title, city, province, website, image_url')
          .eq('title', widget.universityName)
          .single();
      setState(() {
        universityCard = response;
      });
    } catch (error) {
      print('Error fetching university card: $error');
    }
  }

  Future<String> getSelectedChildId() async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      print(userId);

      if (userId == null) {
        throw Exception('No user logged in');
      }

      final response = await _supabaseClient
          .from('profiles')
          .select('id')
          .eq('parent_id', userId)
          .limit(1)
          .single();

      if (response == null || response['id'] == null) {
        throw Exception('No child profile found');
      }

      return response['id'].toString();
    } catch (error) {
      print('Error details: $error');
      throw Exception('Error fetching child ID: $error');
    }
  }

  Future<void> loadChildData() async {
    setState(() {
      isLoading = true; // Show loading animatiog
    });

    String childUserId = await getSelectedChildId();
    await Future.wait([
      _fetchAvailableCourses(widget.aps, widget.universityName, childUserId),
      Future.delayed(const Duration(seconds: 50)),
    ]);

    setState(() {
      isLoading = false; // Hide loading animation
    });
  }

  Future<void> _fetchAvailableCourses(
      int aps, String universityName, String childUserId) async {
    try {
      final userMarksResponse = await _supabaseClient
          .from('user_marks')
          .select(
              'math_mark, math_level, math_type, home_language_mark, home_language_level, first_additional_language_mark, first_additional_language_level, second_additional_language_mark, second_additional_language_level, subject1, subject1_level, subject2, subject2_level, subject3, subject3_level, subject4, subject4_level, life_orientation_mark, life_orientation_level, home_language, first_additional_language, second_additional_language')
          .eq('user_id', childUserId)
          .single();

      final userMarks = userMarksResponse;

      // Fetch courses from the specific university
      final response = await _supabaseClient
          .from('universities')
          .select(
              'university_name, qualification, aps, faculty, english_hl, english_fal, maths, technical_math, maths_lit, physical_sciences, life_orientation, accounting, business_studies, economics, history, geography, tourism, civil_technology, egd, cat, it, electrical_technology, mechanical_technology')
          .eq('university_name', universityName); // Filter by university name

      final Map<String, List<Map<String, dynamic>>> groupedCourses = {};

      // Mapping user subjects to university columns
      final subjectMapping = {
        'Physical Sciences': 'physical_sciences',
        'Accounting': 'accounting',
        'Business Studies': 'business_studies',
        'Economics': 'economics',
        'History': 'history',
        'Geography': 'geography',
        'Tourism': 'tourism',
        'Civil Technology': 'civil_technology',
        'Engineering Graphics and Design': 'egd',
        'Computer Applications Technology': 'cat',
        'Information Technology': 'it',
        'Electrical Technology': 'electrical_technology',
        'Mechanical Technology': 'mechanical_technology',
      };

      for (var university in response) {
        bool meetsRequirements = true;

        // Skip APS comparison if APS is null in the universities table
        if (university['aps'] != null) {
          if (aps < university['aps']) {
            meetsRequirements = false;
            continue; // Skip this course if APS does not meet the requirement
          }
        }

        // Compare based on math_type
        if (userMarks['math_type'] == 'Mathematics') {
          if ((userMarks['math_level'] ?? 0) < (university['maths'] ?? 0)) {
            meetsRequirements = false;
          }
        } else if (userMarks['math_type'] == 'Mathematical Literacy') {
          if ((userMarks['math_level'] ?? 0) < (university['maths_lit'] ?? 0)) {
            meetsRequirements = false;
          }
        } else if (userMarks['math_type'] == 'Technical Mathematics') {
          if ((userMarks['math_level'] ?? 0) <
              (university['technical_math'] ?? 0)) {
            meetsRequirements = false;
          }
        }

        // Check English requirements
        bool hasEnglishHL = userMarks['home_language']
                ?.toString()
                .toLowerCase()
                .contains('english') ??
            false;
        bool hasEnglishFAL = userMarks['first_additional_language']
                ?.toString()
                .toLowerCase()
                .contains('english') ??
            false;

        if (hasEnglishHL) {
          if ((userMarks['home_language_level'] ?? 0) <
              (university['english_hl'] ?? 0)) {
            meetsRequirements = false;
          }
        } else if (hasEnglishFAL) {
          if ((userMarks['first_additional_language_level'] ?? 0) <
              (university['english_fal'] ?? 0)) {
            meetsRequirements = false;
          }
        } else {
          meetsRequirements = false;
        }

        // Iterate over the subjects required by the university
        subjectMapping.forEach((key, subjectName) {
          // Get the required level for this subject from the university
          final requiredLevel = university[key];

          // If the university has a requirement for this subject
          if (requiredLevel != null) {
            bool subjectFound = false;

            // Check if any of the user's selected subjects match this university subject
            for (int i = 1; i <= 4; i++) {
              final userSubject = userMarks['subject$i'];
              final userLevel = userMarks['subject${i}_level'];

              // If the user's subject matches the university-required subject
              if (userSubject == subjectName) {
                subjectFound = true;

                // If the user's subject level is less than the required level, they don't qualify
                if ((userLevel ?? 0) < requiredLevel) {
                  meetsRequirements = false;
                  break;
                }
              }
            }

            // If the required subject wasn't found in the user's selected subjects
            if (!subjectFound) {
              meetsRequirements = false;
            }
          }
        });

        // If requirements are met, add to the list
        if (meetsRequirements) {
          final faculty = university['faculty'] ?? 'Unknown Faculty';
          if (!groupedCourses.containsKey(faculty)) {
            groupedCourses[faculty] = [];
          }
          groupedCourses[faculty]!.add(university);
        }
      }

      setState(() {
        facultyCourses = groupedCourses;
        visibleCoursesPerFaculty = {
          for (var faculty in groupedCourses.keys) faculty: 5
        };
        isLoading = false;
      });

      if (facultyCourses.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('No courses match your subjects and levels')),
        );
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching available courses: $error')),
      );
    }
  }

  void _showMoreCourses(String faculty) {
    setState(() {
      visibleCoursesPerFaculty[faculty] =
          (visibleCoursesPerFaculty[faculty] ?? 0) + 5;
    });
  }

  void _showMoreFaculties() {
    setState(() {
      visibleFaculties += 3;
    });
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
                Navigator.pop(context); // Navigate back
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
                  'Courses',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D47A1),
                  ),
                ),
                Text(
                  'Course Matches',
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Unclickable card with university info
                  if (universityCard != null) const SizedBox(height: 10),

                  GetAvailabeleCoursesCard1(
                    title: universityCard!['title'],
                    image_url: universityCard!['image_url'],
                    city: universityCard!['city'],
                    province: universityCard!['province'],
                    website: universityCard!['website'],
                  ),
                  Card(
                    elevation: 0,
                    margin: const EdgeInsets.all(16.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white, // Change background color
                        borderRadius: BorderRadius.circular(
                            12), // Optional: Rounded corners
                      ),
                      padding: const EdgeInsets.all(
                          16.0), // Padding inside the containe
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Existing ListView for courses
                  facultyCourses.isEmpty
                      ? const Center(
                          child: Text('No courses available for your APS'))
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(16.0),
                          itemCount: visibleFaculties,
                          itemBuilder: (context, index) {
                            if (index < facultyCourses.keys.length) {
                              final faculty =
                                  facultyCourses.keys.elementAt(index);
                              final courses = facultyCourses[faculty]!;

                              return Card(
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      12), // Set radius to 12
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: const Color(
                                        0xFFE3F2FA), // Set background color
                                    borderRadius: BorderRadius.circular(
                                        12), // Match the Card's radius
                                  ),
                                  child: Theme(
                                    data: Theme.of(context).copyWith(
                                      dividerColor: Colors
                                          .transparent, // Removes the top and bottom lines
                                    ),
                                    child: ExpansionTile(
                                      title: Text(
                                        faculty,
                                        style: const TextStyle(
                                          fontSize: 18,
                                        ),
                                      ),
                                      children: [
                                        ...courses
                                            .take(visibleCoursesPerFaculty[
                                                faculty]!)
                                            .map((course) {
                                          return Column(
                                            children: [
                                              ListTile(
                                                title: Text(
                                                  course['qualification'],
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                onTap: () {
                                                  // Navigate to CoursePage when the ListTile is tapped
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          CoursePage(
                                                        course: course,
                                                        userAps: widget.aps,
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                              const Divider(
                                                  color: Colors
                                                      .black), // Add divider between qualifications
                                            ],
                                          );
                                        }),
                                        if (courses.length >
                                            visibleCoursesPerFaculty[faculty]!)
                                          const SizedBox(height: 20),
                                        ElevatedButton(
                                          onPressed: () {
                                            _showMoreCourses(faculty);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color(0xFF0D47A1),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 70,
                                              vertical: 12,
                                            ),
                                          ),
                                          child: const Text(
                                            'View more',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              return const SizedBox.shrink();
                            }
                          },
                        ),
                  if (facultyCourses.keys.length > visibleFaculties)
                    const SizedBox(
                      height: 40,
                    ),
                  ElevatedButton(
                    onPressed: () {
                      _showMoreFaculties();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D47A1),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 70,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      'View More Faculties',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class CoursePage extends StatelessWidget {
  final Map<String, dynamic> course;
  final int userAps; // Add user's APS as a parameter

  const CoursePage({super.key, required this.course, required this.userAps});

  @override
  Widget build(BuildContext context) {
    // Subject mapping for easy display of required subjects
    final subjectMapping = {
      'maths': 'Mathematics',
      'maths_lit': 'Mathematical Literacy',
      'technical_math': 'Technical Mathematics',
      'english_hl': 'English Home Language',
      'english_fal': 'English First Additional Language',
      'life_sciences': 'Life Sciences',
      'physical_sciences': 'Physical Sciences',
      'life_orientation': 'Life Orientation',
      'accounting': 'Accounting',
      'business_studies': 'Business Studies',
      'economics': 'Economics',
      'history': 'History',
      'geography': 'Geography',
      'tourism': 'Tourism',
      'civil_technology': 'Civil Technology',
      'egd': 'Engineering Graphics and Design (EGD)',
      'cat': 'Computer Applications Technology (CAT)',
      'it': 'Information Technology (IT)',
      'electrical_technology': 'Electrical Technology',
      'mechanical_technology': 'Mechanical Technology',
      'design': 'Design',
      'technical_sciences': 'Technical Sciences',
      'consumer_studies': 'Consumer Studies',
      'agricultural_sciences': 'Agricultural Sciences',
      'agricultural_technology': 'Agricultural Technology',
      'agricultural_management_practice': 'Agricultural Management Practice',
    };

    // Collect maths-related subjects and English subjects into separate lists
    final List<Map<String, String>> mathSubjects = [];
    final List<Map<String, String>> englishSubjects = [];
    final List<Map<String, String>> otherSubjects = [];

    subjectMapping.forEach((key, value) {
      final subjectLevel = course[key];
      if (subjectLevel != null && subjectLevel > 0) {
        if (key == 'maths' || key == 'maths_lit' || key == 'technical_math') {
          mathSubjects
              .add({'subject': value, 'level': subjectLevel.toString()});
        } else if (key == 'english_hl' || key == 'english_fal') {
          englishSubjects
              .add({'subject': value, 'level': subjectLevel.toString()});
        } else {
          otherSubjects
              .add({'subject': value, 'level': subjectLevel.toString()});
        }
      }
    });

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
                Navigator.pop(context); // Navigate back
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
                  'Admissions',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D47A1),
                  ),
                ),
                Text(
                  'Admission Requirements',
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                course['qualification'] ?? 'Unknown Qualification',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D47A1),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Admission Points Score',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FA),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'MIN APS',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${course['aps'] ?? 'N/A'}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FA),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'MY APS',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$userAps',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ScholarshipsPage(),
                    ),
                  );
                },
                child: const Text(
                  'View Scholarships',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF0D47A1),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 10),
              const Text(
                'Required Subjects & Levels',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D47A1),
                ),
              ),
              const SizedBox(height: 10),
              if (mathSubjects.isNotEmpty)
                Card(
                  color: const Color(0xFFE3F2FA),
                  elevation: 0,
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    leading: const Icon(Icons.book, color: Colors.black),
                    title: Text(
                      mathSubjects
                          .map((subj) =>
                              '${subj['subject']} (Level ${subj['level']})')
                          .join(' or '),
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              if (englishSubjects.isNotEmpty)
                Card(
                  elevation: 0,
                  color: const Color(0xFFE3F2FA),
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    leading: const Icon(Icons.book, color: Colors.black),
                    title: Text(
                      englishSubjects
                          .map((subj) =>
                              '${subj['subject']} (Level ${subj['level']})')
                          .join(' or '),
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ...otherSubjects.map((subject) => Card(
                    elevation: 0,
                    color: const Color(0xFFE3F2FA),
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      leading: const Icon(Icons.book, color: Colors.black),
                      title: Text(
                        '${subject['subject']} (Level ${subject['level']})',
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                  )),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
