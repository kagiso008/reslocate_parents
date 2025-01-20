import 'package:flutter/material.dart';

class SearchableSubjectList extends StatefulWidget {
  final List<String> subjects;
  final Map<String, WidgetBuilder> subjectPages;

  const SearchableSubjectList({
    super.key,
    required this.subjects,
    required this.subjectPages,
  });

  @override
  _SearchableSubjectListState createState() => _SearchableSubjectListState();
}

class _SearchableSubjectListState extends State<SearchableSubjectList> {
  final TextEditingController _searchController = TextEditingController();
  List<String> filteredSubjects = [];

  @override
  void initState() {
    super.initState();
    filteredSubjects = widget.subjects; // Initialize filtered list with all subjects
  }

  void _filterSubjects(String query) {
    if (query.isEmpty) {
      filteredSubjects = widget.subjects; // Show all subjects if the search query is empty
    } else {
      filteredSubjects = widget.subjects
          .where((subject) => subject.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: filteredSubjects.map((subject) {
                return Column(
                  children: [
                    _buildCustomCard(
                      context: context,
                      label: subject,
                      onPressed: () {
                        // Navigate to the appropriate page based on the subject
                        final pageBuilder = widget.subjectPages[subject];
                        if (pageBuilder != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: pageBuilder),
                          );
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
      elevation: 4, // Add elevation to create a shadow effect
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
