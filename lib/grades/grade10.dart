import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:reslocate/pastPapers/grade10/Accounting/accounting.dart';
import 'package:reslocate/pastPapers/grade10/AgriculturalSciences/AgriculturalScience.dart';
import 'package:reslocate/pastPapers/grade10/BusinessStudies/businessStudies.dart';
import 'package:reslocate/pastPapers/grade10/Economics/economics.dart';
import 'package:reslocate/pastPapers/grade10/English/english.dart';
import 'package:reslocate/pastPapers/grade10/Geography/geography.dart';
import 'package:reslocate/pastPapers/grade10/History/history.dart';
import 'package:reslocate/pastPapers/grade10/LifeSciences/lifeSciences.dart';
import 'package:reslocate/pastPapers/grade10/MathematicalLiteracy/mathsLit.dart';
import 'package:reslocate/pastPapers/grade10/Mathematics/maths.dart';
import 'package:reslocate/pastPapers/grade10/PhysicalSciences/physicalSciences.dart';
import 'package:reslocate/pastPapers/grade10/Setswana/setswana.dart';
import 'package:reslocate/pastPapers/grade10/TechnicalMathematics/technicalMath.dart';
import 'package:reslocate/pastPapers/grade10/TechnicalSciences/technicalScience.dart';

class Grade10Page extends StatefulWidget {
  const Grade10Page({super.key});

  @override
  _Grade10PageState createState() => _Grade10PageState();
}

class _Grade10PageState extends State<Grade10Page> {
  final TextEditingController _searchController = TextEditingController();
  List<String> subjects = [
    'ACCOUNTING',
    'AGRICULTURAL SCIENCE',
    'BUSINESS STUDIES',
    'ECONOMICS',
    'ENGLISH',
    'GEOGRAPHY',
    'HISTORY',
    'LIFE SCIENCE',
    'MATHEMATICAL LITERACY',
    'MATHEMATICS',
    'PHYSICAL SCIENCE',
    'SETSWANA',
    'TECHNICAL MATHEMATICS',
    'TECHNICAL SCIENCES',
  ];

  List<String> filteredSubjects = [];

  @override
  void initState() {
    super.initState();
    filteredSubjects = subjects; // Initialize filtered list with all subjects
  }

  void _filterSubjects(String query) {
    if (query.isEmpty) {
      filteredSubjects =
          subjects; // Show all subjects if the search query is empty
    } else {
      filteredSubjects = subjects
          .where(
              (subject) => subject.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    setState(() {});
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
                    'NSC Exam Papers',
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
              // Search bar
              TextField(
                controller: _searchController,
                onChanged: _filterSubjects,
                decoration: InputDecoration(
                  hintText: 'Search subjects...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: Colors.grey.shade400,
                    ),
                  ),
                  prefixIcon: const Icon(Icons.search),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: filteredSubjects.map((subject) {
                      return Column(
                        children: [
                          _buildCustomCard(
                            context: context,
                            label: subject,
                            onPressed: () {
                              // Navigate to the appropriate page based on the subject
                              switch (subject) {
                                case 'ACCOUNTING':
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const AccountingGrade10Page(),
                                    ),
                                  );
                                  break;
                                case 'AGRICULTURAL SCIENCE':
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const AgriculturalScienceGrade10Page(),
                                    ),
                                  );
                                  break;
                                case 'BUSINESS STUDIES':
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const BusinessStudiesGrade10Page(),
                                    ),
                                  );
                                  break;
                                case 'ECONOMICS':
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const EconomicsGrade10Page(),
                                    ),
                                  );
                                  break;
                                case 'ENGLISH':
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const EnglishGrade10Page(),
                                    ),
                                  );
                                  break;
                                case 'GEOGRAPHY':
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const GeographyGrade10Page(),
                                    ),
                                  );
                                  break;
                                case 'HISTORY':
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const HistoryGrade10Page(),
                                    ),
                                  );
                                  break;
                                case 'LIFE SCIENCE':
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const LifeSciencesGrade10Page(),
                                    ),
                                  );
                                  break;
                                case 'MATHEMATICAL LITERACY':
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const MathematicalLiteracyGrade10Page(),
                                    ),
                                  );
                                  break;
                                case 'MATHEMATICS':
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const MathsGrade10Page(),
                                    ),
                                  );
                                  break;
                                case 'PHYSICAL SCIENCE':
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const PhysicalSciencesGrade10Page(),
                                    ),
                                  );
                                  break;
                                case 'SETSWANA':
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const SetswanaGrade10Page(),
                                    ),
                                  );
                                  break;
                                case 'TECHNICAL MATHEMATICS':
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const TechnicalMathsGrade10Page(),
                                    ),
                                  );
                                  break;
                                case 'TECHNICAL SCIENCES':
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const TechnicalScienceGrade10Page(),
                                    ),
                                  );
                                  break;
                                default:
                                  break;
                              }
                            },
                          ),
                          const SizedBox(height: 20),
                        ],
                      );
                    }).toList(),
                  ),
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

    return GestureDetector(
      onTap: onPressed,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: screenWidth * 0.9, // Adjust width dynamically
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [Color(0xFFE3F2FA), Color(0xFFE1F5FE)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
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
            ),
          ),
        ),
      ),
    );
  }
}
