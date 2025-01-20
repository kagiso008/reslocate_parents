import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:reslocate/pastPapers/grade11IEB/BusinessStudies/businessStudies.dart';
import 'package:reslocate/pastPapers/grade11IEB/ConsumerStudies/consumerStudies.dart';
import 'package:reslocate/pastPapers/grade11IEB/English/english.dart';
import 'package:reslocate/pastPapers/grade11IEB/French/french.dart';
import 'package:reslocate/pastPapers/grade11IEB/Geography/geography.dart';
import 'package:reslocate/pastPapers/grade11IEB/History/history.dart';
import 'package:reslocate/pastPapers/grade11IEB/IsiZulu/isiZulu.dart';
import 'package:reslocate/pastPapers/grade11IEB/LifeSciences/lifeSciences.dart';
import 'package:reslocate/pastPapers/grade11IEB/MathematicalLiteracy/mathsLit.dart';
import 'package:reslocate/pastPapers/grade11IEB/Mathematics/maths.dart';
import 'package:reslocate/pastPapers/grade11IEB/PhysicalSciences/physicalSciences.dart';
import 'package:reslocate/pastPapers/grade11IEB/VisualArts/visualArts.dart';

class Grade11IEBPage extends StatefulWidget {
  const Grade11IEBPage({super.key});

  @override
  _Grade11IEBPageState createState() => _Grade11IEBPageState();
}

class _Grade11IEBPageState extends State<Grade11IEBPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> subjects = [];
  List<Map<String, dynamic>> filteredSubjects = [];

  @override
  void initState() {
    super.initState();
    subjects = [
      {
        'label': 'BUSINESS STUDIES',
        'page': const BusinessStudiesGrade11IEBPage()
      },
      {
        'label': 'CONSUMER STUDIES',
        'page': const ConsumerStudiesGrade11IEBPage()
      },
      {'label': 'ENGLISH', 'page': const EnglishGrade11IEBPage()},
      {'label': 'FRENCH', 'page': const FrenchGrade11IEBPage()},
      {'label': 'GEOGRAPHY', 'page': const GeographyGrade11IEBPage()},
      {'label': 'HISTORY', 'page': const HistoryGrade11IEBPage()},
      {'label': 'isiZULU', 'page': const IsiZuluGrade11IEBPage()},
      {'label': 'LIFE SCIENCE', 'page': const LifeSciencesGrade11IEBPage()},
      {
        'label': 'MATHEMATICAL LITERACY',
        'page': const MathematicalLiteracyGrade11IEBPage()
      },
      {'label': 'MATHEMATICS', 'page': const MathsGrade11IEBPage()},
      {
        'label': 'PHYSICAL SCIENCE',
        'page': const PhysicalSciencesGrade11IEBPage()
      },
      {'label': 'VISUAL ARTS', 'page': const VisualArtsGrade11IEBPage()},
    ];
    filteredSubjects = subjects;
  }

  void _filterSubjects(String query) {
    setState(() {
      filteredSubjects = subjects
          .where((subject) =>
              subject['label'].toLowerCase().contains(query.toLowerCase()))
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
                    'Grade 11',
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
          padding: EdgeInsets.all(screenWidth * 0.04),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search Subjects',
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF0D47A1)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onChanged: _filterSubjects,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: filteredSubjects.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: _buildCustomCard(
                        context: context,
                        label: filteredSubjects[index]['label'],
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  filteredSubjects[index]['page'],
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
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
      elevation: 0,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: screenWidth * 0.9,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: const Color(0xFFE3F2FA),
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
