import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:reslocate/pastPapers/grade12/Accounting/accounting.dart';
import 'package:reslocate/pastPapers/grade12/Afrikaans/Afrikaans.dart';
import 'package:reslocate/pastPapers/grade12/AgriculturalSciences/AgriculturalScience.dart';
import 'package:reslocate/pastPapers/grade12/AgriculturalTechnology/AgriculturalTechnology.dart';
import 'package:reslocate/pastPapers/grade12/BusinessStudies/businessStudies.dart';
import 'package:reslocate/pastPapers/grade12/CivilTechnology/civilTechnology.dart';
import 'package:reslocate/pastPapers/grade12/AgriculturalManagementPractices/AgriculturalManagementSciences.dart.dart';
import 'package:reslocate/pastPapers/grade12/ComputerApplicationsTechnology/cat.dart';
import 'package:reslocate/pastPapers/grade12/ConsumerStudies/consumerStudies.dart';
import 'package:reslocate/pastPapers/grade12/DanceStudies/danceStudies.dart';
import 'package:reslocate/pastPapers/grade12/Design/design.dart';
import 'package:reslocate/pastPapers/grade12/DramaticArts/dramaticArts.dart';
import 'package:reslocate/pastPapers/grade12/Economics/economics.dart';
import 'package:reslocate/pastPapers/grade12/ElectricalTechnology/electricalTechnology.dart';
import 'package:reslocate/pastPapers/grade12/EngineeringGraphicsAndDesign/egd.dart';
import 'package:reslocate/pastPapers/grade12/English/english.dart';
import 'package:reslocate/pastPapers/grade12/Geography/geography.dart';
import 'package:reslocate/pastPapers/grade12/History/history.dart';
import 'package:reslocate/pastPapers/grade12/HospitalityStudies/hospitalityStudies.dart';
import 'package:reslocate/pastPapers/grade12/InformationTechnology/IT.dart';
import 'package:reslocate/pastPapers/grade12/IsiNdebele/isiNdebele.dart';
import 'package:reslocate/pastPapers/grade12/IsiXhosa/isiXhosa.dart';
import 'package:reslocate/pastPapers/grade12/IsiZulu/isiZulu.dart';
import 'package:reslocate/pastPapers/grade12/LifeOrientation/LifeOrientation.dart';
import 'package:reslocate/pastPapers/grade12/LifeSciences/lifeSciences.dart';
import 'package:reslocate/pastPapers/grade12/MarineSciences/marineSciences.dart';
import 'package:reslocate/pastPapers/grade12/MathematicalLiteracy/mathsLit.dart';
import 'package:reslocate/pastPapers/grade12/Mathematics/maths.dart';
import 'package:reslocate/pastPapers/grade12/MechanicalTechnology/mechinalTechnology.dart';
import 'package:reslocate/pastPapers/grade12/Music/music.dart';
import 'package:reslocate/pastPapers/grade12/PhysicalSciences/physicalSciences.dart';
import 'package:reslocate/pastPapers/grade12/ReligionStudies/religionStudies.dart';
import 'package:reslocate/pastPapers/grade12/Sepedi/sepedi.dart';
import 'package:reslocate/pastPapers/grade12/Sesotho/sesotho.dart';
import 'package:reslocate/pastPapers/grade12/Setswana/setswana.dart';
import 'package:reslocate/pastPapers/grade12/Siswati/siswati.dart';
import 'package:reslocate/pastPapers/grade12/SouthAfricanSignLanguage/sign.dart';
import 'package:reslocate/pastPapers/grade12/TechnicalMathematics/technicalMath.dart';
import 'package:reslocate/pastPapers/grade12/TechnicalSciences/technicalScience.dart';
import 'package:reslocate/pastPapers/grade12/Tshivenda/tshivenda.dart';
import 'package:reslocate/pastPapers/grade12/Xitsonga/xitsonga.dart';

class Grade12Page extends StatelessWidget {
  const Grade12Page({super.key});

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
    {'label': 'ACCOUNTING', 'page': const AccountingGrade12Page()},
    {'label': 'AFRIKAANS', 'page': const AfrikaansGrade12Page()},
    {
      'label': 'AGRICULTURAL MANAGEMENT',
      'page': const AgriculturalManagementPractices()
    },
    {
      'label': 'AGRICULTURAL SCIENCE',
      'page': const AgriculturalScienceGrade12Page()
    },
    {
      'label': 'AGRICULTURAL TECHNOLOGY',
      'page': const AgriculturalTechnologyGrade12Page()
    },
    {'label': 'BUSINESS STUDIES', 'page': const BusinessStudiesGrade12Page()},
    {'label': 'CAT', 'page': const CATGrade12Page()},
    {'label': 'CIVIL TECHNOLOGY', 'page': const CivilTechnologyGrade12Page()},
    {'label': 'CONSUMER STUDIES', 'page': const ConsumerStudiesGrade12Page()},
    {'label': 'DANCE STUDIES', 'page': const DanceStudiesGrade12Page()},
    {'label': 'DESIGN', 'page': const DesignGrade12Page()},
    {'label': 'DRAMATIC ARTS', 'page': const DramaticArtsGrade12Page()},
    {'label': 'ECONOMICS', 'page': const EconomicsGrade12Page()},
    {
      'label': 'ELECTRICAL TECHNOLOGY',
      'page': const ElectricalTechnologyGrade12Page()
    },
    {'label': 'EGD', 'page': const EGDGrade12Page()},
    {'label': 'ENGLISH', 'page': const EnglishGrade12Page()},
    {'label': 'GEOGRAPHY', 'page': const GeographyGrade12Page()},
    {'label': 'HISTORY', 'page': const HistoryGrade12Page()},
    {
      'label': 'HOSPITALITY STUDIES',
      'page': const HospitalityStudiesGrade12Page()
    },
    {'label': 'INFORMATION TECHNOLOGY', 'page': const ITGrade12Page()},
    {'label': 'isiNDEBELE', 'page': const IsiNdebeleGrade12Page()},
    {'label': 'isiXHOSA', 'page': const IsiXhosaGrade12Page()},
    {'label': 'isiZULU', 'page': const IsiZuluGrade12Page()},
    {'label': 'LIFE ORIENTATION', 'page': const LifeOrientationGrade12Page()},
    {'label': 'LIFE SCIENCES', 'page': const LifeSciencesGrade12Page()},
    {'label': 'MARINE SCIENCE', 'page': const MarineSciencesGrade12Page()},
    {
      'label': 'MATHEMATICAL LITERACY',
      'page': const MathematicalLiteracyGrade12Page()
    },
    {'label': 'MATHEMATICS', 'page': const MathsGrade12Page()},
    {
      'label': 'MECHANICAL TECHNOLOGY',
      'page': const MechanicalTechnologyGrade12Page()
    },
    {'label': 'MUSIC', 'page': const MusicGrade12Page()},
    {'label': 'PHYSICAL SCIENCE', 'page': const PhysicalSciencesGrade12Page()},
    {'label': 'RELIGION STUDIES', 'page': const ReligionStudiesGrade12Page()},
    {'label': 'SEPEDI', 'page': const SepediGrade12Page()},
    {'label': 'SESOTHO', 'page': const SesothoGrade12Page()},
    {'label': 'SETSWANA', 'page': const SetswanaGrade12Page()},
    {'label': 'SISWATI', 'page': const SiswatiGrade12Page()},
    {'label': 'SOUTH AFRICAN SL', 'page': const SASLGrade12Page()},
    {
      'label': 'TECHNICAL MATHEMATICS',
      'page': const TechnicalMathsGrade12Page()
    },
    {
      'label': 'TECHNICAL SCIENCES',
      'page': const TechnicalScienceGrade12Page()
    },
    {'label': 'XITSONGA', 'page': const XitsongaGrade12Page()},
    {'label': 'TSHIVENDA', 'page': const TshivendaGrade12Page()},
    // Add more subjects as needed
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Subjects',
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
