import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:reslocate/main.dart';
import 'package:reslocate/pages/bookmarks.dart';
import 'package:reslocate/pages/chat.dart';
import 'package:reslocate/pages/editProfile.dart';
import 'package:reslocate/pages/homepage.dart';
import 'package:reslocate/pages/login_page.dart';
import 'package:reslocate/widgets/loadingAnimation.dart';
import 'package:reslocate/widgets/mytoast.dart';
import 'package:reslocate/widgets/navBar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final SupabaseClient _supabaseClient = Supabase.instance.client;
  bool isLoading = true;
  Map<String, dynamic> profileData = {};
  Map<String, dynamic> marksData = {};
  final int _selectedIndex = 3;

  final ImagePicker _picker = ImagePicker();
  // URL for default profile picture (from Supabase bucket)
  final String defaultProfileUrl =
      'https://sjqlnrztidffvuapbijf.supabase.co/storage/v1/object/public/profiles/profile_picture.webp';

  @override
  void initState() {
    super.initState();
    _initPage();
  }

  Future<void> _initPage() async {
    // Show loading animation for at least 3 seconds
    await _fetchProfileData();
    await Future.delayed(const Duration(seconds: 3));
  }

  Future<void> _fetchProfileData() async {
    try {
      final response = await _supabaseClient
          .from('profiles')
          .select()
          .eq('id', _supabaseClient.auth.currentUser!.id)
          .single();
      setState(() {
        profileData = response;
        isLoading = false;
      });
      await _fetchMarksData(); // Fetch marks data after profile data
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching profile data: $error')),
      );
    }
  }

  Future<void> _fetchMarksData() async {
    try {
      final response = await _supabaseClient
          .from('user_marks')
          .select()
          .eq('user_id', _supabaseClient.auth.currentUser!.id)
          .single();
      setState(() {
        marksData = response; // Store marks data
      });
    } catch (error) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching marks data: $error')),
      );
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      // Upload the image to Supabase Storage
      String? imageUrl = await _uploadImageToSupabase(image.path);
      if (imageUrl != null) {
        // Update the profile with the new image URL
        await _updateProfilePicture(imageUrl);
      }
    }
  }

  Future<String?> _uploadImageToSupabase(String imagePath) async {
    try {
      final file = File(imagePath);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName =
          'profile_images/${_supabaseClient.auth.currentUser!.id}_$timestamp.jpg';

      // Upload the image
      final response =
          await _supabaseClient.storage.from('profiles').upload(fileName, file);

      // Get the public URL
      return _supabaseClient.storage.from('profiles').getPublicUrl(fileName);
    } catch (error) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading image: $error')),
      );
    }
    return null;
  }

  Future<void> _updateProfilePicture(String imageUrl) async {
    try {
      final oldFileName =
          'profile_images/${_supabaseClient.auth.currentUser!.id}.jpg';
      await _supabaseClient.storage.from('profiles').remove([oldFileName]);

      await _supabaseClient
          .from('profiles')
          .update({'profile_picture': imageUrl}).eq(
              'id', _supabaseClient.auth.currentUser!.id);

      // ignore: use_build_context_synchronously
      MyToast.showToast(context, 'Profile picture updated successfully!');

      // Refresh profile data to show updated image
      _fetchProfileData();
    } catch (error) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile picture: $error')),
      );
    }
  }

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
        // Navigate to Scholarships page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ChatScreen()),
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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return DefaultTabController(
      length: 2,
      // ignore: deprecated_member_use
      child: WillPopScope(
        onWillPop: () async {
          // Navigate back to the homepage when the back button is pressed
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const HomePage()),
            (Route<dynamic> route) => false, // Remove all previous routes
          );
          return false; // Prevent default back navigation
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            toolbarHeight: screenHeight * 0.12,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF0D47A1)),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                );
              },
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    SvgPicture.asset(
                      'assets/images/reslocate_logo.svg',
                      height: screenHeight * 0.06,
                    ),
                    const SizedBox(width: 10),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Profile',
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
              ],
            ),
            bottom: const TabBar(
              tabs: [
                Tab(text: 'Personal Info'),
                Tab(text: 'Education'),
              ],
              indicatorColor: Color(0xFF0D47A1),
              labelColor: Color(0xFF0D47A1),
              unselectedLabelColor: Color.fromARGB(179, 53, 51, 51),
            ),
          ),
          body: isLoading
              ? const Center(child: BouncingImageLoader())
              : TabBarView(
                  children: [
                    _buildPersonalInfoTab(screenWidth),
                    _buildEducationTab(screenWidth),
                  ],
                ),
          bottomNavigationBar: CustomBottomNavigationBar(
            selectedIndex: _selectedIndex,
            onItemTapped: _onItemTapped,
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalInfoTab(double screenWidth) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(screenWidth * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: GestureDetector(
              onTap: _pickImage,
              child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: Stack(
                    alignment: Alignment
                        .bottomRight, // Aligns the icon to the bottom-right corner
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: NetworkImage(
                          profileData['profile_picture'] ?? defaultProfileUrl,
                        ),
                      ),
                      // Container for the edit icon with transparency
                      Container(
                        width: 30, // Smaller width for the circular background
                        height:
                            30, // Smaller height for the circular background
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              Color(0xFF0D47A1), // Blue color with 70% opacity
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.edit,
                            color: Colors.white, // Icon color
                            size: 16, // Adjust the icon size to be smaller
                          ),
                          onPressed: () {
                            // Add your edit profile picture functionality here
                          },
                          padding: EdgeInsets
                              .zero, // Removes extra padding around the icon
                          constraints:
                              const BoxConstraints(), // Removes constraints to size the icon
                        ),
                      ),
                    ],
                  )),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Column(
              children: [
                Text(
                  "${profileData['first_name']} ${profileData['last_name']}",
                  style: TextStyle(
                    fontSize: screenWidth * 0.07,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0D47A1),
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 5),
              ],
            ),
          ),
          const SizedBox(height: 30),
          _buildCoolProfileItem(
              Icons.person, 'First Name', profileData['first_name']),
          _buildCoolProfileItem(
              Icons.person_outline, 'Last Name', profileData['last_name']),
          _buildCoolProfileItem(
              Icons.phone, 'Phone Number', profileData['phone_number']),
          _buildCoolProfileItem(Icons.school, 'School', profileData['school']),
          _buildCoolProfileItem(Icons.calendar_today, 'Date of Birth',
              profileData['date_of_birth']),
          _buildCoolProfileItem(
              Icons.transgender, 'Gender', profileData['gender']),
          _buildCoolProfileItem(Icons.people, 'Race', profileData['race']),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 20),
              child: SizedBox(
                width: 200, // Fixed width for both buttons
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            EditProfilePage(profileData: profileData),
                      ),
                    );
                  }, // Added icon since it's ElevatedButton.icon
                  label: const Text('Edit Profile'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color(0xFF0D47A1),
                    elevation: 2,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50.0, vertical: 15),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 20),
              child: SizedBox(
                width: 200, // Same fixed width as above
                child: ElevatedButton.icon(
                  onPressed: () {
                    _confirmSignOut(context);
                  },
                  label: const Text('Sign Out'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color(0xFF0D47A1),
                    elevation: 2,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50.0, vertical: 15),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 20),
              child: SizedBox(
                width: 200, // Same fixed width as above
                child: ElevatedButton.icon(
                  onPressed: () {
                    _confirmDeleteAccount(context);
                  },
                  label: const Text('Delete Account'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.red,
                    elevation: 2,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 25.0, vertical: 15),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEducationTab(double screenWidth) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // School and Grade Section with a gradient card
          _buildCoolProfileItem(Icons.school, 'School', profileData['school']),
          _buildCoolProfileItem(
              Icons.grade, 'Grade', profileData['grade']?.toString()),
          const SizedBox(height: 16),
          const Align(
            alignment: Alignment.center,
            child: Text(
              "Your Subjects And Marks",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D47A1),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Marks Section
          if (marksData['math_mark'] != null && marksData['math_type'] != null)
            _buildCoolProfileItem(Icons.calculate, marksData['math_type'],
                marksData['math_mark']?.toString()),
          if (marksData['home_language_mark'] != null &&
              marksData['home_language'] != null)
            _buildCoolProfileItem(Icons.language, marksData['home_language'],
                marksData['home_language_mark']?.toString()),
          if (marksData['first_additional_language_mark'] != null &&
              marksData['first_additional_language'] != null)
            _buildCoolProfileItem(
                Icons.language,
                marksData['first_additional_language'],
                marksData['first_additional_language_mark']?.toString()),
          if (marksData['subject1'] != 'None' &&
              marksData['subject1_mark'] != null)
            _buildCoolProfileItem(Icons.book, marksData['subject1'],
                marksData['subject1_mark']?.toString()),
          if (marksData['subject2'] != 'None' &&
              marksData['subject2_mark'] != null)
            _buildCoolProfileItem(Icons.book, marksData['subject2'],
                marksData['subject2_mark']?.toString()),
          if (marksData['subject3'] != 'None' &&
              marksData['subject3_mark'] != null)
            _buildCoolProfileItem(Icons.book, marksData['subject3'],
                marksData['subject3_mark']?.toString()),
          if (marksData['life_orientation_mark'] != null)
            _buildCoolProfileItem(Icons.book, 'Life Orientation',
                marksData['life_orientation_mark']?.toString()),
          if (marksData['second_additional_language'] != 'None' &&
              marksData['second_additional_language_mark'] != null)
            _buildCoolProfileItem(
                Icons.book,
                marksData['second_additional_language'],
                marksData['second_additional_language_mark']?.toString()),
          if (marksData['subject4'] != 'None' &&
              marksData['subject4_mark'] != null)
            _buildCoolProfileItem(Icons.book, marksData['subject4'],
                marksData['subject4_mark']?.toString()),

          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 20),
              child: SizedBox(
                width: 200, // Fixed width for both buttons
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            EditProfilePage(profileData: profileData),
                      ),
                    );
                  }, // Added icon since it's ElevatedButton.icon
                  label: const Text('Edit Profile'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color(0xFF0D47A1),
                    elevation: 2,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50.0, vertical: 15),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 20),
              child: SizedBox(
                width: 200, // Same fixed width as above
                child: ElevatedButton.icon(
                  onPressed: () {
                    _confirmSignOut(context);
                  },
                  label: const Text('Sign Out'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color(0xFF0D47A1),
                    elevation: 2,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50.0, vertical: 15),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 20),
              child: SizedBox(
                width: 200, // Same fixed width as above
                child: ElevatedButton.icon(
                  onPressed: () {
                    _confirmDeleteAccount(context);
                  },
                  label: const Text('Delete account'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.red,
                    elevation: 2,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 25.0, vertical: 15),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoolProfileItem(IconData icon, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Card(
        color: const Color(0xFFE3F2FA).withOpacity(0.4),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          leading: Icon(icon, color: const Color(0xFF0D47A1)),
          title: Text(
            label,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          subtitle: Text(
            value ?? 'Not available',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon or Illustration (optional)
                const Icon(
                  Icons.exit_to_app,
                  color: Colors.redAccent,
                  size: 48,
                ),
                const SizedBox(height: 16),

                // Title
                const Text(
                  'Confirm Sign Out',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Content
                const Text(
                  'Are you sure you want to sign out?',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Cancel Button
                    TextButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop(false); // Cancel
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: Colors.grey),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    // Confirm Button
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(dialogContext)
                            .pop(true); // Confirm sign out
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Sign Out',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    // Proceed with sign-out if the user confirms
    if (shouldSignOut == true) {
      // ignore: use_build_context_synchronously
      await _signOut(context);
    }
  }

  Future<void> _confirmDeleteAccount(BuildContext context) async {
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon or Illustration (optional)
                const Icon(
                  Icons.exit_to_app,
                  color: Colors.redAccent,
                  size: 48,
                ),
                const SizedBox(height: 16),

                // Title
                const Text(
                  'Confirm Account Deletion',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Content
                const Text(
                  'Are you sure you want to delete your account?',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Buttons
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Cancel Button
                    TextButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop(false); // Cancel
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: Colors.grey),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Confirm Button
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(dialogContext)
                            .pop(true); // Confirm sign out
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Delete account',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    // Proceed with sign-out if the user confirms
    if (shouldSignOut == true) {
      // ignore: use_build_context_synchronously
      await deleteAccount();
    }
  }

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

  //account deletion function
  Future<void> deleteAccount() async {
    try {
      final response = await supabase.rpc('delete_account', params: {
        'user_id': supabase.auth.currentUser!.id,
      });

      // Print response for debugging
      print('Delete account response: $response');

      // Check if response is a Map and safely access values
      if (response is Map) {
        final status = response['status']?.toString();
        final message =
            response['message']?.toString() ?? 'Unknown error occurred';

        if (status == 'success') {
          // Handle successful deletion
          await supabase.auth.signOut();
          if (mounted) {
            Navigator.pushReplacement(
              // ignore: use_build_context_synchronously
              context,
              MaterialPageRoute(builder: (_) => const LoginPage()),
            );
            MyToast.showToast(context, 'Account deleted successfully');
          }
        } else {
          // Handle error
          if (mounted) {
            MyToast.showToast(context, 'Error: $message');
          }
        }
      } else {
        throw 'Unexpected response format';
      }
    } catch (e) {
      print('Delete account error: $e'); // Add logging for debugging
      if (mounted) {
        MyToast.showToast(context, 'Error deleting account: ${e.toString()}');
      }
    }
  }

// Function to show confirmation dialog
  Future<void> confirmDeleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Account'),
          content: Text(
            'Are you sure you want to delete your account? '
            'This action cannot be undone and will permanently remove all your data.',
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await deleteAccount();
    }
  }
}
