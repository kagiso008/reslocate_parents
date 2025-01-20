// ignore_for_file: dead_code

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:reslocate/aps_calculators/nmu_aps.dart';
import 'package:reslocate/aps_calculators/rhodes_aps.dart';
import 'package:reslocate/aps_calculators/stellies_aps.dart';
import 'package:reslocate/aps_calculators/uct_aps.dart';
import 'package:reslocate/aps_calculators/univen_aps.dart';
import 'package:reslocate/aps_calculators/vut_aps.dart';
import 'package:reslocate/available_courses/getAvailableCollegeCourse.dart';
import 'package:reslocate/available_courses/getallcourses.dart';
import 'package:reslocate/pages/homepage.dart';
import 'package:reslocate/pages/parent_pages/getreport.dart';
import 'package:reslocate/pages/parent_pages/parent_homepage.dart';
import 'package:reslocate/pages/parent_pages/parent_profile.dart';
import 'package:reslocate/widgets/college_card.dart';
import 'package:reslocate/widgets/loadingAnimation.dart';
import 'package:reslocate/widgets/mytoast.dart';
import 'package:reslocate/widgets/pnav_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:reslocate/widgets/university_cards.dart';
import 'package:reslocate/available_courses/getAvailableCourses.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Assuming this is needed for the course pages

class ParentBookmarks extends StatefulWidget {
  const ParentBookmarks({super.key});

  @override
  _ParentBookmarksState createState() => _ParentBookmarksState();
}

class _ParentBookmarksState extends State<ParentBookmarks> {
  final SupabaseClient _supabaseClient = Supabase.instance.client;
  Map<String, List<Map<String, dynamic>>> facultyCourses = {};
  Map<String, int> visibleCoursesPerFaculty = {};
  List<String> bookmarks = [];
  List<String> bookmarks2 = [];
  List<Widget> universityCards = [];
  bool isLoading = true; // Track loading state
  final int _selectedIndex = 2;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _initializeData2();
  }

  Future<void> _initializeData2() async {
    await _loadBookmarks2();
  }

  Future<void> _loadBookmarks2() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      bookmarks2 = prefs.getStringList('search_bookmarks') ?? [];
    });
    await _fetchUniversityCards2();
  }

  Future<void> _toggleBookmark2(String universityName) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (bookmarks2.contains(universityName)) {
        bookmarks2.remove(universityName);
      } else {
        bookmarks2.add(universityName);
      }
    });
    await prefs.setStringList('search_bookmarks', bookmarks2);
    // Refresh the cards
    await _fetchUniversityCards2();
  }

  Future<void> _clearBookmarks2() async {}

  Future<void> _fetchUniversityCards2() async {
    if (bookmarks2.isEmpty) {
      setState(() {
        universityCards = [];
        isLoading = false;
      });
      return;
    }

    try {
      final response = await _supabaseClient
          .from('Institutions Information')
          .select('title, city, province, website, image_url');

      setState(() {
        universityCards = response
            .where((institution) => bookmarks2.contains(institution['title']))
            .map((institution) {
          final title = institution['title'] as String;
          return UniversitySearchCard(
            title: title,
            image_url: institution['image_url'],
            city: institution['city'],
            province: institution['province'],
            website: institution['website'],
            route: GetAvailableAllCouresPage(
              aps: 1000,
              institutionName: title,
            ),
            isBookmarked: true, // Always true in bookmarks page
            onBookmarkPressed: () => _toggleBookmark2(title),
          );
        }).toList();
        isLoading = false;
      });
    } catch (error) {
      print('Error fetching bookmarked universities: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  bool isBookmarked2(String universityName) {
    return bookmarks2.contains(universityName);
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

  Future<void> clearBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('bookmarks');
    await prefs.remove('search_bookmarks');

    setState(() {
      bookmarks.clear(); // Clear the list in the UI
      bookmarks2.clear();
      universityCards.clear();
    });
    // ignore: use_build_context_synchronously
    MyToast.showToast(context, 'All bookmarks removed successfully');
  }

  Future<void> _loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      bookmarks = prefs.getStringList('bookmarks') ?? [];
    });
  }

  Future<void> _initializeData() async {
    setState(() {
      isLoading = true; // Show loading animation
    });

    // Wait for all your functions to complete using Future.wait
    await Future.wait([
      _fetchUserMarks_uj(),
      _fetchUserMarksCput(),
      _fetchUserMarks_spu(),
      _fetchUserMarks_ufh(),
      _fetchUserMarks_mut(),
      _fetchUserMarks_ufs(),
      _fetchUserMarks_uz(),
      _fetchUserMarks_cut(),
      _fetchUserMarks_wsu(),
      _fetchUserMarks_smu(),
      _fetchUserMarks_lo(),
      _fetchUserMarks_wits(),
      _fetchUserMarks_ukzn(),
      _fetchUserMarks_ump(),
      _loadBookmarks(), // Load bookmarks on init
      _fetchAvailableCourses_uj(),
      _fetchAvailableCourses_up(),
      _fetchAvailableCourses_cput(),
      _fetchAvailableCourses_wits(),
      _fetchAvailableCourses_ukzn(),
      _fetchAvailableCourses_nwu(),
      _fetchAvailableCourses_nmu(),
      _fetchAvailableCourses_ul(),
      _fetchAvailableCourses_uwc(),
      _fetchAvailableCourses_tut(),
      _fetchAvailableCourses_stllies(),
      _fetchAvailableCourses_smu(),
      _fetchAvailableCourses_dut(),
      _fetchAvailableCourses_wsu(),
      _fetchAvailableCourses_rhodes(),
      _fetchAvailableCourses_cut(),
      _fetchAvailableCourses_ufs(),
      _fetchAvailableCourses_uct(),
      _fetchAvailableCourses_uz(),
      _fetchAvailableCourses_uv(),
      _fetchAvailableCourses_mut(),
      _fetchAvailableCourses_vut(),
      _fetchAvailableCourses_ufh(),
      _fetchAvailableCourses_spu(),
      _fetchAvailableCourses_ump(),
      Future.delayed(const Duration(seconds: 50)),
    ]);

    // Once all the functions are done
    setState(() {
      isLoading = false; // Hide loading animation
    });
  }

  int ujCourses = 0; //
  int ujFaculties = 0; //
  int umpCourses = 0; //
  int umpFaculties = 0; //
  int upCourses = 0; //
  int upFaculties = 0; //
  int cputCourses = 0; //
  int cputFaculties = 0; //
  int spuCourses = 0; //
  int spuFaculties = 0; //
  int ufhCourses = 0; //
  int ufhFaculties = 0; //
  int vutCourses = 0; //
  int vutFaculties = 0; //
  int mutCourses = 0; //
  int mutFaculties = 0; //
  int univenCourses = 0; //
  int univenFaculties = 0; //
  int unizuluCourses = 0; //
  int unizuluFaculties = 0; //
  int uctCourses = 0; //
  int uctFaculties = 0; //
  int ufsCourses = 0; //
  int ufsFaculties = 0; //
  int cutCourses = 0; //
  int cutFaculties = 0; //
  int rhodesCourses = 0; //
  int rhodesFaculties = 0; //
  int wsuCourses = 0; //
  int wsuFaculties = 0; //
  int dutCourses = 0; //
  int dutFaculties = 0; //
  int smuCourses = 0; //
  int smuFaculties = 0; //
  int stelliesCourses = 0; //
  int stelliesFaculties = 0; //
  int tutCourses = 0; //
  int tutFaculties = 0; //
  int uwcCourses = 0; //
  int uwcFaculties = 0; //
  int ulCourses = 0; //
  int ulFaculties = 0; //
  int nmuCourses = 0; //
  int nmuFaculties = 0; //
  int nwuCourses = 0; //
  int nwuFaculties = 0; //
  int witsCourses = 0; //
  int witsFaculties = 0; //
  int ukznCourses = 0; //
  int ukznFaculties = 0; //
  Map<String, int?> userMarks = {};
  Map<String, String?> userSubjects = {};
  int? apsUj;
  int? apsCput;
  int? apsSpu;
  int? apsUfh;
  int? apsMut;
  int? apsUfs;
  int? apsUz;
  int? apsCut;
  int? apsWsu;
  int? apsDut;
  int? apsSmu;
  int? apsUwc;
  int? apsUl;
  int? apsNwu;
  int? apsWits;
  int? apsUkzn;
  int? apsUmp;
  int apsWithLifeOrientation = 0;
  int? lifeOrientationMark;
  int lifeOrientationAps = 0;

  //double? apsUv;
  String? mathType;

  Future<void> _fetchUserMarks_ukzn() async {
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
        apsUkzn = _CalculateApsUkzn(userMarks);
        apsNwu = _CalculateApsNWU(userMarks);
        apsUl = _CalculateULAPS(userMarks);
        apsDut = _CalculateDUTAPS(userMarks);
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
    }
  }

  int _CalculateApsUkzn(Map<String, int?> marks) {
    int apsScore = 0;

    // Add math_mark
    if (marks['math_mark'] != null) {
      apsScore += _getApsPoints_ukzn(marks['math_mark']!);
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
        apsScore += _getApsPoints_ukzn(mark);
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
        apsScore += _getApsPoints_ukzn(mark);
      }
    }

    return apsScore;
  }

  int _getApsPoints_ukzn(int mark) {
    if (mark >= 90) return 8;
    if (mark >= 80) return 7;
    if (mark >= 70) return 6;
    if (mark >= 60) return 5;
    if (mark >= 50) return 4;
    if (mark >= 40) return 3;
    if (mark >= 30) return 2;
    return 1;
  }

  Future<void> _fetchUserMarks_ump() async {
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
        apsUmp = _CalculateApsUmp(userMarks);
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
    }
  }

  int _CalculateApsUmp(Map<String, int?> marks) {
    int apsScore = 0;

    // Add math_mark
    if (marks['math_mark'] != null) {
      apsScore += _getApsPoints_ump(marks['math_mark']!);
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
        apsScore += _getApsPoints_ump(mark);
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
        apsScore += _getApsPoints_ump(mark);
      }
    }

    return apsScore;
  }

  int _getApsPoints_ump(int mark) {
    if (mark >= 90) return 8;
    if (mark >= 80) return 7;
    if (mark >= 70) return 6;
    if (mark >= 60) return 5;
    if (mark >= 50) return 4;
    if (mark >= 40) return 3;
    if (mark >= 30) return 2;
    return 1;
  }

  Future<void> _fetchUserMarks_wits() async {
    try {
      final response = await _supabaseClient
          .from('user_marks')
          .select(
              'math_mark, subject1_mark, subject2_mark, subject3_mark, subject4_mark, home_language_mark, first_additional_language_mark, second_additional_language_mark, life_orientation_mark, math_type, subject1, subject2, subject3, subject4, home_language, first_additional_language, second_additional_language')
          .eq('user_id', _supabaseClient.auth.currentUser!.id)
          .single();

      final homeLanguageMark = response['home_language_mark'];
      final firstAdditionalLanguageMark =
          response['first_additional_language_mark'];
      final secondAdditionalLanguageMark =
          response['second_additional_language_mark'];

      setState(() {
        userMarks = {
          'math_mark': response['math_mark'],
          'subject1_mark': response['subject1_mark'],
          'subject2_mark': response['subject2_mark'],
          'subject3_mark': response['subject3_mark'],
          'subject4_mark': response['subject4_mark'],
          'home_language_mark': homeLanguageMark,
          'first_additional_language_mark': firstAdditionalLanguageMark,
          'second_additional_language_mark': secondAdditionalLanguageMark,
          'life_orientation_mark': response['life_orientation_mark'],
        };

        // Detect subjects
        userSubjects = {
          'subject1': response['subject1'],
          'subject2': response['subject2'],
          'subject3': response['subject3'],
          'subject4': response['subject4'],
          'home_language': response['home_language'],
          'first_additional_language': response['first_additional_language'],
          'second_additional_language': response['second_additional_language'],
        };

        mathType = response['math_type'];

        // Get the best two marks from the language subjects
        final languageMarks = [
          homeLanguageMark,
          firstAdditionalLanguageMark,
          secondAdditionalLanguageMark
        ].where((mark) => mark != null).toList();

        languageMarks
            .sort((a, b) => b!.compareTo(a!)); // Sort in descending order
        final topTwoLanguageMarks = languageMarks.take(2).toList();

        // Update userMarks with the top two language marks
        userMarks['best_language_mark1'] =
            topTwoLanguageMarks.isNotEmpty ? topTwoLanguageMarks[0] : null;
        userMarks['best_language_mark2'] =
            topTwoLanguageMarks.length > 1 ? topTwoLanguageMarks[1] : null;

        // Get the best three marks from subject1 to subject4
        final subjectMarks = [
          response['subject1_mark'],
          response['subject2_mark'],
          response['subject3_mark'],
          response['subject4_mark'],
        ].where((mark) => mark != null).toList();

        subjectMarks
            .sort((a, b) => b!.compareTo(a!)); // Sort in descending order
        final topThreeSubjectMarks = subjectMarks.take(3).toList();

        // Update userMarks with the top three subject marks
        userMarks['best_subject_mark1'] =
            topThreeSubjectMarks.isNotEmpty ? topThreeSubjectMarks[0] : null;
        userMarks['best_subject_mark2'] =
            topThreeSubjectMarks.length > 1 ? topThreeSubjectMarks[1] : null;
        userMarks['best_subject_mark3'] =
            topThreeSubjectMarks.length > 2 ? topThreeSubjectMarks[2] : null;

        apsWits = _calculateApsWits(userMarks, mathType);
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
    }
  }

  int _calculateApsWits(Map<String, int?> marks, String? mathType) {
    int apsScore = 0;

    // Helper function to get APS points based on the mark
    int getApsPoints(int mark) {
      if (mark >= 90) return 8;
      if (mark >= 80) return 7;
      if (mark >= 70) return 6;
      if (mark >= 60) return 5;
      if (mark >= 50) return 4;
      if (mark >= 40) return 3;
      return 0; // Return 0 for marks below 40
    }

    // Collect all relevant marks
    final allMarks = [
      marks['math_mark'],
      marks['best_subject_mark1'],
      marks['best_subject_mark2'],
      marks['best_subject_mark3'],
      marks['best_language_mark1'],
      marks['best_language_mark2'],
    ];

    // Remove null values and calculate APS points
    final validMarks = allMarks
        .where((mark) => mark != null)
        .map((mark) => getApsPoints(mark!))
        .toList();

    // Sort marks in descending order and take the best six
    validMarks.sort((a, b) => b.compareTo(a));
    final bestSixMarks = validMarks.take(6).toList();
    apsScore = bestSixMarks.reduce((a, b) => a + b);

    final mathMark = marks['math_mark'];

    // Apply math type bonus if applicable
    if (mathMark != null && mathType == 'Mathematics' && mathMark >= 60) {
      apsScore += 2;
    }

    // Handle Life Orientation mark
    final lifeOrientationMark = marks['life_orientation_mark'];
    if (lifeOrientationMark != null) {
      if (lifeOrientationMark >= 90) {
        apsScore += 4;
      } else if (lifeOrientationMark >= 80) {
        apsScore += 3;
      } else if (lifeOrientationMark >= 70) {
        apsScore += 2;
      } else if (lifeOrientationMark >= 60) {
        apsScore += 1;
      }
    }

    // Helper function to detect English subject
    int? getEnglishMark() {
      // Check if any of the subjects are "English"
      if (userSubjects['home_language']?.contains('English') == true) {
        return userMarks['home_language_mark'];
      } else if (userSubjects['first_additional_language']
              ?.contains('English') ==
          true) {
        return userMarks['first_additional_language_mark'];
      }
      return null; // If no subject is English
    }

    // Detect if English is a home or first additional language and apply bonus
    final englishMark = getEnglishMark();
    if (englishMark != null && englishMark >= 60) {
      apsScore += 2;
    }

    return apsScore;
  }

  int _CalculateApsNWU(Map<String, int?> marks) {
    int apsScore = 0;

    // Add math_mark
    if (marks['math_mark'] != null) {
      apsScore += _getApsPoints_nwu(marks['math_mark']!);
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
        apsScore += _getApsPoints_nwu(mark);
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
        apsScore += _getApsPoints_nwu(mark);
      }
    }

    return apsScore;
  }

  int _getApsPoints_nwu(int mark) {
    if (mark >= 80) return 8;
    if (mark >= 80) return 7;
    if (mark >= 70) return 6;
    if (mark >= 60) return 5;
    if (mark >= 50) return 4;
    if (mark >= 40) return 3;
    if (mark >= 30) return 2;
    return 1;
  }

  int _CalculateULAPS(Map<String, int?> marks) {
    int apsScore = 0;

    // Add math_mark
    if (marks['math_mark'] != null) {
      apsScore += _getApsPoints_ul(marks['math_mark']!);
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
        apsScore += _getApsPoints_ul(mark);
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
        apsScore += _getApsPoints_ul(mark);
      }
    }

    return apsScore;
  }

  int _getApsPoints_ul(int mark) {
    if (mark >= 80) return 7;
    if (mark >= 70) return 6;
    if (mark >= 60) return 5;
    if (mark >= 50) return 4;
    if (mark >= 40) return 3;
    if (mark >= 30) return 2;
    return 1;
  }

  Future<void> _fetchUserMarks_lo() async {
    try {
      final response = await _supabaseClient
          .from('user_marks')
          .select(
              'math_mark, subject1_mark, subject2_mark, subject3_mark, subject4_mark, home_language_mark, first_additional_language_mark, second_additional_language_mark, life_orientation_mark')
          .eq('user_id', _supabaseClient.auth.currentUser!.id)
          .single();

      final homeLanguageMark = response['home_language_mark'];
      final firstAdditionalLanguageMark =
          response['first_additional_language_mark'];
      final secondAdditionalLanguageMark =
          response['second_additional_language_mark'];

      setState(() {
        userMarks = {
          'math_mark': response['math_mark'],
          'subject1_mark': response['subject1_mark'],
          'subject2_mark': response['subject2_mark'],
          'subject3_mark': response['subject3_mark'],
          'subject4_mark': response['subject4_mark'],
          'home_language_mark': homeLanguageMark,
          'first_additional_language_mark': firstAdditionalLanguageMark,
          'second_additional_language_mark': secondAdditionalLanguageMark,
          'life_orientation_mark': response['life_orientation_mark'],
        };

        // Get the best two marks from the language subjects
        final languageMarks = [
          homeLanguageMark,
          firstAdditionalLanguageMark,
          secondAdditionalLanguageMark
        ].where((mark) => mark != null).toList();

        languageMarks
            .sort((a, b) => b!.compareTo(a!)); // Sort in descending order
        final topTwoLanguageMarks = languageMarks.take(2).toList();

        // Update userMarks with the top two language marks
        userMarks['best_language_mark1'] =
            topTwoLanguageMarks.isNotEmpty ? topTwoLanguageMarks[0] : null;
        userMarks['best_language_mark2'] =
            topTwoLanguageMarks.length > 1 ? topTwoLanguageMarks[1] : null;

        // Get the best three marks from subject1 to subject4
        final subjectMarks = [
          response['subject1_mark'],
          response['subject2_mark'],
          response['subject3_mark'],
          response['subject4_mark'],
        ].where((mark) => mark != null).toList();

        subjectMarks
            .sort((a, b) => b!.compareTo(a!)); // Sort in descending order
        final topThreeSubjectMarks = subjectMarks.take(3).toList();

        // Update userMarks with the top three subject marks
        userMarks['best_subject_mark1'] =
            topThreeSubjectMarks.isNotEmpty ? topThreeSubjectMarks[0] : null;
        userMarks['best_subject_mark2'] =
            topThreeSubjectMarks.length > 1 ? topThreeSubjectMarks[1] : null;
        userMarks['best_subject_mark3'] =
            topThreeSubjectMarks.length > 2 ? topThreeSubjectMarks[2] : null;

        apsUwc = _CalculateApsUWC(userMarks);
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
    }
  }

  int _CalculateApsUWC(Map<String, int?> marks) {
    int apsScore = 0;

    // Helper function to get APS points based on the mark
    int getApsPoints(int mark) {
      if (mark >= 90) return 8;
      if (mark >= 80) return 7;
      if (mark >= 70) return 6;
      if (mark >= 60) return 5;
      if (mark >= 50) return 4;
      if (mark >= 40) return 3;
      if (mark >= 30) return 2;
      if (mark >= 20) return 1;
      return 0; // Return 0 for marks below 40
    }

    // Collect all relevant marks
    final allMarks = [
      marks['math_mark'],
      marks['best_subject_mark1'],
      marks['best_subject_mark2'],
      marks['best_subject_mark3'],
      marks['best_language_mark1'],
      marks['best_language_mark2'],
    ];

    // Remove null values and calculate APS points
    final validMarks = allMarks
        .where((mark) => mark != null)
        .map((mark) => getApsPoints(mark!))
        .toList();

    // Sort marks in descending order and take the best six
    validMarks.sort((a, b) => b.compareTo(a));
    final bestSixMarks = validMarks.take(6).toList();
    apsScore = bestSixMarks.reduce((a, b) => a + b);

    final mathMark = marks['math_mark'];
    final homeLanguageMark = marks['home_language_mark'];

// Handle Mathematics mark
    if (mathMark != null) {
      if (mathMark >= 90) {
        apsScore += 7;
      } else if (mathMark >= 80) {
        apsScore += 6;
      } else if (mathMark >= 70) {
        apsScore += 5;
      } else if (mathMark >= 60) {
        apsScore += 4;
      } else if (mathMark >= 50) {
        apsScore += 3;
      } else if (mathMark >= 40) {
        apsScore += 2;
      } else if (mathMark >= 30) {
        apsScore += 1;
      } else {
        apsScore += 0;
      }
    }

// Handle Home Language mark
    if (homeLanguageMark != null) {
      if (homeLanguageMark >= 90) {
        apsScore += 7;
      } else if (homeLanguageMark >= 80) {
        apsScore += 6;
      } else if (homeLanguageMark >= 70) {
        apsScore += 5;
      } else if (homeLanguageMark >= 60) {
        apsScore += 4;
      } else if (homeLanguageMark >= 50) {
        apsScore += 3;
      } else if (homeLanguageMark >= 40) {
        apsScore += 2;
      } else if (homeLanguageMark >= 30) {
        apsScore += 1;
      } else {
        apsScore += 0;
      }
    }

    // Handle Life Orientation mark
    final lifeOrientationMark = marks['life_orientation_mark'];
    if (lifeOrientationMark != null) {
      if (lifeOrientationMark >= 90) {
        apsScore += 3;
      } else if (lifeOrientationMark >= 80) {
        apsScore += 3;
      } else if (lifeOrientationMark >= 70) {
        apsScore += 2;
      } else if (lifeOrientationMark >= 60) {
        apsScore += 2;
      } else if (lifeOrientationMark >= 50) {
        apsScore += 2;
      } else if (lifeOrientationMark >= 40) {
        apsScore += 1;
      } else if (lifeOrientationMark >= 30) {
        apsScore += 1;
      } else if (lifeOrientationMark >= 20) {
        apsScore += 1;
      } else {
        apsScore += 0;
      }
    }

    return apsScore;
  }

  Future<void> _fetchUserMarks_smu() async {
    try {
      final response = await _supabaseClient
          .from('user_marks')
          .select(
              'math_mark, subject1_mark, subject2_mark, subject3_mark, subject4_mark, home_language_mark, first_additional_language_mark, second_additional_language_mark, life_orientation_mark')
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
        lifeOrientationMark = response['life_orientation_mark'];

        apsSmu = _CalculateSMUAPS(userMarks);
        lifeOrientationAps = lifeOrientationMark != null
            ? _getApsPointsForLifeOrientation(lifeOrientationMark!)
            : 0;
        apsSmu = apsSmu! +
            lifeOrientationAps; // Include Life Orientation APS in total
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
    }
  }

  int _CalculateSMUAPS(Map<String, int?> marks) {
    int apsScore = 0;

    // Add math_mark
    if (marks['math_mark'] != null) {
      apsScore += _getApsPoints_smu(marks['math_mark']!);
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
        apsScore += _getApsPoints_smu(mark);
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
        apsScore += _getApsPoints_smu(mark);
      }
    }

    return apsScore;
  }

  int _getApsPoints_smu(int mark) {
    if (mark >= 80) return 7;
    if (mark >= 70) return 6;
    if (mark >= 60) return 5;
    if (mark >= 50) return 4;
    if (mark >= 40) return 3;
    if (mark >= 30) return 2;
    return 1;
  }

  int _getApsPointsForLifeOrientation_smu(int mark) {
    // Define specific APS points for Life Orientation (usually capped at 3 points)
    if (mark >= 80) return 7;
    if (mark >= 70) return 6;
    if (mark >= 60) return 5;
    if (mark >= 50) return 4;
    if (mark >= 40) return 3;
    if (mark >= 30) return 2;
    return 1;
  }

  int _CalculateDUTAPS(Map<String, int?> marks) {
    int apsScore = 0;

    // Add math_mark
    if (marks['math_mark'] != null) {
      apsScore += _getApsPoints_dut(marks['math_mark']!);
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
        apsScore += _getApsPoints_dut(mark);
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
        apsScore += _getApsPoints_dut(mark);
      }
    }

    return apsScore;
  }

  int _getApsPoints_dut(int mark) {
    if (mark >= 80) return 7;
    if (mark >= 70) return 6;
    if (mark >= 60) return 5;
    if (mark >= 50) return 4;
    if (mark >= 40) return 3;
    if (mark >= 30) return 2;
    return 1;
  }

  Future<void> _fetchUserMarks_wsu() async {
    try {
      final response = await _supabaseClient
          .from('user_marks')
          .select(
              'math_mark, subject1_mark, subject2_mark, subject3_mark, subject4_mark, home_language_mark, first_additional_language_mark, second_additional_language_mark, life_orientation_mark')
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
        lifeOrientationMark = response['life_orientation_mark'];
        apsWsu = _CalculateWSUAPS(userMarks);
        lifeOrientationAps = lifeOrientationMark != null
            ? _getApsPointsForLifeOrientation(lifeOrientationMark!)
            : 0;
        apsWithLifeOrientation = apsWsu! + lifeOrientationAps;
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
    }
  }

  int _CalculateWSUAPS(Map<String, int?> marks) {
    int apsScore = 0;

    // Add math_mark
    if (marks['math_mark'] != null) {
      apsScore += _getApsPoints_wsu(marks['math_mark']!);
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
        apsScore += _getApsPoints_wsu(mark);
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
        apsScore += _getApsPoints_wsu(mark);
      }
    }

    return apsScore;
  }

  int _getApsPoints_wsu(int mark) {
    if (mark >= 90) return 8;
    if (mark >= 80) return 7;
    if (mark >= 70) return 6;
    if (mark >= 60) return 5;
    if (mark >= 50) return 4;
    if (mark >= 40) return 3;
    if (mark >= 30) return 2;
    return 1;
  }

  int _getApsPointsForLifeOrientation_wsu(int mark) {
    if (mark >= 90) return 8;
    if (mark >= 80) return 7;
    if (mark >= 70) return 6;
    if (mark >= 60) return 5;
    if (mark >= 50) return 4;
    if (mark >= 40) return 3;
    if (mark >= 30) return 2;
    return 1;
  }

  Future<void> _fetchUserMarks_cut() async {
    try {
      final response = await _supabaseClient
          .from('user_marks')
          .select(
              'math_mark, subject1_mark, subject2_mark, subject3_mark, subject4_mark, home_language_mark, first_additional_language_mark, second_additional_language_mark, life_orientation_mark')
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
        lifeOrientationMark = response['life_orientation_mark'];
        apsCut = _CalculateCUTAPS(userMarks);
        lifeOrientationAps = lifeOrientationMark != null
            ? _getApsPointsForLifeOrientation(lifeOrientationMark!)
            : 0;
        apsWithLifeOrientation = apsCut! + lifeOrientationAps;
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
    }
  }

  int _CalculateCUTAPS(Map<String, int?> marks) {
    int apsScore = 0;

    // Add math_mark
    if (marks['math_mark'] != null) {
      apsScore += _getApsPoints_cut(marks['math_mark']!);
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
        apsScore += _getApsPoints_cut(mark);
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
        apsScore += _getApsPoints_cut(mark);
      }
    }

    return apsScore;
  }

  int _getApsPoints_cut(int mark) {
    if (mark >= 90) return 8;
    if (mark >= 80) return 7;
    if (mark >= 70) return 6;
    if (mark >= 60) return 5;
    if (mark >= 50) return 4;
    if (mark >= 40) return 3;
    if (mark >= 30) return 2;
    return 1;
  }

  int _getApsPointsForLifeOrientation(int mark) {
    return 1;
  }

  Future<void> _fetchUserMarks_uz() async {
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
        apsUz = _CalculateUZAPS(userMarks);
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
    }
  }

  int _CalculateUZAPS(Map<String, int?> marks) {
    int apsScore = 0;

    // Add math_mark
    if (marks['math_mark'] != null) {
      apsScore += _getApsPoints_uz(marks['math_mark']!);
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
        apsScore += _getApsPoints_uz(mark);
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
        apsScore += _getApsPoints_uz(mark);
      }
    }

    return apsScore;
  }

  int _getApsPoints_uz(int mark) {
    if (mark >= 80) return 7;
    if (mark >= 70) return 6;
    if (mark >= 60) return 5;
    if (mark >= 50) return 4;
    if (mark >= 40) return 3;
    if (mark >= 30) return 2;
    return 1;
  }

  Future<void> _fetchUserMarks_ufs() async {
    try {
      final response = await _supabaseClient
          .from('user_marks')
          .select(
              'math_mark, subject1_mark, subject2_mark, subject3_mark, subject4_mark, home_language_mark, first_additional_language_mark, second_additional_language_mark, life_orientation_mark')
          .eq('user_id', _supabaseClient.auth.currentUser!.id)
          .single();

      final homeLanguageMark = response['home_language_mark'];
      final firstAdditionalLanguageMark =
          response['first_additional_language_mark'];
      final secondAdditionalLanguageMark =
          response['second_additional_language_mark'];

      setState(() {
        userMarks = {
          'math_mark': response['math_mark'],
          'subject1_mark': response['subject1_mark'],
          'subject2_mark': response['subject2_mark'],
          'subject3_mark': response['subject3_mark'],
          'subject4_mark': response['subject4_mark'],
          'home_language_mark': homeLanguageMark,
          'first_additional_language_mark': firstAdditionalLanguageMark,
          'second_additional_language_mark': secondAdditionalLanguageMark,
          'life_orientation_mark': response['life_orientation_mark'],
        };

        // Get the best two marks from the language subjects
        final languageMarks = [
          homeLanguageMark,
          firstAdditionalLanguageMark,
          secondAdditionalLanguageMark
        ].where((mark) => mark != null).toList();

        languageMarks
            .sort((a, b) => b!.compareTo(a!)); // Sort in descending order
        final topTwoLanguageMarks = languageMarks.take(2).toList();

        // Update userMarks with the top two language marks
        userMarks['best_language_mark1'] =
            topTwoLanguageMarks.isNotEmpty ? topTwoLanguageMarks[0] : null;
        userMarks['best_language_mark2'] =
            topTwoLanguageMarks.length > 1 ? topTwoLanguageMarks[1] : null;

        // Get the best three marks from subject1 to subject4
        final subjectMarks = [
          response['subject1_mark'],
          response['subject2_mark'],
          response['subject3_mark'],
          response['subject4_mark'],
        ].where((mark) => mark != null).toList();

        subjectMarks
            .sort((a, b) => b!.compareTo(a!)); // Sort in descending order
        final topThreeSubjectMarks = subjectMarks.take(3).toList();

        // Update userMarks with the top three subject marks
        userMarks['best_subject_mark1'] =
            topThreeSubjectMarks.isNotEmpty ? topThreeSubjectMarks[0] : null;
        userMarks['best_subject_mark2'] =
            topThreeSubjectMarks.length > 1 ? topThreeSubjectMarks[1] : null;
        userMarks['best_subject_mark3'] =
            topThreeSubjectMarks.length > 2 ? topThreeSubjectMarks[2] : null;

        apsUfs = _CalculateApsUFS(userMarks);
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
    }
  }

  int _CalculateApsUFS(Map<String, int?> marks) {
    int apsScore = 0;

    // Helper function to get APS points based on the mark
    int getApsPoints(int mark) {
      if (mark >= 90) return 8;
      if (mark >= 80) return 7;
      if (mark >= 70) return 6;
      if (mark >= 60) return 5;
      if (mark >= 50) return 4;
      if (mark >= 40) return 3;
      if (mark >= 30) return 2;
      return 0; // Return 0 for marks below 40
    }

    // Collect all relevant marks
    final allMarks = [
      marks['math_mark'],
      marks['best_subject_mark1'],
      marks['best_subject_mark2'],
      marks['best_subject_mark3'],
      marks['best_language_mark1'],
      marks['best_language_mark2'],
    ];

    // Remove null values and calculate APS points
    final validMarks = allMarks
        .where((mark) => mark != null)
        .map((mark) => getApsPoints(mark!))
        .toList();

    // Sort marks in descending order and take the best six
    validMarks.sort((a, b) => b.compareTo(a));
    final bestSixMarks = validMarks.take(6).toList();
    apsScore = bestSixMarks.reduce((a, b) => a + b);

    // Handle Life Orientation mark
    final lifeOrientationMark = marks['life_orientation_mark'];
    if (lifeOrientationMark != null) {
      if (lifeOrientationMark >= 60) {
        apsScore += 1;
      }
    }

    return apsScore;
  }

  Future<void> _fetchUserMarks_mut() async {
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
        apsMut = _CalculateMUTAPS(userMarks);
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
    }
  }

  int _CalculateMUTAPS(Map<String, int?> marks) {
    int apsScore = 0;

    // Add math_mark
    if (marks['math_mark'] != null) {
      apsScore += _getApsPoints_mut(marks['math_mark']!);
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
        apsScore += _getApsPoints_mut(mark);
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
        apsScore += _getApsPoints_mut(mark);
      }
    }

    return apsScore;
  }

  int _getApsPoints_mut(int mark) {
    if (mark >= 90) return 8;
    if (mark >= 80) return 7;
    if (mark >= 70) return 6;
    if (mark >= 60) return 5;
    if (mark >= 50) return 4;
    if (mark >= 40) return 3;
    return 0;
  }

  Future<void> _fetchUserMarks_ufh() async {
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
        apsUfh = _CalculateApsUFH(userMarks);
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
    }
  }

  int _getApsPoints_ufh(int mark) {
    if (mark >= 90) return 8;
    if (mark >= 80) return 7;
    if (mark >= 70) return 6;
    if (mark >= 60) return 5;
    if (mark >= 50) return 4;
    if (mark >= 40) return 3;
    if (mark >= 30) return 2;
    return 1;
  }

  int _CalculateApsUFH(Map<String, int?> marks) {
    int apsScore = 0;

    // Add math_mark
    if (marks['math_mark'] != null) {
      apsScore += _getApsPoints_ufh(marks['math_mark']!);
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
        apsScore += _getApsPoints_ufh(mark);
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
        apsScore += _getApsPoints_ufh(mark);
      }
    }

    return apsScore;
  }

  Future<void> _fetchUserMarks_spu() async {
    try {
      final response = await _supabaseClient
          .from('user_marks')
          .select(
              'math_mark, subject1_mark, subject2_mark, subject3_mark, subject4_mark, home_language_mark, first_additional_language_mark, second_additional_language_mark, life_orientation_mark, math_type')
          .eq('user_id', _supabaseClient.auth.currentUser!.id)
          .single();

      final homeLanguageMark = response['home_language_mark'];
      final firstAdditionalLanguageMark =
          response['first_additional_language_mark'];
      final secondAdditionalLanguageMark =
          response['second_additional_language_mark'];

      setState(() {
        userMarks = {
          'math_mark': response['math_mark'],
          'subject1_mark': response['subject1_mark'],
          'subject2_mark': response['subject2_mark'],
          'subject3_mark': response['subject3_mark'],
          'subject4_mark': response['subject4_mark'],
          'home_language_mark': homeLanguageMark,
          'first_additional_language_mark': firstAdditionalLanguageMark,
          'second_additional_language_mark': secondAdditionalLanguageMark,
          'life_orientation_mark': response['life_orientation_mark'],
        };

        // Get the math type
        mathType = response['math_type'];

        // Get the best two marks from the language subjects
        final languageMarks = [
          homeLanguageMark,
          firstAdditionalLanguageMark,
          secondAdditionalLanguageMark
        ].where((mark) => mark != null).toList();

        languageMarks
            .sort((a, b) => b!.compareTo(a!)); // Sort in descending order
        final topTwoLanguageMarks = languageMarks.take(2).toList();

        // Update userMarks with the top two language marks
        userMarks['best_language_mark1'] =
            topTwoLanguageMarks.isNotEmpty ? topTwoLanguageMarks[0] : null;
        userMarks['best_language_mark2'] =
            topTwoLanguageMarks.length > 1 ? topTwoLanguageMarks[1] : null;

        // Get the best three marks from subject1 to subject4
        final subjectMarks = [
          response['subject1_mark'],
          response['subject2_mark'],
          response['subject3_mark'],
          response['subject4_mark'],
        ].where((mark) => mark != null).toList();

        subjectMarks
            .sort((a, b) => b!.compareTo(a!)); // Sort in descending order
        final topThreeSubjectMarks = subjectMarks.take(3).toList();

        // Update userMarks with the top three subject marks
        userMarks['best_subject_mark1'] =
            topThreeSubjectMarks.isNotEmpty ? topThreeSubjectMarks[0] : null;
        userMarks['best_subject_mark2'] =
            topThreeSubjectMarks.length > 1 ? topThreeSubjectMarks[1] : null;
        userMarks['best_subject_mark3'] =
            topThreeSubjectMarks.length > 2 ? topThreeSubjectMarks[2] : null;

        apsSpu = _CalculateApsSP(userMarks, mathType);
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
    }
  }

  int _CalculateApsSP(Map<String, int?> marks, String? mathType) {
    int apsScore = 0;

    // Helper function to get APS points based on the mark
    int getApsPoints(int mark) {
      if (mark >= 90) return 8;
      if (mark >= 80) return 7;
      if (mark >= 70) return 6;
      if (mark >= 60) return 5;
      if (mark >= 50) return 4;
      if (mark >= 40) return 3;
      return 0; // Return 0 for marks below 40
    }

    // Collect all relevant marks
    final allMarks = [
      marks['math_mark'],
      marks['best_subject_mark1'],
      marks['best_subject_mark2'],
      marks['best_subject_mark3'],
      marks['best_language_mark1'],
      marks['best_language_mark2'],
    ];

    // Remove null values and calculate APS points
    final validMarks = allMarks
        .where((mark) => mark != null)
        .map((mark) => getApsPoints(mark!))
        .toList();

    // Sort marks in descending order and take the best six
    validMarks.sort((a, b) => b.compareTo(a));
    final bestSixMarks = validMarks.take(6).toList();
    apsScore = bestSixMarks.reduce((a, b) => a + b);

    final mathMark = marks['math_mark'];
    final homeLanguageMark = marks['home_language_mark'];

    if (mathMark != null && mathType == 'Mathematics') {
      if (mathMark >= 60) {
        apsScore += 2;
      } else if (mathMark >= 40) {
        apsScore += 1;
      }
    }

    if (homeLanguageMark != null) {
      if (homeLanguageMark >= 60) {
        apsScore += 2;
      } else if (homeLanguageMark >= 40) {
        apsScore += 1;
      }
    }

    // Handle Life Orientation mark
    final lifeOrientationMark = marks['life_orientation_mark'];
    if (lifeOrientationMark != null) {
      if (lifeOrientationMark >= 90) {
        apsScore += 4;
      } else if (lifeOrientationMark >= 80) {
        apsScore += 3;
      } else if (lifeOrientationMark >= 70) {
        apsScore += 2;
      } else if (lifeOrientationMark >= 60) {
        apsScore += 1;
      }
    }

    return apsScore;
  }

  Future<void> _fetchUserMarksCput() async {
    try {
      final response = await _supabaseClient
          .from('user_marks')
          .select(
              'math_mark, subject1_mark, subject2_mark, subject3_mark, subject4_mark, home_language_mark, first_additional_language_mark, second_additional_language_mark, life_orientation_mark')
          .eq('user_id', _supabaseClient.auth.currentUser!.id)
          .single();

      setState(() {
        userMarks = {
          'math_mark': response['math_mark'] ?? 0,
          'subject1_mark': response['subject1_mark'] ?? 0,
          'subject2_mark': response['subject2_mark'] ?? 0,
          'subject3_mark': response['subject3_mark'] ?? 0,
          'subject4_mark': response['subject4_mark'] ?? 0,
          'home_language_mark': response['home_language_mark'] ?? 0,
          'first_additional_language_mark':
              response['first_additional_language_mark'] ?? 0,
          'second_additional_language_mark':
              response['second_additional_language_mark'] ?? 0,
          'life_orientation_mark': response['life_orientation_mark'] ?? 0
        };
        apsCput = _CalculateApsCPUT(userMarks);
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
    }
  }

  int _CalculateApsCPUT(Map<String, int?> marks) {
    int apsscoreCput = 0;

    int getApsPoints_cput(int mark) {
      if (mark >= 90) return 8;
      if (mark >= 80) return 7;
      if (mark >= 70) return 6;
      if (mark >= 60) return 5;
      if (mark >= 50) return 4;
      if (mark >= 40) return 3;
      return 0;
    }

    if (marks['math_mark'] != null) {
      apsscoreCput += getApsPoints_cput(marks['math_mark']!);
    }

    final subjectMarks = [
      marks['subject1_mark'],
      marks['subject2_mark'],
      marks['subject3_mark'],
      marks['subject4_mark'],
    ];

    subjectMarks.removeWhere((mark) => mark == null);

    subjectMarks.sort((a, b) => (b ?? 0).compareTo(a ?? 0));

    final bestThreeSubjects = subjectMarks.take(3);
    for (var mark in bestThreeSubjects) {
      if (mark != null) {
        apsscoreCput += getApsPoints_cput(mark);
      }
    }

    final languageMarks = [
      marks['home_language_mark'],
      marks['first_additional_language_mark'],
      marks['second_additional_language_mark'],
    ];

    languageMarks.removeWhere((mark) => mark == null);

    languageMarks.sort((a, b) => (b ?? 0).compareTo(a ?? 0));

    final bestTwoLanguages = languageMarks.take(2);
    for (var mark in bestTwoLanguages) {
      if (mark != null) {
        apsscoreCput += getApsPoints_cput(mark);
      }
    }

    if (marks['life_orientation_mark'] != null) {
      apsscoreCput += getApsPoints_cput(marks['life_orientation_mark']!);
    }

    return apsscoreCput;
  }

  Future<void> _fetchUserMarks_uj() async {
    try {
      final response = await _supabaseClient
          .from('user_marks')
          .select(
              'math_mark, subject1_mark, subject2_mark, subject3_mark, subject4_mark, home_language_mark, first_additional_language_mark, second_additional_language_mark')
          .eq('user_id', _supabaseClient.auth.currentUser!.id)
          .single();

      setState(() {
        userMarks = {
          'math_mark': response['math_mark'] ?? 0,
          'subject1_mark': response['subject1_mark'] ?? 0,
          'subject2_mark': response['subject2_mark'] ?? 0,
          'subject3_mark': response['subject3_mark'] ?? 0,
          'subject4_mark': response['subject4_mark'] ?? 0,
          'home_language_mark': response['home_language_mark'] ?? 0,
          'first_additional_language_mark':
              response['first_additional_language_mark'] ?? 0,
          'second_additional_language_mark':
              response['second_additional_language_mark'] ?? 0,
        };
        apsUj = _calculateAps_uj(userMarks);
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
    }
  }

  int _calculateAps_uj(Map<String, int?> marks) {
    int apsScore = 0;

    if (marks['math_mark'] != null) {
      apsScore += _getApsPoints_uj(marks['math_mark']!);
    }

    final subjectMarks = [
      marks['subject1_mark'],
      marks['subject2_mark'],
      marks['subject3_mark'],
      marks['subject4_mark'],
    ];

    subjectMarks.removeWhere((mark) => mark == null);

    subjectMarks.sort((a, b) => (b ?? 0).compareTo(a ?? 0));

    final bestThreeSubjects = subjectMarks.take(3);
    for (var mark in bestThreeSubjects) {
      if (mark != null) {
        apsScore += _getApsPoints_uj(mark);
      }
    }

    final languageMarks = [
      marks['home_language_mark'],
      marks['first_additional_language_mark'],
      marks['second_additional_language_mark'],
    ];

    languageMarks.removeWhere((mark) => mark == null);

    languageMarks.sort((a, b) => (b ?? 0).compareTo(a ?? 0));

    final bestTwoLanguages = languageMarks.take(2);
    for (var mark in bestTwoLanguages) {
      if (mark != null) {
        apsScore += _getApsPoints_uj(mark);
      }
    }

    return apsScore;
  }

  int _getApsPoints_uj(int mark) {
    if (mark >= 80) return 7;
    if (mark >= 70) return 6;
    if (mark >= 60) return 5;
    if (mark >= 50) return 4;
    if (mark >= 40) return 3;
    if (mark >= 30) return 2;
    return 1;
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    switch (index) {
      case 0:
        // Navigate to Home page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ParentHomepage()),
        );
        break;
      case 1:
        // Navigate to chatscreen page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ParentStudentDetailsPage()),
        );
        break;
      case 2:
        // Navigate to Bookmarks page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ParentBookmarks()),
        );
        break;
      case 3:
        // Navigate to Profile page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ParentProfile()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return DefaultTabController(
      length: 2,
      child: WillPopScope(
        onWillPop: () async {
          final user = Supabase.instance.client.auth.currentUser;

          if (user != null) {
            // Fetch user role from the database or local storage
            final response = await Supabase.instance.client
                .from('profiles')
                .select('role') // Assuming the column is 'role'
                .eq('id', user.id)
                .single();

            if (response['role'] == 'parent') {
              // Navigate back to ParentHomepage
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const ParentHomepage()),
                (Route<dynamic> route) => false,
              );
            } else {
              // Navigate back to HomePage
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const HomePage()),
                (Route<dynamic> route) => false,
              );
            }
          } else {
            // Handle the case where the user is not logged in (optional)
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('User not logged in.')),
            );
          }
          return false; // Prevent default back navigation
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            toolbarHeight: 100,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF0D47A1)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ParentHomepage()),
                );
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
                      'Bookmarks',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0D47A1),
                      ),
                    ),
                    Text(
                      'Favourite Cards',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.delete, color: Color(0xFF0D47A1)),
                tooltip: 'Clear All Bookmarks',
                onPressed: () async {
                  await clearBookmarks();
                },
              ),
            ],
            bottom: const TabBar(
              tabs: [
                Tab(text: 'Institutions'),
                Tab(text: 'Search Results'),
              ],
              indicatorColor: Color(0xFF0D47A1),
              labelColor: Color(0xFF0D47A1),
              unselectedLabelColor: Color.fromARGB(179, 53, 51, 51),
            ),
          ),
          body: isLoading
              ? const Center(child: BouncingImageLoader())
              : TabBarView(
                  children: [
                    _buildInstitutionTab(screenWidth),
                    _buildSearchResultTab(screenWidth),
                  ],
                ),
          bottomNavigationBar: PnavBar(
            selectedIndex: _selectedIndex,
            onItemTapped: _onItemTapped,
          ),
        ),
      ),
    );
  }

  Widget _buildInstitutionTab(double screenWidth) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
      child: bookmarks.isNotEmpty
          ? ListView.builder(
              itemCount: bookmarks.length,
              itemBuilder: (context, index) {
                final String universityName = bookmarks[index];
                switch (universityName) {
                  case 'University of Johannesburg':
                    return UniversityCard(
                      title: 'University of Johannesburg',
                      logo: 'assets/images/uj_logo.webp',
                      aps: apsUj ?? 0,
                      courses: ujCourses,
                      faculties: ujFaculties,
                      route: GetAvailableCouresPage(
                        aps: apsUj ?? 0,
                        universityName: 'University of Johannesburg',
                      ),
                      isBookmarked: true,
                      onBookmarkPressed: () =>
                          _toggleBookmark('University of Johannesburg'),
                    );
                  case 'Cape Peninsula University of Technology':
                    return UniversityCard(
                      title: 'Cape Peninsula University of Technology',
                      logo: 'assets/images/cput_logo.png',
                      aps: apsCput ?? 0,
                      courses: cputCourses,
                      faculties: cputFaculties,
                      route: GetAvailableCouresPage(
                        aps: apsCput ?? 0,
                        universityName:
                            'Cape Peninsula University of Technology',
                      ),
                      isBookmarked: true,
                      onBookmarkPressed: () => _toggleBookmark(
                        'Cape Peninsula University of Technology',
                      ),
                    );
                  case 'University of Pretoria':
                    return UniversityCard(
                      title: 'University of Pretoria',
                      logo: 'assets/images/up_logo.png',
                      aps: apsUj ?? 0,
                      courses: upCourses,
                      faculties: upFaculties,
                      route: GetAvailableCouresPage(
                          aps: apsUj ?? 0,
                          universityName: 'University of Pretoria'),
                      isBookmarked: true,
                      onBookmarkPressed: () =>
                          _toggleBookmark('University of Pretoria'),
                    );
                  case 'University of Mpumalanga':
                    return UniversityCard(
                      title: 'University of Mpumalanga',
                      logo: 'assets/images/um_logo.png',
                      aps: apsUmp ?? 0,
                      courses: umpCourses,
                      faculties: umpFaculties,
                      route: GetAvailableCouresPage(
                          aps: apsUj ?? 0,
                          universityName: 'University of Mpumalanga'),
                      isBookmarked: true,
                      onBookmarkPressed: () =>
                          _toggleBookmark('University of Mpumalanga'),
                    );
                  case 'Sol Plaatje University':
                    return UniversityCard(
                      title: 'Sol Plaatje University',
                      logo: 'assets/images/spu_logo.png',
                      aps: apsSpu ?? 0,
                      courses: spuCourses,
                      faculties: spuFaculties,
                      route: GetAvailableCouresPage(
                          aps: apsSpu ?? 0,
                          universityName: 'Sol Plaatje University'),
                      isBookmarked: true,
                      onBookmarkPressed: () =>
                          _toggleBookmark('Sol Plaatje University'),
                    );
                  case 'University of Fort Hare':
                    return UniversityCard(
                      title: 'University of Fort Hare',
                      logo: 'assets/images/ufh_logo.png',
                      aps: apsUfh ?? 0,
                      courses: ufhCourses,
                      faculties: ufhFaculties,
                      route: GetAvailableCouresPage(
                          aps: apsUfh ?? 0,
                          universityName: 'University of Fort Hare'),
                      isBookmarked: true,
                      onBookmarkPressed: () =>
                          _toggleBookmark('University of Fort Hare'),
                    );
                  case 'Vaal University of Technology':
                    return UniversityCard2(
                      title: 'Vaal University of Technology',
                      logo: 'assets/images/vut_logo.png',
                      aps: "",
                      courses: vutCourses,
                      faculties: vutFaculties,
                      route: const CalculateApsVUTPage(),
                      isBookmarked: true,
                      onBookmarkPressed: () =>
                          _toggleBookmark('Vaal University of Technology'),
                    );
                  case 'Mangosuthu University of Technology':
                    return UniversityCard(
                      title: 'Mangosuthu University of Technology',
                      logo: 'assets/images/mut_logo.png',
                      aps: apsMut ?? 0,
                      courses: mutCourses,
                      faculties: mutFaculties,
                      route: GetAvailableCouresPage(
                          aps: apsMut ?? 0,
                          universityName:
                              'Mangosuthu University of Technology'),
                      isBookmarked: true,
                      onBookmarkPressed: () => _toggleBookmark(
                          'Mangosuthu University of Technology'),
                    );
                  case 'University Of Venda':
                    return UniversityCard2(
                      title: 'University Of Venda',
                      logo: 'assets/images/univen_logo.svg.png',
                      aps: '',
                      courses: univenCourses,
                      faculties: univenFaculties,
                      route: const CalculateUNIVENAPSPage(),
                      isBookmarked: true,
                      onBookmarkPressed: () =>
                          _toggleBookmark('University Of Venda'),
                    );
                  case 'University Of Zululand':
                    return UniversityCard(
                      title: 'University Of Zululand',
                      logo: 'assets/images/uz_logo.png',
                      aps: apsUz ?? 0,
                      courses: unizuluCourses,
                      faculties: univenFaculties,
                      route: GetAvailableCouresPage(
                          aps: apsUz ?? 0,
                          universityName: 'University of Zululand'),
                      isBookmarked: true,
                      onBookmarkPressed: () =>
                          _toggleBookmark('University Of Zululand'),
                    );
                  case 'University of Cape Town':
                    return UniversityCard2(
                      title: 'University of Cape Town',
                      logo: 'assets/images/uct_logo.webp',
                      aps: "",
                      courses: 6,
                      faculties: 8,
                      route: const CalculateAPSUCTPage(),
                      isBookmarked: true,
                      onBookmarkPressed: () =>
                          _toggleBookmark('University of Cape Town'),
                    );
                  case 'University Of The Free State':
                    return UniversityCard(
                        title: 'University Of The Free State',
                        logo: 'assets/images/ufs_logo.png',
                        aps: apsUfs ?? 0,
                        courses: ufsCourses,
                        faculties: ufsFaculties,
                        route: GetAvailableCouresPage(
                            aps: apsUfs ?? 0,
                            universityName: 'University of The Free State'),
                        isBookmarked: true,
                        onBookmarkPressed: () =>
                            _toggleBookmark('University Of The Free State'));
                  case 'Central University of Technology':
                    return UniversityCard(
                        title: 'Central University of Technology',
                        logo: 'assets/images/cut_logo.webp',
                        aps: apsCut ?? 0,
                        courses: cutCourses,
                        faculties: cutFaculties,
                        route: GetAvailableCouresPage(
                            aps: apsCut ?? 0,
                            universityName: 'Central University of Technology'),
                        isBookmarked: true,
                        onBookmarkPressed: () => _toggleBookmark(
                            'Central University of Technology'));
                  case 'Rhodes University':
                    return UniversityCard2(
                      title: 'Rhodes University',
                      logo: 'assets/images/Rhodes_logo.png',
                      aps: "",
                      courses: rhodesCourses,
                      faculties: rhodesFaculties,
                      route: const CalculateApsRhodesPage(),
                      isBookmarked: true,
                      onBookmarkPressed: () =>
                          _toggleBookmark('Rhodes University'),
                    );
                  case 'Walter Sisulu University':
                    return UniversityCard(
                      title: 'Walter Sisulu University',
                      logo: 'assets/images/wsu_logo.png',
                      aps: apsWsu ?? 0,
                      courses: wsuCourses,
                      faculties: wsuFaculties,
                      route: GetAvailableCouresPage(
                          aps: apsWsu ?? 0,
                          universityName: 'Walter Sisulu University'),
                      isBookmarked: true,
                      onBookmarkPressed: () =>
                          _toggleBookmark('Walter Sisulu University'),
                    );
                  case 'Durban University of Technology':
                    return UniversityCard(
                        title: 'Durban University of Technology',
                        logo: 'assets/images/dut_logo.webp',
                        aps: apsDut ?? 0,
                        courses: dutCourses,
                        faculties: dutFaculties,
                        route: GetAvailableCouresPage(
                            aps: apsDut ?? 0,
                            universityName: 'Durban University of Technology'),
                        isBookmarked: true,
                        onBookmarkPressed: () =>
                            _toggleBookmark('Durban University of Technology'));
                  case 'Sefako Makgatho University':
                    return UniversityCard(
                      title: 'Sefako Makgatho University',
                      logo: 'assets/images/smu_logo.png',
                      aps: apsSmu ?? 0,
                      courses: smuCourses,
                      faculties: smuFaculties,
                      route: GetAvailableCouresPage(
                          aps: apsSmu ?? 0,
                          universityName: 'Sefako Makgatho University'),
                      isBookmarked: true,
                      onBookmarkPressed: () =>
                          _toggleBookmark('Sefako Makgatho University'),
                    );
                  case 'Stellenbosch University':
                    return UniversityCard2(
                      title: 'Stellenbosch University',
                      logo: 'assets/images/stellies_logo.webp',
                      aps: '',
                      courses: stelliesCourses,
                      faculties: stelliesFaculties,
                      route: const CalculateApsStelliesPage(),
                      isBookmarked: true,
                      onBookmarkPressed: () =>
                          _toggleBookmark('Stellenbosch University'),
                    );
                  case 'Tshwane University of Technology':
                    return UniversityCard(
                      title: 'Tshwane University of Technology',
                      logo: 'assets/images/tut_logo.jpeg',
                      aps: apsUj ?? 0,
                      courses: tutCourses,
                      faculties: tutFaculties,
                      route: GetAvailableCouresPage(
                          aps: apsUj ?? 0,
                          universityName: 'Tshwane University of Technology'),
                      isBookmarked: true,
                      onBookmarkPressed: () =>
                          _toggleBookmark('Tshwane University of Technology'),
                    );
                  case 'University of the Western Cape':
                    return UniversityCard(
                      title: 'University of the Western Cape',
                      logo: 'assets/images/uwc_logo.png',
                      aps: apsUwc ?? 0,
                      courses: uwcCourses,
                      faculties: uwcFaculties,
                      route: GetAvailableCouresPage(
                          aps: apsUwc ?? 0,
                          universityName: 'University of the Western Cape'),
                      isBookmarked: true,
                      onBookmarkPressed: () =>
                          _toggleBookmark('University of the Western Cape'),
                    );
                  case 'University of Limpopo':
                    return UniversityCard(
                      title: 'University of Limpopo',
                      logo: 'assets/images/ul_logo.png',
                      aps: apsUl ?? 0,
                      courses: ulCourses,
                      faculties: ulFaculties,
                      route: GetAvailableCouresPage(
                          aps: apsUl ?? 0,
                          universityName: 'University of Limpopo'),
                      isBookmarked: true,
                      onBookmarkPressed: () =>
                          _toggleBookmark('University of Limpopo'),
                    );
                  case 'Nelson Mandela University':
                    return UniversityCard2(
                      title: 'Nelson Mandela University',
                      logo: 'assets/images/nmu_logo.png',
                      aps: "",
                      courses: nmuCourses,
                      faculties: nmuFaculties,
                      route: const CalculateApsNMUPage(),
                      isBookmarked: true,
                      onBookmarkPressed: () =>
                          _toggleBookmark('Nelson Mandela University'),
                    );
                  case 'North West University':
                    return UniversityCard(
                      title: 'North West University',
                      logo: 'assets/images/nwu_logo.png',
                      aps: apsNwu ?? 0,
                      courses: nwuCourses,
                      faculties: nwuFaculties,
                      route: GetAvailableCouresPage(
                          aps: apsNwu ?? 0,
                          universityName: 'North-West University'),
                      isBookmarked: true,
                      onBookmarkPressed: () =>
                          _toggleBookmark('North West University'),
                    );
                  case 'University of the Witwatersrand':
                    return UniversityCard(
                      title: 'University of the Witwatersrand',
                      logo: 'assets/images/wits_logo.webp',
                      aps: apsWits ?? 0,
                      courses: witsCourses,
                      faculties: witsFaculties,
                      route: GetAvailableCouresPage(
                          aps: apsWits ?? 0,
                          universityName: 'University of the Witwatersrand'),
                      isBookmarked: true,
                      onBookmarkPressed: () =>
                          _toggleBookmark('University of the Witwatersrand'),
                    );
                  case 'University of Kwazulu-Natal':
                    return UniversityCard(
                      title: 'University of Kwazulu-Natal',
                      logo: 'assets/images/ukzn_logo.webp',
                      aps: apsUkzn ?? 0,
                      courses: ukznCourses,
                      faculties: ukznFaculties,
                      route: GetAvailableCouresPage(
                          aps: apsUkzn ?? 0,
                          universityName: 'University of Kwazulu-Natal'),
                      isBookmarked: true,
                      onBookmarkPressed: () =>
                          _toggleBookmark('University of Kwazulu-Natal'),
                    );

                  case 'Central Johannesburg TVET College':
                    return CollegeCard(
                      title: 'Central Johannesburg TVET College',
                      logo: 'assets/images/college_images/cjc_logo.jpg',
                      aps: apsUj ?? 0,
                      courses: "6+",
                      faculties: "",
                      route: GetAvailableCollegeCouresPage(
                          aps: apsUj ?? 0,
                          collegeName: 'Central Johannesburg TVET College'),
                      isBookmarked: true,
                      onBookmarkPressed: () =>
                          _toggleBookmark('Central Johannesburg TVET College'),
                    );
                  case 'Ekurhuleni East TVET College':
                    return CollegeCard(
                      title: 'Ekurhuleni East TVET College',
                      logo:
                          'assets/images/college_images/ekurhuleniEastTVET_logo 2.jpg',
                      aps: apsUj ?? 0,
                      courses: "6+",
                      faculties: "",
                      route: GetAvailableCollegeCouresPage(
                        aps: apsUj ?? 0,
                        collegeName: 'Ekurhuleni East TVET College',
                      ),
                      isBookmarked: true,
                      onBookmarkPressed: () =>
                          _toggleBookmark('Ekurhuleni East TVET College'),
                    );
                  case 'Ekurhuleni West TVET College':
                    return CollegeCard(
                      title: 'Ekurhuleni West TVET College',
                      logo:
                          'assets/images/college_images/ekurhuleni-west-college-logo.jpg',
                      aps: apsUj ?? 0,
                      courses: "6+",
                      faculties: "",
                      route: GetAvailableCollegeCouresPage(
                        aps: apsUj ?? 0,
                        collegeName: 'Ekurhuleni West TVET College',
                      ),
                      isBookmarked: true,
                      onBookmarkPressed: () =>
                          _toggleBookmark('Ekurhuleni West TVET College'),
                    );
                  case 'Sedibeng TVET College':
                    return CollegeCard(
                      title: 'Sedibeng TVET College',
                      logo: 'assets/images/college_images/sedibeng_logo 2.jpg',
                      aps: apsUj ?? 0,
                      courses: "6+",
                      faculties: "",
                      route: GetAvailableCollegeCouresPage(
                        aps: apsUj ?? 0,
                        collegeName: 'Sedibeng TVET College',
                      ),
                      isBookmarked: true,
                      onBookmarkPressed: () =>
                          _toggleBookmark('Sedibeng TVET College'),
                    );
                  case 'South West Gauteng TVET College':
                    return CollegeCard(
                      title: 'South West Gauteng TVET College',
                      logo:
                          'assets/images/college_images/SouthWestTvetGauteng_logo 2.jpg',
                      aps: apsUj ?? 0,
                      courses: "6+",
                      faculties: "",
                      route: GetAvailableCollegeCouresPage(
                        aps: apsUj ?? 0,
                        collegeName: 'South West Gauteng TVET College',
                      ),
                      isBookmarked: true,
                      onBookmarkPressed: () =>
                          _toggleBookmark('South West Gauteng TVET College'),
                    );
                  case 'Tshwane North TVET College':
                    return CollegeCard(
                      title: 'Tshwane North TVET College',
                      logo:
                          'assets/images/college_images/tshwaneNorth_logo 2.png',
                      aps: apsUj ?? 0,
                      courses: "6+",
                      faculties: "",
                      route: GetAvailableCollegeCouresPage(
                        aps: apsUj ?? 0,
                        collegeName: 'Tshwane North TVET College',
                      ),
                      isBookmarked: true,
                      onBookmarkPressed: () =>
                          _toggleBookmark('Tshwane North TVET College'),
                    );
                  case 'Tshwane South College':
                    return CollegeCard(
                      title: 'Tshwane South College',
                      logo:
                          'assets/images/college_images/TshwaneSouth_logo 2.jpg',
                      aps: apsUj ?? 0,
                      courses: "6+",
                      faculties: "",
                      route: GetAvailableCollegeCouresPage(
                        aps: apsUj ?? 0,
                        collegeName: 'Tshwane South College',
                      ),
                      isBookmarked: true,
                      onBookmarkPressed: () =>
                          _toggleBookmark('Tshwane South College'),
                    );
                  case 'Western TVET College':
                    return CollegeCard(
                      title: 'Western TVET College',
                      logo: 'assets/images/college_images/Westcol.jpg',
                      aps: apsUj ?? 0,
                      courses: "6+",
                      faculties: "",
                      route: GetAvailableCollegeCouresPage(
                        aps: apsUj ?? 0,
                        collegeName: 'Western TVET College',
                      ),
                      isBookmarked: true,
                      onBookmarkPressed: () =>
                          _toggleBookmark('Western TVET College'),
                    );
                  case 'Coastal KZN TVET College':
                    return CollegeCard(
                      title: 'Coastal KZN TVET College',
                      logo:
                          'assets/images/college_images/coastalTvet_logo 2.jpg',
                      aps: apsUj ?? 0,
                      courses: "6+",
                      faculties: "",
                      route: GetAvailableCollegeCouresPage(
                        aps: apsUj ?? 0,
                        collegeName: 'Coastal KZN TVET College',
                      ),
                      isBookmarked: true,
                      onBookmarkPressed: () =>
                          _toggleBookmark('Coastal KZN TVET College'),
                    );
                  case 'Elangeni TVET College':
                    return CollegeCard(
                      title: 'Elangeni TVET College',
                      logo:
                          'assets/images/college_images/ElangeniTvet_logo 2.jpg',
                      aps: apsUj ?? 0,
                      courses: "6+",
                      faculties: "",
                      route: GetAvailableCollegeCouresPage(
                        aps: apsUj ?? 0,
                        collegeName: 'Elangeni TVET College',
                      ),
                      isBookmarked: true,
                      onBookmarkPressed: () =>
                          _toggleBookmark('Elangeni TVET College'),
                    );
                  case 'Esayidi TVET College':
                    return CollegeCard(
                      title: 'Esayidi TVET College',
                      logo: 'assets/images/college_images/esayidiTvet_logo.png',
                      aps: apsUj ?? 0,
                      courses: "6+",
                      faculties: "",
                      route: GetAvailableCollegeCouresPage(
                        aps: apsUj ?? 0,
                        collegeName: 'Esayidi TVET College',
                      ),
                      isBookmarked: true,
                      onBookmarkPressed: () =>
                          _toggleBookmark('Esayidi TVET College'),
                    );
                  case 'Majuba TVET College':
                    return CollegeCard(
                      title: 'Majuba TVET College',
                      logo: 'assets/images/college_images/majuba_logo 2.png',
                      aps: apsUj ?? 0,
                      courses: "6+",
                      faculties: "",
                      route: GetAvailableCollegeCouresPage(
                        aps: apsUj ?? 0,
                        collegeName: 'Majuba TVET College',
                      ),
                      isBookmarked: true,
                      onBookmarkPressed: () =>
                          _toggleBookmark('Majuba TVET College'),
                    );
                  case 'Mnambithi TVET College':
                    return CollegeCard(
                      title: 'Mnambithi TVET College',
                      logo: 'assets/images/college_images/mnambithi_logo 2.png',
                      aps: apsUj ?? 0,
                      courses: "6+",
                      faculties: "",
                      route: GetAvailableCollegeCouresPage(
                        aps: apsUj ?? 0,
                        collegeName: 'Mnambithi TVET College',
                      ),
                      isBookmarked: true,
                      onBookmarkPressed: () =>
                          _toggleBookmark('Mnambithi TVET College'),
                    );
                  case 'Mthashana TVET College':
                    return CollegeCard(
                      title: 'Mthashana TVET College',
                      logo: 'assets/images/college_images/mthashana_logo 2.jpg',
                      aps: apsUj ?? 0,
                      courses: "6+",
                      faculties: "",
                      route: GetAvailableCollegeCouresPage(
                        aps: apsUj ?? 0,
                        collegeName: 'Mthashana TVET College',
                      ),
                      isBookmarked: true,
                      onBookmarkPressed: () =>
                          _toggleBookmark('Mthashana TVET College'),
                    );
                  case 'uMfolozi TVET College':
                    return CollegeCard(
                      title: 'uMfolozi TVET College',
                      logo: 'assets/images/college_images/umfolozi-logo.png',
                      aps: apsUj ?? 0,
                      courses: "6+",
                      faculties: "",
                      route: GetAvailableCollegeCouresPage(
                        aps: apsUj ?? 0,
                        collegeName: 'uMfolozi TVET College',
                      ),
                      isBookmarked: true,
                      onBookmarkPressed: () =>
                          _toggleBookmark('uMfolozi TVET College'),
                    );
                  case 'Umgungundlovu TVET College':
                    return CollegeCard(
                      title: 'Umgungundlovu TVET College',
                      logo:
                          'assets/images/college_images/UmgungundlovuTvet_logo.png',
                      aps: apsUj ?? 0,
                      courses: "6+",
                      faculties: "",
                      route: GetAvailableCollegeCouresPage(
                        aps: apsUj ?? 0,
                        collegeName: 'Umgungundlovu TVET College',
                      ),
                      isBookmarked: true,
                      onBookmarkPressed: () =>
                          _toggleBookmark('Umgungundlovu TVET College'),
                    );
                  case 'Boland TVET College':
                    return CollegeCard(
                      title: 'Boland TVET College',
                      logo:
                          'assets/images/college_images/bolandcollege_logo.png',
                      aps: apsUj ?? 0,
                      courses: "6+",
                      faculties: "",
                      route: GetAvailableCollegeCouresPage(
                        aps: apsUj ?? 0,
                        collegeName: 'Boland TVET College',
                      ),
                      isBookmarked: true,
                      onBookmarkPressed: () =>
                          _toggleBookmark('Boland TVET College'),
                    );
                  case 'College of Cape Town':
                    return CollegeCard(
                      title: 'College of Cape Town',
                      logo:
                          'assets/images/college_images/collegeOfCT_logo 2.png',
                      aps: apsUj ?? 0,
                      courses: "6+",
                      faculties: "",
                      route: GetAvailableCollegeCouresPage(
                        aps: apsUj ?? 0,
                        collegeName: 'College of Cape Town',
                      ),
                      isBookmarked: true,
                      onBookmarkPressed: () =>
                          _toggleBookmark('College of Cape Town'),
                    );
                  case 'False Bay College':
                    return CollegeCard(
                      title: 'False Bay College',
                      logo:
                          'assets/images/college_images/FalseBayCollege_logo 2.png',
                      aps: apsUj ?? 0,
                      courses: "6+",
                      faculties: "",
                      route: GetAvailableCollegeCouresPage(
                        aps: apsUj ?? 0,
                        collegeName: 'False Bay College',
                      ),
                      isBookmarked: true,
                      onBookmarkPressed: () =>
                          _toggleBookmark('False Bay College'),
                    );
                  case 'Northlink TVET College':
                    return CollegeCard(
                      title: 'Northlink TVET College',
                      logo:
                          'assets/images/college_images/NorthLinkCollege_logo.jpg',
                      aps: apsUj ?? 0,
                      courses: "6+",
                      faculties: "",
                      route: GetAvailableCollegeCouresPage(
                        aps: apsUj ?? 0,
                        collegeName: 'Northlink TVET College',
                      ),
                      isBookmarked: true,
                      onBookmarkPressed: () =>
                          _toggleBookmark('Northlink TVET College'),
                    );
                  case 'South Cape TVET College':
                    return CollegeCard(
                      title: 'South Cape TVET College',
                      logo:
                          'assets/images/college_images/SouthCapeTVET_logo 2.png',
                      aps: apsUj ?? 0,
                      courses: "6+",
                      faculties: "",
                      route: GetAvailableCollegeCouresPage(
                        aps: apsUj ?? 0,
                        collegeName: 'South Cape TVET College',
                      ),
                      isBookmarked: true,
                      onBookmarkPressed: () =>
                          _toggleBookmark('South Cape TVET College'),
                    );
                  case 'Mopani South East TVET College':
                    return CollegeCard(
                      title: 'Mopani South East TVET College',
                      logo:
                          'assets/images/college_images/mopaniSouthEast_logo 2.jpg',
                      aps: apsUj ?? 0,
                      courses: "6+",
                      faculties: "",
                      route: GetAvailableCollegeCouresPage(
                        aps: apsUj ?? 0,
                        collegeName: 'Mopani South East TVET College',
                      ),
                      isBookmarked: true,
                      onBookmarkPressed: () =>
                          _toggleBookmark('Mopani South East TVET College'),
                    );
                  case 'Buffalo City TVET College':
                    return CollegeCard(
                      title: 'Buffalo City TVET College',
                      logo:
                          'assets/images/college_images/Buffalo-tvet_logo.jpg',
                      aps: apsUj ?? 0,
                      courses: "6+",
                      faculties: "",
                      route: GetAvailableCollegeCouresPage(
                        aps: apsUj ?? 0,
                        collegeName: 'Buffalo City TVET College',
                      ),
                      isBookmarked: true,
                      onBookmarkPressed: () =>
                          _toggleBookmark('Buffalo City TVET College'),
                    );
                  case 'Eastcape Midlands TVET College':
                    return CollegeCard(
                      title: 'Eastcape Midlands TVET College',
                      logo:
                          'assets/images/college_images/EastcapeTvet_Logo.jpg',
                      aps: apsUj ?? 0,
                      courses: "6+",
                      faculties: "",
                      route: GetAvailableCollegeCouresPage(
                        aps: apsUj ?? 0,
                        collegeName: 'Eastcape Midlands TVET College',
                      ),
                      isBookmarked: true,
                      onBookmarkPressed: () =>
                          _toggleBookmark('Eastcape Midlands TVET College'),
                    );
                  case 'Ingwe TVET College':
                    return CollegeCard(
                      title: 'Ingwe TVET College',
                      logo: 'assets/images/college_images/IngweTvet_logo 2.png',
                      aps: apsUj ?? 0,
                      courses: "6+",
                      faculties: "",
                      route: GetAvailableCollegeCouresPage(
                        aps: apsUj ?? 0,
                        collegeName: 'Ingwe TVET College',
                      ),
                      isBookmarked: true,
                      onBookmarkPressed: () =>
                          _toggleBookmark('Ingwe TVET College'),
                    );
                  case 'King Hintsa TVET College':
                    return CollegeCard(
                      title: 'King Hintsa TVET College',
                      logo:
                          'assets/images/college_images/college-kinghintsa-logo.jpg',
                      aps: apsUj ?? 0,
                      courses: "6+",
                      faculties: "",
                      route: GetAvailableCollegeCouresPage(
                        aps: apsUj ?? 0,
                        collegeName: 'King Hintsa TVET College',
                      ),
                      isBookmarked: true,
                      onBookmarkPressed: () =>
                          _toggleBookmark('King Hintsa TVET College'),
                    );
                  case 'King Sabata Dalindyebo TVET College':
                    return CollegeCard(
                      title: 'King Sabata Dalindyebo TVET College',
                      logo:
                          'assets/images/college_images/king_sabata_tvet_logo.png',
                      aps: apsUj ?? 0,
                      courses: "6+",
                      faculties: "",
                      route: GetAvailableCollegeCouresPage(
                        aps: apsUj ?? 0,
                        collegeName: 'King Sabata Dalindyebo TVET College',
                      ),
                      isBookmarked: true,
                      onBookmarkPressed: () => _toggleBookmark(
                          'King Sabata Dalindyebo TVET College'),
                    );
                  case 'Lovedale TVET College':
                    return CollegeCard(
                      title: 'Lovedale TVET College',
                      logo:
                          'assets/images/college_images/Lovedale-TVET-College-logo.png',
                      aps: apsUj ?? 0,
                      courses: "6+",
                      faculties: "",
                      route: GetAvailableCollegeCouresPage(
                        aps: apsUj ?? 0,
                        collegeName: 'Lovedale TVET College',
                      ),
                      isBookmarked: true,
                      onBookmarkPressed: () =>
                          _toggleBookmark('Lovedale TVET College'),
                    );
                  case 'Port Elizabeth TVET College':
                    return CollegeCard(
                      title: 'Port Elizabeth TVET College',
                      logo:
                          'assets/images/college_images/port-elizabeth-tvet-college-logo.jpg',
                      aps: apsUj ?? 0,
                      courses: "6+",
                      faculties: "",
                      route: GetAvailableCollegeCouresPage(
                        aps: apsUj ?? 0,
                        collegeName: 'Port Elizabeth TVET College',
                      ),
                      isBookmarked: true,
                      onBookmarkPressed: () =>
                          _toggleBookmark('Port Elizabeth TVET College'),
                    );
                  case 'Flavius Mareka TVET College':
                    return CollegeCard(
                      title: 'Flavius Mareka TVET College',
                      logo:
                          'assets/images/college_images/Flavius_Mareka_Tvet_logo 2.png',
                      aps: apsUj ?? 0,
                      courses: "6+",
                      faculties: "",
                      route: GetAvailableCollegeCouresPage(
                        aps: apsUj ?? 0,
                        collegeName: 'Flavius Mareka TVET College',
                      ),
                      isBookmarked: true,
                      onBookmarkPressed: () =>
                          _toggleBookmark('Flavius Mareka TVET College'),
                    );
                  case 'Goldfields TVET College':
                    return CollegeCard(
                      title: 'Goldfields TVET College',
                      logo:
                          'assets/images/college_images/Goldfields_Tvet_logo 2.jpg',
                      aps: apsUj ?? 0,
                      courses: "6+",
                      faculties: "",
                      route: GetAvailableCollegeCouresPage(
                        aps: apsUj ?? 0,
                        collegeName: 'Goldfields TVET College',
                      ),
                      isBookmarked: true,
                      onBookmarkPressed: () =>
                          _toggleBookmark('Goldfields TVET College'),
                    );
                  case 'Maluti TVET College':
                    return CollegeCard(
                      title: 'Maluti TVET College',
                      logo:
                          'assets/images/college_images/Maluti-TVET-College_logo.jpg',
                      aps: apsUj ?? 0,
                      courses: "6+",
                      faculties: "",
                      route: GetAvailableCollegeCouresPage(
                        aps: apsUj ?? 0,
                        collegeName: 'Maluti TVET College',
                      ),
                      isBookmarked: true,
                      onBookmarkPressed: () =>
                          _toggleBookmark('Maluti TVET College'),
                    );
                  case 'Motheo TVET College':
                    return CollegeCard(
                      title: 'Motheo TVET College',
                      logo: 'assets/images/college_images/Motheo_tvet_logo.png',
                      aps: apsUj ?? 0,
                      courses: "6+",
                      faculties: "",
                      route: GetAvailableCollegeCouresPage(
                        aps: apsUj ?? 0,
                        collegeName: 'Motheo TVET College',
                      ),
                      isBookmarked: true,
                      onBookmarkPressed: () =>
                          _toggleBookmark('Motheo TVET College'),
                    );
                  case 'Capricorn TVET College':
                    return CollegeCard(
                      title: 'Capricorn TVET College',
                      logo:
                          'assets/images/college_images/capricorn_tvet_logo 2.jpg',
                      aps: apsUj ?? 0,
                      courses: "6+",
                      faculties: "",
                      route: GetAvailableCollegeCouresPage(
                        aps: apsUj ?? 0,
                        collegeName: 'Capricorn TVET College',
                      ),
                      isBookmarked: true,
                      onBookmarkPressed: () =>
                          _toggleBookmark('Capricorn TVET College'),
                    );
                  case 'Lephalale TVET College':
                    return CollegeCard(
                      title: 'Lephalale TVET College',
                      logo:
                          'assets/images/college_images/lephalale_tvet_logo.png',
                      aps: apsUj ?? 0,
                      courses: "6+",
                      faculties: "",
                      route: GetAvailableCollegeCouresPage(
                        aps: apsUj ?? 0,
                        collegeName: 'Lephalale TVET College',
                      ),
                      isBookmarked: true,
                      onBookmarkPressed: () =>
                          _toggleBookmark('Lephalale TVET College'),
                    );
                  case 'Letaba TVET College':
                    return CollegeCard(
                      title: 'Letaba TVET College',
                      logo:
                          'assets/images/college_images/letaba-tvet-college-logo 2.png',
                      aps: apsUj ?? 0,
                      courses: "6+",
                      faculties: "",
                      route: GetAvailableCollegeCouresPage(
                        aps: apsUj ?? 0,
                        collegeName: 'Letaba TVET College',
                      ),
                      isBookmarked: true,
                      onBookmarkPressed: () =>
                          _toggleBookmark('Letaba TVET College'),
                    );
                  case 'Sekhukhune TVET College':
                    return CollegeCard(
                      title: 'Sekhukhune TVET College',
                      logo:
                          'assets/images/college_images/sekhukhuneTvet_logo.jpg',
                      aps: apsUj ?? 0,
                      courses: "6+",
                      faculties: "",
                      route: GetAvailableCollegeCouresPage(
                        aps: apsUj ?? 0,
                        collegeName: 'Sekhukhune TVET College',
                      ),
                      isBookmarked: true,
                      onBookmarkPressed: () =>
                          _toggleBookmark('Sekhukhune TVET College'),
                    );
                  case 'Vhembe TVET College':
                    return CollegeCard(
                      title: 'Vhembe TVET College',
                      logo:
                          'assets/images/college_images/vhembeTvet_logo 2.jpg',
                      aps: apsUj ?? 0,
                      courses: "6+",
                      faculties: "",
                      route: GetAvailableCollegeCouresPage(
                        aps: apsUj ?? 0,
                        collegeName: 'Vhembe TVET College',
                      ),
                      isBookmarked: true,
                      onBookmarkPressed: () =>
                          _toggleBookmark('Vhembe TVET College'),
                    );
                  case 'Waterberg TVET College':
                    return CollegeCard(
                      title: 'Waterberg TVET College',
                      logo:
                          'assets/images/college_images/WaterBurgTvet_logo 2.png',
                      aps: apsUj ?? 0,
                      courses: "6+",
                      faculties: "",
                      route: GetAvailableCollegeCouresPage(
                        aps: apsUj ?? 0,
                        collegeName: 'Waterberg TVET College',
                      ),
                      isBookmarked: true,
                      onBookmarkPressed: () =>
                          _toggleBookmark('Waterberg TVET College'),
                    );
                  case 'Ehlanzeni TVET College':
                    return CollegeCard(
                      title: 'Ehlanzeni TVET College',
                      logo:
                          'assets/images/college_images/Ehlanzeni-TVET-College-logo.jpg',
                      aps: apsUj ?? 0,
                      courses: "6+",
                      faculties: "",
                      route: GetAvailableCollegeCouresPage(
                        aps: apsUj ?? 0,
                        collegeName: 'Ehlanzeni TVET College',
                      ),
                      isBookmarked: true,
                      onBookmarkPressed: () =>
                          _toggleBookmark('Ehlanzeni TVET College'),
                    );
                  case 'Gert Sibande TVET College':
                    return CollegeCard(
                      title: 'Gert Sibande TVET College',
                      logo:
                          'assets/images/college_images/Gert_Sibande_logo.png',
                      aps: apsUj ?? 0,
                      courses: "6+",
                      faculties: "",
                      route: GetAvailableCollegeCouresPage(
                        aps: apsUj ?? 0,
                        collegeName: 'Gert Sibande TVET College',
                      ),
                      isBookmarked: true,
                      onBookmarkPressed: () =>
                          _toggleBookmark('Gert Sibande TVET College'),
                    );
                  case 'Nkangala TVET College':
                    return CollegeCard(
                      title: 'Nkangala TVET College',
                      logo:
                          'assets/images/college_images/nkangala_Tvet_logo.png',
                      aps: apsUj ?? 0,
                      courses: "6+",
                      faculties: "",
                      route: GetAvailableCollegeCouresPage(
                        aps: apsUj ?? 0,
                        collegeName: 'Nkangala TVET College',
                      ),
                      isBookmarked: true,
                      onBookmarkPressed: () =>
                          _toggleBookmark('Nkangala TVET College'),
                    );
                  case 'Northern Cape Urban TVET College':
                    return CollegeCard(
                      title: 'Northern Cape Urban TVET College',
                      logo: 'assets/images/college_images/NCUTtvet_logo.jpg',
                      aps: apsUj ?? 0,
                      courses: "6+",
                      faculties: "",
                      route: GetAvailableCollegeCouresPage(
                        aps: apsUj ?? 0,
                        collegeName: 'Northern Cape Urban TVET College',
                      ),
                      isBookmarked: true,
                      onBookmarkPressed: () =>
                          _toggleBookmark('Northern Cape Urban TVET College'),
                    );
                  case 'Orbit TVET College':
                    return CollegeCard(
                      title: 'Orbit TVET College',
                      logo: 'assets/images/college_images/orbitTvet_logo 2.jpg',
                      aps: apsUj ?? 0,
                      courses: "6+",
                      faculties: "",
                      route: GetAvailableCollegeCouresPage(
                        aps: apsUj ?? 0,
                        collegeName: 'Orbit TVET College',
                      ),
                      isBookmarked: true,
                      onBookmarkPressed: () =>
                          _toggleBookmark('Orbit TVET College'),
                    );
                  case 'Taletso TVET College':
                    return CollegeCard(
                      title: 'Taletso TVET College',
                      logo: 'assets/images/college_images/taletso_logo.jpg',
                      aps: apsUj ?? 0,
                      courses: "6+",
                      faculties: "",
                      route: GetAvailableCollegeCouresPage(
                        aps: apsUj ?? 0,
                        collegeName: 'Taletso TVET College',
                      ),
                      isBookmarked: true,
                      onBookmarkPressed: () =>
                          _toggleBookmark('Taletso TVET College'),
                    );
                  case 'Vuselela TVET College':
                    return CollegeCard(
                      title: 'Vuselela TVET College',
                      logo:
                          'assets/images/college_images/VuselelaTvet_logo.png',
                      aps: apsUj ?? 0,
                      courses: "6+",
                      faculties: "",
                      route: GetAvailableCollegeCouresPage(
                        aps: apsUj ?? 0,
                        collegeName: 'Vuselela TVET College',
                      ),
                      isBookmarked: true,
                      onBookmarkPressed: () =>
                          _toggleBookmark('Vuselela TVET College'),
                    );
                  case 'Thekwini TVET College':
                    return CollegeCard(
                      title: 'Thekwini TVET College',
                      logo: 'assets/images/college_images/Thekwini.jpg',
                      aps: apsUj ?? 0,
                      courses: "6+",
                      faculties: "",
                      route: GetAvailableCollegeCouresPage(
                        aps: apsUj ?? 0,
                        collegeName: 'Thekwini TVET College',
                      ),
                      isBookmarked: true,
                      onBookmarkPressed: () =>
                          _toggleBookmark('Thekwini TVET College'),
                    );
                  case 'West Coast TVET College':
                    return CollegeCard(
                      title: 'West Coast TVET College',
                      logo:
                          'assets/images/college_images/west_coast_college_logo 2.jpg',
                      aps: apsUj ?? 0,
                      courses: "6+",
                      faculties: "",
                      route: GetAvailableCollegeCouresPage(
                        aps: apsUj ?? 0,
                        collegeName: 'West Coast TVET College',
                      ),
                      isBookmarked: true,
                      onBookmarkPressed: () =>
                          _toggleBookmark('West Coast TVET College'),
                    );
                  case 'Ikhala TVET College':
                    return CollegeCard(
                      title: 'Ikhala TVET College',
                      logo:
                          'assets/images/college_images/ikhala_tvet_college.jpg',
                      aps: apsUj ?? 0,
                      courses: "6+",
                      faculties: "",
                      route: GetAvailableCollegeCouresPage(
                        aps: apsUj ?? 0,
                        collegeName: 'Ikhala TVET College',
                      ),
                      isBookmarked: true,
                      onBookmarkPressed: () =>
                          _toggleBookmark('Ikhala TVET College'),
                    );
                  case 'Northern Cape Rural TVET College':
                    return CollegeCard(
                      title: 'Northern Cape Rural TVET College',
                      logo: 'assets/images/college_images/NCRTvet_logo.jpg',
                      aps: apsUj ?? 0,
                      courses: "6+",
                      faculties: "",
                      route: GetAvailableCollegeCouresPage(
                        aps: apsUj ?? 0,
                        collegeName: 'Northern Cape Rural TVET College',
                      ),
                      isBookmarked: true,
                      onBookmarkPressed: () =>
                          _toggleBookmark('Northern Cape Rural TVET College'),
                    );
                  default:
                    return ListTile(
                      title: Text(universityName),
                    );
                }
              },
            )
          : const Center(child: Text('No bookmarks yet')),
    );
  }

  Widget _buildSearchResultTab(double screenWidth) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
      child: universityCards.isNotEmpty
          ? ListView(
              children: universityCards
                  .map((card) => Padding(
                        padding: const EdgeInsets.only(top: 10, bottom: 20.0),
                        child: card,
                      ))
                  .toList(),
            )
          : const Center(child: Text('No institution found.')),
    );
  }

  // ignore: non_constant_identifier_names
  Future<void> _fetchAvailableCourses_uj() async {
    try {
      final userMarksResponse = await _supabaseClient
          .from('user_marks')
          .select(
              'math_mark, math_level, math_type, home_language_mark, home_language_level, first_additional_language_mark, first_additional_language_level, second_additional_language_mark, second_additional_language_level, subject1, subject1_level, subject2, subject2_level, subject3, subject3_level, subject4, subject4_level, life_orientation_mark, life_orientation_level, home_language, first_additional_language, second_additional_language')
          .eq('user_id', _supabaseClient.auth.currentUser!.id)
          .single();

      final userMarks = userMarksResponse;

      // Fetch courses from the specific university
      final response = await _supabaseClient
          .from('universities')
          .select(
              'university_name, qualification, aps, faculty, english_hl, english_fal, maths, technical_math, maths_lit, physical_sciences, life_orientation, accounting, business_studies, economics, history, geography, tourism, civil_technology, egd, cat, it, electrical_technology, mechanical_technology')
          .eq('university_name',
              'University of Johannesburg'); // Filter by university name

      final Map<String, List<Map<String, dynamic>>> groupedCourses = {};

      // Mapping user subjects to university columns
      final subjectMapping = {
        'Physical Sciences': 'physical_sciences',
        'Accounting': 'accounting',
        'Business Studies': 'business_studies',
        'Economics': 'economics',
        'History': 'history',
        'Geography': 'geography',
        'Tourism': 'tourism',
        'Civil Technology': 'civil_technology',
        'Engineering Graphics and Design': 'egd',
        'Computer Applications Technology': 'cat',
        'Information Technology': 'it',
        'Electrical Technology': 'electrical_technology',
        'Mechanical Technology': 'mechanical_technology',
      };

      for (var university in response) {
        bool meetsRequirements = true;

        // Skip APS comparison if APS is null in the universities table
        if (university['aps'] != null) {
          if (apsUj! < university['aps']) {
            meetsRequirements = false;
            continue; // Skip this course if APS does not meet the requirement
          }
        }

        // Compare based on math_type
        if (userMarks['math_type'] == 'Mathematics') {
          if ((userMarks['math_level'] ?? 0) < (university['maths'] ?? 0)) {
            meetsRequirements = false;
          }
        } else if (userMarks['math_type'] == 'Mathematical Literacy') {
          if ((userMarks['math_level'] ?? 0) < (university['maths_lit'] ?? 0)) {
            meetsRequirements = false;
          }
        } else if (userMarks['math_type'] == 'Technical Mathematics') {
          if ((userMarks['math_level'] ?? 0) <
              (university['technical_math'] ?? 0)) {
            meetsRequirements = false;
          }
        }

        // Check English requirements
        bool hasEnglishHL = userMarks['home_language']
                ?.toString()
                .toLowerCase()
                .contains('english') ??
            false;
        bool hasEnglishFAL = userMarks['first_additional_language']
                ?.toString()
                .toLowerCase()
                .contains('english') ??
            false;

        if (hasEnglishHL) {
          if ((userMarks['home_language_level'] ?? 0) <
              (university['english_hl'] ?? 0)) {
            meetsRequirements = false;
          }
        } else if (hasEnglishFAL) {
          if ((userMarks['first_additional_language_level'] ?? 0) <
              (university['english_fal'] ?? 0)) {
            meetsRequirements = false;
          }
        } else {
          meetsRequirements = false;
        }

        // Iterate over the subjects required by the university
        subjectMapping.forEach((key, subjectName) {
          // Get the required level for this subject from the university
          final requiredLevel = university[key];

          // If the university has a requirement for this subject
          if (requiredLevel != null) {
            bool subjectFound = false;

            // Check if any of the user's selected subjects match this university subject
            for (int i = 1; i <= 4; i++) {
              final userSubject = userMarks['subject$i'];
              final userLevel = userMarks['subject${i}_level'];

              // If the user's subject matches the university-required subject
              if (userSubject == subjectName) {
                subjectFound = true;

                // If the user's subject level is less than the required level, they don't qualify
                if ((userLevel ?? 0) < requiredLevel) {
                  meetsRequirements = false;
                  break;
                }
              }
            }

            // If the required subject wasn't found in the user's selected subjects
            if (!subjectFound) {
              meetsRequirements = false;
            }
          }
        });

        // If requirements are met, add to the list
        if (meetsRequirements) {
          final faculty = university['faculty'] ?? 'Unknown Faculty';
          if (!groupedCourses.containsKey(faculty)) {
            groupedCourses[faculty] = [];
          }
          groupedCourses[faculty]!.add(university);
        }
      }

      setState(() {
        facultyCourses = groupedCourses;
        visibleCoursesPerFaculty = {
          for (var faculty in groupedCourses.keys) faculty: 5
        };
        isLoading = false;
      });

      // Print the number of faculties and courses returned
      ujFaculties = facultyCourses.keys.length;
      ujCourses = facultyCourses.values.expand((list) => list).length;
    } catch (error) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchAvailableCourses_up() async {
    try {
      final userMarksResponse = await _supabaseClient
          .from('user_marks')
          .select(
              'math_mark, math_level, math_type, home_language_mark, home_language_level, first_additional_language_mark, first_additional_language_level, second_additional_language_mark, second_additional_language_level, subject1, subject1_level, subject2, subject2_level, subject3, subject3_level, subject4, subject4_level, life_orientation_mark, life_orientation_level, home_language, first_additional_language, second_additional_language')
          .eq('user_id', _supabaseClient.auth.currentUser!.id)
          .single();

      final userMarks = userMarksResponse;

      // Fetch courses from the specific university
      final response = await _supabaseClient
          .from('universities')
          .select(
              'university_name, qualification, aps, faculty, english_hl, english_fal, maths, technical_math, maths_lit, physical_sciences, life_orientation, accounting, business_studies, economics, history, geography, tourism, civil_technology, egd, cat, it, electrical_technology, mechanical_technology')
          .eq('university_name',
              'University of Pretoria'); // Filter by university name

      final Map<String, List<Map<String, dynamic>>> groupedCourses = {};

      // Mapping user subjects to university columns
      final subjectMapping = {
        'Physical Sciences': 'physical_sciences',
        'Accounting': 'accounting',
        'Business Studies': 'business_studies',
        'Economics': 'economics',
        'History': 'history',
        'Geography': 'geography',
        'Tourism': 'tourism',
        'Civil Technology': 'civil_technology',
        'Engineering Graphics and Design': 'egd',
        'Computer Applications Technology': 'cat',
        'Information Technology': 'it',
        'Electrical Technology': 'electrical_technology',
        'Mechanical Technology': 'mechanical_technology',
      };

      for (var university in response) {
        bool meetsRequirements = true;

        // Skip APS comparison if APS is null in the universities table
        if (university['aps'] != null) {
          if (apsUj! < university['aps']) {
            meetsRequirements = false;
            continue; // Skip this course if APS does not meet the requirement
          }
        }

        // Compare based on math_type
        if (userMarks['math_type'] == 'Mathematics') {
          if ((userMarks['math_level'] ?? 0) < (university['maths'] ?? 0)) {
            meetsRequirements = false;
          }
        } else if (userMarks['math_type'] == 'Mathematical Literacy') {
          if ((userMarks['math_level'] ?? 0) < (university['maths_lit'] ?? 0)) {
            meetsRequirements = false;
          }
        } else if (userMarks['math_type'] == 'Technical Mathematics') {
          if ((userMarks['math_level'] ?? 0) <
              (university['technical_math'] ?? 0)) {
            meetsRequirements = false;
          }
        }

        // Check English requirements
        bool hasEnglishHL = userMarks['home_language']
                ?.toString()
                .toLowerCase()
                .contains('english') ??
            false;
        bool hasEnglishFAL = userMarks['first_additional_language']
                ?.toString()
                .toLowerCase()
                .contains('english') ??
            false;

        if (hasEnglishHL) {
          if ((userMarks['home_language_level'] ?? 0) <
              (university['english_hl'] ?? 0)) {
            meetsRequirements = false;
          }
        } else if (hasEnglishFAL) {
          if ((userMarks['first_additional_language_level'] ?? 0) <
              (university['english_fal'] ?? 0)) {
            meetsRequirements = false;
          }
        } else {
          meetsRequirements = false;
        }

        // Iterate over the subjects required by the university
        subjectMapping.forEach((key, subjectName) {
          // Get the required level for this subject from the university
          final requiredLevel = university[key];

          // If the university has a requirement for this subject
          if (requiredLevel != null) {
            bool subjectFound = false;

            // Check if any of the user's selected subjects match this university subject
            for (int i = 1; i <= 4; i++) {
              final userSubject = userMarks['subject$i'];
              final userLevel = userMarks['subject${i}_level'];

              // If the user's subject matches the university-required subject
              if (userSubject == subjectName) {
                subjectFound = true;

                // If the user's subject level is less than the required level, they don't qualify
                if ((userLevel ?? 0) < requiredLevel) {
                  meetsRequirements = false;
                  break;
                }
              }
            }

            // If the required subject wasn't found in the user's selected subjects
            if (!subjectFound) {
              meetsRequirements = false;
            }
          }
        });

        // If requirements are met, add to the list
        if (meetsRequirements) {
          final faculty = university['faculty'] ?? 'Unknown Faculty';
          if (!groupedCourses.containsKey(faculty)) {
            groupedCourses[faculty] = [];
          }
          groupedCourses[faculty]!.add(university);
        }
      }

      setState(() {
        facultyCourses = groupedCourses;
        visibleCoursesPerFaculty = {
          for (var faculty in groupedCourses.keys) faculty: 5
        };
        isLoading = false;
      });

      // Print the number of faculties and courses returned
      upFaculties = facultyCourses.keys.length;
      upCourses = facultyCourses.values.expand((list) => list).length;
    } catch (error) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchAvailableCourses_cput() async {
    try {
      final userMarksResponse = await _supabaseClient
          .from('user_marks')
          .select(
              'math_mark, math_level, math_type, home_language_mark, home_language_level, first_additional_language_mark, first_additional_language_level, second_additional_language_mark, second_additional_language_level, subject1, subject1_level, subject2, subject2_level, subject3, subject3_level, subject4, subject4_level, life_orientation_mark, life_orientation_level, home_language, first_additional_language, second_additional_language')
          .eq('user_id', _supabaseClient.auth.currentUser!.id)
          .single();

      final userMarks = userMarksResponse;

      // Fetch courses from the specific university
      final response = await _supabaseClient
          .from('universities')
          .select(
              'university_name, qualification, aps, faculty, english_hl, english_fal, maths, technical_math, maths_lit, physical_sciences, life_orientation, accounting, business_studies, economics, history, geography, tourism, civil_technology, egd, cat, it, electrical_technology, mechanical_technology')
          .eq('university_name',
              'Cape Peninsula University of Technology'); // Filter by university name

      final Map<String, List<Map<String, dynamic>>> groupedCourses = {};

      // Mapping user subjects to university columns
      final subjectMapping = {
        'Physical Sciences': 'physical_sciences',
        'Accounting': 'accounting',
        'Business Studies': 'business_studies',
        'Economics': 'economics',
        'History': 'history',
        'Geography': 'geography',
        'Tourism': 'tourism',
        'Civil Technology': 'civil_technology',
        'Engineering Graphics and Design': 'egd',
        'Computer Applications Technology': 'cat',
        'Information Technology': 'it',
        'Electrical Technology': 'electrical_technology',
        'Mechanical Technology': 'mechanical_technology',
      };

      for (var university in response) {
        bool meetsRequirements = true;

        // Skip APS comparison if APS is null in the universities table
        if (university['aps'] != null) {
          if (apsCput! < university['aps']) {
            meetsRequirements = false;
            continue; // Skip this course if APS does not meet the requirement
          }
        }

        // Compare based on math_type
        if (userMarks['math_type'] == 'Mathematics') {
          if ((userMarks['math_level'] ?? 0) < (university['maths'] ?? 0)) {
            meetsRequirements = false;
          }
        } else if (userMarks['math_type'] == 'Mathematical Literacy') {
          if ((userMarks['math_level'] ?? 0) < (university['maths_lit'] ?? 0)) {
            meetsRequirements = false;
          }
        } else if (userMarks['math_type'] == 'Technical Mathematics') {
          if ((userMarks['math_level'] ?? 0) <
              (university['technical_math'] ?? 0)) {
            meetsRequirements = false;
          }
        }

        // Check English requirements
        bool hasEnglishHL = userMarks['home_language']
                ?.toString()
                .toLowerCase()
                .contains('english') ??
            false;
        bool hasEnglishFAL = userMarks['first_additional_language']
                ?.toString()
                .toLowerCase()
                .contains('english') ??
            false;

        if (hasEnglishHL) {
          if ((userMarks['home_language_level'] ?? 0) <
              (university['english_hl'] ?? 0)) {
            meetsRequirements = false;
          }
        } else if (hasEnglishFAL) {
          if ((userMarks['first_additional_language_level'] ?? 0) <
              (university['english_fal'] ?? 0)) {
            meetsRequirements = false;
          }
        } else {
          meetsRequirements = false;
        }

        // Iterate over the subjects required by the university
        subjectMapping.forEach((key, subjectName) {
          // Get the required level for this subject from the university
          final requiredLevel = university[key];

          // If the university has a requirement for this subject
          if (requiredLevel != null) {
            bool subjectFound = false;

            // Check if any of the user's selected subjects match this university subject
            for (int i = 1; i <= 4; i++) {
              final userSubject = userMarks['subject$i'];
              final userLevel = userMarks['subject${i}_level'];

              // If the user's subject matches the university-required subject
              if (userSubject == subjectName) {
                subjectFound = true;

                // If the user's subject level is less than the required level, they don't qualify
                if ((userLevel ?? 0) < requiredLevel) {
                  meetsRequirements = false;
                  break;
                }
              }
            }

            // If the required subject wasn't found in the user's selected subjects
            if (!subjectFound) {
              meetsRequirements = false;
            }
          }
        });

        // If requirements are met, add to the list
        if (meetsRequirements) {
          final faculty = university['faculty'] ?? 'Unknown Faculty';
          if (!groupedCourses.containsKey(faculty)) {
            groupedCourses[faculty] = [];
          }
          groupedCourses[faculty]!.add(university);
        }
      }

      setState(() {
        facultyCourses = groupedCourses;
        visibleCoursesPerFaculty = {
          for (var faculty in groupedCourses.keys) faculty: 5
        };
        isLoading = false;
      });

      // Print the number of faculties and courses returned
      cputFaculties = facultyCourses.keys.length;
      cputCourses = facultyCourses.values.expand((list) => list).length;
    } catch (error) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchAvailableCourses_ump() async {
    try {
      final userMarksResponse = await _supabaseClient
          .from('user_marks')
          .select(
              'math_mark, math_level, math_type, home_language_mark, home_language_level, first_additional_language_mark, first_additional_language_level, second_additional_language_mark, second_additional_language_level, subject1, subject1_level, subject2, subject2_level, subject3, subject3_level, subject4, subject4_level, life_orientation_mark, life_orientation_level, home_language, first_additional_language, second_additional_language')
          .eq('user_id', _supabaseClient.auth.currentUser!.id)
          .single();

      final userMarks = userMarksResponse;

      // Fetch courses from the specific university
      final response = await _supabaseClient
          .from('universities')
          .select(
              'university_name, qualification, aps, faculty, english_hl, english_fal, maths, technical_math, maths_lit, physical_sciences, life_orientation, accounting, business_studies, economics, history, geography, tourism, civil_technology, egd, cat, it, electrical_technology, mechanical_technology')
          .eq('university_name',
              'University of Mpumalanga'); // Filter by university name

      final Map<String, List<Map<String, dynamic>>> groupedCourses = {};

      // Mapping user subjects to university columns
      final subjectMapping = {
        'Physical Sciences': 'physical_sciences',
        'Accounting': 'accounting',
        'Business Studies': 'business_studies',
        'Economics': 'economics',
        'History': 'history',
        'Geography': 'geography',
        'Tourism': 'tourism',
        'Civil Technology': 'civil_technology',
        'Engineering Graphics and Design': 'egd',
        'Computer Applications Technology': 'cat',
        'Information Technology': 'it',
        'Electrical Technology': 'electrical_technology',
        'Mechanical Technology': 'mechanical_technology',
      };

      for (var university in response) {
        bool meetsRequirements = true;

        // Skip APS comparison if APS is null in the universities table
        if (university['aps'] != null) {
          if (apsUmp! < university['aps']) {
            meetsRequirements = false;
            continue; // Skip this course if APS does not meet the requirement
          }
        }

        // Compare based on math_type
        if (userMarks['math_type'] == 'Mathematics') {
          if ((userMarks['math_level'] ?? 0) < (university['maths'] ?? 0)) {
            meetsRequirements = false;
          }
        } else if (userMarks['math_type'] == 'Mathematical Literacy') {
          if ((userMarks['math_level'] ?? 0) < (university['maths_lit'] ?? 0)) {
            meetsRequirements = false;
          }
        } else if (userMarks['math_type'] == 'Technical Mathematics') {
          if ((userMarks['math_level'] ?? 0) <
              (university['technical_math'] ?? 0)) {
            meetsRequirements = false;
          }
        }

        // Check English requirements
        bool hasEnglishHL = userMarks['home_language']
                ?.toString()
                .toLowerCase()
                .contains('english') ??
            false;
        bool hasEnglishFAL = userMarks['first_additional_language']
                ?.toString()
                .toLowerCase()
                .contains('english') ??
            false;

        if (hasEnglishHL) {
          if ((userMarks['home_language_level'] ?? 0) <
              (university['english_hl'] ?? 0)) {
            meetsRequirements = false;
          }
        } else if (hasEnglishFAL) {
          if ((userMarks['first_additional_language_level'] ?? 0) <
              (university['english_fal'] ?? 0)) {
            meetsRequirements = false;
          }
        } else {
          meetsRequirements = false;
        }

        // Iterate over the subjects required by the university
        subjectMapping.forEach((key, subjectName) {
          // Get the required level for this subject from the university
          final requiredLevel = university[key];

          // If the university has a requirement for this subject
          if (requiredLevel != null) {
            bool subjectFound = false;

            // Check if any of the user's selected subjects match this university subject
            for (int i = 1; i <= 4; i++) {
              final userSubject = userMarks['subject$i'];
              final userLevel = userMarks['subject${i}_level'];

              // If the user's subject matches the university-required subject
              if (userSubject == subjectName) {
                subjectFound = true;

                // If the user's subject level is less than the required level, they don't qualify
                if ((userLevel ?? 0) < requiredLevel) {
                  meetsRequirements = false;
                  break;
                }
              }
            }

            // If the required subject wasn't found in the user's selected subjects
            if (!subjectFound) {
              meetsRequirements = false;
            }
          }
        });

        // If requirements are met, add to the list
        if (meetsRequirements) {
          final faculty = university['faculty'] ?? 'Unknown Faculty';
          if (!groupedCourses.containsKey(faculty)) {
            groupedCourses[faculty] = [];
          }
          groupedCourses[faculty]!.add(university);
        }
      }

      setState(() {
        facultyCourses = groupedCourses;
        visibleCoursesPerFaculty = {
          for (var faculty in groupedCourses.keys) faculty: 5
        };
        isLoading = false;
      });

      // Print the number of faculties and courses returned
      umpFaculties = facultyCourses.keys.length;
      umpCourses = facultyCourses.values.expand((list) => list).length;
    } catch (error) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchAvailableCourses_spu() async {
    try {
      final userMarksResponse = await _supabaseClient
          .from('user_marks')
          .select(
              'math_mark, math_level, math_type, home_language_mark, home_language_level, first_additional_language_mark, first_additional_language_level, second_additional_language_mark, second_additional_language_level, subject1, subject1_level, subject2, subject2_level, subject3, subject3_level, subject4, subject4_level, life_orientation_mark, life_orientation_level, home_language, first_additional_language, second_additional_language')
          .eq('user_id', _supabaseClient.auth.currentUser!.id)
          .single();

      final userMarks = userMarksResponse;

      // Fetch courses from the specific university
      final response = await _supabaseClient
          .from('universities')
          .select(
              'university_name, qualification, aps, faculty, english_hl, english_fal, maths, technical_math, maths_lit, physical_sciences, life_orientation, accounting, business_studies, economics, history, geography, tourism, civil_technology, egd, cat, it, electrical_technology, mechanical_technology')
          .eq('university_name',
              'Sol Plaatje University'); // Filter by university name

      final Map<String, List<Map<String, dynamic>>> groupedCourses = {};

      // Mapping user subjects to university columns
      final subjectMapping = {
        'Physical Sciences': 'physical_sciences',
        'Accounting': 'accounting',
        'Business Studies': 'business_studies',
        'Economics': 'economics',
        'History': 'history',
        'Geography': 'geography',
        'Tourism': 'tourism',
        'Civil Technology': 'civil_technology',
        'Engineering Graphics and Design': 'egd',
        'Computer Applications Technology': 'cat',
        'Information Technology': 'it',
        'Electrical Technology': 'electrical_technology',
        'Mechanical Technology': 'mechanical_technology',
      };

      for (var university in response) {
        bool meetsRequirements = true;

        // Skip APS comparison if APS is null in the universities table
        if (university['aps'] != null) {
          if (apsSpu! < university['aps']) {
            meetsRequirements = false;
            continue; // Skip this course if APS does not meet the requirement
          }
        }

        // Compare based on math_type
        if (userMarks['math_type'] == 'Mathematics') {
          if ((userMarks['math_level'] ?? 0) < (university['maths'] ?? 0)) {
            meetsRequirements = false;
          }
        } else if (userMarks['math_type'] == 'Mathematical Literacy') {
          if ((userMarks['math_level'] ?? 0) < (university['maths_lit'] ?? 0)) {
            meetsRequirements = false;
          }
        } else if (userMarks['math_type'] == 'Technical Mathematics') {
          if ((userMarks['math_level'] ?? 0) <
              (university['technical_math'] ?? 0)) {
            meetsRequirements = false;
          }
        }

        // Check English requirements
        bool hasEnglishHL = userMarks['home_language']
                ?.toString()
                .toLowerCase()
                .contains('english') ??
            false;
        bool hasEnglishFAL = userMarks['first_additional_language']
                ?.toString()
                .toLowerCase()
                .contains('english') ??
            false;

        if (hasEnglishHL) {
          if ((userMarks['home_language_level'] ?? 0) <
              (university['english_hl'] ?? 0)) {
            meetsRequirements = false;
          }
        } else if (hasEnglishFAL) {
          if ((userMarks['first_additional_language_level'] ?? 0) <
              (university['english_fal'] ?? 0)) {
            meetsRequirements = false;
          }
        } else {
          meetsRequirements = false;
        }

        // Iterate over the subjects required by the university
        subjectMapping.forEach((key, subjectName) {
          // Get the required level for this subject from the university
          final requiredLevel = university[key];

          // If the university has a requirement for this subject
          if (requiredLevel != null) {
            bool subjectFound = false;

            // Check if any of the user's selected subjects match this university subject
            for (int i = 1; i <= 4; i++) {
              final userSubject = userMarks['subject$i'];
              final userLevel = userMarks['subject${i}_level'];

              // If the user's subject matches the university-required subject
              if (userSubject == subjectName) {
                subjectFound = true;

                // If the user's subject level is less than the required level, they don't qualify
                if ((userLevel ?? 0) < requiredLevel) {
                  meetsRequirements = false;
                  break;
                }
              }
            }

            // If the required subject wasn't found in the user's selected subjects
            if (!subjectFound) {
              meetsRequirements = false;
            }
          }
        });

        // If requirements are met, add to the list
        if (meetsRequirements) {
          final faculty = university['faculty'] ?? 'Unknown Faculty';
          if (!groupedCourses.containsKey(faculty)) {
            groupedCourses[faculty] = [];
          }
          groupedCourses[faculty]!.add(university);
        }
      }

      setState(() {
        facultyCourses = groupedCourses;
        visibleCoursesPerFaculty = {
          for (var faculty in groupedCourses.keys) faculty: 5
        };
        isLoading = false;
      });

      // Print the number of faculties and courses returned
      spuFaculties = facultyCourses.keys.length;
      spuCourses = facultyCourses.values.expand((list) => list).length;
    } catch (error) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchAvailableCourses_ufh() async {
    try {
      final userMarksResponse = await _supabaseClient
          .from('user_marks')
          .select(
              'math_mark, math_level, math_type, home_language_mark, home_language_level, first_additional_language_mark, first_additional_language_level, second_additional_language_mark, second_additional_language_level, subject1, subject1_level, subject2, subject2_level, subject3, subject3_level, subject4, subject4_level, life_orientation_mark, life_orientation_level, home_language, first_additional_language, second_additional_language')
          .eq('user_id', _supabaseClient.auth.currentUser!.id)
          .single();

      final userMarks = userMarksResponse;

      // Fetch courses from the specific university
      final response = await _supabaseClient
          .from('universities')
          .select(
              'university_name, qualification, aps, faculty, english_hl, english_fal, maths, technical_math, maths_lit, physical_sciences, life_orientation, accounting, business_studies, economics, history, geography, tourism, civil_technology, egd, cat, it, electrical_technology, mechanical_technology')
          .eq('university_name',
              'University of Fort Hare'); // Filter by university name

      final Map<String, List<Map<String, dynamic>>> groupedCourses = {};

      // Mapping user subjects to university columns
      final subjectMapping = {
        'Physical Sciences': 'physical_sciences',
        'Accounting': 'accounting',
        'Business Studies': 'business_studies',
        'Economics': 'economics',
        'History': 'history',
        'Geography': 'geography',
        'Tourism': 'tourism',
        'Civil Technology': 'civil_technology',
        'Engineering Graphics and Design': 'egd',
        'Computer Applications Technology': 'cat',
        'Information Technology': 'it',
        'Electrical Technology': 'electrical_technology',
        'Mechanical Technology': 'mechanical_technology',
      };

      for (var university in response) {
        bool meetsRequirements = true;

        // Skip APS comparison if APS is null in the universities table
        if (university['aps'] != null) {
          if (apsUfh! < university['aps']) {
            meetsRequirements = false;
            continue; // Skip this course if APS does not meet the requirement
          }
        }

        // Compare based on math_type
        if (userMarks['math_type'] == 'Mathematics') {
          if ((userMarks['math_level'] ?? 0) < (university['maths'] ?? 0)) {
            meetsRequirements = false;
          }
        } else if (userMarks['math_type'] == 'Mathematical Literacy') {
          if ((userMarks['math_level'] ?? 0) < (university['maths_lit'] ?? 0)) {
            meetsRequirements = false;
          }
        } else if (userMarks['math_type'] == 'Technical Mathematics') {
          if ((userMarks['math_level'] ?? 0) <
              (university['technical_math'] ?? 0)) {
            meetsRequirements = false;
          }
        }

        // Check English requirements
        bool hasEnglishHL = userMarks['home_language']
                ?.toString()
                .toLowerCase()
                .contains('english') ??
            false;
        bool hasEnglishFAL = userMarks['first_additional_language']
                ?.toString()
                .toLowerCase()
                .contains('english') ??
            false;

        if (hasEnglishHL) {
          if ((userMarks['home_language_level'] ?? 0) <
              (university['english_hl'] ?? 0)) {
            meetsRequirements = false;
          }
        } else if (hasEnglishFAL) {
          if ((userMarks['first_additional_language_level'] ?? 0) <
              (university['english_fal'] ?? 0)) {
            meetsRequirements = false;
          }
        } else {
          meetsRequirements = false;
        }

        // Iterate over the subjects required by the university
        subjectMapping.forEach((key, subjectName) {
          // Get the required level for this subject from the university
          final requiredLevel = university[key];

          // If the university has a requirement for this subject
          if (requiredLevel != null) {
            bool subjectFound = false;

            // Check if any of the user's selected subjects match this university subject
            for (int i = 1; i <= 4; i++) {
              final userSubject = userMarks['subject$i'];
              final userLevel = userMarks['subject${i}_level'];

              // If the user's subject matches the university-required subject
              if (userSubject == subjectName) {
                subjectFound = true;

                // If the user's subject level is less than the required level, they don't qualify
                if ((userLevel ?? 0) < requiredLevel) {
                  meetsRequirements = false;
                  break;
                }
              }
            }

            // If the required subject wasn't found in the user's selected subjects
            if (!subjectFound) {
              meetsRequirements = false;
            }
          }
        });

        // If requirements are met, add to the list
        if (meetsRequirements) {
          final faculty = university['faculty'] ?? 'Unknown Faculty';
          if (!groupedCourses.containsKey(faculty)) {
            groupedCourses[faculty] = [];
          }
          groupedCourses[faculty]!.add(university);
        }
      }

      setState(() {
        facultyCourses = groupedCourses;
        visibleCoursesPerFaculty = {
          for (var faculty in groupedCourses.keys) faculty: 5
        };
        isLoading = false;
      });

      // Print the number of faculties and courses returned
      ufhFaculties = facultyCourses.keys.length;
      ufhCourses = facultyCourses.values.expand((list) => list).length;
    } catch (error) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchAvailableCourses_vut() async {
    try {
      final userMarksResponse = await _supabaseClient
          .from('user_marks')
          .select(
              'math_mark, math_level, math_type, home_language_mark, home_language_level, first_additional_language_mark, first_additional_language_level, second_additional_language_mark, second_additional_language_level, subject1, subject1_level, subject2, subject2_level, subject3, subject3_level, subject4, subject4_level, life_orientation_mark, life_orientation_level, home_language, first_additional_language, second_additional_language')
          .eq('user_id', _supabaseClient.auth.currentUser!.id)
          .single();

      final userMarks = userMarksResponse;

      // Fetch courses from the specific university
      final response = await _supabaseClient
          .from('universities')
          .select(
              'university_name, qualification, aps, faculty, english_hl, english_fal, maths, technical_math, maths_lit, physical_sciences, life_orientation, accounting, business_studies, economics, history, geography, tourism, civil_technology, egd, cat, it, electrical_technology, mechanical_technology')
          .eq('university_name',
              'Vaal University of Technology'); // Filter by university name

      final Map<String, List<Map<String, dynamic>>> groupedCourses = {};

      // Mapping user subjects to university columns
      final subjectMapping = {
        'Physical Sciences': 'physical_sciences',
        'Accounting': 'accounting',
        'Business Studies': 'business_studies',
        'Economics': 'economics',
        'History': 'history',
        'Geography': 'geography',
        'Tourism': 'tourism',
        'Civil Technology': 'civil_technology',
        'Engineering Graphics and Design': 'egd',
        'Computer Applications Technology': 'cat',
        'Information Technology': 'it',
        'Electrical Technology': 'electrical_technology',
        'Mechanical Technology': 'mechanical_technology',
      };

      for (var university in response) {
        bool meetsRequirements = true;

        // Skip APS comparison if APS is null in the universities table
        if (university['aps'] != null) {
          if (apsCput! < university['aps']) {
            meetsRequirements = false;
            continue; // Skip this course if APS does not meet the requirement
          }
        }

        // Compare based on math_type
        if (userMarks['math_type'] == 'Mathematics') {
          if ((userMarks['math_level'] ?? 0) < (university['maths'] ?? 0)) {
            meetsRequirements = false;
          }
        } else if (userMarks['math_type'] == 'Mathematical Literacy') {
          if ((userMarks['math_level'] ?? 0) < (university['maths_lit'] ?? 0)) {
            meetsRequirements = false;
          }
        } else if (userMarks['math_type'] == 'Technical Mathematics') {
          if ((userMarks['math_level'] ?? 0) <
              (university['technical_math'] ?? 0)) {
            meetsRequirements = false;
          }
        }

        // Check English requirements
        bool hasEnglishHL = userMarks['home_language']
                ?.toString()
                .toLowerCase()
                .contains('english') ??
            false;
        bool hasEnglishFAL = userMarks['first_additional_language']
                ?.toString()
                .toLowerCase()
                .contains('english') ??
            false;

        if (hasEnglishHL) {
          if ((userMarks['home_language_level'] ?? 0) <
              (university['english_hl'] ?? 0)) {
            meetsRequirements = false;
          }
        } else if (hasEnglishFAL) {
          if ((userMarks['first_additional_language_level'] ?? 0) <
              (university['english_fal'] ?? 0)) {
            meetsRequirements = false;
          }
        } else {
          meetsRequirements = false;
        }

        // Iterate over the subjects required by the university
        subjectMapping.forEach((key, subjectName) {
          // Get the required level for this subject from the university
          final requiredLevel = university[key];

          // If the university has a requirement for this subject
          if (requiredLevel != null) {
            bool subjectFound = false;

            // Check if any of the user's selected subjects match this university subject
            for (int i = 1; i <= 4; i++) {
              final userSubject = userMarks['subject$i'];
              final userLevel = userMarks['subject${i}_level'];

              // If the user's subject matches the university-required subject
              if (userSubject == subjectName) {
                subjectFound = true;

                // If the user's subject level is less than the required level, they don't qualify
                if ((userLevel ?? 0) < requiredLevel) {
                  meetsRequirements = false;
                  break;
                }
              }
            }

            // If the required subject wasn't found in the user's selected subjects
            if (!subjectFound) {
              meetsRequirements = false;
            }
          }
        });

        // If requirements are met, add to the list
        if (meetsRequirements) {
          final faculty = university['faculty'] ?? 'Unknown Faculty';
          if (!groupedCourses.containsKey(faculty)) {
            groupedCourses[faculty] = [];
          }
          groupedCourses[faculty]!.add(university);
        }
      }

      setState(() {
        facultyCourses = groupedCourses;
        visibleCoursesPerFaculty = {
          for (var faculty in groupedCourses.keys) faculty: 5
        };
        isLoading = false;
      });

      // Print the number of faculties and courses returned
      cputFaculties = facultyCourses.keys.length;
      cputCourses = facultyCourses.values.expand((list) => list).length;
    } catch (error) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchAvailableCourses_mut() async {
    try {
      final userMarksResponse = await _supabaseClient
          .from('user_marks')
          .select(
              'math_mark, math_level, math_type, home_language_mark, home_language_level, first_additional_language_mark, first_additional_language_level, second_additional_language_mark, second_additional_language_level, subject1, subject1_level, subject2, subject2_level, subject3, subject3_level, subject4, subject4_level, life_orientation_mark, life_orientation_level, home_language, first_additional_language, second_additional_language')
          .eq('user_id', _supabaseClient.auth.currentUser!.id)
          .single();

      final userMarks = userMarksResponse;

      // Fetch courses from the specific university
      final response = await _supabaseClient
          .from('universities')
          .select(
              'university_name, qualification, aps, faculty, english_hl, english_fal, maths, technical_math, maths_lit, physical_sciences, life_orientation, accounting, business_studies, economics, history, geography, tourism, civil_technology, egd, cat, it, electrical_technology, mechanical_technology')
          .eq('university_name',
              'Mangosuthu University of Technology'); // Filter by university name

      final Map<String, List<Map<String, dynamic>>> groupedCourses = {};

      // Mapping user subjects to university columns
      final subjectMapping = {
        'Physical Sciences': 'physical_sciences',
        'Accounting': 'accounting',
        'Business Studies': 'business_studies',
        'Economics': 'economics',
        'History': 'history',
        'Geography': 'geography',
        'Tourism': 'tourism',
        'Civil Technology': 'civil_technology',
        'Engineering Graphics and Design': 'egd',
        'Computer Applications Technology': 'cat',
        'Information Technology': 'it',
        'Electrical Technology': 'electrical_technology',
        'Mechanical Technology': 'mechanical_technology',
      };

      for (var university in response) {
        bool meetsRequirements = true;

        // Skip APS comparison if APS is null in the universities table
        if (university['aps'] != null) {
          if (apsMut! < university['aps']) {
            meetsRequirements = false;
            continue; // Skip this course if APS does not meet the requirement
          }
        }

        // Compare based on math_type
        if (userMarks['math_type'] == 'Mathematics') {
          if ((userMarks['math_level'] ?? 0) < (university['maths'] ?? 0)) {
            meetsRequirements = false;
          }
        } else if (userMarks['math_type'] == 'Mathematical Literacy') {
          if ((userMarks['math_level'] ?? 0) < (university['maths_lit'] ?? 0)) {
            meetsRequirements = false;
          }
        } else if (userMarks['math_type'] == 'Technical Mathematics') {
          if ((userMarks['math_level'] ?? 0) <
              (university['technical_math'] ?? 0)) {
            meetsRequirements = false;
          }
        }

        // Check English requirements
        bool hasEnglishHL = userMarks['home_language']
                ?.toString()
                .toLowerCase()
                .contains('english') ??
            false;
        bool hasEnglishFAL = userMarks['first_additional_language']
                ?.toString()
                .toLowerCase()
                .contains('english') ??
            false;

        if (hasEnglishHL) {
          if ((userMarks['home_language_level'] ?? 0) <
              (university['english_hl'] ?? 0)) {
            meetsRequirements = false;
          }
        } else if (hasEnglishFAL) {
          if ((userMarks['first_additional_language_level'] ?? 0) <
              (university['english_fal'] ?? 0)) {
            meetsRequirements = false;
          }
        } else {
          meetsRequirements = false;
        }

        // Iterate over the subjects required by the university
        subjectMapping.forEach((key, subjectName) {
          // Get the required level for this subject from the university
          final requiredLevel = university[key];

          // If the university has a requirement for this subject
          if (requiredLevel != null) {
            bool subjectFound = false;

            // Check if any of the user's selected subjects match this university subject
            for (int i = 1; i <= 4; i++) {
              final userSubject = userMarks['subject$i'];
              final userLevel = userMarks['subject${i}_level'];

              // If the user's subject matches the university-required subject
              if (userSubject == subjectName) {
                subjectFound = true;

                // If the user's subject level is less than the required level, they don't qualify
                if ((userLevel ?? 0) < requiredLevel) {
                  meetsRequirements = false;
                  break;
                }
              }
            }

            // If the required subject wasn't found in the user's selected subjects
            if (!subjectFound) {
              meetsRequirements = false;
            }
          }
        });

        // If requirements are met, add to the list
        if (meetsRequirements) {
          final faculty = university['faculty'] ?? 'Unknown Faculty';
          if (!groupedCourses.containsKey(faculty)) {
            groupedCourses[faculty] = [];
          }
          groupedCourses[faculty]!.add(university);
        }
      }

      setState(() {
        facultyCourses = groupedCourses;
        visibleCoursesPerFaculty = {
          for (var faculty in groupedCourses.keys) faculty: 5
        };
        isLoading = false;
      });

      // Print the number of faculties and courses returned
      mutFaculties = facultyCourses.keys.length;
      mutCourses = facultyCourses.values.expand((list) => list).length;
    } catch (error) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchAvailableCourses_uv() async {
    try {
      final userMarksResponse = await _supabaseClient
          .from('user_marks')
          .select(
              'math_mark, math_level, math_type, home_language_mark, home_language_level, first_additional_language_mark, first_additional_language_level, second_additional_language_mark, second_additional_language_level, subject1, subject1_level, subject2, subject2_level, subject3, subject3_level, subject4, subject4_level, life_orientation_mark, life_orientation_level, home_language, first_additional_language, second_additional_language')
          .eq('user_id', _supabaseClient.auth.currentUser!.id)
          .single();

      final userMarks = userMarksResponse;

      // Fetch courses from the specific university
      final response = await _supabaseClient
          .from('universities')
          .select(
              'university_name, qualification, aps, faculty, english_hl, english_fal, maths, technical_math, maths_lit, physical_sciences, life_orientation, accounting, business_studies, economics, history, geography, tourism, civil_technology, egd, cat, it, electrical_technology, mechanical_technology')
          .eq('university_name',
              'University of Venda '); // Filter by university name

      final Map<String, List<Map<String, dynamic>>> groupedCourses = {};

      // Mapping user subjects to university columns
      final subjectMapping = {
        'Physical Sciences': 'physical_sciences',
        'Accounting': 'accounting',
        'Business Studies': 'business_studies',
        'Economics': 'economics',
        'History': 'history',
        'Geography': 'geography',
        'Tourism': 'tourism',
        'Civil Technology': 'civil_technology',
        'Engineering Graphics and Design': 'egd',
        'Computer Applications Technology': 'cat',
        'Information Technology': 'it',
        'Electrical Technology': 'electrical_technology',
        'Mechanical Technology': 'mechanical_technology',
      };

      for (var university in response) {
        bool meetsRequirements = true;

        // Skip APS comparison if APS is null in the universities table
        if (university['aps'] != null) {
          if (apsCput! < university['aps']) {
            meetsRequirements = false;
            continue; // Skip this course if APS does not meet the requirement
          }
        }

        // Compare based on math_type
        if (userMarks['math_type'] == 'Mathematics') {
          if ((userMarks['math_level'] ?? 0) < (university['maths'] ?? 0)) {
            meetsRequirements = false;
          }
        } else if (userMarks['math_type'] == 'Mathematical Literacy') {
          if ((userMarks['math_level'] ?? 0) < (university['maths_lit'] ?? 0)) {
            meetsRequirements = false;
          }
        } else if (userMarks['math_type'] == 'Technical Mathematics') {
          if ((userMarks['math_level'] ?? 0) <
              (university['technical_math'] ?? 0)) {
            meetsRequirements = false;
          }
        }

        // Check English requirements
        bool hasEnglishHL = userMarks['home_language']
                ?.toString()
                .toLowerCase()
                .contains('english') ??
            false;
        bool hasEnglishFAL = userMarks['first_additional_language']
                ?.toString()
                .toLowerCase()
                .contains('english') ??
            false;

        if (hasEnglishHL) {
          if ((userMarks['home_language_level'] ?? 0) <
              (university['english_hl'] ?? 0)) {
            meetsRequirements = false;
          }
        } else if (hasEnglishFAL) {
          if ((userMarks['first_additional_language_level'] ?? 0) <
              (university['english_fal'] ?? 0)) {
            meetsRequirements = false;
          }
        } else {
          meetsRequirements = false;
        }

        // Iterate over the subjects required by the university
        subjectMapping.forEach((key, subjectName) {
          // Get the required level for this subject from the university
          final requiredLevel = university[key];

          // If the university has a requirement for this subject
          if (requiredLevel != null) {
            bool subjectFound = false;

            // Check if any of the user's selected subjects match this university subject
            for (int i = 1; i <= 4; i++) {
              final userSubject = userMarks['subject$i'];
              final userLevel = userMarks['subject${i}_level'];

              // If the user's subject matches the university-required subject
              if (userSubject == subjectName) {
                subjectFound = true;

                // If the user's subject level is less than the required level, they don't qualify
                if ((userLevel ?? 0) < requiredLevel) {
                  meetsRequirements = false;
                  break;
                }
              }
            }

            // If the required subject wasn't found in the user's selected subjects
            if (!subjectFound) {
              meetsRequirements = false;
            }
          }
        });

        // If requirements are met, add to the list
        if (meetsRequirements) {
          final faculty = university['faculty'] ?? 'Unknown Faculty';
          if (!groupedCourses.containsKey(faculty)) {
            groupedCourses[faculty] = [];
          }
          groupedCourses[faculty]!.add(university);
        }
      }

      setState(() {
        facultyCourses = groupedCourses;
        visibleCoursesPerFaculty = {
          for (var faculty in groupedCourses.keys) faculty: 5
        };
        isLoading = false;
      });

      // Print the number of faculties and courses returned
      univenFaculties = facultyCourses.keys.length;
      univenCourses = facultyCourses.values.expand((list) => list).length;
    } catch (error) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchAvailableCourses_uz() async {
    try {
      final userMarksResponse = await _supabaseClient
          .from('user_marks')
          .select(
              'math_mark, math_level, math_type, home_language_mark, home_language_level, first_additional_language_mark, first_additional_language_level, second_additional_language_mark, second_additional_language_level, subject1, subject1_level, subject2, subject2_level, subject3, subject3_level, subject4, subject4_level, life_orientation_mark, life_orientation_level, home_language, first_additional_language, second_additional_language')
          .eq('user_id', _supabaseClient.auth.currentUser!.id)
          .single();

      final userMarks = userMarksResponse;

      // Fetch courses from the specific university
      final response = await _supabaseClient
          .from('universities')
          .select(
              'university_name, qualification, aps, faculty, english_hl, english_fal, maths, technical_math, maths_lit, physical_sciences, life_orientation, accounting, business_studies, economics, history, geography, tourism, civil_technology, egd, cat, it, electrical_technology, mechanical_technology')
          .eq('university_name',
              'University of Zululand'); // Filter by university name

      final Map<String, List<Map<String, dynamic>>> groupedCourses = {};

      // Mapping user subjects to university columns
      final subjectMapping = {
        'Physical Sciences': 'physical_sciences',
        'Accounting': 'accounting',
        'Business Studies': 'business_studies',
        'Economics': 'economics',
        'History': 'history',
        'Geography': 'geography',
        'Tourism': 'tourism',
        'Civil Technology': 'civil_technology',
        'Engineering Graphics and Design': 'egd',
        'Computer Applications Technology': 'cat',
        'Information Technology': 'it',
        'Electrical Technology': 'electrical_technology',
        'Mechanical Technology': 'mechanical_technology',
      };

      for (var university in response) {
        bool meetsRequirements = true;

        // Skip APS comparison if APS is null in the universities table
        if (university['aps'] != null) {
          if (apsUz! < university['aps']) {
            meetsRequirements = false;
            continue; // Skip this course if APS does not meet the requirement
          }
        }

        // Compare based on math_type
        if (userMarks['math_type'] == 'Mathematics') {
          if ((userMarks['math_level'] ?? 0) < (university['maths'] ?? 0)) {
            meetsRequirements = false;
          }
        } else if (userMarks['math_type'] == 'Mathematical Literacy') {
          if ((userMarks['math_level'] ?? 0) < (university['maths_lit'] ?? 0)) {
            meetsRequirements = false;
          }
        } else if (userMarks['math_type'] == 'Technical Mathematics') {
          if ((userMarks['math_level'] ?? 0) <
              (university['technical_math'] ?? 0)) {
            meetsRequirements = false;
          }
        }

        // Check English requirements
        bool hasEnglishHL = userMarks['home_language']
                ?.toString()
                .toLowerCase()
                .contains('english') ??
            false;
        bool hasEnglishFAL = userMarks['first_additional_language']
                ?.toString()
                .toLowerCase()
                .contains('english') ??
            false;

        if (hasEnglishHL) {
          if ((userMarks['home_language_level'] ?? 0) <
              (university['english_hl'] ?? 0)) {
            meetsRequirements = false;
          }
        } else if (hasEnglishFAL) {
          if ((userMarks['first_additional_language_level'] ?? 0) <
              (university['english_fal'] ?? 0)) {
            meetsRequirements = false;
          }
        } else {
          meetsRequirements = false;
        }

        // Iterate over the subjects required by the university
        subjectMapping.forEach((key, subjectName) {
          // Get the required level for this subject from the university
          final requiredLevel = university[key];

          // If the university has a requirement for this subject
          if (requiredLevel != null) {
            bool subjectFound = false;

            // Check if any of the user's selected subjects match this university subject
            for (int i = 1; i <= 4; i++) {
              final userSubject = userMarks['subject$i'];
              final userLevel = userMarks['subject${i}_level'];

              // If the user's subject matches the university-required subject
              if (userSubject == subjectName) {
                subjectFound = true;

                // If the user's subject level is less than the required level, they don't qualify
                if ((userLevel ?? 0) < requiredLevel) {
                  meetsRequirements = false;
                  break;
                }
              }
            }

            // If the required subject wasn't found in the user's selected subjects
            if (!subjectFound) {
              meetsRequirements = false;
            }
          }
        });

        // If requirements are met, add to the list
        if (meetsRequirements) {
          final faculty = university['faculty'] ?? 'Unknown Faculty';
          if (!groupedCourses.containsKey(faculty)) {
            groupedCourses[faculty] = [];
          }
          groupedCourses[faculty]!.add(university);
        }
      }

      setState(() {
        facultyCourses = groupedCourses;
        visibleCoursesPerFaculty = {
          for (var faculty in groupedCourses.keys) faculty: 5
        };
        isLoading = false;
      });

      // Print the number of faculties and courses returned
      unizuluFaculties = facultyCourses.keys.length;
      unizuluCourses = facultyCourses.values.expand((list) => list).length;
    } catch (error) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchAvailableCourses_uct() async {
    try {
      final userMarksResponse = await _supabaseClient
          .from('user_marks')
          .select(
              'math_mark, math_level, math_type, home_language_mark, home_language_level, first_additional_language_mark, first_additional_language_level, second_additional_language_mark, second_additional_language_level, subject1, subject1_level, subject2, subject2_level, subject3, subject3_level, subject4, subject4_level, life_orientation_mark, life_orientation_level, home_language, first_additional_language, second_additional_language')
          .eq('user_id', _supabaseClient.auth.currentUser!.id)
          .single();

      final userMarks = userMarksResponse;

      // Fetch courses from the specific university
      final response = await _supabaseClient
          .from('universities')
          .select(
              'university_name, qualification, aps, faculty, english_hl, english_fal, maths, technical_math, maths_lit, physical_sciences, life_orientation, accounting, business_studies, economics, history, geography, tourism, civil_technology, egd, cat, it, electrical_technology, mechanical_technology')
          .eq('university_name',
              'University of Capetown'); // Filter by university name

      final Map<String, List<Map<String, dynamic>>> groupedCourses = {};

      // Mapping user subjects to university columns
      final subjectMapping = {
        'Physical Sciences': 'physical_sciences',
        'Accounting': 'accounting',
        'Business Studies': 'business_studies',
        'Economics': 'economics',
        'History': 'history',
        'Geography': 'geography',
        'Tourism': 'tourism',
        'Civil Technology': 'civil_technology',
        'Engineering Graphics and Design': 'egd',
        'Computer Applications Technology': 'cat',
        'Information Technology': 'it',
        'Electrical Technology': 'electrical_technology',
        'Mechanical Technology': 'mechanical_technology',
      };

      for (var university in response) {
        bool meetsRequirements = true;

        // Skip APS comparison if APS is null in the universities table
        if (university['aps'] != null) {
          if (apsCput! < university['aps']) {
            meetsRequirements = false;
            continue; // Skip this course if APS does not meet the requirement
          }
        }

        // Compare based on math_type
        if (userMarks['math_type'] == 'Mathematics') {
          if ((userMarks['math_level'] ?? 0) < (university['maths'] ?? 0)) {
            meetsRequirements = false;
          }
        } else if (userMarks['math_type'] == 'Mathematical Literacy') {
          if ((userMarks['math_level'] ?? 0) < (university['maths_lit'] ?? 0)) {
            meetsRequirements = false;
          }
        } else if (userMarks['math_type'] == 'Technical Mathematics') {
          if ((userMarks['math_level'] ?? 0) <
              (university['technical_math'] ?? 0)) {
            meetsRequirements = false;
          }
        }

        // Check English requirements
        bool hasEnglishHL = userMarks['home_language']
                ?.toString()
                .toLowerCase()
                .contains('english') ??
            false;
        bool hasEnglishFAL = userMarks['first_additional_language']
                ?.toString()
                .toLowerCase()
                .contains('english') ??
            false;

        if (hasEnglishHL) {
          if ((userMarks['home_language_level'] ?? 0) <
              (university['english_hl'] ?? 0)) {
            meetsRequirements = false;
          }
        } else if (hasEnglishFAL) {
          if ((userMarks['first_additional_language_level'] ?? 0) <
              (university['english_fal'] ?? 0)) {
            meetsRequirements = false;
          }
        } else {
          meetsRequirements = false;
        }

        // Iterate over the subjects required by the university
        subjectMapping.forEach((key, subjectName) {
          // Get the required level for this subject from the university
          final requiredLevel = university[key];

          // If the university has a requirement for this subject
          if (requiredLevel != null) {
            bool subjectFound = false;

            // Check if any of the user's selected subjects match this university subject
            for (int i = 1; i <= 4; i++) {
              final userSubject = userMarks['subject$i'];
              final userLevel = userMarks['subject${i}_level'];

              // If the user's subject matches the university-required subject
              if (userSubject == subjectName) {
                subjectFound = true;

                // If the user's subject level is less than the required level, they don't qualify
                if ((userLevel ?? 0) < requiredLevel) {
                  meetsRequirements = false;
                  break;
                }
              }
            }

            // If the required subject wasn't found in the user's selected subjects
            if (!subjectFound) {
              meetsRequirements = false;
            }
          }
        });

        // If requirements are met, add to the list
        if (meetsRequirements) {
          final faculty = university['faculty'] ?? 'Unknown Faculty';
          if (!groupedCourses.containsKey(faculty)) {
            groupedCourses[faculty] = [];
          }
          groupedCourses[faculty]!.add(university);
        }
      }

      setState(() {
        facultyCourses = groupedCourses;
        visibleCoursesPerFaculty = {
          for (var faculty in groupedCourses.keys) faculty: 5
        };
        isLoading = false;
      });

      // Print the number of faculties and courses returned
      uctFaculties = facultyCourses.keys.length;
      uctCourses = facultyCourses.values.expand((list) => list).length;
    } catch (error) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchAvailableCourses_ufs() async {
    try {
      final userMarksResponse = await _supabaseClient
          .from('user_marks')
          .select(
              'math_mark, math_level, math_type, home_language_mark, home_language_level, first_additional_language_mark, first_additional_language_level, second_additional_language_mark, second_additional_language_level, subject1, subject1_level, subject2, subject2_level, subject3, subject3_level, subject4, subject4_level, life_orientation_mark, life_orientation_level, home_language, first_additional_language, second_additional_language')
          .eq('user_id', _supabaseClient.auth.currentUser!.id)
          .single();

      final userMarks = userMarksResponse;

      // Fetch courses from the specific university
      final response = await _supabaseClient
          .from('universities')
          .select(
              'university_name, qualification, aps, faculty, english_hl, english_fal, maths, technical_math, maths_lit, physical_sciences, life_orientation, accounting, business_studies, economics, history, geography, tourism, civil_technology, egd, cat, it, electrical_technology, mechanical_technology')
          .eq('university_name',
              'University of The Free State'); // Filter by university name

      final Map<String, List<Map<String, dynamic>>> groupedCourses = {};

      // Mapping user subjects to university columns
      final subjectMapping = {
        'Physical Sciences': 'physical_sciences',
        'Accounting': 'accounting',
        'Business Studies': 'business_studies',
        'Economics': 'economics',
        'History': 'history',
        'Geography': 'geography',
        'Tourism': 'tourism',
        'Civil Technology': 'civil_technology',
        'Engineering Graphics and Design': 'egd',
        'Computer Applications Technology': 'cat',
        'Information Technology': 'it',
        'Electrical Technology': 'electrical_technology',
        'Mechanical Technology': 'mechanical_technology',
      };

      for (var university in response) {
        bool meetsRequirements = true;

        // Skip APS comparison if APS is null in the universities table
        if (university['aps'] != null) {
          if (apsUfs! < university['aps']) {
            meetsRequirements = false;
            continue; // Skip this course if APS does not meet the requirement
          }
        }

        // Compare based on math_type
        if (userMarks['math_type'] == 'Mathematics') {
          if ((userMarks['math_level'] ?? 0) < (university['maths'] ?? 0)) {
            meetsRequirements = false;
          }
        } else if (userMarks['math_type'] == 'Mathematical Literacy') {
          if ((userMarks['math_level'] ?? 0) < (university['maths_lit'] ?? 0)) {
            meetsRequirements = false;
          }
        } else if (userMarks['math_type'] == 'Technical Mathematics') {
          if ((userMarks['math_level'] ?? 0) <
              (university['technical_math'] ?? 0)) {
            meetsRequirements = false;
          }
        }

        // Check English requirements
        bool hasEnglishHL = userMarks['home_language']
                ?.toString()
                .toLowerCase()
                .contains('english') ??
            false;
        bool hasEnglishFAL = userMarks['first_additional_language']
                ?.toString()
                .toLowerCase()
                .contains('english') ??
            false;

        if (hasEnglishHL) {
          if ((userMarks['home_language_level'] ?? 0) <
              (university['english_hl'] ?? 0)) {
            meetsRequirements = false;
          }
        } else if (hasEnglishFAL) {
          if ((userMarks['first_additional_language_level'] ?? 0) <
              (university['english_fal'] ?? 0)) {
            meetsRequirements = false;
          }
        } else {
          meetsRequirements = false;
        }

        // Iterate over the subjects required by the university
        subjectMapping.forEach((key, subjectName) {
          // Get the required level for this subject from the university
          final requiredLevel = university[key];

          // If the university has a requirement for this subject
          if (requiredLevel != null) {
            bool subjectFound = false;

            // Check if any of the user's selected subjects match this university subject
            for (int i = 1; i <= 4; i++) {
              final userSubject = userMarks['subject$i'];
              final userLevel = userMarks['subject${i}_level'];

              // If the user's subject matches the university-required subject
              if (userSubject == subjectName) {
                subjectFound = true;

                // If the user's subject level is less than the required level, they don't qualify
                if ((userLevel ?? 0) < requiredLevel) {
                  meetsRequirements = false;
                  break;
                }
              }
            }

            // If the required subject wasn't found in the user's selected subjects
            if (!subjectFound) {
              meetsRequirements = false;
            }
          }
        });

        // If requirements are met, add to the list
        if (meetsRequirements) {
          final faculty = university['faculty'] ?? 'Unknown Faculty';
          if (!groupedCourses.containsKey(faculty)) {
            groupedCourses[faculty] = [];
          }
          groupedCourses[faculty]!.add(university);
        }
      }

      setState(() {
        facultyCourses = groupedCourses;
        visibleCoursesPerFaculty = {
          for (var faculty in groupedCourses.keys) faculty: 5
        };
        isLoading = false;
      });

      // Print the number of faculties and courses returned
      ufsFaculties = facultyCourses.keys.length;
      ufsCourses = facultyCourses.values.expand((list) => list).length;
    } catch (error) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchAvailableCourses_cut() async {
    try {
      final userMarksResponse = await _supabaseClient
          .from('user_marks')
          .select(
              'math_mark, math_level, math_type, home_language_mark, home_language_level, first_additional_language_mark, first_additional_language_level, second_additional_language_mark, second_additional_language_level, subject1, subject1_level, subject2, subject2_level, subject3, subject3_level, subject4, subject4_level, life_orientation_mark, life_orientation_level, home_language, first_additional_language, second_additional_language')
          .eq('user_id', _supabaseClient.auth.currentUser!.id)
          .single();

      final userMarks = userMarksResponse;

      // Fetch courses from the specific university
      final response = await _supabaseClient
          .from('universities')
          .select(
              'university_name, qualification, aps, faculty, english_hl, english_fal, maths, technical_math, maths_lit, physical_sciences, life_orientation, accounting, business_studies, economics, history, geography, tourism, civil_technology, egd, cat, it, electrical_technology, mechanical_technology')
          .eq('university_name',
              'Central University of Technology'); // Filter by university name

      final Map<String, List<Map<String, dynamic>>> groupedCourses = {};

      // Mapping user subjects to university columns
      final subjectMapping = {
        'Physical Sciences': 'physical_sciences',
        'Accounting': 'accounting',
        'Business Studies': 'business_studies',
        'Economics': 'economics',
        'History': 'history',
        'Geography': 'geography',
        'Tourism': 'tourism',
        'Civil Technology': 'civil_technology',
        'Engineering Graphics and Design': 'egd',
        'Computer Applications Technology': 'cat',
        'Information Technology': 'it',
        'Electrical Technology': 'electrical_technology',
        'Mechanical Technology': 'mechanical_technology',
      };

      for (var university in response) {
        bool meetsRequirements = true;

        // Skip APS comparison if APS is null in the universities table
        if (university['aps'] != null) {
          if (apsCut! < university['aps']) {
            meetsRequirements = false;
            continue; // Skip this course if APS does not meet the requirement
          }
        }

        // Compare based on math_type
        if (userMarks['math_type'] == 'Mathematics') {
          if ((userMarks['math_level'] ?? 0) < (university['maths'] ?? 0)) {
            meetsRequirements = false;
          }
        } else if (userMarks['math_type'] == 'Mathematical Literacy') {
          if ((userMarks['math_level'] ?? 0) < (university['maths_lit'] ?? 0)) {
            meetsRequirements = false;
          }
        } else if (userMarks['math_type'] == 'Technical Mathematics') {
          if ((userMarks['math_level'] ?? 0) <
              (university['technical_math'] ?? 0)) {
            meetsRequirements = false;
          }
        }

        // Check English requirements
        bool hasEnglishHL = userMarks['home_language']
                ?.toString()
                .toLowerCase()
                .contains('english') ??
            false;
        bool hasEnglishFAL = userMarks['first_additional_language']
                ?.toString()
                .toLowerCase()
                .contains('english') ??
            false;

        if (hasEnglishHL) {
          if ((userMarks['home_language_level'] ?? 0) <
              (university['english_hl'] ?? 0)) {
            meetsRequirements = false;
          }
        } else if (hasEnglishFAL) {
          if ((userMarks['first_additional_language_level'] ?? 0) <
              (university['english_fal'] ?? 0)) {
            meetsRequirements = false;
          }
        } else {
          meetsRequirements = false;
        }

        // Iterate over the subjects required by the university
        subjectMapping.forEach((key, subjectName) {
          // Get the required level for this subject from the university
          final requiredLevel = university[key];

          // If the university has a requirement for this subject
          if (requiredLevel != null) {
            bool subjectFound = false;

            // Check if any of the user's selected subjects match this university subject
            for (int i = 1; i <= 4; i++) {
              final userSubject = userMarks['subject$i'];
              final userLevel = userMarks['subject${i}_level'];

              // If the user's subject matches the university-required subject
              if (userSubject == subjectName) {
                subjectFound = true;

                // If the user's subject level is less than the required level, they don't qualify
                if ((userLevel ?? 0) < requiredLevel) {
                  meetsRequirements = false;
                  break;
                }
              }
            }

            // If the required subject wasn't found in the user's selected subjects
            if (!subjectFound) {
              meetsRequirements = false;
            }
          }
        });

        // If requirements are met, add to the list
        if (meetsRequirements) {
          final faculty = university['faculty'] ?? 'Unknown Faculty';
          if (!groupedCourses.containsKey(faculty)) {
            groupedCourses[faculty] = [];
          }
          groupedCourses[faculty]!.add(university);
        }
      }

      setState(() {
        facultyCourses = groupedCourses;
        visibleCoursesPerFaculty = {
          for (var faculty in groupedCourses.keys) faculty: 5
        };
        isLoading = false;
      });

      // Print the number of faculties and courses returned
      cutFaculties = facultyCourses.keys.length;
      cutCourses = facultyCourses.values.expand((list) => list).length;
    } catch (error) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchAvailableCourses_rhodes() async {
    try {
      final userMarksResponse = await _supabaseClient
          .from('user_marks')
          .select(
              'math_mark, math_level, math_type, home_language_mark, home_language_level, first_additional_language_mark, first_additional_language_level, second_additional_language_mark, second_additional_language_level, subject1, subject1_level, subject2, subject2_level, subject3, subject3_level, subject4, subject4_level, life_orientation_mark, life_orientation_level, home_language, first_additional_language, second_additional_language')
          .eq('user_id', _supabaseClient.auth.currentUser!.id)
          .single();

      final userMarks = userMarksResponse;

      // Fetch courses from the specific university
      final response = await _supabaseClient
          .from('universities')
          .select(
              'university_name, qualification, aps, faculty, english_hl, english_fal, maths, technical_math, maths_lit, physical_sciences, life_orientation, accounting, business_studies, economics, history, geography, tourism, civil_technology, egd, cat, it, electrical_technology, mechanical_technology')
          .eq('university_name',
              'Rhodes University'); // Filter by university name

      final Map<String, List<Map<String, dynamic>>> groupedCourses = {};

      // Mapping user subjects to university columns
      final subjectMapping = {
        'Physical Sciences': 'physical_sciences',
        'Accounting': 'accounting',
        'Business Studies': 'business_studies',
        'Economics': 'economics',
        'History': 'history',
        'Geography': 'geography',
        'Tourism': 'tourism',
        'Civil Technology': 'civil_technology',
        'Engineering Graphics and Design': 'egd',
        'Computer Applications Technology': 'cat',
        'Information Technology': 'it',
        'Electrical Technology': 'electrical_technology',
        'Mechanical Technology': 'mechanical_technology',
      };

      for (var university in response) {
        bool meetsRequirements = true;

        // Skip APS comparison if APS is null in the universities table
        if (university['aps'] != null) {
          if (apsCput! < university['aps']) {
            meetsRequirements = false;
            continue; // Skip this course if APS does not meet the requirement
          }
        }

        // Compare based on math_type
        if (userMarks['math_type'] == 'Mathematics') {
          if ((userMarks['math_level'] ?? 0) < (university['maths'] ?? 0)) {
            meetsRequirements = false;
          }
        } else if (userMarks['math_type'] == 'Mathematical Literacy') {
          if ((userMarks['math_level'] ?? 0) < (university['maths_lit'] ?? 0)) {
            meetsRequirements = false;
          }
        } else if (userMarks['math_type'] == 'Technical Mathematics') {
          if ((userMarks['math_level'] ?? 0) <
              (university['technical_math'] ?? 0)) {
            meetsRequirements = false;
          }
        }

        // Check English requirements
        bool hasEnglishHL = userMarks['home_language']
                ?.toString()
                .toLowerCase()
                .contains('english') ??
            false;
        bool hasEnglishFAL = userMarks['first_additional_language']
                ?.toString()
                .toLowerCase()
                .contains('english') ??
            false;

        if (hasEnglishHL) {
          if ((userMarks['home_language_level'] ?? 0) <
              (university['english_hl'] ?? 0)) {
            meetsRequirements = false;
          }
        } else if (hasEnglishFAL) {
          if ((userMarks['first_additional_language_level'] ?? 0) <
              (university['english_fal'] ?? 0)) {
            meetsRequirements = false;
          }
        } else {
          meetsRequirements = false;
        }

        // Iterate over the subjects required by the university
        subjectMapping.forEach((key, subjectName) {
          // Get the required level for this subject from the university
          final requiredLevel = university[key];

          // If the university has a requirement for this subject
          if (requiredLevel != null) {
            bool subjectFound = false;

            // Check if any of the user's selected subjects match this university subject
            for (int i = 1; i <= 4; i++) {
              final userSubject = userMarks['subject$i'];
              final userLevel = userMarks['subject${i}_level'];

              // If the user's subject matches the university-required subject
              if (userSubject == subjectName) {
                subjectFound = true;

                // If the user's subject level is less than the required level, they don't qualify
                if ((userLevel ?? 0) < requiredLevel) {
                  meetsRequirements = false;
                  break;
                }
              }
            }

            // If the required subject wasn't found in the user's selected subjects
            if (!subjectFound) {
              meetsRequirements = false;
            }
          }
        });

        // If requirements are met, add to the list
        if (meetsRequirements) {
          final faculty = university['faculty'] ?? 'Unknown Faculty';
          if (!groupedCourses.containsKey(faculty)) {
            groupedCourses[faculty] = [];
          }
          groupedCourses[faculty]!.add(university);
        }
      }

      setState(() {
        facultyCourses = groupedCourses;
        visibleCoursesPerFaculty = {
          for (var faculty in groupedCourses.keys) faculty: 5
        };
        isLoading = false;
      });

      // Print the number of faculties and courses returned
      rhodesFaculties = facultyCourses.keys.length;
      rhodesCourses = facultyCourses.values.expand((list) => list).length;
    } catch (error) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchAvailableCourses_wsu() async {
    try {
      final userMarksResponse = await _supabaseClient
          .from('user_marks')
          .select(
              'math_mark, math_level, math_type, home_language_mark, home_language_level, first_additional_language_mark, first_additional_language_level, second_additional_language_mark, second_additional_language_level, subject1, subject1_level, subject2, subject2_level, subject3, subject3_level, subject4, subject4_level, life_orientation_mark, life_orientation_level, home_language, first_additional_language, second_additional_language')
          .eq('user_id', _supabaseClient.auth.currentUser!.id)
          .single();

      final userMarks = userMarksResponse;

      // Fetch courses from the specific university
      final response = await _supabaseClient
          .from('universities')
          .select(
              'university_name, qualification, aps, faculty, english_hl, english_fal, maths, technical_math, maths_lit, physical_sciences, life_orientation, accounting, business_studies, economics, history, geography, tourism, civil_technology, egd, cat, it, electrical_technology, mechanical_technology')
          .eq('university_name',
              'Walter Sisulu University'); // Filter by university name

      final Map<String, List<Map<String, dynamic>>> groupedCourses = {};

      // Mapping user subjects to university columns
      final subjectMapping = {
        'Physical Sciences': 'physical_sciences',
        'Accounting': 'accounting',
        'Business Studies': 'business_studies',
        'Economics': 'economics',
        'History': 'history',
        'Geography': 'geography',
        'Tourism': 'tourism',
        'Civil Technology': 'civil_technology',
        'Engineering Graphics and Design': 'egd',
        'Computer Applications Technology': 'cat',
        'Information Technology': 'it',
        'Electrical Technology': 'electrical_technology',
        'Mechanical Technology': 'mechanical_technology',
      };

      for (var university in response) {
        bool meetsRequirements = true;

        // Skip APS comparison if APS is null in the universities table
        if (university['aps'] != null) {
          if (apsWsu! < university['aps']) {
            meetsRequirements = false;
            continue; // Skip this course if APS does not meet the requirement
          }
        }

        // Compare based on math_type
        if (userMarks['math_type'] == 'Mathematics') {
          if ((userMarks['math_level'] ?? 0) < (university['maths'] ?? 0)) {
            meetsRequirements = false;
          }
        } else if (userMarks['math_type'] == 'Mathematical Literacy') {
          if ((userMarks['math_level'] ?? 0) < (university['maths_lit'] ?? 0)) {
            meetsRequirements = false;
          }
        } else if (userMarks['math_type'] == 'Technical Mathematics') {
          if ((userMarks['math_level'] ?? 0) <
              (university['technical_math'] ?? 0)) {
            meetsRequirements = false;
          }
        }

        // Check English requirements
        bool hasEnglishHL = userMarks['home_language']
                ?.toString()
                .toLowerCase()
                .contains('english') ??
            false;
        bool hasEnglishFAL = userMarks['first_additional_language']
                ?.toString()
                .toLowerCase()
                .contains('english') ??
            false;

        if (hasEnglishHL) {
          if ((userMarks['home_language_level'] ?? 0) <
              (university['english_hl'] ?? 0)) {
            meetsRequirements = false;
          }
        } else if (hasEnglishFAL) {
          if ((userMarks['first_additional_language_level'] ?? 0) <
              (university['english_fal'] ?? 0)) {
            meetsRequirements = false;
          }
        } else {
          meetsRequirements = false;
        }

        // Iterate over the subjects required by the university
        subjectMapping.forEach((key, subjectName) {
          // Get the required level for this subject from the university
          final requiredLevel = university[key];

          // If the university has a requirement for this subject
          if (requiredLevel != null) {
            bool subjectFound = false;

            // Check if any of the user's selected subjects match this university subject
            for (int i = 1; i <= 4; i++) {
              final userSubject = userMarks['subject$i'];
              final userLevel = userMarks['subject${i}_level'];

              // If the user's subject matches the university-required subject
              if (userSubject == subjectName) {
                subjectFound = true;

                // If the user's subject level is less than the required level, they don't qualify
                if ((userLevel ?? 0) < requiredLevel) {
                  meetsRequirements = false;
                  break;
                }
              }
            }

            // If the required subject wasn't found in the user's selected subjects
            if (!subjectFound) {
              meetsRequirements = false;
            }
          }
        });

        // If requirements are met, add to the list
        if (meetsRequirements) {
          final faculty = university['faculty'] ?? 'Unknown Faculty';
          if (!groupedCourses.containsKey(faculty)) {
            groupedCourses[faculty] = [];
          }
          groupedCourses[faculty]!.add(university);
        }
      }

      setState(() {
        facultyCourses = groupedCourses;
        visibleCoursesPerFaculty = {
          for (var faculty in groupedCourses.keys) faculty: 5
        };
        isLoading = false;
      });

      // Print the number of faculties and courses returned
      wsuFaculties = facultyCourses.keys.length;
      wsuCourses = facultyCourses.values.expand((list) => list).length;
    } catch (error) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchAvailableCourses_smu() async {
    try {
      final userMarksResponse = await _supabaseClient
          .from('user_marks')
          .select(
              'math_mark, math_level, math_type, home_language_mark, home_language_level, first_additional_language_mark, first_additional_language_level, second_additional_language_mark, second_additional_language_level, subject1, subject1_level, subject2, subject2_level, subject3, subject3_level, subject4, subject4_level, life_orientation_mark, life_orientation_level, home_language, first_additional_language, second_additional_language')
          .eq('user_id', _supabaseClient.auth.currentUser!.id)
          .single();

      final userMarks = userMarksResponse;

      // Fetch courses from the specific university
      final response = await _supabaseClient
          .from('universities')
          .select(
              'university_name, qualification, aps, faculty, english_hl, english_fal, maths, technical_math, maths_lit, physical_sciences, life_orientation, accounting, business_studies, economics, history, geography, tourism, civil_technology, egd, cat, it, electrical_technology, mechanical_technology')
          .eq('university_name',
              'Sefako Makgatho University'); // Filter by university name

      final Map<String, List<Map<String, dynamic>>> groupedCourses = {};

      // Mapping user subjects to university columns
      final subjectMapping = {
        'Physical Sciences': 'physical_sciences',
        'Accounting': 'accounting',
        'Business Studies': 'business_studies',
        'Economics': 'economics',
        'History': 'history',
        'Geography': 'geography',
        'Tourism': 'tourism',
        'Civil Technology': 'civil_technology',
        'Engineering Graphics and Design': 'egd',
        'Computer Applications Technology': 'cat',
        'Information Technology': 'it',
        'Electrical Technology': 'electrical_technology',
        'Mechanical Technology': 'mechanical_technology',
      };

      for (var university in response) {
        bool meetsRequirements = true;

        // Skip APS comparison if APS is null in the universities table
        if (university['aps'] != null) {
          if (apsSmu! < university['aps']) {
            meetsRequirements = false;
            continue; // Skip this course if APS does not meet the requirement
          }
        }

        // Compare based on math_type
        if (userMarks['math_type'] == 'Mathematics') {
          if ((userMarks['math_level'] ?? 0) < (university['maths'] ?? 0)) {
            meetsRequirements = false;
          }
        } else if (userMarks['math_type'] == 'Mathematical Literacy') {
          if ((userMarks['math_level'] ?? 0) < (university['maths_lit'] ?? 0)) {
            meetsRequirements = false;
          }
        } else if (userMarks['math_type'] == 'Technical Mathematics') {
          if ((userMarks['math_level'] ?? 0) <
              (university['technical_math'] ?? 0)) {
            meetsRequirements = false;
          }
        }

        // Check English requirements
        bool hasEnglishHL = userMarks['home_language']
                ?.toString()
                .toLowerCase()
                .contains('english') ??
            false;
        bool hasEnglishFAL = userMarks['first_additional_language']
                ?.toString()
                .toLowerCase()
                .contains('english') ??
            false;

        if (hasEnglishHL) {
          if ((userMarks['home_language_level'] ?? 0) <
              (university['english_hl'] ?? 0)) {
            meetsRequirements = false;
          }
        } else if (hasEnglishFAL) {
          if ((userMarks['first_additional_language_level'] ?? 0) <
              (university['english_fal'] ?? 0)) {
            meetsRequirements = false;
          }
        } else {
          meetsRequirements = false;
        }

        // Iterate over the subjects required by the university
        subjectMapping.forEach((key, subjectName) {
          // Get the required level for this subject from the university
          final requiredLevel = university[key];

          // If the university has a requirement for this subject
          if (requiredLevel != null) {
            bool subjectFound = false;

            // Check if any of the user's selected subjects match this university subject
            for (int i = 1; i <= 4; i++) {
              final userSubject = userMarks['subject$i'];
              final userLevel = userMarks['subject${i}_level'];

              // If the user's subject matches the university-required subject
              if (userSubject == subjectName) {
                subjectFound = true;

                // If the user's subject level is less than the required level, they don't qualify
                if ((userLevel ?? 0) < requiredLevel) {
                  meetsRequirements = false;
                  break;
                }
              }
            }

            // If the required subject wasn't found in the user's selected subjects
            if (!subjectFound) {
              meetsRequirements = false;
            }
          }
        });

        // If requirements are met, add to the list
        if (meetsRequirements) {
          final faculty = university['faculty'] ?? 'Unknown Faculty';
          if (!groupedCourses.containsKey(faculty)) {
            groupedCourses[faculty] = [];
          }
          groupedCourses[faculty]!.add(university);
        }
      }

      setState(() {
        facultyCourses = groupedCourses;
        visibleCoursesPerFaculty = {
          for (var faculty in groupedCourses.keys) faculty: 5
        };
        isLoading = false;
      });

      // Print the number of faculties and courses returned
      smuFaculties = facultyCourses.keys.length;
      smuCourses = facultyCourses.values.expand((list) => list).length;
    } catch (error) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchAvailableCourses_stllies() async {
    try {
      final userMarksResponse = await _supabaseClient
          .from('user_marks')
          .select(
              'math_mark, math_level, math_type, home_language_mark, home_language_level, first_additional_language_mark, first_additional_language_level, second_additional_language_mark, second_additional_language_level, subject1, subject1_level, subject2, subject2_level, subject3, subject3_level, subject4, subject4_level, life_orientation_mark, life_orientation_level, home_language, first_additional_language, second_additional_language')
          .eq('user_id', _supabaseClient.auth.currentUser!.id)
          .single();

      final userMarks = userMarksResponse;

      // Fetch courses from the specific university
      final response = await _supabaseClient
          .from('universities')
          .select(
              'university_name, qualification, aps, faculty, english_hl, english_fal, maths, technical_math, maths_lit, physical_sciences, life_orientation, accounting, business_studies, economics, history, geography, tourism, civil_technology, egd, cat, it, electrical_technology, mechanical_technology')
          .eq('university_name',
              'Stellenbosch University'); // Filter by university name

      final Map<String, List<Map<String, dynamic>>> groupedCourses = {};

      // Mapping user subjects to university columns
      final subjectMapping = {
        'Physical Sciences': 'physical_sciences',
        'Accounting': 'accounting',
        'Business Studies': 'business_studies',
        'Economics': 'economics',
        'History': 'history',
        'Geography': 'geography',
        'Tourism': 'tourism',
        'Civil Technology': 'civil_technology',
        'Engineering Graphics and Design': 'egd',
        'Computer Applications Technology': 'cat',
        'Information Technology': 'it',
        'Electrical Technology': 'electrical_technology',
        'Mechanical Technology': 'mechanical_technology',
      };

      for (var university in response) {
        bool meetsRequirements = true;

        // Skip APS comparison if APS is null in the universities table
        if (university['aps'] != null) {
          if (apsCput! < university['aps']) {
            meetsRequirements = false;
            continue; // Skip this course if APS does not meet the requirement
          }
        }

        // Compare based on math_type
        if (userMarks['math_type'] == 'Mathematics') {
          if ((userMarks['math_level'] ?? 0) < (university['maths'] ?? 0)) {
            meetsRequirements = false;
          }
        } else if (userMarks['math_type'] == 'Mathematical Literacy') {
          if ((userMarks['math_level'] ?? 0) < (university['maths_lit'] ?? 0)) {
            meetsRequirements = false;
          }
        } else if (userMarks['math_type'] == 'Technical Mathematics') {
          if ((userMarks['math_level'] ?? 0) <
              (university['technical_math'] ?? 0)) {
            meetsRequirements = false;
          }
        }

        // Check English requirements
        bool hasEnglishHL = userMarks['home_language']
                ?.toString()
                .toLowerCase()
                .contains('english') ??
            false;
        bool hasEnglishFAL = userMarks['first_additional_language']
                ?.toString()
                .toLowerCase()
                .contains('english') ??
            false;

        if (hasEnglishHL) {
          if ((userMarks['home_language_level'] ?? 0) <
              (university['english_hl'] ?? 0)) {
            meetsRequirements = false;
          }
        } else if (hasEnglishFAL) {
          if ((userMarks['first_additional_language_level'] ?? 0) <
              (university['english_fal'] ?? 0)) {
            meetsRequirements = false;
          }
        } else {
          meetsRequirements = false;
        }

        // Iterate over the subjects required by the university
        subjectMapping.forEach((key, subjectName) {
          // Get the required level for this subject from the university
          final requiredLevel = university[key];

          // If the university has a requirement for this subject
          if (requiredLevel != null) {
            bool subjectFound = false;

            // Check if any of the user's selected subjects match this university subject
            for (int i = 1; i <= 4; i++) {
              final userSubject = userMarks['subject$i'];
              final userLevel = userMarks['subject${i}_level'];

              // If the user's subject matches the university-required subject
              if (userSubject == subjectName) {
                subjectFound = true;

                // If the user's subject level is less than the required level, they don't qualify
                if ((userLevel ?? 0) < requiredLevel) {
                  meetsRequirements = false;
                  break;
                }
              }
            }

            // If the required subject wasn't found in the user's selected subjects
            if (!subjectFound) {
              meetsRequirements = false;
            }
          }
        });

        // If requirements are met, add to the list
        if (meetsRequirements) {
          final faculty = university['faculty'] ?? 'Unknown Faculty';
          if (!groupedCourses.containsKey(faculty)) {
            groupedCourses[faculty] = [];
          }
          groupedCourses[faculty]!.add(university);
        }
      }

      setState(() {
        facultyCourses = groupedCourses;
        visibleCoursesPerFaculty = {
          for (var faculty in groupedCourses.keys) faculty: 5
        };
        isLoading = false;
      });

      // Print the number of faculties and courses returned
      stelliesFaculties = facultyCourses.keys.length;
      stelliesCourses = facultyCourses.values.expand((list) => list).length;
    } catch (error) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchAvailableCourses_tut() async {
    try {
      final userMarksResponse = await _supabaseClient
          .from('user_marks')
          .select(
              'math_mark, math_level, math_type, home_language_mark, home_language_level, first_additional_language_mark, first_additional_language_level, second_additional_language_mark, second_additional_language_level, subject1, subject1_level, subject2, subject2_level, subject3, subject3_level, subject4, subject4_level, life_orientation_mark, life_orientation_level, home_language, first_additional_language, second_additional_language')
          .eq('user_id', _supabaseClient.auth.currentUser!.id)
          .single();

      final userMarks = userMarksResponse;

      // Fetch courses from the specific university
      final response = await _supabaseClient
          .from('universities')
          .select(
              'university_name, qualification, aps, faculty, english_hl, english_fal, maths, technical_math, maths_lit, physical_sciences, life_orientation, accounting, business_studies, economics, history, geography, tourism, civil_technology, egd, cat, it, electrical_technology, mechanical_technology')
          .eq('university_name',
              'Cape Peninsula University of Technology'); // Filter by university name

      final Map<String, List<Map<String, dynamic>>> groupedCourses = {};

      // Mapping user subjects to university columns
      final subjectMapping = {
        'Physical Sciences': 'physical_sciences',
        'Accounting': 'accounting',
        'Business Studies': 'business_studies',
        'Economics': 'economics',
        'History': 'history',
        'Geography': 'geography',
        'Tourism': 'tourism',
        'Civil Technology': 'civil_technology',
        'Engineering Graphics and Design': 'egd',
        'Computer Applications Technology': 'cat',
        'Information Technology': 'it',
        'Electrical Technology': 'electrical_technology',
        'Mechanical Technology': 'mechanical_technology',
      };

      for (var university in response) {
        bool meetsRequirements = true;

        // Skip APS comparison if APS is null in the universities table
        if (university['aps'] != null) {
          if (apsUj! < university['aps']) {
            meetsRequirements = false;
            continue; // Skip this course if APS does not meet the requirement
          }
        }

        // Compare based on math_type
        if (userMarks['math_type'] == 'Mathematics') {
          if ((userMarks['math_level'] ?? 0) < (university['maths'] ?? 0)) {
            meetsRequirements = false;
          }
        } else if (userMarks['math_type'] == 'Mathematical Literacy') {
          if ((userMarks['math_level'] ?? 0) < (university['maths_lit'] ?? 0)) {
            meetsRequirements = false;
          }
        } else if (userMarks['math_type'] == 'Technical Mathematics') {
          if ((userMarks['math_level'] ?? 0) <
              (university['technical_math'] ?? 0)) {
            meetsRequirements = false;
          }
        }

        // Check English requirements
        bool hasEnglishHL = userMarks['home_language']
                ?.toString()
                .toLowerCase()
                .contains('english') ??
            false;
        bool hasEnglishFAL = userMarks['first_additional_language']
                ?.toString()
                .toLowerCase()
                .contains('english') ??
            false;

        if (hasEnglishHL) {
          if ((userMarks['home_language_level'] ?? 0) <
              (university['english_hl'] ?? 0)) {
            meetsRequirements = false;
          }
        } else if (hasEnglishFAL) {
          if ((userMarks['first_additional_language_level'] ?? 0) <
              (university['english_fal'] ?? 0)) {
            meetsRequirements = false;
          }
        } else {
          meetsRequirements = false;
        }

        // Iterate over the subjects required by the university
        subjectMapping.forEach((key, subjectName) {
          // Get the required level for this subject from the university
          final requiredLevel = university[key];

          // If the university has a requirement for this subject
          if (requiredLevel != null) {
            bool subjectFound = false;

            // Check if any of the user's selected subjects match this university subject
            for (int i = 1; i <= 4; i++) {
              final userSubject = userMarks['subject$i'];
              final userLevel = userMarks['subject${i}_level'];

              // If the user's subject matches the university-required subject
              if (userSubject == subjectName) {
                subjectFound = true;

                // If the user's subject level is less than the required level, they don't qualify
                if ((userLevel ?? 0) < requiredLevel) {
                  meetsRequirements = false;
                  break;
                }
              }
            }

            // If the required subject wasn't found in the user's selected subjects
            if (!subjectFound) {
              meetsRequirements = false;
            }
          }
        });

        // If requirements are met, add to the list
        if (meetsRequirements) {
          final faculty = university['faculty'] ?? 'Unknown Faculty';
          if (!groupedCourses.containsKey(faculty)) {
            groupedCourses[faculty] = [];
          }
          groupedCourses[faculty]!.add(university);
        }
      }

      setState(() {
        facultyCourses = groupedCourses;
        visibleCoursesPerFaculty = {
          for (var faculty in groupedCourses.keys) faculty: 5
        };
        isLoading = false;
      });

      // Print the number of faculties and courses returned
      tutFaculties = facultyCourses.keys.length;
      tutCourses = facultyCourses.values.expand((list) => list).length;
    } catch (error) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchAvailableCourses_uwc() async {
    try {
      final userMarksResponse = await _supabaseClient
          .from('user_marks')
          .select(
              'math_mark, math_level, math_type, home_language_mark, home_language_level, first_additional_language_mark, first_additional_language_level, second_additional_language_mark, second_additional_language_level, subject1, subject1_level, subject2, subject2_level, subject3, subject3_level, subject4, subject4_level, life_orientation_mark, life_orientation_level, home_language, first_additional_language, second_additional_language')
          .eq('user_id', _supabaseClient.auth.currentUser!.id)
          .single();

      final userMarks = userMarksResponse;

      // Fetch courses from the specific university
      final response = await _supabaseClient
          .from('universities')
          .select(
              'university_name, qualification, aps, faculty, english_hl, english_fal, maths, technical_math, maths_lit, physical_sciences, life_orientation, accounting, business_studies, economics, history, geography, tourism, civil_technology, egd, cat, it, electrical_technology, mechanical_technology')
          .eq('university_name',
              'University of the Western Cape'); // Filter by university name

      final Map<String, List<Map<String, dynamic>>> groupedCourses = {};

      // Mapping user subjects to university columns
      final subjectMapping = {
        'Physical Sciences': 'physical_sciences',
        'Accounting': 'accounting',
        'Business Studies': 'business_studies',
        'Economics': 'economics',
        'History': 'history',
        'Geography': 'geography',
        'Tourism': 'tourism',
        'Civil Technology': 'civil_technology',
        'Engineering Graphics and Design': 'egd',
        'Computer Applications Technology': 'cat',
        'Information Technology': 'it',
        'Electrical Technology': 'electrical_technology',
        'Mechanical Technology': 'mechanical_technology',
      };

      for (var university in response) {
        bool meetsRequirements = true;

        // Skip APS comparison if APS is null in the universities table
        if (university['aps'] != null) {
          if (apsUwc! < university['aps']) {
            meetsRequirements = false;
            continue; // Skip this course if APS does not meet the requirement
          }
        }

        // Compare based on math_type
        if (userMarks['math_type'] == 'Mathematics') {
          if ((userMarks['math_level'] ?? 0) < (university['maths'] ?? 0)) {
            meetsRequirements = false;
          }
        } else if (userMarks['math_type'] == 'Mathematical Literacy') {
          if ((userMarks['math_level'] ?? 0) < (university['maths_lit'] ?? 0)) {
            meetsRequirements = false;
          }
        } else if (userMarks['math_type'] == 'Technical Mathematics') {
          if ((userMarks['math_level'] ?? 0) <
              (university['technical_math'] ?? 0)) {
            meetsRequirements = false;
          }
        }

        // Check English requirements
        bool hasEnglishHL = userMarks['home_language']
                ?.toString()
                .toLowerCase()
                .contains('english') ??
            false;
        bool hasEnglishFAL = userMarks['first_additional_language']
                ?.toString()
                .toLowerCase()
                .contains('english') ??
            false;

        if (hasEnglishHL) {
          if ((userMarks['home_language_level'] ?? 0) <
              (university['english_hl'] ?? 0)) {
            meetsRequirements = false;
          }
        } else if (hasEnglishFAL) {
          if ((userMarks['first_additional_language_level'] ?? 0) <
              (university['english_fal'] ?? 0)) {
            meetsRequirements = false;
          }
        } else {
          meetsRequirements = false;
        }

        // Iterate over the subjects required by the university
        subjectMapping.forEach((key, subjectName) {
          // Get the required level for this subject from the university
          final requiredLevel = university[key];

          // If the university has a requirement for this subject
          if (requiredLevel != null) {
            bool subjectFound = false;

            // Check if any of the user's selected subjects match this university subject
            for (int i = 1; i <= 4; i++) {
              final userSubject = userMarks['subject$i'];
              final userLevel = userMarks['subject${i}_level'];

              // If the user's subject matches the university-required subject
              if (userSubject == subjectName) {
                subjectFound = true;

                // If the user's subject level is less than the required level, they don't qualify
                if ((userLevel ?? 0) < requiredLevel) {
                  meetsRequirements = false;
                  break;
                }
              }
            }

            // If the required subject wasn't found in the user's selected subjects
            if (!subjectFound) {
              meetsRequirements = false;
            }
          }
        });

        // If requirements are met, add to the list
        if (meetsRequirements) {
          final faculty = university['faculty'] ?? 'Unknown Faculty';
          if (!groupedCourses.containsKey(faculty)) {
            groupedCourses[faculty] = [];
          }
          groupedCourses[faculty]!.add(university);
        }
      }

      setState(() {
        facultyCourses = groupedCourses;
        visibleCoursesPerFaculty = {
          for (var faculty in groupedCourses.keys) faculty: 5
        };
        isLoading = false;
      });

      // Print the number of faculties and courses returned
      uwcFaculties = facultyCourses.keys.length;
      uwcCourses = facultyCourses.values.expand((list) => list).length;
    } catch (error) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchAvailableCourses_ul() async {
    try {
      final userMarksResponse = await _supabaseClient
          .from('user_marks')
          .select(
              'math_mark, math_level, math_type, home_language_mark, home_language_level, first_additional_language_mark, first_additional_language_level, second_additional_language_mark, second_additional_language_level, subject1, subject1_level, subject2, subject2_level, subject3, subject3_level, subject4, subject4_level, life_orientation_mark, life_orientation_level, home_language, first_additional_language, second_additional_language')
          .eq('user_id', _supabaseClient.auth.currentUser!.id)
          .single();

      final userMarks = userMarksResponse;

      // Fetch courses from the specific university
      final response = await _supabaseClient
          .from('universities')
          .select(
              'university_name, qualification, aps, faculty, english_hl, english_fal, maths, technical_math, maths_lit, physical_sciences, life_orientation, accounting, business_studies, economics, history, geography, tourism, civil_technology, egd, cat, it, electrical_technology, mechanical_technology')
          .eq('university_name',
              'University of Limpopo'); // Filter by university name

      final Map<String, List<Map<String, dynamic>>> groupedCourses = {};

      // Mapping user subjects to university columns
      final subjectMapping = {
        'Physical Sciences': 'physical_sciences',
        'Accounting': 'accounting',
        'Business Studies': 'business_studies',
        'Economics': 'economics',
        'History': 'history',
        'Geography': 'geography',
        'Tourism': 'tourism',
        'Civil Technology': 'civil_technology',
        'Engineering Graphics and Design': 'egd',
        'Computer Applications Technology': 'cat',
        'Information Technology': 'it',
        'Electrical Technology': 'electrical_technology',
        'Mechanical Technology': 'mechanical_technology',
      };

      for (var university in response) {
        bool meetsRequirements = true;

        // Skip APS comparison if APS is null in the universities table
        if (university['aps'] != null) {
          if (apsUl! < university['aps']) {
            meetsRequirements = false;
            continue; // Skip this course if APS does not meet the requirement
          }
        }

        // Compare based on math_type
        if (userMarks['math_type'] == 'Mathematics') {
          if ((userMarks['math_level'] ?? 0) < (university['maths'] ?? 0)) {
            meetsRequirements = false;
          }
        } else if (userMarks['math_type'] == 'Mathematical Literacy') {
          if ((userMarks['math_level'] ?? 0) < (university['maths_lit'] ?? 0)) {
            meetsRequirements = false;
          }
        } else if (userMarks['math_type'] == 'Technical Mathematics') {
          if ((userMarks['math_level'] ?? 0) <
              (university['technical_math'] ?? 0)) {
            meetsRequirements = false;
          }
        }

        // Check English requirements
        bool hasEnglishHL = userMarks['home_language']
                ?.toString()
                .toLowerCase()
                .contains('english') ??
            false;
        bool hasEnglishFAL = userMarks['first_additional_language']
                ?.toString()
                .toLowerCase()
                .contains('english') ??
            false;

        if (hasEnglishHL) {
          if ((userMarks['home_language_level'] ?? 0) <
              (university['english_hl'] ?? 0)) {
            meetsRequirements = false;
          }
        } else if (hasEnglishFAL) {
          if ((userMarks['first_additional_language_level'] ?? 0) <
              (university['english_fal'] ?? 0)) {
            meetsRequirements = false;
          }
        } else {
          meetsRequirements = false;
        }

        // Iterate over the subjects required by the university
        subjectMapping.forEach((key, subjectName) {
          // Get the required level for this subject from the university
          final requiredLevel = university[key];

          // If the university has a requirement for this subject
          if (requiredLevel != null) {
            bool subjectFound = false;

            // Check if any of the user's selected subjects match this university subject
            for (int i = 1; i <= 4; i++) {
              final userSubject = userMarks['subject$i'];
              final userLevel = userMarks['subject${i}_level'];

              // If the user's subject matches the university-required subject
              if (userSubject == subjectName) {
                subjectFound = true;

                // If the user's subject level is less than the required level, they don't qualify
                if ((userLevel ?? 0) < requiredLevel) {
                  meetsRequirements = false;
                  break;
                }
              }
            }

            // If the required subject wasn't found in the user's selected subjects
            if (!subjectFound) {
              meetsRequirements = false;
            }
          }
        });

        // If requirements are met, add to the list
        if (meetsRequirements) {
          final faculty = university['faculty'] ?? 'Unknown Faculty';
          if (!groupedCourses.containsKey(faculty)) {
            groupedCourses[faculty] = [];
          }
          groupedCourses[faculty]!.add(university);
        }
      }

      setState(() {
        facultyCourses = groupedCourses;
        visibleCoursesPerFaculty = {
          for (var faculty in groupedCourses.keys) faculty: 5
        };
        isLoading = false;
      });

      // Print the number of faculties and courses returned
      ulFaculties = facultyCourses.keys.length;
      ulCourses = facultyCourses.values.expand((list) => list).length;
    } catch (error) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchAvailableCourses_nmu() async {
    try {
      final userMarksResponse = await _supabaseClient
          .from('user_marks')
          .select(
              'math_mark, math_level, math_type, home_language_mark, home_language_level, first_additional_language_mark, first_additional_language_level, second_additional_language_mark, second_additional_language_level, subject1, subject1_level, subject2, subject2_level, subject3, subject3_level, subject4, subject4_level, life_orientation_mark, life_orientation_level, home_language, first_additional_language, second_additional_language')
          .eq('user_id', _supabaseClient.auth.currentUser!.id)
          .single();

      final userMarks = userMarksResponse;

      // Fetch courses from the specific university
      final response = await _supabaseClient
          .from('universities')
          .select(
              'university_name, qualification, aps, faculty, english_hl, english_fal, maths, technical_math, maths_lit, physical_sciences, life_orientation, accounting, business_studies, economics, history, geography, tourism, civil_technology, egd, cat, it, electrical_technology, mechanical_technology')
          .eq('university_name',
              'Nelson Mandela University'); // Filter by university name

      final Map<String, List<Map<String, dynamic>>> groupedCourses = {};

      // Mapping user subjects to university columns
      final subjectMapping = {
        'Physical Sciences': 'physical_sciences',
        'Accounting': 'accounting',
        'Business Studies': 'business_studies',
        'Economics': 'economics',
        'History': 'history',
        'Geography': 'geography',
        'Tourism': 'tourism',
        'Civil Technology': 'civil_technology',
        'Engineering Graphics and Design': 'egd',
        'Computer Applications Technology': 'cat',
        'Information Technology': 'it',
        'Electrical Technology': 'electrical_technology',
        'Mechanical Technology': 'mechanical_technology',
      };

      for (var university in response) {
        bool meetsRequirements = true;

        // Skip APS comparison if APS is null in the universities table
        if (university['aps'] != null) {
          if (apsNwu! < university['aps']) {
            meetsRequirements = false;
            continue; // Skip this course if APS does not meet the requirement
          }
        }

        // Compare based on math_type
        if (userMarks['math_type'] == 'Mathematics') {
          if ((userMarks['math_level'] ?? 0) < (university['maths'] ?? 0)) {
            meetsRequirements = false;
          }
        } else if (userMarks['math_type'] == 'Mathematical Literacy') {
          if ((userMarks['math_level'] ?? 0) < (university['maths_lit'] ?? 0)) {
            meetsRequirements = false;
          }
        } else if (userMarks['math_type'] == 'Technical Mathematics') {
          if ((userMarks['math_level'] ?? 0) <
              (university['technical_math'] ?? 0)) {
            meetsRequirements = false;
          }
        }

        // Check English requirements
        bool hasEnglishHL = userMarks['home_language']
                ?.toString()
                .toLowerCase()
                .contains('english') ??
            false;
        bool hasEnglishFAL = userMarks['first_additional_language']
                ?.toString()
                .toLowerCase()
                .contains('english') ??
            false;

        if (hasEnglishHL) {
          if ((userMarks['home_language_level'] ?? 0) <
              (university['english_hl'] ?? 0)) {
            meetsRequirements = false;
          }
        } else if (hasEnglishFAL) {
          if ((userMarks['first_additional_language_level'] ?? 0) <
              (university['english_fal'] ?? 0)) {
            meetsRequirements = false;
          }
        } else {
          meetsRequirements = false;
        }

        // Iterate over the subjects required by the university
        subjectMapping.forEach((key, subjectName) {
          // Get the required level for this subject from the university
          final requiredLevel = university[key];

          // If the university has a requirement for this subject
          if (requiredLevel != null) {
            bool subjectFound = false;

            // Check if any of the user's selected subjects match this university subject
            for (int i = 1; i <= 4; i++) {
              final userSubject = userMarks['subject$i'];
              final userLevel = userMarks['subject${i}_level'];

              // If the user's subject matches the university-required subject
              if (userSubject == subjectName) {
                subjectFound = true;

                // If the user's subject level is less than the required level, they don't qualify
                if ((userLevel ?? 0) < requiredLevel) {
                  meetsRequirements = false;
                  break;
                }
              }
            }

            // If the required subject wasn't found in the user's selected subjects
            if (!subjectFound) {
              meetsRequirements = false;
            }
          }
        });

        // If requirements are met, add to the list
        if (meetsRequirements) {
          final faculty = university['faculty'] ?? 'Unknown Faculty';
          if (!groupedCourses.containsKey(faculty)) {
            groupedCourses[faculty] = [];
          }
          groupedCourses[faculty]!.add(university);
        }
      }

      setState(() {
        facultyCourses = groupedCourses;
        visibleCoursesPerFaculty = {
          for (var faculty in groupedCourses.keys) faculty: 5
        };
        isLoading = false;
      });

      // Print the number of faculties and courses returned
      nmuFaculties = facultyCourses.keys.length;
      nmuCourses = facultyCourses.values.expand((list) => list).length;
    } catch (error) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchAvailableCourses_nwu() async {
    try {
      final userMarksResponse = await _supabaseClient
          .from('user_marks')
          .select(
              'math_mark, math_level, math_type, home_language_mark, home_language_level, first_additional_language_mark, first_additional_language_level, second_additional_language_mark, second_additional_language_level, subject1, subject1_level, subject2, subject2_level, subject3, subject3_level, subject4, subject4_level, life_orientation_mark, life_orientation_level, home_language, first_additional_language, second_additional_language')
          .eq('user_id', _supabaseClient.auth.currentUser!.id)
          .single();

      final userMarks = userMarksResponse;

      // Fetch courses from the specific university
      final response = await _supabaseClient
          .from('universities')
          .select(
              'university_name, qualification, aps, faculty, english_hl, english_fal, maths, technical_math, maths_lit, physical_sciences, life_orientation, accounting, business_studies, economics, history, geography, tourism, civil_technology, egd, cat, it, electrical_technology, mechanical_technology')
          .eq('university_name',
              'North-West University'); // Filter by university name

      final Map<String, List<Map<String, dynamic>>> groupedCourses = {};

      // Mapping user subjects to university columns
      final subjectMapping = {
        'Physical Sciences': 'physical_sciences',
        'Accounting': 'accounting',
        'Business Studies': 'business_studies',
        'Economics': 'economics',
        'History': 'history',
        'Geography': 'geography',
        'Tourism': 'tourism',
        'Civil Technology': 'civil_technology',
        'Engineering Graphics and Design': 'egd',
        'Computer Applications Technology': 'cat',
        'Information Technology': 'it',
        'Electrical Technology': 'electrical_technology',
        'Mechanical Technology': 'mechanical_technology',
      };

      for (var university in response) {
        bool meetsRequirements = true;

        // Skip APS comparison if APS is null in the universities table
        if (university['aps'] != null) {
          if (apsNwu! < university['aps']) {
            meetsRequirements = false;
            continue; // Skip this course if APS does not meet the requirement
          }
        }

        // Compare based on math_type
        if (userMarks['math_type'] == 'Mathematics') {
          if ((userMarks['math_level'] ?? 0) < (university['maths'] ?? 0)) {
            meetsRequirements = false;
          }
        } else if (userMarks['math_type'] == 'Mathematical Literacy') {
          if ((userMarks['math_level'] ?? 0) < (university['maths_lit'] ?? 0)) {
            meetsRequirements = false;
          }
        } else if (userMarks['math_type'] == 'Technical Mathematics') {
          if ((userMarks['math_level'] ?? 0) <
              (university['technical_math'] ?? 0)) {
            meetsRequirements = false;
          }
        }

        // Check English requirements
        bool hasEnglishHL = userMarks['home_language']
                ?.toString()
                .toLowerCase()
                .contains('english') ??
            false;
        bool hasEnglishFAL = userMarks['first_additional_language']
                ?.toString()
                .toLowerCase()
                .contains('english') ??
            false;

        if (hasEnglishHL) {
          if ((userMarks['home_language_level'] ?? 0) <
              (university['english_hl'] ?? 0)) {
            meetsRequirements = false;
          }
        } else if (hasEnglishFAL) {
          if ((userMarks['first_additional_language_level'] ?? 0) <
              (university['english_fal'] ?? 0)) {
            meetsRequirements = false;
          }
        } else {
          meetsRequirements = false;
        }

        // Iterate over the subjects required by the university
        subjectMapping.forEach((key, subjectName) {
          // Get the required level for this subject from the university
          final requiredLevel = university[key];

          // If the university has a requirement for this subject
          if (requiredLevel != null) {
            bool subjectFound = false;

            // Check if any of the user's selected subjects match this university subject
            for (int i = 1; i <= 4; i++) {
              final userSubject = userMarks['subject$i'];
              final userLevel = userMarks['subject${i}_level'];

              // If the user's subject matches the university-required subject
              if (userSubject == subjectName) {
                subjectFound = true;

                // If the user's subject level is less than the required level, they don't qualify
                if ((userLevel ?? 0) < requiredLevel) {
                  meetsRequirements = false;
                  break;
                }
              }
            }

            // If the required subject wasn't found in the user's selected subjects
            if (!subjectFound) {
              meetsRequirements = false;
            }
          }
        });

        // If requirements are met, add to the list
        if (meetsRequirements) {
          final faculty = university['faculty'] ?? 'Unknown Faculty';
          if (!groupedCourses.containsKey(faculty)) {
            groupedCourses[faculty] = [];
          }
          groupedCourses[faculty]!.add(university);
        }
      }

      setState(() {
        facultyCourses = groupedCourses;
        visibleCoursesPerFaculty = {
          for (var faculty in groupedCourses.keys) faculty: 5
        };
        isLoading = false;
      });

      // Print the number of faculties and courses returned
      nwuFaculties = facultyCourses.keys.length;
      nwuCourses = facultyCourses.values.expand((list) => list).length;
    } catch (error) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchAvailableCourses_wits() async {
    try {
      final userMarksResponse = await _supabaseClient
          .from('user_marks')
          .select(
              'math_mark, math_level, math_type, home_language_mark, home_language_level, first_additional_language_mark, first_additional_language_level, second_additional_language_mark, second_additional_language_level, subject1, subject1_level, subject2, subject2_level, subject3, subject3_level, subject4, subject4_level, life_orientation_mark, life_orientation_level, home_language, first_additional_language, second_additional_language')
          .eq('user_id', _supabaseClient.auth.currentUser!.id)
          .single();

      final userMarks = userMarksResponse;

      // Fetch courses from the specific university
      final response = await _supabaseClient
          .from('universities')
          .select(
              'university_name, qualification, aps, faculty, english_hl, english_fal, maths, technical_math, maths_lit, physical_sciences, life_orientation, accounting, business_studies, economics, history, geography, tourism, civil_technology, egd, cat, it, electrical_technology, mechanical_technology')
          .eq('university_name',
              'University of the Witwatersrand'); // Filter by university name

      final Map<String, List<Map<String, dynamic>>> groupedCourses = {};

      // Mapping user subjects to university columns
      final subjectMapping = {
        'Physical Sciences': 'physical_sciences',
        'Accounting': 'accounting',
        'Business Studies': 'business_studies',
        'Economics': 'economics',
        'History': 'history',
        'Geography': 'geography',
        'Tourism': 'tourism',
        'Civil Technology': 'civil_technology',
        'Engineering Graphics and Design': 'egd',
        'Computer Applications Technology': 'cat',
        'Information Technology': 'it',
        'Electrical Technology': 'electrical_technology',
        'Mechanical Technology': 'mechanical_technology',
      };

      for (var university in response) {
        bool meetsRequirements = true;

        // Skip APS comparison if APS is null in the universities table
        if (university['aps'] != null) {
          if (apsWits! < university['aps']) {
            meetsRequirements = false;
            continue; // Skip this course if APS does not meet the requirement
          }
        }

        // Compare based on math_type
        if (userMarks['math_type'] == 'Mathematics') {
          if ((userMarks['math_level'] ?? 0) < (university['maths'] ?? 0)) {
            meetsRequirements = false;
          }
        } else if (userMarks['math_type'] == 'Mathematical Literacy') {
          if ((userMarks['math_level'] ?? 0) < (university['maths_lit'] ?? 0)) {
            meetsRequirements = false;
          }
        } else if (userMarks['math_type'] == 'Technical Mathematics') {
          if ((userMarks['math_level'] ?? 0) <
              (university['technical_math'] ?? 0)) {
            meetsRequirements = false;
          }
        }

        // Check English requirements
        bool hasEnglishHL = userMarks['home_language']
                ?.toString()
                .toLowerCase()
                .contains('english') ??
            false;
        bool hasEnglishFAL = userMarks['first_additional_language']
                ?.toString()
                .toLowerCase()
                .contains('english') ??
            false;

        if (hasEnglishHL) {
          if ((userMarks['home_language_level'] ?? 0) <
              (university['english_hl'] ?? 0)) {
            meetsRequirements = false;
          }
        } else if (hasEnglishFAL) {
          if ((userMarks['first_additional_language_level'] ?? 0) <
              (university['english_fal'] ?? 0)) {
            meetsRequirements = false;
          }
        } else {
          meetsRequirements = false;
        }

        // Iterate over the subjects required by the university
        subjectMapping.forEach((key, subjectName) {
          // Get the required level for this subject from the university
          final requiredLevel = university[key];

          // If the university has a requirement for this subject
          if (requiredLevel != null) {
            bool subjectFound = false;

            // Check if any of the user's selected subjects match this university subject
            for (int i = 1; i <= 4; i++) {
              final userSubject = userMarks['subject$i'];
              final userLevel = userMarks['subject${i}_level'];

              // If the user's subject matches the university-required subject
              if (userSubject == subjectName) {
                subjectFound = true;

                // If the user's subject level is less than the required level, they don't qualify
                if ((userLevel ?? 0) < requiredLevel) {
                  meetsRequirements = false;
                  break;
                }
              }
            }

            // If the required subject wasn't found in the user's selected subjects
            if (!subjectFound) {
              meetsRequirements = false;
            }
          }
        });

        // If requirements are met, add to the list
        if (meetsRequirements) {
          final faculty = university['faculty'] ?? 'Unknown Faculty';
          if (!groupedCourses.containsKey(faculty)) {
            groupedCourses[faculty] = [];
          }
          groupedCourses[faculty]!.add(university);
        }
      }

      setState(() {
        facultyCourses = groupedCourses;
        visibleCoursesPerFaculty = {
          for (var faculty in groupedCourses.keys) faculty: 5
        };
        isLoading = false;
      });

      // Print the number of faculties and courses returned
      witsFaculties = facultyCourses.keys.length;
      witsCourses = facultyCourses.values.expand((list) => list).length;
    } catch (error) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchAvailableCourses_ukzn() async {
    try {
      final userMarksResponse = await _supabaseClient
          .from('user_marks')
          .select(
              'math_mark, math_level, math_type, home_language_mark, home_language_level, first_additional_language_mark, first_additional_language_level, second_additional_language_mark, second_additional_language_level, subject1, subject1_level, subject2, subject2_level, subject3, subject3_level, subject4, subject4_level, life_orientation_mark, life_orientation_level, home_language, first_additional_language, second_additional_language')
          .eq('user_id', _supabaseClient.auth.currentUser!.id)
          .single();

      final userMarks = userMarksResponse;

      // Fetch courses from the specific university
      final response = await _supabaseClient
          .from('universities')
          .select(
              'university_name, qualification, aps, faculty, english_hl, english_fal, maths, technical_math, maths_lit, physical_sciences, life_orientation, accounting, business_studies, economics, history, geography, tourism, civil_technology, egd, cat, it, electrical_technology, mechanical_technology')
          .eq('university_name',
              'University of Kwazulu-Natal'); // Filter by university name

      final Map<String, List<Map<String, dynamic>>> groupedCourses = {};

      // Mapping user subjects to university columns
      final subjectMapping = {
        'Physical Sciences': 'physical_sciences',
        'Accounting': 'accounting',
        'Business Studies': 'business_studies',
        'Economics': 'economics',
        'History': 'history',
        'Geography': 'geography',
        'Tourism': 'tourism',
        'Civil Technology': 'civil_technology',
        'Engineering Graphics and Design': 'egd',
        'Computer Applications Technology': 'cat',
        'Information Technology': 'it',
        'Electrical Technology': 'electrical_technology',
        'Mechanical Technology': 'mechanical_technology',
      };

      for (var university in response) {
        bool meetsRequirements = true;

        // Skip APS comparison if APS is null in the universities table
        if (university['aps'] != null) {
          if (apsUkzn! < university['aps']) {
            meetsRequirements = false;
            continue; // Skip this course if APS does not meet the requirement
          }
        }

        // Compare based on math_type
        if (userMarks['math_type'] == 'Mathematics') {
          if ((userMarks['math_level'] ?? 0) < (university['maths'] ?? 0)) {
            meetsRequirements = false;
          }
        } else if (userMarks['math_type'] == 'Mathematical Literacy') {
          if ((userMarks['math_level'] ?? 0) < (university['maths_lit'] ?? 0)) {
            meetsRequirements = false;
          }
        } else if (userMarks['math_type'] == 'Technical Mathematics') {
          if ((userMarks['math_level'] ?? 0) <
              (university['technical_math'] ?? 0)) {
            meetsRequirements = false;
          }
        }

        // Check English requirements
        bool hasEnglishHL = userMarks['home_language']
                ?.toString()
                .toLowerCase()
                .contains('english') ??
            false;
        bool hasEnglishFAL = userMarks['first_additional_language']
                ?.toString()
                .toLowerCase()
                .contains('english') ??
            false;

        if (hasEnglishHL) {
          if ((userMarks['home_language_level'] ?? 0) <
              (university['english_hl'] ?? 0)) {
            meetsRequirements = false;
          }
        } else if (hasEnglishFAL) {
          if ((userMarks['first_additional_language_level'] ?? 0) <
              (university['english_fal'] ?? 0)) {
            meetsRequirements = false;
          }
        } else {
          meetsRequirements = false;
        }

        // Iterate over the subjects required by the university
        subjectMapping.forEach((key, subjectName) {
          // Get the required level for this subject from the university
          final requiredLevel = university[key];

          // If the university has a requirement for this subject
          if (requiredLevel != null) {
            bool subjectFound = false;

            // Check if any of the user's selected subjects match this university subject
            for (int i = 1; i <= 4; i++) {
              final userSubject = userMarks['subject$i'];
              final userLevel = userMarks['subject${i}_level'];

              // If the user's subject matches the university-required subject
              if (userSubject == subjectName) {
                subjectFound = true;

                // If the user's subject level is less than the required level, they don't qualify
                if ((userLevel ?? 0) < requiredLevel) {
                  meetsRequirements = false;
                  break;
                }
              }
            }

            // If the required subject wasn't found in the user's selected subjects
            if (!subjectFound) {
              meetsRequirements = false;
            }
          }
        });

        // If requirements are met, add to the list
        if (meetsRequirements) {
          final faculty = university['faculty'] ?? 'Unknown Faculty';
          if (!groupedCourses.containsKey(faculty)) {
            groupedCourses[faculty] = [];
          }
          groupedCourses[faculty]!.add(university);
        }
      }

      setState(() {
        facultyCourses = groupedCourses;
        visibleCoursesPerFaculty = {
          for (var faculty in groupedCourses.keys) faculty: 5
        };
        isLoading = false;
      });

      // Print the number of faculties and courses returned
      ukznFaculties = facultyCourses.keys.length;
      ukznCourses = facultyCourses.values.expand((list) => list).length;
    } catch (error) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchAvailableCourses_dut() async {
    try {
      final userMarksResponse = await _supabaseClient
          .from('user_marks')
          .select(
              'math_mark, math_level, math_type, home_language_mark, home_language_level, first_additional_language_mark, first_additional_language_level, second_additional_language_mark, second_additional_language_level, subject1, subject1_level, subject2, subject2_level, subject3, subject3_level, subject4, subject4_level, life_orientation_mark, life_orientation_level, home_language, first_additional_language, second_additional_language')
          .eq('user_id', _supabaseClient.auth.currentUser!.id)
          .single();

      final userMarks = userMarksResponse;

      // Fetch courses from the specific university
      final response = await _supabaseClient
          .from('universities')
          .select(
              'university_name, qualification, aps, faculty, english_hl, english_fal, maths, technical_math, maths_lit, physical_sciences, life_orientation, accounting, business_studies, economics, history, geography, tourism, civil_technology, egd, cat, it, electrical_technology, mechanical_technology')
          .eq('university_name',
              'Durban University of Technology'); // Filter by university name

      final Map<String, List<Map<String, dynamic>>> groupedCourses = {};

      // Mapping user subjects to university columns
      final subjectMapping = {
        'Physical Sciences': 'physical_sciences',
        'Accounting': 'accounting',
        'Business Studies': 'business_studies',
        'Economics': 'economics',
        'History': 'history',
        'Geography': 'geography',
        'Tourism': 'tourism',
        'Civil Technology': 'civil_technology',
        'Engineering Graphics and Design': 'egd',
        'Computer Applications Technology': 'cat',
        'Information Technology': 'it',
        'Electrical Technology': 'electrical_technology',
        'Mechanical Technology': 'mechanical_technology',
      };

      for (var university in response) {
        bool meetsRequirements = true;

        // Skip APS comparison if APS is null in the universities table
        if (university['aps'] != null) {
          if (apsDut! < university['aps']) {
            meetsRequirements = false;
            continue; // Skip this course if APS does not meet the requirement
          }
        }

        // Compare based on math_type
        if (userMarks['math_type'] == 'Mathematics') {
          if ((userMarks['math_level'] ?? 0) < (university['maths'] ?? 0)) {
            meetsRequirements = false;
          }
        } else if (userMarks['math_type'] == 'Mathematical Literacy') {
          if ((userMarks['math_level'] ?? 0) < (university['maths_lit'] ?? 0)) {
            meetsRequirements = false;
          }
        } else if (userMarks['math_type'] == 'Technical Mathematics') {
          if ((userMarks['math_level'] ?? 0) <
              (university['technical_math'] ?? 0)) {
            meetsRequirements = false;
          }
        }

        // Check English requirements
        bool hasEnglishHL = userMarks['home_language']
                ?.toString()
                .toLowerCase()
                .contains('english') ??
            false;
        bool hasEnglishFAL = userMarks['first_additional_language']
                ?.toString()
                .toLowerCase()
                .contains('english') ??
            false;

        if (hasEnglishHL) {
          if ((userMarks['home_language_level'] ?? 0) <
              (university['english_hl'] ?? 0)) {
            meetsRequirements = false;
          }
        } else if (hasEnglishFAL) {
          if ((userMarks['first_additional_language_level'] ?? 0) <
              (university['english_fal'] ?? 0)) {
            meetsRequirements = false;
          }
        } else {
          meetsRequirements = false;
        }

        // Iterate over the subjects required by the university
        subjectMapping.forEach((key, subjectName) {
          // Get the required level for this subject from the university
          final requiredLevel = university[key];

          // If the university has a requirement for this subject
          if (requiredLevel != null) {
            bool subjectFound = false;

            // Check if any of the user's selected subjects match this university subject
            for (int i = 1; i <= 4; i++) {
              final userSubject = userMarks['subject$i'];
              final userLevel = userMarks['subject${i}_level'];

              // If the user's subject matches the university-required subject
              if (userSubject == subjectName) {
                subjectFound = true;

                // If the user's subject level is less than the required level, they don't qualify
                if ((userLevel ?? 0) < requiredLevel) {
                  meetsRequirements = false;
                  break;
                }
              }
            }

            // If the required subject wasn't found in the user's selected subjects
            if (!subjectFound) {
              meetsRequirements = false;
            }
          }
        });

        // If requirements are met, add to the list
        if (meetsRequirements) {
          final faculty = university['faculty'] ?? 'Unknown Faculty';
          if (!groupedCourses.containsKey(faculty)) {
            groupedCourses[faculty] = [];
          }
          groupedCourses[faculty]!.add(university);
        }
      }

      setState(() {
        facultyCourses = groupedCourses;
        visibleCoursesPerFaculty = {
          for (var faculty in groupedCourses.keys) faculty: 5
        };
        isLoading = false;
      });

      // Print the number of faculties and courses returned
      dutFaculties = facultyCourses.keys.length;
      dutCourses = facultyCourses.values.expand((list) => list).length;
    } catch (error) {
      setState(() {
        isLoading = false;
      });
    }
  }
}
