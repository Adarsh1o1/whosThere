import 'package:flutter/material.dart';
import 'package:flutter_app/home.dart';
import 'package:flutter_app/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';

void main() async {
  // runApp(const MyApp());
  WidgetsFlutterBinding.ensureInitialized();
  await setOptimalDisplayMode();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor: Color(0xFFD2E2E2), // Set your custom color here
    systemNavigationBarIconBrightness:
    Brightness.light, // Set icon color (light/dark)
  ));
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var token = prefs.getString("token");
  if (token != null){
    runApp(const MyAppLoggedIn());
  } else{
    runApp(const MyApp());
  }

}

class MyApp extends StatelessWidget {

  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor:  Color(0xffD2E2E2)),
        useMaterial3: true,
        fontFamily: 'sf'
      ),
      home: LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}


class MyAppLoggedIn extends StatelessWidget {
  const MyAppLoggedIn({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor:  Color(0xffD2E2E2)),
          useMaterial3: true,
          fontFamily: 'sf'
      ),
      home: homepage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

Future<void> setOptimalDisplayMode() async {
  try {
    // Fetch available display modes
    final List<DisplayMode> modes = await FlutterDisplayMode.supported;
    print(modes);
    // Sort modes by the highest refresh rate first
    modes.sort((a, b) => b.refreshRate.compareTo(a.refreshRate));

    // Set the mode with the highest refresh rate
    if (modes.isNotEmpty) {
      await FlutterDisplayMode.setPreferredMode(modes.first);
    }
  } catch (e) {
    print('Failed to set display mode: $e');
  }
}