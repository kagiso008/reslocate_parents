import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:reslocate/pastPapers/grade11/Accounting/accounting.dart';
import 'package:reslocate/pastPapers/grade11/Afrikaans/Afrikaans.dart';
import 'package:reslocate/pastPapers/grade11/AgriculturalSciences/AgriculturalScience.dart';
import 'package:reslocate/pastPapers/grade11/BusinessStudies/businessStudies.dart';
import 'package:reslocate/pastPapers/grade11/CivilTechnology/civilTechnology.dart';
import 'package:reslocate/pastPapers/grade11/ComputerApplicationsTechnology/cat.dart';
import 'package:reslocate/pastPapers/grade11/ConsumerStudies/consumerStudies.dart';
import 'package:reslocate/pastPapers/grade11/DanceStudies/danceStudies.dart';
import 'package:reslocate/pastPapers/grade11/Design/design.dart';
import 'package:reslocate/pastPapers/grade11/DramaticArts/dramaticArts.dart';
import 'package:reslocate/pastPapers/grade11/Economics/economics.dart';
import 'package:reslocate/pastPapers/grade11/ElectricalTechnology/electricalTechnology.dart';
import 'package:reslocate/pastPapers/grade11/EngineeringGraphicsAndDesign/egd.dart';
import 'package:reslocate/pastPapers/grade11/English/english.dart';
import 'package:reslocate/pastPapers/grade11/Geography/geography.dart';
import 'package:reslocate/pastPapers/grade11/History/history.dart';
import 'package:reslocate/pastPapers/grade11/HospitalityStudies/hospitalityStudies.dart';
import 'package:reslocate/pastPapers/grade11/InformationTechnology/IT.dart';
import 'package:reslocate/pastPapers/grade11/IsiXhosa/isiXhosa.dart';
import 'package:reslocate/pastPapers/grade11/LifeOrientation/LifeOrientation.dart';
import 'package:reslocate/pastPapers/grade11/LifeSciences/lifeSciences.dart';
import 'package:reslocate/pastPapers/grade11/MathematicalLiteracy/mathsLit.dart';
import 'package:reslocate/pastPapers/grade11/Mathematics/maths.dart';
import 'package:reslocate/pastPapers/grade11/MechanicalTechnology/mechinalTechnology.dart';
import 'package:reslocate/pastPapers/grade11/Music/music.dart';
import 'package:reslocate/pastPapers/grade11/PhysicalSciences/physicalSciences.dart';
import 'package:reslocate/pastPapers/grade11/ReligionStudies/religionStudies.dart';
import 'package:reslocate/pastPapers/grade11/Sesotho/sesotho.dart';
import 'package:reslocate/pastPapers/grade11/Setswana/setswana.dart';
import 'package:reslocate/pastPapers/grade11/TechnicalMathematics/technicalMath.dart';
import 'package:reslocate/pastPapers/grade11/TechnicalSciences/technicalScience.dart';
import 'package:reslocate/pastPapers/grade11/Tourism/tourism.dart';
import 'package:reslocate/pastPapers/grade11/VisualArts/visualArts.dart';

class Grade11Page extends StatefulWidget {
  const Grade11Page({super.key});

  @override
  _Grade11PageState createState() => _Grade11PageState();
}

class _Grade11PageState extends State<Grade11Page> {
  final TextEditingController _searchController = TextEditingController();
  List<String> subjects = [
    'ACCOUNTING',
    'AFRIKAANS',
    'AGRICULTURAL SCIENCE',
    'BUSINESS STUDIES',
    'CAT',
    'CIVIL TECHNOLOGY',
    'CONSUMER STUDIES',
    'DANCE STUDIES',
    'DESIGN',
    'DRAMATIC ARTS',
    'ECONOMICS',
    'ELECTRICAL TECHNOLOGY',
    'EGD',
    'ENGLISH',
    'GEOGRAPHY',
    'HISTORY',
    'HOSPITALITY STUDIES',
    'INFORMATION TECHNOLOGY',
    'isiXHOSA',
    'LIFE ORIENTATION',
    'LIFE SCIENCE',
    'MATHEMATICAL LITERACY',
    'MATHEMATICS',
    'MECHANICAL TECHNOLOGY',
    'MUSIC',
    'PHYSICAL SCIENCE',
    'RELIGION STUDIES',
    'SESOTHO',
    'SETSWANA',
    'TECHNICAL MATHEMATICS',
    'TECHNICAL SCIENCES',
    'TOURISM',
    'VISUAL ARTS',
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
                    'Grade 11',
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
          padding: EdgeInsets.all(screenWidth * 0.04), // Responsive padding
          child: Column(
            children: [
              // Search bar
              TextField(
                controller: _searchController,
                onChanged: _filterSubjects,
                decoration: InputDecoration(
                  hintText: 'Search subjects...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: filteredSubjects.map((subject) {
                      return Column(
                        children: [
                          _buildCustomCard(
                            context: context,
                            label: subject,
                            color: const Color(0xFFE3F2FA),
                            onPressed: () {
                              _navigateToSubjectPage(context, subject);
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

  void _navigateToSubjectPage(BuildContext context, String subject) {
    switch (subject) {
      case 'ACCOUNTING':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AccountingGrade11Page(),
          ),
        );
        break;
      case 'AFRIKAANS':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AfrikaansGrade11Page(),
          ),
        );
        break;
      case 'AGRICULTURAL SCIENCE':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AgriculturalScienceGrade11Page(),
          ),
        );
        break;
      case 'BUSINESS STUDIES':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const BusinessStudiesGrade11Page(),
          ),
        );
        break;
      case 'CAT':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const CATGrade11Page(),
          ),
        );
        break;
      case 'CIVIL TECHNOLOGY':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const CivilTechnologyGrade11Page(),
          ),
        );
        break;
      case 'CONSUMER STUDIES':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ConsumerStudiesGrade11Page(),
          ),
        );
        break;
      case 'DANCE STUDIES':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const DanceStudiesGrade11Page(),
          ),
        );
        break;
      case 'DESIGN':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const DesignGrade11Page(),
          ),
        );
        break;
      case 'DRAMATIC ARTS':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const DramaticArtsGrade11Page(),
          ),
        );
        break;
      case 'ECONOMICS':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const EconomicsGrade11Page(),
          ),
        );
        break;
      case 'ELECTRICAL TECHNOLOGY':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ElectricalTechnologyGrade11Page(),
          ),
        );
        break;
      case 'EGD':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const EGDGrade11Page(),
          ),
        );
        break;
      case 'ENGLISH':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const EnglishGrade11Page(),
          ),
        );
        break;
      case 'GEOGRAPHY':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const GeographyGrade11Page(),
          ),
        );
        break;
      case 'HISTORY':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const HistoryGrade11Page(),
          ),
        );
        break;
      case 'HOSPITALITY STUDIES':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const HospitalityStudiesGrade11Page(),
          ),
        );
        break;
      case 'INFORMATION TECHNOLOGY':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ITGrade11Page(),
          ),
        );
        break;
      case 'isiXHOSA':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const IsiXhosaGrade11Page(),
          ),
        );
        break;
      case 'LIFE ORIENTATION':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const LifeOrientationGrade11Page(),
          ),
        );
        break;
      case 'LIFE SCIENCE':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const LifeSciencesGrade11Page(),
          ),
        );
        break;
      case 'MATHEMATICAL LITERACY':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const MathematicalLiteracyGrade11Page(),
          ),
        );
        break;
      case 'MATHEMATICS':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const MathsGrade11Page(),
          ),
        );
        break;
      case 'MECHANICAL TECHNOLOGY':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const MechanicalTechnologyGrade11Page(),
          ),
        );
        break;
      case 'MUSIC':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const MusicGrade11Page(),
          ),
        );
        break;
      case 'PHYSICAL SCIENCE':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PhysicalSciencesGrade11Page(),
          ),
        );
        break;
      case 'RELIGION STUDIES':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ReligionStudiesGrade11Page(),
          ),
        );
        break;
      case 'SESOTHO':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SesothoGrade11Page(),
          ),
        );
        break;
      case 'SETSWANA':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SetswanaGrade11Page(),
          ),
        );
        break;
      case 'TECHNICAL MATHEMATICS':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const TechnicalMathsGrade11Page(),
          ),
        );
        break;
      case 'TECHNICAL SCIENCES':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const TechnicalScienceGrade11Page(),
          ),
        );
        break;
      case 'TOURISM':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const TourismGrade11Page(),
          ),
        );
        break;
      case 'VISUAL ARTS':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const VisualArtsGrade11Page(),
          ),
        );
        break;
      default:
        break;
    }
  }

  Widget _buildCustomCard({
    required BuildContext context,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: screenWidth * 0.9, // Responsive width for buttons
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [color, color],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0, // No elevation because we are using a shadow manually
          backgroundColor: Colors
              .transparent, // Set background to transparent to show gradient
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24),
        ),
        child: FittedBox(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  overflow: TextOverflow.ellipsis,
                ),
                maxLines: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
