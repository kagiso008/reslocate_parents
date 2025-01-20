import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:reslocate/lists/search.dart';
import 'package:reslocate/lists/subjects.dart';
import 'package:reslocate/pages/careerguidance.dart';
import 'package:reslocate/pages/chat.dart';
import 'package:reslocate/pages/college_matches_page.dart';
import 'package:reslocate/pages/gradeSearchpage.dart';
import 'package:reslocate/pages/matchesPage.dart';
import 'package:reslocate/pages/past_papers.dart';
import 'package:reslocate/pages/private_college_search.dart';
import 'package:reslocate/pages/profile_page.dart';
import 'package:reslocate/pages/bookmarks.dart'; // Empty bookmarks page
import 'package:reslocate/pages/quiz_game.dart';
import 'package:reslocate/pages/housing_listings_page.dart';
import 'package:reslocate/pages/scholarshipsPage.dart';
import 'package:reslocate/pages/subjectSearchpage.dart';
import 'package:reslocate/pages/unversitySearch.dart';
import 'package:reslocate/widgets/mytoast.dart';
import 'package:reslocate/widgets/navBar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:reslocate/pages/login_page.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime? _lastBackPressedTime;
  String userName = '';
  String userEmail = '';
  String profileImageUrl = '';
  final int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;

    if (userId != null) {
      // Query the 'profiles' table to get the user's details
      final response = await Supabase.instance.client
          .from('profiles')
          .select('first_name, phone_number, profile_picture')
          .eq('id', userId)
          .single();

      if (response.isNotEmpty) {
        setState(() {
          userName = response['first_name'] ?? 'User'; // Fallback name
          userEmail =
              response['phone_number'] ?? 'user@example.com'; // Fallback email
          // Ensure the profile picture URL is constructed correctly
          profileImageUrl = Supabase.instance.client.storage
              .from('profiles')
              .getPublicUrl('profile_images/${response['profile_picture']}');
        });
      } else {
        // Handle error (e.g., show a Snackbar or log)
        print('Error fetching user data: $response');
      }
    }
  }

  // Handle BottomNavigationBar tap event
  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    switch (index) {
      case 0:
        // Navigate to Home page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
        break;
      case 1:
        // Navigate to Chat Screen page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ChatScreen()),
        );
        break;
      case 2:
        // Navigate to Bookmarks page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const BookmarksPage()),
        );
        break;
      case 3:
        // Navigate to Profile page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ProfilePage()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        DateTime currentTime = DateTime.now();

        // If the back button is pressed twice within 2 seconds, exit the page
        if (_lastBackPressedTime == null ||
            currentTime.difference(_lastBackPressedTime!) >
                const Duration(seconds: 2)) {
          _lastBackPressedTime = currentTime;
          MyToast.showToast(context, 'Press back again to exit');
          return false; // Stay on the page for the first tap
        }

        // If the user presses back within 2 seconds, exit the page
        return true; // Exit the page
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: const SafeArea(child: HomePageContent()), // Default content
        bottomNavigationBar: CustomBottomNavigationBar(
          selectedIndex: _selectedIndex,
          onItemTapped: _onItemTapped,
        ),
      ),
    );
  }
}

// Content for the HomePage (Home)
class HomePageContent extends StatefulWidget {
  const HomePageContent({super.key});

  @override
  _HomePageContentState createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentPage);
    _startAutoScroll();
    _fetchUserFirstName();
    _fetchProfilePicture();
  }

  Future<void> _fetchProfilePicture() async {
    final user =
        Supabase.instance.client.auth.currentUser; // Get the current user
    if (user != null) {
      final response = await Supabase.instance.client
          .from('profiles') // Querying the 'profiles' table
          .select(
              'profile_picture') // Assuming your profile picture URL is stored in the 'profile_pic_url' field
          .eq('id', user.id) // Find the record for the current user
          .single(); // Retrieve a single record

      if (response.isNotEmpty) {
        setState(() {
          profilePicUrl =
              response['profile_picture']; // Set the profile picture URL
        });
      } else {
        print('Error fetching profile picture: $response');
      }
    }
  }

  late PageController _pageController;
  int _currentPage = 0;
  late Timer _timer;
  String _userFirstName = '';
  String? profilePicUrl; // Variable to hold the profile picture URL

  Future<void> _fetchUserFirstName() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      final response = await Supabase.instance.client
          .from('profiles')
          .select('first_name')
          .eq('id', user.id)
          .single();

      if (response.isNotEmpty) {
        setState(() {
          _userFirstName = response['first_name'] ?? '';
        });
      }
    }
  }

  // List of SVG paths for the slider images
  final List<String> _sliderImages = [
    'assets/images/slider_1.svg',
    'assets/images/slider_2.svg',
    'assets/images/slider_3.svg',
    'assets/images/slider_4.svg',
    'assets/images/slider_5.svg',
    'assets/images/slider_6.svg',
  ];

  // List of dummy messages for each slider
  final List<Map<String, String>> _sliderMessages = [
    {'heading': 'Discover', 'message': 'The best universities for you.'},
    {
      'heading': 'Explore',
      'message': 'TVET colleges that align with your goals.'
    },
    {'heading': 'Find', 'message': 'Financial aid to support your journey.'},
    {'heading': 'Access', 'message': 'Past exam papers to help you excel.'},
    {'heading': 'Ask', 'message': 'For homework assistance from our AI Tutor.'},
    {
      'heading': 'Verify',
      'message': 'Accredited Student Housing and Private colleges.'
    }
  ];

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_currentPage < _sliderImages.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        final isTablet =
            constraints.maxWidth >= 600 && constraints.maxWidth < 1024;

        return Padding(
          padding: const EdgeInsets.only(
            top: 20.0, // Padding for the top
            left: 20.0, // Padding for the left
            right: 20.0, // Padding for the right
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4.0),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color.fromARGB(200, 227, 242, 250),
                                ),
                                child: IconButton(
                                  icon: profilePicUrl != null
                                      ? CircleAvatar(
                                          backgroundImage: NetworkImage(
                                              profilePicUrl!), // Display profile picture
                                          radius:
                                              25, // Set radius to match icon size
                                        )
                                      : const Icon(Icons.person_outline,
                                          size:
                                              36), // Fallback icon if profile picture is not available
                                  onPressed: () {
                                    // Open drawer on press
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const ProfilePage()),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Hi, $_userFirstName!',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0D47A1),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                    height: 16), // Space between the name/icons and search bar

                Autocomplete<String>(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text.isEmpty) {
                      return const Iterable<String>.empty();
                    }

                    // Combine search, grades, and uniqueSubjects lists for searching
                    final List<String> combinedList = [
                      ...search,
                      ...grades,
                      ...uniqueSubjects
                    ];

                    return combinedList.where((String option) {
                      return option
                          .toLowerCase()
                          .contains(textEditingValue.text.toLowerCase());
                    });
                  },
                  fieldViewBuilder: (BuildContext context,
                      TextEditingController textEditingController,
                      FocusNode focusNode,
                      VoidCallback onFieldSubmitted) {
                    return TextField(
                      controller: textEditingController,
                      focusNode: focusNode,
                      keyboardType:
                          TextInputType.text, // Set the keyboard type to text
                      decoration: InputDecoration(
                        hintText: 'Find Universities, colleges or past papers',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        prefixIcon: const Icon(Icons.search),
                      ),
                      onSubmitted: (String value) {
                        // Trigger the onSelected when the search key is pressed
                        if (search.any((option) =>
                            option.toLowerCase() == value.toLowerCase())) {
                          onFieldSubmitted(); // Call onFieldSubmitted to show selected item
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  UniversitySearchPage(searchQuery: value),
                            ),
                          );
                        } else if (grades.any((option) =>
                            option.toLowerCase() == value.toLowerCase())) {
                          onFieldSubmitted(); // Call onFieldSubmitted to show selected item
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  GradeSearchPage(searchQuery: value),
                            ),
                          );
                        } else if (uniqueSubjects.any((option) =>
                            option.toLowerCase() == value.toLowerCase())) {
                          onFieldSubmitted(); // Call onFieldSubmitted to show selected item
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  SubjectSearchPage(searchQuery: value),
                            ),
                          );
                        } else {
                          // Optionally, show a message or do something if no match is found
                          MyToast.showToast(
                              context, 'No matches found for "$value"');
                        }
                      },
                    );
                  },
                  optionsViewBuilder: (BuildContext context,
                      void Function(String) onSelected,
                      Iterable<String> options) {
                    return Align(
                      alignment: Alignment.topLeft,
                      child: Material(
                        elevation: 4.0,
                        color: Colors.white,
                        shadowColor: Colors.black26,
                        borderRadius: BorderRadius.circular(8.0),
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: 390,
                            maxHeight: options.length * 50.0 > 200.0
                                ? 200.0
                                : options.length * 50.0,
                          ),
                          child: Theme(
                            data: Theme.of(context).copyWith(
                              scrollbarTheme: ScrollbarThemeData(
                                thumbColor: WidgetStateProperty.all(
                                  Colors.grey[400],
                                ),
                                thickness: WidgetStateProperty.all(6.0),
                                radius: const Radius.circular(3.0),
                                thumbVisibility: WidgetStateProperty.all(true),
                                trackVisibility: WidgetStateProperty.all(true),
                                trackColor: WidgetStateProperty.all(
                                  Colors.grey[200],
                                ),
                              ),
                            ),
                            child: RawScrollbar(
                              radius: const Radius.circular(3.0),
                              thickness: 6.0,
                              thumbVisibility: true,
                              trackVisibility: true,
                              child: ListView.builder(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                itemCount: options.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final String option =
                                      options.elementAt(index);
                                  return InkWell(
                                    onTap: () => onSelected(option),
                                    child: Container(
                                      padding: const EdgeInsets.fromLTRB(
                                          16.0, 12.0, 24.0, 12.0),
                                      child: Text(
                                        option,
                                        style: const TextStyle(
                                          fontSize: 15.0,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  onSelected: (String selection) {
                    // Navigate based on the selection
                    if (search.any((option) =>
                        option.toLowerCase() == selection.toLowerCase())) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              UniversitySearchPage(searchQuery: selection),
                        ),
                      );
                    } else if (grades.any((option) =>
                        option.toLowerCase() == selection.toLowerCase())) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              GradeSearchPage(searchQuery: selection),
                        ),
                      );
                    } else if (uniqueSubjects.any((option) =>
                        option.toLowerCase() == selection.toLowerCase())) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              SubjectSearchPage(searchQuery: selection),
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 16),

                SizedBox(
                  height: isMobile
                      ? 200
                      : isTablet
                          ? 300
                          : 400,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      PageView.builder(
                        controller: _pageController,
                        itemCount: _sliderImages.length,
                        onPageChanged: (index) {
                          setState(() {
                            _currentPage = index;
                          });
                        },
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 0),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE3F2FA),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  // The SVG image on the left
                                  SvgPicture.asset(
                                    _sliderImages[index],
                                    width: isMobile
                                        ? 100
                                        : isTablet
                                            ? 150
                                            : 200,
                                    height: isMobile
                                        ? 100
                                        : isTablet
                                            ? 150
                                            : 200,
                                  ),
                                  const SizedBox(width: 16),

                                  // The text message on the right
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          _sliderMessages[index]['heading']!,
                                          style: TextStyle(
                                            fontSize: isMobile
                                                ? 20
                                                : isTablet
                                                    ? 25
                                                    : 30,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          _sliderMessages[index]['message']!,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                DotsIndicator(
                  dotsCount: _sliderImages.length,
                  position: _currentPage,
                ),
                const SizedBox(height: 20),

                const Align(
                  alignment: Alignment.center,
                  child: Text(
                    "My Matches",
                    style: TextStyle(
                      color: Color(0xFF0D47A1),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Replace the existing Column of buttons with this:
                Column(
                  children: [
                    // First row
                    Row(
                      children: [
                        Expanded(
                          child: _buildCustomButton(
                            context: context,
                            label: 'Universities',
                            svgPath: 'assets/images/university.svg',
                            color: Colors.lightBlue,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const UniversitiesPage(),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 16), // Spacing between buttons
                        Expanded(
                          child: _buildCustomButton(
                            context: context,
                            label: 'TVET',
                            svgPath: 'assets/images/tvetColleges.svg',
                            color: Colors.lightBlue,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const CollegeMatchesPage(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16), // Spacing between rows
                    // Second row
                    Row(
                      children: [
                        Expanded(
                          child: _buildCustomButton(
                            context: context,
                            label: 'Scholarships',
                            svgPath: 'assets/images/scholarships.svg',
                            color: Colors.lightBlue,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const ScholarshipsPage(),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 16), // Spacing between buttons
                        Expanded(
                          child: _buildCustomButton(
                            context: context,
                            label: 'Past Papers',
                            svgPath: 'assets/images/pastPapers.svg',
                            color: Colors.lightBlue,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const PastPapers(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Keep the remaining buttons in a single column
                    const Align(
                      alignment: Alignment.center,
                      child: Text(
                        "Education",
                        style: TextStyle(
                          color: Color(0xFF0D47A1),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildCustomButton(
                      context: context,
                      label: 'AI Tutor',
                      svgPath: 'assets/images/consultant.svg',
                      color: Colors.lightBlue,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ChatScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildCustomButton(
                      context: context,
                      label: 'SA Quiz',
                      svgPath: 'assets/images/choose.svg',
                      color: Colors.lightBlue,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QuizApp(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Align(
                  alignment: Alignment.center,
                  child: Text(
                    "Private Colleges",
                    style: TextStyle(
                      color: Color(0xFF0D47A1),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildCustomButton(
                  context: context,
                  label: 'College Search',
                  svgPath: 'assets/images/folder.svg',
                  color: Colors.lightBlue,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SearchPage(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                const Align(
                  alignment: Alignment.center,
                  child: Text(
                    "Careers",
                    style: TextStyle(
                      color: Color(0xFF0D47A1),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildCustomButton(
                  context: context,
                  label: 'Career Assessment',
                  svgPath: 'assets/images/housing.svg',
                  color: Colors.lightBlue,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CareerGuidanceForm(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                const Align(
                  alignment: Alignment.center,
                  child: Text(
                    "Accomodation",
                    style: TextStyle(
                      color: Color(0xFF0D47A1),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildCustomButton(
                  context: context,
                  label: 'Student Housing',
                  svgPath: 'assets/images/housing.svg',
                  color: Colors.lightBlue,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HousingListingsPage(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}

class FullScreenGallery extends StatelessWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const FullScreenGallery(
      {super.key, required this.imageUrls, required this.initialIndex});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255), // Pure white
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 100,
        automaticallyImplyLeading: false, // Disable default leading button
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back,
                  color: Color(0xFF0D47A1)), // Custom back button
              onPressed: () {
                Navigator.pop(context); // Navigate back
              },
            ),
            SvgPicture.asset(
              'assets/images/reslocate_logo.svg', // Replace with the correct path to your logo
              height: 50,
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Full Screen View',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D47A1),
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
                begin: Alignment.center,
                end: Alignment.centerRight,
              ),
            ),
          ),
        ),
      ),
      body: PhotoViewGallery.builder(
        itemCount: imageUrls.length,
        builder: (context, index) {
          return PhotoViewGalleryPageOptions(
            imageProvider: NetworkImage(imageUrls[index]),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 2,
          );
        },
        scrollPhysics: const BouncingScrollPhysics(),
        backgroundDecoration: const BoxDecoration(
          color: Colors.black,
        ),
        pageController: PageController(initialPage: initialIndex),
      ),
    );
  }
}

// Custom Button Widget with SVG Image and label above
Widget _buildCustomButton({
  required BuildContext context,
  required String label,
  required Color color,
  required VoidCallback onPressed,
  String? svgPath,
}) {
  return SizedBox(
    width: MediaQuery.of(context).size.width, // Full width
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFE3F2FA),
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (svgPath != null)
            SvgPicture.asset(
              svgPath,
              width: 40,
              height: 40,
            ),
          if (svgPath != null)
            const SizedBox(height: 8), // Space between icon and text
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}

class CustomDrawer extends StatelessWidget {
  final String userName;
  final String userEmail;
  final String profileImageUrl;

  const CustomDrawer({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.profileImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        // Ensures the drawer content is placed properly on the screen
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Custom header with profile picture or logo
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              color:
                  const Color(0xFF0D47A1), // Custom background color for header
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome, $userName', // Dynamic user name
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        userEmail, // Dynamic email
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Buttons with icons and better padding

            const Spacer(), // Pushes the rest of the content up

            // Sign out button at the bottom
            ListTile(
              leading: const Icon(Icons.exit_to_app, color: Colors.red),
              title: const Text('Sign Out'),
              onTap: () {
                _signOut;
                MyToast.showToast(context, "Logged Out successfully");
                Navigator.pushReplacement(
                  // ignore: use_build_context_synchronously
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
              },
            ),

            // Add some padding at the bottom to make sure the button is not too close to the bottom edge
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// Sign out method
Future<void> _signOut(BuildContext context) async {
  try {
    await Supabase.instance.client.auth.signOut();
    Navigator.pushReplacement(
      // ignore: use_build_context_synchronously
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  } on AuthException catch (error) {
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error.message), backgroundColor: Colors.red),
    );
  } catch (error) {
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Unexpected error occurred'),
        backgroundColor: Colors.red,
      ),
    );
  }
}

// DotsIndicator Widget
class DotsIndicator extends StatelessWidget {
  final int dotsCount;
  final int position;

  const DotsIndicator({
    super.key,
    required this.dotsCount,
    required this.position,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(dotsCount, (index) {
        return Container(
          width: 10.0,
          height: 10.0,
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: position == index ? const Color(0xFF0D47A1) : Colors.grey,
            boxShadow: [
              BoxShadow(
                color: position == index
                    ? const Color(0xFF0D47A1).withOpacity(0.3)
                    : Colors.transparent, // No shadow for inactive dots
                blurRadius: 10.0, // Controls the blur radius for the glow
                spreadRadius: 2.0, // Controls how much the glow spreads
              ),
            ],
          ),
        );
      }),
    );
  }
}
