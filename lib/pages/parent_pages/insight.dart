import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fl_chart/fl_chart.dart';

class InsightsPage extends StatefulWidget {
  const InsightsPage({super.key});

  @override
  State<InsightsPage> createState() => _InsightsPageState();
}

class _InsightsPageState extends State<InsightsPage> {
  final SupabaseClient _supabaseClient = Supabase.instance.client;
  Map<String, dynamic>? _insights;
  Map<String, dynamic>? _currentStudent;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchInsights();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    try {
      await Future.wait([
        _fetchInsights(),
        loadChildData(),
      ]);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load some data')),
        );
      }
    }
  }

  Future<void> _fetchInsights() async {
    try {
      final response = await Supabase.instance.client
          .from('insights_table')
          .select()
          .order('created_at', ascending: false)
          .limit(1)
          .single();

      setState(() {
        _insights = response;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load insights')),
        );
      }
    }
  }

  Future<void> _fetchCurrentStudentData(String childUserId) async {
    try {
      print('Attempting to fetch student data for ID: $childUserId');

      final response = await Supabase.instance.client
          .from('user_marks')
          .select()
          .eq('user_id', childUserId)
          .single();

      setState(() {
        _currentStudent = response;
      });
    } catch (e) {
      print('Error fetching student data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load student data: $e')),
        );
      }
    }
  }

  Future<String?> getSelectedChildId() async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;

      if (userId == null) {
        print('No user logged in');
        return null;
      }

      final response = await _supabaseClient
          .from('profiles')
          .select('id')
          .eq('parent_id', userId)
          .limit(1)
          .single();

      if (response['id'] == null) {
        print('No child profile found');
        return null;
      }

      return response['id'].toString();
    } catch (error) {
      print('Error in getSelectedChildId: $error');
      return null;
    }
  }

  Future<void> loadChildData() async {
    try {
      String? childUserId = await getSelectedChildId();
      if (childUserId != null) {
        await _fetchCurrentStudentData(childUserId);
      } else {
        print('No child ID available');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No student profile found')),
          );
        }
      }
    } catch (e) {
      print('Error in loadChildData: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load student data')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_insights == null) {
      return const Scaffold(
        body: Center(child: Text('No insights available')),
      );
    }

    return Scaffold(
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
                  'Insights',
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
      body: RefreshIndicator(
        backgroundColor: Colors.white,
        onRefresh: _fetchInsights,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildKeyMetricsSection(constraints),
                  const SizedBox(height: 24),
                  _buildSubjectPerformanceSection(),
                  const SizedBox(height: 24),
                  _buildApsDistributionSection(),
                  const SizedBox(height: 24),
                  _buildMathLevelsSection(),
                  const SizedBox(height: 24),
                  _buildCurrentStudentComparisonSection(),
                  const SizedBox(height: 24),
                  _buildChartsSection(),
                  const SizedBox(height: 24),
                  _buildEnhancedComparisonSection()
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildKeyMetricsSection(BoxConstraints constraints) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Key Metrics',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0D47A1),
          ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final isWideScreen = constraints.maxWidth > 600;

            return ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: constraints.maxHeight, // Ensure grid height fits
              ),
              child: GridView.count(
                crossAxisCount: isWideScreen ? 4 : 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio:
                    (constraints.maxWidth / (isWideScreen ? 4 : 2)) /
                        200, // Make it more flexible for varying screen sizes
                children: [
                  _buildMetricCard(
                    'Total Users',
                    _insights!['total_users']?.toString() ?? 'N/A',
                    Icons.people,
                  ),
                  _buildMetricCard(
                    'Average APS',
                    _insights!['avg_aps']?.toStringAsFixed(2) ?? 'N/A',
                    Icons.score,
                  ),
                  _buildMetricCard(
                    'Most Common Math Type',
                    _insights!['most_common_math_type'] ?? 'N/A',
                    Icons.functions,
                  ),
                  _buildMetricCard(
                    'Most Chosen Subject',
                    _insights!['most_chosen_subject'] ?? 'N/A',
                    Icons.book,
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: Color(0xFF0D47A1)),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D47A1),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectPerformanceSection() {
    if (_insights!['average_marks_by_subject'] == null) {
      return const SizedBox.shrink();
    }

    final averageMarks = Map<String, dynamic>.from(
      _insights!['average_marks_by_subject'] as Map,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Subject Performance',
          style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D47A1)),
        ),
        const SizedBox(height: 16),
        ...averageMarks.entries.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildPerformanceBar(
                entry.key,
                (entry.value as num).toDouble(),
              ),
            )),
      ],
    );
  }

  Widget _buildPerformanceBar(String subject, double average) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              subject,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 18,
                color: Color(0xFF0D47A1),
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: average / 100,
                minHeight: 12,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.blue.shade600,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${average.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApsDistributionSection() {
    if (_insights!['aps_distribution'] == null) {
      return const SizedBox.shrink();
    }

    final apsDistribution = Map<String, dynamic>.from(
      _insights!['aps_distribution'] as Map,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'APS Distribution',
          style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D47A1)),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final isWideScreen = constraints.maxWidth > 600;

            return GridView.count(
              crossAxisCount: isWideScreen
                  ? 2
                  : 1, // Two cards per row on wide screens, one on small
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio:
                  1, // Ensure the aspect ratio stays 1:1 (no enlargement)
              children: apsDistribution.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16), // Reduced padding
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Range: ${entry.key}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 18,
                              color: Color(0xFF0D47A1),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Students: ${entry.value}',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildEnhancedComparisonSection() {
    if (_currentStudent == null || _insights == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('Student comparison data not available'),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Student Performance Analysis',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0D47A1),
          ),
        ),
        const SizedBox(height: 16),
        _buildPerformanceRadarChart(),
        const SizedBox(height: 16),
        _buildDetailedMetricsComparison(),
        const SizedBox(height: 16),
        _buildPercentileIndicator(),
        const SizedBox(height: 16),
        _buildStrengthsWeaknesses(),
      ],
    );
  }

  Widget _buildPerformanceRadarChart() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Performance Overview',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D47A1),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: const Text(
                    'Radar Chart Comparing: APS, Subject Averages, Attendance, Assignment Completion, and Class Participation',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedMetricsComparison() {
    final metrics = [
      {
        'name': 'APS Score',
        'current': _currentStudent!['aps']?.toDouble() ?? 0.0,
        'average': _insights!['avg_aps']?.toDouble() ?? 0.0,
        'percentile':
            _calculatePercentile(_currentStudent!['aps']?.toDouble() ?? 0.0),
      },
      {
        'name': 'Subject Average',
        'current': _calculateStudentSubjectAverage(),
        'average': _calculateOverallSubjectAverage(),
        'percentile': _calculatePercentile(_calculateStudentSubjectAverage()),
      },
    ];

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Detailed Metrics Comparison',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D47A1),
              ),
            ),
            const SizedBox(height: 16),
            ...metrics
                .map((metric) => Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              metric['name'] as String,
                              style: const TextStyle(fontSize: 16),
                            ),
                            Text(
                              'Percentile: ${(metric['percentile'] as double).toStringAsFixed(1)}%',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0D47A1),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: (metric['current'] as double) / 100,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF0D47A1)),
                          minHeight: 8,
                        ),
                        const SizedBox(height: 16),
                      ],
                    ))
                ,
          ],
        ),
      ),
    );
  }

  Widget _buildPercentileIndicator() {
    final studentPercentile = _calculateOverallPercentile();

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Overall Performance Percentile',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D47A1),
              ),
            ),
            const SizedBox(height: 16),
            Stack(
              children: [
                Container(
                  height: 24,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(
                      colors: [Colors.red, Colors.yellow, Colors.green],
                    ),
                  ),
                ),
                Positioned(
                  left: (studentPercentile / 100) *
                      MediaQuery.of(context).size.width *
                      0.8,
                  child: Container(
                    width: 4,
                    height: 24,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Your child is in the ${studentPercentile.toStringAsFixed(1)}th percentile',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStrengthsWeaknesses() {
    final strengths = _identifyStrengths();
    final weaknesses = _identifyWeaknesses();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth > 600;

        if (isWideScreen) {
          // Wide screen layout (side by side)
          return Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Strengths & Areas for Improvement',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D47A1),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Strengths:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            ...strengths.map((strength) => Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.arrow_upward,
                                          color: Colors.green),
                                      const SizedBox(width: 8),
                                      Expanded(child: Text(strength)),
                                    ],
                                  ),
                                )),
                          ],
                        ),
                      ),
                      const SizedBox(width: 32),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Areas for Improvement:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            ...weaknesses.map((weakness) => Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.arrow_downward,
                                          color: Colors.red),
                                      const SizedBox(width: 8),
                                      Expanded(child: Text(weakness)),
                                    ],
                                  ),
                                )),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        } else {
          // Narrow screen layout (stacked)
          return Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: EdgeInsets.all(isWideScreen ? 16 : 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Strengths & Areas for Improvement',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D47A1),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Strengths:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ...strengths.map((strength) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            const Icon(Icons.arrow_upward, color: Colors.green),
                            const SizedBox(width: 8),
                            Expanded(child: Text(strength)),
                          ],
                        ),
                      )),
                  const SizedBox(height: 16),
                  const Text(
                    'Areas for Improvement:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ...weaknesses.map((weakness) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            const Icon(Icons.arrow_downward, color: Colors.red),
                            const SizedBox(width: 8),
                            Expanded(child: Text(weakness)),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          );
        }
      },
    );
  }

// Helper methods for calculations
  double _calculatePercentile(double value) {
    if (_insights == null || _insights!['aps_distribution'] == null) {
      return 0;
    }

    final apsDistribution = Map<String, dynamic>.from(
      _insights!['aps_distribution'] as Map,
    );

    // Convert the distribution map to a list of scores
    List<double> scores = [];
    apsDistribution.forEach((key, count) {
      try {
        // Handle "start-end" and "start+" formats
        if (key.contains('-')) {
          // Parse range keys like "10-20"
          double? rangeStart = double.tryParse(key.split('-')[0]);
          double? rangeEnd = double.tryParse(key.split('-')[1]);
          if (rangeStart != null && rangeEnd != null) {
            double average = (rangeStart + rangeEnd) / 2;
            for (int i = 0; i < (count as int); i++) {
              scores.add(average);
            }
          }
        } else if (key.contains('+')) {
          // Parse keys like "30+"
          double? rangeStart = double.tryParse(key.replaceAll('+', ''));
          if (rangeStart != null) {
            for (int i = 0; i < (count as int); i++) {
              scores.add(rangeStart); // Use rangeStart for "30+"
            }
          }
        } else {
          print('Unrecognized key format: $key');
        }
      } catch (e) {
        // Debugging in case of invalid data
        print('Error parsing range or count for key "$key": $e');
      }
    });

    if (scores.isEmpty) {
      print('Scores list is empty. Ensure aps_distribution has valid data.');
      return 0; // Return 0 if scores list is empty
    }

    // Sort the scores
    scores.sort();

    // Find the position of the value in the sorted list
    int position = scores.indexWhere((score) => score >= value);

    // If no scores are greater or equal to value, position should be the length of the list
    if (position == -1) {
      position = scores.length;
    }

    // Calculate the percentile
    double percentile = (position / scores.length) * 100;

    return percentile;
  }

  double _calculateStudentSubjectAverage() {
    // Implementation would depend on your data structure
    // This is a placeholder that should be replaced with actual calculation
    return 75.0;
  }

  double _calculateOverallSubjectAverage() {
    // Check if the insights or the average_marks_by_subject field is null
    if (_insights == null || _insights!['average_marks_by_subject'] == null) {
      return 0.0; // Return 0 if data is not available
    }

    // Convert the average marks map to a strongly-typed map
    final averageMarks = Map<String, dynamic>.from(
      _insights!['average_marks_by_subject'] as Map,
    );

    double totalMarks = 0.0;
    int subjectCount = 0;

    // Iterate over each subject and marks entry
    averageMarks.forEach((subject, marks) {
      // Attempt to parse the marks into a double
      double? mark = double.tryParse(marks.toString());
      if (mark != null) {
        totalMarks += mark; // Add valid marks to the total
        subjectCount++; // Count valid subjects
      } else {
        // Debugging for invalid marks data
        print('Invalid mark for subject "$subject": $marks');
      }
    });

    // Calculate and return the average if subjectCount is greater than 0
    return subjectCount > 0 ? totalMarks / subjectCount : 0.0;
  }

  double _calculateOverallPercentile() {
    if (_insights == null || _insights!['aps_distribution'] == null) {
      return 0.0; // Return 0 if insights or distribution is missing
    }

    final apsDistribution = Map<String, dynamic>.from(
      _insights!['aps_distribution'] as Map,
    );

    List<double> scores = [];

    apsDistribution.forEach((key, value) {
      try {
        // Check if the key has a "+" symbol indicating an open-ended range
        if (key.contains('+')) {
          double? rangeStart = double.tryParse(key.replaceAll('+', '').trim());
          if (rangeStart != null) {
            // For "30+", add 'value' times the rangeStart to the scores list
            int count = int.tryParse(value.toString()) ?? 0;
            scores.addAll(List.generate(count, (_) => rangeStart));
          } else {
            print('Invalid range: $key');
          }
        } else {
          // Process "start-end" ranges
          List<String> rangeParts = key.split('-');
          double? rangeStart = double.tryParse(rangeParts[0].trim());
          double? rangeEnd = (rangeParts.length > 1)
              ? double.tryParse(rangeParts[1].trim())
              : null;

          if (rangeStart != null && rangeEnd != null) {
            double average = (rangeStart + rangeEnd) / 2;
            int count = int.tryParse(value.toString()) ?? 0;
            scores.addAll(List.generate(count, (_) => average));
          } else {
            print('Invalid range: $key');
          }
        }
      } catch (e) {
        print('Error processing range "$key": $e');
      }
    });

    scores.sort();

    if (scores.isEmpty) {
      return 0.0; // No data to calculate percentile
    }

    double? studentAps =
        double.tryParse(_currentStudent!['aps']?.toString() ?? '0.0');
    if (studentAps == null) {
      return 0.0; // Invalid student APS
    }

    // Find the position of the student's APS in the sorted scores
    int position = scores.indexWhere((score) => score >= studentAps);

    if (position == -1) {
      position = scores.length; // APS is higher than all scores
    }

    double percentile = (position / scores.length) * 100;

    return percentile;
  }

  List<String> _identifyStrengths() {
    // Check for null or missing data
    if (_currentStudent == null || _insights == null) {
      return []; // Return an empty list if data is unavailable
    }

    final subjectMarks = _currentStudent!['subject_marks'] is Map
        ? Map<String, dynamic>.from(_currentStudent!['subject_marks'] as Map)
        : {};
    final averageMarks = _insights!['average_marks_by_subject'] is Map
        ? Map<String, dynamic>.from(
            _insights!['average_marks_by_subject'] as Map)
        : {};

    List<String> strengths = [];

    subjectMarks.forEach((subject, marks) {
      try {
        double? mark = double.tryParse(marks.toString());
        double? averageMark =
            double.tryParse(averageMarks[subject]?.toString() ?? '0.0');

        // Add subject to strengths if marks exceed the average
        if (mark != null && averageMark != null && mark > averageMark) {
          strengths.add('Above average in $subject');
        }
      } catch (e) {
        // Log any errors for debugging purposes
        print('Error processing subject "$subject": $e');
      }
    });

    return strengths;
  }

  List<String> _identifyWeaknesses() {
    // Check for null or missing data
    if (_currentStudent == null || _insights == null) {
      return []; // Return an empty list if data is unavailable
    }

    // Validate and parse the data
    final subjectMarks = _currentStudent!['subject_marks'] is Map
        ? Map<String, dynamic>.from(_currentStudent!['subject_marks'] as Map)
        : {};
    final averageMarks = _insights!['average_marks_by_subject'] is Map
        ? Map<String, dynamic>.from(
            _insights!['average_marks_by_subject'] as Map)
        : {};

    List<String> weaknesses = [];

    // Iterate over the student's marks and compare them to the averages
    subjectMarks.forEach((subject, marks) {
      try {
        double? mark = double.tryParse(marks.toString());
        double? averageMark =
            double.tryParse(averageMarks[subject]?.toString() ?? '0.0');

        // Add subject to weaknesses if marks are below the average
        if (mark != null && averageMark != null && mark < averageMark) {
          weaknesses.add('Below average in $subject');
        }
      } catch (e) {
        // Log any errors for debugging
        print('Error processing subject "$subject": $e');
      }
    });

    return weaknesses;
  }

  Widget _buildMathLevelsSection() {
    if (_insights!['total_users_per_level'] == null) {
      return const SizedBox.shrink();
    }

    final levels = Map<String, dynamic>.from(
      (_insights!['total_users_per_level'] as Map)['Math'] as Map,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate number of columns dynamically based on screen width
        final crossAxisCount =
            (constraints.maxWidth / 200).floor(); // Each card ~200px
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Math Levels Distribution',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D47A1),
              ),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount.clamp(1, 4), // Minimum 1, max 4
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 3, // Adjust aspect ratio for card dimensions
              ),
              itemCount: levels.length,
              itemBuilder: (context, index) {
                final entry = levels.entries.elementAt(index);
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Level ${entry.key}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 18,
                            color: Color(0xFF0D47A1),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Students: ${entry.value}',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildCurrentStudentComparisonSection() {
    if (_currentStudent == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Current Student Comparison',
          style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D47A1)),
        ),
        const SizedBox(height: 16),
        _buildComparisonCard(
          'APS',
          _currentStudent!['aps']?.toStringAsFixed(2) ?? 'N/A',
          _insights!['avg_aps']?.toStringAsFixed(2) ?? 'N/A',
        ),
        const SizedBox(height: 16),
        _buildComparisonCard(
          'Math Level',
          _currentStudent!['math_level']?.toString() ?? 'N/A',
          _insights!['most_common_math_type'] ?? 'N/A',
        ),
        const SizedBox(height: 16),
        _buildComparisonCard(
          'Most Chosen Subject',
          _currentStudent!['most_chosen_subject']?.toString() ?? 'N/A',
          _insights!['most_chosen_subject'] ?? 'N/A',
        ),
        const SizedBox(height: 16),
        _buildApsComparisonChart(),
      ],
    );
  }

  Widget _buildComparisonCard(
      String title, String currentValue, String averageValue) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D47A1)),
            ),
            const SizedBox(height: 8),
            Text(
              'Current Student: $currentValue',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              'Average: $averageValue',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApsComparisonChart() {
    final currentAps =
        double.tryParse(_currentStudent!['aps']?.toStringAsFixed(2) ?? '0') ??
            0;
    final averageAps =
        double.tryParse(_insights!['avg_aps']?.toStringAsFixed(2) ?? '0') ?? 0;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'APS Comparison',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D47A1)),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(
                              value.toInt() == 0 ? 'Current' : 'Average',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(
                              '${value.toInt()}',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        FlSpot(0, currentAps),
                        FlSpot(1, averageAps),
                      ],
                      isCurved: true,
                      color:
                          const Color(0xFF0D47A1), // Updated for single color
                      barWidth: 4,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(show: true),
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

  Widget _buildChartsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Charts',
          style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D47A1)),
        ),
        const SizedBox(height: 16),
        _buildLineChart(),
      ],
    );
  }

  Widget _buildLineChart() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'APS Over Time',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D47A1)),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(
                              '${value.toInt()}',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(
                              '${value.toInt()}',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        FlSpot(0, 3),
                        FlSpot(1, 2),
                        FlSpot(2, 5),
                        FlSpot(3, 3),
                        FlSpot(4, 4),
                      ],
                      isCurved: true,
                      color: const Color(0xFF0D47A1), // Single color line
                      barWidth: 4,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(show: true),
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
}
