import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:reslocate/grades/grade10.dart';
import 'package:reslocate/grades/grade10IEB.dart';
import 'package:reslocate/grades/grade11.dart';
import 'package:reslocate/grades/grade11IEB.dart';
import 'package:reslocate/grades/grade12.dart';
import 'package:reslocate/grades/grade12IEB.dart';

class GradeSearchPage extends StatefulWidget {
  final String searchQuery;

  const GradeSearchPage({super.key, required this.searchQuery});

  @override
  _GradeSearchPageState createState() => _GradeSearchPageState();
}

class _GradeSearchPageState extends State<GradeSearchPage> {
  bool _isGrade12Expanded = false;
  bool _isGrade11Expanded = false;
  bool _isGrade10Expanded = false;
  late String _searchQuery;

  @override
  void initState() {
    super.initState();
    _searchQuery = widget.searchQuery.toLowerCase();
  }

  void _toggleExpansion(String grade) {
    setState(() {
      if (grade == 'Grade 12') {
        _isGrade12Expanded = !_isGrade12Expanded;
        _isGrade11Expanded = false;
        _isGrade10Expanded = false;
      } else if (grade == 'Grade 11') {
        _isGrade11Expanded = !_isGrade11Expanded;
        _isGrade12Expanded = false;
        _isGrade10Expanded = false;
      } else if (grade == 'Grade 10') {
        _isGrade10Expanded = !_isGrade10Expanded;
        _isGrade12Expanded = false;
        _isGrade11Expanded = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    List<Map<String, dynamic>> grades = [
      {
        'title': 'Grade 12',
        'isExpanded': _isGrade12Expanded,
        'nscPage': const Grade12Page(),
        'iebPage': const Grade12IEBPage(),
        'nscIcon': Icons.book, // Icon for NSC
        'iebIcon': Icons.assignment, // Icon for IEB
      },
      {
        'title': 'Grade 11',
        'isExpanded': _isGrade11Expanded,
        'nscPage': const Grade11Page(),
        'iebPage': const Grade11IEBPage(),
        'nscIcon': Icons.book, // Icon for NSC
        'iebIcon': Icons.assignment, // Icon for IEB
      },
      {
        'title': 'Grade 10',
        'isExpanded': _isGrade10Expanded,
        'nscPage': const Grade10Page(),
        'iebPage': const Grade10IEBPage(),
        'nscIcon': Icons.book, // Icon for NSC
        'iebIcon': Icons.assignment, // Icon for IEB
      },
    ];

    // Filter grades based on the search query
    var filteredGrades = grades.where((grade) {
      return grade['title'].toLowerCase().contains(_searchQuery);
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 100,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0D47A1)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/images/reslocate_logo.svg',
              height: 50,
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Past Papers',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D47A1),
                  ),
                ),
                Text(
                  'NSC and IEB Exam Papers',
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (filteredGrades.isEmpty)
              const Center(child: Text('No results found for this grade.')),
            if (filteredGrades.isNotEmpty)
              ...filteredGrades.map((grade) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: ElevatedButton(
                        onPressed: () => _toggleExpansion(grade['title']),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: const Color(0xFF0D47A1),
                          elevation: 2,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 50, vertical: 15),
                        ),
                        child: Text(
                          grade['title'],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: grade['isExpanded']
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    if (grade['isExpanded'])
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildAnimatedCard(
                            label: 'NSC',
                            icon: Icons.book_outlined,
                            gradientColors: const [
                              Color(0xFFE3F2FA),
                              Color(0xFFE3F2FA)
                            ],
                            screenWidth: screenWidth, // Pass screen width here
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => grade['nscPage'],
                                ),
                              );
                            },
                          ),
                          _buildAnimatedCard(
                            label: 'IEB',
                            icon: Icons.assignment_outlined,
                            gradientColors: const [
                              Color(0xFFE3F2FA),
                              Color(0xFFE3F2FA)
                            ],
                            screenWidth: screenWidth, // Pass screen width here
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => grade['iebPage'],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    const Divider(),
                  ],
                );
              }),
          ],
        ),
      ),
    );
  }

  // Responsive Animated Card Widget for NSC and IEB
  Widget _buildAnimatedCard({
    required String label,
    required IconData icon,
    required List<Color> gradientColors,
    required double screenWidth, // Ensure screenWidth is passed as an argument
    double buttonWidth = 0.35, // Default width as a fraction of screen width
    double buttonHeight = 120,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      splashColor: Colors.transparent, // Remove line/splash effect
      highlightColor: Colors.transparent, // Remove highlight color
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: buttonHeight,
        width: screenWidth * buttonWidth, // Calculate width using screenWidth
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.black),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
