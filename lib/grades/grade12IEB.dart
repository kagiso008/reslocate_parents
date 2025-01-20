import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:reslocate/pastPapers/grade12IEB/APAfrikaans/APAfrikaans.dart';
import 'package:reslocate/pastPapers/grade12IEB/Afrikaans/AfrikaansFAL.dart';
import 'package:reslocate/pastPapers/grade12IEB/AgriculturalSciences/AgriculturalScience.dart';
import 'package:reslocate/pastPapers/grade12IEB/APMath/APMath.dart';
import 'package:reslocate/pastPapers/grade12IEB/BusinessStudies/businessStudies.dart';
import 'package:reslocate/pastPapers/grade12IEB/EnglishFAL/EnglishFAL.dart';
import 'package:reslocate/pastPapers/grade12IEB/AgriculturalManagementPractices/AgriculturalManagementSciences.dart.dart';
import 'package:reslocate/pastPapers/grade12IEB/Equine%20studies/equineStudies.dart';
import 'package:reslocate/pastPapers/grade12IEB/ConsumerStudies/consumerStudies.dart';
import 'package:reslocate/pastPapers/grade12IEB/GreekSAL/greekSAL.dart';
import 'package:reslocate/pastPapers/grade12IEB/DramaticArts/dramaticArts.dart';
import 'package:reslocate/pastPapers/grade12IEB/Economics/economics.dart';
import 'package:reslocate/pastPapers/grade12IEB/frenchSAL/frenchSAL.dart';
import 'package:reslocate/pastPapers/grade12IEB/APEnglish/APEnglish.dart';
import 'package:reslocate/pastPapers/grade12IEB/History/history.dart';
import 'package:reslocate/pastPapers/grade12IEB/GermanSAL/germanSAL.dart';
import 'package:reslocate/pastPapers/grade12IEB/GujaratiFAL/gujaratiFAL.dart';
import 'package:reslocate/pastPapers/grade12IEB/HindiFAL/HindiFAL.dart';
import 'package:reslocate/pastPapers/grade12IEB/IsiXhosaFAL/isiXhosaFAL.dart';
import 'package:reslocate/pastPapers/grade12IEB/IsiZuluHL/isiZuluHL.dart';
import 'package:reslocate/pastPapers/grade12IEB/Latin/LifeOrientation.dart';
import 'package:reslocate/pastPapers/grade12IEB/LifeSciences/lifeSciences.dart';
import 'package:reslocate/pastPapers/grade12IEB/MarineSciences/marineSciences.dart';
import 'package:reslocate/pastPapers/grade12IEB/MathematicalLiteracy/mathsLit.dart';
import 'package:reslocate/pastPapers/grade12IEB/Mathematics/maths.dart';
import 'package:reslocate/pastPapers/grade12IEB/portuguese/portugueseSAL.dart';
import 'package:reslocate/pastPapers/grade12IEB/Music/music.dart';
import 'package:reslocate/pastPapers/grade12IEB/Mandarin/MandarinSAL.dart';
import 'package:reslocate/pastPapers/grade12IEB/HindiSAL/hindiSAL.dart';
import 'package:reslocate/pastPapers/grade12IEB/Sepedi/sepediHL.dart';
import 'package:reslocate/pastPapers/grade12IEB/SiswatiHL/siswatiHL.dart';
import 'package:reslocate/pastPapers/grade12IEB/SiswatiFAL/siswatiFAL.dart';
import 'package:reslocate/pastPapers/grade12IEB/Telegu/teluguSAL.dart';
import 'package:reslocate/pastPapers/grade12IEB/TechnicalSciences/technicalScience.dart';
import 'package:reslocate/pastPapers/grade12IEB/Tourism/tourism.dart';
import 'package:reslocate/pastPapers/grade12IEB/VisualCutureStudies/visualCutureStudies.dart';
import 'package:reslocate/pastPapers/grade12IEB/Urdu/Urdu.dart';

class Grade12IEBPage extends StatelessWidget {
  const Grade12IEBPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SubjectButtonsPage();
  }
}

class SubjectButtonsPage extends StatefulWidget {
  const SubjectButtonsPage({super.key});

  @override
  _SubjectButtonsPageState createState() => _SubjectButtonsPageState();
}

class _SubjectButtonsPageState extends State<SubjectButtonsPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredSubjects = [];
  final List<Map<String, dynamic>> subjects = [
    {
      'label': 'ADVANCED AFRIKAANS',
      'page': const APAfrikaansGrade12IEBPage(),
    },
    {
      'label': 'ADVANCED ENGLISH',
      'page': const APEnglishGrade12IEBPage(),
    },
    {
      'label': 'ADVANCED MATHEMATICS',
      'page': const APMathGrade12IEBPage(),
    },
    {
      'label': 'AFRIKAANS FAL',
      'page': const AfrikaansFALGrade12IEBPage(),
    },
    {
      'label': 'AGRICULTURAL MANAGEMENT',
      'page': const AgriculturalManagementPracticesIEB(),
    },
    {
      'label': 'AGRICULTURAL SCIENCE',
      'page': const AgriculturalScienceGrade12IEBPage(),
    },
    {
      'label': 'BUSINESS STUDIES',
      'page': const BusinessStudiesGrade12IEBPage(),
    },
    {
      'label': 'CONSUMER STUDIES',
      'page': const ConsumerStudiesGrade12IEBPage(),
    },
    {
      'label': 'DRAMATIC ARTS',
      'page': const DramaticArtsGrade12IEBPage(),
    },
    {
      'label': 'ECONOMICS',
      'page': const EconomicsGrade12IEBPage(),
    },
    {
      'label': 'ENGLISH FAL',
      'page': const EnglishFALGrade12IEBPage(),
    },
    {
      'label': 'EQUINE STUDIES',
      'page': const EquineStudiesGrade12IEBPage(),
    },
    {
      'label': 'FRENCH SAL',
      'page': const FrenchSALGrade12IEBPage(),
    },
    {
      'label': 'GERMAN SAL',
      'page': const GermanSALGrade12IEBPage(),
    },
    {
      'label': 'GREEK SAL',
      'page': const GreekSALGrade12IEBPage(),
    },
    {
      'label': 'GUJARATI FAL',
      'page': const GujaratiFALGrade12IEBPage(),
    },
    {
      'label': 'HINDI FAL',
      'page': const HindiFALGrade12IEBPage(),
    },
    {
      'label': 'HINDI SAL',
      'page': const HindiSALGrade12IEBPage(),
    },
    {
      'label': 'HISTORY',
      'page': const HistoryGrade12IEBPage(),
    },
    {
      'label': 'ISIZULU HOME LANGUAGE',
      'page': const IsiZuluHLGrade12IEBPage(),
    },
    {
      'label': 'ISIXHOSA FAL',
      'page': const IsiXhosaFALGrade12IEBPage(),
    },
    {
      'label': 'LATIN SAL',
      'page': const LatinSALGrade12IEBPage(),
    },
    {
      'label': 'LIFE SCIENCE',
      'page': const LifeSciencesGrade12IEBPage(),
    },
    {
      'label': 'MANDARIN SAL',
      'page': const MandarinSALGrade12IEBPage(),
    },
    {
      'label': 'MARINE SCIENCE',
      'page': const MarineSciencesGrade12IEBPage(),
    },
    {
      'label': 'MATHEMATICAL LITERACY',
      'page': const MathematicalLiteracyGrade12IEBPage(),
    },
    {
      'label': 'MATHEMATICS',
      'page': const MathsGrade12IEBPage(),
    },
    {
      'label': 'MUSIC',
      'page': const MusicGrade12IEBPage(),
    },
    {
      'label': 'PORTUGUESE SAL',
      'page': const PortugueseSALGrade12IEBPage(),
    },
    {
      'label': 'SEPEDI HL',
      'page': const SepediHLGrade12IEBPage(),
    },
    {
      'label': 'SISWATI FAL',
      'page': const SiswatiFALGrade12IEBPage(),
    },
    {
      'label': 'SISWATI HL',
      'page': const SiswatiHLGrade12IEBPage(),
    },
    {
      'label': 'TECHNICAL SCIENCES',
      'page': const TechnicalScienceGrade12IEBPage(),
    },
    {
      'label': 'TELUGU SAL',
      'page': const TeleguSALGrade12IEBPage(),
    },
    {
      'label': 'TOURISM',
      'page': const TourismGrade12IEBPage(),
    },
    {
      'label': 'URDU SAL',
      'page': const UrduSALGrade12IEBPage(),
    },
    {
      'label': 'VISUAL CULTURE STUDIES',
      'page': const VisualCultureStudiesGrade12IEBPage(),
    },
  ];

  @override
  void initState() {
    super.initState();
    _filteredSubjects = subjects;
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() {
      _filteredSubjects = subjects
          .where((subject) => subject['label']
              .toString()
              .toLowerCase()
              .contains(_searchController.text.toLowerCase()))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
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
                    'Grade 12',
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search Subjects',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                prefixIcon: const Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: _filteredSubjects.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 20),
                itemBuilder: (context, index) {
                  final subject = _filteredSubjects[index];
                  return _buildCustomCard(
                    context: context,
                    label: subject['label'] as String,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => subject['page'] as Widget,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
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
