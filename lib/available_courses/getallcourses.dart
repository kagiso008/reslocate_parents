// ignore_for_file: library_private_types_in_public_api
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:reslocate/widgets/university_cards.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:reslocate/pages/scholarshipsPage.dart';

class GetAvailableAllCouresPage extends StatefulWidget {
  final int aps; // Add this parameter to receive the APS score
  final String institutionName;

  const GetAvailableAllCouresPage({
    super.key,
    required this.aps,
    required this.institutionName,
  }); // Update constructor

  @override
  _GetAvailableAllCouresPageState createState() =>
      _GetAvailableAllCouresPageState();
}

class _GetAvailableAllCouresPageState extends State<GetAvailableAllCouresPage> {
  final SupabaseClient _supabaseClient = Supabase.instance.client;
  bool isLoading = true;
  Map<String, List<Map<String, dynamic>>> facultyCourses = {};
  int visibleFaculties = 8; // Number of faculties to show initially
  Map<String, int> visibleCoursesPerFaculty =
      {}; // Number of courses to show per faculty initially
  Map<String, dynamic>? universityCard;

  @override
  void initState() {
    super.initState();
    _fetchAvailableCourses(widget.aps, widget.institutionName); // Example
    _fetchUniversityCard();
  }

  Future<void> _fetchUniversityCard() async {
    try {
      final response = await _supabaseClient
          .from('Institutions Information')
          .select('title, city, province, website, image_url')
          .eq('title', widget.institutionName)
          .single();
      setState(() {
        universityCard = response;
      });
    } catch (error) {
      print('Error fetching university card: $error');
    }
  }

  Future<void> _fetchAvailableCourses(int aps, String institutionName) async {
    try {
      // Fetch user marks (if needed for other logic)
      final userMarksResponse = await _supabaseClient
          .from('user_marks')
          .select(
              'math_mark, math_level, math_type, home_language_mark, home_language_level, first_additional_language_mark, first_additional_language_level, second_additional_language_mark, second_additional_language_level, subject1, subject1_level, subject2, subject2_level, subject3, subject3_level, subject4, subject4_level, life_orientation_mark, life_orientation_level, home_language, first_additional_language, second_additional_language')
          .eq('user_id', _supabaseClient.auth.currentUser!.id)
          .single();

      // Fetch all courses for the specified institution
      final response = await _supabaseClient
          .from('allcourses')
          .select(
              'institution_name, qualification, aps, faculty, english_hl, english_fal, maths, technical_math, maths_lit, physical_sciences, life_orientation, accounting, business_studies, economics, history, geography, tourism, civil_technology, egd, cat, it, electrical_technology, mechanical_technology')
          .eq('institution_name', institutionName); // Filter by university name

      // Group courses by faculty
      final Map<String, List<Map<String, dynamic>>> groupedCourses = {};

      for (var college in response) {
        final faculty = college['faculty'] ?? 'Unknown Faculty';
        if (!groupedCourses.containsKey(faculty)) {
          groupedCourses[faculty] = [];
        }
        groupedCourses[faculty]!.add(college);
      }

      // Update state with all fetched courses
      setState(() {
        facultyCourses = groupedCourses;
        visibleCoursesPerFaculty = {
          for (var faculty in groupedCourses.keys) faculty: 5
        };
        isLoading = false;
      });

      // If no courses are found
      if (facultyCourses.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('No courses found for the selected institution')),
        );
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching courses: $error')),
      );
    }
  }

  void _showMoreCourses(String faculty) {
    setState(() {
      visibleCoursesPerFaculty[faculty] =
          (visibleCoursesPerFaculty[faculty] ?? 0) + 20;
    });
  }

  void _showMoreFaculties() {
    setState(() {
      visibleFaculties += 8;
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
                colors: [Color(0xFF0D47A1), Color(0xFF00E4BA)],
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
                  if (universityCard != null) const SizedBox(height: 10),
                  GetAvailableCoursesCard(
                    title: universityCard!['title'],
                    image_url: universityCard!['image_url'],
                    city: universityCard!['city'],
                    province: universityCard!['province'],
                    website: universityCard!['website'],
                  ),
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
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE3F2FA),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Theme(
                                    data: Theme.of(context).copyWith(
                                      dividerColor: Colors.transparent,
                                    ),
                                    child: ExpansionTile(
                                      title: Text(
                                        faculty,
                                        style: const TextStyle(fontSize: 18),
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
                                                  color: Colors.black),
                                            ],
                                          );
                                        }),
                                        if (courses.length >
                                            visibleCoursesPerFaculty[faculty]!)
                                          const SizedBox(height: 20),
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
                    const SizedBox(height: 40),
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
    final Map<String, String> subjectMapping = {
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
                  // Min APS Card
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
              // Math subjects
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
              // English subjects
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
              // Other subjects
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
