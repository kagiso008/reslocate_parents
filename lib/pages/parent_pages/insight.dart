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
  final _isLoading = false.obs;
  final _insights = Rx<Map<String, dynamic>>({});
  final _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _fetchInsights();
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
                  _buildPerformanceSection(),
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
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceSection() {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Performance Metrics',
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
                    'Highest Average Mark',
                    '${_insights.value['highest_average_mark'] ?? 0}%',
                    Colors.purple,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Lowest Average Mark',
                    '${_insights.value['lowest_average_mark'] ?? 0}%',
                    Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildPerformanceList(),
          ],
        ),
      ),
    );
  }

  Widget _buildDemographicsSection() {
    final genderData = _insights.value['total_users_by_gender'] as Map? ?? {};
    final raceData = _insights.value['total_users_by_race'] as Map? ?? {};

    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Demographics',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Gender Distribution',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            ...genderData.entries.map((entry) => _buildDistributionItem(
                  entry.key.toString(),
                  entry.value.toString(),
                )),
            const SizedBox(height: 16),
            const Text(
              'Race Distribution',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            ...raceData.entries.map((entry) => _buildDistributionItem(
                  entry.key.toString(),
                  entry.value.toString(),
                )),
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
}
