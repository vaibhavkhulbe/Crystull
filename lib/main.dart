import 'dart:developer';

import 'package:crystull/providers/user_provider.dart';
import 'package:crystull/responsive/mobile_screen_layout.dart';
import 'package:crystull/responsive/response_layout_screen.dart';
import 'package:crystull/responsive/web_screen_layout.dart';
import 'package:crystull/screens/login_screen.dart';
import 'package:crystull/screens/onboarding_screen.dart';
import 'package:crystull/utils/config.dart';
import 'package:crystull/utils/colors.dart';
import 'package:crystull/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: apiKey,
        appId: appId,
        messagingSenderId: messagingSenderId,
        projectId: projectId,
        storageBucket: storageBucket,
      ),
    );
  } else {
    await Firebase.initializeApp();
  }
  final pref = await SharedPreferences.getInstance();
  final onboardingDone = pref.getBool('onboardingDone') ?? false;
  // pref.setBool('onboardingDone', false);
  runApp(MyApp(onboardingDone: onboardingDone));
}

class MyApp extends StatelessWidget {
  final bool onboardingDone;
  const MyApp({Key? key, required this.onboardingDone}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => UserProvider(),
        )
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Cyrstull',
        theme: ThemeData.dark()
            .copyWith(scaffoldBackgroundColor: mobileBackgroundColor),
        // home:
        home: !onboardingDone
            ? const OnboardingScreen()
            : StreamBuilder(
                stream: FirebaseAuth.instance.userChanges(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.active) {
                    if (snapshot.hasData) {
                      // log("Snapshot data: ${snapshot.data}");
                      return ResponsiveLayout(
                          webScreenLayout: const WebScreenLayout(),
                          mobileScreenLayout: MobileScreenLayout());
                    } else if (snapshot.hasError) {
                      log("Snapshot error: ${snapshot.error}");
                      return Center(
                        child: Text(
                          'Error: ${snapshot.error}',
                        ),
                      );
                    }
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return SafeArea(
                      child: Container(
                        height: getSafeAreaHeight(context),
                        width: getSafeAreaWidth(context),
                        color: mobileBackgroundColor,
                        child: const Center(
                            child: CircularProgressIndicator(
                          color: primaryColor,
                          backgroundColor: mobileBackgroundColor,
                        )),
                      ),
                    );
                  }
                  log("Snapshot connection state: ${snapshot.connectionState}");
                  return const LoginScreen();
                },
              ),
      ),
    );
  }
}
