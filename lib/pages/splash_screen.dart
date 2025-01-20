import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:reslocate/pages/login_page.dart';
import 'package:reslocate/pages/signup_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  final int currentIndex = 0;

  final List<Map<String, String>> slides = [
    {
      "title": "Hello",
      "description":
          "Welcome to Reslocate! Your one-stop shop for education and career development.",
      "image": "assets/images/splash_1.svg"
    },
    {
      "title": "Level up your options",
      "description":
          "Discover private colleges and housing that fit your goals.",
      "image": "assets/images/splash_2.svg"
    },
    {
      "title": "Unlock your potential",
      "description":
          "Get personalized tertiary matches, scholarships, and career guidance.",
      "image": "assets/images/splash_3.svg"
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Screen size to adapt the layout based on device size
    final size = MediaQuery.of(context).size;
    final isLargeScreen = size.width > 600;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Column(
        children: [
          SizedBox(
              height: isLargeScreen ? size.height * 0.1 : size.height * 0.08),
          Expanded(
            flex: 8,
            child: PageView.builder(
              itemCount: slides.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.05,
                    vertical: size.height * 0.01,
                  ),
                  child: Column(
                    children: [
                      Text(
                        slides[index]["title"]!,
                        style: TextStyle(
                          fontSize: isLargeScreen ? 32 : 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[900],
                        ),
                      ),
                      SizedBox(height: size.height * 0.02),
                      Text(
                        slides[index]["description"]!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isLargeScreen ? 18 : 16,
                          color: Colors.black,
                        ),
                      ),
                      const Spacer(),
                      SvgPicture.asset(
                        slides[index]["image"]!,
                        height: isLargeScreen ? 400 : 240,
                      ),
                      SizedBox(height: size.height * 0.03),
                    ],
                  ),
                );
              },
            ),
          ),
          const Spacer(),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[900],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.1,
                vertical: size.height * 0.02,
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SignupPage()),
              );
            },
            child: Text(
              'Get Started',
              style: TextStyle(
                fontSize: isLargeScreen ? 20 : 18,
                color: const Color.fromARGB(255, 255, 255, 255),
              ),
            ),
          ),
          SizedBox(height: size.height * 0.02),

          // Already have an account? Log In link
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Already have an account?'),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
                child: const Text(
                  'Log In',
                  style: TextStyle(
                    color: Color(0xFF0D47A1),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: size.height * 0.04),
        ],
      ),
    );
  }
}
