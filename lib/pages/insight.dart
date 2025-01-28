import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:reslocate/widgets/loadingAnimation.dart';

class InsightsPage extends StatefulWidget {
  const InsightsPage({super.key});

  @override
  _InsightsPageState createState() => _InsightsPageState();
}

class _InsightsPageState extends State<InsightsPage> {
  final SupabaseClient _supabaseClient = Supabase.instance.client;
  String mostChosenCourse = '';
  String mostChosenVarsity = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchInsights();
  }

  Future<void> _fetchInsights() async {
    try {
      // Fetch the most chosen first choice course using the rpc function
      final courseResponse =
          await _supabaseClient.rpc('get_most_chosen_course');

      // Ensure we check if courseResponse has data before accessing it
      if (courseResponse.error == null && courseResponse.data.isNotEmpty) {
        mostChosenCourse = courseResponse.data[0]['first_choice_course'] ?? '';
      }

      // Fetch the most chosen first choice varsity using the rpc function
      final varsityResponse =
          await _supabaseClient.rpc('get_most_chosen_varsity');

      // Ensure we check if varsityResponse has data before accessing it
      if (varsityResponse.error == null && varsityResponse.data.isNotEmpty) {
        mostChosenVarsity =
            varsityResponse.data[0]['first_choice_varsity'] ?? '';
      }

      setState(() {
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching insights: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Insights'),
      ),
      body: isLoading
          ? const Center(child: BouncingImageLoader())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Most Chosen Course',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(mostChosenCourse,
                              style: const TextStyle(fontSize: 18)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Most Chosen Varsity',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(mostChosenVarsity,
                              style: const TextStyle(fontSize: 18)),
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
