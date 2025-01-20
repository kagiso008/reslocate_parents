import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:reslocate/pastPapers/grade10IEB/Accounting/accounting.dart';
import 'package:reslocate/pastPapers/grade10IEB/Afrikaans/Afrikaans.dart';
import 'package:reslocate/pastPapers/grade10IEB/BusinessStudies/businessStudies.dart';
import 'package:reslocate/pastPapers/grade10IEB/ConsumerStudies/consumerStudies.dart';
import 'package:reslocate/pastPapers/grade10IEB/DramaticArts/dramaticArts.dart';
import 'package:reslocate/pastPapers/grade10IEB/English/english.dart';
import 'package:reslocate/pastPapers/grade10IEB/Geography/geography.dart';
import 'package:reslocate/pastPapers/grade10IEB/History/history.dart';
import 'package:reslocate/pastPapers/grade10IEB/IsiZulu/isiZulu.dart';
import 'package:reslocate/pastPapers/grade10IEB/LifeSciences/lifeSciences.dart';
import 'package:reslocate/pastPapers/grade10IEB/MathematicalLiteracy/mathsLit.dart';
import 'package:reslocate/pastPapers/grade10IEB/Mathematics/maths.dart';

class Grade10IEBPage extends StatefulWidget {
  const Grade10IEBPage({super.key});

  @override
  _Grade10IEBPageState createState() => _Grade10IEBPageState();
}

class _Grade10IEBPageState extends State<Grade10IEBPage> {
  List<String> subjects = [
    'ACCOUNTING',
    'AFRIKAANS',
    'BUSINESS STUDIES',
    'CONSUMER STUDIES',
    'DRAMATIC ARTS',
    'ENGLISH',
    'GEOGRAPHY',
    'HISTORY',
    'isiZULU',
    'LIFE SCIENCES',
    'MATHEMATICAL LITERACY',
    'MATHEMATICS',
  ];

  List<String> filteredSubjects = [];
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    filteredSubjects = subjects; // Initialize filtered subjects
  }

  void _filterSubjects(String query) {
    setState(() {
      searchQuery = query;
      filteredSubjects = subjects
          .where(
              (subject) => subject.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

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
            const Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Grade 10',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D47A1),
                    ),
                  ),
                  Text(
                    'IEB Exam Papers',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
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
          padding: EdgeInsets.all(screenWidth * 0.04), // Responsive padding
          child: Column(
            children: [
              _buildSearchBar(),
              const SizedBox(height: 10),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: List.generate(filteredSubjects.length, (index) {
                      return Column(
                        children: [
                          const SizedBox(height: 20),
                          _buildCustomCard(
                            context: context,
                            label: filteredSubjects[index],
                            onPressed: () {
                              _navigateToSubjectPage(filteredSubjects[index]);
                            },
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      onChanged: _filterSubjects,
      decoration: InputDecoration(
        labelText: 'Search subjects',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF0D47A1)),
        ),
        prefixIcon: const Icon(Icons.search, color: Color(0xFF0D47A1)),
      ),
    );
  }

  void _navigateToSubjectPage(String subject) {
    Widget page;
    switch (subject) {
      case 'ACCOUNTING':
        page = const AccountingGrade10IEBPage();
        break;
      case 'AFRIKAANS':
        page = const AfrikaansGrade10IEBPage();
        break;
      case 'BUSINESS STUDIES':
        page = const BusinessStudiesGrade10IEBPage();
        break;
      case 'CONSUMER STUDIES':
        page = const ConsumerStudiesGrade10IEBPage();
        break;
      case 'DRAMATIC ARTS':
        page = const DramaticArtsGrade10IEBPage();
        break;
      case 'ENGLISH':
        page = const EnglishGrade10IEBPage();
        break;
      case 'GEOGRAPHY':
        page = const GeographyGrade10IEBPage();
        break;
      case 'HISTORY':
        page = const HistoryGrade10IEBPage();
        break;
      case 'isiZULU':
        page = const IsiZuluGrade10IEBPage();
        break;
      case 'LIFE SCIENCES':
        page = const LifeSciencesGrade10IEBPage();
        break;
      case 'MATHEMATICAL LITERACY':
        page = const MathematicalLiteracyGrade10IEBPage();
        break;
      case 'MATHEMATICS':
        page = const MathsGrade10IEBPage();
        break;
      default:
        return; // If the subject doesn't match any case, do nothing
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  Widget _buildCustomCard({
    required BuildContext context,
    required String label,
    required VoidCallback onPressed,
  }) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0, // Add elevation to create a shadow effect
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: screenWidth * 0.9, // Responsive width for cards
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: const Color(0xFFE3F2FA), // Set the card color
          ),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
                fontWeight: FontWeight.w600,
                overflow: TextOverflow.ellipsis,
              ),
              maxLines: 1,
            ),
          ),
        ),
      ),
    );
  }
}
