import 'package:flutter/material.dart';
import 'package:reslocate/grades/grade12.dart';
import 'package:reslocate/grades/grade12IEB.dart';
import 'package:reslocate/grades/grade11.dart';
import 'package:reslocate/grades/grade11IEB.dart';
import 'package:reslocate/grades/grade10.dart';
import 'package:reslocate/grades/grade10IEB.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PastPapers extends StatefulWidget {
  const PastPapers({super.key});

  @override
  _PastPapersState createState() => _PastPapersState();
}

// Inside your PastPapers widget

class _PastPapersState extends State<PastPapers> {
  bool _isGrade12Expanded = true; // Default Grade 12 is expanded
  bool _isGrade11Expanded = false;
  bool _isGrade10Expanded = false;

  void _toggleExpansion(String grade) {
    setState(() {
      if (grade == 'Grade 12') {
        _isGrade12Expanded = true;
        _isGrade11Expanded = false;
        _isGrade10Expanded = false;
      } else if (grade == 'Grade 11') {
        _isGrade12Expanded = false;
        _isGrade11Expanded = true;
        _isGrade10Expanded = false;
      } else if (grade == 'Grade 10') {
        _isGrade12Expanded = false;
        _isGrade11Expanded = false;
        _isGrade10Expanded = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Getting screen dimensions for responsiveness
    double screenWidth = MediaQuery.of(context).size.width;
    double buttonWidth =
        screenWidth * 0.35; // Button width adapts to screen size
    double buttonHeight = 120; // Fixed height

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
            const SizedBox(height: 20), // Increased spacing
            const Text(
              'Select your grade and curriculum',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D47A1),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Grade 12 section
            InkWell(
              onTap: () => _toggleExpansion('Grade 12'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(
                            20.0), // Add padding of 16.0 on all sides
                        child: Text(
                          'Grade 12',
                          style: TextStyle(
                            fontSize: 16,
                            color: _isGrade12Expanded
                                ? const Color(0xFF0D47A1)
                                : Colors.black,
                            fontWeight: _isGrade12Expanded
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_isGrade12Expanded) ...[
                    const SizedBox(height: 20),
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
                          width: buttonWidth,
                          height: buttonHeight,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Grade12Page()),
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
                          width: buttonWidth,
                          height: buttonHeight,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Grade12IEBPage()),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                  ],
                ],
              ),
            ),
            const Divider(), // Divider between grade sections

            // Grade 11 section
            InkWell(
              onTap: () => _toggleExpansion('Grade 11'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(
                            20.0), // Add padding of 16.0 on all sides
                        child: Text(
                          'Grade 11',
                          style: TextStyle(
                            fontSize: 16,
                            color: _isGrade11Expanded
                                ? const Color(0xFF0D47A1)
                                : Colors.black,
                            fontWeight: _isGrade11Expanded
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_isGrade11Expanded) ...[
                    const SizedBox(height: 20),
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
                          width: buttonWidth,
                          height: buttonHeight,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Grade11Page()),
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
                          width: buttonWidth,
                          height: buttonHeight,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Grade11IEBPage()),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                  ],
                ],
              ),
            ),
            const Divider(), // Divider between grade sections

            // Grade 10 section
            InkWell(
              onTap: () => _toggleExpansion('Grade 10'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(
                            20.0), // Add padding of 16.0 on all sides
                        child: Text(
                          'Grade 10',
                          style: TextStyle(
                            fontSize: 16,
                            color: _isGrade10Expanded
                                ? const Color(0xFF0D47A1)
                                : Colors.black,
                            fontWeight: _isGrade10Expanded
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_isGrade10Expanded) ...[
                    const SizedBox(height: 20),
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
                          width: buttonWidth,
                          height: buttonHeight,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Grade10Page()),
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
                          width: buttonWidth,
                          height: buttonHeight,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Grade10IEBPage()),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                  ],
                ],
              ),
            ),
            const Divider(), // Divider after Grade 10 section
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
    required double width,
    required double height,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      splashColor: Colors.transparent, // Remove line/splash effect
      highlightColor: Colors.transparent, // Remove highlight color
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: height,
        width: width,
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
