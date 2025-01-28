import 'package:flutter/material.dart';
import 'package:reslocate/pages/logo_screen.dart';
import 'package:reslocate/pages/homepage.dart';
import 'package:reslocate/pages/account_page.dart';
import 'package:reslocate/pages/careerAspirations.dart';
import 'package:reslocate/pages/EnterMarksPage.dart';
import 'package:reslocate/pages/academicChallenges.dart';
import 'package:reslocate/pages/almostDone.dart';
import 'package:reslocate/pages/parent_pages/parent_homepage.dart';
import 'package:reslocate/widgets/loadingAnimation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'utils/connectivity_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "private.env");

  String supabaseApiKey = dotenv.env['SUPABASE_API_KEY'] ?? '';
  String supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  await Supabase.initialize(url: supabaseApiKey, anonKey: supabaseAnonKey);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ConnectivityProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reslocate',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
        primaryColor: Colors.green,
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.green,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.green,
          ),
        ),
      ),
      builder: (context, child) {
        return Consumer<ConnectivityProvider>(
          builder: (context, connectivity, _) {
            if (!connectivity.isOnline) {
              // Show offline screen when no internet
              return WillPopScope(
                onWillPop: () async => false, // Prevent back button
                child: MaterialApp(
                  debugShowCheckedModeBanner: false,
                  home: Scaffold(
                    backgroundColor: Colors.white,
                    body: SafeArea(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Spacer(),
                            Icon(
                              Icons.wifi_off,
                              size: 100,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 32),
                            const Text(
                              'No Internet Connection',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0D47A1),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 32),
                              child: Text(
                                'Please check your internet connection and try again',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),
                            ElevatedButton.icon(
                              onPressed: () async {
                                // Check connectivity
                                final isOnline =
                                    await connectivity.checkConnectivity();

                                if (!context.mounted) return;

                                if (isOnline) {
                                  // If online, rebuild the app
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const AuthenticationWrapper(),
                                    ),
                                  );
                                } else {}
                              },
                              icon: const Icon(Icons.refresh),
                              label: const Text('Try Again'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0D47A1),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                            ),
                            const Spacer(),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                'Reslocate needs an internet connection to work',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }

            // Show normal app when online
            return child ?? const SizedBox();
          },
        );
      },
      home: const AuthenticationWrapper(),
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({super.key});

  Future<Widget> _checkUserProfileCompletion(BuildContext context) async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      return const LogoScreen();
    }

    try {
      // First check if user is a parent
      final roleResponse = await supabase
          .from('profiles')
          .select('is_parent')
          .eq('id', user.id)
          .single();

      // Get full profile data
      final profileResponse = await supabase.from('profiles').select('''
            first_name,
            last_name,
            phone_number,
            school,
            grade,
            date_of_birth,
            career_asp1,
            acad_chal1,
            race,
            gender,
            hobby1,
            is_parent
          ''').eq('id', user.id).single();

      // Check if user is a parent
      if (profileResponse['is_parent'] == true) {
        // Parent-specific flow
        return const ParentHomepage();
      }

      final marksResponse = await supabase
          .from('user_marks')
          .select('life_orientation_mark')
          .eq('user_id', user.id)
          .maybeSingle();

      // Basic profile completion check for learners
      if (profileResponse.isEmpty ||
          profileResponse['first_name'] == null ||
          profileResponse['last_name'] == null ||
          profileResponse['phone_number'] == null ||
          profileResponse['date_of_birth'] == null) {
        return const AccountPage();
      }

      if (profileResponse['school'] == null ||
          profileResponse['grade'] == null) {
        return const AccountPage();
      }

      if (profileResponse['career_asp1'] == null) {
        return const CareerAspirationsPage();
      }

      if (marksResponse == null || marksResponse.isEmpty) {
        return const EnterMarksPage();
      }

      if (profileResponse['acad_chal1'] == null) {
        return const AcademicChallengesPage();
      }

      if (profileResponse['race'] == null ||
          profileResponse['gender'] == null ||
          profileResponse['hobby1'] == null) {
        return const PersonalInfoPage();
      }

      return const HomePage(); // Learner homepage
    } catch (e) {
      if (!context.mounted) return const AccountPage();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Error checking profile: ${e.toString()}'),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
      return const AccountPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _checkUserProfileCompletion(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: BouncingImageLoader(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text(
                    'Error Loading Profile',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AuthenticationWrapper(),
                        ),
                      );
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        return snapshot.data ?? const LogoScreen();
      },
    );
  }
}
