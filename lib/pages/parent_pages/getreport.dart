import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:reslocate/pages/parent_pages/parent_bookmarks.dart';
import 'package:reslocate/pages/parent_pages/parent_profile.dart';
import 'package:reslocate/widgets/mytoast.dart';
import 'package:reslocate/widgets/pnav_bar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:reslocate/pages/parent_pages/parent_homepage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:io';
import 'package:open_file/open_file.dart';
import 'package:reslocate/widgets/loadingAnimation.dart';
import 'package:http/http.dart' as http;

final supabase = Supabase.instance.client;

class ParentStudentDetailsPage extends StatefulWidget {
  const ParentStudentDetailsPage({super.key});

  @override
  _ParentStudentDetailsPageState createState() =>
      _ParentStudentDetailsPageState();
}

class _ParentStudentDetailsPageState extends State<ParentStudentDetailsPage> {
  bool _isLoading = true;
  bool _isParent = false;
  List<Map<String, dynamic>> _children = [];
  Map<String, Map<String, dynamic>> _childrenMarks = {};
  Map<String, Map<String, dynamic>> _careerGuidanceResponses = {};
  int _selectedChildIndex = 0;
  bool _isGeneratingReport = false;
  String? _errorMessage;
  final int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    _checkParentStatus();
  }

  Future<void> _checkParentStatus() async {
    setState(() => _isLoading = true);
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // First check if the user is a parent
      final parentData =
          await supabase.from('profiles').select().eq('id', user.id).single();

      _isParent = parentData['is_parent'] ?? false;

      if (!_isParent) {
        throw Exception('User is not registered as a parent');
      }

      // If user is a parent, load their children's data
      await _loadChildrenData(user.id);
    } catch (e) {
      print('Error checking parent status: $e');
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    switch (index) {
      case 0:
        // Navigate to Home page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ParentHomepage()),
        );
        break;
      case 1:
        // Navigate to Scholarships page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => const ParentStudentDetailsPage()),
        );
        break;
      case 2:
        // Navigate to Bookmarks page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ParentBookmarks()),
        );
        break;
      case 3:
        // Navigate to Profile page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ParentProfile()),
        );
        break;
    }
  }

  Future<void> _loadChildrenData(String parentId) async {
    try {
      // Get all children linked to this parent
      final List<dynamic> children =
          await supabase.from('profiles').select().eq('parent_id', parentId);

      if (children.isEmpty) {
        setState(() {
          _errorMessage = 'No children linked to this parent account';
        });
        return;
      }

      // Fetch marks separately for each child
      final Map<String, Map<String, dynamic>> processedMarks = {};
      final Map<String, Map<String, dynamic>> careerGuidanceResponses = {};
      for (var child in children) {
        final marks = await supabase
            .from('user_marks')
            .select()
            .eq('user_id', child['id'])
            .maybeSingle();

        if (marks != null) {
          // Convert marks to a Map and remove subjects with null values
          final filteredMarks = Map<String, dynamic>.from(marks)
            ..removeWhere((key, value) => value == null);

          // Only add the processed marks if there's valid data remaining
          if (filteredMarks.isNotEmpty) {
            processedMarks[child['id']] = filteredMarks;
          }
        }

        // Fetch career guidance responses
        final careerGuidanceResponse = await supabase
            .from('career_guidance_responses')
            .select()
            .eq('user_id', child['id'])
            .maybeSingle();

        if (careerGuidanceResponse != null) {
          careerGuidanceResponses[child['id']] =
              Map<String, dynamic>.from(careerGuidanceResponse);
        }
      }

      setState(() {
        _children =
            children.map((child) => Map<String, dynamic>.from(child)).toList();
        _childrenMarks = processedMarks;
        _careerGuidanceResponses = careerGuidanceResponses;
        _errorMessage = null;
      });
    } catch (e) {
      print('Error loading children data: $e');
      setState(() {
        _errorMessage = 'Error loading children data: ${e.toString()}';
      });
    }
  }

  Widget _buildCareerGuidanceResponsesSection(
      Map<String, dynamic> studentProfile) {
    final careerGuidanceResponse =
        _careerGuidanceResponses[studentProfile['id']];

    if (careerGuidanceResponse == null) {
      return const SizedBox.shrink();
    }

    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Career Guidance Responses',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D47A1),
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
                'Family Support',
                careerGuidanceResponse['family_support']?.toString() ??
                    'Not specified'),
            _buildInfoRow(
                'Internet Access',
                careerGuidanceResponse['internet_access']?.toString() ??
                    'Not specified'),
            _buildInfoRow(
                'School Library',
                careerGuidanceResponse['school_library']?.toString() ??
                    'Not specified'),
            _buildInfoRow(
                'Computer Lab',
                careerGuidanceResponse['computer_lab']?.toString() ??
                    'Not specified'),
            _buildInfoRow('Workforce Worries',
                careerGuidanceResponse['workforce_worries'] ?? 'Not specified'),
            _buildInfoRow('Library Visits',
                careerGuidanceResponse['library_visits'] ?? 'Not specified'),
            _buildInfoRow(
                'Soft Skills',
                careerGuidanceResponse['soft_skills']?.join(', ') ??
                    'Not specified'),
            _buildInfoRow(
                'Soft Skills Explanation',
                careerGuidanceResponse['soft_skills_explanation'] ??
                    'Not specified'),
          ],
        ),
      ),
    );
  }

  Widget _buildAcademicMarksSection(Map<String, dynamic> marks) {
    if (marks.isEmpty) {
      return Card(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No academic marks available'),
        ),
      );
    }

    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Academic Performance',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D47A1),
              ),
            ),
            const SizedBox(height: 16),
            // Core subjects
            if (marks['math_mark'] != null && marks['math_mark'] != 'None')
              _buildMarkRow(
                'Mathematics (${marks['math_type'] ?? 'Not specified'})',
                marks['math_mark'],
                level: marks['math_level'],
              ),
            if (marks['home_language_mark'] != 'None')
              _buildMarkRow(
                marks['home_language'] ?? 'Home Language',
                marks['home_language_mark'],
                level: marks['home_language_level'],
              ),
            if (marks['first_additional_language_mark'] != 'None')
              _buildMarkRow(
                marks['first_additional_language'] ??
                    'First Additional Language',
                marks['first_additional_language_mark'],
                level: marks['first_additional_language_level'],
              ),
            if (marks['second_additional_language_mark'] != 'None' &&
                marks['second_additional_language'] != 'None')
              _buildMarkRow(
                marks['second_additional_language'],
                marks['second_additional_language_mark'],
                level: marks['second_additional_language_level'],
              ),
            if (marks['life_orientation_mark'] != 'None')
              _buildMarkRow(
                'Life Orientation',
                marks['life_orientation_mark'],
                level: marks['life_orientation_level'],
              ),
            // Optional subjects
            if (marks['subject1'] != null &&
                marks['subject1'] != 'None' &&
                marks['subject1_mark'] != null &&
                marks['subject1_mark'] != 'None')
              _buildMarkRow(
                marks['subject1'],
                marks['subject1_mark'],
                level: marks['subject1_level'],
              ),
            if (marks['subject2'] != null &&
                marks['subject2'] != 'None' &&
                marks['subject2_mark'] != null &&
                marks['subject2_mark'] != 'None')
              _buildMarkRow(
                marks['subject2'],
                marks['subject2_mark'],
                level: marks['subject2_level'],
              ),
            if (marks['subject3'] != null &&
                marks['subject3'] != 'None' &&
                marks['subject3_mark'] != null &&
                marks['subject3_mark'] != 'None')
              _buildMarkRow(
                marks['subject3'],
                marks['subject3_mark'],
                level: marks['subject3_level'],
              ),
            if (marks['subject4'] != null &&
                marks['subject4'] != 'None' &&
                marks['subject4_mark'] != null &&
                marks['subject4_mark'] != 'None')
              _buildMarkRow(
                marks['subject4'],
                marks['subject4_mark'],
                level: marks['subject4_level'],
              ),
            const Divider(),
            if (marks['average'] != null && marks['average'] != 'None')
              _buildMarkRow('Average', marks['average'], isAverage: true),
            if (marks['aps_mark'] != null && marks['aps_mark'] != 'None')
              _buildMarkRow('APS Score', marks['aps_mark'], isAPS: true),
          ],
        ),
      ),
    );
  }

  Widget _buildMarkRow(String subject, dynamic mark,
      {bool isAverage = false, bool isAPS = false, int? level}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              subject,
              style: TextStyle(
                fontWeight:
                    (isAverage || isAPS) ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          if (level != null)
            Container(
              width: 40,
              alignment: Alignment.center,
              child: Text(
                'L$level',
                style: const TextStyle(
                  color: Color(0xFF666666),
                ),
              ),
            ),
          Container(
            width: 60,
            alignment: Alignment.centerRight,
            child: Text(
              mark != null ? (isAPS ? '$mark' : '$mark%') : 'N/A',
              style: TextStyle(
                fontWeight:
                    (isAverage || isAPS) ? FontWeight.bold : FontWeight.normal,
                color: (isAverage || isAPS) ? const Color(0xFF0D47A1) : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: BouncingImageLoader()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          toolbarHeight: 100,
          automaticallyImplyLeading: false, // Disable default leading button
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF0D47A1)),
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ParentHomepage()),
                ),
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
                    'Error',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D47A1),
                    ),
                  ),
                  Text(
                    'Something went wrong',
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
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _checkParentStatus,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D47A1),
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: PnavBar(
          selectedIndex: _selectedIndex,
          onItemTapped: _onItemTapped,
        ),
      );
    }

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
              icon: const Icon(Icons.arrow_back, color: Color(0xFF0D47A1)),
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ParentHomepage()),
              ),
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
                  'Learner Details',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D47A1),
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
      body: Column(
        children: [
          if (_children.length > 1)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: DropdownButton<int>(
                isExpanded: true,
                value: _selectedChildIndex,
                items: List.generate(_children.length, (index) {
                  final child = _children[index];
                  return DropdownMenuItem(
                    value: index,
                    child: Text('${child['first_name']} ${child['last_name']}'),
                  );
                }),
                onChanged: (index) {
                  if (index != null) {
                    setState(() => _selectedChildIndex = index);
                  }
                },
              ),
            ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStudentInfoSection(_children[_selectedChildIndex]),
                  const SizedBox(height: 20),
                  _buildAcademicMarksSection(
                      _childrenMarks[_children[_selectedChildIndex]['id']] ??
                          {}),
                  const SizedBox(height: 20),
                  _buildCareerAspirationsSection(
                      _children[_selectedChildIndex]),
                  const SizedBox(height: 20),
                  _buildAcademicChallengesSection(
                      _children[_selectedChildIndex]),
                  const SizedBox(height: 20),
                  _buildHobbiesSection(_children[_selectedChildIndex]),
                  const SizedBox(height: 20),
                  _buildAdditionalInfoSection(_children[_selectedChildIndex]),
                  const SizedBox(height: 20),
                  _buildCareerGuidanceResponsesSection(
                      _children[_selectedChildIndex]),
                  const SizedBox(height: 20),
                  _buildSeeSampleButton(),
                  const SizedBox(height: 20),
                  _buildDownloadReportButton(_children[_selectedChildIndex]),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: PnavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  Widget _buildStudentInfoSection(Map<String, dynamic> studentProfile) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.school, color: Color(0xFF0D47A1), size: 24),
                const SizedBox(width: 10),
                const Text(
                  'Student Information',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D47A1),
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildCoolProfileItem(Icons.person, 'Name',
                '${studentProfile['first_name']} ${studentProfile['last_name']}'),
            _buildCoolProfileItem(Icons.school_outlined, 'School',
                studentProfile['school'] ?? 'Not specified'),
            _buildCoolProfileItem(Icons.grade, 'Grade',
                studentProfile['grade']?.toString() ?? 'Not specified'),
            _buildCoolProfileItem(Icons.cake, 'Date of Birth',
                _formatDate(studentProfile['date_of_birth'])),
            _buildCoolProfileItem(Icons.transgender, 'Gender',
                studentProfile['gender'] ?? 'Not specified'),
            _buildCoolProfileItem(Icons.people, 'Race',
                studentProfile['race'] ?? 'Not specified'),
            _buildCoolProfileItem(Icons.grade_outlined, 'Quintile',
                studentProfile['quintile'] ?? 'Not specified'),
            _buildCoolProfileItem(Icons.phone, 'Phone Number',
                studentProfile['phone_number'] ?? 'Not specified'),
          ],
        ),
      ),
    );
  }

  Widget _buildCareerAspirationsSection(Map<String, dynamic> studentProfile) {
    // Define the list of career aspirations with labels and icons
    final aspirations = [
      {
        'icon': Icons.stars,
        'label': 'First Choice',
        'value': studentProfile['career_asp1']
      },
      {
        'icon': Icons.star_border,
        'label': 'Second Choice',
        'value': studentProfile['career_asp2']
      },
      {
        'icon': Icons.star_outline,
        'label': 'Third Choice',
        'value': studentProfile['career_asp3']
      },
    ];

    // Filter out aspirations that are null or "Not specified"
    final filteredAspirations = aspirations.where((aspiration) {
      final value = aspiration['value'];
      return value != null && value != 'Not specified';
    }).toList();

    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.work, color: Color(0xFF0D47A1), size: 24),
                const SizedBox(width: 10),
                const Text(
                  'Career Aspirations',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D47A1),
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...filteredAspirations.map((aspiration) => _buildCoolProfileItem(
                  aspiration['icon'] as IconData,
                  aspiration['label'] as String,
                  aspiration['value'] as String,
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildAcademicChallengesSection(Map<String, dynamic> studentProfile) {
    // Define the list of challenges with labels and icons
    final challenges = [
      {
        'icon': Icons.warning_amber,
        'label': 'Challenge 1',
        'value': studentProfile['acad_chal1']
      },
      {
        'icon': Icons.warning_amber_outlined,
        'label': 'Challenge 2',
        'value': studentProfile['acad_chal2']
      },
      {
        'icon': Icons.warning_outlined,
        'label': 'Challenge 3',
        'value': studentProfile['acad_chal3']
      },
    ];

    // Filter out challenges that are null or "Not specified"
    final filteredChallenges = challenges.where((challenge) {
      final value = challenge['value'];
      return value != null && value != 'Not specified';
    }).toList();

    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.psychology,
                    color: Color(0xFF0D47A1), size: 24),
                const SizedBox(width: 10),
                const Text(
                  'Academic Challenges',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D47A1),
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...filteredChallenges.map((challenge) => _buildCoolProfileItem(
                  challenge['icon'] as IconData,
                  challenge['label'] as String,
                  challenge['value'] as String,
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildHobbiesSection(Map<String, dynamic> studentProfile) {
    // Define the list of hobbies with labels and icons
    final hobbies = [
      {
        'icon': Icons.sports_esports,
        'label': 'Hobby 1',
        'value': studentProfile['hobby1']
      },
      {
        'icon': Icons.sports,
        'label': 'Hobby 2',
        'value': studentProfile['hobby2']
      },
      {
        'icon': Icons.palette,
        'label': 'Hobby 3',
        'value': studentProfile['hobby3']
      },
    ];

    // Filter out hobbies that are null or "Not specified"
    final filteredHobbies = hobbies.where((hobby) {
      final value = hobby['value'];
      return value != null && value != 'Not specified';
    }).toList();

    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.interests, color: Color(0xFF0D47A1), size: 24),
                const SizedBox(width: 10),
                const Text(
                  'Hobbies & Interests',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D47A1),
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...filteredHobbies.map((hobby) => _buildCoolProfileItem(
                  hobby['icon'] as IconData,
                  hobby['label'] as String,
                  hobby['value'] as String,
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalInfoSection(Map<String, dynamic> studentProfile) {
    // Define the list of profile items with labels and icons
    final additionalInfoItems = [
      {
        'icon': Icons.location_city,
        'label': 'Nearby Amenity',
        'value': studentProfile['nearby_amenity']
      },
      {
        'icon': Icons.security,
        'label': 'Safety',
        'value': studentProfile['safety']
      },
      {
        'icon': Icons.star_rate,
        'label': 'Important Feature',
        'value': studentProfile['important_feature']
      },
      {
        'icon': Icons.directions_bus,
        'label': 'Commute',
        'value': studentProfile['commute']
      },
      {
        'icon': Icons.menu_book,
        'label': 'Learning Method 1',
        'value': studentProfile['learning_method1']
      },
      {
        'icon': Icons.menu_book_outlined,
        'label': 'Learning Method 2',
        'value': studentProfile['learning_method2']
      },
      {
        'icon': Icons.book_outlined,
        'label': 'Learning Method 3',
        'value': studentProfile['learning_method3']
      },
    ];

    // Filter out items where the value is null or "Not specified"
    final filteredItems = additionalInfoItems.where((item) {
      final value = item['value'];
      return value != null && value != 'Not specified';
    }).toList();

    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.more_horiz,
                    color: Color(0xFF0D47A1), size: 24),
                const SizedBox(width: 10),
                const Text(
                  'Additional Information',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D47A1),
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...filteredItems.map((item) => _buildCoolProfileItem(
                  item['icon'] as IconData,
                  item['label'] as String,
                  item['value'] as String,
                )),
          ],
        ),
      ),
    );
  }

// Helper widget for consistent item styling
  Widget _buildCoolProfileItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF0D47A1), size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeeSampleButton() {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () async {
          const bucketName = 'pdfs';
          const filePath = 'sample_report/career_guidance_report.pdf';

          try {
            final supabase = Supabase.instance.client;

            // Retrieve the public URL of the PDF
            final publicUrl =
                supabase.storage.from(bucketName).getPublicUrl(filePath);

            if (publicUrl.isEmpty) {
              throw Exception('Failed to retrieve the PDF URL.');
            }
            MyToast.showToast(context, "Downloading PDF...");

            // Download the file
            final response = await http.get(Uri.parse(publicUrl));

            if (response.statusCode == 200) {
              // Get temporary directory
              final directory = await getApplicationDocumentsDirectory();
              final filePath =
                  '${directory.path}/career_guidance_sample_report.pdf';

              // Write the file
              final file = File(filePath);
              await file.writeAsBytes(response.bodyBytes);

              // Show success message
              MyToast.showToast(context, "PDF downloaded successfully.");
              await OpenFile.open(filePath);
            } else {
              throw Exception('Failed to download PDF');
            }
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${e.toString()}')),
            );
          }
        },
        icon: const Icon(Icons.download),
        label: const Text('Download Sample Report'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0D47A1),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget _buildDownloadReportButton(Map<String, dynamic> studentProfile) {
    return Center(
      child: ElevatedButton.icon(
        onPressed:
            _isGeneratingReport ? null : () => _generateReport(studentProfile),
        icon: _isGeneratingReport
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2),
              )
            : const Icon(Icons.download),
        label: Text(_isGeneratingReport
            ? 'Generating...'
            : 'Download Career Guidance Report'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0D47A1),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF666666),
              ),
            ),
          ),
          Expanded(
            child: Text(value ?? 'Not specified'),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Not specified';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Invalid date';
    }
  }

  Future<void> _generateReport(Map<String, dynamic> studentProfile) async {
    setState(() => _isGeneratingReport = true);

    try {
      // Initialize Gemini
      final model = GenerativeModel(
        model: 'gemini-pro',
        apiKey: 'AIzaSyCr13Pn-UTmpaUGTyoqouw5QBV7wRdovSQ',
      );

      // Prepare student data for the prompt
      final careerGuidanceResponse =
          _careerGuidanceResponses[studentProfile['id']];
      final studentInfo = '''
Name: ${studentProfile['first_name']} ${studentProfile['last_name']}
Age: ${studentProfile['age']}
Academic Performance: ${_childrenMarks[studentProfile['id']]}
Interests: ${studentProfile['interests']}
Strengths: ${studentProfile['strengths']}
Family Support: ${careerGuidanceResponse!['family_support'] ?? 'Not specified'}
Internet Access: ${careerGuidanceResponse['internet_access'] ?? 'Not specified'}
School Library: ${careerGuidanceResponse['school_library'] ?? 'Not specified'}
Computer Lab: ${careerGuidanceResponse['computer_lab'] ?? 'Not specified'}
Workforce Worries: ${careerGuidanceResponse['workforce_worries'] ?? 'Not specified'}
Library Visits: ${careerGuidanceResponse['library_visits'] ?? 'Not specified'}
Soft Skills: ${careerGuidanceResponse['soft_skills']?.join(', ') ?? 'Not specified'}
Soft Skills Explanation: ${careerGuidanceResponse['soft_skills_explanation'] ?? 'Not specified'}
Preferred Activities: ${careerGuidanceResponse['preferred_activities'] ?? 'Not specified'}
Work Environment: ${careerGuidanceResponse['work_environment'] ?? 'Not specified'}
Problem Solving Style: ${careerGuidanceResponse['problem_solving_style'] ?? 'Not specified'}
Team Role: ${careerGuidanceResponse['team_role'] ?? 'Not specified'}
Energy Source: ${careerGuidanceResponse['energy_source'] ?? 'Not specified'}
Information Processing: ${careerGuidanceResponse['information_processing'] ?? 'Not specified'}
Decision Making: ${careerGuidanceResponse['decision_making'] ?? 'Not specified'}
Lifestyle Preference: ${careerGuidanceResponse['lifestyle_preference'] ?? 'Not specified'}
''';

      // Create content for Gemini
      final prompt = '''
As a career counselor, provide a detailed career guidance report for a student with the following profile:
$studentInfo

Please include:
1. Career paths that align with their strengths and interests
2. Required educational qualifications
3. Skill development recommendations
4. Potential challenges and how to overcome them
5. Next steps and action items

Format the response in clear sections with detailed explanations.
''';

      // Generate content using the correct Content type
      final content = await model.generateContent([Content.text(prompt)]);
      final reportText = content.text;

      // Generate PDF
      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (context) => [
            pw.Header(
              level: 0,
              child: pw.Text('Career Guidance Report',
                  style: pw.TextStyle(
                      fontSize: 24, fontWeight: pw.FontWeight.bold)),
            ),
            pw.Header(
              level: 1,
              child: pw.Text('Student Profile',
                  style: pw.TextStyle(
                      fontSize: 18, fontWeight: pw.FontWeight.bold)),
            ),
            pw.Paragraph(text: studentInfo),
            pw.SizedBox(height: 20),
            pw.Header(
              level: 1,
              child: pw.Text('Career Analysis',
                  style: pw.TextStyle(
                      fontSize: 18, fontWeight: pw.FontWeight.bold)),
            ),
            pw.Paragraph(text: reportText),
            pw.SizedBox(height: 20),
            pw.Footer(
              margin: pw.EdgeInsets.all(10),
              title: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Text(
                      'Generated on ${DateTime.now().toString().split(' ')[0]}'),
                ],
              ),
            ),
          ],
        ),
      );

      // Get a directory for saving the file
      final outputDir = await getApplicationDocumentsDirectory();

      final fileName =
          'career_guidance_${studentProfile['id']}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final filePath = '${outputDir.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      if (!mounted) return;

      // Notify user of successful save
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Report saved at: $filePath'),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: 'Open',
            onPressed: () {
              OpenFile.open(
                  filePath); // Open the file if a file viewer is installed
            },
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generating report: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isGeneratingReport = false);
      }
    }
  }
}
