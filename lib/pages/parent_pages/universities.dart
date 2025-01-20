import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:reslocate/aps_calculators/nmu_aps.dart';
import 'package:reslocate/aps_calculators/rhodes_aps.dart';
import 'package:reslocate/aps_calculators/stellies_aps.dart';
import 'package:reslocate/aps_calculators/vut_aps.dart';
import 'package:reslocate/aps_calculators/uct_aps.dart';
import 'package:reslocate/aps_calculators/univen_aps.dart';
import 'package:reslocate/pages/parent_pages/available_universities.dart';
import 'package:reslocate/widgets/loadingAnimation.dart';
import 'package:reslocate/widgets/university_cards.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:reslocate/available_courses/getAvailableCourses.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ParentUniversitiespage extends StatefulWidget {
  const ParentUniversitiespage({super.key});

  @override
  _UniversitiesPageState createState() => _UniversitiesPageState();
}

class _UniversitiesPageState extends State<ParentUniversitiespage> {
  final SupabaseClient _supabaseClient = Supabase.instance.client;
  Map<String, List<Map<String, dynamic>>> facultyCourses = {};
  Map<String, int> visibleCoursesPerFaculty = {};
  bool isLoading = true; // Track loading state
  @override
  void initState() {
    super.initState();
    loadChildData();
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

  Future<void> loadChildData() async {
    setState(() {
      isLoading = true; // Show loading animation
    });

    String childUserId = await getSelectedChildId();
    print(childUserId);
    await Future.wait([
      _fetchUserMarks_ukzn(childUserId),
      _fetchUserMarks_uj(childUserId),
      _fetchUserMarksCput(childUserId),
      _fetchUserMarks_spu(childUserId),
      _fetchUserMarks_ufh(childUserId),
      _fetchUserMarks_mut(childUserId),
      _fetchUserMarks_ufs(childUserId),
      _fetchUserMarks_uz(childUserId),
      _fetchUserMarks_cut(childUserId),
      _fetchUserMarks_wsu(childUserId),
      _fetchUserMarks_smu(childUserId),
      _fetchUserMarks_lo(childUserId),
      _fetchUserMarks_wits(childUserId),
      _fetchUserMarks_ump(childUserId),
      _loadBookmarks(), // Load bookmarks on init
      _fetchAvailableCourses_uj(childUserId),
      _fetchAvailableCourses_up(childUserId),
      _fetchAvailableCourses_cput(childUserId),
      _fetchAvailableCourses_wits(childUserId),
      _fetchAvailableCourses_ukzn(childUserId),
      _fetchAvailableCourses_nwu(childUserId),
      _fetchAvailableCourses_nmu(childUserId),
      _fetchAvailableCourses_ul(childUserId),
      _fetchAvailableCourses_uwc(childUserId),
      _fetchAvailableCourses_tut(childUserId),
      _fetchAvailableCourses_stllies(childUserId),
      _fetchAvailableCourses_smu(childUserId),
      _fetchAvailableCourses_dut(childUserId),
      _fetchAvailableCourses_wsu(childUserId),
      _fetchAvailableCourses_rhodes(childUserId),
      _fetchAvailableCourses_cut(childUserId),
      _fetchAvailableCourses_ufs(childUserId),
      _fetchAvailableCourses_uct(childUserId),
      _fetchAvailableCourses_uz(childUserId),
      _fetchAvailableCourses_uv(childUserId),
      _fetchAvailableCourses_mut(childUserId),
      _fetchAvailableCourses_vut(childUserId),
      _fetchAvailableCourses_ufh(childUserId),
      _fetchAvailableCourses_spu(childUserId),
      _fetchAvailableCourses_ump(childUserId),
      Future.delayed(const Duration(seconds: 50)),
    ]);

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

  Future<void> _fetchUserMarks_ukzn(String childUserId) async {
    try {
      final response = await _supabaseClient
          .from('user_marks')
          .select(
              'math_mark, subject1_mark, subject2_mark, subject3_mark, subject4_mark, home_language_mark, first_additional_language_mark, second_additional_language_mark')
          .eq('user_id', childUserId) // Use the child's ID here
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching user marks: $error')),
      );
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

  Future<void> _fetchUserMarks_ump(String childUserId) async {
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
        apsUmp = _CalculateApsUmp(userMarks);
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

  Future<void> _fetchUserMarks_wits(String childUserId) async {
    try {
      final response = await _supabaseClient
          .from('user_marks')
          .select(
              'math_mark, subject1_mark, subject2_mark, subject3_mark, subject4_mark, home_language_mark, first_additional_language_mark, second_additional_language_mark, life_orientation_mark, math_type, subject1, subject2, subject3, subject4, home_language, first_additional_language, second_additional_language')
          .eq('user_id', childUserId)
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching user marks: $error')),
      );
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

  Future<void> _fetchUserMarks_lo(String childUserId) async {
    try {
      final response = await _supabaseClient
          .from('user_marks')
          .select(
              'math_mark, subject1_mark, subject2_mark, subject3_mark, subject4_mark, home_language_mark, first_additional_language_mark, second_additional_language_mark, life_orientation_mark')
          .eq('user_id', childUserId)
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching user marks: $error')),
      );
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

  Future<void> _fetchUserMarks_smu(String childUserId) async {
    try {
      final response = await _supabaseClient
          .from('user_marks')
          .select(
              'math_mark, subject1_mark, subject2_mark, subject3_mark, subject4_mark, home_language_mark, first_additional_language_mark, second_additional_language_mark, life_orientation_mark')
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching user marks: $error')),
      );
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

  Future<void> _fetchUserMarks_wsu(String childUserId) async {
    try {
      final response = await _supabaseClient
          .from('user_marks')
          .select(
              'math_mark, subject1_mark, subject2_mark, subject3_mark, subject4_mark, home_language_mark, first_additional_language_mark, second_additional_language_mark, life_orientation_mark')
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching user marks: $error')),
      );
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

  Future<void> _fetchUserMarks_cut(String childUserId) async {
    try {
      final response = await _supabaseClient
          .from('user_marks')
          .select(
              'math_mark, subject1_mark, subject2_mark, subject3_mark, subject4_mark, home_language_mark, first_additional_language_mark, second_additional_language_mark, life_orientation_mark')
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching user marks: $error')),
      );
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

  Future<void> _fetchUserMarks_uz(String childUserId) async {
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
        apsUz = _CalculateUZAPS(userMarks);
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

  Future<void> _fetchUserMarks_ufs(String childUserId) async {
    try {
      final response = await _supabaseClient
          .from('user_marks')
          .select(
              'math_mark, subject1_mark, subject2_mark, subject3_mark, subject4_mark, home_language_mark, first_additional_language_mark, second_additional_language_mark, life_orientation_mark')
          .eq('user_id', childUserId)
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching user marks: $error')),
      );
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

  Future<void> _fetchUserMarks_mut(String childUserId) async {
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
        apsMut = _CalculateMUTAPS(userMarks);
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

  Future<void> _fetchUserMarks_ufh(String childUserId) async {
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
        apsUfh = _CalculateApsUFH(userMarks);
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

  Future<void> _fetchUserMarks_spu(String childUserId) async {
    try {
      final response = await _supabaseClient
          .from('user_marks')
          .select(
              'math_mark, subject1_mark, subject2_mark, subject3_mark, subject4_mark, home_language_mark, first_additional_language_mark, second_additional_language_mark, life_orientation_mark, math_type')
          .eq('user_id', childUserId)
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching user marks: $error')),
      );
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

  Future<void> _fetchUserMarksCput(String childUserId) async {
    try {
      final response = await _supabaseClient
          .from('user_marks')
          .select(
              'math_mark, subject1_mark, subject2_mark, subject3_mark, subject4_mark, home_language_mark, first_additional_language_mark, second_additional_language_mark, life_orientation_mark')
          .eq('user_id', childUserId)
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching user marks: $error')),
      );
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

  Future<void> _fetchUserMarks_uj(String childUserId) async {
    try {
      final response = await _supabaseClient
          .from('user_marks')
          .select(
              'math_mark, subject1_mark, subject2_mark, subject3_mark, subject4_mark, home_language_mark, first_additional_language_mark, second_additional_language_mark')
          .eq('user_id', childUserId)
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching user marks: $error')),
      );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                  'Universities',
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
      body: isLoading
          ? const Center(child: BouncingImageLoader()) // Show loading animation
          : SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 600;
                  final isTablet = constraints.maxWidth >= 600 &&
                      constraints.maxWidth < 1024;
                  final isDesktop = constraints.maxWidth >= 1024;

                  return Padding(
                    padding: const EdgeInsets.only(
                      left: 20.0, // Padding for the left
                      right: 20.0, // Padding for the right
                      // No padding for the bottom
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 30),

                          // University of Johannesburg card with APS
                          UniversityCard(
                            title: 'University of Johannesburg',
                            logo: 'assets/images/uj_logo.webp',
                            aps: apsUj ?? 0,
                            courses: ujCourses,
                            faculties: ujFaculties,
                            route: ParentGetAvailableCourses(
                                aps: apsUj ?? 0,
                                universityName:
                                    'University of Johannesburg'), // Replace with the appropriate page
                            isBookmarked:
                                isBookmarked('University of Johannesburg'),
                            onBookmarkPressed: () =>
                                _toggleBookmark('University of Johannesburg'),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          UniversityCard(
                            title: 'Cape Peninsula University Of Technology',
                            logo: 'assets/images/cput_logo.png',
                            aps: apsCput ?? 0,
                            courses: cputCourses,
                            faculties: cputFaculties,
                            route: ParentGetAvailableCourses(
                                aps: apsCput ?? 0,
                                universityName:
                                    'Cape Peninsula University of Technology'),
                            isBookmarked: isBookmarked(
                                'Cape Peninsula University of Technology'),
                            onBookmarkPressed: () => _toggleBookmark(
                                'Cape Peninsula University of Technology'), // Replace with the appropriate page
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          UniversityCard(
                            title: 'University of Pretoria',
                            logo: 'assets/images/up_logo.png',
                            aps: apsUj ?? 0,
                            courses: upCourses,
                            faculties: upFaculties,
                            route: ParentGetAvailableCourses(
                                aps: apsUj ?? 0,
                                universityName:
                                    'University of Pretoria'), // Replace with the appropriate page
                            isBookmarked:
                                isBookmarked('University of Pretoria'),
                            onBookmarkPressed: () =>
                                _toggleBookmark('University of Pretoria'),
                          ),
                          // CPUT card with APS
                          const SizedBox(
                            height: 10,
                          ),
                          UniversityCard(
                            title: 'Sol Plaatje University',
                            logo: 'assets/images/spu_logo.png',
                            aps: apsSpu ?? 0,
                            courses: spuCourses,
                            faculties: spuFaculties,
                            route: ParentGetAvailableCourses(
                                aps: apsSpu ?? 0,
                                universityName:
                                    'Sol Plaatje University'), // Replace with the appropriate page
                            isBookmarked:
                                isBookmarked('Sol Plaatje University'),
                            onBookmarkPressed: () =>
                                _toggleBookmark('Sol Plaatje University'),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          UniversityCard(
                            title: 'University of Fort Hare',
                            logo: 'assets/images/ufh_logo.png',
                            aps: apsUfh ?? 0,
                            courses: ufhCourses,
                            faculties: ufhFaculties,
                            route: ParentGetAvailableCourses(
                                aps: apsUfh ?? 0,
                                universityName:
                                    'University of Fort Hare'), // Replace with the appropriate page
                            isBookmarked:
                                isBookmarked('University of Fort Hare'),
                            onBookmarkPressed: () =>
                                _toggleBookmark('University of Fort Hare'),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          UniversityCard2(
                            title: 'Vaal University of Technology',
                            logo: 'assets/images/vut_logo.png',
                            aps: "",
                            courses: vutCourses,
                            faculties: vutFaculties,
                            route:
                                const CalculateApsVUTPage(), // Replace with the appropriate page
                            isBookmarked:
                                isBookmarked('Vaal University of Technology'),
                            onBookmarkPressed: () => _toggleBookmark(
                                'Vaal University of Technology'),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          UniversityCard(
                            title: 'Mangosuthu University of Technology',
                            logo: 'assets/images/mut_logo.png',
                            aps: apsMut ?? 0,
                            courses: mutCourses,
                            faculties: mutFaculties,
                            route: ParentGetAvailableCourses(
                                aps: apsUfh ?? 0,
                                universityName:
                                    'Mangosuthu University of Technology'), // Replace with the appropriate page
                            isBookmarked: isBookmarked(
                                'Mangosuthu University of Technology'),
                            onBookmarkPressed: () => _toggleBookmark(
                                'Mangosuthu University of Technology'),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          UniversityCard2(
                            title: 'University Of Venda',
                            logo: 'assets/images/univen_logo.svg.png',
                            aps: '',
                            courses: univenCourses,
                            faculties: univenFaculties,
                            route:
                                const CalculateUNIVENAPSPage(), // Replace with the appropriate page
                            isBookmarked: isBookmarked('University Of Venda'),
                            onBookmarkPressed: () =>
                                _toggleBookmark('University Of Venda'),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          UniversityCard(
                            title: 'University Of Zululand',
                            logo: 'assets/images/uz_logo.png',
                            aps: apsUz ?? 0,
                            courses: unizuluCourses,
                            faculties: univenFaculties,
                            route: ParentGetAvailableCourses(
                                aps: apsUz ?? 0,
                                universityName:
                                    'University of Zululand'), // Replace with the appropriate page
                            isBookmarked:
                                isBookmarked('University Of Zululand'),
                            onBookmarkPressed: () =>
                                _toggleBookmark('University Of Zululand'),
                          ),
                          const SizedBox(
                            height: 10,
                          ),

                          UniversityCard2(
                            title: 'University of Cape Town',
                            logo: 'assets/images/uct_logo.webp',
                            aps: "",
                            courses: 6,
                            faculties: 8,
                            route:
                                const CalculateAPSUCTPage(), // Replace with the appropriate page
                            isBookmarked:
                                isBookmarked('University of Cape Town'),
                            onBookmarkPressed: () =>
                                _toggleBookmark('University of Cape Town'),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          UniversityCard(
                            title: 'University Of The Free State',
                            logo: 'assets/images/ufs_logo.png',
                            aps: apsUfs ?? 0,
                            courses: ufsCourses,
                            faculties: ufsFaculties,
                            route: ParentGetAvailableCourses(
                                aps: apsUfs ?? 0,
                                universityName:
                                    'University of The Free State'), // Replace with the appropriate page
                            isBookmarked:
                                isBookmarked('University Of The Free State'),
                            onBookmarkPressed: () =>
                                _toggleBookmark('University Of The Free State'),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          UniversityCard(
                            title: 'Central University of Technology',
                            logo: 'assets/images/cut_logo.webp',
                            aps: apsCut ?? 0,
                            courses: cutCourses,
                            faculties: cutFaculties,
                            route: ParentGetAvailableCourses(
                                aps: apsCut ?? 0,
                                universityName:
                                    'Central University of Technology'), // Replace with the appropriate page
                            isBookmarked: isBookmarked(
                                'Central University of Technology'),
                            onBookmarkPressed: () => _toggleBookmark(
                                'Central University of Technology'),
                          ),
                          const SizedBox(
                            height: 10,
                          ),

                          UniversityCard2(
                            title: 'Rhodes University',
                            logo: 'assets/images/Rhodes_logo.png',
                            aps: "",
                            courses: rhodesCourses,
                            faculties: rhodesFaculties,
                            route:
                                const CalculateApsRhodesPage(), // Replace with the appropriate page
                            isBookmarked: isBookmarked('Rhodes University'),
                            onBookmarkPressed: () =>
                                _toggleBookmark('Rhodes University'),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          UniversityCard(
                            title: 'Walter Sisulu University',
                            logo: 'assets/images/wsu_logo.png',
                            aps: apsWsu ?? 0,
                            courses: wsuCourses,
                            faculties: wsuFaculties,
                            route: ParentGetAvailableCourses(
                                aps: apsWsu ?? 0,
                                universityName:
                                    'Walter Sisulu University'), // Replace with the appropriate page
                            isBookmarked:
                                isBookmarked('Walter Sisulu University'),
                            onBookmarkPressed: () =>
                                _toggleBookmark('Walter Sisulu University'),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          UniversityCard(
                            title: 'Durban University of Technology',
                            logo: 'assets/images/dut_logo.webp',
                            aps: apsDut ?? 0,
                            courses: dutCourses,
                            faculties: dutFaculties,
                            route: ParentGetAvailableCourses(
                                aps: apsDut ?? 0,
                                universityName:
                                    'Durban University of Technology'), // Replace with the appropriate page
                            isBookmarked:
                                isBookmarked('Durban University of Technology'),
                            onBookmarkPressed: () => _toggleBookmark(
                                'Durban University of Technology'),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          UniversityCard(
                            title: 'Sefako Makgatho University',
                            logo: 'assets/images/smu_logo.png',
                            aps: apsSmu ?? 0,
                            courses: smuCourses,
                            faculties: smuFaculties,
                            route: ParentGetAvailableCourses(
                                aps: apsSmu ?? 0,
                                universityName:
                                    'Sefako Makgatho University'), // Replace with the appropriate page
                            isBookmarked:
                                isBookmarked('Sefako Makgatho University'),
                            onBookmarkPressed: () =>
                                _toggleBookmark('Sefako Makgatho University'),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          UniversityCard2(
                            title: 'Stellenbosch University',
                            logo: 'assets/images/stellies_logo.webp',
                            aps: '',
                            courses: stelliesCourses,
                            faculties: stelliesFaculties,
                            route:
                                const CalculateApsStelliesPage(), // Replace with the appropriate page
                            isBookmarked:
                                isBookmarked('Stellenbosch University'),
                            onBookmarkPressed: () =>
                                _toggleBookmark('Stellenbosch University'),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          UniversityCard(
                            title: 'Tshwane University of Technology',
                            logo: 'assets/images/tut_logo.jpeg',
                            aps: apsUj ?? 0,
                            courses: tutCourses,
                            faculties: tutFaculties,
                            route: ParentGetAvailableCourses(
                                aps: apsUj ?? 0,
                                universityName:
                                    'Tshwane University of Technology'), // Replace with the appropriate page
                            isBookmarked: isBookmarked(
                                'Tshwane University of Technology'),
                            onBookmarkPressed: () => _toggleBookmark(
                                'Tshwane University of Technology'),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          UniversityCard(
                            title: 'University of the Western Cape',
                            logo: 'assets/images/uwc_logo.png',
                            aps: apsUwc ?? 0,
                            courses: uwcCourses,
                            faculties: uwcFaculties,
                            route: ParentGetAvailableCourses(
                                aps: apsUwc ?? 0,
                                universityName:
                                    'University of the Western Cape'), // Replace with the appropriate page
                            isBookmarked:
                                isBookmarked('University of the Western Cape'),
                            onBookmarkPressed: () => _toggleBookmark(
                                'University of the Western Cape'),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          UniversityCard(
                            title: 'University of Limpopo',
                            logo: 'assets/images/ul_logo.png',
                            aps: apsUl ?? 0,
                            courses: ulCourses,
                            faculties: ulFaculties,
                            route: ParentGetAvailableCourses(
                                aps: apsUl ?? 0,
                                universityName:
                                    'University of Limpopo'), // Replace with the appropriate page
                            isBookmarked: isBookmarked('University of Limpopo'),
                            onBookmarkPressed: () =>
                                _toggleBookmark('University of Limpopo'),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          UniversityCard2(
                            title: 'Nelson Mandela University',
                            logo: 'assets/images/nmu_logo.png',
                            aps: "",
                            courses: nmuCourses,
                            faculties: nmuFaculties,
                            route:
                                const CalculateApsNMUPage(), // Replace with the appropriate page
                            isBookmarked:
                                isBookmarked('Nelson Mandela University'),
                            onBookmarkPressed: () =>
                                _toggleBookmark('Nelson Mandela University'),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          UniversityCard(
                            title: 'North West University',
                            logo: 'assets/images/nwu_logo.png',
                            aps: apsNwu ?? 0,
                            courses: nwuCourses,
                            faculties: nwuFaculties,
                            route: ParentGetAvailableCourses(
                                aps: apsNwu ?? 0,
                                universityName:
                                    'North-West University'), // Replace with the appropriate page
                            isBookmarked: isBookmarked('North West University'),
                            onBookmarkPressed: () =>
                                _toggleBookmark('North West University'),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          UniversityCard(
                            title: 'University of the Witwatersrand',
                            logo: 'assets/images/wits_logo.webp',
                            aps: apsWits ?? 0,
                            courses: witsCourses,
                            faculties: witsFaculties,
                            route: ParentGetAvailableCourses(
                                aps: apsWits ?? 0,
                                universityName:
                                    'University of the Witwatersrand'), // Replace with the appropriate page
                            isBookmarked:
                                isBookmarked('University of the Witwatersrand'),
                            onBookmarkPressed: () => _toggleBookmark(
                                'University of the Witwatersrand'),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          UniversityCard(
                            title: 'University of Kwazulu-Natal',
                            logo: 'assets/images/ukzn_logo.webp',
                            aps: apsUkzn ?? 0,
                            courses: ukznCourses,
                            faculties: ukznFaculties,
                            route: ParentGetAvailableCourses(
                                aps: apsUkzn ?? 0,
                                universityName:
                                    'University of Kwazulu-Natal'), // Replace with the appropriate page
                            isBookmarked:
                                isBookmarked('University of Kwazulu-Natal'),
                            onBookmarkPressed: () =>
                                _toggleBookmark('University of Kwazulu-Natal'),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          UniversityCard(
                            title: 'University of Mpumalanga',
                            logo: 'assets/images/um_logo.png',
                            aps: apsUmp ?? 0,
                            courses: umpCourses,
                            faculties: umpFaculties,
                            route: ParentGetAvailableCourses(
                                aps: apsUmp ?? 0,
                                universityName:
                                    'University of Mpumalanga'), // Replace with the appropriate page
                            isBookmarked:
                                isBookmarked('University of Mpumalanga'),
                            onBookmarkPressed: () =>
                                _toggleBookmark('University of Mpumalanga'),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }

// Custom Button for navigation
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

  Future<void> _fetchAvailableCourses_uj(String childUserId) async {
    try {
      final userMarksResponse = await _supabaseClient
          .from('user_marks')
          .select(
              'math_mark, math_level, math_type, home_language_mark, home_language_level, first_additional_language_mark, first_additional_language_level, second_additional_language_mark, second_additional_language_level, subject1, subject1_level, subject2, subject2_level, subject3, subject3_level, subject4, subject4_level, life_orientation_mark, life_orientation_level, home_language, first_additional_language, second_additional_language')
          .eq('user_id', childUserId)
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

  Future<void> _fetchAvailableCourses_up(String childUserId) async {
    try {
      final userMarksResponse = await _supabaseClient
          .from('user_marks')
          .select(
              'math_mark, math_level, math_type, home_language_mark, home_language_level, first_additional_language_mark, first_additional_language_level, second_additional_language_mark, second_additional_language_level, subject1, subject1_level, subject2, subject2_level, subject3, subject3_level, subject4, subject4_level, life_orientation_mark, life_orientation_level, home_language, first_additional_language, second_additional_language')
          .eq('user_id', childUserId)
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

  Future<void> _fetchAvailableCourses_cput(String childUserId) async {
    try {
      final userMarksResponse = await _supabaseClient
          .from('user_marks')
          .select(
              'math_mark, math_level, math_type, home_language_mark, home_language_level, first_additional_language_mark, first_additional_language_level, second_additional_language_mark, second_additional_language_level, subject1, subject1_level, subject2, subject2_level, subject3, subject3_level, subject4, subject4_level, life_orientation_mark, life_orientation_level, home_language, first_additional_language, second_additional_language')
          .eq('user_id', childUserId)
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

  Future<void> _fetchAvailableCourses_spu(String childUserId) async {
    try {
      final userMarksResponse = await _supabaseClient
          .from('user_marks')
          .select(
              'math_mark, math_level, math_type, home_language_mark, home_language_level, first_additional_language_mark, first_additional_language_level, second_additional_language_mark, second_additional_language_level, subject1, subject1_level, subject2, subject2_level, subject3, subject3_level, subject4, subject4_level, life_orientation_mark, life_orientation_level, home_language, first_additional_language, second_additional_language')
          .eq('user_id', childUserId)
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

  Future<void> _fetchAvailableCourses_ufh(String childUserId) async {
    try {
      final userMarksResponse = await _supabaseClient
          .from('user_marks')
          .select(
              'math_mark, math_level, math_type, home_language_mark, home_language_level, first_additional_language_mark, first_additional_language_level, second_additional_language_mark, second_additional_language_level, subject1, subject1_level, subject2, subject2_level, subject3, subject3_level, subject4, subject4_level, life_orientation_mark, life_orientation_level, home_language, first_additional_language, second_additional_language')
          .eq('user_id', childUserId)
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

  Future<void> _fetchAvailableCourses_vut(String childUserId) async {
    try {
      final userMarksResponse = await _supabaseClient
          .from('user_marks')
          .select(
              'math_mark, math_level, math_type, home_language_mark, home_language_level, first_additional_language_mark, first_additional_language_level, second_additional_language_mark, second_additional_language_level, subject1, subject1_level, subject2, subject2_level, subject3, subject3_level, subject4, subject4_level, life_orientation_mark, life_orientation_level, home_language, first_additional_language, second_additional_language')
          .eq('user_id', childUserId)
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

  Future<void> _fetchAvailableCourses_mut(String childUserId) async {
    try {
      final userMarksResponse = await _supabaseClient
          .from('user_marks')
          .select(
              'math_mark, math_level, math_type, home_language_mark, home_language_level, first_additional_language_mark, first_additional_language_level, second_additional_language_mark, second_additional_language_level, subject1, subject1_level, subject2, subject2_level, subject3, subject3_level, subject4, subject4_level, life_orientation_mark, life_orientation_level, home_language, first_additional_language, second_additional_language')
          .eq('user_id', childUserId)
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

  Future<void> _fetchAvailableCourses_uv(String childUserId) async {
    try {
      final userMarksResponse = await _supabaseClient
          .from('user_marks')
          .select(
              'math_mark, math_level, math_type, home_language_mark, home_language_level, first_additional_language_mark, first_additional_language_level, second_additional_language_mark, second_additional_language_level, subject1, subject1_level, subject2, subject2_level, subject3, subject3_level, subject4, subject4_level, life_orientation_mark, life_orientation_level, home_language, first_additional_language, second_additional_language')
          .eq('user_id', childUserId)
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

  Future<void> _fetchAvailableCourses_uz(String childUserId) async {
    try {
      final userMarksResponse = await _supabaseClient
          .from('user_marks')
          .select(
              'math_mark, math_level, math_type, home_language_mark, home_language_level, first_additional_language_mark, first_additional_language_level, second_additional_language_mark, second_additional_language_level, subject1, subject1_level, subject2, subject2_level, subject3, subject3_level, subject4, subject4_level, life_orientation_mark, life_orientation_level, home_language, first_additional_language, second_additional_language')
          .eq('user_id', childUserId)
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

  Future<void> _fetchAvailableCourses_uct(String childUserId) async {
    try {
      final userMarksResponse = await _supabaseClient
          .from('user_marks')
          .select(
              'math_mark, math_level, math_type, home_language_mark, home_language_level, first_additional_language_mark, first_additional_language_level, second_additional_language_mark, second_additional_language_level, subject1, subject1_level, subject2, subject2_level, subject3, subject3_level, subject4, subject4_level, life_orientation_mark, life_orientation_level, home_language, first_additional_language, second_additional_language')
          .eq('user_id', childUserId)
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

  Future<void> _fetchAvailableCourses_ufs(String childUserId) async {
    try {
      final userMarksResponse = await _supabaseClient
          .from('user_marks')
          .select(
              'math_mark, math_level, math_type, home_language_mark, home_language_level, first_additional_language_mark, first_additional_language_level, second_additional_language_mark, second_additional_language_level, subject1, subject1_level, subject2, subject2_level, subject3, subject3_level, subject4, subject4_level, life_orientation_mark, life_orientation_level, home_language, first_additional_language, second_additional_language')
          .eq('user_id', childUserId)
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

  Future<void> _fetchAvailableCourses_cut(String childUserId) async {
    try {
      final userMarksResponse = await _supabaseClient
          .from('user_marks')
          .select(
              'math_mark, math_level, math_type, home_language_mark, home_language_level, first_additional_language_mark, first_additional_language_level, second_additional_language_mark, second_additional_language_level, subject1, subject1_level, subject2, subject2_level, subject3, subject3_level, subject4, subject4_level, life_orientation_mark, life_orientation_level, home_language, first_additional_language, second_additional_language')
          .eq('user_id', childUserId)
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

  Future<void> _fetchAvailableCourses_rhodes(String childUserId) async {
    try {
      final userMarksResponse = await _supabaseClient
          .from('user_marks')
          .select(
              'math_mark, math_level, math_type, home_language_mark, home_language_level, first_additional_language_mark, first_additional_language_level, second_additional_language_mark, second_additional_language_level, subject1, subject1_level, subject2, subject2_level, subject3, subject3_level, subject4, subject4_level, life_orientation_mark, life_orientation_level, home_language, first_additional_language, second_additional_language')
          .eq('user_id', childUserId)
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

  Future<void> _fetchAvailableCourses_wsu(String childUserId) async {
    try {
      final userMarksResponse = await _supabaseClient
          .from('user_marks')
          .select(
              'math_mark, math_level, math_type, home_language_mark, home_language_level, first_additional_language_mark, first_additional_language_level, second_additional_language_mark, second_additional_language_level, subject1, subject1_level, subject2, subject2_level, subject3, subject3_level, subject4, subject4_level, life_orientation_mark, life_orientation_level, home_language, first_additional_language, second_additional_language')
          .eq('user_id', childUserId)
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

  Future<void> _fetchAvailableCourses_smu(String childUserId) async {
    try {
      final userMarksResponse = await _supabaseClient
          .from('user_marks')
          .select(
              'math_mark, math_level, math_type, home_language_mark, home_language_level, first_additional_language_mark, first_additional_language_level, second_additional_language_mark, second_additional_language_level, subject1, subject1_level, subject2, subject2_level, subject3, subject3_level, subject4, subject4_level, life_orientation_mark, life_orientation_level, home_language, first_additional_language, second_additional_language')
          .eq('user_id', childUserId)
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

  Future<void> _fetchAvailableCourses_stllies(String childUserId) async {
    try {
      final userMarksResponse = await _supabaseClient
          .from('user_marks')
          .select(
              'math_mark, math_level, math_type, home_language_mark, home_language_level, first_additional_language_mark, first_additional_language_level, second_additional_language_mark, second_additional_language_level, subject1, subject1_level, subject2, subject2_level, subject3, subject3_level, subject4, subject4_level, life_orientation_mark, life_orientation_level, home_language, first_additional_language, second_additional_language')
          .eq('user_id', childUserId)
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

  Future<void> _fetchAvailableCourses_tut(String childUserId) async {
    try {
      final userMarksResponse = await _supabaseClient
          .from('user_marks')
          .select(
              'math_mark, math_level, math_type, home_language_mark, home_language_level, first_additional_language_mark, first_additional_language_level, second_additional_language_mark, second_additional_language_level, subject1, subject1_level, subject2, subject2_level, subject3, subject3_level, subject4, subject4_level, life_orientation_mark, life_orientation_level, home_language, first_additional_language, second_additional_language')
          .eq('user_id', childUserId)
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

  Future<void> _fetchAvailableCourses_uwc(String childUserId) async {
    try {
      final userMarksResponse = await _supabaseClient
          .from('user_marks')
          .select(
              'math_mark, math_level, math_type, home_language_mark, home_language_level, first_additional_language_mark, first_additional_language_level, second_additional_language_mark, second_additional_language_level, subject1, subject1_level, subject2, subject2_level, subject3, subject3_level, subject4, subject4_level, life_orientation_mark, life_orientation_level, home_language, first_additional_language, second_additional_language')
          .eq('user_id', childUserId)
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

  Future<void> _fetchAvailableCourses_ul(String childUserId) async {
    try {
      final userMarksResponse = await _supabaseClient
          .from('user_marks')
          .select(
              'math_mark, math_level, math_type, home_language_mark, home_language_level, first_additional_language_mark, first_additional_language_level, second_additional_language_mark, second_additional_language_level, subject1, subject1_level, subject2, subject2_level, subject3, subject3_level, subject4, subject4_level, life_orientation_mark, life_orientation_level, home_language, first_additional_language, second_additional_language')
          .eq('user_id', childUserId)
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

  Future<void> _fetchAvailableCourses_nmu(String childUserId) async {
    try {
      final userMarksResponse = await _supabaseClient
          .from('user_marks')
          .select(
              'math_mark, math_level, math_type, home_language_mark, home_language_level, first_additional_language_mark, first_additional_language_level, second_additional_language_mark, second_additional_language_level, subject1, subject1_level, subject2, subject2_level, subject3, subject3_level, subject4, subject4_level, life_orientation_mark, life_orientation_level, home_language, first_additional_language, second_additional_language')
          .eq('user_id', childUserId)
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

  Future<void> _fetchAvailableCourses_nwu(String childUserId) async {
    try {
      final userMarksResponse = await _supabaseClient
          .from('user_marks')
          .select(
              'math_mark, math_level, math_type, home_language_mark, home_language_level, first_additional_language_mark, first_additional_language_level, second_additional_language_mark, second_additional_language_level, subject1, subject1_level, subject2, subject2_level, subject3, subject3_level, subject4, subject4_level, life_orientation_mark, life_orientation_level, home_language, first_additional_language, second_additional_language')
          .eq('user_id', childUserId)
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

  Future<void> _fetchAvailableCourses_wits(String childUserId) async {
    try {
      final userMarksResponse = await _supabaseClient
          .from('user_marks')
          .select(
              'math_mark, math_level, math_type, home_language_mark, home_language_level, first_additional_language_mark, first_additional_language_level, second_additional_language_mark, second_additional_language_level, subject1, subject1_level, subject2, subject2_level, subject3, subject3_level, subject4, subject4_level, life_orientation_mark, life_orientation_level, home_language, first_additional_language, second_additional_language')
          .eq('user_id', childUserId)
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

  Future<void> _fetchAvailableCourses_ukzn(String childUserId) async {
    try {
      final userMarksResponse = await _supabaseClient
          .from('user_marks')
          .select(
              'math_mark, math_level, math_type, home_language_mark, home_language_level, first_additional_language_mark, first_additional_language_level, second_additional_language_mark, second_additional_language_level, subject1, subject1_level, subject2, subject2_level, subject3, subject3_level, subject4, subject4_level, life_orientation_mark, life_orientation_level, home_language, first_additional_language, second_additional_language')
          .eq('user_id', childUserId)
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

  Future<void> _fetchAvailableCourses_dut(String childUserId) async {
    try {
      final userMarksResponse = await _supabaseClient
          .from('user_marks')
          .select(
              'math_mark, math_level, math_type, home_language_mark, home_language_level, first_additional_language_mark, first_additional_language_level, second_additional_language_mark, second_additional_language_level, subject1, subject1_level, subject2, subject2_level, subject3, subject3_level, subject4, subject4_level, life_orientation_mark, life_orientation_level, home_language, first_additional_language, second_additional_language')
          .eq('user_id', childUserId)
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

  Future<void> _fetchAvailableCourses_ump(String childUserId) async {
    try {
      final userMarksResponse = await _supabaseClient
          .from('user_marks')
          .select(
              'math_mark, math_level, math_type, home_language_mark, home_language_level, first_additional_language_mark, first_additional_language_level, second_additional_language_mark, second_additional_language_level, subject1, subject1_level, subject2, subject2_level, subject3, subject3_level, subject4, subject4_level, life_orientation_mark, life_orientation_level, home_language, first_additional_language, second_additional_language')
          .eq('user_id', childUserId)
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
}
