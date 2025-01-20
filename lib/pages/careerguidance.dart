import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:reslocate/pages/homepage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Get Supabase client instance
final supabase = Supabase.instance.client;

class CareerGuidanceForm extends StatefulWidget {
  const CareerGuidanceForm({super.key});

  @override
  _CareerGuidanceFormState createState() => _CareerGuidanceFormState();
}

class _CareerGuidanceFormState extends State<CareerGuidanceForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _explainController = TextEditingController();
  bool _showExplanationField = false;
  bool _isLoading = false;

  Map<String, dynamic> _formData = {
    'familySupport': null,
    'workforceWorries': null,
    'internetAccess': null,
    'softSkills': null,
    'softSkillsExplanation': '',
    'libraryVisits': null,
    'schoolLibrary': null,
    'computerLab': null,
  };

  final Map<String, String> _questionLabels = {
    'familySupport':
        'Do you have access to academic support from family members?',
    'workforceWorries':
        'What are your biggest concerns about entering the workforce after high school?',
    'internetAccess':
        'Do you have access to a reliable internet connection at home?',
    'softSkills':
        'What soft skills do you think are most important for future success?',
    'libraryVisits': 'How often do you visit a public library?',
    'schoolLibrary':
        'Does your high school have a well-equipped library with a variety of academic resources?',
    'computerLab':
        'Does your high school have a computer lab with reliable internet access for student use?',
  };

  final Map<String, List<String>> _dropdownOptions = {
    'workforceWorries': [
      'Finding a job that matches my skills and interests',
      'Lack of work experience',
      'Unpreparedness for the interview process',
      'Competition for jobs',
      'Salary and benefits'
    ],
    'libraryVisits': ['Never', 'Occasionally', 'Frequently'],
    'softSkills': [
      'Communication (written and verbal)',
      'Teamwork and collaboration',
      'Problem-solving and critical thinking',
      'Adaptability and lifelong learning',
      'Time management and organization',
      'Leadership and initiative',
      'Creativity and innovation'
    ],
  };
  @override
  void initState() {
    super.initState();
    _checkExistingResponses();
  }

  @override
  void dispose() {
    _explainController.dispose();
    super.dispose();
  }

  Future<void> _checkExistingResponses() async {
    setState(() => _isLoading = true);
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      final response = await supabase
          .from('career_guidance_responses')
          .select()
          .eq('user_id', user.id)
          .single();

      if (mounted) {
        setState(() {
          _formData = {
            'familySupport': response['family_support'],
            'workforceWorries': response['workforce_worries'],
            'internetAccess': response['internet_access'],
            'softSkills': response['soft_skills']?[0],
            'softSkillsExplanation': response['soft_skills_explanation'],
            'libraryVisits': response['library_visits'],
            'schoolLibrary': response['school_library'],
            'computerLab': response['computer_lab'],
          };

          if (response['soft_skills_explanation'] != null) {
            _explainController.text = response['soft_skills_explanation'];
            _showExplanationField = true;
          }
        });
      }
    } catch (e) {
      debugPrint('No existing responses found: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: _buildForm(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      toolbarHeight: 100,
      automaticallyImplyLeading: false,
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF0D47A1)),
            onPressed: _showExitConfirmationDialog,
          ),
          SvgPicture.asset('assets/images/reslocate_logo.svg', height: 50),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Career Guidance Form',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D47A1),
              ),
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
    );
  }

  Future<void> _showExitConfirmationDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Exit Form?'),
          content: const Text(
              'Your progress will be lost. Are you sure you want to exit?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Exit'),
            ),
          ],
        );
      },
    );

    if (result ?? false) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    }
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(),
            const SizedBox(height: 20),
            ..._questionLabels.entries.map((entry) {
              if (entry.key == 'softSkills') {
                return Column(
                  children: [
                    _buildDropdownQuestion(entry.key, entry.value),
                    if (_showExplanationField) _buildExplanationField(),
                  ],
                );
              }
              if (_dropdownOptions.containsKey(entry.key)) {
                return _buildDropdownQuestion(entry.key, entry.value);
              }
              return _buildYesNoQuestion(entry.key, entry.value);
            }),
            const SizedBox(height: 24),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();

    bool isComplete = _formData.entries
        .where((entry) => entry.key != 'softSkillsExplanation')
        .every((entry) => entry.value != null);

    if (!isComplete) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please answer all questions'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      final formattedData = {
        'user_id': user.id,
        'family_support': _formData['familySupport'],
        'workforce_worries': _formData['workforceWorries'],
        'internet_access': _formData['internetAccess'],
        'soft_skills': _formData['softSkills'] is List
            ? _formData['softSkills']
            : [_formData['softSkills']],
        'soft_skills_explanation': _formData['softSkillsExplanation'],
        'library_visits': _formData['libraryVisits'],
        'school_library': _formData['schoolLibrary'],
        'computer_lab': _formData['computerLab'],
        'submission_platform': 'mobile',
        'form_version': 1,
      };

      await supabase
          .from('career_guidance_responses')
          .upsert(formattedData, onConflict: 'user_id');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Form submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        Future.delayed(const Duration(seconds: 1), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        });
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting form: ${error.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Career Readiness Survey',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D47A1),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Please answer the following questions about your career readiness and access to resources during high school.',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExplanationField() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextFormField(
          controller: _explainController,
          decoration: const InputDecoration(
            labelText: 'Please explain why you chose these soft skills',
            border: OutlineInputBorder(),
            alignLabelWithHint: true,
          ),
          maxLines: 3,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please provide an explanation';
            }
            return null;
          },
          onSaved: (value) {
            _formData['softSkillsExplanation'] = value;
          },
        ),
      ),
    );
  }

  Widget _buildYesNoQuestion(String key, String question) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildRadioOption(key, true, 'Yes'),
                const SizedBox(width: 20),
                _buildRadioOption(key, false, 'No'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRadioOption(String key, bool value, String label) {
    return Expanded(
      child: RadioListTile<bool>(
        title: Text(label),
        value: value,
        groupValue: _formData[key],
        onChanged: (bool? newValue) {
          setState(() {
            _formData[key] = newValue;
          });
        },
        activeColor: const Color(0xFF0D47A1),
        contentPadding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildDropdownQuestion(String key, String question) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            LayoutBuilder(
              builder: (context, constraints) {
                return DropdownButtonFormField<String>(
                  value: _formData[key],
                  isExpanded: true, // Makes the dropdown take full width
                  itemHeight: null, // Allows items to wrap
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    constraints: BoxConstraints(
                      maxWidth: constraints.maxWidth,
                    ),
                  ),
                  menuMaxHeight: MediaQuery.of(context).size.height *
                      0.4, // Limits menu height to 40% of screen
                  items: _dropdownOptions[key]!.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth: constraints.maxWidth -
                              42, // Account for padding and icon
                        ),
                        child: Text(
                          value,
                          style: const TextStyle(fontSize: 14),
                          softWrap: true,
                          overflow: TextOverflow.visible,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _formData[key] = newValue;
                      if (key == 'softSkills') {
                        _showExplanationField = newValue != null;
                      }
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select an option';
                    }
                    return null;
                  },
                  icon: const Icon(Icons.arrow_drop_down),
                  iconSize: 24,
                  selectedItemBuilder: (BuildContext context) {
                    return _dropdownOptions[key]!.map((String value) {
                      return Container(
                        constraints: BoxConstraints(
                          maxWidth: constraints.maxWidth - 42,
                        ),
                        child: Text(
                          value,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      );
                    }).toList();
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Center(
      child: ElevatedButton(
        onPressed: _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0D47A1),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text(
          'Submit',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
