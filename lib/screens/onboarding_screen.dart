import 'package:crystull/responsive/mobile_screen_layout.dart';
import 'package:crystull/responsive/response_layout_screen.dart';
import 'package:crystull/responsive/web_screen_layout.dart';
import 'package:crystull/screens/signup_screen.dart';
import 'package:crystull/utils/colors.dart';
import 'package:crystull/utils/utils.dart';
import 'package:crystull/widgets/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  bool isLastPage = false;
  bool isFirstPage = true;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: !isFirstPage
          ? AppBar(
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: color575757),
                onPressed: () => _pageController.previousPage(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut),
              ),
              backgroundColor: mobileBackgroundColor,
            )
          : AppBar(
              elevation: 0,
              backgroundColor: mobileBackgroundColor,
              automaticallyImplyLeading: false,
            ),
      body: Container(
        padding: const EdgeInsets.only(bottom: 25),
        child: PageView(
          onPageChanged: (page) {
            setState(() {
              isLastPage = page == 2;
              isFirstPage = page == 0;
            });
          },
          controller: _pageController,
          children: [
            buildPage("images/onboarding/1.svg", "Personal Development",
                "Makes your personal development journey easy"),
            buildPage("images/onboarding/2.svg", "Contribution to society",
                "Help people around you to improve themselves"),
            buildPage("images/onboarding/3.svg", "Honest and trasnparent",
                "Feedback become more honest and transparent with Crystull"),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(vertical: 35, horizontal: 30),
        decoration: const BoxDecoration(
          color: mobileBackgroundColor,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(25),
            bottomRight: Radius.circular(25),
          ),
        ),
        child: isLastPage
            ? TextButton(
                onPressed: (() async {
                  final pref = await SharedPreferences.getInstance();
                  pref.setBool('onboardingDone', true);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SignupScreen(),
                    ),
                  );
                }),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  padding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: primaryColor,
                  ),
                  child: const Text(
                    'Get Started',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: "Poppins",
                      fontSize: 18,
                      height: 1.5,
                      letterSpacing: -0.015,
                      fontWeight: FontWeight.w600,
                      color: mobileBackgroundColor,
                    ),
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => _pageController.jumpToPage(2),
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 14,
                        height: 1.5,
                        letterSpacing: -0.015,
                        fontWeight: FontWeight.w400,
                        color: color808080,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _pageController.nextPage(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: primaryColor,
                      ),
                      child: const Text(
                        'Next',
                        style: TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 18,
                          height: 1.5,
                          letterSpacing: -0.015,
                          fontWeight: FontWeight.w600,
                          color: mobileBackgroundColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget buildPage(String imageUrl, String title, String description) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(imageUrl, height: 300, width: 220),
        const SizedBox(height: 60),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: "Poppins",
            fontSize: 20,
            height: 1.5,
            fontWeight: FontWeight.w600,
            color: primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.7,
          child: Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: "Poppins",
              fontSize: 16,
              height: 1.5,
              fontWeight: FontWeight.w400,
              color: color808080,
            ),
          ),
        ),
        const SizedBox(height: 60),
      ],
    );
  }
}
