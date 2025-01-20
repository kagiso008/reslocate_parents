import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:reslocate/available_courses/getAvailableCourses2.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CalculateApsStelliesPage extends StatefulWidget {
  const CalculateApsStelliesPage({super.key});

  @override
  _CalculateApsStelliesPageState createState() =>
      _CalculateApsStelliesPageState();
}

class _CalculateApsStelliesPageState extends State<CalculateApsStelliesPage> {
  final SupabaseClient _supabaseClient = Supabase.instance.client;
  bool isLoading = true;
  Map<String, int?> userMarks = {};
  double? aps;

  @override
  void initState() {
    super.initState();
    _fetchUserMarks();
  }

  Future<void> _fetchUserMarks() async {
    try {
      final response = await _supabaseClient
          .from('user_marks')
          .select(
              'math_mark, subject1_mark, subject2_mark, subject3_mark, subject4_mark, home_language_mark, first_additional_language_mark, second_additional_language_mark')
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
        };
        aps = _calculateAps(userMarks);
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

  double _getApsPoints(double mark) {
    // Calculate APS points directly based on the mark
    return mark;
  }

  double _calculateAps(Map<String, int?> marks) {
    double apsScore = 0.0;

    // Collect all relevant marks
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

    // Remove null values and sort marks in descending order
    final sortedMarks = allMarks
        .where((mark) => mark != null)
        .map((mark) => mark!.toDouble())
        .toList();
    sortedMarks.sort((a, b) => b.compareTo(a));

    // Take the best six marks
    final bestSixMarks = sortedMarks.take(6).toList();
    final averageBestSixMarks = bestSixMarks.isNotEmpty
        ? bestSixMarks.reduce((a, b) => a + b) / bestSixMarks.length
        : 0.0;

    // Calculate APS score based on the average of the best six marks
    apsScore = _getApsPoints(averageBestSixMarks);

    return apsScore;
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
                  'APS',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D47A1),
                  ),
                ),
                Text(
                  'Stellenbosch University',
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
      body: AnimatedContainer(
        duration: const Duration(seconds: 5),
        child: Center(
          child: isLoading
              ? const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Column(
                    children: [
                      // Main APS Card
                      const SizedBox(
                        height: 20,
                      ),

                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                        color: Colors.white,
                        shadowColor: Colors.black.withOpacity(0.5),
                        child: Padding(
                          padding: const EdgeInsets.all(30.0),
                          child: Column(
                            children: [
                              // APS Score Title with Icon
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(width: 10),
                                  Text(
                                    'Your APS Score',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 30),

                              // Animated APS Score Display
                              TweenAnimationBuilder(
                                tween: Tween<double>(begin: 0, end: aps ?? 0),
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

                              // University Name
                              const Text(
                                'Stellenbosch University',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D47A1),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 50,
                            vertical: 20,
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => GetAvailableCoures2Page(
                                    aps: aps ?? 0,
                                    universityName: 'Stellenbosch University')),
                          );
                        },
                        child: const Text('See Available Courses'),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
