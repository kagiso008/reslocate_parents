import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:reslocate/pages/parent_pages/parent_homepage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:reslocate/widgets/loadingAnimation.dart';

class InsightsPage extends StatefulWidget {
  const InsightsPage({super.key});

  @override
  State<InsightsPage> createState() => _InsightsPageState();
}

class _InsightsPageState extends State<InsightsPage> {
  final SupabaseClient _supabaseClient = Supabase.instance.client;
  final _isLoading = false.obs;
  final _insights = Rx<Map<String, dynamic>>({});
  final _supabase = Supabase.instance.client;
  late Map<String, String> subjectNames;
  Map<String, int?> userMarks = {};
  int? aps;

  @override
  void initState() {
    super.initState();
    loadChildData();
    _fetchInsights();
  }

  Map<String, String> _subjectDisplayNames = {
    'math_mark': 'Mathematics',
    'subject1_mark': 'First Choice Elective',
    'subject2_mark': 'Second Choice Elective',
    'subject3_mark': 'Third Choice Elective',
    'subject4_mark': 'Fourth Choice Elective',
    'home_language_mark': 'Home Language',
    'first_additional_language_mark': 'First Additional Language',
    'second_additional_language_mark': 'Second Additional Language',
  };

  Map<String, dynamic> _getSubjectPerformance() {
    if (userMarks.isEmpty) return {};

    // Create a new map excluding subject4 and second_additional_language if they are None
    var filteredMarks = Map<String, num>.from(userMarks)
      ..removeWhere((key, value) =>
          value == null ||
          key == 'subject4_mark' ||
          key == 'second_additional_language_mark');

    if (filteredMarks.isEmpty) return {};

    // Find highest and lowest marks
    var maxEntry =
        filteredMarks.entries.reduce((a, b) => a.value > b.value ? a : b);
    var minEntry =
        filteredMarks.entries.reduce((a, b) => a.value < b.value ? a : b);

    return {
      'strongest': {
        'subject': subjectNames[maxEntry.key] ?? maxEntry.key,
        'mark': maxEntry.value
      },
      'weakest': {
        'subject': subjectNames[minEntry.key] ?? minEntry.key,
        'mark': minEntry.value
      }
    };
  }

  Future<void> _fetchInsights() async {
    try {
      _isLoading.value = true;
      final response = await _supabase
          .from('insights_table')
          .select()
          .order('created_at', ascending: false)
          .limit(1)
          .single();

      _insights.value = response;
    } catch (e) {
      debugPrint('Error fetching insights: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> loadChildData() async {
    setState(() {
      _isLoading.value = true;
      // Show loading animatiog
    });

    String childUserId = await getSelectedChildId();
    await Future.wait([
      _fetchUserMarks(childUserId),
      Future.delayed(const Duration(seconds: 50)),
    ]);

    setState(() {
      _isLoading.value = false;
    });
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

      if (response['id'] == null) {
        throw Exception('No child profile found');
      }

      return response['id'].toString();
    } catch (error) {
      print('Error details: $error');
      throw Exception('Error fetching child ID: $error');
    }
  }

  Future<void> _fetchUserMarks(String childUserId) async {
    try {
      final response = await _supabaseClient.from('user_marks').select('''
          math_mark, math_type,
          subject1, subject1_mark,
          subject2, subject2_mark,
          subject3, subject3_mark,
          subject4, subject4_mark,
          home_language_mark, home_language,
          first_additional_language_mark, first_additional_language,
          second_additional_language_mark, second_additional_language,
          life_orientation_mark
        ''').eq('user_id', childUserId).single();

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

        // Store the subject names
        subjectNames = {
          'math_mark': response['math_type'] ?? 'Mathematics',
          'subject1_mark': response['subject1'] ?? 'First Choice Elective',
          'subject2_mark': response['subject2'] ?? 'Second Choice Elective',
          'subject3_mark': response['subject3'] ?? 'Third Choice Elective',
          'subject4_mark': response['subject4'] ?? 'Fourth Choice Elective',
          'home_language_mark': response['home_language'] ?? 'Home Language',
          'first_additional_language_mark':
              response['first_additional_language'] ??
                  'First Additional Language',
          'second_additional_language_mark':
              response['second_additional_language'] ??
                  'Second Additional Language',
          'life_orientation_mark': 'Life Orientation'
        };

        aps = _CalculateApsUP(userMarks);
        _isLoading.value = false;
      });
    } catch (error) {
      setState(() {
        _isLoading.value = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching user marks: $error')),
      );
    }
  }

  int _CalculateApsUP(Map<String, int?> marks) {
    int apsScore = 0;

    // Add math_mark
    if (marks['math_mark'] != null) {
      apsScore += _getApsPoints(marks['math_mark']!);
    }

    // For subjects (subject1_mark, subject2_mark, subject3_mark, subject4_mark), take the best three marks
    final subjectMarks = [
      marks['subject1_mark'],
      marks['subject2_mark'],
      marks['subject3_mark'],
      marks['subject4_mark'],
    ];

    // Sort subjects in descending order and take the best three
    subjectMarks.sort((a, b) => (b ?? 0).compareTo(a ?? 0));

    final bestThreeSubjects = subjectMarks.take(3);
    for (var mark in bestThreeSubjects) {
      if (mark != null) {
        apsScore += _getApsPoints(mark);
      }
    }

    // For languages, take the best two marks between home_language, first_additional_language, and second_additional_language
    final languageMarks = [
      marks['home_language_mark'],
      marks['first_additional_language_mark'],
      marks['second_additional_language_mark'],
    ];

    // Sort language marks in descending order and take the two highest
    languageMarks.sort((a, b) => (b ?? 0).compareTo(a ?? 0));

    final bestTwoLanguages = languageMarks.take(2);
    for (var mark in bestTwoLanguages) {
      if (mark != null) {
        apsScore += _getApsPoints(mark);
      }
    }

    return apsScore;
  }

  int _getApsPoints(int mark) {
    if (mark >= 80) return 7;
    if (mark >= 70) return 6;
    if (mark >= 60) return 5;
    if (mark >= 50) return 4;
    if (mark >= 40) return 3;
    if (mark >= 30) return 2;
    return 1;
  }

  @override
  Widget build(BuildContext context) {
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
              icon: const Icon(Icons.arrow_back,
                  color: Color(0xFF0D47A1)), // Back button
              onPressed: () {
                Navigator.push(
                  // ignore: use_build_context_synchronously
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ParentHomepage()),
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
                  'Insights',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D47A1),
                  ),
                ),
                Text(
                  'Analytics Dashboard',
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
        color: Colors.white,
        child: Obx(() {
          if (_isLoading.value) {
            return const Center(child: BouncingImageLoader());
          }

          return RefreshIndicator(
            onRefresh: _fetchInsights,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildOverviewSection(),
                  const SizedBox(height: 24),
                  _buildSubjectAnalysisSection(),
                  const SizedBox(height: 24),
                  _buildMatricStatisticsSection(), // New section
                  const SizedBox(height: 24),
                  _buildDistributionSection(),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildOverviewSection() {
    final currentAps = aps ?? 0;
    final avgAps = _insights.value['avg_aps'] ?? 0;
    final difference = currentAps - avgAps;
    final isAboveAverage = difference >= 0;

    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Overview',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Total Users',
                    '${_insights.value['total_users'] ?? 0}',
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Average APS',
                    '${_insights.value['avg_aps'] ?? 0}',
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Card(
              color: const Color(0xFFF5F5F5),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  double screenWidth = MediaQuery.of(context).size.width;
                  double textSize = screenWidth * 0.04; // Scalable text size
                  double apsSize = screenWidth * 0.06; // APS text size

                  return Padding(
                    padding: EdgeInsets.all(
                        screenWidth * 0.04), // Responsive padding
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Your child's APS Comparison",
                          style: TextStyle(
                            fontSize: textSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: screenWidth * 0.03),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Your APS',
                                  style: TextStyle(
                                    fontSize: textSize * 0.85,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                SizedBox(height: screenWidth * 0.01),
                                Text(
                                  '$currentAps',
                                  style: TextStyle(
                                    fontSize: apsSize,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF0D47A1),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.03,
                                vertical: screenWidth * 0.015,
                              ),
                              decoration: BoxDecoration(
                                color: isAboveAverage
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isAboveAverage
                                        ? Icons.arrow_upward
                                        : Icons.arrow_downward,
                                    size: screenWidth * 0.035,
                                    color: isAboveAverage
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                  SizedBox(width: screenWidth * 0.01),
                                  Text(
                                    '${difference.abs().toStringAsFixed(2)} points ${isAboveAverage ? 'above' : 'below'} average',
                                    style: TextStyle(
                                      fontSize: textSize * 0.85,
                                      fontWeight: FontWeight.w500,
                                      color: isAboveAverage
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDistributionSection() {
    final currentStudentAps =
        _insights.value['current_student_aps'] as int? ?? 0;
    final apsDistribution = _insights.value['aps_distribution'] as Map? ?? {};
    final subjectDistribution =
        _insights.value['subject_distribution'] as Map? ?? {};

    // Sort subjects by value in descending order, and filter out subjects labeled as "None"
    final sortedSubjects = subjectDistribution.entries
        .where((entry) => entry.key.toString().toLowerCase() != 'none')
        .toList()
      ..sort((a, b) => (b.value as num).compareTo(a.value as num));

    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Distributions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Subject Distribution',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            ...sortedSubjects.map((entry) => _buildDistributionItem(
                  entry.key.toString(),
                  entry.value.toString(),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectAnalysisSection() {
    final performance = _getSubjectPerformance();
    if (performance.isEmpty) return const SizedBox.shrink();

    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Subject Analysis',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                // Use column layout if width is less than 600dp
                if (constraints.maxWidth < 600) {
                  return Column(
                    children: [
                      _buildPerformanceCard(
                        isStrong: true,
                        subject: performance['strongest']['subject'],
                        mark: performance['strongest']['mark'],
                      ),
                      const SizedBox(height: 16),
                      _buildPerformanceCard(
                        isStrong: false,
                        subject: performance['weakest']['subject'],
                        mark: performance['weakest']['mark'],
                      ),
                    ],
                  );
                }
                // Use row layout for wider screens
                return Row(
                  children: [
                    Expanded(
                      child: _buildPerformanceCard(
                        isStrong: true,
                        subject: performance['strongest']['subject'],
                        mark: performance['strongest']['mark'],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildPerformanceCard(
                        isStrong: false,
                        subject: performance['weakest']['subject'],
                        mark: performance['weakest']['mark'],
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceCard({
    required bool isStrong,
    required String subject,
    required num mark,
  }) {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isStrong ? Icons.arrow_circle_up : Icons.arrow_circle_down,
                  color: isStrong ? Colors.green : Colors.red,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isStrong ? 'Strongest Subject' : 'Needs Attention',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              subject,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
            const SizedBox(height: 4),
            Text(
              '$mark%',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isStrong ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDistributionItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceList() {
    final averageMarksBySubject =
        _insights.value['average_marks_by_subject'] as Map? ?? {};

    final filteredSubjects = averageMarksBySubject.entries.where((entry) =>
        entry.key != 'subject4' && entry.key != 'second_additional_language');

    String getSubjectDisplayName(String key) {
      switch (key) {
        case 'subject1':
          return 'First Choice Elective';
        case 'subject2':
          return 'Second Choice Elective';
        case 'subject3':
          return 'Third Choice Elective';
        case 'home_language':
          return 'Home Language';
        case 'life_orientation':
          return 'Life Orientation';
        case 'first_additional_language':
          return 'Additional Language';
        default:
          return key; // Default to the original key if no match
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Average Marks by Subject',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        ...filteredSubjects.map((entry) => _buildDistributionItem(
              getSubjectDisplayName(entry.key),
              '${entry.value}%',
            )),
      ],
    );
  }

  Widget _buildMatricStatisticsSection() {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'National Education Statistics 2024',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Matric Pass Rate',
                    '87.3%',
                    const Color(0xFF0D47A1),
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Bachelor Passes',
                    '47.8%',
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Card(
              color: const Color(0xFFF5F5F5),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'University Statistics',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildWarningStatItem(
                      'First-Year Dropout Rate',
                      '60%',
                      Icons.warning_amber_rounded,
                      Colors.orange,
                    ),
                    const SizedBox(height: 12),
                    _buildWarningStatItem(
                      'Overall Degree Completion',
                      '40%',
                      Icons.school_rounded,
                      Colors.blue,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Add new method for warning statistics items
  Widget _buildWarningStatItem(
      String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color.fromARGB(255, 5, 5, 5),
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
