import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:reslocate/available_courses/getallcourses.dart';
import 'package:reslocate/widgets/university_cards.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:reslocate/widgets/loadingAnimation.dart';

class UniversitySearchPage extends StatefulWidget {
  final String? searchQuery;

  const UniversitySearchPage({super.key, this.searchQuery});

  @override
  _UniversitySearchPageState createState() => _UniversitySearchPageState();
}

class _UniversitySearchPageState extends State<UniversitySearchPage> {
  final SupabaseClient _supabaseClient = Supabase.instance.client;
  List<Widget> universityCards = [];
  List<String> bookmarks2 = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _loadBookmarks();
    await _fetchUniversityCards();
  }

  Future<void> _loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      bookmarks2 = prefs.getStringList('search_bookmarks') ?? [];
    });
  }

  Future<void> _toggleBookmark(String universityName) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (bookmarks2.contains(universityName)) {
        bookmarks2.remove(universityName);
      } else {
        bookmarks2.add(universityName);
      }
    });
    await prefs.setStringList('search_bookmarks', bookmarks2);
    // Refresh the cards to update bookmark status
    await _fetchUniversityCards();
  }

  bool isBookmarked(String universityName) {
    return bookmarks2.contains(universityName);
  }

  Future<void> _fetchUniversityCards() async {
    try {
      final response = await _supabaseClient
          .from('Institutions Information')
          .select('title, city, province, website, image_url');

      setState(() {
        universityCards = response.map((institution) {
          final title = institution['title'] as String;
          return UniversitySearchCard(
            title: institution['title'],
            image_url: institution['image_url'],
            city: institution['city'],
            province: institution['province'],
            website: institution['website'],
            route: GetAvailableAllCouresPage(
              aps: 1000,
              institutionName: title,
            ),
            isBookmarked: isBookmarked(title),
            onBookmarkPressed: () => _toggleBookmark(title),
          );
        }).toList();
        isLoading = false;
      });
    } catch (error) {
      print('Error fetching university cards: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> filteredCards =
        widget.searchQuery != null && widget.searchQuery!.isNotEmpty
            ? universityCards.where((card) {
                String title =
                    (card as UniversitySearchCard).title.toLowerCase().trim();
                String query = widget.searchQuery!.toLowerCase().trim();
                return title.contains(query);
              }).toList()
            : universityCards;

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
                  'Search Results',
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: isLoading
              ? const Center(child: BouncingImageLoader())
              : filteredCards.isNotEmpty
                  ? ListView(
                      children: [
                        const SizedBox(height: 20), // Add spacing at the top
                        ...filteredCards,
                      ],
                    )
                  : const Center(child: Text('No institution found.')),
        ),
      ),
    );
  }
}
