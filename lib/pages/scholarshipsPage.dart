import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:reslocate/pages/parent_pages/parent_homepage.dart';
import 'package:reslocate/widgets/mytoast.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'homepage.dart';
import 'package:reslocate/widgets/loadingAnimation.dart';

class ScholarshipsPage extends StatefulWidget {
  const ScholarshipsPage({super.key});

  @override
  State<ScholarshipsPage> createState() => _ScholarshipsPageState();
}

class _ScholarshipsPageState extends State<ScholarshipsPage> {
  final SupabaseClient _supabaseClient = Supabase.instance.client;
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> notes = [];
  int _loadedItemsCount = 5;
  static const int _itemsPerPage = 5;

  int? minAverageMark;
  int? minMathMark;
  int? minphysical_sciencesMark;
  int? minAccountingMark;
  int? minEnglishMark;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _fetchUserMarks(); // Fetch the user's marks when the page loads
  }

  void _fetchUserMarks() async {
    try {
      final response = await _supabaseClient
          .from('user_marks')
          .select(
              'average, math_mark, subject2_mark, subject3_mark, home_language_mark')
          .eq('user_id', _supabaseClient.auth.currentUser!.id)
          .single(); // Get a single user's data

      setState(() {
        minAverageMark = response['average'] ?? 0;
        minMathMark = response['math_mark'] ?? 0;
        minphysical_sciencesMark = response['subject2_mark'] ?? 0;
        minAccountingMark = response['subject3_mark'] ?? 0;
        minEnglishMark = response['home_language_mark'] ?? 0;
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

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMoreItems();
    }
  }

  void _loadMoreItems() {
    setState(() {
      _loadedItemsCount += _itemsPerPage;
    });
  }

  void _launchURL(String url) async {
    try {
      // Validate the URL format
      if (!_isValidURL(url)) {
        MyToast.showToast(context, 'Invalid URL or link expired');
        return;
      }

      // Check if the URL can be launched
      if (await canLaunch(url)) {
        await launch(url).catchError((error) {
          debugPrint('Error launching URL: $error');
          MyToast.showToast(
              context, 'Failed to open the link. Please try again.');
        });
      } else {
        MyToast.showToast(
            context, 'Cannot open the link. URL may be incorrect.');
      }
    } catch (e) {
      debugPrint('Unexpected error: $e');
      MyToast.showToast(context, 'An unexpected error occurred.');
    }
  }

  // Helper to validate URL
  bool _isValidURL(String url) {
    final Uri? uri = Uri.tryParse(url);
    return uri != null && (uri.isScheme('http') || uri.isScheme('https'));
  }

  // Show error messages in a Snackbar
  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }

  Stream<List<Map<String, dynamic>>> _getFilteredNotes() {
    return _supabaseClient
        .from('scholarships')
        .select()
        .lte('average', minAverageMark ?? 0)
        .lte('mathematics', minMathMark ?? 0)
        .lte('physical_sciences', minphysical_sciencesMark ?? 0)
        .lte('accounting', minAccountingMark ?? 0)
        .lte('english', minEnglishMark ?? 0)
        .asStream()
        .map((response) {
      return (response as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList();
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0D47A1)),
          onPressed: () async {
            final user = Supabase.instance.client.auth.currentUser;

            if (user != null) {
              // Fetch user role from the database or local storage
              final response = await Supabase.instance.client
                  .from('profiles')
                  .select('role') // Assuming the column is 'role'
                  .eq('id', user.id)
                  .single();

              if (response['role'] == 'parent') {
                // Navigate to ParentHomepage
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ParentHomepage()),
                );
              } else {
                // Navigate to HomePage
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                );
              }
            } else {
              // Handle the case where the user is not logged in (optional)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('User not logged in.')),
              );
            }
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
                  'Scholarships',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D47A1),
                  ),
                ),
                Text(
                  'Financial Aid',
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
      body: Container(
        padding: const EdgeInsets.all(16.0),
        color: Colors.white,
        child: StreamBuilder<List<Map<String, dynamic>>>(
          stream: _getFilteredNotes(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }
            if (!snapshot.hasData) {
              return const Center(child: BouncingImageLoader());
            }
            notes = snapshot.data!;
            final visibleNotes = notes.take(_loadedItemsCount).toList();
            if (visibleNotes.isEmpty) {
              return const Center(
                child: Text(
                  "You do not qualify for any scholarship or bursary at the moment.",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            }
            return ListView.builder(
              controller: _scrollController,
              itemCount: visibleNotes.length + 1,
              itemBuilder: (context, index) {
                if (index == visibleNotes.length) {
                  return Visibility(
                    visible: _loadedItemsCount < notes.length,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Center(
                        child: ElevatedButton(
                          onPressed: _loadMoreItems,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0D47A1),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40.0, vertical: 20.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                          ),
                          child: const Text(
                            'Load More',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }

                final item = visibleNotes[index];
                return Card(
                  elevation: 0,
                  color: const Color(0xFFE3F2FA),
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    title: Text(
                      item['scholarships'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                    subtitle: const Text(
                      'Click to view details',
                      style: TextStyle(color: Colors.black),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => _launchURL(item['scholarship_url']),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
