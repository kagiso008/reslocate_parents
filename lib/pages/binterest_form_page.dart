import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:reslocate/widgets/mytoast.dart';
import 'package:flutter_svg/flutter_svg.dart';

class InterestFormPage extends StatefulWidget {
  final Map<String, dynamic> house;
  final String houseName;
  final String houseId;

  const InterestFormPage({
    super.key,
    required this.house,
    required this.houseName,
    required this.houseId,
  });

  @override
  _InterestFormPageState createState() => _InterestFormPageState();
}

class _InterestFormPageState extends State<InterestFormPage> {
  final SupabaseClient _supabaseClient = Supabase.instance.client;
  Map<String, String> answers = {};

  String? selectedAmenity;
  String? selectedSafety;
  String? selectedFeature;
  String? selectedCommute;

  bool get isFormComplete =>
      selectedAmenity != null &&
      selectedSafety != null &&
      selectedFeature != null &&
      selectedCommute != null;

  Future<void> _submitInterest() async {
    final user = _supabaseClient.auth.currentUser;

    if (user != null && isFormComplete) {
      try {
        final response = await _supabaseClient.from('profiles').update({
          'nearby_amenity': selectedAmenity,
          'safety': selectedSafety,
          'important_feature': selectedFeature,
          'commute': selectedCommute,
        }).eq('id', user.id);

        MyToast.showToast(context, 'Interest saved successfully!');
        Navigator.pop(context);
      } catch (e) {
        MyToast.showToast(context, 'Error saving your interest: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 100,
        automaticallyImplyLeading: false,
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
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Student',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D47A1),
                  ),
                ),
                Text(
                  'Housing',
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
                colors: [Color(0xFF0D47A1), Color(0xFF00E4BA)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Text(
                  'Which amenity is most important to have nearby?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.05,
                    color: const Color(0xFF0D47A1),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                buildRadioQuestion(
                  options: [
                    'Public transportation',
                    'Shopping centers',
                    'Parks',
                    'Libraries'
                  ],
                  selectedOption: selectedAmenity,
                  onSelected: (value) => setState(() {
                    selectedAmenity = value;
                  }),
                ),
                const SizedBox(height: 40),
                Text(
                  'How important is the safety of the neighborhood to you?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.05,
                    color: const Color(0xFF0D47A1),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                buildRadioQuestion(
                  options: [
                    'Very important',
                    'Somewhat important',
                    'Neutral',
                    'Not important'
                  ],
                  selectedOption: selectedSafety,
                  onSelected: (value) => setState(() {
                    selectedSafety = value;
                  }),
                ),
                const SizedBox(height: 40),
                Text(
                  'Which feature is most important to you in a property?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.05,
                    color: const Color(0xFF0D47A1),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                buildRadioQuestion(
                  options: [
                    'High-speed internet',
                    'Study spaces',
                    'Security measures',
                    'Other'
                  ],
                  selectedOption: selectedFeature,
                  onSelected: (value) => setState(() {
                    selectedFeature = value;
                  }),
                ),
                const SizedBox(height: 40),
                Text(
                  'How do you prefer to commute to school or university?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.05,
                    color: const Color(0xFF0D47A1),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                buildRadioQuestion(
                  options: [
                    'Public transportation',
                    'Walking',
                    'Cycling',
                    'Driving'
                  ],
                  selectedOption: selectedCommute,
                  onSelected: (value) => setState(() {
                    selectedCommute = value;
                  }),
                ),
                const SizedBox(height: 60),
                ElevatedButton(
                  onPressed: isFormComplete ? _submitInterest : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 20),
                    backgroundColor:
                        isFormComplete ? const Color(0xFF0D47A1) : Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Submit',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildRadioQuestion({
    required List<String> options,
    required String? selectedOption,
    required Function(String) onSelected,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: options.map((option) {
        return GestureDetector(
          onTap: () => onSelected(option),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              border: Border.all(
                color: selectedOption == option
                    ? const Color(0xFF0D47A1)
                    : Colors.black26,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(12),
              color: selectedOption == option
                  ? const Color(0xFF0D47A1)
                  : Colors.white,
            ),
            child: Text(
              option,
              style: TextStyle(
                color: selectedOption == option ? Colors.white : Colors.black,
                fontSize: 16,
                fontWeight: selectedOption == option
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
