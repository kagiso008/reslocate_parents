import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:reslocate/pages/parent_pages/available_college.dart';
import 'package:reslocate/widgets/college_card.dart';
//import 'package:reslocate/widgets/university_cards.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:reslocate/available_courses/getAvailableCollegeCourse.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ParentColleges extends StatefulWidget {
  const ParentColleges({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ParentCollegesState createState() => _ParentCollegesState();
}

class _ParentCollegesState extends State<ParentColleges> {
  final SupabaseClient _supabaseClient = Supabase.instance.client;
  bool isLoading = true;
  Map<String, int?> userMarks = {};
  //int? apsUj;
  //int? apsCput;
  int? aps;

  @override
  void initState() {
    super.initState();
    loadChildData();
    _loadBookmarks(); // Load bookmarks on init
  }

  Future<void> loadChildData() async {
    setState(() {
      isLoading = true; // Show loading animatiog
    });

    String childUserId = await getSelectedChildId();
    await Future.wait([
      _fetchUserMarks(childUserId),
      Future.delayed(const Duration(seconds: 50)),
    ]);

    setState(() {
      isLoading = false; // Hide loading animation
    });
  }

  List<String> bookmarks = []; // To track bookmarked universities

  Future<void> _loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      bookmarks = prefs.getStringList('bookmarks') ?? [];
    });
  }

  Future<void> _toggleBookmark(String universityName) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (bookmarks.contains(universityName)) {
        bookmarks.remove(universityName);
      } else {
        bookmarks.add(universityName);
      }
    });
    await prefs.setStringList('bookmarks', bookmarks);
  }

  bool isBookmarked(String universityName) {
    return bookmarks.contains(universityName);
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

      if (response == null || response['id'] == null) {
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
      final response = await _supabaseClient
          .from('user_marks')
          .select(
              'math_mark, subject1_mark, subject2_mark, subject3_mark, subject4_mark, home_language_mark, first_additional_language_mark, second_additional_language_mark')
          .eq('user_id', childUserId)
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
        aps = _CalculateApsUP(userMarks);
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
        toolbarHeight: 100, // Adjust height for your content
        automaticallyImplyLeading: false, // Disable default leading button
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back,
                  color: Color(0xFF0D47A1)), // Custom back button
              onPressed: () {
                // Navigate back
                Navigator.pop(context);
              },
            ),
            SvgPicture.asset(
              'assets/images/reslocate_logo.svg', // Replace with the correct path to your logo
              height: 50, // Adjust logo size
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TVET Colleges',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D47A1),
                  ),
                ),
                Text(
                  'Matches',
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                CollegeCard(
                  title: 'Central Johannesburg TVET College',
                  logo: 'assets/images/college_images/cjc_logo.jpg',
                  aps: aps ?? 0,
                  courses: "6+",
                  faculties: "",
                  route: ParentGetCollegeCourses(
                      aps: aps ?? 0,
                      collegeName: 'Central Johannesburg TVET College'),
                  isBookmarked:
                      isBookmarked('Central Johannesburg TVET College'),
                  onBookmarkPressed: () =>
                      _toggleBookmark('Central Johannesburg TVET College'),
                ),
                // CPUT card with APS
                const SizedBox(
                  height: 20,
                ),
                CollegeCard(
                  title: 'Ekurhuleni East TVET College',
                  logo:
                      'assets/images/college_images/ekurhuleniEastTVET_logo 2.jpg',
                  aps: aps ?? 0,
                  courses: "6+",
                  faculties: "",
                  route: ParentGetCollegeCourses(
                      aps: aps ?? 0,
                      collegeName: 'ekurhuleni east tvet college'),
                  isBookmarked: isBookmarked('Ekurhuleni East TVET College'),
                  onBookmarkPressed: () =>
                      _toggleBookmark('Ekurhuleni East TVET College'),
                ),
                const SizedBox(height: 20),
                CollegeCard(
                  title: 'Ekurhuleni West TVET College',
                  logo:
                      'assets/images/college_images/ekurhuleni-west-college-logo.jpg',
                  aps: aps ?? 0,
                  courses: "6+",
                  faculties: "",
                  route: ParentGetCollegeCourses(
                      aps: aps ?? 0,
                      collegeName: 'Ekurhuleni West TVET College'),
                  isBookmarked: isBookmarked('Ekurhuleni West TVET College'),
                  onBookmarkPressed: () =>
                      _toggleBookmark('Ekurhuleni West TVET College'),
                ),
                const SizedBox(height: 20),
                CollegeCard(
                  title: 'Sedibeng TVET College',
                  logo: 'assets/images/college_images/sedibeng_logo 2.jpg',
                  aps: aps ?? 0,
                  courses: "6+",
                  faculties: "",
                  route: ParentGetCollegeCourses(
                      aps: aps ?? 0, collegeName: 'Sedibeng TVET College'),
                  isBookmarked: isBookmarked('Sedibeng TVET College'),
                  onBookmarkPressed: () =>
                      _toggleBookmark('Sedibeng TVET College'),
                ),
                const SizedBox(height: 20),
                CollegeCard(
                  title: 'South West Gauteng TVET College',
                  logo:
                      'assets/images/college_images/SouthWestTvetGauteng_logo 2.jpg',
                  aps: aps ?? 0,
                  courses: "6+",
                  faculties: "",
                  route: ParentGetCollegeCourses(
                      aps: aps ?? 0,
                      collegeName: 'South West Gauteng TVET College'),
                  isBookmarked: isBookmarked('South West Gauteng TVET College'),
                  onBookmarkPressed: () =>
                      _toggleBookmark('South West Gauteng TVET College'),
                ),
                const SizedBox(height: 20),
                CollegeCard(
                  title: 'Tshwane North TVET College',
                  logo: 'assets/images/college_images/tshwaneNorth_logo 2.png',
                  aps: aps ?? 0,
                  courses: "6+",
                  faculties: "",
                  route: ParentGetCollegeCourses(
                      aps: aps ?? 0, collegeName: 'Tshwane North TVET College'),
                  isBookmarked: isBookmarked('Tshwane North TVET College'),
                  onBookmarkPressed: () =>
                      _toggleBookmark('Tshwane North TVET College'),
                ),
                const SizedBox(height: 20),
                CollegeCard(
                  title: 'Tshwane South College',
                  logo: 'assets/images/college_images/TshwaneSouth_logo 2.jpg',
                  aps: aps ?? 0,
                  courses: "6+",
                  faculties: "",
                  route: ParentGetCollegeCourses(
                      aps: aps ?? 0, collegeName: 'Tshwane South College'),
                  isBookmarked: isBookmarked('Tshwane South College'),
                  onBookmarkPressed: () =>
                      _toggleBookmark('Tshwane South College'),
                ),
                const SizedBox(height: 20),
                CollegeCard(
                  title: 'Western TVET College',
                  logo: 'assets/images/college_images/Westcol.jpg',
                  aps: aps ?? 0,
                  courses: "6+",
                  faculties: "",
                  route: ParentGetCollegeCourses(
                      aps: aps ?? 0, collegeName: 'Western TVET College'),
                  isBookmarked: isBookmarked('Western TVET College'),
                  onBookmarkPressed: () =>
                      _toggleBookmark('Western TVET College'),
                ),
                const SizedBox(height: 20),
                CollegeCard(
                  title: 'Coastal KZN TVET College',
                  logo: 'assets/images/college_images/coastalTvet_logo 2.jpg',
                  aps: aps ?? 0,
                  courses: "6+",
                  faculties: "",
                  route: ParentGetCollegeCourses(
                      aps: aps ?? 0, collegeName: 'Coastal KZN TVET College'),
                  isBookmarked: isBookmarked('Coastal KZN TVET College'),
                  onBookmarkPressed: () =>
                      _toggleBookmark('Coastal KZN TVET College'),
                ),
                const SizedBox(height: 20),
                CollegeCard(
                  title: 'Elangeni TVET College',
                  logo: 'assets/images/college_images/ElangeniTvet_logo 2.jpg',
                  aps: aps ?? 0,
                  courses: "6+",
                  faculties: "",
                  route: ParentGetCollegeCourses(
                      aps: aps ?? 0, collegeName: 'Elangeni TVET College'),
                  isBookmarked: isBookmarked('Elangeni TVET College'),
                  onBookmarkPressed: () =>
                      _toggleBookmark('Elangeni TVET College'),
                ),
                const SizedBox(height: 20),
                CollegeCard(
                  title: 'Esayidi TVET College',
                  logo: 'assets/images/college_images/esayidiTvet_logo.png',
                  aps: aps ?? 0,
                  courses: "6+",
                  faculties: "",
                  route: ParentGetCollegeCourses(
                      aps: aps ?? 0, collegeName: 'Esayidi TVET College'),
                  isBookmarked: isBookmarked('Esayidi TVET College'),
                  onBookmarkPressed: () =>
                      _toggleBookmark('Esayidi TVET College'),
                ),
                const SizedBox(height: 20),
                CollegeCard(
                  title: 'Majuba TVET College',
                  logo: 'assets/images/college_images/majuba_logo 2.png',
                  aps: aps ?? 0,
                  courses: "6+",
                  faculties: "",
                  route: ParentGetCollegeCourses(
                      aps: aps ?? 0, collegeName: 'Majuba TVET College'),
                  isBookmarked: isBookmarked('Majuba TVET College'),
                  onBookmarkPressed: () =>
                      _toggleBookmark('Majuba TVET College'),
                ),
                const SizedBox(height: 20),
                CollegeCard(
                  title: 'Mnambithi TVET College',
                  logo: 'assets/images/college_images/mnambithi_logo 2.png',
                  aps: aps ?? 0,
                  courses: "6+",
                  faculties: "",
                  route: ParentGetCollegeCourses(
                      aps: aps ?? 0, collegeName: 'Mnambithi TVET College'),
                  isBookmarked: isBookmarked('Mnambithi TVET College'),
                  onBookmarkPressed: () =>
                      _toggleBookmark('Mnambithi TVET College'),
                ),
                const SizedBox(height: 20),
                CollegeCard(
                  title: 'Mthashana TVET College',
                  logo: 'assets/images/college_images/mthashana_logo 2.jpg',
                  aps: aps ?? 0,
                  courses: "6+",
                  faculties: "",
                  route: ParentGetCollegeCourses(
                      aps: aps ?? 0, collegeName: 'Mthashana TVET College'),
                  isBookmarked: isBookmarked('Mthashana TVET College'),
                  onBookmarkPressed: () =>
                      _toggleBookmark('Mthashana TVET College'),
                ),
                const SizedBox(height: 20),
                CollegeCard(
                  title: 'uMfolozi TVET College',
                  logo: 'assets/images/college_images/umfolozi-logo.png',
                  aps: aps ?? 0,
                  courses: "6+",
                  faculties: "",
                  route: ParentGetCollegeCourses(
                      aps: aps ?? 0, collegeName: 'uMfolozi TVET College'),
                  isBookmarked: isBookmarked('uMfolozi TVET College'),
                  onBookmarkPressed: () =>
                      _toggleBookmark('uMfolozi TVET College'),
                ),
                const SizedBox(height: 20),
                CollegeCard(
                  title: 'Umgungundlovu TVET College',
                  logo:
                      'assets/images/college_images/UmgungundlovuTvet_logo.png',
                  aps: aps ?? 0,
                  courses: "6+",
                  faculties: "",
                  route: ParentGetCollegeCourses(
                      aps: aps ?? 0, collegeName: 'Umgungundlovu TVET College'),
                  isBookmarked: isBookmarked('Umgungundlovu TVET College'),
                  onBookmarkPressed: () =>
                      _toggleBookmark('Umgungundlovu TVET College'),
                ),
                const SizedBox(height: 20),
                CollegeCard(
                  title: 'Boland TVET College',
                  logo: 'assets/images/college_images/bolandcollege_logo.png',
                  aps: aps ?? 0,
                  courses: "6+",
                  faculties: "",
                  route: ParentGetCollegeCourses(
                      aps: aps ?? 0, collegeName: 'Boland TVET College'),
                  isBookmarked: isBookmarked('Boland TVET College'),
                  onBookmarkPressed: () =>
                      _toggleBookmark('Boland TVET College'),
                ),
                const SizedBox(height: 20),
                CollegeCard(
                  title: 'College of Cape Town',
                  logo: 'assets/images/college_images/collegeOfCT_logo 2.png',
                  aps: aps ?? 0,
                  courses: "6+",
                  faculties: "",
                  route: ParentGetCollegeCourses(
                      aps: aps ?? 0, collegeName: 'College of Cape Town'),
                  isBookmarked: isBookmarked('College of Cape Town'),
                  onBookmarkPressed: () =>
                      _toggleBookmark('College of Cape Town'),
                ),
                const SizedBox(height: 20),
                CollegeCard(
                  title: 'False Bay College',
                  logo:
                      'assets/images/college_images/FalseBayCollege_logo 2.png',
                  aps: aps ?? 0,
                  courses: "6+",
                  faculties: "",
                  route: ParentGetCollegeCourses(
                      aps: aps ?? 0, collegeName: 'False Bay College'),
                  isBookmarked: isBookmarked('False Bay College'),
                  onBookmarkPressed: () => _toggleBookmark('False Bay College'),
                ),
                const SizedBox(height: 20),
                CollegeCard(
                  title: 'Northlink TVET College',
                  logo:
                      'assets/images/college_images/NorthLinkCollege_logo.jpg',
                  aps: aps ?? 0,
                  courses: "6+",
                  faculties: "",
                  route: ParentGetCollegeCourses(
                      aps: aps ?? 0, collegeName: 'Northlink TVET College'),
                  isBookmarked: isBookmarked('Northlink TVET College'),
                  onBookmarkPressed: () =>
                      _toggleBookmark('Northlink TVET College'),
                ),
                const SizedBox(height: 20),
                CollegeCard(
                  title: 'South Cape TVET College',
                  logo: 'assets/images/college_images/SouthCapeTVET_logo 2.png',
                  aps: aps ?? 0,
                  courses: "6+",
                  faculties: "",
                  route: ParentGetCollegeCourses(
                      aps: aps ?? 0, collegeName: 'South Cape TVET College'),
                  isBookmarked: isBookmarked('South Cape TVET College'),
                  onBookmarkPressed: () =>
                      _toggleBookmark('South Cape TVET College'),
                ),
                const SizedBox(height: 20),
                CollegeCard(
                  title: 'Thekwini TVET College',
                  logo: 'assets/images/college_images/Thekwini.jpg',
                  aps: aps ?? 0,
                  courses: "6+",
                  faculties: "",
                  route: ParentGetCollegeCourses(
                      aps: aps ?? 0, collegeName: 'Thekwini TVET College'),
                  isBookmarked: isBookmarked('Thekwini TVET College'),
                  onBookmarkPressed: () =>
                      _toggleBookmark('Thekwini TVET College'),
                ),
                const SizedBox(height: 20),
                CollegeCard(
                  title: 'Mopani South East TVET College',
                  logo:
                      'assets/images/college_images/mopaniSouthEast_logo 2.jpg',
                  aps: aps ?? 0,
                  courses: "6+",
                  faculties: "",
                  route: ParentGetCollegeCourses(
                      aps: aps ?? 0,
                      collegeName: 'Mopani South East TVET College'),
                  isBookmarked: isBookmarked('Mopani South East TVET College'),
                  onBookmarkPressed: () =>
                      _toggleBookmark('Mopani South East TVET College'),
                ),
                const SizedBox(height: 20),
                CollegeCard(
                  title: 'Buffalo City TVET College',
                  logo: 'assets/images/college_images/Buffalo-tvet_logo.jpg',
                  aps: aps ?? 0,
                  courses: "6+",
                  faculties: "",
                  route: ParentGetCollegeCourses(
                      aps: aps ?? 0, collegeName: 'Buffalo City TVET College'),
                  isBookmarked: isBookmarked('Buffalo City TVET College'),
                  onBookmarkPressed: () =>
                      _toggleBookmark('Buffalo City TVET College'),
                ),
                const SizedBox(height: 20),
                CollegeCard(
                  title: 'Eastcape Midlands TVET College',
                  logo: 'assets/images/college_images/EastcapeTvet_Logo.jpg',
                  aps: aps ?? 0,
                  courses: "6+",
                  faculties: "",
                  route: ParentGetCollegeCourses(
                      aps: aps ?? 0,
                      collegeName: 'Eastcape Midlands TVET College'),
                  isBookmarked: isBookmarked('Eastcape Midlands TVET College'),
                  onBookmarkPressed: () =>
                      _toggleBookmark('Eastcape Midlands TVET College'),
                ),
                const SizedBox(height: 20),
                CollegeCard(
                  title: 'Ingwe TVET College',
                  logo: 'assets/images/college_images/IngweTvet_logo 2.png',
                  aps: aps ?? 0,
                  courses: "6+",
                  faculties: "",
                  route: ParentGetCollegeCourses(
                      aps: aps ?? 0, collegeName: 'Ingwe TVET College'),
                  isBookmarked: isBookmarked('Ingwe TVET College'),
                  onBookmarkPressed: () =>
                      _toggleBookmark('Ingwe TVET College'),
                ),
                const SizedBox(height: 20),
                CollegeCard(
                  title: 'King Hintsa TVET College',
                  logo:
                      'assets/images/college_images/college-kinghintsa-logo.jpg',
                  aps: aps ?? 0,
                  courses: "6+",
                  faculties: "",
                  route: ParentGetCollegeCourses(
                      aps: aps ?? 0, collegeName: 'King Hintsa TVET College'),
                  isBookmarked: isBookmarked('King Hintsa TVET College'),
                  onBookmarkPressed: () =>
                      _toggleBookmark('King Hintsa TVET College'),
                ),
                const SizedBox(height: 20),
                CollegeCard(
                  title: 'King Sabata Dalindyebo TVET College',
                  logo:
                      'assets/images/college_images/king_sabata_tvet_logo.png',
                  aps: aps ?? 0,
                  courses: "6+",
                  faculties: "",
                  route: ParentGetCollegeCourses(
                      aps: aps ?? 0,
                      collegeName: 'King Sabata Dalindyebo TVET College'),
                  isBookmarked:
                      isBookmarked('King Sabata Dalindyebo TVET College'),
                  onBookmarkPressed: () =>
                      _toggleBookmark('King Sabata Dalindyebo TVET College'),
                ),
                const SizedBox(height: 20),
                CollegeCard(
                  title: 'Lovedale TVET College',
                  logo:
                      'assets/images/college_images/Lovedale-TVET-College-logo.png',
                  aps: aps ?? 0,
                  courses: "6+",
                  faculties: "",
                  route: ParentGetCollegeCourses(
                      aps: aps ?? 0, collegeName: 'Lovedale TVET College'),
                  isBookmarked: isBookmarked('Lovedale TVET College'),
                  onBookmarkPressed: () =>
                      _toggleBookmark('Lovedale TVET College'),
                ),
                const SizedBox(height: 20),
                CollegeCard(
                  title: 'Port Elizabeth TVET College',
                  logo:
                      'assets/images/college_images/port-elizabeth-tvet-college-logo.jpg',
                  aps: aps ?? 0,
                  courses: "6+",
                  faculties: "",
                  route: ParentGetCollegeCourses(
                      aps: aps ?? 0,
                      collegeName: 'Port Elizabeth TVET College'),
                  isBookmarked: isBookmarked('Port Elizabeth TVET College'),
                  onBookmarkPressed: () =>
                      _toggleBookmark('Port Elizabeth TVET College'),
                ),
                const SizedBox(height: 20),
                CollegeCard(
                  title: 'Flavius Mareka TVET College',
                  logo:
                      'assets/images/college_images/Flavius_Mareka_Tvet_logo 2.png',
                  aps: aps ?? 0,
                  courses: "6+",
                  faculties: "",
                  route: ParentGetCollegeCourses(
                      aps: aps ?? 0,
                      collegeName: 'Flavius Mareka TVET College'),
                  isBookmarked: isBookmarked('Flavius Mareka TVET College'),
                  onBookmarkPressed: () =>
                      _toggleBookmark('Flavius Mareka TVET College'),
                ),
                const SizedBox(height: 20),
                CollegeCard(
                  title: 'Goldfields TVET College',
                  logo:
                      'assets/images/college_images/Goldfields_Tvet_logo 2.jpg',
                  aps: aps ?? 0,
                  courses: "6+",
                  faculties: "",
                  route: ParentGetCollegeCourses(
                      aps: aps ?? 0, collegeName: 'Goldfields TVET College'),
                  isBookmarked: isBookmarked('Goldfields TVET College'),
                  onBookmarkPressed: () =>
                      _toggleBookmark('Goldfields TVET College'),
                ),
                const SizedBox(height: 20),
                CollegeCard(
                  title: 'Maluti TVET College',
                  logo:
                      'assets/images/college_images/Maluti-TVET-College_logo.jpg',
                  aps: aps ?? 0,
                  courses: "6+",
                  faculties: "",
                  route: ParentGetCollegeCourses(
                      aps: aps ?? 0, collegeName: 'Maluti TVET College'),
                  isBookmarked: isBookmarked('Maluti TVET College'),
                  onBookmarkPressed: () =>
                      _toggleBookmark('Maluti TVET College'),
                ),
                const SizedBox(height: 20),
                CollegeCard(
                  title: 'Motheo TVET College',
                  logo: 'assets/images/college_images/Motheo_tvet_logo.png',
                  aps: aps ?? 0,
                  courses: "6+",
                  faculties: "",
                  route: ParentGetCollegeCourses(
                      aps: aps ?? 0, collegeName: 'Motheo TVET College'),
                  isBookmarked: isBookmarked('Motheo TVET College'),
                  onBookmarkPressed: () =>
                      _toggleBookmark('Motheo TVET College'),
                ),
                const SizedBox(height: 20),
                CollegeCard(
                  title: 'Capricorn TVET College',
                  logo:
                      'assets/images/college_images/capricorn_tvet_logo 2.jpg',
                  aps: aps ?? 0,
                  courses: "6+",
                  faculties: "",
                  route: ParentGetCollegeCourses(
                      aps: aps ?? 0, collegeName: 'Capricorn TVET College'),
                  isBookmarked: isBookmarked('Capricorn TVET College'),
                  onBookmarkPressed: () =>
                      _toggleBookmark('Capricorn TVET College'),
                ),
                const SizedBox(height: 20),
                CollegeCard(
                  title: 'Lephalale TVET College',
                  logo: 'assets/images/college_images/lephalale_tvet_logo.png',
                  aps: aps ?? 0,
                  courses: "6+",
                  faculties: "",
                  route: ParentGetCollegeCourses(
                      aps: aps ?? 0, collegeName: 'Lephalale TVET College'),
                  isBookmarked: isBookmarked('Lephalale TVET College'),
                  onBookmarkPressed: () =>
                      _toggleBookmark('Lephalale TVET College'),
                ),
                const SizedBox(height: 20),
                CollegeCard(
                  title: 'Letaba TVET College',
                  logo:
                      'assets/images/college_images/letaba-tvet-college-logo 2.png',
                  aps: aps ?? 0,
                  courses: "6+",
                  faculties: "",
                  route: ParentGetCollegeCourses(
                      aps: aps ?? 0, collegeName: 'Letaba TVET College'),
                  isBookmarked: isBookmarked('Letaba TVET College'),
                  onBookmarkPressed: () =>
                      _toggleBookmark('Letaba TVET College'),
                ),
                const SizedBox(height: 20),
                CollegeCard(
                  title: 'Lovedale TVET College',
                  logo:
                      'assets/images/college_images/Lovedale-TVET-College-logo.png',
                  aps: aps ?? 0,
                  courses: "6+",
                  faculties: "",
                  route: ParentGetCollegeCourses(
                      aps: aps ?? 0, collegeName: 'Lovedale TVET College'),
                  isBookmarked: isBookmarked('Lovedale TVET College'),
                  onBookmarkPressed: () =>
                      _toggleBookmark('Lovedale TVET College'),
                ),
                const SizedBox(height: 20),
                CollegeCard(
                  title: 'Sekhukhune TVET College',
                  logo: 'assets/images/college_images/sekhukhuneTvet_logo.jpg',
                  aps: aps ?? 0,
                  courses: "6+",
                  faculties: "",
                  route: ParentGetCollegeCourses(
                      aps: aps ?? 0, collegeName: 'Sekhukhune TVET College'),
                  isBookmarked: isBookmarked('Sekhukhune TVET College'),
                  onBookmarkPressed: () =>
                      _toggleBookmark('Sekhukhune TVET College'),
                ),
                const SizedBox(height: 20),
                CollegeCard(
                  title: 'Vhembe TVET College',
                  logo: 'assets/images/college_images/vhembeTvet_logo 2.jpg',
                  aps: aps ?? 0,
                  courses: "6+",
                  faculties: "",
                  route: ParentGetCollegeCourses(
                      aps: aps ?? 0, collegeName: 'Vhembe TVET College'),
                  isBookmarked: isBookmarked('Vhembe TVET College'),
                  onBookmarkPressed: () =>
                      _toggleBookmark('Vhembe TVET College'),
                ),
                const SizedBox(height: 20),
                CollegeCard(
                  title: 'Waterberg TVET College',
                  logo: 'assets/images/college_images/WaterBurgTvet_logo 2.png',
                  aps: aps ?? 0,
                  courses: "6+",
                  faculties: "",
                  route: ParentGetCollegeCourses(
                      aps: aps ?? 0, collegeName: 'Waterberg TVET College'),
                  isBookmarked: isBookmarked('Waterberg TVET College'),
                  onBookmarkPressed: () =>
                      _toggleBookmark('Waterberg TVET College'),
                ),
                const SizedBox(height: 20),
                CollegeCard(
                  title: 'Ehlanzeni TVET College',
                  logo:
                      'assets/images/college_images/Ehlanzeni-TVET-College-logo.jpg',
                  aps: aps ?? 0,
                  courses: "6+",
                  faculties: "",
                  route: ParentGetCollegeCourses(
                      aps: aps ?? 0, collegeName: 'Ehlanzeni TVET College'),
                  isBookmarked: isBookmarked('Ehlanzeni TVET College'),
                  onBookmarkPressed: () =>
                      _toggleBookmark('Ehlanzeni TVET College'),
                ),
                const SizedBox(height: 20),
                CollegeCard(
                  title: 'Gert Sibande TVET College',
                  logo: 'assets/images/college_images/Gert_Sibande_logo.png',
                  aps: aps ?? 0,
                  courses: "6+",
                  faculties: "",
                  route: ParentGetCollegeCourses(
                      aps: aps ?? 0, collegeName: 'Gert Sibande TVET College'),
                  isBookmarked: isBookmarked('Gert Sibande TVET College'),
                  onBookmarkPressed: () =>
                      _toggleBookmark('Gert Sibande TVET College'),
                ),
                const SizedBox(height: 20),
                CollegeCard(
                  title: 'Nkangala TVET College',
                  logo: 'assets/images/college_images/nkangala_Tvet_logo.png',
                  aps: aps ?? 0,
                  courses: "6+",
                  faculties: "",
                  route: ParentGetCollegeCourses(
                      aps: aps ?? 0, collegeName: 'Nkangala TVET College'),
                  isBookmarked: isBookmarked('Nkangala TVET College'),
                  onBookmarkPressed: () =>
                      _toggleBookmark('Nkangala TVET College'),
                ),
                const SizedBox(height: 20),
                CollegeCard(
                  title: 'Northern Cape Urban TVET College',
                  logo: 'assets/images/college_images/NCUTtvet_logo.jpg',
                  aps: aps ?? 0,
                  courses: "6+",
                  faculties: "",
                  route: ParentGetCollegeCourses(
                      aps: aps ?? 0,
                      collegeName: 'Northern Cape Urban TVET College'),
                  isBookmarked:
                      isBookmarked('Northern Cape Urban TVET College'),
                  onBookmarkPressed: () =>
                      _toggleBookmark('Northern Cape Urban TVET College'),
                ),
                const SizedBox(height: 20),
                CollegeCard(
                  title: 'Orbit TVET College',
                  logo: 'assets/images/college_images/orbitTvet_logo 2.jpg',
                  aps: aps ?? 0,
                  courses: "6+",
                  faculties: "",
                  route: ParentGetCollegeCourses(
                      aps: aps ?? 0, collegeName: 'Orbit TVET College'),
                  isBookmarked: isBookmarked('Orbit TVET College'),
                  onBookmarkPressed: () =>
                      _toggleBookmark('Orbit TVET College'),
                ),
                const SizedBox(height: 20),
                CollegeCard(
                  title: 'Taletso TVET College',
                  logo: 'assets/images/college_images/taletso_logo.jpg',
                  aps: aps ?? 0,
                  courses: "6+",
                  faculties: "",
                  route: ParentGetCollegeCourses(
                      aps: aps ?? 0, collegeName: 'Taletso TVET College'),
                  isBookmarked: isBookmarked('Taletso TVET College'),
                  onBookmarkPressed: () =>
                      _toggleBookmark('Taletso TVET College'),
                ),
                const SizedBox(height: 20),
                CollegeCard(
                  title: 'Vuselela TVET College',
                  logo: 'assets/images/college_images/VuselelaTvet_logo.png',
                  aps: aps ?? 0,
                  courses: "6+",
                  faculties: "",
                  route: ParentGetCollegeCourses(
                      aps: aps ?? 0, collegeName: 'Vuselela TVET College'),
                  isBookmarked: isBookmarked('Vuselela TVET College'),
                  onBookmarkPressed: () =>
                      _toggleBookmark('Vuselela TVET College'),
                ),
                const SizedBox(height: 20),
                CollegeCard(
                  title: 'West Coast TVET College',
                  logo:
                      'assets/images/college_images/west_coast_college_logo 2.jpg',
                  aps: aps ?? 0,
                  courses: "6+",
                  faculties: "",
                  route: ParentGetCollegeCourses(
                      aps: aps ?? 0, collegeName: 'West Coast TVET College'),
                  isBookmarked: isBookmarked('West Coast TVET College'),
                  onBookmarkPressed: () => _toggleBookmark(
                      'West Coast TVET College'), // Replace with the appropriate page
                ),
                const SizedBox(height: 20),
                CollegeCard(
                  title: 'Ikhala TVET College',
                  logo: 'assets/images/college_images/ikhala_tvet_college.jpg',
                  aps: aps ?? 0,
                  courses: "6+",
                  faculties: "",
                  route: ParentGetCollegeCourses(
                      aps: aps ?? 0, collegeName: 'Ikhala TVET College'),
                  isBookmarked: isBookmarked('Ikhala TVET College'),
                  onBookmarkPressed: () => _toggleBookmark(
                      'Ikhala TVET College'), // Replace with the appropriate page
                ),
                const SizedBox(height: 20),
                CollegeCard(
                  title: 'Northern Cape Rural TVET College',
                  logo: 'assets/images/college_images/NCRTvet_logo.jpg',
                  aps: aps ?? 0,
                  courses: "6+",
                  faculties: "",
                  route: ParentGetCollegeCourses(
                      aps: aps ?? 0,
                      collegeName: 'Northern Cape Rural TVET College'),
                  isBookmarked:
                      isBookmarked('Northern Cape Rural TVET College'),
                  onBookmarkPressed: () => _toggleBookmark(
                      'Northern Cape Rural TVET College'), // Replace with the appropriate page
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Custom Button for navigation
  // ignore: unused_element
  Widget _buildCustomButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        elevation: 10,
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 28, color: Colors.white),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 22,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
